;=============================================================================
; dh_structpar.pro
;
;=============================================================================
pro dh_structpar, label, keyword, get=get, set=set
compile_opt idl2,logical_predicate
 if(arg_present(get)) then begin
	 tn=tag_names(label)
	 wt=where(strmatch(tn,keyword,/fold_case),/null)
	 get=n_elements(wt) ? label.(wt[0]) : ''
	 
 endif


end
;=============================================================================
