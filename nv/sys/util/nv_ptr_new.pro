;=============================================================================
;+
; NAME:
;	nv_ptr_new
;
;
; PURPOSE:
;	Wrapper for te IDL function ptr_new.  In conjunction with nv_ptr_free, 
;	pointer allocations are tracked for debugging purposes.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	p = nv_ptr_new(x)
;
;
; ARGUMENTS:
;  INPUT:
;	x:	Data to point to.
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
;	Newly allocated pointer
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
function nv_ptr_new, x, allocate_heap=allocate_heap, no_copy=no_copy
@nv_block.common

 ;----------------------------------------------------
 ; allocate pointer
 ;----------------------------------------------------
 if(NOT defined(x)) then p = ptr_new(allocate_heap=allocate_heap, no_cop=no_copy) $
 else p = ptr_new(x, allocate_heap=allocate_heap, no_cop=no_copy)


 ;----------------------------------------------------
 ; record pointer info if tracking enabled
 ;----------------------------------------------------
 if(nv_state.ptr_tracking) then $
  begin
   help, calls=stack
   stack = str_nnsplit(stack, ' ')
   item = {ptr_list_struct, ptr:p, stack_p:ptr_new(stack)}
;print, item.ptr, str_pad((*item.stack_p)[1:*], 15)

   *nv_state.ptr_list_p = append_array(*nv_state.ptr_list_p, item)
  end


 return, p
end
;===========================================================================
