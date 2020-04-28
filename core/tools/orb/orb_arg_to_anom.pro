;==============================================================================
; orb_arg_to_anom
;
;  Converts angles meaured from the ascending node to angles measured from 
;  periapse.
;
;==============================================================================
function orb_arg_to_anom, xd, arg, frame_bd, ap=ap

 if(NOT keyword_set(ap)) then ap = orb_get_ap(xd, frame_bd)
 anom = arg - ap

 return, anom
end
;==============================================================================
