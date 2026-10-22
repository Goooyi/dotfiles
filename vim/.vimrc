set nocompatible

" Space is the terminal-Vim equivalent of Command in GUI editors.
let mapleader = " "

set regexpengine=0
syntax enable
filetype plugin indent on

set nofoldenable
set nobackup
set nowb
set noswapfile
set ignorecase
set smartcase
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
set shortmess-=S
set hlsearch

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

function! FocusEditor()
  for l:win in range(1, winnr('$'))
    let l:buf = winbufnr(l:win)
    if getbufvar(l:buf, '&buftype') ==# ''
          \ && getbufvar(l:buf, '&filetype') !=# 'netrw'
      execute l:win . 'wincmd w'
      return
    endif
  endfor
endfunction

" GUI-aligned navigation: Command becomes Space in terminal Vim.
nnoremap <silent> <leader>e :call FocusEditor()<CR>
nnoremap <silent> <leader>r :call ToggleNetrw()<CR>
nnoremap <silent> <leader>n :call ToggleNetrw()<CR>
nnoremap <silent> <localleader>n :call ToggleNetrw()<CR>

" Quick Open: open buffers and recent project files rank ahead of the
" remaining project files, while all entries remain fuzzy-searchable.
function! s:AddProjectFile(files, seen, root, path) abort
  if empty(a:path)
    return
  endif

  let l:absolute = resolve(fnamemodify(a:path, ':p'))
  let l:root = substitute(resolve(fnamemodify(a:root, ':p')), '/$', '', '')
  if !filereadable(l:absolute)
        \ || (l:absolute !=# l:root && stridx(l:absolute, l:root . '/') != 0)
        \ || has_key(a:seen, l:absolute)
    return
  endif

  let a:seen[l:absolute] = 1
  call add(a:files, l:absolute)
endfunction

function! s:ProjectRoot() abort
  let l:start = empty(expand('%:p')) ? getcwd() : expand('%:p:h')
  if executable('git')
    let l:result = systemlist(
          \ 'git -C ' . shellescape(l:start) . ' rev-parse --show-toplevel 2>/dev/null')
    if v:shell_error == 0 && !empty(l:result)
      return l:result[0]
    endif
  endif
  return getcwd()
endfunction

function! s:ProjectFiles() abort
  let l:root = s:ProjectRoot()
  let l:files = []
  let l:seen = {}

  for l:buf in getbufinfo({'buflisted': 1})
    call s:AddProjectFile(l:files, l:seen, l:root, l:buf.name)
  endfor
  for l:path in v:oldfiles
    call s:AddProjectFile(l:files, l:seen, l:root, l:path)
  endfor

  if executable('rg')
    let l:project_files = systemlist(
          \ 'cd ' . shellescape(l:root)
          \ . ' && rg --files --hidden --glob ' . shellescape('!.git/*'))
    for l:path in l:project_files
      call s:AddProjectFile(l:files, l:seen, l:root, l:root . '/' . l:path)
    endfor
  else
    for l:path in globpath(l:root, '**/*', 0, 1)
      call s:AddProjectFile(l:files, l:seen, l:root, l:path)
    endfor
  endif

  let l:spec = {
        \ 'source': l:files,
        \ 'sink': 'edit',
        \ 'options': ['--prompt=Files> ', '--scheme=path', '--tiebreak=index']
        \ }
  call fzf#run(fzf#wrap(
        \ 'project-files', fzf#vim#with_preview(l:spec), 0))
endfunction

command! ProjectFiles call <SID>ProjectFiles()
nnoremap <silent> <leader>p :ProjectFiles<CR>
nnoremap <silent> <leader>P :Commands<CR>
nnoremap <silent> <leader>F :RG<CR>

" Ctrl-` is encoded as Ctrl-@ by traditional terminals. Space-t remains the
" portable fallback for terminals or remote environments that encode it elsewise.
nnoremap <silent> <leader>t :FloatermToggle<CR>
tnoremap <silent> <leader>t <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <C-@> :FloatermToggle<CR>
inoremap <silent> <C-@> <C-o>:FloatermToggle<CR>
tnoremap <silent> <C-@> <C-\><C-n>:FloatermToggle<CR>

" no need to fold things in markdown all the time
let g:vim_markdown_folding_disabled = 1

" use system clipboard by default
set clipboard=unnamed

" function to send the yanked text via OSC 52
function! Osc52Yank()
    " only real yanks, not deletes/changes
    if v:event.operator !=# 'y'
        return
    endif

    let text = join(v:event.regcontents, "\n")
    if v:event.regtype ==# 'V'
        let text .= "\n"
    endif

    " strip ALL newlines (GNU base64 wraps at 76 cols)
    let b64 = substitute(system('base64', text), '\n', '', 'g')
    let seq = "\e]52;c;" . b64 . "\x07"

    " wrap in tmux passthrough if inside tmux (needs: set -g allow-passthrough on)
    if exists('$TMUX')
        let seq = "\ePtmux;" . substitute(seq, "\e", "\e\e", 'g') . "\e\\"
    endif

    if exists('*echoraw')
        call echoraw(seq)
    else
        call writefile([seq], '/dev/tty', 'b')
    endif
endfunction

" auto-trigger the function after every yank
augroup Osc52Yank
    autocmd!
    autocmd TextYankPost * call Osc52Yank()
augroup END
