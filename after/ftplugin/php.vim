compiler phpunit

" Everything south of here stolen from https://github.com/dahu/VimTestRunner

function! RunMake(args)
  let l:sp = &shellpipe
  let &shellpipe = '2>&1 >'
  exec "make! " . a:args
  let &shellpipe = l:sp
endfunction

function! JumpToError()
  let has_valid_error = 0
  for error in getqflist()
    if error['valid']
      let has_valid_error = 1
      break
    endif
  endfor
  if has_valid_error
    let error_message = substitute(substitute(error['text'], '^\W*', '', ''), '\n', ' ', 'g')
    let bufnr = error['bufnr']
    let winnr = bufwinnr(bufnr)
    if winnr == -1
      exec "sbuffer " . error['bufnr']
    else
      exec winnr . "wincmd w"
    end
    silent cc!
    wincmd p
    redraw!
    return [1, error_message]
  else
    redraw!
    return [0, "All tests passed"]
  endif
endfunction

function! RedBar(message)
  hi RedBar ctermfg=black ctermbg=red guibg=red
  echohl RedBar
  echon repeat(" ",&columns - 1) . "\r" . a:message
  echohl
endfunction

function! GreenBar(message)
  hi GreenBar ctermfg=black ctermbg=green guibg=green
  echohl GreenBar
  echon repeat(" ",&columns - 1) . "\r" . a:message
  echohl
endfunction

function! ShowBar(response)
  if a:response[0]
    call RedBar(a:response[1])
  else
    call GreenBar(a:response[1])
  endif
endfunction

nnoremap <leader>a :silent call RunMake('')<CR>:call ShowBar(JumpToError())<CR>
nnoremap <leader>y :silent call RunMake('%')<CR>:call ShowBar(JumpToError())<CR>
