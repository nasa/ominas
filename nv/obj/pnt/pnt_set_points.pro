;=============================================================================
;+
; NAME:
;	pnt_set_points
;
;
; PURPOSE:
;	Replaces the points in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_points, ptd, points
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	points:		New points array.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
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
;	pnt_points
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_points, ptd, points, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 dim = size(points, /dim)
 ndim = n_elements(dim)
 nv = (nt = 1)
 if(ndim GT 1) then nv = dim[1]
 if(ndim GT 2) then nt = dim[2]

 if(NOT ptr_valid(_ptd.points_p)) then $
  begin
   _ptd.nv = nv & _ptd.nt = nt
   _ptd.points_p = nv_ptr_new(points)
  end $
 else $
  begin
   if((nv NE _ptd.nv) OR (nt NE _ptd.nt)) then _pnt_resize, _ptd, nv=nv, nt=nt
   *_ptd.points_p = points
  end


 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
