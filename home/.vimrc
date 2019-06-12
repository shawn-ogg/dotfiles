set nocompatible              " be iMproved, required
if executable('goimports')
    let g:gofmt_command = "goimports"
endif

" Install and run vim-plug on first run
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'jeffkreeftmeijer/vim-dim'

Plug 'christoomey/vim-tmux-navigator'

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sleuth'

Plug 'itchyny/lightline.vim'
Plug 'kmtoki/lightline-colorscheme-simplicity'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'mhinz/vim-signify'
Plug 'AndrewRadev/linediff.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'editorconfig/editorconfig-vim'
Plug 'vim-syntastic/syntastic'
"Plug 'devjoe/vim-codequery'

Plug 'Vimjas/vim-python-pep8-indent'
Plug '~/.vim/plugged/YouCompleteMe'
Plug 'hashivim/vim-terraform'
Plug 'vim-jp/vim-go-extra'

Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'ntpeters/vim-better-whitespace'
call plug#end()

let g:lightline = {
      \ 'colorscheme': 'simplicity',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

silent! colorscheme dim

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_go_checkers = ['golint', 'govet']

map ; :Files<CR>
map <C-n> :NERDTreeToggle<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set noshowmode
set splitbelow
set splitright

set fillchars=""
nnoremap <silent> vv <C-w>v
hi VertSplit ctermbg=black

let mapleader=","
nnoremap <leader>g :YcmCompleter GoTo<CR>

autocmd FileType go autocmd BufWritePre <buffer> Fmt

command! FZFMru call fzf#run({
\ 'source':  reverse(s:all_files()),
\ 'sink':    'edit',
\ 'options': '-m -x +s',
\ 'down':    '40%' })

function! s:all_files()
  return extend(
  \ filter(copy(v:oldfiles),
  \        "v:val !~ 'fugitive:\\|NERD_tree\\|^/tmp/\\|.git/'"),
  \ map(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val)'))
endfunction

nnoremap <silent> <leader>m :FZFMru<CR>

