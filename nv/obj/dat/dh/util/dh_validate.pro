;=============================================================================
;+-+
; NAME:
;	dh_validate
;
;
; PURPOSE:
;	Validates a detached header.
;
;
; CATEGORY:
;	DAT/DH
;
;
; CALLING SEQUENCE:
;	result = dh_validate(dh)
;
;
; ARGUMENTS:
;  INPUT:
;	dh:		String array containing the detached header.
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
;	1 if valid, 0 otherwise.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dh_write
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================
function dh_validate, dh


 if(NOT keyword_set(dh)) then return, 0

 w = where(strpos(dh, 'history =') EQ 0)
 if(w[0] EQ -1) then return, 0

 w = where(strpos(dh, '<updates>') EQ 0)
 if(w[0] EQ -1) then return, 0


 return, 1
end
;=============================================================================
