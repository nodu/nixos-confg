{ sources }:
''
scriptencoding utf-8
set encoding=utf-8

let g:vim_home_path = "~/.vim"
"----------------------------------------------------------------------
" Basic Options
"----------------------------------------------------------------------
let mapleader=";"
set backspace=2           " Makes backspace behave like you'd expect
set colorcolumn=80        " Highlight 80 character limit
set hidden                " Allow buffers to be backgrounded without being saved
set laststatus=2          " Always show the status bar
set list                  " Show invisible characters
set listchars=tab:›\ ,eol:¬,trail:⋅ "Set the characters for the invisibles
set number
set ruler                 " Show the line number and column in the status bar
set t_Co=256              " Use 256 colors
"set scrolloff=999         " Keep the cursor centered in the screen
set scrolloff=5           " Keep a couple lines of buffer
set showmatch             " Highlight matching braces
set showmode              " Show the current mode on the open buffer
set splitbelow            " Splits show up below by default
set splitright            " Splits go to the right by default
set title                 " Set the title for gvim
set visualbell            " Use a visual bell to notify us

" Customize session options. Namely, I don't want to save hidden and
" unloaded buffers or empty windows.
set sessionoptions="curdir,folds,help,options,tabpages,winsize"

if !has("win32")
    set showbreak=↪           " The character to put to show a line has been wrapped
end

syntax on                 " Enable filetype detection by syntax

" Backup settings
execute "set directory=" . g:vim_home_path . "/swap"
execute "set backupdir=" . g:vim_home_path . "/backup"
execute "set undodir=" . g:vim_home_path . "/undo"
set backup
set undofile
set writebackup

" Search settings
set hlsearch   " Highlight results
set ignorecase " Ignore casing of searches
set incsearch  " Start showing results as you type
set smartcase  " Be smart about case sensitivity when searching

" Tab settings
set expandtab     " Expand tabs to the proper type and size
set tabstop=4     " Tabs width in spaces
set softtabstop=4 " Soft tab width in spaces
set shiftwidth=4  " Amount of spaces when shifting

" Tab completion settings
set wildmode=list:longest     " Wildcard matches show a list, matching the longest first
set wildignore+=.git,.hg,.svn " Ignore version control repos
set wildignore+=*.6           " Ignore Go compiled files
set wildignore+=*.pyc         " Ignore Python compiled files
set wildignore+=*.rbc         " Ignore Rubinius compiled files
set wildignore+=*.swp         " Ignore vim backups

" GUI settings

" This is required to force 24-bit color since I use a modern terminal.
set termguicolors

if !has("gui_running")
    " vim hardcodes background color erase even if the terminfo file does
    " not contain bce (not to mention that libvte based terminals
    " incorrectly contain bce in their terminfo files). This causes
    " incorrect background rendering when using a color theme with a
    " background color.
    "
    " see: https://github.com/kovidgoyal/kitty/issues/108
    let &t_ut=""
endif

set guioptions=cegmt
if has("win32")
    set guifont=Inconsolata:h11
else
    set guifont=Monaco\ for\ Powerline:h12
endif

if exists("&fuopt")
    set fuopt+=maxhorz
endif

"----------------------------------------------------------------------
" Key Mappings
"----------------------------------------------------------------------
" Remap a key sequence in insert mode to kick me out to normal
" mode. This makes it so this key sequence can never be typed
" again in insert mode, so it has to be unique.
inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>
inoremap jk <esc>
inoremap jK <esc>
inoremap Jk <esc>
inoremap JK <esc>

" Make j/k visual down and up instead of whole lines. This makes word
" wrapping a lot more pleasent.
map j gj
map k gk

" cd to the directory containing the file in the buffer. Both the local
" and global flavors.
nmap <leader>cd :cd %:h<CR>
nmap <leader>lcd :lcd %:h<CR>

" Shortcut to edit the vimrc
if has("nvim")
    nmap <silent> <leader>vimrc :e ~/nvim/init.vim<CR>
else
    nmap <silent> <leader>vimrc :e ~/.vimrc<CR>
endif

" Shortcut to edit the vimmisc
nmap <silent> <leader>vimmisc :execute "e " . g:vim_home_path . "/plugged/vim-misc/vimrc.vim"<CR>

