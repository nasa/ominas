;=============================================================================
; dat_caller
;
;=============================================================================
function dat_caller, _fns
@core.include

 fns = strupcase(_fns)
 callers = strupcase(caller(/all))
 n = n_elements(callers)

 for i=0, n-1 do $
  begin &$
   w = where(callers[i] EQ fns)
   if(w[0] NE -1) then break
  end

 return, w[0]
end
;=============================================================================
