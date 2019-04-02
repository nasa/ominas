;=============================================================================
; si_get_kernels_to_load
;
;=============================================================================
function si_get_kernels_to_load, k_in, loaded_kernels, reload=reload, $
                    explicit=explicit

 ;-----------------------------------------------------------------
 ; if /reload, just specify all k_in to be loaded and return
 ;-----------------------------------------------------------------
 if(keyword_set(reload)) then return, k_in

 ;------------------------------------------------------------
 ; if no kernels given, or none loaded, then return all k_in
 ;------------------------------------------------------------
 if((NOT keyword_set(loaded_kernels)) OR (NOT keyword_set(k_in))) then $
                                                                 return, k_in


 ;----------------------------------------------------------------------
 ; if any k_in not loaded, then return all k_in so as to maintain the
 ; correct precedence order for this group of kernels
 ;----------------------------------------------------------------------
 ii = nwhere(k_in, loaded_kernels)
 if(ii[0] EQ -1) then return, k_in
 if(n_elements(ii) NE n_elements(k_in)) then return, k_in
 return, ''




; ;--------------------------------------------
; ; determine which kernels are new  
; ;--------------------------------------------
; ii = complement(k_in, nwhere(k_in, loaded_kernels))
; if(ii[0] EQ -1) then kernels_to_load = '' $
; else kernels_to_load = k_in[ii]


; ;--------------------------------------------------------------------
; ; if there are kernels_to_load, then make sure any explicit kernels
; ; get unloaded and reloaded so that they maintain their precedence
; ;--------------------------------------------------------------------
; if(keyword_set(kernels_to_load) AND keyword__set(explicit)) then $
;                            kernels_to_load = [kernels_to_load, explicit]


 ;return, kernels_to_load
end
;=============================================================================



;=============================================================================
; si_protect_kernels
;
;=============================================================================
function si_protect_kernels, _kernels, specs

 split_filename, _kernels, dirs, kernels

 nspecs = n_elements(specs)

 for i=0, nspecs-1 do $
  begin
   spec = specs[i]

   neg = 0
   if(strmid(spec, 0, 1) EQ '!') then $
    begin
     neg = 1
     spec = strmid(spec, 1, strlen(spec)-1)
    end

   match = stregex(kernels, spec, /boolean)

   if(neg) then $
    begin
     w = nwhere(kernels, match)
     if(w[0] NE -1) then $
      begin
       kernels = kernels[w]
       dirs= dirs[w]
      end $
     else kernels = (dirs = '')
    end $
   else if(keyword_set(match)) then $
    begin
     w = nwhere(kernels, match)
     if(w[0] NE -1) then $
      begin
       kernels = rm_list_item(kernels, w, only='')
       dirs = rm_list_item(dirs, w, only='')
      end
    end
  end
 
 return, dirs + path_sep() + kernels
end
;=============================================================================



;=============================================================================
; spice_sort_kernels
;
;=============================================================================
pro spice_sort_kernels, all_kernels, $
  reload=reload, reverse=reverse, protect=protect, $
  k_in=k_in, ck_in=ck_in, spk_in=spk_in, pck_in=pck_in, $
  fk_in=fk_in, ik_in=ik_in, sck_in=sck_in, lsk_in=lsk_in, xk_in=xk_in, $
  ck_exp=ck_exp, spk_exp=spk_exp, pck_exp=pck_exp, $
  fk_exp=fk_exp, ik_exp=ik_exp, sck_exp=sck_exp, lsk_exp=lsk_exp, xk_exp=xk_exp, $
  kernels_to_load=kernels_to_load, kernels_to_unload=kernels_to_unload, $
  ck_reverse=_ck_reverse, spk_reverse=_spk_reverse, pck_reverse=_pck_reverse, $
  fk_reverse=_fk_reverse, ik_reverse=_ik_reverse, sck_reverse=_sck_reverse, $
  lsk_reverse=_lsk_reverse, xk_reverse=_xk_reverse, strict_priority=strict_priority

 all_kernels = append_array(all_kernels, ck_in)
 all_kernels = append_array(all_kernels, spk_in)
 all_kernels = append_array(all_kernels, pck_in)
 all_kernels = append_array(all_kernels, fk_in)
 all_kernels = append_array(all_kernels, ik_in)
 all_kernels = append_array(all_kernels, sck_in)
 all_kernels = append_array(all_kernels, lsk_in)
 all_kernels = append_array(all_kernels, xk_in)


 kernels_to_load = (kernels_to_unload = '')
 if(keyword_set(all_kernels)) then $
  begin
