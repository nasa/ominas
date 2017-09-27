;===========================================================================
; vgr_iss_vicar_header_info
;
;===========================================================================
function vgr_iss_vicar_header_info, dd

 meta = {vgr_iss_spice_label_struct}

 label = dat_header(dd)
 if(NOT keyword_set(label)) then return, 0

 sc_name = vgr_parse_inst(dat_instrument(dd), cam=name)

 ;-----------------------------------
 ; time
 ;-----------------------------------
 meta.time = vgr_iss_spice_time(label)

 ;-----------------------------------
 ; exposure time
 ;-----------------------------------
 meta.exposure = vicar_vgrkey(label, 'EXP') / 1000d

 ;-----------------------------------
 ; image size, scale
 ;-----------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; geom'd image
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 geom = 0
 if(strpos(label,'GEOM') NE -1) then geom = 1
 if(strpos(label,'FARENC') NE -1) then geom = 1
 if(strpos(label,'*** OBJECT SPACE') NE -1) then geom = 1
 s = dat_dim(dd)
 if(s[0] EQ 1000 AND s[1] EQ 1000) then geom = 1

 if((geom)) then $
  begin
   meta.scale = vgr_iss_pixel_scale(sc_name, name, /geom)
   meta.size[0] = 1000d
   meta.size[1] = 1000d
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; raw image   
 ;  Here we use initial guesses.  That's the best that
 ;  can be done before reseau marks are analyzed.
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   meta.scale = vgr_iss_pixel_scale(sc_name, name)
   meta.size[0] = 800d
   meta.size[1] = 800d
  end

 ;-----------------------------------
 ; optic axis
 ;-----------------------------------
 meta.oaxis = meta.size/2d

 ;-----------------------------------
 ; filters
 ;-----------------------------------
 meta.filters = vicgetpar(label, 'FILTER_NAME')

 ;-----------------------------------
 ; target
 ;-----------------------------------
 meta.target = strupcase(vicgetpar(label, 'TARGET_NAME'))

 return, meta
end 
;===========================================================================



