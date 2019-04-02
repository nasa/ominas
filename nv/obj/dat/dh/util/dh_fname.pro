;=============================================================================
; dhfn_filename
;
;=============================================================================
function dhfn_filename, raw_filename

 filename = raw_filename

 ;------------------------------------------------------------------------
 ; This set should be pretty portable...
 ;------------------------------------------------------------------------
 valid = [byte('/'), $
          byte('\'), $
          byte('-'), $
          byte('_'), $
          byte('.'), $
          bindgen(byte('z') - byte('a') + 1) + (byte('a'))[0], $
          bindgen(byte('Z') - byte('A') + 1) + (byte('A'))[0], $
          bindgen(byte('9') - byte('0') + 1) + (byte('0'))[0] $
          ]

 ;------------------------------------------------------------------------
 ; If directory delimeters are present, check whether they refer to an
 ; existing directory.  If not, then remove them from the list of
 ; valid characters.
 ;------------------------------------------------------------------------
 dir = file_dirname(filename)
 dir = file_search(dir, /test_dir)
 if(NOT keyword_set(dir)) then valid = valid[2:*] $
 else filename = file_basename(filename)

 ;------------------------------------------------------------------------
 ; replace any invalid characters with '_'
 ;------------------------------------------------------------------------
 bname = byte(filename)

 nvalid = n_elements(valid)
 n = n_elements(bname)

 diff = (valid # make_array(n, val=1)) $
          - (bname ## make_array(nvalid, val=1))

 bdiff = diff NE 0
 w = where(total(bdiff,1) EQ nvalid)

 if(w[0] NE -1) then bname[w] = byte('_')
 return, dir + path_sep() + string(bname)
end
;=============================================================================



;=============================================================================
; dhfn_findfile
;
;=============================================================================
function dhfn_findfile, dir, name, ext

 sep = path_sep()

 ;---------------------------------------------------------------
 ; try replacing existing extension
 ;---------------------------------------------------------------
 ff = file_search(dir + sep + name + '.dh')
 if(keyword_set(ff)) then return, ff

 ;---------------------------------------------------------------
 ; try just adding .dh extension
 ;---------------------------------------------------------------
 if(keyword_set(ext)) then ff = findfile(dir + sep + name + '.' + ext + '.dh')
 if(keyword_set(ff)) then return, ff

 return, ''
end
;=============================================================================



;=============================================================================
; dh_fname.pro
;
;=============================================================================
function dh_fname, raw_filename, write=write

 ;----------------------------------------------------
 ; check for DH_PATH
 ;----------------------------------------------------
 path = getenv('DH_PATH')


 ;---------------------------------------------------------------
 ; create a file-system-compliant basename
 ;---------------------------------------------------------------
 filename = dhfn_filename(raw_filename)
 split_filename, filename, dir, full_name
 split_filename, filename, dir, name, ext
 if(NOT keyword_set(dir[0])) then dir = './'


 ;----------------------------------------------------------------------------
 ; if creating a new dh, put it in the same directory as the file, or 
 ; in the path, if one exists.  Add '.dh'
 ;----------------------------------------------------------------------------
 outdir = dir
 if(keyword_set(path)) then outdir = path $
 else path = './'
 if(keyword_set(write)) then return, outdir + path_sep() + full_name + '.dh'


 ;------------------------------------------------------------------
 ; Otherwise try various possibilities to find an existing dh file
 ;------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - -
 ; try same directory as the data file
 ;- - - - - - - - - - - - - - - - - - -
 ff = dhfn_findfile(dir, name, ext)
 if(keyword_set(ff)) then return, ff

 ;- - - - - - - - - - - - - - - - - - -
 ; try path directory
 ;- - - - - - - - - - - - - - - - - - -
 ff = dhfn_findfile(path, name, ext)
 if(keyword_set(ff)) then return, ff


 return, ''
end
;=============================================================================


