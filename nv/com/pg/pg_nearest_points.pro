;=============================================================================
;++
; NAME:
;	pg_nearest_points
;
;
; PURPOSE:
;	xx
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = xx(xx, xx)
;	xx, xx, xx
;
;
; ARGUMENTS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; KEYWORDS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; ENVIRONMENT VARIABLES:
;	xx:	xx
;
;	xx:	xx
;
;
; RETURN:
;	xx
;
;
; COMMON BLOCKS:
;	xx:	xx
;
;	xx:	xx
;
;
; SIDE EFFECTS:
;	xx
;
;
; RESTRICTIONS:
;	xx
;
;
; PROCEDURE:
;	xx
;
;
; EXAMPLE:
;	xx
;
;
; STATUS:
;	xx
;
;
; SEE ALSO:
;	xx, xx, xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	xx, xx/xx/xxxx
;	
;-
;=============================================================================
function pg_nearest_points, object_ptd, _ptd
@pnt_include.pro

 ptd = pnt_cull(_ptd)

 n = n_elements(ptd)
 if(n EQ 1) then return, ptd

 ;---------------------------
 ; get object vectors
 ;---------------------------
 v = pnt_vectors(object_ptd)

 nv = n_elements(v)/3

 object_vec = v[linegen3z(nv,3,n)]

 ;--------------------------------
 ; build array of test vectors
 ;--------------------------------
 vec = dblarr(nv,3,n)
 pts = dblarr(2,nv,n)
 flags = bytarr(nv,n)

 for i=0, n-1 do $
  begin
   pnt_query, ptd[i], v=v, p=p, flag=flag
   if(n_elements(v) NE 3*nv) then nv_message, 'Incompatible arrays.'
   vec[*,*,i] = v
   pts[*,*,i] = p
   flags[*,i] = flag
   w = where((flag AND PTD_MASK_INVISIBLE) EQ 1)
   if(w[0] NE -1) then vec[w,*,i] = 1d100	; exclude invisible points
  end

 pts = transpose(pts, [1,0,2])

 ;-------------------------------------------------
 ; compute distances; square distance is faster
 ;-------------------------------------------------
 dd = v_sqmag(object_vec - vec)

 ;-------------------------------------------------
 ; select points with smallest distance
 ;-------------------------------------------------
 if(nv EQ 1) then sub = where(dd EQ min(dd)) $
 else dd_min = nmin(dd, 1, sub=sub)

 min_vec = vec[colgen(nv,3,n, sub)]
 min_pts = pts[colgen(nv,2,n, sub)]
 min_pts = transpose(min_pts)
 min_flags = flags[colgen(nv,1,n, sub)]

 pnt_assign, ptd[0], v=min_vec, p=min_pts, flags=min_flags

 return, ptd[0]
end
;=============================================================================
