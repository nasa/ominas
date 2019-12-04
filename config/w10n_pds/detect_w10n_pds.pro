;===========================================================================
; detect_w10n_pds.pro
;
;===========================================================================
function detect_w10n_pds, filename=filename, header=header

 ;if(keyword_set(header)) then return, 0

 if (strpos(filename,'https://pds-imaging.jpl.nasa.gov/w10n/') EQ 0 ) then return, 1
 if (strpos(filename,'http://pds-imaging.jpl.nasa.gov/w10n/') EQ 0 ) then return, 1

 return, 0
end
;===========================================================================
