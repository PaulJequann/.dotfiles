# Multi-OS Dotfiles Restructure Plan

## Executive Summary

Restructure `~/.dotfiles` from a messy single-package structure to a modular, multi-OS architecture using GNU Stow. This will support macOS, WSL2, and Arch Linux with a single main branch, DRY principles, and seamless device_configs integration.

**Strategy:** Modular common packages + platform-specific overlays, orchestrated by an OS-detecting bootstrap script.

---

## Current State Analysis

**Repository:** `/home/pj/.dotfiles` (already using stow, but unorganized)

**Current Issues:**
- Mixed OS logic in `.zshrc` (Homebrew plugin line 13, hardcoded `/home/pj` line 32, macOS path line 48, Flatpak line 52)
- No credential helper in `.gitconfig` (needs platform-specific)
- Alacritty uses Command key (macOS-only, line 7+)
- Arch-specific packages mixed with portable configs

**What Works:**
- `tmux/.tmux.conf` - fully portable
- `nvim/.config/nvim/` - fully portable lua config
- `bin/.local/bin/tmux-sessionizer` - works everywhere (same ~/dev structure)
- `git/.gitconfig` - portable base config

---

## Proposed Structure

```
~/.dotfiles/
├── bootstrap.sh                    # OS-detecting bootstrap script ⭐
├── .stow-local-ignore             # Exclude bootstrap from stowing
├── README.md                       # Updated usage docs
│
├── common-zsh/                     # Portable zsh (OS detection inside)
│   ├── .zshrc                      # Main rc with conditional sourcing
│   ├── .zprofile                   # Portable profile
│   └── .config/zsh/
│       ├── core.zsh               # NVM, pyenv (portable)
│       └── aliases.zsh            # Portable aliases
│
├── common-git/                     # Git base config
│   └── .gitconfig                  # No credential helper (uses include)
│
├── common-tmux/                    # Tmux config
│   └── .tmux.conf
│
├── common-nvim/                    # Neovim config
│   └── .config/nvim/               # Existing lua setup
│
├── common-bin/                     # Portable scripts
│   └── .local/bin/
│       └── tmux-sessionizer
│
├── platform-macos/                 # macOS-specific
│   ├── .config/zsh/
│   │   └── macos.zsh              # Homebrew, gam alias
│   ├── .config/alacritty/
│   │   └── alacritty.toml         # Command key bindings
│   └── .gitconfig.d/
│       └── credentials            # osxkeychain helper
│
├── platform-wsl/                   # WSL2-specific
│   ├── .config/zsh/
│   │   └── wsl.zsh                # SSH agent, WSL paths
│   └── .gitconfig.d/
│       └── credentials            # wincred or manager
│
├── platform-arch/                  # Arch-specific
│   ├── .config/zsh/
│   │   └── arch.zsh               # Flatpak XDG_DATA_DIRS
│   ├── .config/alacritty/
│   │   └── alacritty.toml         # Control key bindings
│   ├── .gitconfig.d/
│   │   └── credentials            # store helper
│   └── .local/bin/
│       └── boot-to-windows        # efibootmgr script
│
└── arch-hyprland/                  # Hyprland desktop configs
    └── .config/
        ├── hypr/
        ├── waybar/
        ├── mako/
        ├── nwg-dock-hyprland/
        └── sunshine/
```

**Design Rationale:**
- **Modular common-\***: Granular control, better failure isolation, devcontainer-friendly
- **Platform overlays**: OS-specific files layer on top, no duplication
- **Single .zshrc**: Uses OS detection to source platform snippets (cleaner than multiple .zshrc files)

---

## Critical Files to Create/Modify

### 1. `/home/pj/.dotfiles/bootstrap.sh` ⭐

**Purpose:** OS detection + smart stow orchestration

**Key Features:**
- Detect OS: macOS (Darwin), WSL2 (grep microsoft /proc/version), Arch (/etc/arch-release)
- Stow packages based on OS: `common-*` + `platform-{macos,wsl,arch}` + `arch-hyprland` (if Hyprland detected)
- Dry-run, unstow, and force options
- Pre-flight checks (stow installed, conflict detection)
- Clean failure messages

