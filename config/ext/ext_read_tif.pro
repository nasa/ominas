;=============================================================================
; ext_read_tif
;
;  NOT TESTED
;=============================================================================
function ext_read_tif, filename, dim=dim, nodata=nodata

 stat = query_tiff(filename, info)
 if(NOT keyword_set(stat)) then nv_message, 'Not a TIFF file: ' + filename
 dim = info.dimensions
 if(info.channels GT 1) then dim = [dim, info.channels] 
 type = info.pixel_type

 dat = read_tiff(filename, r, g, b)

 if(n_elements(dim) EQ 3) then dat = transpose(dat, [1,2,0]) $
 else if(keyword_set(r)) then $
  begin
   _dat = bytarr([dim,3])
   _dat[*,*,0] = r[dat]
   _dat[*,*,1] = g[dat]
   _dat[*,*,2] = b[dat]
   dat = _dat
  end

 dim = size(dat, /dim)

 return, dat
end
;=============================================================================