" Make navigating around splits easier
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
if has('nvim')
  " We have to do this to fix a bug with Neovim on OS X where C-h
  " is sent as backspace for some reason.
  nnoremap <BS> <C-W>h
endif

" Navigating tabs easier
map <D-S-{> :tabprevious
map <D-S-}> :tabprevious

" Shortcut to yanking to the system clipboard
map <leader>y "+y
map <leader>p "+p

" Get rid of search highlights
noremap <silent><leader>/ :nohlsearch<cr>

" Command to write as root if we dont' have permission
cmap w!! %!sudo tee > /dev/null %

" Expand in command mode to the path of the currently open file
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Buffer management
nnoremap <leader>d   :bd<cr>

" Terminal mode
if has("nvim")
    tnoremap <esc> <C-\><C-n>
    tnoremap jj <C-\><C-n>
    tnoremap jJ <C-\><C-n>
    tnoremap Jj <C-\><C-n>
    tnoremap JJ <C-\><C-n>
    tnoremap jk <C-\><C-n>
    tnoremap jK <C-\><C-n>
    tnoremap Jk <C-\><C-n>
    tnoremap JK <C-\><C-n>
    nnoremap <Leader>c :terminal <CR>
endif

" Tabs
nnoremap <C-t> :tabnew<CR>
nnoremap <C-c> :tabclose<CR>
nnoremap <C-[> :tabprevious<CR>
nnoremap <C-]> :tabnext<CR>

"----------------------------------------------------------------------
" Autocommands
"----------------------------------------------------------------------
" Clear whitespace at the end of lines automatically
autocmd BufWritePre * :%s/\s\+$//e

" Don't fold anything.
autocmd BufWinEnter * set foldlevel=999999

"----------------------------------------------------------------------
" Helpers
"----------------------------------------------------------------------

" SyncStack shows the current syntax highlight group stack.
nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif

    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    echo map(synstack(line('.'), col('.')), 'synIDattr(synIDtrans(v:val), "name")')
endfunc

"----------------------------------------------------------------------
" Plugin settings
"----------------------------------------------------------------------
" Airline
let g:airline_powerline_fonts = 1
" Don't need to set this since Dracula includes a powerline theme
" let g:airline_theme = "powerlineish"

" JavaScript & JSX
let g:jsx_ext_required = 0

" JSON
let g:vim_json_syntax_conceal = 0

" Default SQL type to PostgreSQL
let g:sql_type_default = 'pgsql'







lua << EOF
--[[
-- Notes:
--
-- When updating TreeSitter, you'll want to update the parsers using
-- :TSUpdate manually. Or, you can call :TSInstall to install new parsers.
-- Run :checkhealth nvim_treesitter to see what parsers are setup.
--]]
---------------------------------------------------------------------
-- LSP Clients
---------------------------------------------------------------------
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "gopls" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

---------------------------------------------------------------------
-- Treesitter
---------------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

---------------------------------------------------------------------
-- Comment.nvim
---------------------------------------------------------------------
require('Comment').setup()
EOF










"--------------------------------------------------------------------
" Fix vim paths so we load the vim-misc directory
let g:vim_home_path = "~/.vim"

" This works on NixOS 21.05
let vim_misc_path = split(&packpath, ",")[0] . "/pack/home-manager/start/vim-misc/vimrc.vim"
if filereadable(vim_misc_path)
  execute "source " . vim_misc_path
endif

" This works on NixOS 21.11pre
let vim_misc_path = split(&packpath, ",")[0] . "/pack/home-manager/start/vimplugin-vim-misc/vimrc.vim"
if filereadable(vim_misc_path)
  execute "source " . vim_misc_path
endif

lua <<EOF
---------------------------------------------------------------------
-- Add our custom treesitter parsers
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.proto = {
  install_info = {
    url = "${sources.tree-sitter-proto}", -- local path or git repo
    files = {"src/parser.c"}
  },
  filetype = "proto", -- if filetype does not agrees with parser name
}

---------------------------------------------------------------------
-- Add our treesitter textobjects
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },

    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

EOF

" Default vim-multiple-cursors mapping
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" vim settings
"set noswapfile
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab
set mouse=n " Allow mouse resizing via drag

