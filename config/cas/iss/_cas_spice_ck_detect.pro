;=============================================================================
; get_all_ck_files
;=============================================================================
function get_all_ck_files, ckpath

 all_files = file_search(ckpath + '/*??.bc')

; yydoy_files = file_search(ckpath + '/?????_?????*.bc')
; yymmdd_files = file_search(ckpath + '/??????_??????*.bc')
; all_files = append_array(yydoy_files, yymmdd_files)

 if(NOT keyword_set(all_files)) then $
  begin
   year = 98
   done = 0

   while(NOT done) do $
    begin
     year_files = file_search(ckpath + '/' + str_pad(strtrim(year,2),2,c='0',align=1) + '*??.bc')
     if(NOT keyword_set(year_files)) then done = 1 $
     else all_files = append_array(all_files, year_files)
     year = (year + 1) mod 100
    end

  end

 return, all_files
end
;=============================================================================



;=============================================================================
; cas_spice_ck_components
;
;=============================================================================
pro cas_spice_ck_components, all_names, format, ii=ii, $
   jd_start=jd_start, jd_stop=jd_stop, type=_type, version=_version, desc=desc

 jd_start = (jd_stop = (_type = (_version = (_desc = ''))))

 n = n_elements(all_names)
 ii = lindgen(n)

 ;-------------------------------------
 ; extract start time
 ;-------------------------------------
 start = str_nnsplit(all_names, '_', rem=rem)
 l = strlen(start)

 lf = strlen(format)
 ww = where(l EQ lf)
 if(ww[0] EQ -1) then return
 start = start[ww]
 ii = ii[ww]

 ;-------------------------------------
 ; extract stop time, type, version
 ;-------------------------------------
 rem = rem[ww]
 stop = strmid(rem, 0, lf)
 type = strmid(rem, lf, 1)
 version = strmid(rem, lf+1, 1)

 desc = type & desc[*] = ''
 w = where(strpos(rem, '_') NE -1)
 if(w[0] NE -1) then $
  begin
   junk = str_nnsplit(rem[w], '_', rem=rem)
   desc[w] = rem 
  end

 ;----------------------------------------------------------------------
 ; sometimes they forget to put the type and version, so we'll use
 ; 'p0' so that it's superceded by any other file with the same 
 ; coverage.
 ;----------------------------------------------------------------------
 w = where(type EQ '')
 if(w[0] NE -1) then $
  begin
   type[w] = 'p'
   version[w] = '0'
  end

 ;----------------------------------------------------------------------
 ; weed out the bad names
 ;----------------------------------------------------------------------
 w = str_isnum(start)
 if(w[0] EQ -1) then return
 ii = ii[w]
 start=start[w] & stop=stop[w] & type=type[w] & version=version[w] & desc=desc[w]

 w = str_isnum(stop)
 if(w[0] EQ -1) then return
 ii = ii[w]
 start=start[w] & stop=stop[w] & type=type[w] & version=version[w] & desc=desc[w]

 w = str_isalpha(type)
 if(w[0] EQ -1) then return
 ii = ii[w]
 start=start[w] & stop = stop[w] & type=type[w] & version=version[w] & desc=desc[w]

 w = str_isalphanum(version)
 if(w[0] EQ -1) then return
 ii = ii[w]
 start=start[w] & stop=stop[w] & type=type[w] & version=version[w] & desc=desc[w]


 jd_start = call_function(format+'_to_jd', start)
 jd_stop = call_function(format+'_to_jd', stop)

 _type = type
 _version = version
end
;=============================================================================



