;===========================================================================
; nv_debug
;
;===========================================================================
pro nv_debug, $
	ptr_tracking=ptr_tracking, $
	ptr_list=ptr_list, $
	ptr_calls=ptr_calls, ptr_call_level=ptr_call_level
@nv_block.common

 if(defined(ptr_tracking)) then nv_state.ptr_tracking = ptr_tracking

 if(keyword_set(*nv_state.ptr_list_p)) then $
  begin
   w = where(ptr_valid((*nv_state.ptr_list_p).ptr))
   if(w[0] EQ -1) then *nv_state.ptr_list_p = 0 $
   else *nv_state.ptr_list_p = (*nv_state.ptr_list_p)[w]
  end

 if(defined(ptr_list)) then ptr_list = *nv_state.ptr_list_p

 if(arg_present(ptr_calls)) then $
  begin
   if(NOT keyword_set(ptr_call_level)) then ptr_call_level = 1
   ptr_list = *nv_state.ptr_list_p

   ptr_calls = {ptr_calls_struct, name:'', n:0l}

   nptr = n_elements(ptr_list)
   for i=0, nptr-1 do $
    begin
     stack = *ptr_list[i].stack_p
     ii = ptr_call_level < n_elements(stack)-1
     w = where(ptr_calls.name EQ stack[ii])
     if(w[0] NE -1) then ptr_calls[w].n = ptr_calls[w].n + 1 $
     else ptr_calls = [ptr_calls, {name:stack[ii], n:1l}]
    end
   ss = rotate(sort(ptr_calls.n), 2)
   ptr_calls = ptr_calls[ss]
  end

end
;===========================================================================
