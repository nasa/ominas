;=============================================================================
;+
; NAME:
;	pnt_cull
;
;
; PURPOSE:
;	Cleans out an array of POINT objects by removing POINT objects that are
;	empty, or whose points all fail the specified conditions.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	new_ptd = pnt_cull(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:	Array of POINT objects.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<condition>:	All of the predefined conditions (e.g. /visible) are 
;			accepted; see pnt_condition_keywords.include.  In this 
;			case, pnt_cull removes objects for which the specified
;			conditions return no points.  
;
;	nofree:		If set, invalid POINT object are not freed.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array POINT objects, or 0 if all were empty.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_cull
;	
;-
;=============================================================================
function pnt_cull, _ptd, nofree=nofree, condition=condition, $
@pnt_condition_keywords.include
end_keywords
@pnt_include.pro

 if(NOT keyword__set(_ptd)) then return, 0
 ptd = _ptd

 ;------------------------
 ; reform to 1D
 ;------------------------
 n = n_elements(ptd)
 ptd = reform(ptd, n, /over)


 ;------------------------------------
 ; apply conditions
 ;------------------------------------
 for i=0, n-1 do if(obj_valid(ptd[i])) then $
  begin
   w = pnt_apply_condition(ptd[i], pnt_condition(condition=condition, $
@pnt_condition_keywords.include
end_keywords))
   if(w[0] EQ -1) then ptd[i] = obj_new()
  end


 ;-----------------------------
 ; mark empty POINT objects
 ;-----------------------------
 ff = bytarr(n)
 for i=0, n-1 do $
  begin
   if(NOT pnt_valid(ptd[i])) then ff[i] = 1 $
   else if(pnt_nv(ptd[i]) EQ 0) then ff[i] = 1
  end

 ;------------------------------------
 ; discard the empty POINT objects
 ;------------------------------------
 w = where(ff EQ 0)

 if(NOT keyword_set(nofree)) then $
  begin 
   ww = complement(ptd, w)
   if(ww[0] NE -1) then nv_free, ptd[ww]
  end 

 if(w[0] NE -1) then return, ptd[w] else return, 0
end
;===========================================================================
