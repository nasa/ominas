;====================================================================================
; gr_png_all
;
;====================================================================================
pro gr_png_all

 grift, dd=dds, /all, pn=pn
 grim_data = grim_get_data()

 n = n_elements(pn)
 for i=0, n-1 do $
  begin 
   grim_jump_to_plane, grim_data, pn[i] 
   grim_refresh, grim_data
   png_image, 'grim_' + cor_name(dds[i]) + '-' + strtrim(pn[i],2) + '.png'
  end


end
;====================================================================================
