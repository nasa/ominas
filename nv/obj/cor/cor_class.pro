;=============================================================================
;+
; NAME:
;	cor_class
;
;
; PURPOSE:
;	Returns the class name for the given object class.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	class = cor_class(xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 Descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	superclass:	Returns the object's direct superclass instead of 
;			its class.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	String giving the class name for the given class, without the OMINAS_
;	prefix.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		4/2016
;	
;-
;=============================================================================
function cor_class, xd, superclass=superclass
 if(NOT keyword_set(xd)) then return, ''
 dim = size([xd], /dim)
 n = n_elements(xd)
 class = strarr(dim)
 for i=0, n-1 do class[i] = strmid(obj_class(xd[i], superclass=superclass), 7, 128)
 if(n EQ 1) then class = class[0]
 return, class
end
;===========================================================================


