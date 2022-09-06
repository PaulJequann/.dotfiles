vim.g.nvim_tree_indent_markers = 1

require('nvim-tree').setup {
    auto_close = true,
    view = {
        auto_resize = true,
    }
}

vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
