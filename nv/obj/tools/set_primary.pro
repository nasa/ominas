;=============================================================================
;+
; NAME:
;       set_primary
;
;
; PURPOSE:
;	Sets the primary descriptor in the generic descriptor of the given
;	object.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       set_primary, xd, bx0
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	Any object descritor.
;
;	bx0:	Primary descriptor.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale		7/2017
;
;-
;=============================================================================
pro set_primary, xd, bx0
 cor_set_gd, xd, bx0=bx0
end
;=============================================================================
