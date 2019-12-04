;==============================================================================
; dd_div
;
;  Long division of two double-doubles aa/bb.
;
;==============================================================================
function dd_div, aa, bb

;return, dd_split(dd_reduce(aa)/dd_reduce(bb))

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]

 b0 = bb[0:n-1]
 b1 = bb[n:*]

;rr = aa
;rr[0:n-1] = dd_reduce(aa)/dd_reduce(bb)
;rr[n:*] = 0
;return, rr
 
 q1 = a0/b0
 rr = dd_add(aa, dd_neg(dd_mult_dd_d(bb, q1)))
 r0 = rr[0:n-1]

 q2 = r0/b0
 rr = dd_add(rr, dd_neg(dd_mult_dd_d(bb, q2)))
 r0 = rr[0:n-1]

 q3 = r0/b0
 qq3 = dd_split(q3)

 q1 = dd_quick_two_sum(q1, q2, e=q2)
 rr = dd_add(dd_real(q1, q2), qq3)

 return, reform(rr, dim, /over)
end
;==============================================================================




;==============================================================================
; dd_div
;
;  Long division of two double-doubles aa/bb.
;
;==============================================================================
function ___dd_div, aa, bb

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]

 b0 = bb[0:n-1]
 b1 = bb[n:*]

 
 q1 = a0/b0
 qq1 = dd_split(q1)				; could also use a d x dd routine
 rr = dd_add(aa, dd_neg(dd_mult(qq1, bb)))
 r0 = rr[0:n-1]

 q2 = r0/b0
 qq2 = dd_split(q2)
 rr = dd_add(rr, dd_neg(dd_mult(qq2, bb))
 r0 = rr[0:n-1]

 q3 = r0/b0
 qq3 = dd_split(q3)

 q1 = dd_quick_two_sum(q1, q2, e=q2)
 rr = dd_add(dd_real(q1, q2), qq3)

 return, reform(rr, dim, /over)
end
;==============================================================================
