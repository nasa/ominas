;===========================================================================
; cas_spice_time
;
;  Returns ET of center of observation
;  dt returns offset applied from shutter close
;
;===========================================================================
function cas_spice_time, label, dt=dt, string=close_time

 close_time = vicgetpar(label, 'IMAGE_TIME')
 if(NOT keyword_set(close_time)) then return, -1d100

 if(strmid(close_time,strlen(close_time)-1,1) EQ 'Z') then $
	                close_time = strmid(close_time,0,strlen(close_time)-1)
 exposure = vicgetpar(label, 'EXPOSURE_DURATION')/1000d

 dt = -0.5d*exposure

 return, spice_str2et(close_time) + dt
end
;===========================================================================



