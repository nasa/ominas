;=============================================================================
; parallelogram
;
;=============================================================================
function parallelogram, _p0, v1, v2, np=np, center=center

 if(NOT keyword_set(np)) then np = 1000

 p0 = _p0
 if(keyword_set(center)) then p0 = _p0 - 0.5d*(v1 + v2)

 vv1 = p_mag(v1)
 vv2 = p_mag(v2)

 _np = np/2
 np1 = long(_np * vv1/(vv1 + vv2)) > 1
 np2 = _np - np1

 np = 2*(np1 + np2)

 M1 = make_array(np1, val=1d)
 M2 = make_array(np2, val=1d)
 p01 = p0#M1
 p02 = p0#M2

 p1 = (p0 + v1)#M2
 p2 = (p0 + v2)#M2
 p12 = (p0 + v1 + v2)#M1

 t1 = transpose(dindgen(np1)/double(np1)) ## make_array(2, val=1d)
 t2 = transpose(dindgen(np2)/double(np2)) ## make_array(2, val=1d)

 vm1 = v1#M1
 vm2 = v2#M2

 pts = dblarr(2,np)

 pts[*,0:np1-1] = p01 + t1 * vm1
 pts[*,np1:np1+np2-1] = p1 + t2 * vm2
 pts[*,np1+np2:2*np1+np2-1] = p12 - t1 * vm1
 pts[*,2*np1+np2:*] = p2 - t2 * vm2

 return, pts
end
;=============================================================================
