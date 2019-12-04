;=============================================================================
; str_rnd
;
;=============================================================================
function str_rnd, x, ndec, npad

 ;-------------------
 ; round and pad
 ;-------------------
 s = string(x, format='(d50.' + strtrim(ndec,2) + ')')


 ;---------------------------
 ; remove extraneous zeros
 ;---------------------------
 sb = str_decomp(str_flip(s))
 w = where(sb NE '0')
 if(w[0] NE -1) then sb = sb[min(w):*] 
 s = str_flip(str_recomp(sb))

 s = str_pad(strtrim(s,2), npad)

 return, s
end
;=============================================================================
