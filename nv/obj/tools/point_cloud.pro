;=============================================================================
;+
; NAME:
;       point_cloud
;
;
; PURPOSE:
;	Returns the sizes of the given bodies.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       point_cloud(bx, nv)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:     BODY descriptor; nt.
;
;	nv:	Number of points to generate.  
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;   INPUT: NONE
;
;   OUTPUT: NONE
;
;
; RETURN: 
;	nt-element array giving random points within the body.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function point_cloud, bx, nv

 nt = n_elements(bx)
 cloud_pts = dblarr(nv,3,nt)

 gbx = cor_select(bx, 'GLOBE', ind=ii, /class)
 if(keyword_set(gbx)) then $
  for i=0, n_elements(ii)-1 do cloud_pts[*,*,ii[i]] = glb_point_cloud(gbx, nv)

 dkx = cor_select(bx, 'DISK', ind=ii, /class)
 if(keyword_set(dkx)) then $
  for i=0, n_elements(ii)-1 do cloud_pts[*,*,ii[i]] = dsk_point_cloud(dkx, nv)

 return, cloud_pts
end
;=============================================================================
