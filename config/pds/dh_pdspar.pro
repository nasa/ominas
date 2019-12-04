;=============================================================================
; dh_pdspar.pro
;
;=============================================================================
pro dh_pdspar, label, keyword, get=get, set=set

 if(arg_present(get)) then get = pdspar(label, keyword)

; NOTE the pds package does not seem to include a routine for writing keywords.

end
;=============================================================================
