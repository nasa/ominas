;===========================================================================
; spice_bodvar
;
;===========================================================================
pro spice_bodvar, id, name, val

  catch, failed
  if(failed EQ 0) then cspice_bodvar, id, name, _val
  catch, /cancel
  if(failed EQ 0) then val = _val

end
;===========================================================================
