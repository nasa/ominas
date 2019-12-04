pro ominas_icy_test
compile_opt idl2,logical_predicate
catch,err
if err then begin
  catch,/cancel
  ret='Icy not found'
  st=1
endif else begin
  help,/dlm,output=o
  w=where(stregex(o,'icy\.so$',/bool))
  ret=CSPICE_TKVRSN( 'toolkit' ) + ', '+o[w[0]]
  ret=(stregex(ret,'Path:[[:blank:]]*(/.*)/lib/icy\.so$',/extract,/subexpr))[-1]
  st=0
endelse
print,ret
exit,status=st
end
