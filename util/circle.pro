;=============================================================================
; circle
;
;
;=============================================================================
function circle, center, radius, np=np, close=close

 radius = double(radius)
 n = n_elements(radius)
 if(NOT keyword_set(np)) then np = round(2d*!dpi*max(radius))
 
 theta = dindgen(np) / np * 2d*!dpi

 xy = dblarr(2,n,np, /nozero)
 xy[0,*,*] = radius # cos(theta)
 xy[1,*,*] = radius # sin(theta)


 p = xy + center[linegen3z(2,n,np)]
 p = reform(p, 2, n*np)

 if(keyword_set(close)) then p = transpose([transpose(p), transpose(p[*,0])])

 return, p
end
;=============================================================================
