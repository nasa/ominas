;===========================================================================
; cas_uvis_spice_time
;
;  Returns ET of center of observation
;  dt returns offset applied from shutter close
;
;===========================================================================
function cas_uvis_spice_time, dd, dt=dt, string=string, status=status, exposure=exposure

 status = -1
 label=dat_header(dd)
 start_time=pdspar(label,'START_TIME')
 if(NOT keyword_set(start_time)) then return, -1d100
 status = 0

 close_time=pdspar(label,'STOP_TIME')
 if(strmid(close_time,strlen(close_time)-1,1) EQ 'Z') then $
                 close_time = strmid(close_time,0,strlen(close_time)-1)
                 
 if(strmid(start_time,strlen(start_time)-1,1) EQ 'Z') then $
                 start_time = strmid(start_time,0,strlen(start_time)-1)

                 
 endjd=julday(1,strmid(close_time,5,3),strmid(close_time,0,4),$
  strmid(close_time,9,2),strmid(close_time,12,2),strmid(close_time,15,6))
 startjd=julday(1,strmid(start_time,5,3),strmid(start_time,0,4),$
  strmid(start_time,9,2),strmid(start_time,12,2),strmid(start_time,15,6))
 exposure=endjd-startjd
 exposure*=86400d0
 dt = -0.5d*exposure
 nv_message,verb=0.91,'UVIS START_TIME='+strtrim(start_time,2)
 if(keyword_set(string)) then return, close_time
 ret=spice_str2et(start_time)+ (-0d0)*dt
 return, ret
;===========================================================================
end


