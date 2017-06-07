;=============================================================================
; dat_compress_data_mask
;
;=============================================================================
pro dat_compress_data_mask, _dd

 if(NOT ptr_valid(_dd.compress_data_p)) then _dd.compress_data_p = nv_ptr_new(0)

 data = data_archive_get((*_dd.data_struct_p).data_dap, $
                                                (*_dd.data_struct_p).dap_index)
 abscissa = data_archive_get((*_dd.data_struct_p).abscissa_dap, $
                                                 (*_dd.data_struct_p).dap_index)
 s = size(data)

 mask = where(data NE 0)

 cdata = 0
 if(mask[0] NE -1) then $
  begin
   cdata = data[mask]
   if(keyword_set(abscissa)) then cabscissa = abscissa[mask]
  end
 *_dd.compress_data_p = {size:s, mask:mask}

 data_archive_set, (*_dd.data_struct_p).data_dap, cdata, $
                               index=(*_dd.data_struct_p).dap_index, /noarchive
 if(keyword_set(cabscissa)) then $
      data_archive_set, (*_dd.data_struct_p).abscissa_dap, cabscissa, $
                                index=(*_dd.data_struct_p).dap_index, /noarchive
end
;=============================================================================



