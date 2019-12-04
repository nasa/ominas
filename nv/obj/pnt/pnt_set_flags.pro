;=============================================================================
;+
; NAME:
;	pnt_set_flags
;
;
; PURPOSE:
;	Replaces the flags in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_flags, ptd, flags
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	flags:		New flags array.
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
;	pnt_flags
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_flags, ptd, flags, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 dim = [1]
 if(n_elements(flags) GT 1) then dim = size(flags, /dim)
 ndim = n_elements(dim)
 nv = dim[0]
 nt = 1
 if(ndim GT 1) then nt = dim[1]


 if(NOT ptr_valid(_ptd.flags_p)) then $
  begin
   _ptd.nv = nv & _ptd.nt = nt
   _ptd.flags_p = nv_ptr_new(flags)
  end $
 else $
  begin
   if((nv NE _ptd.nv) OR (nt NE _ptd.nt)) then _pnt_resize, _ptd, nv=nv, nt=nt
   *_ptd.flags_p = flags
  end

 
 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