**Stow Logic:**
```bash
# Example: WSL2 on this machine
stow common-zsh common-git common-tmux common-nvim common-bin platform-wsl

# Example: Arch with Hyprland
stow common-zsh common-git common-tmux common-nvim common-bin platform-arch arch-hyprland
```

### 2. `/home/pj/.dotfiles/common-zsh/.zshrc`

**CRITICAL: PATH must be configured FIRST** - before zgenom, before plugins, before anything else. This ensures device_configs tools (task, claude, bd, git, nvim, etc.) are immediately available.

**Structure:**
```bash
# =============================================================================
# PATH Configuration (MUST BE FIRST)
# =============================================================================
# Essential PATH for device_configs tools (task, claude, bd, etc.)
export PATH="$HOME/.local/bin:$PATH"           # User binaries
export PATH="/usr/local/bin:$PATH"             # System-wide custom binaries

# Platform-specific PATH
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Homebrew paths
    export PATH="/opt/homebrew/bin:$PATH"      # Apple Silicon
    export PATH="/opt/homebrew/sbin:$PATH"
fi

# =============================================================================
# zgenom Plugin Manager
# =============================================================================
source "${HOME}/.zgenom/zgenom.zsh"

ZSH_DISABLE_COMPFIX=true

if ! zgenom saved; then
    zgenom ohmyzsh
    zgenom ohmyzsh plugins/history
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/dirhistory

    # Conditional Homebrew plugin (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        zgenom ohmyzsh plugins/brew
    fi

    zgenom load zdharma/fast-syntax-highlighting
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load spaceship-prompt/spaceship-prompt

    zgenom save
fi

# =============================================================================
# Modular Configuration
# =============================================================================
ZSHCONFIG="$HOME/.config/zsh"
[ -f "$ZSHCONFIG/core.zsh" ] && source "$ZSHCONFIG/core.zsh"
[ -f "$ZSHCONFIG/aliases.zsh" ] && source "$ZSHCONFIG/aliases.zsh"

# =============================================================================
# Platform-Specific Configuration
# =============================================================================
case "$(uname -s)" in
    Darwin)
        [ -f "$ZSHCONFIG/macos.zsh" ] && source "$ZSHCONFIG/macos.zsh"
        ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            [ -f "$ZSHCONFIG/wsl.zsh" ] && source "$ZSHCONFIG/wsl.zsh"
        elif [ -f /etc/arch-release ]; then
            [ -f "$ZSHCONFIG/arch.zsh" ] && source "$ZSHCONFIG/arch.zsh"
        fi
        ;;
esac

# =============================================================================
# Common Keybindings
# =============================================================================
bindkey -s ^f "tmux-sessionizer\n"
```

**Changes from current:**
- **PATH FIRST:** All PATH configuration at the top, before zgenom
- **Conditional Homebrew plugin:** Only load on macOS
- **Modular sourcing:** Load core.zsh, aliases.zsh, then platform-specific
- **Remove platform-specific lines:** Move gam alias to macos.zsh, XDG_DATA_DIRS to arch.zsh, SSH agent to wsl.zsh
- **Clear sections:** Organized with clear comments for maintainability

### 3. `/home/pj/.dotfiles/common-zsh/.config/zsh/core.zsh`

**Purpose:** Runtime environment setup (NVM, pyenv) - these extend PATH further

```bash
# =============================================================================
# NVM (Node Version Manager)
# =============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # nvm bash completion

# =============================================================================
# Pyenv (Python Version Manager)
# =============================================================================
export PATH="$HOME/.pyenv/bin:$PATH"  # Add pyenv to PATH

# Initialize pyenv if available
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi

# Initialize pyenv-virtualenv if available
if command -v pyenv-virtualenv &>/dev/null; then
    eval "$(pyenv virtualenv-init -)"
fi
```

**Key Changes:**
- Use `$HOME` instead of hardcoded `/home/pj` or `/Users/pj`
- Uncommented NVM setup (was commented in original)
- Command checks before init to avoid errors if tools not installed
- Clear comments for each section

### 4. `/home/pj/.dotfiles/common-zsh/.config/zsh/aliases.zsh`

