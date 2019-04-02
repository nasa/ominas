;===========================================================================
; detect_geotiffmap.pro
;
;===========================================================================
function detect_geotiffmap, dd
 dh = dat_dh(dd)

 header=dat_header(dd)
 
 if size(header,/type) ne 8 then return,''
 tn=tag_names(header)
 if total(strmatch(tn,'INFO')+strmatch(tn,'GEO')+strmatch(tn,'PLANET')) ne 3 then return,''

 return, 'GEOTIFFMAP'
end
;===========================================================================
