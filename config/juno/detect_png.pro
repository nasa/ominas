;===========================================================================
; detect_png.pro
;
;===========================================================================
function detect_png, filename=filename, header=header

 status=0

 ;==============================
 ; open the file
 ;==============================
 openr, unit, filename, /get_lun, error=error
 if(error NE 0) then return,0

 ;=================================
 ; read the first 8 bytes
 ;=================================
 if((fstat(unit)).size LT 8) then return, 0
 b=bytarr(8)
 readu,unit,b
 ;==============================
 ; close config file
 ;==============================
 close, unit
 free_lun, unit
 
 return,array_equal(b,[137B,80B,78B,71B,13B,10B,26B,10B])

end
;===========================================================================
