pro unpack_tycho2
compile_opt idl2,logical_predicate
a=pp_command_line_args_parse()
path=a.arguments[0]
rfiles=['index.dat.gz','suppl_1.dat.gz','suppl_2.dat.gz']
file_gunzip,path+path_sep()+rfiles,/verbose
fs=file_search(path+path_sep()+'tyc2.dat.??.gz')
openw,lun,path+path_sep()+'tyc2.dat',/get_lun
foreach f,fs do begin
  print,'unpacking ',f
  file_gunzip,f,buffer=b
  writeu,lun,b
endforeach
free_lun,lun
print,'Tycho 2 files unpacked'
end
