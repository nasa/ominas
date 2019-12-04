;=============================================================================
; cas_spice_spk_components
;
;=============================================================================
pro cas_spice_spk_components, all_names, wbad=wbad, wgood=wgood, $
         jd_deliv=jd_deliv, descr=descr, $
         type=type, version=version, format=format


 lf = strlen(format)

 n = n_elements(all_names)
 good = make_array(n, val=1b)

 ;-----------------------------------------
 ; extract delivery time, type, version
 ;-----------------------------------------

 ;- - - - - - - - - - - - - -
 ; delivery time
 ;- - - - - - - - - - - - - -
 s = str_nnsplit(all_names, '_', rem=rem)
 deliv = strtrim(strmid(s, 0, lf), 2)
 w = where(strlen(deliv) LT lf)
 if(w[0] NE -1) then good[w] = 0

 w = complement(good, str_isnum(deliv))
 if(w[0] NE -1) then good[w] = 0


 ;- - - - - - - - - - - - - -
 ; type / version
 ;- - - - - - - - - - - - - -
 code = strmid(s, lf, 2)
 lc = strlen(code)

 ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
 ; if no type/version, then make it 'AP'
 ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
 w = where((lc NE 1) AND (lc NE 2))
 if(w[0] NE -1) then code[w] = 'AP'

 ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
 ; if only one character, then determine which it is, and make the 
 ; other as preliminary as possible
 ;-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
 w = where(lc EQ 1)
 if(w[0] NE -1) then $
  begin
   ww = where((code[w] EQ 'R') OR (code[w] EQ 'P'))
   if(ww[0] NE -1) then code[w[ww]] = '0' + code[w[ww]]

   ww = complement(good, ww)
   if(ww[0] NE -1) then code[w[ww]] = code[w[ww]] + '0'
  end 

 version = strmid(code, 0, 1)
 type = strmid(code, 1, 1)

 ;-----------------------------------------
 ; extract content description
 ;-----------------------------------------
 descr = strtrim(str_nnsplit(rem, '_', rem=rem), 2)
 w = where(descr EQ '')
 if(w[0] NE -1) then good[w] = 0

 w = where(descr EQ 'SCEPH')			; SCEPH means 'SK'
 if(w[0] NE -1) then descr[w] = 'SK'


 ;-------------------------------------------------------
 ; now were finished; don't worry about coverage times
 ;-------------------------------------------------------
 wgood = where(good EQ 1)
 wbad = where(good EQ 0)

 deliv[wbad] = ''
 type[wbad] = ''
 version[wbad] = ''
 descr[wbad] = ''

 jd_deliv = dblarr(n)
 jd_deliv[wgood] = call_function(format+'_to_jd', deliv[wgood])

end
;=============================================================================



;=============================================================================
; cas_spice_spk_match_target
;
;=============================================================================
function cas_spice_spk_match_target, data, target

 ndata = n_elements(data)

 ii = 0

 for i=0, ndata-1 do $
  begin
   if(ptr_valid(data[i].targets_p)) then targets = *(data[i].targets_p)
   w = where(targets EQ target)
   if(w[0] NE -1) then ii = [ii, i]
  end

 if(n_elements(ii) EQ 1) then return, -1

 return, ii[1:*]
end
;=============================================================================



;=============================================================================
; cas_spice_spk_reject_by_descr
;
;=============================================================================
pro cas_spice_spk_reject_by_descr, data, descr, w=w

 w = where((data.descr EQ descr) AND data.good)
 if(w[0] NE -1) then $
  begin
   sort_names = strtrim(data[w].deliv,2) + data[w].version + data[w].type
   ss = rotate(sort(sort_names), 2)
   if(n_elements(ss) GT 1) then data[w[ss[1:*]]].good = 0
   w = w[ss[0]]
  end

end
;=============================================================================



;=============================================================================
; cas_spice_spk_latest
;
;=============================================================================
function cas_spice_spk_latest, data, w1, w2 

 dat1 = data[w1] & dat2 = data[w2]

 if((dat1.deliv GT dat2.deliv) $
     AND ((byte(dat1.version))[0] GT (byte(dat2.version))[0]) $
     AND ((byte(dat1.type))[0] GT (byte(dat2.type))[0])) then return, w1

 return, w2
end
;=============================================================================



;=============================================================================
; cas_spice_spk_detect
;
; The naming scheme is described at :
;   https://cassini.jpl.nasa.gov/cel/cedr/inv/work_area/work_group/spice/
;
; /strict causes kernels that don't follow the naming convention to be
; rejected.  Otherwise, they're accepted, but given lowest priority.
;
;=============================================================================
function cas_spice_spk_detect, dd, kpath, sc=sc, strict=strict, all=all, time=_time
common cas_spice_spk_block, data

 if(keyword__set(_time)) then time = _time

 label = dat_header(dd)

 ;--------------------------------
 ; get image jd
 ;--------------------------------
