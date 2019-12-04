;===========================================================================
; dsk_swap
;
;  This routine is not used
;
;===========================================================================
pro dsk_swap, dkd, noevent=noevent
@core.include
 
 _dkd = cor_dereference(dkd)

 tags = tag_names(_dkd)

 for i=2, n_elements(tags)-1 do $
  begin
   dim = size(_dkd.(i), /dim)
   ndim = n_elements(dim)
   if(ndim EQ 2) then if(dim[1] EQ 2) then _dkd.(i) = rotate(_dkd.(i),7)
  end

 cor_rereference, dkd, _dkd
 nv_notify, dkd, type = 0, noevent=noevent
end
;===========================================================================
