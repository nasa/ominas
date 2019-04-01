;=============================================================================
; grim_settings_struct__define
;
;=============================================================================
pro grim_settings_struct__define

 struct = $
    { grim_settings_struct, $
	name:		'', $		; Name of grim_data field
	callback:	0, $		; Whether to call callback fn.
	boolean:	'', $		; 
	options:	strarr(10), $	; Array of options
	range:		dblarr(2) $ 	; Slider range for NUMERIC types.
    }

end
;===========================================================================
