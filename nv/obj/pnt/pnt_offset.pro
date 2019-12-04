;=============================================================================
;+
; NAME:
;	pnt_offset
;
;
; PURPOSE:
;	Offsets points in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_offset, ptd, offset
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	offset:		Offset to apply.
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
; RETURN: NONE.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_offset
;	
;-
;=============================================================================
pro pnt_offset, ptd, offset, noevent=noevent

 if(NOT keyword__set(ptd)) then return
 _ptd = cor_dereference(ptd)

 for i=0, n_elements(_ptd)-1 do $
  begin
   p = *_ptd[i].points_p
   p = p + offset#make_array(n_elements(p), val=1d)
   *_ptd[i].points_p = p
  end

 nv_notify, ptd, type = 0, noevent=noevent
end
;=============================================================================
