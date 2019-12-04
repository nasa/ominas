;=============================================================================
;+
; NAME:
;	pnt_set_data
;
;
; PURPOSE:
;	Replaces the point-by-point data in a POINT object.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_set_data, ptd, data
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	data:		New point-by-point data array.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
;
;	tags:	If given, data arrays are replaced only for these tags, and in 
;		this order.
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
;	pnt_data
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		11/2015
;	
;-
;=============================================================================
pro pnt_set_data, ptd, new_data, tags=select_tags, noevent=noevent
@core.include
 _ptd = cor_dereference(ptd)

 dim = size(new_data, /dim)
 ndim = n_elements(dim)
 nv = (nt = 1)
 ndat = dim[0]
 if(ndim GT 1) then nv = dim[1]
 if(ndim GT 2) then nt = dim[2]

 if((nv NE _ptd.nv) OR (nt NE _ptd.nt)) then _pnt_resize, _ptd, nv=nv, nt=nt


 if(NOT keyword_set(_ptd.data_p)) then $
  begin
   _ptd.data_p = nv_ptr_new(new_data)
   if(keyword_set(select_tags)) then _ptd.tags_p = nv_ptr_new(select_tags)
  end $
 else $
  begin
   if(NOT keyword_set(select_tags)) then *_ptd.data_p = new_data $
   else $
    begin
     data = *_ptd.data_p
     tags = ''
     if(ptr_valid(_ptd.tags_p)) then tags = *_ptd.tags_p

     w = nwhere(tags, select_tags)
     if(w[0] EQ -1) then return

     data[w,*,*] = new_data

     *_ptd.data_p = data
    end
  end


 cor_rereference, ptd, _ptd
 nv_notify, ptd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
