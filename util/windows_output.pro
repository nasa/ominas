;=============================================================================
; windows_output
;
;  Returns true if windows-related routines like wset work.
;
;=============================================================================
function windows_output

 if(!d.name EQ 'X') then return, 1
 if(!d.name EQ 'WIN') then return, 1
 if(!d.name EQ 'MAC') then return, 1

 return, 0
end
;=============================================================================
