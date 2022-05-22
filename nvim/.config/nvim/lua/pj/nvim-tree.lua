local g = vim.g

g.nvim_tree_add_trailing = 0 -- append a trailing slash to folder names
g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 0

g.nvim_tree_show_icons = {
   folders = 1,
   files = 1,
   git = 1,
   folder_arrows = 1,
}

g.nvim_tree_icons = {
   default = "",
   symlink = "",
   git = {
      deleted = "",
      ignored = "◌",
      renamed = "➜",
      staged = "✓",
      unmerged = "",
      unstaged = "✗",
      untracked = "★",
   },
   folder = {
      default = "",
      empty = "",
      empty_open = "",
      open = "",
      symlink = "",
      symlink_open = "",
      arrow_open = "",
      arrow_closed = "",
   },
}


require('nvim-tree').setup {
    auto_close = true,
    update_cwd = true,
    -- update_focused_file = {
    --     enable = true,
    --     update_cwd = false,
    -- },
    git = {
        enable = false,
        ignore = true,
    },
    view = {
        side = 'left',
        auto_resize = true,
        hide_root_folder = true,
    },
    renderer = {
        indent_markers = {
            enable = false,
        }
    }
}

vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeFocus<CR>', {noremap = true, silent = true})
