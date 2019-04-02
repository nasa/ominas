;==============================================================================
; cas_iss_relut
;
;==============================================================================
function cas_iss_relut, dd, force=force

 image = dat_data(dd, /true)
 label = dat_header(dd)

 if(NOT keyword_set(label)) then force = 1

 ;----------------------------------------------------------
 ; determine whether conversion is necessary 
 ;----------------------------------------------------------
 if(NOT keyword_set(force)) then if(NOT cas_iss_query_lut(label)) then return, image
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

 dat_set_data, dd, byte(lut[image])
end
;==============================================================================
