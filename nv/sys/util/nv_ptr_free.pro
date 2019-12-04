;=============================================================================
;+
; NAME:
;	nv_ptr_free
;
;
; PURPOSE:
;	Wrapper to the IDL routine ptr_free.  In conjunction with nv_ptr_new, 
;	pointer allocations are tracked for debugging purposes.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_ptr_free, p
;
;
; ARGUMENTS:
;  INPUT:
;	p:	Pointer to free.
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
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
pro nv_ptr_free, p
@nv_block.common

 ;----------------------------------------------------
 ; remove pointer info if tracking enabled
 ;----------------------------------------------------
 if(nv_state.ptr_tracking) then $
  begin
   if(keyword_set(*nv_state.ptr_list_p)) then $
    for i=0, n_elements(p)-1 do $
     begin
      w = where((*nv_state.ptr_list_p).ptr EQ p[i])
      if(w[0] NE -1) then $
        *nv_state.ptr_list_p = rm_list_item(*nv_state.ptr_list_p, w)
     end
  end


 ;----------------------------------------------------
 ; free pointer
 ;----------------------------------------------------
;print, p
 ptr_free, p

end
;===========================================================================
