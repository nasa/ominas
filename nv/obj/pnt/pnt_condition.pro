;=============================================================================
;+
; NAME:
;	pnt_condition
;
;
; PURPOSE:
;	Returns predefined condition structures for various common situations.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	condition = pnt_condition(</visible | /invisible | /select|...>)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	condition:	If a condition structure is given as in input, it
;			is returned.
;
;   *** The following keywords are defined in pnt_condition_keywords.include ***
;	
;	visible:	Returns a condition structure corresponding to 
;			points whose visible flag is not set.
;
;	invisible:	Returns a condition structure corresponding to 
;			points whose visible flag is set.
;
;	selected:	Returns a condition structure corresponding to 
;			points whose select flag is set.
;
;	unselected:	Returns a condition structure corresponding to 
;			points whose select flag is not set.
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



;=============================================================================
; pnt_condition_set
;
;=============================================================================
pro pnt_condition_set, state, mask, flag
 state = state OR flag
 mask = mask OR flag
end
;=============================================================================



;=============================================================================
; pnt_condition_unset
;
;=============================================================================
pro pnt_condition_unset, state, mask, flag
 state = state AND NOT flag
 mask = mask OR flag
end
;=============================================================================



;=============================================================================
; pnt_condition
;
;=============================================================================
function pnt_condition, condition=condition, $
@pnt_condition_keywords.include
end_keywords
@pnt_include.pro

 if(keyword_set(condition)) then return, condition

 mask = (state = 0b)
 if(keyword_set(visible)) then pnt_condition_unset, state, mask, PTD_MASK_INVISIBLE 
 if(keyword_set(invisible)) then pnt_condition_set, state, mask, PTD_MASK_INVISIBLE 
 if(keyword_set(selected)) then pnt_condition_set, state, mask, PTD_MASK_SELECT 
 if(keyword_set(unselected)) then pnt_condition_unset, state, mask, PTD_MASK_SELECT 
 
 if(mask EQ 0) then return, 0
 return, {mask:mask, state:state}
end
;===============================================================================
