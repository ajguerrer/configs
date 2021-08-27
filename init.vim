let mapleader = "\<Space>"
" must be first because it changes a lot of options
set nocompatible
filetype off

call plug#begin()
" GUI enhancements
Plug 'ajguerrer/stonerose'
Plug 'hoob3rt/lualine.nvim'
Plug 'machakann/vim-highlightedyank'

" VIM enhancements
Plug 'ciaranm/securemodelines'
Plug 'justinmk/vim-sneak'

" Spell check
Plug 'kamykn/spelunker.vim'
Plug 'kamykn/popup-menu.nvim'

" Fuzzy finder
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Language server
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/lsp-status.nvim'

" Completion autopair
Plug 'windwp/nvim-autopairs'

" Language syntax
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate rust toml go'}

" Language utils
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

" =============================================================================
" # Visual settings
" =============================================================================

" "LSP signs
sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=

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

syntax enable
colorscheme stonerose
set background=dark

hi Normal ctermbg=NONE

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

" Use Spelunker instead
set nospell

" =============================================================================
" # Plugin settings
" =============================================================================
" s for next match
let g:sneak#s_next = 1

" LSP config
" https://github.com/neovim/nvim-lspconfig#rust_analyzer
lua <<EOF
-- nvim_lsp object
local lsp_status = require('lsp-status')
-- Status bar config
lsp_status.config({
  indicator_errors = '',
  indicator_warnings = '',
  indicator_info = '',
  indicator_hint = '',
  indicator_ok = '',
})
lsp_status.register_progress()

local nvim_lsp = require'lspconfig'

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = {
                command = 'clippy'
            },
            cargo = {
                loadOutDirsFromCheck = true
            },
            procMacro = {
                enable = true
            },
        }
    },
    flags = {
        debounce_text_changes = 150
    }
})

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  require('lsp_extensions.workspace.diagnostic').handler, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
    underline = false,
  }
)
EOF

lua <<EOF
require'lualine'.setup{
  options = { theme  = 'stonerose' },
  sections = {lualine_c = {'Filename', require'lsp-status'.status}},
}
EOF

function! Filename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

" Treesitter config
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true
  },
}
EOF

" autopairs config
lua<<EOF
require('nvim-autopairs').setup{}

local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- skip it, if you use another global object
_G.MUtils= {}

vim.g.completion_confirm_key = ""

MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      require'completion'.confirmCompletion()
      return npairs.esc("<c-y>")
    else
      vim.api.nvim_select_popupmenu_item(0 , false , false ,{})
      require'completion'.confirmCompletion()
      return npairs.esc("<c-n><c-y>")
    end
  else
    return npairs.autopairs_cr()
  end
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
EOF

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Use completion-nvim in every buffer
autocmd BufEnter * lua require'completion'.on_attach()

" Enable type inlay hints
autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require('lsp_extensions').inlay_hints{ 
\   prefix = " ", 
\   enabled = {"TypeHint", "ChainingHint"}
\ }

" Auto-format *.rs (rust) files prior to saving them
autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 1000)


" Telescope config
lua<<EOF
require('telescope').setup{
   defaults = {
       prompt_prefix = "❯ ",
       selection_caret = "❯ ",
    }
}
EOF

" =============================================================================
" # Keyboard shortcuts
" =============================================================================

" Telescope
nnoremap <leader>f <cmd>Telescope find_files<CR>
nnoremap <leader>e <cmd>Telescope file_browser<CR>
nnoremap <leader>; <cmd>Telescope buffers<CR>
nnoremap <leader>s <cmd>Telescope live_grep<CR>

" LSP navigation
nnoremap <silent> gD         <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd         <cmd>Telescope lsp_definitions<CR>
nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gi         <cmd>Telescope lsp_implementations<CR>
nnoremap <silent> <c-k>      <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gt         <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>a  <cmd>Telescope lsp_code_actions<CR>
nnoremap <silent> gr         <cmd>Telescope lsp_references<CR>
nnoremap <silent> <leader>d  <cmd>Telescope lsp_document_diagnostics<CR>
nnoremap <silent> <leader>D  <cmd>Telescope lsp_workspace_diagnostics<CR>
nnoremap <silent> go         <cmd>Telescope lsp_document_symbols<CR>
nnoremap <silent> gw         <cmd>Telescope lsp_dynamic_workspace_symbols<CR>
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

