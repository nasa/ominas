;=============================================================================
;+
; NAME:
;	dat_test_dd
;
;
; PURPOSE:
;	Determines whether the argument is a valid data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	test = dat_test_dd(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor to test.
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
; RETURN: 
;	True if the argument is present, is a valid pointer, and
;	points to a data descriptor.
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
;=============================================================================
function dat_test_dd, dd, noevent=noevent
@core.include
 if(NOT keyword_set(dd)) then return, 0
 if(NOT obj_valid(dd)) then return, 0

 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 return, tag_exists(_dd, 'DATA_DAP')
end
;====================================================================================
