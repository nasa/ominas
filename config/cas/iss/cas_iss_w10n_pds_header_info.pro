;===========================================================================
; cas_iss_w10n_pds_header_info
;
;===========================================================================
function cas_iss_w10n_pds_header_info, dd

 meta = {cas_iss_spice_label_struct}

 label = dat_header(dd)
 if(NOT keyword_set(label)) then return, 0
 jlabel = json_parse(label, /tostruct)

 ;-----------------------------------
 ; exposure time
 ;-----------------------------------
 meta.exposure = double(jlabel.PROPERTY[0].EXPOSURE_DURATION)/1000d

 ;-----------------------------------
 ; image size
 ;-----------------------------------
 meta.size[0] = double(jlabel.SYSTEM[0].NS)
 meta.size[1] = double(jlabel.SYSTEM[0].NL)

 ;-----------------------------------
 ; filters
 ;-----------------------------------
 meta.filters[0] = jlabel.PROPERTY[0].FILTER_NAME[0]
 meta.filters[1] = jlabel.PROPERTY[0].FILTER_NAME[1]

 ;-----------------------------------
 ; target
 ;-----------------------------------
 target_name = strupcase(jlabel.PROPERTY[3].TARGET_NAME)
 meta.target = target_name
 if(tag_exists(jlabel.PROPERTY[3], 'TARGET_DESC')) then begin
    target_desc = strupcase(jlabel.PROPERTY[3].TARGET_DESC) 
    obs_id = jlabel.PROPERTY[3].OBSERVATION_ID
    if((strpos(strupcase(obs_id), 'OPNAV'))[0] NE -1) then meta.target = target_desc
 endif

 ;-----------------------------------
 ; optic axis
 ;-----------------------------------
 meta.oaxis = meta.size/2d - 0.5

 ;-----------------------------------
 ; time
 ;-----------------------------------
 meta.time = -1d100
 close_time = jlabel.PROPERTY[3].IMAGE_TIME
 if(strmid(close_time,strlen(close_time)-1,1) EQ 'Z') then $
        	      close_time = strmid(close_time,0,strlen(close_time)-1)
 meta.dt = -0.5d*meta.exposure
 meta.stime = close_time
 if(spice_test_lsk()) then meta.time = spice_str2et(close_time) + meta.dt

 return, meta
end 
;===========================================================================



