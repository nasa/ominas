;=============================================================================
;+
; NAME:
;	cor_cull
;
;
; PURPOSE:
;	Removes null objects from an array.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	new_ptd = cor_cull(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:	Array of objects.
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
;	Array objects, or !null if all were empty.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 3/2017
;	
;-
;=============================================================================
function cor_cull, crd

 w = where(obj_valid(crd))
 if(w[0] EQ -1) then return, !null
 return, crd[w]
end
;===========================================================================
