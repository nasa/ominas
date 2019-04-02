;===========================================================================
; detect_vicar.pro
;
;===========================================================================
function detect_vicar, filename=filename, header=header

 status = 0

 ;===============================================
 ; if no header, read the beginning of the file
 ;===============================================
 if(keyword_set(header)) then s = header $
 else $
  begin
   openr, unit, filename, /get_lun, error=error
   if(error NE 0) then return, 0
   if((fstat(unit)).size LT 20) then return, 0
   record = assoc(unit, bytarr(20,/nozero))
   s = string(record[0])
   close, unit
   free_lun, unit
  end

 ;===================================
 ; check for vicar label 
 ;===================================
 if ~isa(s,'string') then return,0
 if(strpos(s[0], 'LBLSIZE') EQ 0) then status = 1


 return, status
end
;===========================================================================
