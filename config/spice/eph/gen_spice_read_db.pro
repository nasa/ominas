;=============================================================================
; gen_spice_read_db
;
;=============================================================================
function gen_spice_read_db, dbfile

 gen_spice_cache_db, dbfile, db, /get
 if(keyword_set(db)) then return, db

 nv_message, verb=0.9, 'Reading kernel database file ' + dbfile

 ff = file_search(dbfile)
 if(NOT keyword_set(ff)) then return, 0

 
 openr, unit, dbfile, /get_lun

 ndb = 0l
 readu, unit, ndb

 db = replicate({gen_db_struct}, ndb)
 db.filename = string(db.filename, format='(A256)')

 readu, unit, db

 close, unit
 free_lun, unit



 db.filename = strtrim(db.filename,2)
 gen_spice_cache_db, dbfile, db
 return, db
end
;=============================================================================



;=============================================================================
; gen_spice_read_db
;
;=============================================================================
function ___gen_spice_read_db, dbfile

 gen_spice_cache_db, dbfile, db, /get
 if(keyword_set(db)) then return, db

 nv_message, verb=0.9, 'Reading kernel database file ' + dbfile

 ff = file_search(dbfile)
 if(NOT keyword_set(ff)) then return, 0

 tab = read_txt_table(dbfile, delim=',')
 dim = size(tab, /dim)
 count = dim[0]
 db = replicate({gen_db_struct}, count)

 db.filename = tab[*,0]
 db.first = double(tab[*,1])
 db.last = double(tab[*,2])
 db.mtime = double(tab[*,3])
 db.lbltime = double(tab[*,4])
 db.installtime = double(tab[*,5])

 gen_spice_cache_db, dbfile, db
 return, db
end
;=============================================================================