**Extract from current .zshrc:**
- vim='nvim'
- ls='ls -la'
- SOPS_AGE_KEY_FILE export

### 5. `/home/pj/.dotfiles/platform-macos/.config/zsh/macos.zsh`

**macOS-specific items:**
```bash
# =============================================================================
# macOS-Specific Configuration
# =============================================================================

# Homebrew environment (PATH already set in main .zshrc)
if command -v brew &>/dev/null; then
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# GAM (Google Workspace Admin tool)
alias gam="$HOME/bin/gamadv-xtd3/gam"
```

**Notes:**
- Homebrew PATH already configured in main .zshrc (no duplication)
- GAM alias uses `$HOME` instead of hardcoded `/Users/pj`

### 6. `/home/pj/.dotfiles/platform-wsl/.config/zsh/wsl.zsh`

**WSL-specific items (from current .zshrc lines 55-64):**
```bash
# SSH agent management
if [ -z "$SSH_AUTH_SOCK" ]; then
    RUNNING_AGENT="$(ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')"
    if [ "$RUNNING_AGENT" = "0" ]; then
        ssh-agent -s &> "$HOME/.ssh/ssh-agent"
    fi
    eval "$(cat "$HOME/.ssh/ssh-agent")" > /dev/null
    ssh-add 2> /dev/null
fi

# WSL-specific paths
export PATH="$PATH:/mnt/c/Windows/System32"
```

### 7. `/home/pj/.dotfiles/platform-arch/.config/zsh/arch.zsh`

**Arch-specific items (from current .zshrc line 52):**
```bash
# Flatpak XDG directories
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"

# Arch aliases
alias pacman='sudo pacman'
alias yay='yay --sudoloop'
```

### 8. `/home/pj/.dotfiles/common-git/.gitconfig`

**Add conditional include (after line 12):**
```ini
[include]
    # Platform-specific credential helpers
    path = ~/.gitconfig.d/credentials
```

### 9. Platform Credential Files

**`platform-macos/.gitconfig.d/credentials`:**
```ini
[credential]
    helper = osxkeychain
```

**`platform-wsl/.gitconfig.d/credentials`:**
```ini
[credential]
    helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
```

**`platform-arch/.gitconfig.d/credentials`:**
```ini
[credential]
    helper = store
```

### 10. `/home/pj/.dotfiles/.stow-local-ignore`

**Ignore bootstrap files:**
```
README.md
bootstrap.sh
Taskfile.yml
.git
.gitignore
RESTRUCTURE_PLAN.md
```

### 11. `/home/pj/.dotfiles/README.md`

**Update with:**
- Quick start: `git clone ... && cd ~/.dotfiles && ./bootstrap.sh`
- Structure explanation
- Bootstrap options (--dry-run, --unstow)
- Supported platforms

### 12. `~/dev/device_configs/.taskfiles/common.yml`

**Update dotfiles task (replace `stow .` logic):**
```yaml
dotfiles:
  desc: Clone and setup dotfiles
  cmds:
    - |
      if [ ! -d "{{.DOTFILES_DIR}}" ]; then
        echo "📁 Cloning dotfiles repository..."
        git clone {{.DOTFILES_REPO}} {{.DOTFILES_DIR}} > /dev/null 2>&1
      else
        cd {{.DOTFILES_DIR}} && git pull > /dev/null 2>&1
      fi
    - |
      if [ -f "{{.DOTFILES_DIR}}/bootstrap.sh" ]; then
        echo "🔗 Bootstrapping dotfiles..."
        bash "{{.DOTFILES_DIR}}/bootstrap.sh"
      else
        # Fallback for backwards compatibility
        if command -v stow &> /dev/null; then
          echo "🔗 Stowing dotfiles..."
          cd {{.DOTFILES_DIR}} && stow . 2>/dev/null
        fi
      fi
```

---

## Migration Steps (Idempotent & Safe)

### Phase 1: Backup (No Destructive Changes)

1. **Create backup branch:**
   ```bash
   cd ~/.dotfiles
   git checkout -b backup-pre-restructure
   git push -u origin backup-pre-restructure
   git checkout main
   ```

