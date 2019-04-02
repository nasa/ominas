;================================================================================
; _dat_compress_data
;
;================================================================================
pro _dat_compress_data, _dd

 if(keyword_set((*_dd.dd0p).compress)) then $
                   call_procedure, 'dat_compress_data_' + (*_dd.dd0p).compress, _dd

end
;================================================================================



;================================================================================
; _dat_compress_data
;
;================================================================================
pro ___dat_compress_data, _dd, cdata=cdata, cabscissa=cabscissa

 if(defined(cdata)) then $
  begin
   data_archive_set, (*_dd.dd0p).data_dap, cdata, $
                                index=(*_dd.dd0p).dap_index, /noarchive
   if(keyword_set(cabscissa)) then $
        data_archive_set, (*_dd.dd0p).abscissa_dap, cabscissa, $
                                 index=(*_dd.dd0p).dap_index, /noarchive
   return
  end

 if(keyword_set((*_dd.dd0p).compress)) then $
                   call_procedure, 'dat_compress_data_' + (*_dd.dd0p).compress, _dd

end
;================================================================================
