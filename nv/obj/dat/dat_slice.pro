;=============================================================================
;+
; NAME:
;	dat_slice
;
;
; PURPOSE:
;	Returns the slice coordinates for the given data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dim = dat_slice(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	dd0: 	Surce data descriptor.
;
;
; RETURN: 
;	Array giving the slice coordinates for the data descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2017
;	
;-
;=============================================================================
function dat_slice, dd, dd0=dd0, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 dd0 = !null
 if(NOT ptr_valid(_dd.slice_struct.slice_p)) then return, 0

 handle_value, _dd.slice_struct.dd0_h, dd0
 return, *_dd.slice_struct.slice_p
end
;=============================================================================
