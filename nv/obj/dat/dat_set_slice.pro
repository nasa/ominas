;=============================================================================
;+
; NAME:
;	dat_set_slice
;
;
; PURPOSE:
;	Sets slice coordinates in a data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	dat_set_slice, dd, dd0, slice
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptorin which to set the slice coordinates.
;
;	dd0:	Data descriptorin describing the source data array.
;
;	slice:	Array giving the slice coordinates.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	new:	If set, a new slice pointer is allocated instead of overwriting
;		the exiting data.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		6/2017
;	
;-
;=============================================================================
pro dat_set_slice, dd, dd0, slice, new=new
@core.include
 _dd = cor_dereference(dd)

 n = n_elements(slice)
 dim  = dat_dim(_dd)
 ndim = n_elements(dim)

 if(keyword_set(new) OR (NOT ptr_valid(_dd.slice_struct.slice_p))) then $
  begin
   _dd.slice_struct.slice_p = nv_ptr_new(slice)
   _dd.slice_struct.dd0_h = handle_create()
   handle_value, _dd.slice_struct.dd0_h, dd0, /set
  end $
 else $
  begin
   *_dd.slice_struct.slice_p = slice
   handle_value, _dd.slice_struct.dd0_h, dd0, /set
  end

 dat_set_dim, _dd, dim[0:ndim-1-n]

 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================



