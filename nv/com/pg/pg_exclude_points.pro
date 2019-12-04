;=============================================================================
;++
; NAME:
;	pg_exclude_points
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
function pg_exclude_points, ptd, xptd, radius=radius
@pnt_include.pro

 if(NOT keyword_set(radius)) then radius = 10

 n = n_elements(ptd)

 xpts = pnt_points(/cat, /vis, xptd)

 for i=0, n-1 do $
  begin
   pnt_query, ptd[i], p=p, f=f
   w = near_points(p, xpts, radius)
   if(w[0] NE -1) then $
    begin
     f[w] = f[w] OR PTD_MASK_INVISIBLE
     pnt_assign, ptd[i], p=p, f=f
    end
  end

 return, ptd
end
;=============================================================================
