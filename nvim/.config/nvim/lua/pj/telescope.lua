local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
    defaults = {
        color_devicons = true,
        prompt_prefix = "❯ ",
        file_ignore_patterns = {
            "^.git/",
            "node_modules",
        },
        mappings = {
            i = {
                ['<esc>'] = actions.close
            }
        }
    },
    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            overide_file_sorter = true,
        }
    }
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension('fzy_native')

local M = {}

M.search_dotfiles = function()
    require('telescope.builtin').find_files({
        prompt_title = "<.dotfiles>",
        cwd = '~/.dotfiles',
        hidden = true
    })
end

M.project_files = function()
    local opts = {}
    local ok = pcall(require('telescope.builtin').git_files, opts)
    if not ok then require('telescope.builtin').find_files(opts) end
end

vim.api.nvim_set_keymap('n', '<Leader>p', ':lua require\'pj.telescope\'.project_files()<Cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<Leader>df', ':lua require\'pj.telescope\'.search_dotfiles()<Cr>', {noremap = true, silent = true})

return M
