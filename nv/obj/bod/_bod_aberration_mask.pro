; docformat = 'rst rst'
;+
;
; :Private:
;
;-


;=============================================================================
;++
; NAME:
;	_bod_aberration_mask
;
;
; PURPOSE:
;	Returns a bitmask for an aberration.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	mask = _bod_aberration_mask(_bx, name)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	name:	 Name of aberration.
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
;	Aberration mask associated with the given name for each given body 
;	structure.
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
function _bod_aberration_mask, name
@core.include

 case strupcase(name) of
  'LT'		: return, 1b
  'STELLAB'	: return, 2b
  else	 	: return, -1
 endcase

end
;===========================================================================



