"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"                                 _                                             "
"                          _   __(_)___ ___  __________                         "
"                         | | / / / __ `__ \/ ___/ ___/                         "
"                         | |/ / / / / / / / /  / /__                           "
"                         |___/_/_/ /_/ /_/_/   \___/                           "
"                                                                               "
"                                                                               "
"++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"{{{
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=1000 " keep n lines of command line history
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch  " do incremental searching
set nobackup

let mapleader=","
"}}}
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo, {{{
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
"}}}
" Switch syntax highlighting on, when the terminal has colors {{{
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif
nnoremap <Esc><Esc> :nohlsearch<CR>
"}}}
" Only do this part when compiled with support for autocommands. {{{
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  autocmd FileType text setlocal textwidth=200

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

  augroup END
else
  set autoindent    " always set autoindenting on
endif
"}}}
" 初回のみ読み込まれるデフォルト定義 {{{
  set tabstop=8
  set softtabstop=4
  set shiftwidth=4
  set noautoindent
  set nowrapscan
  set number
  set ruler
  set laststatus=2
  set cmdheight=2
  set showcmd
  set title
  " バックスペースでインデントや改行を削除できるようにする
  set backspace=2
  " 分割幅を均等でなくする。<C-W>=で均等に、<C-W>|で最大化
  set noequalalways
"}}}
"set tags {{{
if has("autochdir")
  set autochdir
  set tags=tags;
else
  set tags=./tags,./../tags,./*/tags,./../../tags,./../../../tags,./../../../../tags,./../../../../../tags
endif
"nnoremap <C-]> g]
"}}}
" 検索などで飛んだらそこを真ん中に {{{
for maptype in ['n', 'N', '*', '#', 'g*', 'g#', 'G'] | execute 'nmap' maptype maptype . 'zz' | endfor
"}}}
" escape automatically / ? {{{
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'
"}}}
" fileencoding {{{
for [enc, cmds, key] in [
  \ ['utf-8'      , ['Utf8']            , 'u'],
  \ ['euc-jp'     , ['Eucjp']           , 'e'],
  \ ['cp932'      , ['Cp932', 'Sjis']   , 's'],
  \ ['iso-2022-jp', ['Iso2022jp', 'Jis'], 'j'],
  \]
  for cmd in cmds
    execute 'command! -bang -bar -complete=file -nargs=?' cmd 'edit<bang> ++enc=' . enc '<args>'
  endfor
  execute 'nmap <Leader>' . key          ':' . cmds[0] . '<CR>'
  execute 'nmap <Leader>' . toupper(key) ':set fileencoding=' . enc . '<CR>'
endfor
"}}}
" 文字コードの自動認識 {{{
if filereadable(expand("$HOME/.vim/_auto_fileencoding.vim"))
  source $HOME/.vim/_auto_fileencoding.vim
endif
"}}}
" 改行コードの自動認識 {{{
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif
"}}}
" 大文字小文字の両方が含まれている場合は大文字小文字を区別 {{{
set smartcase
"}}}
" コマンドライン補完 {{{
set wildmenu
set wildmode=list:longest
"}}}
" 検索後、画面の端でスクロールするのではなく、数行余裕があるうちにスクロールする {{{
set scrolloff=5
"}}}
" window movement {{{
for key in ['h', 'j', 'k', 'l'] | execute 'nnoremap <silent> <C-' . key . '> :wincmd' key . '<CR>' | endfor
"}}}
" remap for split, vsplit {{{
nnoremap <C-w>- :<C-u>sp<CR>
nnoremap <C-w>\ :<C-u>vs<CR>
"}}}
" change window size {{{
nnoremap <silent> <Up>    :2 wincmd -<CR>
nnoremap <silent> <Down>  :2 wincmd +<CR>
nnoremap <silent> <Left>  :5 wincmd <<CR>
nnoremap <silent> <Right> :5 wincmd ><CR>
"}}}
"折れ曲がった行にも移動 {{{
"set wrap のときに便利
for key in ['j', 'k']
  execute 'nmap' key 'g' . key
  execute 'vmap' key 'g' . key
endfor
"set showbreak=…
"}}}
" folding shortcut {{{
noremap [space] <nop>
nmap <Space> [space]

noremap [space]j zj   " カーソルより下方の折畳へ移動する
noremap [space]k zk   " カーソルより上方の折畳へ移動する
noremap [space]n ]z   " 現在の開いている折畳の末尾へ移動する
noremap [space]p [z   " 現在の開いている折畳の先頭へ移動する
noremap [space]h zc   " カーソルの下の折畳を一段階閉じる
noremap [space]l zo   " カーソルの下の折畳を一段階開く
noremap [space]a za   " 折畳が閉じていた場合: それを開く
noremap [space]m zM   " 全ての折畳を閉じる
noremap [space]i zMzv " 全ての折畳を閉じる => カーソル行を表示する
noremap [space]r zR   " 全ての折畳を開く
noremap [space]f zf   " 折畳を作成する操作
"}}}
" toggle command {{{
for [cmd_name, opt_name, key] in [
  \ ['ToggleNumber'      , 'number'      , 'N'],
  \ ['ToggleList'        , 'list'        , 'L'],
  \ ['ToggleWrap'        , 'wrap'        , 'W'],
  \ ['ToggleCursorLine'  , 'cursorline'  , 'cl'],
  \ ['ToggleCursorColumn', 'cursorcolumn', 'cc'],
  \]
  execute 'command!' cmd_name 'setlocal' opt_name . '!'
  execute 'nmap <Space>'. key ':' . cmd_name . '<CR>'
endfor

" cf http://vimcasts.org/episodes/soft-wrapping-text/
command! Wrap set wrap linebreak nolist
"}}}
" for set list {{{
" Use the same symbols as TextMate for tabstops and EOLs
try
  "set listchars=tab:▸\ ,eol:¬
  "set listchars=tab:»\ ,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
  set listchars=tab:￫\ ,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
  set list
catch
endtry
highlight NonText ctermfg=DarkBlue
highlight SpecialKey ctermfg=DarkBlue
"}}}
" edit vimrc {{{
nnoremap <Leader>v :tabnew $MYVIMRC<CR>     " vimrcを開く
nnoremap <Leader>gv :tabnew $MYVIMRC<CR>     " gvimrcを開く

if has("gui_running")
  nnoremap <Leader>so :source $MYVIMRC \| source $MYGVIMRC<CR>  " vimrcをリロード
else
  nnoremap <Leader>so :source $MYVIMRC<CR>  " vimrcをリロード
endif
"}}}
" FileType Indent {{{
set et
augroup auto_filetype_indent
autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs     setlocal sw=4 sts=4 ts=4 noet
autocmd FileType c          setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp        setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs         setlocal sw=4 sts=4 ts=4 et
autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
autocmd FileType less       setlocal sw=2 sts=2 ts=2 et
autocmd FileType diff       setlocal sw=4 sts=4 ts=4 noet
autocmd FileType eruby      setlocal sw=2 sts=2 ts=2 et
autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
autocmd FileType jsp        setlocal sw=2 sts=2 ts=2 et
autocmd FileType javascript setlocal sw=4 sts=4 ts=4 et
autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
autocmd FileType python     setlocal sw=4 sts=4 ts=4 et
autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
autocmd FileType cucumber   setlocal sw=2 sts=2 ts=2 et
autocmd FileType haml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType sh         setlocal sw=4 sts=4 ts=4 et
autocmd FileType sql        setlocal sw=2 sts=2 ts=2 et
autocmd FileType vb         setlocal sw=4 sts=4 ts=4 noet
autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
autocmd FileType wsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType xhtml      setlocal sw=2 sts=2 ts=2 et
autocmd FileType xml        setlocal sw=2 sts=2 ts=2 et
autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType scala      setlocal sw=2 sts=2 ts=2 et
autocmd FileType mkd        setlocal sw=4 sts=4 ts=4 noet si nofen
autocmd FileType text       setlocal et si
autocmd FileType aws.json   setlocal sw=2 sts=2 ts=2 et fdm=indent nowrap
autocmd FileType json       setlocal sw=2 sts=2 ts=2 et fdm=indent nowrap
augroup END
"}}}
" for grep {{{
"{{{ 外部grep
let &grepprg="find . -type f -name '*'
              \ -a -not -regex '.*\\.swp$'
              \ -a -not -regex '.*\\.gz$'
              \ -a -not -regex '.*\\.gif$'
              \ -a -not -regex '.*\\.png$'
              \ -a -not -regex '.*\\.jpg$'
              \ -a -not -regex '.*\\.bak$'
              \ -a -not -regex '.*\\.bk$'
              \ -a -not -regex '.*\\.class$'
              \ -a -not -regex '.*\\.db$'
              \ -a -not -regex '.*\\.example.*'
              \ -a -not -regex '.*_$'
              \ -a -not -regex '.*log$'
              \ -a -not -regex '.*gomi.*'
              \ -a -not -regex '.*hoge.*'
              \ -a -not -regex '.*/\\.svn/.*'
              \ -a -not -regex '.*/\\.git/.*'
              \ -a -not -regex '.*/tmp/.*'
              \ -a -not -regex '.*/resources/.*'
              \ -a -not -regex '.*/images/.*'
              \ -a -not -regex '.*/plugins/.*'
              \ -a -not -regex '.*/coverage/.*'
              \ -a -not -regex '.*/alias/.*'
              \ -a -not -regex '.*/ext/.*'
              \ -a -not -regex '.*_compress/.*'
              \ -a -not -regex '^\\./\\..*'
              \ -a -not -regex '^\\./work.*'
              \ -a -not -regex '^\\./cpan.*'
              \ -a -not -regex '^\\./etc.*'
              \ -a -not -regex '.*\\.min\\.js$'
              \ -a -not -regex '.*\\.min\\.css$'
              \ -a -not -regex '.*schema.rb$'
              \ -print0 \\| xargs -0 grep -nH"
"}}}
" カーソル直下の単語(Word)
nmap <C-g><C-w> :grep "<C-R><C-W>" \| bot cw<CR>
" カーソル直下の単語(WORD)(C-aはscreenとバッティングするためC-eに)
nmap <C-g><C-e> :grep "<C-R><C-A>" \| bot cw<CR>
" 最後に検索した単語
nmap <C-g><C-h> :grep "<C-R>/" \| bot cw<CR>
nmap <C-g><C-j> :vim /<C-R>// ## \| bot cw<CR>

nmap <silent> <C-n> :<C-u>cnext<CR>
nmap <silent> <C-p> :<C-u>cprevious<CR>

"}}}
" color {{{
set background=light

" cf http://vimwiki.net/
colorscheme desert

" 色番号  :help ctermbg(NR-8)
highlight Pmenu     ctermbg=4
highlight PmenuSel  ctermbg=5
highlight PmenuSbar ctermbg=0

highlight clear Folded
highlight clear FoldColumn
"}}}
" 全角スペースの表示 {{{
highlight ZenkakuSpace cterm=underline ctermfg=White
try
  match ZenkakuSpace /　/
catch
endtry
"}}}
" カーソル行 {{{
"{{{
if has("gui_running")
  " カーソル行をハイライト
  set cursorline

  " カレントウィンドウにのみ罫線を引く
  augroup cch
    autocmd! cch
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
  augroup END
end
"}}}

highlight clear CursorLine
highlight CursorLine cterm=underline gui=underline
"}}}
" map for buffer {{{
nmap <silent> <C-b><C-n> :<C-u>bnext<CR>
nmap <silent> <C-b><C-p> :<C-u>bprevious<CR>
"}}}
" map for syntastic, etc {{{
nmap <silent> <C-g><C-n> :<C-u>lnext<CR>
nmap <silent> <C-g><C-p> :<C-u>lprevious<CR>
"}}}
"カーソル上の言葉をclipboardへヤンク "{{{
function! s:yank_to_clipboard()
  if &clipboard =~# 'unnamed'
    normal! yiw
  else
    set clipboard +=unnamed
    normal! yiw
    set clipboard -=unnamed
  endif
endfunction
nmap tt :call <SID>yank_to_clipboard()<CR>
"}}}
" 単語境界に-を追加 {{{
setlocal iskeyword +=-
function! s:toggle_is_key_word_hyphen() "{{{
  if &iskeyword =~# ',-'
    set iskeyword -=-
  else
    set iskeyword +=-
  endif
  echo &iskeyword
endfunction "}}}
command! ToggleIsKeyWordHyPhen  call s:toggle_is_key_word_hyphen()
nnoremap <Space>K :call <SID>toggle_is_key_word_hyphen()<CR>
"}}}
" clipboardにunnamedを追加 {{{
function! s:toggle_clipboard_unnamed() "{{{
  if &clipboard =~# 'unnamed'
    set clipboard -=unnamed
    echo 'clipboard mode OFF'
  else
    set clipboard +=unnamed
    echo 'clipboard mode ON'
  endif
endfunction "}}}
command! ToggleClipboardUnnamed call s:toggle_clipboard_unnamed()
nnoremap <Space>P :call <SID>toggle_clipboard_unnamed()<CR>
"}}}
" 折り畳み列幅 "{{{
function! s:toggle_fold_column()
  if &foldcolumn
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=4
  endif
endfunction
command! ToggleFoldColumn  call s:toggle_fold_column()
nnoremap <Space>G :call <SID>toggle_fold_column()<CR>
"}}}
" 末尾空白削除 {{{
"autocmd FileType cpp,python,perl,ruby,java autocmd BufWritePre <buffer> :%s/\s\+$//e
" cf: vim-bad-whitespace
function! s:trim_last_white_space() range
  execute a:firstline . ',' . a:lastline . 's/\s\+$//e'
endfunction
command! -range=% Trim :<line1>,<line2>call <SID>trim_last_white_space()
nnoremap <Leader>tr :%Trim<CR>
vnoremap <Leader>tr :Trim<CR>
"}}}
" QuickFixToggle {{{
function! s:quick_fix_toggle()
  let _ = winnr('$')
  cclose
  if _ == winnr('$')
    cwindow
  endif
endfunction
nnoremap <silent> <Space>: :call <SID>quick_fix_toggle()<CR>
"}}}
" LocationListToggle {{{
function! s:location_list_toggle()
  let _ = winnr('$')
  lclose
  if _ == winnr('$')
    lwindow
  endif
endfunction
nnoremap <silent> <Space>; :call <SID>location_list_toggle()<CR>
"}}}
" ChangeCurrentDir {{{
command! -nargs=? -complete=dir -bang CD  call s:ChangeCurrentDir('<args>', '<bang>')
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd ' . a:directory
  endif

  if a:bang == ''
    pwd
  endif
endfunction
nnoremap <silent> <Space>cd :<C-u>CD<CR>
"}}}
" for perl {{{
function! s:perl_filetype_settings()
  " perltidy
  nnoremap <Leader>pt :%!perltidy<CR>
  vnoremap <Leader>pt :!perltidy<CR>
endfunction

augroup perl_filetype
  autocmd! FileType perl call s:perl_filetype_settings()
  autocmd! BufNewFile,BufRead *.tmpl setf tt2html
augroup END
"}}}
" Map semicolon to colon {{{
nnoremap ; :
"}}}
" 矩形選択で行末を超えてブロックを選択できるようにする {{{
set virtualedit+=block
"}}}
" argdoの時の警告を無視 {{{
" http://vimcasts.org/episodes/using-argdo-to-change-multiple-files/
set hidden
"}}}
" diffoff! {{{
nmap <Leader>d :diffoff!<CR>
"}}}
" tab function {{{
nnoremap [Tab] <Nop>
nmap t [Tab]

for n in range(1, 9) | execute 'nnoremap <silent> [Tab]'.n  ':<C-u>tabnext'.n.'<CR>' | endfor
map <silent> [Tab]c :tablast <bar> tabnew<CR>
map <silent> [Tab]d :tabclose<CR>
map <silent> [Tab]n :tabnext<CR>
map <silent> [Tab]p :tabprevious<CR>
noremap gh gT   " Tab move to left
noremap gl gt   " Tab move to right
"}}}
" shellpipe {{{
" no buffering, to utf8
"if $LANG =~# 'UTF'
"  set shellpipe=2>\&1\|nkf\ -uw>%s
"endif
"}}}
" temporary workaround for previm {{{
fun! ChangeFileTypeToMarkDown(ft)
  let &ft = a:ft
endfun
au FileType mkd call ChangeFileTypeToMarkDown('markdown')
"}}}
" not to use undofile after 7.4.227 {{{
set noundofile
"}}}
" jq {{{
set noundofile
if executable('jq')
  function! s:jq(...)
    execute '%!jq' (a:0 == 0 ? '.' : a:1)
  endfunction
  command! -bar -nargs=? Jq call s:jq(<f-args>)
endif
"}}}
" helpをtab helpに {{{
cabbrev help tab help
"}}}
"======================================== for plugin settings ======================================== {{{
"}}}
" yanktmp.vim {{{
if v:version < 700 || (exists('g:loaded_yanktmp') && g:loaded_yanktmp || &cp)
  finish
endif
let g:loaded_yanktmp = 1

if !exists('g:yanktmp_file')
  let g:yanktmp_file = '/tmp/vimyanktmp'
endif

function! YanktmpYank() range
  call writefile(getline(a:firstline, a:lastline), g:yanktmp_file, 'b')
endfunction

function! YanktmpPaste_p() range
  let pos = getpos('.')
  call append(a:firstline, readfile(g:yanktmp_file, "b"))
  call setpos('.', [0, pos[1] + 1, 1, 0])
endfunction

function! YanktmpPaste_P() range
  let pos = getpos('.')
  call append(a:firstline - 1, readfile(g:yanktmp_file, "b"))
  call setpos('.', [0, pos[1], 1, 0])
endfunction

map <silent> sy :call YanktmpYank()<CR>
map <silent> sp :call YanktmpPaste_p()<CR>
map <silent> sP :call YanktmpPaste_P()<CR>
" }}}
" nelstrom/vim-visual-star-search {{{
" From http://got-ravings.blogspot.com/2008/07/vim-pr0n-visual-search-mappings.html

" makes * and # work on visual mode too.
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction

xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" recursively vimgrep for word under cursor or selection if you hit leader-star
nmap <leader>* :execute 'noautocmd vimgrep /\V' . substitute(escape(expand("<cword>"), '\'), '\n', '\\n', 'g') . '/ **'<CR>
vmap <leader>* :<C-u>call <SID>VSetSearch()<CR>:execute 'noautocmd vimgrep /' . @/ . '/ **'<CR>
" }}}
" bad-whitespace.vim {{{
function! s:EraseBadWhitespace(line1,line2)
  let l:save_cursor = getpos(".")
  silent! execute ':' . a:line1 . ',' . a:line2 . 's/\s\+$//'
  call setpos('.', l:save_cursor)
endfunction

" Run :EraseBadWhitespace to remove end of line white space.
command! -range=% EraseBadWhitespace call <SID>EraseBadWhitespace(<line1>,<line2>)
" }}}
" {{{
" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: nowrap
"}}}