2. **Unstow current structure:**
   ```bash
   cd ~/.dotfiles
   for pkg in zsh git tmux nvim bin alacritty hypr waybar mako nwg-dock-hyprland sunshine windows; do
       stow -D "$pkg" 2>/dev/null || true
   done
   ```

### Phase 2: Create New Structure

3. **Create package directories:**
   ```bash
   mkdir -p common-{zsh,git,tmux,nvim,bin}
   mkdir -p platform-{macos,wsl,arch}
   mkdir -p arch-hyprland
   mkdir -p common-zsh/.config/zsh
   mkdir -p platform-{macos,wsl,arch}/.config/zsh
   mkdir -p platform-{macos,wsl,arch}/.gitconfig.d
   mkdir -p platform-macos/.config/alacritty
   mkdir -p platform-arch/.config/alacritty
   mkdir -p platform-arch/.local/bin
   ```

4. **Move portable packages:**
   ```bash
   # Git
   mv git/.gitconfig common-git/

   # Tmux
   mv tmux/.tmux.conf common-tmux/

   # Neovim
   mv nvim/.config common-nvim/

   # Bin
   mv bin/.local common-bin/

   # Hyprland configs to arch-hyprland
   mkdir -p arch-hyprland/.config
   mv hypr waybar mako nwg-dock-hyprland sunshine arch-hyprland/.config/
   ```

5. **Handle Alacritty:**
   ```bash
   # Copy to macOS (current config is macOS)
   cp -r alacritty/.config/alacritty platform-macos/.config/

   # Copy to arch, will edit keybindings later
   cp -r alacritty/.config/alacritty platform-arch/.config/
   ```

6. **Move Zsh (will be manually edited):**
   ```bash
   cp zsh/.zshrc common-zsh/
   cp zsh/.zprofile common-zsh/
   ```

### Phase 3: Create New Files

7. **Create modular zsh configs:**
   - Create `common-zsh/.config/zsh/core.zsh` (NVM, pyenv)
   - Create `common-zsh/.config/zsh/aliases.zsh` (vim, ls, SOPS)
   - Create `platform-macos/.config/zsh/macos.zsh` (Homebrew, gam)
   - Create `platform-wsl/.config/zsh/wsl.zsh` (SSH agent)
   - Create `platform-arch/.config/zsh/arch.zsh` (Flatpak)

8. **Edit `common-zsh/.zshrc`:**
   - Add conditional Homebrew plugin
   - Fix pyenv path to use `$HOME`
   - Add sourcing logic for core.zsh, aliases.zsh, and platform-specific
   - Remove platform-specific lines (gam, XDG_DATA_DIRS, SSH agent)

9. **Create git credential helpers:**
   - Create `platform-macos/.gitconfig.d/credentials`
   - Create `platform-wsl/.gitconfig.d/credentials`
   - Create `platform-arch/.gitconfig.d/credentials`

10. **Edit `common-git/.gitconfig`:**
    - Add `[include] path = ~/.gitconfig.d/credentials`

11. **Edit Alacritty configs:**
    - `platform-arch/.config/alacritty/alacritty.toml`: Change all `mods = "Command"` to `mods = "Control"`

12. **Create bootstrap.sh:**
    - Implement OS detection (Darwin, WSL2, Arch)
    - Implement stow logic
    - Add dry-run, unstow, force options
    - Add conflict detection

13. **Create `.stow-local-ignore`**

14. **Move boot-to-windows script:**
    ```bash
    mv windows/windows.sh platform-arch/.local/bin/boot-to-windows
    ```

### Phase 4: Test & Verify

15. **Test bootstrap (dry-run):**
    ```bash
    chmod +x bootstrap.sh
    ./bootstrap.sh --dry-run
    ```

16. **Test bootstrap (real):**
    ```bash
    ./bootstrap.sh
    ```

17. **Verify zsh:**
    ```bash
    exec zsh
    zgenom reset
    # Check that platform-specific config loaded
    # WSL: SSH agent should start
    # Check paths, aliases work
    ```

18. **Test git credentials:**
    ```bash
    git clone <private-repo>  # Should use correct credential helper
    ```

