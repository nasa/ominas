;================================================================================
; parse_numeric_list
;
;  Extracts a list of numeric strings delimited by non-numeric strings.
;
;================================================================================
function parse_numeric_list, s

 bb = byte(s)
 w = where((bb NE 46) AND (bb NE 45) AND ((bb LT 48) OR (bb GT 57)))
 bb[w] = 32
 ss = parse_comma_list(str_compress(strtrim(bb,2)), delim=' ')
 
 return, ss
end
;================================================================================


