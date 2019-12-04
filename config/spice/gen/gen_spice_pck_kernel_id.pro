;=============================================================================
; gen_spice_pck_kernel_id
; Return date in TEXT_KERNEL_ID of pck
;
;=============================================================================
function gen_spice_pck_kernel_id, file

 creation = ''
 line = ' '
 in_data = 0
 openr, unit, file, /get_lun
 while not EOF(unit) do begin $
   readf, unit, line
   line  = strtrim(line,2)
   if (line EQ '\begindata') then in_data = 1
   if (line EQ '\begintext') then in_data = 0
   if (NOT in_data) then continue
   if (strmatch(line, 'TEXT_KERNEL_ID *=*')) then begin
      pos = strpos(line, "'")
      last_pos = strpos(line, "'", /reverse_search)
      line = strmid(line, pos+1, last_pos-pos-1)
      ; parse text_kernel_id for date
      ; Remove trailing PCK
      test_pck = strmid(line, strlen(line)-4)
      if (test_pck EQ' PCK') then line = strmid(line, 0, strlen(line)-4) $
      else continue
      ; Remove kernel name
      pos = strpos(line, ' ')
      creation = strmid(line, pos+1)
      ; remove version (must start with V)
      vchar = strmid(creation, 0, 1)
      if (vchar EQ 'V' OR vchar EQ 'v') then begin
        pos = strpos(creation, ' ')
        creation = strmid(creation, pos+1)
      endif
      break
   endif
 endwhile
 close, unit
 free_lun, unit
 return, creation 

end
