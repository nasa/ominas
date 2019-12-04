;=============================================================================
; dat_transform_output
;
;=============================================================================
pro dat_transform_output, dd

 _dd = cor_dereference(dd)

 if(NOT keyword_set(*_dd.output_transforms_p)) then return

 transforms = *_dd.output_transforms_p
 for i=0, n_elements(transforms)-1 do call_procedure, transforms[i], dd

end
;=============================================================================
