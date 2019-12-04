;=============================================================================
pro dat_slice__define


 struct = $
    { dat_slice, $
	slice_p:		nv_ptr_new(), $	; Coordinates for slice array
	dd0_h:			0l $		; Data descriptor of source array
    }


end
;===========================================================================


