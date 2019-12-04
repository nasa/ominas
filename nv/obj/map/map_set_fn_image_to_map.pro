;=============================================================================
;+
; NAME:
;	map_set_fn_image_to_map
;
;
; PURPOSE:
;	Replaces the name of the image->map function for each given map 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_set_fn_image_to_map, md, fn
;
;
; ARGUMENTS:
;  INPUT: NONE
;	md:	Array (nt) of map descriptors.
;
;	fn:	Array (nt) of function names.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
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
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro map_set_fn_image_to_map, md, fn, noevent=noevent
@core.include
 _md = cor_dereference(md)

 _md.fn_image_to_map=fn

 cor_rereference, md, _md
 nv_notify, md, type = 0, noevent=noevent
end
;===========================================================================
