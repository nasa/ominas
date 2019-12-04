;===============================================================================
; dat_slice_offset
;
;===============================================================================
function dat_slice_offset, arg

 if(cor_test(arg)) then $
  begin
   dd = arg 
   _dd = cor_dereference(dd)
   slice = dat_slice(_dd, dd0=dd0)
  end $
 else $
  begin
   slice = arg.slice
   dd0 = arg.dd0
  end


 m = n_elements(slice)
 dim0 = dat_dim(dd0, /true)
 ndim0 = n_elements(dim0)

 dim = dim0[0:ndim0-1-m]
 ndim = n_elements(dim)
 nelm = long(product(dim))

 offset = 0

 nn = nelm

 for i=0, m-1 do $
  begin
   offset = offset + nn*slice[i]
   nn = nn*dim0[ndim+i]
  end

 return, offset
end
;===============================================================================
