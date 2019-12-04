;===========================================================================
; cas_radar_pds_header_info
;
;===========================================================================
function cas_radar_pds_header_info, dd

 meta = {cas_radar_spice_label_struct}

 label = dat_header(dd)
 if(NOT keyword_set(label)) then return, 0

 ;-----------------------------------
 ; target
 ;-----------------------------------
 meta.target = pdspar(label, 'TARGET_NAME')

 ;-----------------------------------
 ; time
 ;-----------------------------------
 meta.time = -1d100

 startt = pdspar(label, 'START_TIME')
 endt = pdspar(label, 'STOP_TIME')
 if(strmid(startt,strlen(startt)-1,1) EQ 'Z') then $
	                              startt = strmid(startt,0,strlen(startt)-1)
 if(strmid(endt,strlen(startt)-1,1) EQ 'Z') then $
	                              startt = strmid(startt,0,strlen(startt)-1)

 meta.stime = endt

 if(spice_test_lsk()) then $
  begin
   start_time = spice_str2et(startt)
   end_time = spice_str2et(endt)
   meta.time = mean([start_time, end_time])
   meta.dt = meta.time - end_time
  end

 return, meta
end 
;===========================================================================



