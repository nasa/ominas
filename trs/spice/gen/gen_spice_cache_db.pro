;=============================================================================
; gen_spice_cache_db
;
;=============================================================================
pro gen_spice_cache_db, dbfile, db, get=get
common gen_spice_cache_db_block, cached_dbs

 ;----------------------------------------------
 ; initialize cache
 ;----------------------------------------------
 if(NOT keyword_set(cached_dbs)) then cached_dbs = {gen_db_cache_struct}

 nv_message, verb=0.9, 'Cached kernel databases:'
 if(n_elements(cached_dbs) GT 1) then $
      nv_message, verb=0.9, /anonymous, ' ' + transpose([cached_dbs[1:*].filename]) $
 else nv_message, verb=0.9, /anonymous, 'None.'

 ;----------------------------------------------
 ; look for existing entry
 ;----------------------------------------------
 w = where(cached_dbs.filename EQ dbfile)

 ;----------------------------------------------
 ; return with result if /get
 ;----------------------------------------------
 if(keyword_set(get)) then $
  begin
   if(w[0] NE -1) then db = *cached_dbs[w].dbp
   return
  end

 cached_db = {gen_db_cache_struct, filename:dbfile, dbp:nv_ptr_new(db)}


 ;----------------------------------------------
 ; replace or append
 ;----------------------------------------------
 if(w[0] NE -1) then cached_dbs[w] = cached_db $
 else cached_dbs = append_array(cached_dbs, cached_db)

end
;=============================================================================