;=============================================================================
; cas_spice_ck_detect
;
; Only kernels whose filenames match the standard convention and whose 
; coverage dates are within djd days of the given image are returned.
;
; The naming scheme is described at :
;   https://cassini.jpl.nasa.gov/cel/cedr/inv/work_area/work_group/spice/
;
; 12/2006: kernels whose names contain the image name are also matched.
;
;=============================================================================
function cas_spice_ck_detect, dd, ckpath, sc=sc, djd=djd, time=time, $
                                               all=all, strict=strict
 if(NOT keyword_set(djd)) then djd = 1d			; days, +/-


 ;--------------------------------
 ; get image jd
 ;--------------------------------
 jd = spice_et2jed(time)

 ;--------------------------------
 ; get ck jd's
 ;--------------------------------
 all_files = get_all_ck_files(ckpath)
 if(NOT keyword_set(all_files)) then return, ''
 if(keyword_set(all)) then return, all_files

 ;--------------------------------------------------
 ; get rid of 'waypoint' kernels
 ;--------------------------------------------------
 p = strpos(all_files, 'waypoint')
 w = where(p EQ -1)
 if(w[0] EQ -1) then return, all_files
 all_files = all_files[w]

 split_filename, all_files, dir, all_names
 all_names = str_nnsplit(all_names, '.')


 ;--------------------------------------------------
 ; extract components for each date convention
 ;--------------------------------------------------
 cas_spice_ck_components, all_names, 'yymmdd', ii=_ii, $
   jd_start=_jd_start, jd_stop=_jd_stop, type=_type, version=_version, desc=_desc
 jd_start = append_array(jd_start, _jd_start)
 jd_stop = append_array(jd_stop, _jd_stop)
 type = append_array(type, _type)
 version = append_array(version, _version)
 desc = append_array(desc, _desc)
 ii = append_array(ii, _ii)

 cas_spice_ck_components, all_names, 'yydoy', ii=_ii, $
    jd_start=_jd_start, jd_stop=_jd_stop, type=_type, version=_version, desc=_desc
 jd_start = append_array(jd_start, _jd_start)
 jd_stop = append_array(jd_stop, _jd_stop)
 type = append_array(type, _type)
 version = append_array(version, _version)
 desc = append_array(desc, _desc)
 ii = append_array(ii, _ii)

 nii = n_elements(ii)


 ;----------------------------------------------------------
 ; accept only latest revision, ignore "improved" versions
 ;----------------------------------------------------------
 wr = (wi = (wp = -1))
 if(keyword_set(type)) then $
  begin
   wr = where(type EQ 'r')
   wi = where(type EQ 'i')
   wp = where(type EQ 'p')
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; change types so they'll sort as desired
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(wr[0] NE -1) then type[wr] = 'b'
 if(wp[0] NE -1) then type[wp] = 'a'
 ww = lindgen(nii)
 if(wi[0] NE -1) then ww = rm_list_item(ww, wi, only='')
 if(size(ww[0], /type) EQ 7) then return, '' $
 else $
  begin
   jd_start = jd_start[ww] & jd_stop = jd_stop[ww]
   type = type[ww] & version = version[ww] & ii = ii[ww] & desc = desc[ww]
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 ; sort list such that latest versions are selected
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
; sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + desc + type + version
 sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type + version

 ss = sort(sort_names)
 ii = ii[ss]
 jd_start = jd_start[ss] & jd_stop = jd_stop[ss]
 type = type[ss] & version = version[ss] & desc = desc[ss]


; sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type + desc
 sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type

 uu = uniq(sort_names)
 ii = ii[uu]
 jd_start = jd_start[uu] & jd_stop = jd_stop[uu] 
 type = type[uu] & version = version[uu] & desc = desc[uu]


 ;--------------------------------------------------------------------
 ; compare dates
 ;--------------------------------------------------------------------
; w = where((jd GE jd_start-djd) AND (jd LE jd_stop+djd))
 w = where((jd_start-djd LT min(jd)) AND (jd_stop+djd GT max(jd)))
 if(w[0] NE -1) then $
  begin 
   ii = ii[w]
   jd_start = jd_start[w] & jd_stop = jd_stop[w]
   type = type[w] & version = version[w] & desc = desc[w]


   ;----------------------------------------------------------------------
   ; sort such that latest versions are last, r kernels after p kernels
   ;----------------------------------------------------------------------
   code = type + version
   ss = sort(code)
   ii = ii[ss]
   jd_start = jd_start[ss] & jd_stop = jd_stop[ss]
   type = type[ss] & version = version[ss] & desc = desc[ss]
   ck_files = all_files[ii]
  end 


