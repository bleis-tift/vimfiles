set guioptions-=T
set guioptions-=m
set showtabline=2
set guioptions+=b
set nowrap
set mousemodel=extend
set columns=120
set lines=40
set clipboard=unnamed

colorscheme wombat
try
    set guifont=‚¤‚¸‚çƒtƒHƒ“ƒg:h14
catch /.*/
    " do nothing
endtry

autocmd guienter * set transparency=221

augroup InsertHook
    autocmd!
    autocmd InsertEnter * highlight StatusLine guifg=#CCDC90 guibg=#2E4340
    autocmd InsertLeave * highlight StatusLine guifg=#f6f3e8 guibg=#444444
augroup END

augroup cch
    autocmd! cch
    autocmd WinLeave * set nocursorline
    autocmd WinLeave * set nocursorcolumn
    autocmd WinEnter,BufRead * set cursorline
    autocmd WinEnter,BufRead * set cursorcolumn
augroup END

let g:defaultGuiFont = ""
function! ChangeGuiFontSize(diff)
    if (g:defaultGuiFont == "")
        g:defaultGuiFont = &guifont
    endif
    let fontsize = split(&guifont, ":")[1]
    let size = str2nr(fontsize[1:], 10)
    let newfontsize = printf("h%d", size + a:diff)
    let newguifont = substitute(&guifont, fontsize, newfontsize, "")
    execute 'setlocal guifont=' . newguifont
    echo newguifont
endfunction

function! ResetGuiFontSize()
    if (g:defaultGuiFont != "")
        execute 'setlocal guifont=' . g:defaultGuiFont
        g:defaultGuiFont = ""
    endif
endfunction

function! ZoomIn()
    call ChangeGuiFontSize(1)
endfunction

function! ZoomOut()
    call ChangeGuiFontSize(-1)
endfunction

command! ZoomIn     call ZoomIn()
command! ZoomOut    call ZoomOut()
command! ResetZoom  call ResetGuiFontSize()

nnoremap + :<C-u>ZoomIn<CR>
nnoremap - :<C-u>ZoomOut<CR>
nnoremap <Space>+ :<C-u>ResetZoom<CR>
nnoremap <Space>- :<C-u>ResetZoom<CR>

let s:colors = ['snow', '#ff4444', '#44dd44', '#ffaa44']
let s:idx = 0

function! ToggleCursorLine()
    let l:color = s:colors[s:idx]
    execute 'hi CursorLine guifg=black guibg=' . l:color . ' gui=bold'
    let s:idx = (s:idx + 1) % len(s:colors)
endfunction

command! TDDToggle call ToggleCursorLine()
"nnoremap <Tab>t :<C-u>TDDToggle<CR>
command! ResetCursorLine colorscheme wombat