" Move Lines Up/Down: https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" https://vim.fandom.com/wiki/Highlight_unwanted_spaces
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
" Show trailing whitespace:
match ExtraWhitespace /\s\+$/

set spell spelllang=en_us
set spellfile=~/dotenv/en.utf-8.add
hi clear SpellBad
hi clear SpellLocal
hi clear SpellRare
hi clear SpellCap
hi SpellBad   gui=underline guibg=Red guifg=Black
hi SpellLocal gui=underline guibg=LightGreen guifg=Black
hi SpellRare  gui=underline guibg=Yellow guifg=Black
hi SpellCap   gui=underline guibg=Magenta guifg=Black
noremap zg zg]s
noremap zn ]s
set spell

let g:netrw_liststyle = 3 " Explorer 1:details; 3:tree
let g:netrw_banner = 0 " Remove directory banner

" Opening files
let g:netrw_altv=1 " Explorer 'v' opens new tab on right
let g:netrw_browse_split = 3
"1 - open files in a new horizontal split
"2 - open files in a new vertical split
"3 - open files in a new tab
"4 - open in previous window

let g:netrw_winsize = 75

" Sort: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" modify selected text using combining diacritics
command! -range -nargs=0 Overline        call s:CombineSelection(<line1>, <line2>, '0305')
command! -range -nargs=0 Underline       call s:CombineSelection(<line1>, <line2>, '0332')
command! -range -nargs=0 DoubleUnderline call s:CombineSelection(<line1>, <line2>, '0333')
command! -range -nargs=0 Strikethrough   call s:CombineSelection(<line1>, <line2>, '0336')

function! s:CombineSelection(line1, line2, cp)
  execute 'let char = "\u'.a:cp.'"'
  execute a:line1.','.a:line2.'s/\%V[^[:cntrl:]]/&'.char.'/ge'
endfunction

set autochdir

"statusline
set autoread "Autoload file changes.
" %F(Full file path)
" %m(Shows + if modified - if not modifiable)
" %r(Shows RO if readonly)
" %<(Truncate here if necessary)
" \ (Separator)
" %=(Right align)
" %l(Line number)
" %v(Column number)
" %L(Total number of lines)
" %p(How far in file we are percentage wise)
" %%(Percent sign)
set statusline=%F%m%r%<\ %=%l,%v\ [%L]\ %p%%

" Change the highlighting so it stands out
"hi statusline ctermbg=white ctermfg=black

" Set underline for cursor's line
set cursorline
set cursorcolumn

highlight CursorLine cterm=none term=none
highlight CursorColumn cterm=none term=none
"autocmd WinEnter * setlocal cursorline
"autocmd WinLeave * setlocal nocursorline
highlight CursorLine   guibg=white
highlight CursorColumn guibg=white
highlight ColorColumn guibg=white
" nnoremap <Leader>c :set cursorline! cursorcolumn! colorcolumn!<CR>
let w:cursorColumnHighightOn = 1

nnoremap <Leader>c :call<SID>ToggleHighlight()<cr>
fun! s:ToggleHighlight()
 set cursorline! cursorcolumn!

 if !exists('w:cursorColumnHighightOn')
  let w:cursorColumnHighightOn = 1
  highlight ColorColumn guibg=lightgrey
 else
  unl w:cursorColumnHighightOn
  highlight ColorColumn NONE
 endif
endfunction


"Highlighting that stays after cursor moves
" \l to mark, 'l to return to mark
" :match to clear
nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>


"Folding
"zf (in visual) - create fold
"za             - unfold
"zR             - unfold all
"zf#j           - fold down # lines
"zf#k           - fold up # lines

if has('folding')
  set foldmethod=indent
  set foldlevelstart=99
endif

" Remap Tab to autocomplete next
" https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
inoremap <Tab> <C-n>

au BufRead,BufNewFile *.md   syntax match StrikeoutMatch /\~\~.*\~\~/
hi def  StrikeoutColor   ctermbg=darkblue ctermfg=black    guibg=darkblue guifg=blue
hi link StrikeoutMatch StrikeoutColor

let @s = "I~~\<ESC>A~~\<ESC>:m$"

