; docformat = 'rst rst'
;+
;
; :Private:
;
;-


;=============================================================================
;++
; NAME:
;	_pnt_resize
;
;
; PURPOSE:
;	Resizes a POINT structure.  Arrays are padded with zeroes or truncated
;	as needed.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_resize, _ptd, nv=nv, nt=nt
;
;
; ARGUMENTS:
;  INPUT:
;	_ptd:		POINT struct.  Note this is an actual POINT structure
;			rather than an object, as this routine is only
;			meant to be called internally.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nv.nt:		New nv, nt.
;
;	noevent:	If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		12/2015
;	
;-
;=============================================================================
pro _pnt_resize, _ptd, nv=nv, nt=nt

 if(NOT keyword_set(nt)) then nt = 1

 if(ptr_valid(_ptd.points_p)) then $
        *_ptd.points_p = resize_array(*_ptd.points_p, [2,nv,nt])
 if(ptr_valid(_ptd.vectors_p)) then $
        *_ptd.vectors_p = resize_array(*_ptd.vectors_p, [nv,3,nt])
 if(ptr_valid(_ptd.flags_p)) then $
        *_ptd.flags_p = resize_array(*_ptd.flags_p, [nv,nt])
 if(ptr_valid(_ptd.data_p)) then $
  begin
   ndat = (size(*_ptd.data_p, /dim))[0]
   *_ptd.data_p = resize_array(*_ptd.data_p, [ndat,nv,nt])
  end

 _ptd.nv = nv
 _ptd.nt = nt

end
;===========================================================================
