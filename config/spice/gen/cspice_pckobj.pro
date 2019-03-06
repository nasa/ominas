;=============================================================================
; cspice_pckobj
; Return array of objects covered by pck
;
;=============================================================================
pro cspice_pckobj, file, obj

 line = ' '
 in_data = 0
 openr, unit, file, /get_lun
 while not EOF(unit) do begin $
   readf, unit, line
   line  = strtrim(line,2)
   if (line EQ '\begindata') then in_data = 1
   if (line EQ '\begintext') then in_data = 0
   if (NOT in_data) then continue
   if (strmatch(line,'BODY*_RADII*')) then begin
      pos = strpos(line, '_')
      cobj = strmid(line, 4, pos-4)
      on_ioerror, false
      iobj = long(cobj)
      cspice_appndi, iobj, obj
      continue 
      false: continue
   endif
 endwhile
 close, unit
 free_lun, unit

end
