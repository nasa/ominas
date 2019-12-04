;=============================================================================
; parse_comma_list
;
;
;=============================================================================
function parse_comma_list, _s, delim=delim

 if(NOT keyword_set(delim)) then delim = ','

 s = ''

 rem = _s
 repeat begin
  ss = str_nnsplit(rem, delim, rem=rem)
  w = where(ss NE '')
  if(w[0] NE -1) then s = append_array(s, transpose([ss])) 
 endrep until(w[0] EQ -1)

 if(keyword_set(rem)) then $
  begin
   if(keyword_set(s)) then s = [s, transpose([rem])] $
   else s = transpose([rem])
  end


 return, s
end
;=============================================================================




;=============================================================================
; parse_comma_list
;
;
;=============================================================================
function _parse_comma_list, _s, delim=delim

 if(NOT keyword_set(delim)) then delim = ','

 s = _s

 s = transpose([str_nnsplit(s, delim, rem=rem)])
 for i=0, 3 do s = [s, transpose([str_nnsplit(rem, delim, rem=rem)])]
 array = transpose([s, transpose([rem])])


 return, array
end
;=============================================================================





