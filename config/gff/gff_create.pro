;=============================================================================
; gff_create  
;
;=============================================================================
function gff_create, filename, dim, type, $
        interleave=interleave, file_offset=file_offset, data_offset=data_offset


 if(NOT keyword_set(interleave)) then interleave = 0
 if(NOT keyword_set(file_offset)) then file_offset = 0
 if(NOT keyword_set(data_offset)) then data_offset = 0

 gff = {gff_struct, $
	filename:	filename, $
	file_offset:	file_offset, $
	data_offset_p:	nv_ptr_new(data_offset), $
	dim_p:		nv_ptr_new(dim), $
	type:		type, $
	interleave_p:	nv_ptr_new(interleave) $
    }

 return, gff
end
;=============================================================================
