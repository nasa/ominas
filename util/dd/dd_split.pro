;==============================================================================
; dd_split
;
;  See Hida et al. 2000
;
;==============================================================================
function dd_split, a

 QD_SPLITTER = 134217729d					; 2^27 + 1
 QD_SPLIT_THRESH = 6.69692879491417d+299 			; 2^996

 dim = size([a], /dim)
 aa = dblarr([dim,2])
 n = n_elements(a) 

 hi = dblarr(n)
 lo = dblarr(n)

 w = where((a GT QD_SPLIT_THRESH) OR (a LT -QD_SPLIT_THRESH))
 ww = complement(a, w)

 if(w[0] NE -1) then $
  begin
   a[w] = a[w] * 3.7252902984619140625d-09			; 2^-28
   temp = QD_SPLITTER * a[w]
   hi[w] = temp - (temp - a[w])
   lo[w] = a[w] - hi[w]
   hi[w] = hi[w] * 268435456d					; 2^28
   lo[w] = lo[w] * 268435456d					; 2^28
  end
 if(ww[0] NE -1) then $
  begin
   temp = QD_SPLITTER * a[ww]
   hi[ww] = temp - (temp - a[ww])
   lo[ww] = a[ww] - hi[ww]
  end

 aa[0:n-1] = hi
 aa[n:*] = lo

 return, aa
end
;==============================================================================



;==============================================================================
; dd_split
;
;  See Hida et al. 2000
;
;==============================================================================
function dd_split, a

 nbits = 26d

 dim = size([a], /dim)
 aa = dblarr([dim,2])
 n = n_elements(a) 

 t = (2d^(nbits+1d) + 1d) * a

 aa[0:n-1] = t - (t - a)
 aa[n:*] = a - aa[0:n-1]

 return, aa
end
;==============================================================================
