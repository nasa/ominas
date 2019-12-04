function cor_isa, od, class
@core.include
 return, obj_isa(od, 'OMINAS_' + class)
end
