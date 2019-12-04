;=============================================================================
; lagrange_interp
;
;=============================================================================
function lagrange_interp, _xk, _yk, x

 w = where(_yk NE 0)
 if(w[0] EQ -1) then return, 0

 xk = _xk[w]
 yk = _yk[w]

 nk = n_elements(xk)
 MM = make_array(nk,val=1d)

 top = (x[0]-xk)#MM
 top[diaggen(nk,1)] = 1
 top = prod(top,1)

 M = xk##MM
 bot = M - transpose(M)
 bot[diaggen(nk,1)] = 1
 bot = prod(bot, 1)

 P = total(top/bot * yk)

 return, P
end
;=============================================================================
