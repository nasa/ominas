;=============================================================================
;+
; NAME:
;       eph_spice_read_timestamps
;
;
; PURPOSE:
;       Reads an OMINAS install file for kernels for a particular path
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       timetamps = eph_spice_read_timestamps(path, filenames)
;
;
; ARGUMENTS:
;  INPUT:
;       path:		Path of the kernel files
;
;  OUTPUT:
;	filenames:	String array of filenames in path
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:		Timestamps for files in path (JD)
;
;
; PROCEDURE:		Converts path into OMINAS timestamp filename
;			If path contains wildcard, checks for all timestamp files which apply
;                       Reads json files to get filename and timestamp
;                       Returns as two string arrays
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
;	Adapted by:	Spitale        Feb. 2017
;
;-
;=============================================================================
function eph_spice_read_timestamps, path, filenames

 filenames = ''

 ;------------------------
 ; Local parameters
 ;------------------------
 count = 0L
 first = 1

 ;--------------------------------
 ; Generate template filename(s)
 ; replace / with _
 ;--------------------------------
 fix_path = strjoin(strsplit(path,'/',/extract),'_')
 tsfile = '~/.ominas/timestamps/' + fix_path

 ts_files = file_search(tsfile + '.json')
 if(NOT keyword_set(ts_files)) then return, -1

 tscnt = n_elements(ts_files)
 nv_message, /verbose, 'Found ' + strtrim(tscnt,2) + ' timestamp file(s)'


 ;-------------------------
 ; loop over all ts files
 ;-------------------------
 for i=0, tscnt-1 do $
  begin
   js = read_json(ts_files[i]) 
   filenames = append_array(filenames, js.filename)
   timestamps = append_array(timestamps, js.time)
  end


 return, timestamps
end
;=============================================================================
