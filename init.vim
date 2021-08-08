let mapleader = "\<Space>"
" must be first because it changes a lot of options
set nocompatible
filetype off


call plug#begin()

" GUI enhancements
Plug 'chriskempson/base16-vim'
Plug 'itchyny/lightline.vim'
Plug 'machakann/vim-highlightedyank'

" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'justinmk/vim-sneak'

" Fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Code spell check
Plug 'kamykn/spelunker.vim'
Plug 'kamykn/popup-menu.nvim'

" Language support
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate rust toml go'}
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

" =============================================================================
" # Visual settings
" =============================================================================

" cursor look
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
" live substitution
set inccommand=nosplit
" terminal colors
if !has('gui_running')
  set t_Co=256
endif
if (match($TERM, "-256color") != -1) && (match($TERM, "screen-256color") == -1)
  " screen does not (yet) support truecolor
  set termguicolors
endif
let base16colorspace=256
syntax enable
colorscheme base16-gruvbox-dark-hard
set background=dark

hi Normal ctermbg=NONE

" LSP colors (base16-gruvbox-dark-hard)
hi LspDiagnosticsDefaultError ctermfg=1 guifg=#fb4934
hi LspDiagnosticsDefaultWarning ctermfg=16 guifg=#fe8019
hi LspDiagnosticsDefaultInformation  ctermfg=7 guifg=#d5c4a1
hi LspDiagnosticsDefaultHint ctermfg=8 guifg=#665c45
hi LspDiagnosticsSignError ctermfg=1 guifg=#fb4934 guibg=#3c3836
hi LspDiagnosticsSignWarning ctermfg=16 guifg=#fe8019 guibg=#3c3836
hi LspDiagnosticsSignInformation  ctermfg=7 guifg=#d5c4a1 guibg=#3c3836
hi LspDiagnosticsSignHint ctermfg=8 guifg=#665c45 guibg=#3c3836

"LSP signs
sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=

" Dont highlight long columns
set synmaxcol=500

" Relative with absolute current line
set relativenumber
set number

" Visual indicator at column
set colorcolumn=100

" Give more space for displaying messages
set cmdheight=2

" Always display sign column. Prevent buffer moving when adding/deleting sign.
set signcolumn=yes

" Show (partial) command in status line.
set showcmd 

" Show those damn hidden characters
set listchars=nbsp:¬,extends:»,precedes:«,trail:•

" =============================================================================
" # Editor settings
" =============================================================================

" Only spelunker as spell checker
set nospell

" Write swap after ms
set updatetime=500

" Key seqence delay
set timeoutlen=300

" Key code delay
set ttimeoutlen=5

set encoding=utf-8

" lines of context around cursor when scrolling
set scrolloff=3

" hide, dont close, buffers with changes
set hidden

" no backups
set nobackup
set nowritebackup

" dont wrap lines
set nowrap

" disable extra spaces after sentence
set nojoinspaces

" disable folding
set nofoldenable

" Sane splits
set splitright
set splitbelow

" Permanent undo
set undodir=~/.vimdid
set undofile

" Decent wildmenu
set wildmenu
set wildmode=list:longest
set wildignore=

" Indent
filetype plugin indent on
set autoindent
set shiftwidth=8
set softtabstop=8
set tabstop=8
set noexpandtab

" Wrap text width
set textwidth=100

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" Proper search
set incsearch
set ignorecase
set smartcase
set gdefault

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Very magic by default
nnoremap ? ?\v
nnoremap / /\v
cnoremap %s/ %sm/

" Enable mouse usage (all modes) in terminals
set mouse=a 

" don't give ins-completion-menu messages.
set shortmess+=c 

" completion handling
set completeopt=menuone,noinsert,noselect

" windows clipboard
set clipboard=unnamedplus

" =============================================================================
" # Plugin settings
" =============================================================================
" s for next match
let g:sneak#s_next = 1

" Color scheme

" FZF
if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m
endif

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'source': s:list_cmd(), 
  \                                                    'options': ['--tiebreak=index', '--layout=reverse', '--info=inline']}), <bang>0)

function! s:list_cmd()
  let base = fnamemodify(expand('%'), ':h:.:S')
  return base == '.' ? 'fdfind --type file --follow' : printf('fdfind --type file --follow | proximity-sort %s', shellescape(expand('%')))
endfunction

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" LSP config
" https://github.com/neovim/nvim-lspconfig#rust_analyzer
lua <<EOF
-- nvim_lsp object
local lsp_status = require('lsp-status')
-- Status bar config
lsp_status.config({
  indicator_errors = '',
  indicator_warnings = '',
  indicator_info = '',
  indicator_hint = '',
  indicator_ok = '',
})
lsp_status.register_progress()

local nvim_lsp = require'lspconfig'

local on_attach = function(client)
    require'completion'.on_attach(client)
    lsp_status.on_attach(client)
end

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({
    on_attach=on_attach,
    capabilities = lsp_status.capabilities,
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = {
	        command = 'clippy'
            }
        }
    },
    flags = {
        debounce_text_changes = 150
    }
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
    underline = false,
  }
)
EOF

" Lightline
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'lspstatus', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'lspstatus': 'LspStatus'
      \ },
      \ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" Statusline
function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require'lsp_extensions'.inlay_hints{ 
\   prefix = '', 
\   highlight = "Comment", 
\   enabled = {"TypeHint", "ChainingHint", "ParameterHint"}
\ }

" Auto-format *.rs (rust) files prior to saving them
autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 1000)

" Treesitter config
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true
  },
}
EOF

" =============================================================================
" # Keyboard shortcuts
" =============================================================================

" FZF
" Open hotkeys
map <leader>f :Files<CR>
nmap <leader>; :Buffers<CR>
noremap <leader>s :RG 

" LSP navigation
nnoremap <silent> gD         <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd         <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi         <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k>      <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gt         <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>a  <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> gr         <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> <leader>d  <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
nnoremap <silent> g0         <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW         <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> g[         <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g]         <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Quick qwx
nmap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <leader>x :x<CR>

" close vim, prompt if buffers changed
noremap <C-q> :confirm qall<CR>
" ; as :
nnoremap ; :

" Open new file adjacent to current file
nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" <leader><leader> toggles between buffers
nnoremap <leader><leader> <c-^>

" Keymap for replacing up to next _ or -
noremap <leader>m ct_

" Ctrl+h to stop searching
vnoremap <C-h> :nohlsearch<cr>
nnoremap <C-h> :nohlsearch<cr>

" Suspend with Ctrl+f
inoremap <C-f> :sus<cr>
vnoremap <C-f> :sus<cr>
nnoremap <C-f> :sus<cr>

" Jump to start and end of line using the home row keys
map H ^
map L $

" No arrow keys --- force yourself to use the home row
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" C-arrow to navigate splits
nnoremap <C-down> <C-W><C-J>
nnoremap <C-up> <C-W><C-K>
nnoremap <C-right> <C-W><C-L>
nnoremap <C-left> <C-W><C-H>

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" Move by line
nnoremap j gj
nnoremap k gk

" <leader>, shows/hides hidden characters
nnoremap <leader>, :set invlist<cr>

" Disable F1 help
map <F1> <Esc>
imap <F1> <Esc>

