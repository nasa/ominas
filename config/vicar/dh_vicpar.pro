;=============================================================================
; dh_vicpar.pro
;
;=============================================================================
pro dh_vicpar, label, keyword, get=get, set=set

 if(arg_present(get)) then get = vicgetpar(label, keyword) $
 else vicsetpar, label, keyword, set

end
;=============================================================================
