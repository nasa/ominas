;===========================================================================
; detect_pdscirstable.pro
;
;===========================================================================
function detect_pdscirstable, filename=filename, header=header
 compile_opt idl2,logical_predicate
 status = 0

 ;===============================================
 ; if no header, read the beginning of the file
 ;===============================================
 if(keyword_set(header)) then s = header $
 else $
  begin
   openr, unit, filename, /get_lun, error=error
   if(error NE 0) then return, 0
   if((fstat(unit)).size LT 160) then return, 0
   record = assoc(unit, bytarr(160,/nozero))
   s = string(record[0])
   close, unit
   free_lun, unit
  end


 ;===================================
 ; check for pds label 
 ;===================================
 if ~isa(s,'string') then return,0
 if(strpos(s[0], 'PDS_VERSION_ID') NE -1) then status = 1
 if(strpos(s[0], 'SFDU_LABEL') NE -1) then status = 1
 if(strpos(s[0], 'XV_COMPATIBILITY') NE -1) then status = 1
 if keyword_set(status) then begin
  ;if got here, it is a PDS3 file, now must check for a table and variable length records
  label=headpds(filename,/silent)
  status=0
  if total(stregex(label,'^[[:space:]]*OBJECT[[:space:]]*=[[:space:]]*TABLE[[:space:]]*$',/boolean)) then begin
    wi=where(stregex(label,'^[[:space:]]*OBJECT[[:space:]]*=[[:space:]]*FILE[[:space:]]*$',/boolean))
    we=where(stregex(label,'^[[:space:]]*END_OBJECT[[:space:]]*=[[:space:]]*FILE[[:space:]]*$',/boolean))
    foreach w,wi,iw do begin
      seg=label[w:we[iw]]
      if total(stregex(seg,'^[[:space:]]*RECORD_TYPE[[:space:]]*=[[:space:]]*VARIABLE_LENGTH[[:space:]]*$',/boolean)) then begin
        status=1
      endif else status=0
    endforeach
   endif
  endif

 return, status
end
;===========================================================================
