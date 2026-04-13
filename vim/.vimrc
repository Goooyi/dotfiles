set nocompatible
syntax on
syntax enable
filetype plugin indent on

set nofoldenable
set nobackup
set nowb
set noswapfile
set ic
set mouse=a
set number
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set splitright

" add arcfile support
au BufRead,BufNewFile *.arc set filetype=arc

" make subshell way more obvious
let $DGREY="\e[0;36m"
let $ENDCOLOR="\e[0m"
let $PS1="$DGREY#! $ENDCOLOR"

" get rid of the VertSplit | ugliness
set fillchars+=vert:\ 
hi VertSplit ctermbg=NONE

" hide the status message bar
set noshowmode
set noruler
set laststatus=0
set noshowcmd

" quiet pls
set visualbell t_vb=

" netrw on the right, similar to a VS Code side explorer
let maplocalleader = ","
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 30
let g:netrw_altv = 1

function! ToggleNetrw()
  for l:win in range(1, winnr('$'))
    if getbufvar(winbufnr(l:win), '&filetype') ==# 'netrw'
      execute l:win . 'wincmd c'
      return
    endif
  endfor

  botright vertical 30split
  execute 'Explore'
endfunction

nnoremap <silent> <leader>n :call ToggleNetrw()<CR>
nnoremap <silent> <localleader>n :call ToggleNetrw()<CR>

" no need to fold things in markdown all the time
let g:vim_markdown_folding_disabled = 1

" transparent background
highlight Normal guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE

" use system clipboard by default
set clipboard=unnamed

" function to send the yanked text via OSC 52
function! Osc52Yank()
    let buffer=system('base64', @0)
    let buffer=substitute(buffer, "\n", "", "")
    let buffer='\e]52;c;'.buffer.'\x07'

    " wrap in tmux escape sequence if inside tmux
    if exists('$TMUX')
        let buffer='\ePtmux;\e'.buffer.'\e\\'
    endif

    silent exe "run! echo -ne \"".buffer."\" > /dev/tty"
endfunction

" auto-trigger the function after every yank
augroup Osc52Yank
    autocmd!
    autocmd TextYankPost * call Osc52Yank()
augroup END

set termguicolors
