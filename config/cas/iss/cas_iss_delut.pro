;==============================================================================
; cas_iss_delut
;
;  Adapted from cassimg__twelvebit.pro, which was contributed by Daren Wilson.
;
;  This Lookup Table (or LUT) is from Appendix F1 of the
;  Cassini ISS Calibration Report
;  It is the inverse of the 12bit to 8bit pseudologarithmic LUT
;  optionally used to encode the ISS images.
;  There are therefore 256 elements which map corresponding DNs back
;  into the full 12bit range 0-4095 in a near exponential relationship
;
;==============================================================================
pro cas_iss_delut, dd, force=force

 image = dat_data(dd, /true)
 label = dat_header(dd)
 
 if(NOT keyword_set(label)) then force = 1

 ;----------------------------------------------------------
 ; determine whether conversion is necessary 
 ;----------------------------------------------------------
 if(NOT keyword_set(force)) then if(NOT cas_iss_query_lut(label)) then return, image
 if(size(image, /type) NE 1) then return, image    ; if not byte, then already 
                                                   ;  de-lutted

 ;-----------------------
 ; Get the lookup table
 ;-----------------------
 lut = cas_iss_lut()

 ;--------------------------
 ; apply the lookup table
 ;--------------------------
 nv_message, verb=0.2, 'De-LUT-ing...'

 dat_set_data, dd, lut[image]
end
;==============================================================================
