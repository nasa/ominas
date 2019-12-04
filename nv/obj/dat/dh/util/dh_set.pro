;=============================================================================
; dh_set.pro
;
; Places a detached header into the given data descriptor
;
;=============================================================================
pro dh_set, dd, dh
; dat_set_dh, dd, dh
 cor_set_udata, dd, 'DETACHED_HEADER', dh 
end
;=============================================================================
