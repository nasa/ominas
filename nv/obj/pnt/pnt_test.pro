;=============================================================================
;+
; NAME:
;	pnt_test
;
;
; PURPOSE:
;	Assesses the validity of a single POINT object.  This function
;	differs from pnt_valid in that it simply returns true or false, rather
;	than a list of validity flags. 
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	test = pnt_test(ptd)
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
;	generic:	If set, a generic input is test to determine whether
;			it is a POINT object.  Its validity is not tested.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	1 if the given POINT object is valid and contains points, 0 otherwise.
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
;  Spitale, 12/2015; 	Adapted from pgs_test
;	
;-
;=============================================================================
function pnt_test, ptd, generic=generic, noevent=noevent
 if(NOT keyword_set(ptd)) then return, 0
 if(size(ptd, /type) NE 11) then return, 0

 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)

 if(keyword_set(generic)) then return, tag_exists(_ptd[0], 'POINTS_P')

;;; if(n_elements(_ptd) GT 1) then return, 1 

 if(NOT ptr_valid(_ptd[0].points_p)) then return, 0

 return, 1
end
;===========================================================================
