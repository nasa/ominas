function pp_get_label_value,_label,key
compile_opt idl2,logical_predicate
ret=!null
label=strsplit(_label,string(10B),/extract)
if isa(label,'list') then label=label.toarray()
expr='^[[:blank:]][[:<:]]'+key+'[[:blank:]]*=[[:blank:]]*(("([[:print:]]+)")|([[:print:]]+))'
line=label[where(stregex(label,expr,/boolean),/null,count)]
if count then begin
  line=line[-1]
  ret=stregex(line,expr,/subexpr,/extract)
  return,ret[3] ? ret[3] : ret[4]
endif
return,ret
end
