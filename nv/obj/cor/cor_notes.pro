;=============================================================================
;+
; NAME:
;	cor_notes
;
;
; PURPOSE:
;	Returns the notes for a core descriptor.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	notes = cor_notes(crx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	crx:	 Any subclass of CORE.
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
;	Notes associated with the given core descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2018
;	
;-
;=============================================================================
function cor_notes, crd, noevent=noevent
@core.include
 nv_notify, crd, type = 1, noevent=noevent
 _crd = cor_dereference(crd)
 return, *_crd.notes_p
end
;===========================================================================



