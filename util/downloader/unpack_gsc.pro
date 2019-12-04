pro unpack_gsc
compile_opt idl2,logical_predicate
a=pp_command_line_args_parse()
path=a.arguments[0]
rfiles=['regions.dat.gz','plates.epoch.gz','regions.ord.gz']
file_gunzip,path+path_sep()+rfiles,/verbose
print,'GSC files unpacked'
end
