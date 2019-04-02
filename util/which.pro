;=============================================================================
; which
;
;=============================================================================
pro which, name, output=output

 output = ''

 ;-------------------------------------------------------------
 ; find routine
 ;-------------------------------------------------------------
; if(NOT routine_exists(name, /compile)) then $
 if(NOT routine_exists(name)) then $
  begin
   print, 'Not found.'
   return
  end


 ;-------------------------------------------------------------
 ; if found, get the path
 ;-------------------------------------------------------------
 fn = 0
 s = routine_info()
 w = where(s EQ strupcase(name))
 if(w[0] EQ -1) then fn = 1


 x = routine_info(name, /source, fun=fn)
 if(arg_present(output)) then output = x.path $
 else print, ' ' + x.path

end
;=============================================================================
