;===========================================================================
; detect_geotiff.pro
;
;===========================================================================
function detect_geotiff, filename=filename, header=header

 status = 0

 ;===============================================
 ; if no header, read the beginning of the file
 ;===============================================
 if(keyword_set(header)) then b=byte(header) else begin
   openr, unit, filename, /get_lun, error=error
   if(error NE 0) then return, 0
   if((fstat(unit)).size LT 16) then return, 0
   b=bytarr(16)
   readu,unit,b
   free_lun, unit
  endelse
 if(n_elements(b) LE 1) then return, 0

 ;===================================
 ; check for tiff header 
 ;===================================
 
 if size(b,/type) eq 8 then begin
  tn=tag_names(b)
  if total(strmatch(tn,'INFO')+strmatch(tn,'GEO')+strmatch(tn,'PLANET')) eq 3 then return,1 else return,0
 endif
 
 ;endianness
 case 1 of
   (b[0] eq 73B) and (b[1] eq 73B): bole=1
   (b[0] eq 77B) and (b[1] eq 77B): bole=0
   else: return,0 ; get out if magic numbers do not match tiff
 endcase
 
 if bole then mn=swap_endian(uint(b[2:3],0),/swap_if_big) else mn=swap_endian(uint(b[2:3],0),/swap_if_little)
 if ((mn ne 42) && (mn ne 43)) then return,0 ;get out if magic numbers do not match tiff or bigtiff 
 
 status=query_tiff(filename,geotiff=geo)
 if size(geo,/type) ne 8 then return,0 ;must be geotiff, not just tiff


 return, status
end
;===========================================================================
