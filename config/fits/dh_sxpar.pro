;=============================================================================
; dh_sxpar.pro
;
;=============================================================================
pro dh_sxpar, header, keyword, get=get, set=set

 if(arg_present(get)) then get = sxpar(header, keyword) $
 else sxaddpar, label, keyword, set

end
;=============================================================================