; ;---------------------------------------------------------
; ; match kernels whose names start with the image name
; ;---------------------------------------------------------
; if(keyword_set(all_files)) then $
;  begin
;   split_filename, cor_name(dd), dir, name, ext
;   if(keyword_set(name)) then $
;    begin 
;     len = max(strlen(name))
;     _all_names = strmid(all_names, 0, len)
;     w = str_nmatch(_all_names, name)
;     if(w[0] NE -1) then ck_files = append_array(ck_files, all_files[w])
;    end 
;  end


; ;----------------------------------------------------------------------
; ; now move "waypoint" kernels to the very end.
; ;----------------------------------------------------------------------
; if(keyword_set(ck_files)) then $
;  begin
;   p = strpos(strlowcase(ck_files), 'waypoint')
;   ww = where(p NE -1)
;   w = where(p EQ -1)
;   _ck_files = ''
;   if(ww[0] NE -1) then _ck_files = ck_files[ww]
;   if(w[0] NE -1) then _ck_files = append_array(_ck_files, ck_files[w])
;   ck_files = _ck_files
;  end


 ;----------------------------------------------------------
 ; if no kernels found, then return first ck file in order
 ; to avoid naiflib error 
 ;----------------------------------------------------------
 if(NOT keyword_set(ck_files)) then ck_files = all_files[0]

 return, ck_files
end
;=============================================================================









;=============================================================================
; cas_spice_ck_detect
;
; Only kernels whose filenames match the standard convention and whose 
; coverage dates are within djd days of the given image are returned.
;
; The naming scheme is described at :
;   https://cassini.jpl.nasa.gov/cel/cedr/inv/work_area/work_group/spice/
;
; 12/2006: kernels whose names contain the image name are also matched.
;
;=============================================================================
function ____cas_spice_ck_detect, dd, ckpath, djd=djd, time=time, $
                             all=all, strict=strict
;common cas_spice_ck_block, all_files, all_names_block, ckpath_block, $
;      jd_start_block, jd_stop_block, type_block, version_block, desc_block, ii_block

 if(NOT keyword_set(djd)) then djd = 1d			; days, +/-

 label = dat_header(dd)
; all_files = ''
 

 ;--------------------------------
 ; get image jd
 ;--------------------------------
; if(NOT keyword_set(time)) then jd = spice_str2jed(cas_spice_time(label)) $
; else jd = spice_et2jed(time)
 if(NOT keyword_set(time)) then time = cas_spice_time(label)
 jd = spice_et2jed(time)

 jd = jd[0]



 ;--------------------------------
 ; get ck jd's
 ;--------------------------------
 if(keyword_set(ckpath_block)) then $
  if(ckpath NE ckpath_block) then jd_start_block = ''

 if(NOT keyword_set(jd_start_block)) then $
  begin
   all_files = get_all_ck_files(ckpath)
   if(keyword_set(all)) then return, all_files

   ;--------------------------------------------------
   ; get rid of 'waypoint' kernels
   ;--------------------------------------------------
   p = strpos(all_files, 'waypoint')
   w = where(p EQ -1)
   if(w[0] EQ -1) then return, all_files
   all_files = all_files[w]

   split_filename, all_files, dir, all_names
   all_names = str_nnsplit(all_names, '.')


   ;--------------------------------------------------
   ; extract components for each date convention
   ;--------------------------------------------------
   cas_spice_ck_components, all_names, 'yymmdd', ii=_ii, $
     jd_start=_jd_start, jd_stop=_jd_stop, type=_type, version=_version, desc=_desc
   jd_start_block = append_array(jd_start_block, _jd_start)
   jd_stop_block = append_array(jd_stop_block, _jd_stop)
   type_block = append_array(type_block, _type)
   version_block = append_array(version_block, _version)
   desc_block = append_array(desc_block, _desc)
   ii_block = append_array(ii_block, _ii)

   cas_spice_ck_components, all_names, 'yydoy', ii=_ii, $
      jd_start=_jd_start, jd_stop=_jd_stop, type=_type, version=_version, desc=_desc
   jd_start_block = append_array(jd_start_block, _jd_start)
   jd_stop_block = append_array(jd_stop_block, _jd_stop)
   type_block = append_array(type_block, _type)
   version_block = append_array(version_block, _version)
   desc_block = append_array(desc_block, _desc)
   ii_block = append_array(ii_block, _ii)

   ckpath_block = ckpath
   all_names_block = all_names
  end

 jd_start = jd_start_block
 jd_stop = jd_stop_block
 type = type_block
 version = version_block
 desc = desc_block
 ii = ii_block
 all_names = all_names_block

 nii = n_elements(ii)

 ;----------------------------------------------------------
 ; accept only latest revision, ignore "improved" versions
 ;----------------------------------------------------------
 wr = (wi = (wp = -1))
 if(keyword_set(type)) then $
  begin
   wr = where(type EQ 'r')
   wi = where(type EQ 'i')
   wp = where(type EQ 'p')
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; change types so they'll sort as desired
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(wr[0] NE -1) then type[wr] = 'b'
 if(wp[0] NE -1) then type[wp] = 'a'
 ww = lindgen(nii)
 if(wi[0] NE -1) then ww = rm_list_item(ww, wi, only='')
 if(size(ww[0], /type) EQ 7) then return, '' $
 else $
  begin
   jd_start = jd_start[ww] & jd_stop = jd_stop[ww]
   type = type[ww] & version = version[ww] & ii = ii[ww] & desc = desc[ww]
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 ; sort list such that latest versions are selected
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
; sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + desc + type + version
 sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type + version

 ss = sort(sort_names)
 ii = ii[ss]
 jd_start = jd_start[ss] & jd_stop = jd_stop[ss]
 type = type[ss] & version = version[ss] & desc = desc[ss]


; sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type + desc
 sort_names = strtrim(jd_start,2) + '_' + strtrim(jd_stop,2) + type

 uu = uniq(sort_names)
 ii = ii[uu]
 jd_start = jd_start[uu] & jd_stop = jd_stop[uu] 
 type = type[uu] & version = version[uu] & desc = desc[uu]


 ;--------------------------------------------------------------------
 ; compare dates
 ;--------------------------------------------------------------------
 w = where((jd GE jd_start-djd) AND (jd LE jd_stop+djd))
 if(w[0] NE -1) then $
  begin 
   ii = ii[w]
   jd_start = jd_start[w] & jd_stop = jd_stop[w]
   type = type[w] & version = version[w] & desc = desc[w]


   ;----------------------------------------------------------------------
   ; sort such that latest versions are last, r kernels after p kernels
   ;----------------------------------------------------------------------
   code = type + version
   ss = sort(code)
   ii = ii[ss]
   jd_start = jd_start[ss] & jd_stop = jd_stop[ss]
   type = type[ss] & version = version[ss] & desc = desc[ss]
   ck_files = all_files[ii]
  end 


 ;---------------------------------------------------------
 ; match kernels whose names contain the image id string
 ;---------------------------------------------------------
 if(keyword_set(all_files)) then $
  begin
   split_filename, cor_name(dd), dir, name, ext
   if(keyword_set(name)) then $
    begin 
     p = strpos(strupcase(all_names), strupcase(name))
     w = where(p NE -1) 
     if(w[0] NE -1) then ck_files = append_array(ck_files, all_files[w])
    end 
  end


; ;----------------------------------------------------------------------
; ; now move "waypoint" kernels to the very end.
; ;----------------------------------------------------------------------
; if(keyword_set(ck_files)) then $
;  begin
;   p = strpos(strlowcase(ck_files), 'waypoint')
;   ww = where(p NE -1)
;   w = where(p EQ -1)
;   _ck_files = ''
;   if(ww[0] NE -1) then _ck_files = ck_files[ww]
;   if(w[0] NE -1) then _ck_files = append_array(_ck_files, ck_files[w])
;   ck_files = _ck_files
;  end


 ;----------------------------------------------------------
 ; if no kernels found, then return first ck file in order
 ; to avoid naiflib error 
 ;----------------------------------------------------------
 if(NOT keyword_set(ck_files)) then ck_files = all_files[0]


help, ck_files
 return, ck_files
end
;=============================================================================
