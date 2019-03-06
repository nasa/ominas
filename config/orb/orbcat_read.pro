;=============================================================================;
; ocr_get_value
;
;
;=============================================================================;
pro ocr_get_value, dat, keys, vals, key

 w = where(keys EQ key)
 if(w[0] EQ -1) then return

 val = double(vals[w])

 tags = tag_names(dat)
 w = where(tags EQ strupcase(key))
 dat.(w[0]) = val
 dat.(w[0]+1) = 1
end
;=============================================================================;



;=============================================================================;
; orbcat_read
;
;=============================================================================;
function orbcat_read, filename

 ;----------------------------
 ; read file
 ;----------------------------
 nv_message, verb=0.2, 'Reading orbit catalog ' + filename + '...'
 cat = read_txt_file(filename)


 ;----------------------------
 ; parse and get names
 ;----------------------------
 keys = strtrim(strupcase(str_nnsplit(cat, '=', rem=vals)), 2)
 w_name = where(keys EQ 'NAME')
 names = strupcase(vals[w_name])
 n = n_elements(names)

 dat = replicate({orbcat_record}, n)

 ;----------------------------
 ; get elements
 ;----------------------------
 for i=0, n-1 do $
  begin
   ii = w_name[i]+1
   jj = n_elements(cat)-1
   if(i NE n-1) then jj = w_name[i+1]-1
   _keys = keys[ii:jj]
   _vals = vals[ii:jj]


   dat[i].name = names[i]

   _dat = dat[i]
   ocr_get_value, _dat, _keys, _vals, 'EPOCH'
   ocr_get_value, _dat, _keys, _vals, 'EPOCH_JED'
   ocr_get_value, _dat, _keys, _vals, 'SMA'
   ocr_get_value, _dat, _keys, _vals, 'ECC'
   ocr_get_value, _dat, _keys, _vals, 'INC'
   ocr_get_value, _dat, _keys, _vals, 'LAN'
   ocr_get_value, _dat, _keys, _vals, 'AP'
   ocr_get_value, _dat, _keys, _vals, 'MA'
   ocr_get_value, _dat, _keys, _vals, 'DAPDT'
   ocr_get_value, _dat, _keys, _vals, 'DLANDT'
   ocr_get_value, _dat, _keys, _vals, 'DMLDT'
   ocr_get_value, _dat, _keys, _vals, 'DMADT'
   ocr_get_value, _dat, _keys, _vals, 'LP'
   ocr_get_value, _dat, _keys, _vals, 'ML'
   ocr_get_value, _dat, _keys, _vals, 'DLPDT'
   ocr_get_value, _dat, _keys, _vals, 'PPT'
   ocr_get_value, _dat, _keys, _vals, 'PPT_JED
   ocr_get_value, _dat, _keys, _vals, 'TA'
   ocr_get_value, _dat, _keys, _vals, 'TL'

   dat[i] = _dat
  end


 ;-------------------------------------
 ; conversions
 ;-------------------------------------
 deg2rad = !dpi/180d
 degday2radsec = !dpi/180d / 86400d

 dat.inc = dat.inc * deg2rad
 dat.lan = dat.lan * deg2rad
 dat.ap = dat.ap * deg2rad
 dat.ma = dat.ma * deg2rad
 dat.lp = dat.lp * deg2rad
 dat.ml = dat.ml * deg2rad
 dat.tl = dat.ta * deg2rad

 dat.dapdt = dat.dapdt * degday2radsec
 dat.dlandt = dat.dlandt * degday2radsec
 dat.dmldt = dat.dmldt * degday2radsec
 dat.dmadt = dat.dmadt * degday2radsec
 dat.dlpdt = dat.dlpdt * degday2radsec

 w = where(dat.epoch_jed_defined)
 if(w[0] NE -1) then $
  begin
   dat[w].epoch = jed_to_ret(dat[w].epoch_jed)
   dat[w].epoch_defined = 1
   nv_message, /warning, $
      'Using raw ephemeris times for: ' + str_comma_list(dat[w].name)
  end

 w = where(dat.ppt_jed_defined)
 if(w[0] NE -1) then  $
  begin
   dat[w].ppt = jed_to_ret(dat[w].ppt_jed)
   dat[w].ppt_defined = 1
   nv_message, /warning, $
      'Using raw periapse times for: ' + str_comma_list(dat[w].name)
  end

 return, dat
end
;=============================================================================;


