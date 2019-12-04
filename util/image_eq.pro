;============================================================================
; image_eq
;
;============================================================================
function image_eq, image, $
		fraction=fraction, $		; fraction of power to include
		low=low, $			; relative weight toward sub-peak power
		min=min, max=max

 if(NOT keyword_set(fraction)) then fraction = 0.95
 if(NOT defined(low)) then low = 0.5

 ;--------------------------------
 ; get histogram and smooth it
 ;--------------------------------
 h = double(histogram(image))
 h[0] = 0
 scale = n_elements(h)/20
 h = smooth(h,scale)
 nh = n_elements(h)

 ;---------------------------------------------------------------------
 ; compute integrals on each side of peak, and extending to the tail
 ;---------------------------------------------------------------------
 m = (where(h EQ max(h)))[0]

 ptot = total(h)
 plow = total(rotate(h[0:m-1],2), /cum)
 phigh = total(h[m:*], /cum)


 ;---------------------------------------------------------------------
 ; search for the desired power fraction about peak
 ;---------------------------------------------------------------------
 w = min(where(plow/ptot GE fraction*low))
 if(w[0] EQ -1) then $
  begin
   min = 0
   max = max(where(total(h, /cum)/ptot LE fraction)) < nh-1
  end $
 else $
  begin
   min = m-1-w[0]
   max = (max(where(phigh/ptot LE fraction*(1.-low))) + m) < nh-1
  end


 ;---------------------------------------------------------------------
 ; return a scaled image
 ;---------------------------------------------------------------------
 return, bytscl(image, min=min, max=max) 
end
;============================================================================



