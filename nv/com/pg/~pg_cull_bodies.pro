;===========================================================================
; pg_cull_bodies
;
;
;===========================================================================
pro pg_cull_bodies, bx, sel, name=name

 ;-------------------------------------------------
 ; except any gi
 ;-------------------------------------------------
 if(keyword_set(name)) then $
  begin
   w = nwhere(name, cor_name(bx))
   if(w[0] NE -1) then sel = append_array(sel, w)
  end

 if(keyword_set(sel)) then $
  begin
   sel = unique(sel)

   w = complement(bx, sel)
   nv_message, verb=0.2, $
      'The following objects were deleted: ' + str_comma_list(cor_name(bx[w]))

   if(w[0] NE -1) then nv_free, bx[w]

   if(sel[0] EQ -1) then bx = obj_new() $
   else bx = bx[sel]
  end

end
;===========================================================================
