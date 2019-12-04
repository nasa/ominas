;=============================================================================
; read_ext
;
;=============================================================================
function read_ext, filename, label, dim=dim, type=type, nodata=nodata

 label = ''

 extname = ext_get_name(filename)
 return, call_function(extname, filename, dim=dim, type=type, nodata=nodata)
end
;=============================================================================
