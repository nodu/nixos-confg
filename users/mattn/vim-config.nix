{ sources }:
''
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
''

" Install vim-plug
"if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
"  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
"    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
"endif

" vim-plug plugins; Start vim and execute :PlugInstall to install
"call plug#begin('~/.local/share/nvim/plugged')
"Plug 'mg979/vim-visual-multi', {'branch': 'master'}
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-surround'
"Plug 'altercation/vim-colors-solarized'
"Plug 'chrisbra/Colorizer'
""Plug 'sheerun/vim-polyglot' "Syntax highlighting
"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-telescope/telescope.nvim'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"call plug#end()

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

  colorscheme default

" vim settings
set number
set noswapfile
set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab
set hlsearch
set mouse=n " Allow mouse resizing via drag
set ignorecase
set smartcase

" Move Lines Up/Down: https://vim.fandom.com/wiki/Moving_lines_up_or_down
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" https://vim.fandom.com/wiki/Highlight_unwanted_spaces
:autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
:highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
" Show trailing whitespace:
:match ExtraWhitespace /\s\+$/

set spell spelllang=en_us
set spellfile=~/.vim/spell/en.utf-8.add
hi clear SpellBad
hi clear SpellLocal
hi clear SpellRare
hi clear SpellCap
"hi SpellBad   cterm=underline ctermbg=Red ctermfg=Black
hi SpellBad   cterm=underline
hi SpellLocal cterm=underline ctermbg=Green ctermfg=Black
hi SpellRare  cterm=underline ctermbg=Yellow ctermfg=Black
hi SpellCap   cterm=underline ctermbg=DarkMagenta ctermfg=Black

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

" CtrlP !
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_show_hidden = 1

au BufRead,BufNewFile *.md   syntax match StrikeoutMatch /\~\~.*\~\~/
hi def  StrikeoutColor   ctermbg=darkblue ctermfg=black    guibg=darkblue guifg=blue
hi link StrikeoutMatch StrikeoutColor

let @s = "I~~\<ESC>A~~\<ESC>:m$"

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

" Make sure it always shows
set laststatus=2

" Set underline for cursor's line
set cursorline
set cursorcolumn

highlight CursorLine cterm=none term=none
highlight CursorColumn cterm=none term=none
"autocmd WinEnter * setlocal cursorline
"autocmd WinLeave * setlocal nocursorline
"highlight CursorLine   guibg=#303000 ctermbg=lightred
"highlight CursorColumn guibg=darkred ctermbg=darkgrey
nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

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

" 'altercation/vim-colors-solarized'
syntax enable
set background=dark

" set bold, underline and italic enable
let g:solarized_bold = 1
let g:solarized_underline = 1
let g:solarized_italic = 1
let g:solarized_visibility = "high"

" Make sure the terminal app is using Solarized
colorscheme solarized
" 'altercation/vim-colors-solarized'

"https://github.com/chrisbra/Colorizer/issues/77
"let g:colorizer_auto_filetype='css,html,config'
"let g:colorizer_auto_color = 1

"augroup auto_colorize
"  autocmd!
"  autocmd
"        \ BufNewFile,BufRead,BufEnter,BufLeave,WinEnter,WinLeave,WinNew
"        \ *.js,*.css,*.scss,*.sass,i3.config
"        \ ColorHighlight
"augroup END
"
"
  let mapleader=";"
 set scrolloff=5

" ==================== telescope.nvim ====================
if has('nvim')
  " let g:which_key_map.f = { 'name' : '+telescope find' }
  " nnoremap <leader>ff <cmd>Telescope find_files<CR>
  " let g:which_key_map.f.f = 'telescope find files'
  " nnoremap <leader>fg <cmd>Telescope live_grep<CR>
  " let g:which_key_map.f.g = 'telescope live grep'
  " nnoremap <leader>fb <cmd>Telescope buffers<CR>
  " let g:which_key_map.f.b = 'telescope buffers'
  nnoremap <leader>fh <cmd>Telescope help_tags<CR>
  " let g:which_key_map.f.h = 'telescope help tags'

  " Make Ctrl-p work for telescope since we know those keybindings so well.
  nnoremap <C-p> <cmd>Telescope find_files<CR>
  nnoremap <C-t> <cmd>Telescope live_grep<CR>
  nnoremap <C-b> <cmd>Telescope git_branches<CR>
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
  local TelescopePrompt = {
    TelescopePromptNormal = {
        bg = '#2d3149',
    },
    TelescopePromptBorder = {
        bg = '#2d3149',
    },
    TelescopePromptTitle = {
        fg = '#2d3149',
        bg = '#2d3149',
    },
    TelescopePreviewTitle = {
        fg = '#1F2335',
        bg = '#1F2335',
    },
    TelescopeResultsTitle = {
        fg = '#1F2335',
        bg = '#1F2335',
    },
}
--for hl, col in pairs(TelescopePrompt) do
  --vim.api.nvim_set_hl(0, hl, col)
--end

--if vim.fn.isdirectory(vim.v.argv[2]) == 1 then
 -- vim.api.nvim_set_current_dir(vim.v.argv[2])
--end

--  require('telescope.builtin').find_files( { cwd = vim.fn.expand('%:p:h') })
EOF
"au VimEnter * if isdirectory(argv(0)) | exec 'Telescope find_files cwd=' . argv(0) | endif
endif
