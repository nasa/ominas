;==============================================================================
; curve_rectify
;
;  Rearranges points so as to minimizes distances between neighbors.
;
;==============================================================================
function curve_rectify, p, sub=sub

 ;-----------------------------------
 ; compute distance matrix
 ;-----------------------------------
 x = transpose(p[0,*])
 y = transpose(p[1,*])

 n = n_elements(x)
 sub = make_array(n, val=-1l)
 M = make_array(n, val=1d)

 dx = x#M - x##M
 dy = y#M - y##M

 dp2 = dx^2 + dy^2

 zz = diaggen(n,1)


 ;----------------------------------------
 ; find endpoints, if any
 ;----------------------------------------
 dp2[zz] = 1d100
 dp2min = min(dp2, ww, dim=2)

 dp2[zz] = 0
 dp2max = max(dp2, dim=2)

 dp2min_avg = mean(dp2min)
 w = where(dp2max EQ max(dp2max))
 sub[0] = 0
 if(dp2max[w[0]] GT 4*dp2min_avg) then sub[0] = w[0]


 ;----------------------------------------
 ; crawl along curve
 ;----------------------------------------
 for i=1, n-1 do $
  begin
   ii = sub[i-1]

   jj = ii
   repeat $
    begin
     dp2[jj,ii] = 1d100
     dmin = min(dp2[*,ii], jj)
     w = where(sub EQ jj)
    endrep until(w EQ -1)

   sub[i] = jj
  end


 return, p[*,sub]
end
;==============================================================================






;==============================================================================
; curve_rectify
;
;  Rearranges points so as to minimizes distances between neighbors.
;
;==============================================================================
function ___curve_rectify, p, sub=sub

 ;-----------------------------------
 ; compute distance matrix
 ;-----------------------------------
 x = transpose(p[0,*])
 y = transpose(p[1,*])

 n = n_elements(x)
 sub = lindgen(n)
 M = make_array(n, val=1d)

 dx = x#M - x##M
 dy = y#M - y##M

 dp2 = dx^2 + dy^2


 ;-----------------------------------
 ; swap columns until 
 ;-----------------------------------
 repeat $
  begin
;tvscl, dp2
wait, 0.01
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; find largest array offset between closest points
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   dp2min = nmin(dp2, 1, sub=w, /pos)		; dists to closest other point
   ww = w + n*dindgen(n)			; indices in dp2 for min dists
   ii = diaggen(n,1)				; diaginal indices in dp2

;plot, w
   m = max(abs(ii-ww), mm)			

;print, mm
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; if any neighbors are separated by more than one array index, move 
   ; the most offset one next to its neighbor
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(m GT 1) then $
    begin
     mmm = mm-1				; move to either point before or after
     if(mmm LT 0) then mmm = mm+1	; diagonal element

;stop
;     ss = swapgen(n,n, w[mm],mmm, /col)
     ss = movegen(n,n, w[mm],mmm, /col)

     sub = sub[ss[*,0]]

     dp2 = dp2[ss]
     dp2[trianggen(n, /lower)] = (transpose(dp2))[trianggen(n, /lower)]
    end

  endrep until(m EQ 1)


stop

end
;==============================================================================