;;; if(NOT keyword_set(time)) then time = cas_spice_time(label)
 jd = spice_et2jed(time)

 jd = jd[0]

 ;--------------------------------------------------------------
 ; determine coverage dates, targets, version order
 ;--------------------------------------------------------------
 all_files = file_search(kpath + '*.bsp')
; if(NOT keyword__set(all_files)) then $
;                        nv_message, 'No kernel files found in ' + kpath + '.'

 ;--------------------------------------------------------------
 ; if data not already stored, go get it
 ;--------------------------------------------------------------
 if(NOT keyword__set(data)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; read detached label for coverage, targets
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   data = cas_spice_read_labels(all_files)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; get relevant filename components
   ;  files with problems are included, but given lowest priority
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   split_filename, all_files, dir, all_names
   all_names = str_nnsplit(all_names, '.')

   cas_spice_spk_components, all_names, format='yymmdd', $
        wgood=wgood, wbad=wbad, type=type, version=version, $
        jd_deliv=deliv, descr=descr
   if(wgood[0] EQ -1) then return, ''
   data.deliv = deliv
   data.version = version
   data.descr = descr
   data[wgood].good = 1
 
   wr = where(type EQ 'R')
   wp = where(type EQ 'P')
   if(wr[0] NE -1) then type[wr] = 'B'
   if(wp[0] NE -1) then type[wp] = 'A'

   data.type = type

   if(wbad[0] NE -1) then $
    begin
     data[wbad].deliv = 0
     data[wbad].version = '0'
     data[wbad].descr = ''
     data[wbad].good = 0
     data[wbad].type = '0'

     if(NOT keyword__set(strict)) then data[wbad].good = 1
    end

  end

 dat = data

 ;--------------------------------------------------------------
 ; sort all kernels by delivery / type / version
 ;--------------------------------------------------------------
 sort_names = strtrim(dat.deliv,2) + dat.version + dat.type

 ss = sort(sort_names)
 dat = dat[ss]

 w = where(dat.good)
 if(w[0] EQ -1) then return, ''
 dat = dat[w]

 if(keyword__set(all)) then return, dat.file

 ;--------------------------------------------------------------
 ; discard files for which there are no coverage dates
 ;--------------------------------------------------------------
 w = where(dat.start_jd NE 0)
 if(w[0] EQ -1) then return, ''
 dat = dat[w]

 ;--------------------------------------------------------------
 ; find files with relevant coverage
 ;--------------------------------------------------------------
 w = where(jd GE dat.start_jd)
 if(w[0] EQ -1) then return, ''
 dat = dat[w]

 w = where(jd LE dat.stop_jd)
 if(w[0] EQ -1) then return, ''
 dat = dat[w]

 ;--------------------------------------------------------------
 ; select only latest version of SK, SE, PE descriptions.  SCPSE 
 ;  counts for each of these groups
 ;--------------------------------------------------------------
 cas_spice_spk_reject_by_descr, dat, 'SK', w=wsk
 cas_spice_spk_reject_by_descr, dat, 'SE', w=wse
 cas_spice_spk_reject_by_descr, dat, 'PE' , w=wpe
 cas_spice_spk_reject_by_descr, dat, 'SCPSE' , w=wscpse

 if(wscpse[0] NE -1) then $
  begin
   if(wsk[0] NE -1) then $
    begin
     w = cas_spice_spk_latest(dat, wsk, wscpse)
     if(w EQ wscpse) then dat[wsk].good = 0
    end

   if(wse[0] NE -1) then $
    begin
     w = cas_spice_spk_latest(dat, wse, wscpse)
     if(w EQ wscpse) then dat[wse].good = 0
    end

   if(wpe[0] NE -1) then $
    begin
     w = cas_spice_spk_latest(dat, wpe, wscpse)
     if(w EQ wscpse) then dat[wpe].good = 0
    end
  end

 ;--------------------------------------------------------------
 ; we don't care about OPk files
 ;--------------------------------------------------------------
 cas_spice_spk_reject_by_descr, dat, 'OPK' , w=wopk
 if(wopk[0] NE -1) then dat[wopk].good = 0

 ;--------------------------------------------------------------
 ; as long as we have either PE or SCPSE files, let's ignore
 ; PLTEPH files.
 ;--------------------------------------------------------------
 if((wpe[0] NE -1) OR (wscpse[0] NE -1)) then $
  begin
   p = strpos(dat.file, 'PLTEPH')
   w = where(p NE -1)
   if(w[0] NE -1) then dat[w].good = 0
  end



 w = where(dat.good)
 if(w[0] EQ -1) then return, ''
 dat = dat[w]


;return, [dat.file, $
;  '/home/spitale/kernels/spk/030429AP_SCPSE_SM428_SM294.bsp', $
;  '/home/spitale/kernels/spk/030429AP_SK_SM428D_SM294D.bsp', $
;  '/home/spitale/kernels/spk/030909AP_SK_03244_03276.bsp' $
;  ]
 return, dat.file
end
;=============================================================================
