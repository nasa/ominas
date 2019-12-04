; docformat = 'rst rst'
;+
;
; :Private:
;
;-

;=============================================================================
;++
; NAME:
;	_cor_gd
;
;
; PURPOSE:
;	Retrieves the generic descriptor from a CORE structure.  The generic
;	descriptor is stored in a protected structure that prevents its contents
;	from being freed by nv_free, while still allowing its references to 
;	be copied by nv_clone.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	gd = _cor_gd(_crd)
;
;
; ARGUMENTS:
;  INPUT:
;	_crd:		CORE structure.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE.
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
; SEE ALSO:
;	_cor_set_gd
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		3/2017
;	
;-
;=============================================================================
function _cor_gd, _xd
; return, *_xd.__PROTECT__gdp
 if(NOT keyword_set(*_xd.gdp)) then return, 0
 return, (*_xd.gdp).gd
end
;=============================================================================
