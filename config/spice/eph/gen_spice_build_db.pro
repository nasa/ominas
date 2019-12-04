;=============================================================================
;+
; NAME:
;       gen_spice_build_db
;
;
; PURPOSE:
;       Read/Build the SPICE kernel database
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       gen_spice_build_db, kpath, data 
;
;
; ARGUMENTS:
;  INPUT:
;       kpath:          Path of the kernel files
;
;	type:		Type of kernel: 'c' or 'sp'.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nocheck:	If set, no checking is performed to determine whether
;			the database file needs to be updated.
;
;  OUTPUT: NONE
;
;
;  RETURN:              Structure that contains:
;                       filename:	Kernel filename
;                       first:		Range start (ET seconds)
;                       last:		Range end (ET seconds)
;                       mtime:		File system date (seconds, OS dependent)
;                       lbltime:	LBL file creation date (seconds ET)
;                       installtime:	OMINAS install timestamp (Julian date)
;			stillThere:	File in database still exists in kpath
;
;
; PROCEDURE:		File unit is allocated for internal use, then released when finished
;                       Checks for existence of database, reads if so
;                       Location of database is in ~/.ominas
;                       Filename is spice_<type>k_database.<kpath with / replaced by _ >
;                       (for a kpath with a wildcard, *, it is replaced by x)
;                       Compares/generates list of filename in kpath
;                       If file system time matches current database, uses that information
;                       Uses spice to calculate the range if so
;                       Calls gen_spice_read_label to read from LBL file for PRODUCT_CREATION_TIME
;                       Calls gen_spice_read_timestamp to read OMINAS timestamp file in ~/.ominas/timestamps
;                       Generates structure of information to return in data (optional if supplied)
;                       Writes database if it did not exist.
;
;
; RESTRICTIONS:
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     V. Haemmerle,  Feb. 2017
;	Addapted by:	J.Spitale      Feb. 2017
;
;-
;=============================================================================



;=============================================================================
; esbd_kcov
;
;  Some files give an error (which is caught below) an must be ignored.
;  One example is 04092_04121ca_ISS.bc
;
;=============================================================================
function esbd_kcov, type, file, id, needav, status=status

 MAXIV      = 1000
 WINSIZ     = 2 * MAXIV

 status = 0

 catch, error
 if(error ne 0) then $
  begin
   catch, /cancel
   status = -1
   return, 0
 end

 cover = cspice_celld(WINSIZ)
 cspice_scard, 0L, cover

 if(type EQ 'sp') then cspice_spkcov, file, id, cover $
 else cspice_ckcov, file, id, needav, 'SEGMENT', 0.D, 'SCLK', cover

 return, cover
end
;=============================================================================



;=============================================================================
; esbd_kobj
;
;=============================================================================
function esbd_kobj, type, file, status=status

 MAXOBJ     = 1000

 status = 0

 catch, error
 if(error ne 0) then $
  begin
   catch, /cancel
   status = -1
   return, 0
 end

 obj = cspice_celli(MAXOBJ)

 call_procedure, 'cspice_' + type + 'kobj', file, obj

 return, obj
end
;=============================================================================



