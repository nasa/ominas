;===========================================================================
;+
; NAME:
;	dsk_surface_normal
;
;
; PURPOSE:
;	Computes the surface normal for a DISK object at the given 
;	body-frame positions.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	n = dsk_surface_normal(dkd, r)
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	Array (nt) of any subclass of DISK descriptors.
;
;	v:	Array (nv,3) of observer positions in the BODY frame.
;
;	r:	Array (nv,3) of surface positions in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	north:     If set, the retruned normals will be pointed north.  
;	           Otherwise, they point toward the observer's hemisphere.
;
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (nv, 3, nt) of surface unit normals in the BODY frame.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
function dsk_surface_normal, dkd, v, r, noevent=noevent, north=north
@core.include
 
 nv_notify, dkd, type = 1, noevent=noevent
 _dkd = cor_dereference(dkd)

 nv = (size(r))[1]
 nt = n_elements(_dkd)

 normal = dblarr(nv,3,nt)
 normal[*,2,*] = 1

 s = 1
 if(NOT keyword_set(north)) then  s = sign(transpose((sign(v[*,2,*]))[linegen3z(nv,nt,3)], [0,2,1]))

 return, s*normal
end
;=============================================================================
