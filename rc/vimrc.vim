"================================================================================
" basic {{{
"================================================================================
filetype plugin indent on
set number
set cursorline
set cursorcolumn
set history=1000
set showcmd
set showmatch
set clipboard=unnamed
set hidden
set showtabline=2
set columns=120
set lines=40

" special character
set list
set lcs=tab:^\ 
set showbreak=++++
set display=uhex

" stataus line
set statusline=%<%f\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%(Base64:%{Dec64()}\ %)%([%{GitBranch()}]%)%l,%c%8P

" tab character
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" encoding
set fenc=utf-8

" backup
set backupdir=$HOME/vimback
let &directory = &backupdir

" search
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nnoremap n nzz
nnoremap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
nnoremap <silent> <Esc> <Esc>:<C-u>set nohls<CR>
nnoremap / :<C-u>set hls<CR>/
nnoremap * :<C-u>set hls<CR>*

" :TOhtml
let g:use_xhtml = 1
let g:html_use_css = 1
let g:html_no_pre = 1
" }}}

"================================================================================
" key mapping {{{
"================================================================================

" help
nnoremap <Space>h :<C-u>help<Space>
nnoremap <F1> :<C-u>help <C-r><C-w><CR>
inoremap <F1> <Esc>:help <C-r><C-w><CR>

" select last changed text
nnoremap gc `[v`]
vnoremap gc :<C-u>normal gc<CR>
onoremap gc :<C-u>normal gc<CR>

" new line
nnoremap <Space><CR> :<C-u>call append(expand('.'), '')<CR>j
inoremap <S-CR> <Esc>:call append(expand('.'), '')<CR>ji

" move
for key in ['j', 'k', 'gg', 'G', '{', '}', '[', ']', '[(', '])',
            \ '[{', ']}', ']m', ']M', '[m', '[M', '[#', ']#', '[*', ']*', '[/', ']/',
            \ '%', 'H', 'L', 'w', 'W', 'e', 'ge', 'b', 'B', '<C-d>', '<C-u>', '<C-f>', '<C-b>']
    execute 'nnoremap ' . key . ' ' . key . 'zz'
endfor

inoremap <M-h> <LEFT>
inoremap <M-j> <DOWN>
inoremap <M-k> <UP>
inoremap <M-l> <RIGHT>

" tab page
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <C-Tab> gt
inoremap <C-Tab> <Esc>gt
nnoremap <Space>t :<C-u>tabnew 

" frame
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
inoremap <C-h> <Esc><C-w>h
inoremap <C-j> <Esc><C-w>j
inoremap <C-k> <Esc><C-w>k
inoremap <C-l> <Esc><C-w>l

" disabled all arrow keys
for key in ["Up", "Down", "Left", "Right"]
    execute "noremap <" . key . "> <NOP>"
    execute "noremap <M-" . key . "> <NOP>"
    execute "noremap <C-" . key . "> <NOP>"
    execute "noremap <S-" . key . "> <NOP>"
    execute "noremap! <" . key . "> <NOP>"
    execute "noremap! <M-" . key . "> <NOP>"
    execute "noremap! <C-" . key . "> <NOP>"
    execute "noremap! <S-" . key . "> <NOP>"
endfor

" color scheme
nnoremap <Space>morning :colo morning<CR>
nnoremap <Space>wombat :colo wombat<CR>

" folding
nnoremap <Space>o zo
nnoremap <Space>c zc

" command-line window
function! Enable_cmdwin_keymap()
    nnoremap <sid>(command-line-enter) q:
    xnoremap <sid>(command-line-enter) q:
    nnoremap <sid>(command-line-norange) q:<C-u>

    nmap :  <sid>(command-line-enter)
    xmap :  <sid>(command-line-enter)
endfunction

function! Disable_cmdwin_keymap()
    nunmap <sid>(command-line-enter)
    xunmap <sid>(command-line-enter)
    nunmap <sid>(command-line-norange)
    nunmap :
    xunmap :
endfunction

call Enable_cmdwin_keymap()

