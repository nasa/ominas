;=============================================================================
;+
; NAME:
;	cor_set_notes
;
;
; PURPOSE:
;	Replaces the notes for a core descriptor.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	cor_set_notes, crx, notes
;
;
; ARGUMENTS:
;  INPUT: NONE
;	crx:	 Any subclass of CORE.
;
;	notes:	 String array.
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
; 	Written by:	Spitale, 1/2018
;	
;-
;=============================================================================
pro cor_set_notes, crd, notes, noevent=noevent
@core.include
 _crd = cor_dereference(crd)

 *_crd.notes_p = notes

 cor_rereference, crd, _crd

 nv_notify, crd, type = 0, noevent=noevent
end
;===========================================================================
