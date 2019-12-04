;===========================================================================
; gff_struct__define
;
;
;===========================================================================
pro gff_struct__define


; need to include byte order and floating pt formats

 struct = $
    { gff_struct, $
	filename:	'', $
	file_offset:	0l, $
	data_offset_p:	nv_ptr_new(), $
	dim_p:		nv_ptr_new(), $
	type:		0l, $
	interleave_p:	nv_ptr_new() $
    }


end
;===========================================================================
