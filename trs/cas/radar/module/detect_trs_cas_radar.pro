;===========================================================================
; detect_trs_cas_radar.pro
;
;===========================================================================
function detect_trs_cas_radar, dd, arg, query=query
 if(keyword_set(query)) then return, 'INSTRUMENT'

 label = (dat_header(dd));[0]
 if ~isa(label,'string') then return,''
if total(stregex(label,'INSTRUMENT_NAME[[:blank:]]*=[[:blank:]]*("CASSINI RADAR")|"(CASSINI RADAR)"',/bool)) then return,'CAS_RADAR'

 return, ''
end
;===========================================================================