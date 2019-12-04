;=============================================================================
;+
; NAME:
;	map_type
;
;
; PURPOSE:
;	Returns the type name for each given map descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	type = map_type(md)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	md:	 Array (nt) of map descriptors.
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
; RETURN:
;	Array (nt) of type names associated with each given map descriptor.
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
function map_type, md, noevent=noevent
@core.include
 nv_notify, md, type = 1, noevent=noevent
 _md = cor_dereference(md)
 return, _md.type
end
;===========================================================================
