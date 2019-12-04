;===========================================================================
; data_archive_clone
;
;===========================================================================
function data_archive_clone, dap

 daps = *dap
 nhist = n_elements(daps)

 new_daps = ptrarr(nhist) 
 for i=0, nhist-1 do new_daps[i] = nv_ptr_new(*daps[i])
 new_dap = nv_ptr_new(new_daps)

 return, new_dap
end
;===========================================================================
