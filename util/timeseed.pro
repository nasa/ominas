;==================================================================================
; timeseed
;
;  constructs a random number seed from the system time.
;
;==================================================================================
function timeseed

 ;------------------------------
 ; get system time
 ;------------------------------
 time = systime()

 t = str_nsplit(time, ' ')
 w = where(strpos(t, ':') NE -1) 

 tt = double(str_nsplit(t[w], ':'))
 ntt = n_elements(tt)
 seed = total(tt*rotate(10^dindgen(ntt),2))

 return, seed
end
;==================================================================================
