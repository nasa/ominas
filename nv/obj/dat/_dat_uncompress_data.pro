;================================================================================
; _dat_uncompress_data
;
;================================================================================
pro _dat_uncompress_data, _dd

 if(keyword_set((*_dd.dd0p).compress)) then $
                   call_procedure, 'dat_uncompress_data_' + (*_dd.dd0p).compress, _dd

end
;================================================================================



;================================================================================
; _dat_uncompress_data
;
;================================================================================
pro ___dat_uncompress_data, _dd, cdata=cdata, cabscissa=cabscissa

 cdata = data_archive_get((*_dd.dd0p).data_dap, (*_dd.dd0p).dap_index)
 cabscissa = data_archive_get((*_dd.dd0p).abscissa_dap, (*_dd.dd0p).dap_index)

 if(keyword_set((*_dd.dd0p).compress)) then $
                   call_procedure, 'dat_uncompress_data_' + (*_dd.dd0p).compress, _dd

end
;================================================================================
