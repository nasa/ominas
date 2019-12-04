;==============================================================================
; dd_add
;
;
;==============================================================================
function dd_add, aa, bb

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]

 b0 = bb[0:n-1]
 b1 = bb[n:*]

 
 s1 = dd_two_sum(a0, b0, e=s2)
 t1 = dd_two_sum(a1, b1, e=t2)
 s2 = s2 + t1
 s1 = dd_quick_two_sum(s1, s2, e=s2)
 s2 = s2 + t2
 s1 = dd_quick_two_sum(s1, s2, e=s2)

 ss = dd_real(s1, s2)
 return, reform(ss, dim, /over)
end
;==============================================================================
