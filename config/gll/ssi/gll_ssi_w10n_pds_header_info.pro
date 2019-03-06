;===========================================================================
; gll_ssi_w10n_pds_header_info
;
;===========================================================================
function gll_ssi_w10n_pds_header_info, dd

 meta = {gll_ssi_spice_label_struct}

 label = dat_header(dd)
 if(NOT keyword_set(label)) then return, 0
 jlabel = json_parse(label, /tostruct)

 ;------------------------------
 ; exposure time
 ;------------------------------
 meta.exposure = double(jlabel.TASK[0].EXP)

 ;------------------------------------------------
 ; image size
 ;------------------------------------------------
 meta.size[0] = double(jlabel.SYSTEM[0].NS)
 meta.size[1] = double(jlabel.SYSTEM[0].NL)

 ;------------------------------------------------
 ; nominal optic axis coordinate, camera scale
 ;------------------------------------------------
 meta.oaxis = meta.size/2d - 0.5
 meta.scale = [1.016d-05, 1.016d-05]		    ; from trial and error

 ;------------------------------------------------
 ; detect summation modes
 ;------------------------------------------------
 mode = jlabel.TASK[0].TLMFMT
 if((mode EQ 'HIS') OR (mode EQ 'AI8')) then $
  begin
   meta.oaxis = meta.oaxis / 2d
   meta.scale = meta.scale*2d
  end

  meta.filters[0] = jlabel.TASK[0].FILTER


 ;------------------------------------------------
 ; target
 ;------------------------------------------------
 meta.target = strupcase(jlabel.TASK[0].TARGET)

 ;------------------------------
 ; time
 ;------------------------------
; meta.time = gll_ssi_spice_time(label)
 meta.time = -1d100

 scet_year = strtrim(jlabel.TASK[0].SCETYEAR,2)
 scet_day = str_pad(strtrim(jlabel.TASK[0].SCETDAY,2), 3, c='0', al=1.0)
 scet_hour = str_pad(strtrim(jlabel.TASK[0].SCETHOUR,2), 2, c='0', al=1.0)
 scet_min = str_pad(strtrim(jlabel.TASK[0].SCETMIN,2), 2, c='0', al=1.0)
 scet_sec = str_pad(strtrim(jlabel.TASK[0].SCETSEC,2), 2, c='0', al=1.0)
 scet_msec = jlabel.TASK[0].SCETMSEC
 if(scet_msec GT 99) then scet_msec = strtrim(scet_msec,2) $
 else if(scet_msec GT 9) then scet_msec = '0' + strtrim(scet_msec,2) $
 else scet_msec = '00' + strtrim(scet_msec,2)

 close_time = scet_year $
        +'-'+ scet_day $
        +'T'+ scet_hour $
        +':'+ scet_min $
        +':'+ scet_sec $
        +'.'+ scet_msec

 meta.dt = 0
 meta.stime = close_time
 if(spice_test_lsk()) then meta.time = spice_str2et(close_time) + meta.dt



 return, meta
end 
;===========================================================================



