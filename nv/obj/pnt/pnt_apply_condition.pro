;=============================================================================
;+
; NAME:
;	pnt_apply_condition
;
;
; PURPOSE:
;	Selects point in POINT structures based on a given condition structure.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	indices = _pnt_apply_condition(_ps, condition)
;
;
; ARGUMENTS:
;  INPUT: 
;	ptd:		Points object.
;
;	condition:	Condition structure to compare against the flags
;			contained in _ps.  
;
;			The condition structure is organized as follows:
;			  field	   values
;			  -----------------------------------------------------
;			  mask:	   PTD_MASK_INVISIBLE, etc. (see pnt_include.pro)
;			  state:   PTD_TRUE, PTD_FALSE
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
;	Condition structure corresponding to the given keyword.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO: pnt_points, pnt_vectors, pnt_data
;
;
; MODIFICATION HISTORY:
;  	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_apply_condition, ptd, condition
@pnt_include.pro
 
 _ptd = cor_dereference(ptd)

 flags = *_ptd.flags_p
 if(NOT keyword_set(condition)) then return, lindgen(n_elements(flags))

 compare = flags AND condition.mask
 return, where(compare EQ condition.state)
end
;===============================================================================