augroup MyAutoCmd
    autocmd!
    autocmd CmdwinEnter * call s:init_cmdwin()
augroup END

function! s:init_cmdwin()
    nnoremap <buffer> q :<C-u>quit<CR>
    nnoremap <buffer> <Tab> :<C-u>quit<CR>
    inoremap <buffer><expr><CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
    inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

    " Completion.
    inoremap <buffer><expr><Tab>  pumvisible() ? "\<C-n>" : "\<Tab>"

    nnoremap <buffer> <Esc><Esc> :<C-u>q<CR>
    inoremap <buffer> <Esc><Esc> <Esc>:q<CR>

    startinsert!
endfunction

" }}}

"================================================================================
" make {{{
"================================================================================

function! PadEcho(str)
    let l:result = a:str
    for i in range(len(a:str) + 1, &columns)
        let l:result .= ' '
    endfor
    return l:result
endfunction

function! NotifySuccess()
    echohl Success
    echo PadEcho('Success!')
    echohl None
endfunction

function! NotifyFailure()
    echohl Error
    echo PadEcho('oops!')
    echohl None
endfunction

function! DoMake()
    let l:result = vimproc#system('make')
    if vimproc#get_last_status() == 0
        hi Success guibg=#007700
        call NotifySuccess()
        return
    endif
    botright new
    setlocal buftype=nofile readonly modifiable
    setlocal filetype=errmsg
    silent put=l:result
    call NotifyFailure()
endfunction
command! DoMake call DoMake()
nnoremap <Space>m :<C-u>w<CR>:DoMake<CR>
" }}}

"================================================================================
" vimrc & gvimrc {{{
"================================================================================

function! SourceIfExists(file)
    if filereadable(expand(a:file))
        execute 'source ' . a:file
    endif
    echo 'Reloaded vimrc and gvimrc.'
endfunction

let vimrcbody = '$HOME/vimfiles/rc/vimrc.vim'
let gvimrcbody = '$HOME/vimfiles/rc/gvimrc.vim'
function! OpenFile(file)
    let empty_buffer = line('$') == 1 && strlen(getline('1')) == 0
    if empty_buffer && !&modified
        execute 'e ' . a:file
    else
        execute 'tabnew ' . a:file
    endif
endfunction
command! OpenMyVimrc call OpenFile(vimrcbody)
command! OpenMyGVimrc call OpenFile(gvimrcbody)

" reload vimrc and gvimrc
nnoremap <F5> <Esc>:<C-u>source $MYVIMRC<CR>
            \ :source $MYGVIMRC<CR>
            \ :call SourceIfExists('~/vimfiles/ftplugin/' . &filetype . '.vim')<CR>
" open vimrc/gvimrc
nnoremap <Space><Space> :<C-u>OpenMyVimrc<CR>
nnoremap <Space><Tab> :<C-u>OpenMyGVimrc<CR>
" }}}

"================================================================================
" utils {{{
"================================================================================

command! -nargs=1 -complete=file Rename file <args>|call delete(expand('#'))

command! -bang -nargs=? Utf8 edit <bang> ++enc=utf-8 <args>
command! -bang -nargs=? Sjis edit <bang> ++enc=cp932 <args>
command! -bang -nargs=? Cp932 edit <bang> ++enc=cp932 <args>
command! -bang -nargs=? Euc edit <bang> ++enc=euc-jp <args>

autocmd FileType *
            \   if &l:omnifunc == ''
            \ |   setlocal omnifunc=syntaxcomplete#Complete
            \ | endif

" caps lock
function! CapsLock(isOn)
    for key in range(char2nr('a'), char2nr('z'))
        let l:lower = nr2char(key)
        let l:upper = nr2char(key - char2nr('a') + char2nr('A'))
        if a:isOn
            execute "inoremap <buffer> " . l:lower . " " . l:upper
            execute "inoremap <buffer> " . l:upper . " " . l:lower
        else
            execute "iunmap <buffer> " . l:lower
            execute "iunmap <buffer> " . l:upper
        endif
    endfor
endfunction

