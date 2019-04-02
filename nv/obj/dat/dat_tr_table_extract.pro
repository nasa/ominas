;=============================================================================
; dat_tr_table_extract
;
;=============================================================================
function dat_tr_table_extract, table, instrument, $
      input_translators, output_translators, keyvals


 items = dat_table_extract(table, instrument, 2, keyvals=_keyvals)
 if(NOT keyword_set(items)) then return, -1

 input_translators = append_array(input_translators, items[*,0])
 output_translators = append_array(output_translators, items[*,1])

 keyvals = append_array(keyvals, _keyvals)

 return, 0
end
;=============================================================================
