function cirs_separate_spectra,dd,byreq=byreq,keys=lks
compile_opt idl2,logical_predicate

da=dat_data(dd)
label=dat_header(dd)
table=label.table

l=pp_locate(table._conf_key+(keyword_set(byreq) ? '_'+table._request : ''))

ret=list()
dat_set_header,dd,['','']
dat_set_data,dd,[0,0]
ret=objarr(n_elements(l))
ic=0L
lks=(l.keys()).toarray()
lks=lks[sort(lks)]
confs=strarr(n_elements(lks))
reqs=strarr(n_elements(lks))
foreach lk,lks,ic do begin
  ll=l[lk]
  ddn=ominas_data()
  ddc=cor_dereference(dd)
  dd0p=*ddc.dd0p
  dd0p.header_dap=ptr_new()
  dd0p.data_dap=ptr_new()
  ddc.dd0p=ptr_new(dd0p)
  cor_rereference,ddn,ddc
  wavs=*((table[ll[0]])._ispw)
  specs=dblarr(n_elements(ll),n_elements(wavs))
  foreach lll,ll,ill do specs[ill,*]=*((table[lll])._ispm)
  dat_set_data,ddn,specs
  dat_set_header,ddn,{label:label.label,table:table[ll],fname:label.fname,wavs:wavs}
  ret[ic]=ddn

endforeach
dat_set_data,dd,da
dat_set_header,dd,label
return,ret

end
