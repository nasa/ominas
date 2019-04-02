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
 ; sublabels
 ;-----------------------------------
 meta.lab02 = vicgetpar(label, 'LAB02')
 meta.lab03 = vicgetpar(label, 'LAB03')
 meta.lab05 = vicgetpar(label, 'LAB05')
 meta.lab07 = vicgetpar(label, 'LAB07')

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
 meta.oaxis = meta.size/2d - 0.5

 ;-----------------------------------
 ; filters
 ;-----------------------------------
 meta.filters = vicar_vgrkey(label, 'FILT')

 ;-----------------------------------
 ; target
 ;-----------------------------------
 meta.target = strtrim(strmid(meta.lab05, 35, 11), 2)
 if (meta.target EQ 'ENCELADU') then meta.target = 'ENCELADUS'
 if (meta.target EQ 'S-RINGS') then meta.target = 'SATURN'

 ;-----------------------------------
 ; time
 ;-----------------------------------
 meta.time = -1d100
 scet = vicar_vgrkey(label, 'SCET')
 p = strpos(strupcase(scet), 'UNKNOWN')
 if(p[0] EQ -1) then $
  begin
   close_time = vgr_scet_to_image_time(scet)
   meta.dt = -0.5d*meta.exposure
   meta.stime = close_time
   if(spice_test_lsk()) then meta.time = spice_str2et(close_time) + meta.dt
  end


 return, meta
end 
;===========================================================================



