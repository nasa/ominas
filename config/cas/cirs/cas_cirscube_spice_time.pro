;===========================================================================
; cas_cirs_spice_time
;
;  Returns ET of center of observation
;  dt returns offset applied from shutter close
;
;===========================================================================
function cas_cirscube_spice_time, dd, dt=dt, string=string, status=status, exposure=exposure

 status = -1
 label=dat_header(dd)
 start_time=pdspar(label,'SCET_START')
 close_time=pdspar(label,'SCET_END')
 
 if(NOT keyword_set(start_time)) then return, -1d100
 status = 0

 endjd=julday(1,1,1970,0,0,0)+close_time/86400d0
 startjd=julday(1,1,1970,0,0,0)+start_time/86400d0
 exposure=endjd-startjd
 exposure*=86400d0
 dt = -0.5d*exposure
 nv_message,verb=0.91,'CIRSCUBE START_TIME='+strtrim(start_time,2)
 if(keyword_set(string)) then return, close_time
 return, spice_str2et('JD'+string(endjd,format='(F018.10)'))+ dt
;===========================================================================
end