command! Upper call CapsLock(1)
command! Lower call CapsLock(0)

" key map
command!
            \ -nargs=* -complete=mapping
            \ AllMaps
            \ map <args> | map! <args> | lmap <args>

" auto cd
au BufEnter *   execute ":lcd " . expand("%:p:h")

" auto input close tag
augroup Xml
    autocmd!
    autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
augroup END

" auto input end for tex
augroup TeX
    autocmd!
    autocmd FileType tex inoremap <buffer> \e \end{<C-x><C-o>
augroup END

function! CompleteTeX(findstart, base)
    if a:findstart
        let cur_text = strpart(getline('.'), 0, col('.') - 1)
        return match(cur_text, '\\end{$')
    endif

    let current = line('.')
    for line in range(0, current - 1)
        let str = strpart(getline(current - line), 0)
        let pos = match(str, '\\begin{[^}]*}')
        if pos != -1
            let elem = strpart(str, pos + 7, match(str, '}', pos + 7) - pos - 7)
            let result = { 
                        \ 'word' : '\end{' . elem . '}',
                        \ 'abbr' : elem,
                        \ 'menu' : 'complete tex'
                        \ }
            return [result]
        endif
    endfor
    return []
endfunction
au FileType tex setlocal omnifunc=CompleteTeX

" Comment or uncomment lines from mark a to mark b.
function! CommentMark(doc, a, b)
    if !exists('b:comment')
        let b:comment = CommentStr() . ' '
    endif
    if a:doc
        execute "normal! '" . a:a . "_\<C-V>'" . a:b . 'I' . b:comment
    else
        execute "'" . a:a . ",'" . a:b . 's/^\(\s*\)' . escape(b:comment, '/') . '/\1/e'
    endif
endfunction

function! DoCommentOp(type)
    call CommentMark(1, '[', ']')
endfunction

function! UnCommentOp(type)
    call CommentMark(0, '[', ']')
endfunction

function! CommentStr()
    if &ft == 'cpp' || &ft == 'java' || &ft == 'javascript' || &ft == 'cs' || &ft == 'scala' || &ft == 'fs'
        return '//'
    elseif &ft == 'vim'
        return '"'
    elseif &ft == 'python' || &ft == 'perl' || &ft == 'sh' || &ft == 'ruby' || &ft == 'gitcommit'
        return '#'
    else if &ft == 'tex'
        return '%'
    endif
    return ''
endfunction

nnoremap <Space>c <Esc>:set opfunc=DoCommentOp<CR>g@
nnoremap <Space>C <Esc>:set opfunc=UnCommentOp<CR>g@
vnoremap <Space>c <Esc>:call CommentMark(1, '<', '>')<CR>
vnoremap <Space>C <Esc>:call CommentMakr(0, '<', '>')<CR>

augroup vimrc
    autocmd!
augroup END
function! s:is_changed() "{{{
    try
        " When no `b:vimrc_changedtick` variable
        " (first time), not changed.
        return exists('b:vimrc_changedtick')
                    \   && b:vimrc_changedtick < b:changedtick
    finally
        let b:vimrc_changedtick = b:changedtick
    endtry
endfunction "}}}
autocmd vimrc CursorMovedI * if s:is_changed() | doautocmd User changed-text | endif

let s:current_changed_times = 0
let s:max_changed_times = 10
function! s:changed_text() "{{{
    if s:current_changed_times >= s:max_changed_times - 1
        call feedkeys("\<C-g>u", 'n')
        let s:current_changed_times = 0
    else
        let s:current_changed_times += 1
    endif
endfunction "}}}
autocmd vimrc User changed-text call s:changed_text()

" }}}

"================================================================================
" plugin settings {{{
"================================================================================

" verifyenc
let g:plugin_verifyenc_disable = 1

" dictwin.vim
let g:plugin_dicwin_disable = 1

" eregex.vim
noremap // :<C-u>M/

" git.vim settings
let g:git_no_map_default = 1
let g:git_command_edit = 'rightbelow vnew'
nnoremap <Space>gd :<C-u>GitDiff --cached<CR>
nnoremap <Space>gD :<C-u>GitDiff<CR>
nnoremap <Space>gs :<C-u>GitStatus<CR>
nnoremap <Space>gl :<C-u>GitLog<CR>
nnoremap <Space>gL :<C-u>GitLog -u \| head -10000<CR>
nnoremap <Space>ga :<C-u>GitAdd<CR>
nnoremap <Space>gA :<C-u>GitAdd <cfile><CR>
nnoremap <Space>gc :<C-u>GitCommit<CR>
nnoremap <Space>gC :<C-u>GitCommit --amend<CR>
nnoremap <Space>gn :<C-u>w<CR>:Git now<CR>
nnoremap <Space>gN :<C-u>w<CR>:Git now --all<CR>
nnoremap <Space>now :<C-u>w<CR>:Git now<CR>

" gtags.vim settings
if globpath(&rtp, 'plugin/gtags.vim') != ''
    nnoremap <F12> :<C-u>Gtags <cword><CR>
    nnoremap <S-F12> :<C-u>Gtags -r <cword><CR>
endif

" utl.vim
nnoremap <Space>url :<C-u>Utl<CR>
nnoremap <Space>utl :<C-u>Utl<CR>

" template.vim
noremap <Insert> :<C-u>TemplateLoad<CR>
noremap! <Insert> <Esc>:TemplateLoad<CR>i

" neocomplcache
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_dictionary_filetype_lists = {'default' : ''}
imap <expr><Tab> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" :
            \    pumvisible()                                         ? "\<C-n>"
            \                                                         : "\<TAB>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<BS>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()
augroup Neco
    autocmd!
    autocmd FileType *
                \   if &filetype !=# ''
                \       && findfile(&filetype . '.dict', '~/vimfiles/dict') !=# ''
                \       && !has_key(g:neocomplcache_dictionary_filetype_lists, &filetype)
                \ |     call extend(g:neocomplcache_dictionary_filetype_lists,
                \           { &filetype : findfile(&filetype . '.dict', '~/vimfiles/dict') })
                \ | endif
augroup END

" echodoc
let g:echodoc_enable_at_startup = 1

" vimshell
let g:vimshell_user_prompt = 'getcwd()'
let g:vimshell_right_prompt = 'vimshell#vcs#info("(%s)-[%b]", "(%s)-[%b|%a]")'
let g:vimshell_split_command = "botright new"
noremap <Space>sh :<C-u>VimShell<CR>
noremap <Space>fsi :<C-u>VimShellInteractive fsi<CR>
noremap <Space>ruby :<C-u>VimShellInteractive irb<CR>
noremap <Space>rb :<C-u>VimShellInteractive irb<CR>
noremap <Space>irb :<C-u>VimShellInteractive irb<CR>
noremap <M-^> :VimShellSendString<CR>
vmap <M-CR> :VimShellSendString<CR>
noremap <M-CR> :<C-u>%VimShellSendString<CR>
noremap! <M-CR> <Esc>:%VimShellSendString<CR>

" unite.vim
let g:unite_enable_start_insert = 1

function! HUnite(cmd)
    let g:unite_enable_split_vertically = 0
    let g:unite_split_rule = 'botright'
    execute 'Unite ' . a:cmd
endfunction

function! VUnite(cmd)
    let g:unite_enable_split_vertically = 1
    let g:unite_winwidth = 40
    let g:unite_split_rule = 'topleft'
    execute 'Unite ' . a:cmd
endfunction

nnoremap <C-Space> :<C-u>Unite<Space>
nnoremap <silent> <Space>uu :<C-u>call HUnite('-buffer-name=files -auto-preview buffer file_rec file_mru')<CR>
nnoremap <silent> <Space>uf :<C-u>UniteWithBufferDir -buffer-name=files file_rec<CR>
nnoremap <silent> <Space>ur :<C-u>call HUnite('-buffer-name=register register')<CR>
nnoremap <silent> <Space>uc :<C-u>call VUnite('-auto-preview colorscheme')<CR>
nnoremap <silent> <Space>uh :<C-u>call HUnite('-buffer-name=help help')<CR>

au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite nnoremap <silent> <buffer> <expr> <C-k> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-k> unite#do_action('split')
au FileType unite nnoremap <silent> <buffer> <expr> <C-h> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-h> unite#do_action('vsplit')
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite nnoremap <silent> <buffer> <Esc><Esc> :<C-u>q<CR>
au FileType unite inoremap <silent> <buffer> <Esc><Esc> <Esc>:q<CR>

" zencoding.vim
let g:user_zen_expandabbr_key = "<C-Cr>"

" surround.vim
vmap <Space>Vsurround <Plug>Vsurround
vmap <Space>VSurround <Plug>VSurround

" Vundle
filetype off
set rtp& rtp+=~/vimfiles/vundle.git/
call vundle#rc('$HOME/vimfiles/bundle')

" Github repos: Bundle 'user_name/repos_name'
" Vim-Scripts repos: Bundle 'script_name'
" other git repos: Bundle 'git://full/path/to/git/repos'

Bundle 'utl.vim'

Bundle 'kana/vim-surround'

Bundle 'motemen/git-vim'

Bundle 'Shougo/echodoc'
Bundle 'Shougo/vimshell'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/vimfiler'
Bundle 'Shougo/unite.vim'

Bundle 'Shougo/unite-help'
Bundle 'Shougo/unite-grep'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'ujihisa/unite-font'
Bundle 'h1mesuke/unite-outline'
Bundle 'thinca/vim-unite-history'
Bundle 'sgur/unite-git_grep'
Bundle 'sgur/unite-qf'

Bundle 'killerswan/fs.vim'

Bundle 'thinca/vim-template'

Bundle 'mattn/zencoding-vim'

filetype plugin indent on

autocmd FileType *
            \   if &l:omnifunc == ''
            \ |     setlocal omnifunc=syntaxcomplete#Complete
            \ | endif

" }}}

"================================================================================
" Scouter {{{
"================================================================================
" scouter
function! Scouter(file, ...)
    let pat = '^\s*$\|^\s*"'
    let lines = readfile(a:file)
    if !a:0 || !a:1
        let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
    endif
    return len(filter(lines,'v:val !~ pat'))
endfunction
command! -bar -bang -nargs=? -complete=file Scouter
            \ echo Scouter(empty(<q-args>) ? expand(vimrcbody) : expand(<q-args>), <bang>0)
command! -bar -bang -nargs=? -complete=file GScouter
            \ echo Scouter(empty(<q-args>) ? expand(gvimrcbody) : expand(<q-args>), <bang>0)
" }}}

"================================================================================
" Base64 {{{
"================================================================================
function! D2B(i)
    let l:work = []
    let l:num = a:i
    while l:num != 0
        call insert(l:work, l:num % 2)
        let l:num = l:num / 2
    endwhile

    let l:result = '000000'
    for i in l:work
        let l:result .= i
    endfor
    return strpart(l:result, len(l:result) - 6)
endfunction
let s:AsciiChars =
            \ "??????????\n\t?\r??" .
            \ '????????????????' .
            \ ' !"#$%&''()*+,-./' .
            \ '0123456789:;<=>?' .
            \ '@ABCDEFGHIJKLMNO' .
            \ 'PQRSTUVWXYZ[\]^_' .
            \ '`abcdefghijklmno' .
            \ 'pqrstuvwxyz{|}~?'
function! Bin2Ch(bin)
    let l:ascii = 0
    let l:ascii += a:bin[0] == '1' ? 128 : 0
    let l:ascii += a:bin[1] == '1' ? 64 : 0
    let l:ascii += a:bin[2] == '1' ? 32 : 0
    let l:ascii += a:bin[3] == '1' ? 16 : 0
    let l:ascii += a:bin[4] == '1' ? 8 : 0
    let l:ascii += a:bin[5] == '1' ? 4 : 0
    let l:ascii += a:bin[6] == '1' ? 2 : 0
    let l:ascii += a:bin[7] == '1' ? 1 : 0
    return s:AsciiChars[l:ascii]
endfunction
let s:Base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function! Dec64()
    let l:row = line(".")
    let l:col = col(".")
    let l:line = getline(l:row)
    let l:from = l:col
    while l:from != 0
        let l:ch = l:line[l:from]
        if l:ch != '=' && stridx(s:Base64Chars, l:ch) == -1
            let l:from += 1
            break
        endif
        let l:from -= 1
    endwhile
    let l:to = l:from + 1
    while l:to < len(l:line)
        let l:ch = l:line[l:to]
        if stridx(s:Base64Chars, l:ch) == -1
            break
        endif
        let l:to += 1
    endwhile
    let l:target = strpart(l:line, l:from, l:to - l:from)
    let l:bin = ''
    for i in range(0, len(l:target) - 1)
        let l:ch = l:target[i]
        let l:idx = stridx(s:Base64Chars, l:ch)
        let l:bin .= D2B(l:idx)
    endfor
    let l:result = ''
    while l:bin != '' && len(l:bin) >= 8
        let l:t = strpart(l:bin, 0, 8)
        let l:bin = strpart(l:bin, 8)
        let l:result .= Bin2Ch(l:t)
    endwhile
    return l:result
endfunction
" }}}

"================================================================================
" Encoding {{{
"================================================================================

if &encoding !=# 'utf-8'
    set encoding=japan
    set fileencoding=japan
endif
if has('iconv')
    let s:enc_euc = 'euc-jp'
    let s:enc_jis = 'iso-2022-jp'
    " iconvがeucJP-msに対応しているかをチェック
    if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'eucjp-ms'
        let s:enc_jis = 'iso-2022-jp-3'
        " iconvがJISX0213に対応しているかをチェック
    elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
        let s:enc_euc = 'euc-jisx0213'
        let s:enc_jis = 'iso-2022-jp-3'
    endif
    " fileencodingsを構築
    if &encoding ==# 'utf-8'
        let s:fileencodings_default = &fileencodings
        let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
        let &fileencodings = &fileencodings .','. s:fileencodings_default
        unlet s:fileencodings_default
    else
        let &fileencodings = &fileencodings .','. s:enc_jis
        set fileencodings+=utf-8,ucs-2le,ucs-2
        if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
            set fileencodings+=cp932
            set fileencodings-=euc-jp
            set fileencodings-=euc-jisx0213
            set fileencodings-=eucjp-ms
            let &encoding = s:enc_euc
            let &fileencoding = s:enc_euc
        else
            let &fileencodings = &fileencodings .','. s:enc_euc
        endif
    endif
    " 定数を処分
    unlet s:enc_euc
    unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に utf-8 を使うようにする
if has('autocmd')
    function! AU_ReCheck_FENC()
        if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
            let &fileencoding='utf-8'
        endif
    endfunction
    autocmd BufReadPost * call AU_ReCheck_FENC()
endif

" }}}

"================================================================================
" typo collect {{{
"================================================================================

abbr recieve receive
abbr Bundole Bundle
abbr BundoleInstall BundleInstall
abbr bundole bundle
abbr calender calendar

" }}}

"================================================================================
" unite-neco {{{
"================================================================================
let s:unite_source = {'name': 'neco'}

function! s:unite_source.gather_candidates(args, context)
    let necos = [
                \ "~(-'_'-) goes right",
                \ "~(-'_'-) goes right and left",
                \ "~(-'_'-) goes right quickly",
                \ "~(-'_'-) goes right then smile",
                \ "~(-'_'-)  -8(*'_'*) go right and left",
                \ "(=' .' ) ~w",
                \ ]
    return map(necos, '{
                \ "word": v:val,
                \ "source": "neco",
                \ "kind": "command",
                \ "action__command": "Neco " . v:key,
                \ }')
endfunction

"function! unite#sources#locate#define()
"  return executable('locate') ? s:unite_source : []
"endfunction
call unite#define_source(s:unite_source)
unlet s:unite_source

" }}}
