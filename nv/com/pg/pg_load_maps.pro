;=============================================================================
;+
; NAME:
;	pg_load_maps
;
;
; PURPOSE:
;	Loads maps and descriptors from a map directory.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	ddmap = pg_load_maps(md=md)
;
;
; ARGUMENTS:
;  INPUT: 
;	dir :   Top directory for map library.  If not set, the directory
;		is obtained from the PG_MAPS environment varable.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	bx:	Body descriptors indicating which maps to load.
;
;	projection:
;		If set, only maps with this projection will be returned.
;
;
;  OUTPUT: 
;	md:	Map descriptor for each map.
;
;
; ENVIRONMENT VARIABLES:
;	PG_MAPS:
;		Sets the map directory; overrides the dir keyword.  Maps are 
;		organized into subdirectories named for each body.  
;
;
; RETURN: 
;	Data descriptor containing the rendered image.
;
;
; PROCEDURE:
;	
;
;
; EXAMPLE:
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale  7/2015
;	
;-
;=============================================================================
function pg_load_maps, mapdir, md=mds, bx=bx, dd=dd, projection=projection
common pg_load_maps_block, dd_cache, md_cache

 dds = (mds = !null)

 ;--------------------------------------------------------------
 ; get map directory
 ;--------------------------------------------------------------
 if(NOT keyword_set(mapdir)) then mapdir = getenv('PG_MAPS')
 if(NOT keyword_set(mapdir)) then $
  begin
   nv_message, /con, 'Map directory not specified.', $
       exp=['The map directory may be specified as the argument to this program', $
            'or via the PG_MAPS environment variable.']
   return, 0
  end 


 ;--------------------------------------------------------------
 ; determine map files
 ;--------------------------------------------------------------
 names = cor_name(bx)
 dirs = file_search(mapdir + '/*/*', /test_dir)
 name = file_basename(dirs)

 w = nwhere(strupcase(name), strupcase(names))
 if(w[0] EQ -1) then return, dds

 dirs = dirs[w]
 files = file_search(dirs + '/*.*')
 split_filename, files, a, b,  ext
 w = where(ext NE 'dh')
 if(w[0] EQ -1) then return, 0
 files = files[w]

 ;--------------------------------------------------------------
 ; check whether any maps need to be loaded
 ;--------------------------------------------------------------
 if(keyword_set(dd_cache)) then $
;if(0) then $
  begin
   fnames = file_basename(files)
   fnames_cache = cor_name(dd_cache)
   w = nwhere(fnames, fnames_cache, rev=ww) 

   if(w[0] NE -1) then $
    begin
     dds = dd_cache[ww]
     mds = md_cache[ww]

     ww = complement(names, w)
     if(ww[0] EQ -1) then return, dds
     files = files[ww]
    end
  end

 ;------------------------------------------------------------------
 ; load map files
 ;  The files are not actually loaded, as indicated by maintain=1.
 ;  They will be loaded when accessed.  Only the detached headers 
 ;  are loaded.
 ;-----------------------------------------------------------------
 dd = dat_read(files, maintain=1)
 if(NOT keyword_set(dd)) then return, dds

 ;--------------------------------------------------------------
 ; get map descriptors
 ;--------------------------------------------------------------
 nmap = n_elements(dd)
 md = objarr(nmap)
 for i=0, nmap-1 do md[i] = pg_get_maps(dd[i])

 w = where(obj_valid(md))
 if(w[0] EQ -1) then return, dds

 md = md[w]
 dd = dd[w]

 ;--------------------------------------------------------------
 ; select by projection
 ;--------------------------------------------------------------
 if(keyword_set(projection)) then $
  begin
   w = where(map_projection(md) EQ strupcase(projection))
   if(w[0] EQ -1) then return, dds
   md = md[w]
   dd = dd[w]
  end

 ;--------------------------------------------------------------
 ; cache and return maps
 ;--------------------------------------------------------------
 md_cache = append_array(md_cache, md)
 dd_cache = append_array(dd_cache, dd)

 mds = append_array(mds, md)
 dds = append_array(dds, dd)
 return, dds
end
;=============================================================================
