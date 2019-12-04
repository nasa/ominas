;=============================================================================
;+
; NAME:
;	pnt_valid
;
;
; PURPOSE:
;	Assesses the validity of POINT objects.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	valid = pnt_valid(ptd)
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
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of flags, one for each input PS.  1 indicates that the PS 
;	contains points.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pnt_test
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_valid
;	
;-
;=============================================================================
function pnt_valid, ptd0, noevent=noevent
 if(NOT keyword_set(ptd0)) then return, 0

 n = n_elements(ptd0)

 _w = where(obj_valid(ptd0))
 if(_w[0] EQ -1) then return, bytarr(n)

 ptd = ptd0[_w]

 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)

 nptd = n_elements(_ptd)
 valid = bytarr(nptd)

 w = where(ptr_valid(_ptd.points_p))
 if(w[0] NE -1) then valid[w] = 1

w = where(ptr_valid(_ptd.vectors_p))
if(w[0] NE -1) then valid[w] = 1

 _valid = bytarr(n)
 _valid[_w] = valid

 return, _valid
end
;===========================================================================

