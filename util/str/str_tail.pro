;================================================================================
; str_tail
;
;================================================================================
function str_tail, s, n

 return, strmid(s, strlen(s)-n, strlen(s))

end
;================================================================================
