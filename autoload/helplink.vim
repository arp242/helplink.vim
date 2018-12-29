" Options
if !exists('g:helplink_formats')
	let g:helplink_formats = {
	\	'markdown':    "'[`:help ' . l:tagname . '`](' . l:url . ')'",
	\	'markdown_h':  "'[`:h ' . l:tagname . '`](' . l:url . ')'",
	\	'markdown_nt': "'[`' . l:tagname . '`](' . l:url . ')'",
	\	'html':        "'<a href=\"' . l:url . '\"><code>:help ' . l:tagname . '</code></a>'",
	\	'html_h':      "'<a href=\"' . l:url . '\"><code>:h ' . l:tagname . '</code></a>'",
	\	'html_nt':     "'<a href=\"' . l:url . '\"><code>' . l:tagname . '</code></a>'",
	\	'bbcode':      "'[url=' . l:url . '][code]:help ' . l:tagname . '[/code][/url]'",
	\	'bbcode_h':    "'[url=' . l:url . '][code]:h ' . l:tagname . '[/code][/url]'",
	\	'bbcode_nt':   "'[url=' . l:url . '][code]' . l:tagname . '[/code][/url]'",
	\	'plain':       "l:url"
	\}
endif
if !exists('g:helplink_copy_to_registers')
	let g:helplink_copy_to_registers = ['+', '*']
endif
if !exists('g:helplink_url')
	let g:helplink_url = 'http://vimhelp.appspot.com/%%FILE%%.html#%%TAGNAME_QUOTED%%'
endif
if !exists('g:helplink_default_format')
	let g:helplink_default_format = 'markdown'
endif
if !exists('g:helplink_always_ask')
	let g:helplink_always_ask = 0
endif

fun! helplink#link(...) abort
	let l:format = (a:0 && !empty(a:1)) ? a:1 : g:helplink_default_format
	if !has_key(g:helplink_formats, l:format)
		return s:err('unknown format: "%s"', l:format)
	endif

	let l:r = s:make_url()
	if empty(l:r) | return | endif

	let [l:tagname, l:tagname_q, l:url] = l:r
	let l:out = eval(g:helplink_formats[l:format])
	call s:copy_to_registers(l:out)
	return l:out
endfun

"##########################################################
" Helper functions

" Get the name of the nearest tag.
fun! s:get_tag(wordUnderCursor) abort
	let l:save_cursor = getpos('.')

	" Search backwards for the first tag
	normal! $
	if !search('\*\zs[^*]\+\*', 'bcW') && !search('\*\zs[^*]\+\.[^*]\+\*', 'bcW')
		call setpos('.', l:save_cursor)
		return s:err('no tag found before the cursor')
	endif

	" There are often a bunch of tags on a single line, get them all
	let l:tags = map(split(matchlist(getline('.'), '\*.*\*')[0]), 'v:val[1:-2]')

	" Just one tag, return it
	if len(l:tags) == 1
		call setpos('.', l:save_cursor)
		return l:tags[0]
	endif

	" Let the user choose
	let l:printText = ""
	let l:tagUnderCursor = -1
	let l:i = 1
	for l:t in l:tags
		let l:printText .= l:i . ' ' . l:t."\n"
		if l:t == a:wordUnderCursor
			let l:tagUnderCursor = l:i
		endif
		let l:i += 1
	endfor

	if l:tagUnderCursor != -1 && !g:helplink_always_ask
		let l:choice = l:tagUnderCursor
	else
		echo l:printText
		let l:choice = input('Which one: ')
		echo "\n"
	endif
	call setpos('.', l:save_cursor)
	return l:tags[l:choice - 1]
endfun


" urlencode
fun! s:quote_url(str) abort
	let l:new = ''
	for l:i in range(1, strlen(a:str))
		let l:c = a:str[l:i - 1]
		if l:c =~ '[a-zA-Z0-9\-._]'
			let l:new .= l:c
		else
			let l:new .= toupper(printf('%%%02x', char2nr(l:c)))
		endif
	endfor
	return l:new
endfun


" Make an URL
fun! s:make_url() abort
	if expand('%') == ''
		return s:err('this buffer has no file')
	endif

	let l:file = split(expand('%'), '/')[-1]
	let l:tagname = s:get_tag(expand('<cword>'))
	if empty(l:tagname) | return | endif
	let l:tagname_q = s:quote_url(l:tagname)

	let l:url = g:helplink_url
	let l:url = substitute(l:url, '%%FILE%%', l:file, 'g')
	let l:url = substitute(l:url, '%%TAGNAME%%', l:tagname, 'g')
	let l:url = substitute(l:url, '%%TAGNAME_QUOTED%%', l:tagname_q, 'g')

	return [l:tagname, l:tagname_q, l:url]
endfun


" Copy {str} to all the registers in |g:helplink_copy_to_registers|
fun! s:copy_to_registers(str) abort
	if !empty(g:helplink_copy_to_registers)
		for l:reg in g:helplink_copy_to_registers
			call setreg(l:reg, a:str)
		endfor
	endif
endfun

fun! s:err(msg, ...) abort
	echohl ErrorMsg
	echom 'helplink: ' . call('printf', [a:msg] + a:000)
	echohl None
endfun
