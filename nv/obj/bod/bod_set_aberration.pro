;=============================================================================
;+
; NAME:
;	bod_set_aberration
;
;
; PURPOSE:
;	Sets aberration flags for each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bod_set_aberration, bx, name
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 Any subclass of BODY.
;
;	name:	 Name of aberration to set.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	unset:	If set, the named flag is unset.
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
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================
pro bod_set_aberration, bd, name, unset=unset, noevent=noevent
@core.include
 _bd = cor_dereference(bd)

 mask = _bod_aberration_mask(name)
 if(mask LT 0) then return

 if(keyword_set(unset)) then _bd.aberration = _bd.aberration AND NOT mask $
 else _bd.aberration = _bd.aberration OR mask

 cor_rereference, bd, _bd
 nv_notify, bd, type = 0, noevent=noevent
end
;===========================================================================



