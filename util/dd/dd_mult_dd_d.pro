;==============================================================================
; dd_mult_dd_d
;
;==============================================================================
function dd_mult_dd_d, aa, b

;return, dd_split(b*dd_reduce(aa))

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]

 p1 = dd_two_prod(a0, b, e=p2)
 p2 = p2 + a1 * b
 p1 = dd_quick_two_sum(p1, p2, e=p2)

 pp = dd_real(p1, p2)
 return, reform(pp, dim, /over)
end
;==============================================================================
