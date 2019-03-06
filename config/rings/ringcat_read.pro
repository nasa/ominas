;=============================================================================;
; ringcat_read
;
;=============================================================================;
function ringcat_read, filename, names=names, default=default, $
      fiducial=fiducial, opaque=opaque, sma=sma, ecc=ecc, lp=lp, dlpdt=dlpdt, $
      inc=inc, lan=lan, dlandt=dlandt, m=m, epoch=epoch

 ;----------------------------
 ; read file
 ;----------------------------
 nv_message, /con, verb=0.2, 'Reading ring catalog ' + filename + '...'
 cat = read_txt_table(filename)

 ;----------------------------
 ; read columns
 ;----------------------------
 kk=0
 names = cat[*,kk]					 & kk=kk+1
 default = cat[*,kk] 					 & kk=kk+1
 fiducial = cat[*,kk]					 & kk=kk+1
 opaque = cat[*,kk]					 & kk=kk+1

 w = where(cat EQ '-')
 if(w[0] NE -1) then cat[w] = '0'

 sma = double(cat[*,kk])				 & kk=kk+1
 ecc = double(cat[*,kk])				 & kk=kk+1
 lp = double(cat[*,kk])		*!dpi/180d 		 & kk=kk+1
 dlpdt = double(cat[*,kk])	*!dpi/180d / 86400d	 & kk=kk+1
 inc = double(cat[*,kk])	*!dpi/180d		 & kk=kk+1
 lan = double(cat[*,kk])	*!dpi/180d		 & kk=kk+1
 dlandt = double(cat[*,kk])	*!dpi/180d / 86400d	 & kk=kk+1
 m = long(cat[*,kk])					 & kk=kk+1
 epoch = double(cat[*,kk])				 & kk=kk+1

 ;----------------------------
 ; consolidate features
 ;----------------------------
 w = where(names EQ '-')

; if(w[0] NE -1) then $
;  begin

 nm = dsk_get_nm() + 1
 m = m#make_array(nm,val=1l) & m[*,1:*] = 0
 ecc = ecc#make_array(nm,val=1d) & ecc[*,1:*] = 0
 lp = lp#make_array(nm,val=1d) & lp[*,1:*] = 0
 dlpdt = dlpdt#make_array(nm,val=1d) & dlpdt[*,1:*] = 0

 ;- - - - - - - - - - - - - - - - - - - - -
 ; fill in modes
 ;- - - - - - - - - - - - - - - - - - - - -
 if(w[0] NE -1) then $
  begin
   nw = n_elements(w)
   for i=0, nw-1 do $
    begin
     if(i EQ 0) then jj = 1 $
     else if(w[i] - w[i-1] NE 1) then jj = 1 $
     else jj = jj + 1

     m[w[i]-jj,jj] = m[w[i],0]
     ecc[w[i]-jj,jj] = ecc[w[i],0]
     lp[w[i]-jj,jj] = lp[w[i],0]
     dlpdt[w[i]-jj,jj] = dlpdt[w[i],0]
    end
  end

 ;- - - - - - - - - - - - - - - - - - - - -
 ; separate inner/outer ring edges
 ;- - - - - - - - - - - - - - - - - - - - -
 rings = str_nnsplit(names, path_sep(), rem=types)
 w = where(rings EQ '')
 if(w[0] NE -1) then $
  begin
   rings[w] = types[w]
   types[w] = 'OUTER'
  end

 types = strupcase(types)
 w = where((types NE 'INNER') $
           AND (types NE 'OUTER') $
           AND (types NE 'PEAK') $
           AND (types NE 'TROUGH'))
 if(w[0] NE -1) then nv_message, name='ringcat_read', $
                                   'Parse error in ring catalog file.'


 ;- - - - - - - - - - - - - - - - - - - - -
 ; set up data structure
 ;- - - - - - - - - - - - - - - - - - - - -
 w = where(names NE '-')
 nw = n_elements(w)

 dat = replicate({ringcat_record}, nw)

 dat.name = names[w]
 dat.ring = rings[w]
 dat.type = types[w]
 dat.default = default[w]
 dat.fiducial = fiducial[w]
 dat.opaque = opaque[w]
 dat.sma = sma[w]
 dat.ecc = tr(ecc[w,*])
 dat.lp = tr(lp[w,*])
 dat.dlpdt = tr(dlpdt[w,*])
 dat.inc = inc[w]
 dat.lan = lan[w]
 dat.dlandt = dlandt[w]
 dat.m = tr(m[w,*])
 dat.epoch = epoch[w]

 return, dat
end
;=============================================================================;


