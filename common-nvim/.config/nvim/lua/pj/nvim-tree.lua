require('nvim-tree').setup {
    hijack_directories = {
        enable = false,
    },
    ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
    },
    filters = {
        custom = { ".git" },
        exclude = { ".gitignore" },
    },
    update_cwd = true,
    git = {
        enable = true,
        ignore = true,
        timeout = 500,
    },
    view = {
        side = 'left',
        adaptive_size = true,
        hide_root_folder = true,
        number = true,
        relativenumber = true,
    },
    renderer = {
        indent_markers = {
            enable = false,
        icons = {
            corner = "└ ",
            edge = "│ ",
            none = "  ",
            },
        },
        icons = {
            webdev_colors = true,
            git_placement = "before",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
      },
        glyphs = {
            default = "",
            symlink = "",
            folder = {
                arrow_open = "",
                arrow_closed = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
        },
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          untracked = "U",
          deleted = "",
          ignored = "◌",
        },
        }
    }
}
}

vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeFocus<CR>', {noremap = true, silent = true})