;   loaded_kernels = spice_loaded(/full)
   loaded_kernels = spice_loaded(/verb)

   if(keyword_set(reload)) then $
    begin
     kernels_to_load = all_kernels
     kernels_to_unload = loaded_kernels
    end $
   else $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - -
     ; determine kernels to load, one type at a time
     ;- - - - - - - - - - - - - - - - - - - - - - - - - -
     k_to_load = ''
     ck_to_load = ''
     spk_to_load = ''
     pck_to_load = ''
     fk_to_load = ''
     ik_to_load = ''
     sck_to_load = ''
     lsk_to_load = ''
     xk_to_load = ''

     if(keyword_set(k_in)) then k_to_load = $
       si_get_kernels_to_load(k_in, loaded_kernels, reload=reload)
     if(keyword_set(ck_in)) then ck_to_load = $
       si_get_kernels_to_load(ck_in, loaded_kernels, reload=reload, exp=ck_exp)
     if(keyword_set(spk_in)) then spk_to_load = $
       si_get_kernels_to_load(spk_in, loaded_kernels, reload=reload, exp=spk_exp)
     if(keyword_set(pck_in)) then pck_to_load = $
       si_get_kernels_to_load(pck_in, loaded_kernels, reload=reload, exp=pck_exp)
     if(keyword_set(fk_in)) then fk_to_load = $
       si_get_kernels_to_load(fk_in, loaded_kernels, reload=reload, exp=fk_exp)
     if(keyword_set(ik_in)) then ik_to_load = $
       si_get_kernels_to_load(ik_in, loaded_kernels, reload=reload, exp=ik_exp)
     if(keyword_set(sck_in)) then sck_to_load = $
       si_get_kernels_to_load(sck_in, loaded_kernels, reload=reload, exp=sck_exp)
     if(keyword_set(lsk_in)) then lsk_to_load = $
       si_get_kernels_to_load(lsk_in, loaded_kernels, reload=reload, exp=lsk_exp)
     if(keyword_set(xk_in)) then xk_to_load = $
       si_get_kernels_to_load(xk_in, loaded_kernels, reload=reload, exp=xk_exp)

     ck_reverse = keyword_set(_ck_reverse) OR keyword_set(reverse)
     spk_reverse = keyword_set(_spk_reverse) OR keyword_set(reverse)
     pck_reverse = keyword_set(_pck_reverse) OR keyword_set(reverse)
     fk_reverse = keyword_set(_fk_reverse) OR keyword_set(reverse)
     ik_reverse = keyword_set(_ik_reverse) OR keyword_set(reverse)
     sck_reverse = keyword_set(_sck_reverse) OR keyword_set(reverse)
     lsk_reverse = keyword_set(_lsk_reverse) OR keyword_set(reverse)
     xk_reverse = keyword_set(_xk_reverse) OR keyword_set(reverse)
 
     if(keyword_set(ck_to_load) AND (keyword_set(ck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, ck_to_load)
     if(keyword_set(spk_to_load) AND (keyword_set(spk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, spk_to_load)
     if(keyword_set(pck_to_load) AND (keyword_set(pck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, pck_to_load)
     if(keyword_set(fk_to_load) AND (keyword_set(fk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, fk_to_load)
     if(keyword_set(ik_to_load) AND (keyword_set(ik_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, ik_to_load)
     if(keyword_set(sck_to_load) AND (keyword_set(sck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, sck_to_load)
     if(keyword_set(lsk_to_load) AND (keyword_set(lsk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, lsk_to_load)
     if(keyword_set(xk_to_load) AND (keyword_set(xk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, xk_to_load)

     if(keyword_set(k_to_load)) then $
                   kernels_to_load = append_array(kernels_to_load, k_to_load)

     if(keyword_set(ck_to_load) AND (NOT keyword_set(ck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, ck_to_load)
     if(keyword_set(spk_to_load) AND (NOT keyword_set(spk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, spk_to_load)
     if(keyword_set(pck_to_load) AND (NOT keyword_set(pck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, pck_to_load)
     if(keyword_set(fk_to_load) AND (NOT keyword_set(fk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, fk_to_load)
     if(keyword_set(ik_to_load) AND (NOT keyword_set(ik_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, ik_to_load)
     if(keyword_set(sck_to_load) AND (NOT keyword_set(sck_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, sck_to_load)
     if(keyword_set(lsk_to_load) AND (NOT keyword_set(lsk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, lsk_to_load)
     if(keyword_set(xk_to_load) AND (NOT keyword_set(xk_reverse))) then $
                   kernels_to_load = append_array(kernels_to_load, xk_to_load)


     loaded_kernels = clean_fnames(loaded_kernels)
     all_kernels = clean_fnames(all_kernels)
     kernels_to_load = clean_fnames(kernels_to_load)
     kernels_to_unload = clean_fnames(kernels_to_unload)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; determine kernels to unload 
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     split_filename, loaded_kernels, dir, loaded_names
     split_filename, all_kernels, dir, all_names
     split_filename, kernels_to_load, dir, names_to_load

     ;...................................................................
     ;  Any loaded_kernels not appearing in all_kernels will be unloaded.
     ;...................................................................
     ii = complement(loaded_names, nwhere(loaded_names, all_names))
     if(ii[0] EQ -1) then kernels_to_unload = '' $
     else kernels_to_unload = loaded_kernels[ii]

     ;...................................................................
     ;  Any kernels appearing in kernels_to_load and loaded_kernels
     ;  will be unloaded so they can be reloaded at the end of the list.
     ;...................................................................
     ii = nwhere(names_to_load, loaded_names)
     if(ii[0] NE -1) then $
      begin
       if(keyword_set(strict_priority)) then $
        kernels_to_unload = append_array(kernels_to_unload, kernels_to_load[ii]) $
       else kernels_to_load = rm_list_item(kernels_to_load, ii, only='')
      end
    end 

   ;- - - - - - - - - - - - - - - - - - 
   ; remove any null filenames
   ;- - - - - - - - - - - - - - - - - - 
   w = where(strtrim(kernels_to_load,2) NE '')
   if(w[0] NE -1) then kernels_to_load = kernels_to_load[w]
   w = where(strtrim(kernels_to_unload,2) NE '')
   if(w[0] NE -1) then kernels_to_unload = kernels_to_unload[w]
   
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; remove any duplicate kernels, keeping only the latest occurrence
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   split_filename, kernels_to_load, dir, names_to_load
   ss = sort(names_to_load)
   uu = uniq(names_to_load[ss])
   sss = sort(ss[uu])
   kernels_to_load = kernels_to_load[(ss[uu])[sss]]
  end

 if(n_elements(kernels_to_load) EQ 1) then kernels_to_load = kernels_to_load[0]
 if(n_elements(kernels_to_unload) EQ 1) then $
                                       kernels_to_unload = kernels_to_unload[0]


 ;-----------------------------------------
 ; apply the "protect" keyword
 ;-----------------------------------------
 if(keyword_set(protect)) then $
  begin
   specs = str_nsplit(protect, ';')

   kernels_to_load = si_protect_kernels(kernels_to_load, specs)
   kernels_to_unload = si_protect_kernels(kernels_to_unload, specs)
  end

;print, kernels_to_unload
end
;=============================================================================

