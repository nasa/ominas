;=============================================================================
;+
; NAME:
;	bod_aberration
;
;
; PURPOSE:
;	Returns the aberration flags for each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	ab = bod_aberration(bx, name)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	bx:	 Any subclass of BODY.
;
;	name:	 Name of aberration to return.  If not given, the full
;		 aberration value is returned.
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
;	Aberration flag associated with the given name for each given body 
;	descriptor.
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
function bod_aberration, bd, name, noevent=noevent
@core.include
 nv_notify, bd, type = 1, noevent=noevent
 _bd = cor_dereference(bd)

 if(NOT keyword_set(name)) then return, _bd.aberration

 mask = _bod_aberration_mask(name)
 if(mask LT 0) then return, -1

 return, (_bd.aberration AND mask) NE 0
end
;===========================================================================



