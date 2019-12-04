;===========================================================================
; gll_spice_time
;
;===========================================================================
function gll_spice_time, label, dt=dt, string=close_time

 dt = 0d

 scet_year = strtrim(vicgetpar(label, 'SCETYEAR'),2)
 scet_day = str_pad(strtrim(vicgetpar(label, 'SCETDAY'),2), 3, c='0', al=1.0)
 scet_hour = str_pad(strtrim(vicgetpar(label, 'SCETHOUR'),2), 2, c='0', al=1.0)
 scet_min = str_pad(strtrim(vicgetpar(label, 'SCETMIN'),2), 2, c='0', al=1.0)
 scet_sec = str_pad(strtrim(vicgetpar(label, 'SCETSEC'),2), 2, c='0', al=1.0)
 scet_msec = vicgetpar(label, 'SCETMSEC')
 if(scet_msec GT 99) then scet_msec = strtrim(scet_msec,2) $
 else if(scet_msec GT 9) then scet_msec = '0' + strtrim(scet_msec,2) $
 else scet_msec = '00' + strtrim(scet_msec,2)

 close_time = scet_year $
        +'-'+ scet_day $
        +'T'+ scet_hour $
        +':'+ scet_min $
        +':'+ scet_sec $
        +'.'+ scet_msec

 return, spice_str2et(close_time) + dt
end
;===========================================================================


