;==============================================================================
; dd_quotient
;
;  Long division of two double-doubles xx/yy.
;
;==============================================================================
function dd_quotient, xx, yy

 dim = size(xx, /dim)
 n = n_elements(xx)/2
 
 x1 = xx[0:n-1]
 x2 = xx[n:*]

 y1 = yy[0:n-1]
 y2 = yy[n:*]

 
 result = dblarr(dim)


 q0 = x1/y1
 qq0 = dd_split(q0)
 r = xx - dd_prod(qq0, yy)
 r1 = r[0:n-1]

 q1 = r1/y1
 qq1 = dd_split(q1)
 r = xx - dd_prod(qq0 + qq1, yy)
 r1 = r[0:n-1]

 q2 = r1/y1
; qq2 = dd_split(q2)


 result = dd_renorm(q0, q1, q2)

 return, result
end
;==============================================================================
