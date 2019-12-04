;=============================================================================
;+
; NAME:
;	file_manage
;
;
; PURPOSE:
;	Manages searching and caching of data files.  Files are searched for
;	in the given directories, and once loaded, are cached in memory.
;
;
; CATEGORY:
;	UTIL/EXD
;
;
; CALLING SEQUENCE:
;	data = file_manage(fn, path, filename)
;
;
; ARGUMENTS:
;  INPUT:
;	fn:	Name of function to read the file.  The only argument to
;		this function is the file name, ad it returns a data array.
;
;	path:	Path specifications to use for searching for the file.  All 
;		matching files are read and the data arrays are concatenated.
;
;	filename:	 
;		Name of the file to search for.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	reload:	If set, the file is loaded from disk, even if it is already
;		cached.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Data obtained from the given reader function.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2017
;	
;-
;=============================================================================



;=============================================================================
; cl_cache_put
;
;=============================================================================
pro cl_cache_put, file, dat
common cl_load_block, _catfile, _dat_p

 _catfile = append_array(_catfile, file)
 _dat_p = append_array(_dat_p, nv_ptr_new(dat))

end
;=============================================================================



;=============================================================================
; cl_cache_get
;
;=============================================================================
function cl_cache_get, file, reload=reload, found=found
common cl_load_block, _catfile, _dat_p

 found = 0

 if((NOT keyword_set(_catfile)) OR keyword_set(reload)) then return, ''

 w = where(_catfile EQ file)
 if(w[0] EQ -1) then return, ''
 
 found = 1
 return, *(_dat_p[w[0]])
end
;=============================================================================



;=============================================================================
; file_manage
;
;=============================================================================
function file_manage, fn, catpath, catfile, reload=reload
 
 ;--------------------------------------------------------------------
 ; check the cache, return data if files already cached
 ;--------------------------------------------------------------------
 dat = cl_cache_get(catfile, reload=reload, found=found)
 if(found) then return, dat

 ;--------------------------------------------------------------------
 ; search for files, if none exist, use blank data array
 ;--------------------------------------------------------------------
 catdirs = get_path(catpath, file=catfile)
 if(NOT keyword_set(catdirs[0])) then dat = 0 $
 else $
  begin
   ;- - - - - - - - - - - - -
   ; read the file
   ;- - - - - - - - - - - - -
   files = catdirs + path_sep() + catfile

   for i=0, n_elements(files)-1 do $
                    dat = append_array(dat, call_function(fn, files[i]))
  end

 ;--------------------------------------------------------------------
 ; cache file data
 ;--------------------------------------------------------------------
 cl_cache_put, catfile, dat


 return, dat
end
;=============================================================================
