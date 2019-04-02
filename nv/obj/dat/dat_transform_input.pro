;=============================================================================
; dat_transform_input
;
;=============================================================================
pro dat_transform_input, dd

 _dd = cor_dereference(dd)

 if(NOT keyword_set(*_dd.input_transforms_p)) then return

 transforms = *_dd.input_transforms_p
 for i=0, n_elements(transforms)-1 do call_procedure, transforms[i], dd

end
;=============================================================================
