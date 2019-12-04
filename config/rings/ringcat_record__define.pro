;===========================================================================
; ringcat_record__define
;
;
;===========================================================================
pro ringcat_record__define

 nm = dsk_get_nm() + 1

 struct = $
    { ringcat_record, $
	 name 		:	'', $
	 ring		:	'', $
	 type		:	'', $
	 default 	:	'', $
	 fiducial 	:	'', $
	 opaque		:	'', $
	 sma 		:	0d, $
	 ecc 		:	dblarr(nm), $
	 lp		:	dblarr(nm), $
	 dlpdt		:	dblarr(nm), $
	 inc 		:	0d, $
	 lan 		:	0d, $
	 dlandt 	:	0d, $
	 m 		:	lonarr(nm), $
	 epoch 		:	0d $
    }

end
;===========================================================================

