;=============================================================================;
; station_read
;
;=============================================================================;
function station_read, filename, names=names, default=default


 ;----------------------------
 ; read file
 ;----------------------------
 nv_message, /con, verb=0.2, 'Reading station catalog ' + filename + '...'
 cat = read_txt_table(filename)

 ;----------------------------
 ; read columns
 ;----------------------------
 dim = size(cat, /dim)
 kk=0
;stop
 if(dim[1] EQ 4) then $
  begin
   names = cat[*,kk]					 & kk=kk+1
   lat = double(cat[*,kk]) 				 & kk=kk+1
   lon = double(cat[*,kk]) 				 & kk=kk+1
   alt = double(cat[*,kk]) 				 & kk=kk+1
  end $
 else $
  begin 
   names = cat[*,kk]					 & kk=kk+1
   latdeg = double(cat[*,kk]) 				 & kk=kk+1
   latmin = double(cat[*,kk]) 				 & kk=kk+1
   latsec = double(cat[*,kk]) 				 & kk=kk+1
   londeg = double(cat[*,kk]) 				 & kk=kk+1
   lonmin = double(cat[*,kk]) 				 & kk=kk+1
   lonsec = double(cat[*,kk]) 				 & kk=kk+1
   alt = double(cat[*,kk]) 				 & kk=kk+1

   lat = latdeg + latmin/60d + latsec/3600d
   lon = londeg + lonmin/60d + lonsec/3600d
  end

 ;- - - - - - - - - - - - - - - - - - - - -
 ; set up data structure
 ;- - - - - - - - - - - - - - - - - - - - -
 n = n_elements(names)

 split_filename, filename, dir, name

 array_fnames = strarr(n)
 w = where(strpos(names, ':') NE -1)
 if(w[0] NE -1) then $
  begin
   names[w] = str_nnsplit(names[w], ':', rem=_array_fnames)
   array_fnames[w] = dir + path_sep() + _array_fnames + '.arr'
  end

 dat = replicate({station_record}, n)

 dat.name = names
 dat.array_fname = array_fnames
 dat.lat = lat * !dpi/180d
 dat.lon = lon * !dpi/180d
 dat.alt = alt


 return, dat
end
;=============================================================================;


