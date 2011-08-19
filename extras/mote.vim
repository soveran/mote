" Vim syntax file
" Language:     mote
" Maintainer:   Armin Ronacher <armin.ronacher@active-4.com>
" URL:          http://lucumr.pocoo.org/
" Last Change:  2008 September 12
" Version:	0.6.1
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if !exists("main_syntax")
  let main_syntax = 'html'
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = "html"
endif

" Source the html syntax file
ru! syntax/html.vim
unlet b:current_syntax

" Put the ruby syntax file in @rubyTop
syn include @rubyTop syntax/ruby.vim

" End keywords
syn keyword moteEnd contained else elsif end

" Block rules
syn region moteLine matchgroup=moteDelim start="^\s*%" end="$" keepend contains=@rubyTop,moteEnd

" Variables
syn region moteVariable matchgroup=moteDelim start="\${" end="}" contains=@rubyTop

" Newline Escapes
syn match moteEscape /\\$/

" Default highlighting links
if version >= 508 || !exists("did_mote_syn_inits")
  if version < 508
    let did_mote_syn_inits = 1
    com -nargs=+ HiLink hi link <args>
  else
    com -nargs=+ HiLink hi def link <args>
  endif

  HiLink moteDocComment moteComment
  HiLink moteDefEnd moteDelim

  HiLink moteAttributeKey Type
  HiLink moteAttributeValue String
  HiLink moteText Normal
  HiLink moteDelim Preproc
  HiLink moteEnd Keyword
  HiLink moteComment Comment
  HiLink moteEscape Special
  HiLink moteVariable Special

  delc HiLink
endif

let b:current_syntax = "eruby"
