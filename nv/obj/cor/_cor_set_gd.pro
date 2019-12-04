; docformat = 'rst rst'
;+
;
; :Private:
;
;-


;=============================================================================
;++
; NAME:
;	_cor_set_gd
;
;
; PURPOSE:
;	Sets the generic descriptor in a CORE structure.  The generic
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
;	_cor_set_gd, _crd, gd
;
;
; ARGUMENTS:
;  INPUT:
;	_crd:		CORE structure.
;
;	gd:		New gd.  
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
;	_cor_gd
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		3/2017
;	
;-
;=============================================================================
pro _cor_set_gd, _xd, gd
; *_xd.__PROTECT__gdp = gd
 *_xd.gdp = {__PROTECT__:0, gd:gd}
end
;=============================================================================
