;===========================================================================
;+
; NAME:
;	arr_set_surface_pts
;
;
; PURPOSE:
;	Replaces the surface_pts vector in each given array descriptor.
;
;
; CATEGORY:
;	NV/LIB/arr
;
;
; CALLING SEQUENCE:
;	arr_set_surface_pts, ard, surface_pts
;
;
; ARGUMENTS:
;  INPUT: 
;	ard:		Array (nt) of ARRAY descriptors.
;
;	surface_pts:	Array (nv,3,nt) of surface_pts vectors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro arr_set_surface_pts, ard, surface_pts, noevent=noevent
@core.include

 _ard = cor_dereference(ard)

 if(NOT ptr_valid(_ard.surface_pts_p)) then _ard.surface_pts_p = ptr_new(surface_pts) $
 else *_ard.surface_pts_p = surface_pts

 cor_rereference, ard, _ard
 nv_notify, ard, type = 0, noevent=noevent
end
;===========================================================================