;=============================================================================
; gen_spice_build_db
;
;=============================================================================
function gen_spice_build_db, _kpath, type, nocheck=nocheck

 ;------------------------
 ; Local parameters
 ;------------------------
 SPICEFALSE = 0B
 TIMELEN    = 51
 MAXOBJ     = 1000

 ;-------------------------------------
 ; Generate db filename
 ; replace / with _
 ;-------------------------------------
 kpath = file_search(_kpath)
 fix_path = strjoin(strsplit(kpath,'/',/extract),'_')

 ;-------------------------------------
 ; replace * with x
 ;-------------------------------------
 fix_path = strjoin(strsplit(fix_path,'*',/extract,/preserve_null), 'x')
 dbfile = '~/.ominas/spice_' + type + 'k_database.' + fix_path

 ;-------------------------------------
 ; attempt to read db file
 ;-------------------------------------
 db_files = ''
 db = gen_spice_read_db(dbfile)
 n_db = n_elements(db)
 if(keyword_set(db)) then $
  begin
   db_files_all = db.filename
   db_files = unique(db_files_all)
  end

 ;-------------------------------------
 ; get all filenames
 ;-------------------------------------
 all_files = file_search(kpath + '/*')

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; filter out some common extensions that we know are not kernel files
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 split_filename, all_files, dir, name, ext

 w = where(ext NE 'lbl')
 if(w[0] EQ -1) then return, db
 all_files = all_files[w]

 n_all = n_elements(all_files)

 ;---------------------------------------------------------
 ; if /nocheck, just return the database
 ;---------------------------------------------------------
 if(keyword_set(nocheck)) then return, db

 ;---------------------------------------------------------
 ; compare database files with found files
 ;---------------------------------------------------------
 new_db = 1
 if(NOT keyword_set(db_files)) then wnew = lindgen(n_all) $
 else $
  begin
   new_db = 0
   jj = value_locate(db_files, all_files)        ; find all_files within db_files
   kk = value_locate(all_files, db_files)        ; find db_files within all_files

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   ; check for new kernel files
   ;  New files are ones whose returned interval start subscripts do not
   ;  correspond to existing files; i.e., the interval boundary missed the
   ;  file.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   wnew = unique(append_array(/pos, where(jj EQ -1), $
                                    where(all_files NE db_files[jj])))
   

   ;- - - - - - - - - - - - - - - - -
   ; check for removed kernel files
   ;- - - - - - - - - - - - - - - - -
   wrm = unique(append_array(/pos, where(kk EQ -1), $
                                    where(db_files NE all_files[kk])))

   ;-------------------------------------------
   ; if no changes, return current database
   ;-------------------------------------------
   if((wnew[0] EQ -1) AND (wrm[0] EQ -1)) then return, db

   ;----------------------------------------------------
   ; remove db entries if files have disappeared
   ;----------------------------------------------------
   if(wrm[0] NE -1) then $
    begin
     for i=0, n_elements(wrm)-1 do $
      begin
       w = where(db_files_all EQ db_files[wrm[i]])
       db[w].filename = ''
      end
     w = where(db.filename EQ '')
     db = rm_list_item(db, w, /scalar) 
    end
  end
 if(wnew[0] EQ -1) then n_new = 0


 ;---------------------------------------------------------
 ; add any new files to database 
 ;---------------------------------------------------------
 n_new = n_elements(wnew)
 if(n_new GT 0) then $
  begin

   verb = 'Updating' & explanation = ''
   if(new_db) then $
    begin
     verb = 'Creating'
     explanation = $
        ['This database expedites the search for the appropriate kernels.', $
         'It is only updated when kernels are added or deleted from the kernel', $
         'directory.  The initial creation may take a minute or two.']
    end

   verb = new_db ? 'Creating' : 'Updating'
   nv_message, /con, verb + ' ' + strupcase(type) + ' kernel database...', $
    explanation=explanation

   new_files = all_files[wnew]

   ;---------------------------------------------------
   ; read timestamps files
   ;---------------------------------------------------
   timestamps = gen_spice_read_timestamps(kpath, ts_filenames)

   ;---------------------------------------------------
   ; build new records
   ;---------------------------------------------------
   nullrec = {gen_db_struct}
   nullrec.lbltime = -1
   nullrec.installtime = -1
   nullrec.first = -1
   nullrec.mtime = -1

   for i=0, n_new-1 do $
    begin
     dbrec = !null

     infodat = file_info(new_files[i])
     lbltime = -1
     installtime = -1

     ;------------------------
     ; Find ominas timestamp
     ;------------------------
     index = where(ts_filenames EQ new_files[i], tscount)
     nv_message, /verbose, 'Timestamp index = ' + strtrim(index,2)
     if(tscount EQ 1) then installtime = timestamps[index]

     ;----------------------
     ; Find PDS Label time
     ;----------------------
     creation = gen_spice_read_label(new_files[i])
     if(keyword_set(creation)) then $
      begin
       cspice_tparse, creation, lbl_time, lbl_error
       if lbl_time NE 0 then lbltime = lbl_time
      end

     ;----------------------------------
     ; get ids of all bodies in kernel
     ;----------------------------------
     obj = esbd_kobj(type, new_files[i], status=status)
     if(status EQ 0) then $
      begin
       nobj = cspice_card(obj)

       if(nobj GT 0) then $
        begin
         for j=0, nobj-1 do $
          begin
           id = obj.base[obj.data+j]

           ;----------------------------------------
           ; For each object, collect time windows
           ;----------------------------------------
           cover = esbd_kcov(type, new_files[i], id, SPICEFALSE, status=status)

           ;----------------------------------------
           ; build entries for each coverage window
           ;----------------------------------------
           if(status EQ 0) then $
            begin
             first = (last = '')
             for l=0, n_elements(cover)-1 do $
              begin
               nseg = cspice_wncard(cover[l])
               nv_message, /verbose, 'Number of segments: ' + strtrim(nseg,2)

               dbrec = replicate({gen_db_struct}, nseg)

               ;----------------------------------------
               ; build entries for all segments
               ;----------------------------------------
               for k=0, nseg-1 do $
                begin
                 cspice_wnfetd, cover[l], k, first, last
 
                 nv_message, /verbose, $
                  'Segment ' + strtrim(k,2) + ', begin: '+ strtrim(first,2) + ', end: ' + strtrim(first,2)

                 ;----------------------
                 ; add record
                 ;----------------------
                 dbrec[k].filename = new_files[i]
                 dbrec[k].id = id
                 dbrec[k].first = first
                 dbrec[k].last = last
                 dbrec[k].mtime = infodat.mtime
                 dbrec[k].lbltime = lbltime
                 dbrec[k].installtime = installtime
                end
              end
             dbnew = append_array(dbnew, dbrec)

            end
          end
        end
      end
     ;-----------------------------------------------------------------
     ; if no record, insert a blank one to record that this file has
     ; been looked at
     ;-----------------------------------------------------------------
     if(NOT keyword_set(dbrec)) then $
      begin
       nullrec.filename = new_files[i]
       dbnew = append_array(dbnew, nullrec)
      end

    end
  end


 ;------------------------------
 ; construct new database
 ;------------------------------
 dbnew = append_array(db, dbnew)


 ;----------------------
 ; write database
 ;----------------------
 gen_spice_write_db, dbfile, dbnew


 return, dbnew
end
;=============================================================================
