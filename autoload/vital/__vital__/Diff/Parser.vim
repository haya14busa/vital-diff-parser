" git diff --no-color --no-ext-diff --no-prefix -U0

" @typedef {{
"   'old_l': number,
"   'old_s': number,
"   'new_l': number,
"   'new_s': number,
"   'context': string,
"   'heading': string?,
" }} hunk

" @typedef {list<{'src': string, 'dest': string, 'hunks': list<hunk>}>} diff

" @param {string} diff
" @return {diff}
function! s:parse(diff) abort
  let files = split(a:diff, "\n\\zediff")
  return map(files, 's:_hunk_from_file(v:val)')
endfunction

" http://stackoverflow.com/questions/6764953/what-is-the-reason-for-the-a-b-prefixes-of-git-diff
" https://git-scm.com/docs/git-diff
function! s:_hunk_from_file(diff_file) abort
  let lines = split(a:diff_file, "\n")
  let [diff_line, index_line, src_path_line, dest_path_line; rest] = lines
  " diff_line:      diff --git a/rc/dein.vim b/rc/dein.vim
  " index_line:     index feb07e4..5902d0d 100644
  " src_path_line:  --- a/rc/dein.vim
  " dest_path_line: +++ b/rc/dein.vim
  let src = matchstr(src_path_line, '^--- \zs.*$')
  let dest = matchstr(dest_path_line, '^+++ \zs.*$')
  let raw_hunks = split(join(rest, "\n"), "\n\\ze@@")
  let hunks = map(raw_hunks, 's:_parse_hunk(v:val)')
  return {
  \   'src': src,
  \   'dest': dest,
  \   'hunks': hunks,
  \ }
endfunction

" @param {string} raw_hunk
" @return {hunk}
" raw_hunk sample:
"   @@ -18 +18,2 @@ endif
"   -let g:vimrc_root = fnamemodify(expand('<sfile>:p'), ':p:h')
"   +let g:vimrc = expand('<sfile>')
"   +let g:vimrc_root = fnamemodify(g:vimrc, ':h')
" https://en.wikipedia.org/wiki/Diff_utility
" info_line: @@ -l,s +l,s @@ optional section heading
function! s:_parse_hunk(raw_hunk) abort
  let [info_line; context_lines] = split(a:raw_hunk, "\n")
  let pattern = '^@@ -\(\d\+\)\%(,\(\d\+\)\)\? +\(\d\+\)\%(,\(\d\+\)\)\? @@\%( \(.*\)\)\?$'
  let [_, orig_l, orig_s, new_l, new_s, heading; __] = matchlist(info_line, pattern)
  return {
  \   'orig_l': s:_str2nr(orig_l),
  \   'orig_s': s:_str2nr(orig_s),
  \   'new_l': s:_str2nr(new_l),
  \   'new_s': s:_str2nr(new_s),
  \   'heading': heading,
  \   'context': join(context_lines, "\n"),
  \ }
endfunction

function! s:_str2nr(str) abort
  return a:str is# '' ? 1 : str2nr(a:str, 10)
endfunction
