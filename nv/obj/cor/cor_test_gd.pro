;=============================================================================
;+
; NAME:
;	cor_test_gd
;
;
; PURPOSE:
;	Tests whether a generic descriptor field exists and contains a 
;	descriptor.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	data = cor_test_gd(gd, tag)
;
;
; ARGUMENTS:
;  INPUT:
;	gd:	 Generic descriptor.  An object may also be provided, in which
;		 case its generic descripor is tested.
;
;	tag:	 Name of field to test.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	True if gd contains the tag and it is a valid descriptor, false otherwise.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2017
;	
;-
;=============================================================================
function cor_test_gd, _gd, tag

 if(NOT keyword_set(_gd)) then return, 0
 gd = _gd

 ;---------------------------
 ; extract gdif necessary
 ;---------------------------
 if(size(gd, /type) EQ 11) then gd = cor_gd(gd)

 if(NOT tag_exists(gd, tag, index=ii)) then return, 0
 if(NOT cor_test(gd.(ii))) then return, 0
 return, 1
end
;=============================================================================
