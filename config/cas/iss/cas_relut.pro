;==============================================================================
; cas_relut
;
;==============================================================================
function cas_relut, image, label, force=force

 if(NOT keyword_set(label)) then force = 1

 ;----------------------------------------------------------
 ; determine whether conversion is necessary 
 ;----------------------------------------------------------
 if(NOT keyword_set(force)) then if(NOT cas_query_lut(label)) then return, image
 if(size(image, /type) EQ 1) then return, image    ; if byte, then already 
                                                   ;  lutted

 ;----------------------------------
 ; generate a reverse lookup table
 ;----------------------------------
 lut = cas_reverse_lut()

 ;--------------------------
 ; apply the lookup table
 ;--------------------------
 nv_message, verb=0.2, 'Re-LUT-ing...'

 return, byte(lut[image])
end
;==============================================================================
