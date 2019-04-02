;=============================================================================
; ext_read_jpeg
;
;  color table not yet implemented
;=============================================================================
function ext_read_jpeg, filename, dim=dim, type=type, nodata=nodata

 stat = query_jpeg(filename, info)
 if(NOT keyword_set(stat)) then nv_message, 'Not a JPEG file: ' + filename
 dim = info.dimensions
 if(info.channels GT 1) then dim = [dim, info.channels] 
 type = info.pixel_type

 if(keyword_set(nodata)) then return, 0

 read_jpeg, filename, dat

 if(n_elements(dim) EQ 3) then dat = transpose(dat, [1,2,0])
 dim = size(dat, /dim)

 return, dat
end
;=============================================================================
