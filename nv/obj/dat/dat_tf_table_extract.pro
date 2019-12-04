;=============================================================================
; dat_tf_table_extract
;
;=============================================================================
function dat_tf_table_extract, table, instrument, $
          input_transforms, output_transforms, keyvals


 items = dat_table_extract(table, instrument, 2, keyvals=_keyvals)
 if(NOT keyword_set(items)) then return, -1

 input_transforms = append_array(input_transforms, items[*,0])
 output_transforms = append_array(output_transforms, items[*,1])

 keyvals = append_array(keyvals, _keyvals)

 return, 0
end
;=============================================================================