"""""" Colors
"colorscheme default
"set background=dark
"" set bold, underline and italic enable
"let g:solarized_bold = 1
"let g:solarized_underline = 1
"let g:solarized_italic = 1
"let g:solarized_visibility = "high"
" Make sure the terminal app is using Solarized
" 'altercation/vim-colors-solarized'

"  colorscheme solarized
  "colorscheme onehalfdark
  highlight LineNr guifg=#050505
  highlight LineNr ctermfg=grey
"""""" Colors


" ==================== telescope.nvim ====================
if has('nvim')
  " Make Ctrl-p work for telescope since we know those keybindings so well.
  nnoremap <C-p> <cmd>Telescope find_files<CR>
  nnoremap <C-t> <cmd>Telescope live_grep<CR>
  nnoremap <C-b> <cmd>Telescope git_branches<CR>
  nnoremap <C-g> <cmd>Telescope commands<CR>
  nnoremap <C-h> <cmd>Telescope help_tags<CR>
  nnoremap <C-?> <cmd>Telescope keymaps<CR>
  nnoremap <leader>b <cmd>Telescope buffers<CR>
  nnoremap <leader>e <cmd>Telescope lsp_document_diagnostics<CR>
  nnoremap <leader>ca <cmd>Telescope lsp_code_actions<CR>
  xnoremap <leader>ca <cmd>Telescope lsp_range_code_actions<CR>


  if !executable('rg')
    echo "You might want to install ripgrep: https://github.com/BurntSushi/ripgrep#installation"
  endif

lua << EOF
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        -- map actions.which_key to ?
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["?"] = "which_key"
      }
    },
    file_ignore_patterns = {
      "^.git/",
      ".DS_Store",
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      find_command = {"rg", "--ignore", "--hidden", "--files"},
      },
    live_grep = {
      theme = "dropdown",
      },
    buffers = {
      theme = "dropdown",
      },
    git_branches = {
      theme = "dropdown",
      },
  },
  extensions = {
  }
}
EOF

  lua << EOF
  local utils = require "telescope.utils"

project_files = function()
  local _, ret, stderr = utils.get_os_command_output {
    "git",
    "rev-parse",
    "--is-inside-work-tree",
  }

  local gopts = {}
  local fopts = {}

  gopts.prompt_title = "Find"
  gopts.prompt_prefix = " "
  gopts.results_title = "Repo Files"

  fopts.hidden = true
  fopts.file_ignore_patterns = {
    ".vim/",
    ".local/",
    ".cache/",
    ".git/",
    "Library/.*",
  }

  if ret == 0 then
    require("telescope.builtin").git_files(gopts)
  else
    fopts.results_title = "CWD: " .. vim.fn.getcwd()
    require("telescope.builtin").find_files(fopts)
  end
end


  local key_map = vim.api.nvim_set_keymap

  -- find files with gitfiles & fallback on find_files
  key_map("n", ",<space>", [[<Cmd>lua project_files()<CR>]], { noremap = true, silent = true })

  -- grep word under cursor
  key_map("n", "<leader>g", [[<Cmd>lua require'telescope.builtin'.grep_string()<CR>]], { noremap = true, silent = true })
 -- grep word under cursor - case-sensitive (exact word) - made for use with Replace All - see <leader>ra
   key_map(
     "n",
     "<leader>G",
     [[<Cmd>lua require'telescope.builtin'.grep_string({word_match='-w'})<CR>]],
     { noremap = true, silent = true }
   )

   -- LSP!
   -- show LSP implementations
  key_map(
     "n",
     "<leader>ti",
     [[<Cmd>lua require'telescope.builtin'.lsp_implementations()<CR>]],
     { noremap = true, silent = true }
   )

   -- show LSP definitions
   key_map(
     "n",
     "<leader>td",
     [[<Cmd>lua require'telescope.builtin'.lsp_definitions({layout_config = { preview_width = 0.50, width = 0.92 }, path_displa      ↪y = { "shorten" }, results_title='Definitions'})<CR>]],
     { noremap = true, silent = true }
   )

  -- LSP setup
  require'lspconfig'.pyright.setup{}
  require'lspconfig'.tsserver.setup{}
EOF


  endif
''
