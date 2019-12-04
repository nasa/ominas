;=============================================================================
; read_json
;
;=============================================================================
function read_json, filename

 record = {filename:'', time:0d}

 lines = read_txt_file(filename)
 nlines = n_elements(lines)

 lines = strep_char(lines, '{', ' ')
 lines = strep_char(lines, '}', ' ')
 lines = strep_char(lines, '"', ' ')
 lines = strep_char(lines, ',', ' ')
 lines = strep_char(lines, ':', ' ')
 lines = str_compress(strtrim(lines,2))

 tab = parse_comma_list(lines, delim=' ')

 result = replicate(record, nlines)
 result.filename = reform(tab[0,*])
 result.time = reform(double(tab[1,*]))

 return, result
end
;=============================================================================


