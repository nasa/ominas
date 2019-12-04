;=============================================================================
; gen_spice_pck_detect
;
;
;=============================================================================
function gen_spice_pck_detect, dd, kpath, sc=sc, time=time, strict=strict, all=all

 kernels = ''

 ;--------------------------------
 ; new naming convention
 ;--------------------------------
 all_files = file_search(kpath + 'cpck*.tpc')
 if(keyword__set(all_files)) then $
  begin
   if(keyword__set(all)) then kernels = append_array(kernels, all_files)

   split_filename, all_files, dir, all_names
   w = where(strlen(all_names) EQ 17)

   if(w[0] NE -1) then $
    begin
     all_names = all_names[w] & all_files = all_files[w]
     dates = strmid(all_names, 4, 9)
     jd = ddmmmyyyy_to_jd(dates)
     w = where(jd EQ max(jd))
     kernels = append_array(kernels, all_files[w])
    end
  end

 ;--------------------------------
 ; old naming convention
 ;--------------------------------
 all_files = file_search(kpath + 'pck*.tpc')
 if(keyword__set(all_files)) then $
  begin
   split_filename, all_files, dir, all_names
   w = where(strlen(all_names) EQ 12)

   if(w[0] NE -1) then $
    begin
     all_names = all_names[w] & all_files = all_files[w]
     versions = long(strmid(all_names, 3, 5))
     w = where(versions EQ max(versions))
     kernels = append_array(kernels, all_files[w])
    end

  end

 
; if(NOT keyword_set(kernels)) then $
;                  nv_message,'No kernel files found in ' + kpath + '.'


 return, kernels
end
;=============================================================================
