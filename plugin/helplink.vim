" helplink.vim: link to Vim help pages with ease.
"
" http://code.arp242.net/helplink.vim
"
" See the bottom of this file for copyright & license information.


"##########################################################
" Initialize some stuff
scriptencoding utf-8
if exists('g:loaded_helplink') | finish | endif
let g:loaded_helplink = 1
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -complete=help Helplink call s:echo(helplink#link(<q-args>))

" Echo only if string is non-empty
fun! s:echo(str)
	if !empty(a:str) | echo a:str | endif
endfun

let &cpo = s:save_cpo
unlet s:save_cpo


" The MIT License (MIT)
"
" Copyright © 2015-2017 Martin Tournoij
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
