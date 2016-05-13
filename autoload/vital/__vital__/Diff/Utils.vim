function! s:loclist(diff, unified) abort
  let loclist = []
  for diff_for_file in a:diff
    let filename = diff_for_file.dest
    for hunk in diff_for_file.hunks
      let lnum = hunk.new_l
      let context_index = 0
      if lnum > a:unified
        let lnum += a:unified
        let context_index += a:unified
      endif
      let list = {
      \   'filename': filename,
      \   'lnum': lnum,
      \   'text': get(split(hunk.context, "\n"), context_index, hunk.heading),
      \ }
      let loclist += [list]
    endfor
  endfor
  return loclist
endfunction
