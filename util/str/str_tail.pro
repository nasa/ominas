;================================================================================
; str_tail
;
;================================================================================
function str_tail, s, n, rem=rem

; ss = strmid(s, strlen(s)-n, strlen(s))
 ss = strmid_11(s, strlen(s)-n, strlen(s))
 if(arg_present(rem)) then rem = strmid(s, 0, strlen(s)-n)

 return, ss
end
;================================================================================
