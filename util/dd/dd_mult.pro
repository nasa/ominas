;==============================================================================
; dd_mult
;
;==============================================================================
function dd_mult, aa, bb

;return, dd_split(dd_reduce(aa)*dd_reduce(bb))

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]

 b0 = bb[0:n-1]
 b1 = bb[n:*]

 
 p1 = dd_two_prod(a0, b0, e=p2)
 p2 = p2 + (a0*b1 + a1*b0)
 p1 = dd_quick_two_sum(p1, p2, e=p2)

 pp = dd_real(p1, p2)
 return, reform(pp, dim, /over)
end
;==============================================================================