19. **Test tmux & nvim:**
    ```bash
    tmux  # Should load .tmux.conf
    nvim  # Should load config without errors
    Ctrl+F  # tmux-sessionizer should work
    ```

### Phase 5: Cleanup

20. **Remove old packages (only after confirming new structure works):**
    ```bash
    rm -rf zsh git tmux nvim bin alacritty hypr waybar mako nwg-dock-hyprland sunshine windows
    ```

21. **Update README.md**

22. **Commit changes:**
    ```bash
    git add -A
    git commit -m "Restructure dotfiles for multi-OS support with GNU Stow

    - Split into modular common-* packages
    - Add platform-specific overlays
    - Create bootstrap.sh with OS detection
    - Modularize .zshrc with platform sourcing
    - Add git credential helper per platform
    - Separate Alacritty keybindings by OS

    🤖 Generated with Claude Code

    Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

    git push origin main
    ```

### Phase 6: Integration

23. **Update device_configs:**
    - Edit `~/dev/device_configs/.taskfiles/common.yml`
    - Replace `stow .` with bootstrap.sh call
    - Test on fresh clone

---

## Rollback Plan

If issues occur:

```bash
# 1. Unstow new structure
cd ~/.dotfiles
./bootstrap.sh --unstow

# 2. Checkout backup branch
git checkout backup-pre-restructure

# 3. Stow old structure
stow .

# 4. Restart shell
exec zsh
```

---

## Testing Checklist

Before considering migration complete:

- [ ] Bootstrap detects OS correctly (WSL2)
- [ ] All common-* packages stow without conflicts
- [ ] platform-wsl stows correctly
- [ ] Zsh loads and sources wsl.zsh
- [ ] SSH agent starts automatically
- [ ] Git credential helper works
- [ ] Tmux Ctrl+F sessionizer works
- [ ] Neovim loads without errors
- [ ] tmux-sessionizer script works
- [ ] No hardcoded /home/pj or /Users/pj paths remain
- [ ] Devcontainer mounting doesn't break (test in a container)

---

## Key Technical Details

### OS Detection Logic

```bash
case "$(uname -s)" in
    Darwin) os="macos" ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            os="wsl"
        elif [ -f /etc/arch-release ]; then
            os="arch"
        else
            os="linux"  # Generic fallback
        fi
        ;;
esac
```

### Stow Commands by OS

**WSL2 (current system):**
```bash
stow common-zsh common-git common-tmux common-nvim common-bin platform-wsl
```

**macOS:**
```bash
stow common-zsh common-git common-tmux common-nvim common-bin platform-macos
```

**Arch (with Hyprland):**
```bash
stow common-zsh common-git common-tmux common-nvim common-bin platform-arch arch-hyprland
```

### File Conflicts to Watch

- `.zshrc` - will be replaced by common-zsh version
- `.gitconfig` - will be replaced by common-git version
- Alacritty - only macOS/arch get it (WSL doesn't need)

### Hardcoded Paths to Fix

- Line 32: `/home/pj/.pyenv/bin` → `$HOME/.pyenv/bin`
- Line 48: `/Users/pj/bin/gamadv-xtd3/gam` → `$HOME/bin/gamadv-xtd3/gam`

---

## Success Criteria

1. ✅ Single branch, multi-profile architecture
2. ✅ DRY: No duplicate configs
3. ✅ Portable: Works on macOS, WSL2, Arch
4. ✅ Idempotent: Bootstrap can run multiple times safely
5. ✅ Clean failure states: Conflicts detected before stowing
6. ✅ Devcontainer compatible: No host-only hardcoded paths
7. ✅ device_configs integration: Seamless orchestration

---

## Estimated Complexity

- **Structure creation:** Low (mkdir, mv commands)
- **Config file editing:** Medium (split .zshrc, add conditionals)
- **Bootstrap script:** Medium (bash with OS detection, error handling)
- **Testing:** Medium (verify on current WSL2 system)
- **Total time:** 2-3 hours with careful testing

---

## Future Enhancements (Out of Scope)

- Auto-update mechanism (dotfiles:update task)
- Interactive conflict resolution
- Minimal stow profile for devcontainers
- SOPS/age secrets integration
- Taskfile.yml alternative to bootstrap.sh
