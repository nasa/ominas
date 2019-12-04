;=============================================================================
; gen_spice_write_db
;
;=============================================================================
pro gen_spice_write_db, dbfile, db, nosort=nosort

 nv_message, verb=0.9, 'Writing kernel data base file ' + dbfile

 ;---------------------------------------------------------------------------
 ; sort by file name to make searching on file names easier
 ;---------------------------------------------------------------------------
; ss = sort(db.filename)
; db = db[ss]

 ;---------------------------------------------------------------------------
 ; strings need to all be the same length for the file to be read correctly
 ;---------------------------------------------------------------------------
 db.filename = string(db.filename, format='(A256)')

 ;---------------------------------------------------------------------------
 ; write the data
 ;---------------------------------------------------------------------------
 openw, unit, dbfile, /get_lun

; need to write a byteorder test number...

 writeu, unit, long(n_elements(db))
 writeu, unit, db

 close, unit
 free_lun, unit

 ;---------------------------------------------------------------------------
 ; unpad the file names
 ;---------------------------------------------------------------------------
 db.filename = strtrim(db.filename,2)

 gen_spice_cache_db, dbfile, db
end
;=============================================================================



;=============================================================================
; gen_spice_write_db
;
;=============================================================================
pro ___gen_spice_write_db, dbfile, db

 nv_message, verb=0.9, 'Writing kernel data base file ' + dbfile

 format = '(F20.3)'
 tab = transpose( $
         [transpose([db.filename]), $
          transpose([string(db.first, format=format)]), $
          transpose([string(db.last, format=format)]), $
          transpose([string(db.mtime, format=format)]), $
          transpose([string(db.lbltime, format=format)]), $
          transpose([string(db.installtime, format=format)])])

 write_txt_table, dbfile, tab, delim=','
 gen_spice_cache_db, dbfile, db

end
;=============================================================================
