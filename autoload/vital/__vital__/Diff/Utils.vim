function! s:loclist(diff) abort
  let loclist = []
  for diff_for_file in a:diff
    let filename = diff_for_file.dest
    for hunk in diff_for_file.hunks
      let list = {
      \   'filename': filename,
      \   'lnum': hunk.new_l,
      \   'text': get(split(hunk.context, "\n"), 0, hunk.heading),
      \ }
      let loclist += [list]
    endfor
  endfor
  return loclist
endfunction
