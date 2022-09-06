let mapleader = " "
set guicursor=
set tabstop=3 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number
set numberwidth=4
set relativenumber
set nohlsearch
set hidden
set noerrorbells
set incsearch
set scrolloff=8
set signcolumn=yes
set splitbelow
set splitright
set ignorecase
set smartcase
set termguicolors
" --- Plugins

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-lualine/lualine.nvim'

" -- cmp plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
""Plug 'windwp/nvim-autopairs' "conf in lsp file
Plug 'steelsojka/pears.nvim'
" -- Theme
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'onsails/lspkind-nvim'
Plug 'numToStr/Comment.nvim'

call plug#end()

" require plugin configs
lua require('pj')

" --- Key Maps
nnoremap <silent> <C-f> :silent !tmux neww tmux-sessionizer<CR>

colorscheme tokyonight
