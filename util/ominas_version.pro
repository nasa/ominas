function ominas_version
compile_opt idl2,logical_predicate

gitver='cd '+getenv('OMINAS_DIR')+' && git describe --abbrev=4 --dirty --always --tags'
spawn,gitver,res,err

if keyword_set(err) then begin
  readme=getenv('OMINAS_DIR')+path_sep()+'README.md'
  re=strarr(file_lines(readme))
  openr,lun,/get_lun,readme
  readf,lun,re
  free_lun,lun
  rev=re[where(stregex(re,'^###Current release:',/boolean))]
  ret=(stregex(rev,'^###Current release:[[:space:]]*(.*)',/subexpr,/extract))[-1]+'-untracked'
endif else ret=res

return,ret
end
