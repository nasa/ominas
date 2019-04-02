;===========================================================================
; vgr_iss_w10n_pds_header_info
;
;===========================================================================
function vgr_iss_w10n_pds_header_info, dd

 meta = {vgr_iss_spice_label_struct}

 label = dat_header(dd)
 if(NOT keyword_set(label)) then return, 0

 jlabel = json_parse(label, /tostruct)
 meta.lab02 = jlabel.task[0].lab02
 meta.lab03 = jlabel.task[0].lab03
 meta.lab05 = jlabel.task[0].lab05
 meta.lab07 = jlabel.task[0].lab07

 sc_name = vgr_parse_inst(dat_instrument(dd), cam=name)

 ;-----------------------------------
 ; exposure time
 ;-----------------------------------
 exp = strmid(meta.lab03, strpos(meta.lab03,' EXP ')+5, 9)
 meta.exposure = double(exp) / 1000d

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
 meta.filters = strmid(meta.lab03, strpos(meta.lab03,' FILT ')+8, 6)

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
 scet = strmid(meta.lab02, strpos(meta.lab02,' SCET ')+6, 15)
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



