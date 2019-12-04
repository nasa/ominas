;=============================================================================
; set_intersection
;
;  Duplicate elements allowed in B.
; 
;=============================================================================
function set_intersection, A, B, iiA, iiB, kk

 iiA = (iiB = -1)

 ;--------------------------------------------------
 ; determine range of intersection
 ;--------------------------------------------------
 A_min = min(A) & A_max = max(A)
 B_min = min(B) & B_max = max(B)

 min = A_min > B_min
 max = A_max < B_max

 if(max LT min) then return, -1

 ;--------------------------------------------------
 ; find intersection
 ;--------------------------------------------------
 hA = histogram(A, min=min, max=max, rev=rrA, loc=loc)
 hB = histogram(B, min=min, max=max, rev=rrB)
 w = where((hA GT 0) AND (hB GT 0))

 if(w[0] EQ -1) then return, -1

 iiA = rrA[rrA[w]]
 iiB = rrB[rrB[w]]
 kk = iiA[iiB]
 

 ;--------------------------------------------------
 ; compute cross indices kk, such that A[kk] = B
 ;  elements of A must be unique
 ;--------------------------------------------------
 if(arg_present(kk)) then $
  if(max(hB) GT 1) then $
   begin
    kk = make_array(n_elements(B), val=-1l)

    ;- - - - - - - - - - - - - - - - - - -
    ; find unique histogram frequencies
    ;- - - - - - - - - - - - - - - - - - -
    ss = sort(hB)
    uu = uniq((hBss=hB[ss]))
    f = hBss[uu]

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; locate reverse indices for each non-zero frequency
    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
    for i=0, n_elements(f)-1 do if(f[i] NE 0) then $
     begin
      n = f[i]
      w = where(hB EQ n)
      if(w[0] NE -1) then $
       begin
        M = make_array(n,val=1l)
        ii = rrB[w]##M + lindgen(n)#make_array(n_elements(w),val=1l)
        iii = rrB[ii]
        kk[iii] = rrA[rrA[w##M]]
       end
     end
   end



 return, A[iiA]
end
;=============================================================================



; A = [1,2,3,4,5,6,7,8] & B = [2,2,2,3,3,4,4,9,9]
; ss = set_intersection(A, B, ii, jj, kk)
;    ss = [2,3,4]
;    ii = [1,2,3]
;    jj = [0,3,5]
;    kk = [1,1,1,2,2,3,3,-1,-1]

; A = [1,2,3,4,5,6,7,8] & B = [4,4,3,3,2,2]
; ss = set_intersection(A, B, ii, jj, kk)


; ss = set_intersection([1,2,3,4,5,6,7,8], [2,3,4,2,3,4], ii, jj, kk)

; ss = set_intersection(lindgen(100)+10, [20,31,45,100], ii, jj, kk)

; A = lindgen(100)+10 & B = [20,20,20,31,100,45,45]
; ss = set_intersection(A, B, ii, jj, kk)
;    ss = [20, 31, 45, 100]
;    ii = [10,21,35,90]
;    jj = [0,3,5,4]
;    kk = [10,10,10,21,90,35,35]

; A = lindgen(100)+10 & B = reverse([20,20,20,31,45,45,100])
; ss = set_intersection(A, B, ii, jj, kk)
;    ss = [20, 31, 45, 100]
;    ii = [10,21,35,90]
;    jj = [0,3,5,4]
;    kk = [10,10,10,21,90,35,35]

; A = reverse(lindgen(100)+10) & B = [20,20,20,31,45,45,100]
; ss = set_intersection(A, B, ii, jj, kk)
;    ss = [20, 31, 45, 100]
;    ii = [10,21,35,90]
;    jj = [0,3,5,4]
;    kk = [10,10,10,21,90,35,35]


; A = [lindgen(20)+10,lindgen(5)+2] & B = reverse([20,20,20,28,3,3,6])
; ss = set_intersection(A, B, ii, jj, kk)
;    ss = [20, 31, 45, 100]
;    ii = [10,21,35,90]
;    jj = [0,3,5,4]
;    kk = [10,10,10,21,90,35,35]

