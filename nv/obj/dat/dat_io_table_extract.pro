;=============================================================================
; dat_io_table_extract
;
;=============================================================================
function dat_io_table_extract, table, filetype, $
      input_fn, output_fn, keyword_fn, keyvals


 items = dat_table_extract(table, filetype, 3, keyvals=keyvals)
 if(NOT keyword_set(items)) then return, -1

 input_fn = decrapify(items[*,0])
 output_fn = decrapify(items[*,1])
 keyword_fn = decrapify(items[*,2])

 return, 0
end
;=============================================================================
