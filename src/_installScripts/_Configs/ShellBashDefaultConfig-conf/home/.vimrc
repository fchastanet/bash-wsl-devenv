call plug#begin()
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

colorscheme desert
set noeb vb t_vb=
set paste
set nocompatible "arrow keys compatibility
set backspace=2 "make backspace to work
set noswapfile "avoid creating an intermediate file when saving that could break docker mount https://github.com/moby/moby/issues/15793
" activates filetype detection
filetype plugin indent on
syntax on "
set background=dark
set ruler
set hlsearch
