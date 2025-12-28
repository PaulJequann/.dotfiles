# Dotfiles

Multi-OS dotfiles for macOS, WSL2, and Arch Linux using GNU Stow.

## Quick Start

```bash
git clone git@github.com:PaulJequann/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## Structure

This repository uses a modular package structure with GNU Stow:

- **`common-*`** - Portable configs that work across all platforms
  - `common-zsh` - Zsh configuration with PATH-first approach
  - `common-git` - Git base configuration
  - `common-tmux` - Tmux configuration
  - `common-nvim` - Neovim configuration
  - `common-bin` - Portable scripts (tmux-sessionizer)

- **`platform-*`** - OS-specific configurations
  - `platform-macos` - macOS-specific (Homebrew, aliases)
  - `platform-wsl` - WSL2-specific (SSH agent, paths)
  - `platform-arch` - Arch Linux-specific (Flatpak, aliases)

- **`arch-hyprland`** - Hyprland desktop environment configs (Arch only)

## Bootstrap Options

```bash
./bootstrap.sh              # Normal bootstrap
./bootstrap.sh --dry-run    # Preview changes without applying
./bootstrap.sh --unstow     # Remove stowed configs
./bootstrap.sh --help       # Show help
```

## How It Works

The bootstrap script:
1. Detects your OS (macOS, WSL2, or Arch Linux)
2. Selects appropriate packages to stow
3. Creates symlinks from `~/.dotfiles` to `$HOME`
4. Configures platform-specific settings automatically

## Supported Platforms

- **macOS** (Darwin) - Homebrew integration, macOS-specific aliases
- **WSL2** (Windows Subsystem for Linux) - SSH agent, Git credential manager
- **Arch Linux** - Flatpak support, optional Hyprland desktop configs
- **Generic Linux** - Limited support (common packages only)

## Key Features

- **PATH-first approach** - Ensures device_configs tools (task, claude, bd) are immediately available
- **Modular architecture** - Granular control over what gets stowed
- **DRY principles** - No duplication across platforms
- **Idempotent** - Safe to run multiple times
- **Platform-aware** - Automatic OS detection and configuration

## Integration with device_configs

This dotfiles repository is designed to work seamlessly with the [device_configs](https://github.com/PaulJequann/device_configs) setup orchestrator. The device_configs Taskfile handles:
- Installing package managers and essential tools
- Installing oh-my-zsh and zgenom
- Cloning this dotfiles repo
- Running the bootstrap script

After device_configs setup and switching to zsh, all tools are immediately available in PATH.

## Post-Bootstrap Steps

After running bootstrap:

1. Restart your shell:
   ```bash
   exec zsh
   ```

2. Regenerate zgenom plugins:
   ```bash
   zgenom reset
   ```

3. Verify tools are accessible:
   ```bash
   command -v task claude bd git nvim tmux
   ```

## Directory Structure

```
~/.dotfiles/
├── bootstrap.sh           # Smart bootstrap with OS detection
├── .stow-local-ignore     # Excludes repo metadata from stowing
│
├── common-zsh/           # Portable zsh config
│   ├── .zshrc            # Main config (PATH first!)
│   ├── .zprofile         # Profile
│   └── .config/zsh/
│       ├── core.zsh      # NVM, pyenv
│       └── aliases.zsh   # Common aliases
│
├── common-git/           # Git config
│   └── .gitconfig        # Includes platform credentials
│
├── common-tmux/          # Tmux config
├── common-nvim/          # Neovim config
├── common-bin/           # Scripts
│
├── platform-macos/       # macOS-specific
│   ├── .config/zsh/macos.zsh
│   ├── .config/alacritty/
│   └── .gitconfig.d/credentials
│
├── platform-wsl/         # WSL2-specific
│   ├── .config/zsh/wsl.zsh
│   └── .gitconfig.d/credentials
│
├── platform-arch/        # Arch-specific
│   ├── .config/zsh/arch.zsh
│   ├── .config/alacritty/
│   ├── .gitconfig.d/credentials
│   └── .local/bin/boot-to-windows
│
└── arch-hyprland/        # Hyprland configs
    └── .config/
        ├── hypr/
        ├── waybar/
        ├── mako/
        └── ...
```

## Configuration Philosophy

- **Shared first** - Default to portable configs in `common-*` packages
- **Platform when needed** - Only use `platform-*` for OS-specific logic
- **No hardcoded paths** - Use `$HOME` instead of `/Users/pj` or `/home/pj`
- **Modular sourcing** - Platform configs are sourced conditionally

## Troubleshooting

**Stow conflicts:**
```bash
# Backup existing dotfiles
mkdir -p ~/.dotfiles-backup
mv ~/.zshrc ~/.gitconfig ~/.tmux.conf ~/.dotfiles-backup/

# Try bootstrap again
./bootstrap.sh
```

**Tools not in PATH:**
- Check that `~/.local/bin` is in your PATH
- Restart your shell: `exec zsh`
- Verify .zshrc is sourced: `source ~/.zshrc`

**Platform-specific config not loading:**
- Check OS detection: `uname -s` and `cat /proc/version`
- Verify platform file exists: `ls ~/.config/zsh/`
- Check symlinks: `ls -la ~/.config/zsh/`

## License

Personal dotfiles - use at your own discretion.
