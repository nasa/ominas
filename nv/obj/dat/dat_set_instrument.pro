;=============================================================================
;+
; NAME:
;	dat_set_instrument
;
;
; PURPOSE:
;	Changes the file name associated with a data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	dat_set_instrument, dd, instrument
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	instrument:	New instrument name.
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
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_set_instrument, dd, instrument, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 _dd.instrument = instrument

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
