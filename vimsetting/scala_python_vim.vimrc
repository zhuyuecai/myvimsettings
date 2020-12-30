" configure expanding of tabs for various file types
au BufRead,BufNewFile *.py set expandtab shiftwidth=4
au BufRead,BufNewFile *.scala set expandtab shiftwidth=2
" au BufRead,BufNewFile *.scala source ~/.vimscala
au BufRead,BufNewFile *.c set noexpandtab
au BufRead,BufNewFile *.h set noexpandtab
au BufRead,BufNewFile Makefile* set noexpandtab

" --------------------------------------------------------------------------------
" configure editor with tabs and nice stuff...
" --------------------------------------------------------------------------------
set t_u7=
set expandtab           " enter spaces when tab is pressed
set textwidth=120       " break lines when line length increases
set tabstop=4           " use 4 spaces to represent tab
set softtabstop=4
set shiftwidth=2        " number of spaces to use for auto indent
set autoindent          " copy indent from current line when starting a new line
set spell
set nocompatible              " be iMproved, required

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" " alternatively, pass a path where Vundle should install plugins
" "call vundle#begin('~/some/path/here')
"
" " let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"
" " The following are examples of different formats supported.
" " Keep Plugin commands between vundle#begin/end.
" " plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
Plugin 'derekwyatt/vim-scala'
Plugin 'megaannum/scala_commenter'
Plugin 'mikelue/vim-maven-plugin'
Plugin 'tpope/vim-projectionist'
Plugin 'tpope/vim-dispatch'
Plugin 'vim-airline/vim-airline'
Plugin 'jonathanfilip/vim-dbext'
Plugin 'luochen1990/rainbow'
let g:rainbow_active = 1
" code formatter"
Plugin 'Chiel92/vim-autoformat'
" python formatting"
" scalafmt settings
let g:formatdef_scalafmt = '"scalafmt --stdin"'
let g:formatters_scala = ['scalafmt']
" au BufWrite * :Autoformat
" This is a Scaladoc comment using the recommended indentation.
let g:scala_scaladoc_indent = 1
Plugin 'neomake/neomake'

"Plugin 'Shougo/deoplete.nvim'
"Plugin 'roxma/nvim-yarp'
"Plugin 'roxma/vim-hug-neovim-rpc'
"let g:deoplete#enable_at_startup = 1
"let g:deoplete#sources={} 
"let g:deoplete#sources._=['buffer', 'member', 'tag', 'file', 'omni', 'ultisnips'] 

"let g:deoplete#omni#input_patterns={} 
"let g:deoplete#omni#input_patterns.scala='[^. *\t]\.\w*'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'janko-m/vim-test'
Plugin 'ktvoelker/sbt-vim'
let test#strategy = "dispatch"
let test#runner = "maventest"
" " python plugins
Plugin 'vim-scripts/indentpython.vim'
Bundle 'Valloric/YouCompleteMe'
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
Plugin 'vim-syntastic/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['flake8','python','pylint','mypy']
" Pylint configuration file
let g:pymode_lint_config = '$HOME/.pylintrc'
let g:syntastic_scala_checkers = ['scalastyle']
let g:syntastic_scala_scalastyle_jar = '/home/yuecazhu/apps/scalastyle/scalastyle_2.12-1.0.0-batch.jar'
let g:syntastic_scala_scalastyle_config_file = '/home/yuecazhu/scalastyle_config.xml'
let python_highlight_all=1
syntax on
Plugin 'jnurmine/Zenburn'
set t_Co=256
"set background=dark

set nu

Plugin 'neoclide/coc.nvim', {'branch': 'release'}

 " Configuration for coc.nvim

 " If hidden is not set, TextEdit might fail.
set hidden
 "
 " Some servers have issues with backup files
set nobackup
set nowritebackup
 
 " You will have a bad experience with diagnostic messages with the default 4000.
set updatetime=300

 " Don't give |ins-completion-menu| messages.
set shortmess+=c

 " Always show signcolumns
set signcolumn=yes

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Used in the tab autocompletion for coc
function! s:check_back_space() abort
   let col = col('.') - 1
     return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

":Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>

Plugin 'davidhalter/jedi-vim'
let g:jedi#completions_enabled = 0
Plugin 'preservim/nerdcommenter'

" " All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" " To ignore plugin indent changes, instead use:
" "filetype plugin on
" "
" " Brief help
" " :PluginList       - lists configured plugins
" " :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" " :PluginSearch foo - searches for foo; append `!` to refresh local cache
" " :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
" "
" " see :h vundle for more details or wiki for FAQ
" " Put your non-Plugin stuff after this line
"

au BufNewFile,BufRead *.js, *.html, *.css
            \ set tabstop=2
            \ set softtabstop=2
            \ set shiftwidth=2


colors zenburn
highlight Normal ctermfg=grey ctermbg=black
" make backspaces more powerfull
set backspace=indent,eol,start
set spelllang=en
set spell
function! Test()
    let l:curr=expand(@%) 
    if l:curr =~ '.*src/main/scala'
        let l:start=matchend(l:curr,'src/main/scala/')
        let l:fullTestName=substitute(strpart(l:curr, l:start), '/','.',"g")
        let l:testName=substitute(l:fullTestName, '.scala','Test',"g")
    else
        let l:start=matchend(l:curr,'src/test/scala/')
        let l:fullTestName=substitute(strpart(l:curr, l:start), '/','.',"g")
        let l:testName=substitute(l:fullTestName, '.scala','',"g")
    endif
    execute "! mvn test -Dsuites=".l:testName
endfunction
command! Test call Test()

" When writing a buffer (no delay).
" call neomake#configure#automake('w')

" let g:neomake_enabled_makers = ['mvn']
" let g:neomake_verbose=1
" let g:neomake_open_list = 2

" au BufRead,BufNewFile *.scala autocmd InsertLeave,TextChanged * update | Neomake! mvn compile
" autocmd FileType scala source $HOME/.vim/bundle/scala_commenter/plugin/scala/commenter.vim
