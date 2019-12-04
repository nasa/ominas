;=============================================================================
;+
; NAME:
;	pnt_set_vectors
;
;
; PURPOSE:
;	Replaces the vectors in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_vectors, ptd, vectors
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	vectors:	New vectors array.
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
;	pnt_vectors
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_vectors, ptd, vectors, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 dim = size(vectors, /dim)
 ndim = n_elements(dim)
 nv = (nt = 1)
 nv = dim[0]
 if(ndim GT 2) then nt = dim[2]


 if(NOT ptr_valid(_ptd.vectors_p)) then $
  begin
   _ptd.nv = nv & _ptd.nt = nt
   _ptd.vectors_p = nv_ptr_new(vectors)
  end $
 else $
  begin
   if((nv NE _ptd.nv) OR (nt NE _ptd.nt)) then _pnt_resize, _ptd, nv=nv, nt=nt
   *_ptd.vectors_p = vectors
  end


 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
