;===================================================================================
; clusters
;
;===================================================================================
function clusters, p, radius

 n = n_elements(p)/2

 p0 = p[linegen3z(2,n,n)]
 p1 = transpose(p0, [0,2,1])

 r2 = p_sqmag(p0-p1)

 ii = where(r2 LE radius^2)
 w = where(r2[ii] NE 0)
 if(w[0] EQ -1) then return, 0

 ii = ii[w]

 jj = fix(ii/n)
 jjj = ii mod n

 j = [jj, jjj]
 ss = sort(j)
 j = j[ss]
 uu = uniq(j)
 j = j[uu]
 
 return, p[*,jj]
end
;===================================================================================
