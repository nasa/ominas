;=============================================================================
; dh_read_geotiff.pro
;
;=============================================================================
function dh_read_geotiff, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples
 compile_opt idl2,logical_predicate
 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 ;--------------------------------------------------------
 ; read label
 ;--------------------------------------------------------
 q=query_tiff(filename,info,geotiff=geo)
 planet=strtrim(dat_keyword_value(dd,'planet'),2) ? strtrim(dat_keyword_value(dd,'planet'),2) : 'EARTH' 
 


 ;- - - - - - - - - - - - - - - - - - - - -
 ; determine image dimensions
 ;- - - - - - - - - - - - - - - - - - - - -

 
min=0
max=0
dim=info.channels gt 1 ? [info.dimensions,info.channels] : info.dimensions
type=info.pixel_type

label={info:info,geo:geo,planet:planet,lines:dim[1],samples:dim[0]}

if(keyword_set(nodata)) then return, 0

 ;--------------------------------------------------------
 ; read image
 ;--------------------------------------------------------

 imaged=read_tiff(filename,orientation=ori)
 if ori eq 1 then imaged=reverse(imaged,2)
 return,imaged










end
;=============================================================================
