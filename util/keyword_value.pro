;=============================================================================
; keyword_value
;
;=============================================================================
function keyword_value, lines, keyword, delim=delim
 
 if(NOT keyword_set(delim)) then delim = ' '

 words = parse_comma_list(lines, delim=delim)
 dim = size(words, /dim)
 nwords = dim[0]
 nlines = 1 
 if(n_elements(dim) GT 1) then nlines = dim[1]

 vals = strarr(nlines)

 for i=0, nwords-1 do $
  begin
   word = transpose(words[i,*])
   keys = str_nnsplit(word, '=', rem=rem)
   w = where(keys EQ keyword)
   if(w[0] NE -1) then vals[w] = rem[w]
  end


 return, vals
end
;=============================================================================




;=============================================================================
; keyword_value
;
;=============================================================================
function __keyword_value, lines, keyword

 keywords = strtrim(str_nnsplit(lines, '=', rem=values),2)

 w = where(keywords EQ keyword)
 if(w[0] EQ -1) then return, ''

 return, values[w[0]]
end
;=============================================================================




