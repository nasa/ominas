;=============================================================================
; dhh_insert
;
;=============================================================================
pro dhh_insert, dh, dh_section, dh_history=dh_history

 new_dh = dh_history

 dhh_separate, dh, _dh_history, dh_sections=dh_sections
 if(NOT keyword_set(dh_sections)) then return

 n = n_elements(dh_sections)

 new = 1
 for i=0, n-1 do $
  if((*(dh_sections[i]))[0] EQ dh_section[0]) then $
   begin
     new_dh = [new_dh, dh_section]
     new = 0
   end $
  else new_dh = [new_dh, *(dh_sections[i])]

 if(new) then new_dh = [new_dh, dh_section]

 dh = new_dh

end
;=============================================================================



