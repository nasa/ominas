;=============================================================================
;+-+
; NAME:
;	rim
;
;
; PURPOSE:
;	Prints the headers, or specific header values, for the specified files.
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	rim, files
;
;
; ARGUMENTS:
;  INPUT:
;	files:	List of filenames and file specifications.  Only files whose
;		filetypes can be detected are loaded.  An array of
;		data descriptors may also be specified.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	keywords:	String array giving keywords for which values are
;			desired.  Results are filetype-dependent.  If keywords
;			are specfied, the results are printed as a table.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	NONE
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================



;=============================================================================
; rim
;
;=============================================================================
pro rim, files, keywords=keywords

 if(NOT keyword_set(files)) then return

 sep = path_sep()

 ;---------------------------------------------------------
 ; resolve any file specifications and determine filetypes
 ;---------------------------------------------------------
 if(size(files, /type) EQ 7) then $
  begin
   for i=0, n_elements(files)-1 do $
    begin
     if(strpos(files[i], sep) EQ -1) then files[i] = pwd() + sep + files[i]
     ff = file_search(files[i])
     if(keyword_set(ff)) then _files = append_array(_files, ff)
    end
   if(NOT keyword_set(_files)) then return
   files = _files

   w = where(files NE '')
   if(w[0] EQ -1) then return
   files = files[w]

   w = where(strpos(files,':') EQ -1)
   if(w[0] EQ -1) then return
   files = files[w]

   w = where(strpos(files,sep) NE -1)
   if(w[0] EQ -1) then return
   files = files[w]

   nfiles = n_elements(files)
   unknown = lonarr(nfiles)
   for i=0, nfiles-1 do $
           if(dat_detect_filetype(files[i]) EQ '') then unknown[i] = 1

   w = where(unknown EQ 1)
   if(w[0] NE -1) then $
    begin
     files = rm_list_item(files, w, only='')
     if(keyword_set(labels)) then labels = rm_list_item(labels, w, only='')
     if(keyword_set(ids)) then ids = rm_list_item(ids, w)
    end
   if(NOT keyword_set(files)) then return

   split_filename, files, dirs, names
   labels = names  
  end


 ;----------------------------------
 ; read files if necessary
 ;----------------------------------
 if(size(files, /type) NE 7) then dd = files $
 else dd = dat_read(files, maintain=2)

 ndd = n_elements(dd)


 ;----------------------------------
 ; print output
 ;----------------------------------
 nkey = n_elements(keywords)
 if(nkey NE 0) then values = strarr(nkey)

 for i=0, ndd-1 do $
  begin
   if(nkey EQ 0) then print, $
      transpose([' ', cor_name(dd[i]) + ':', dat_header(dd[i])]) $
   else $
    begin
     for j=0, nkey-1 do $
      begin
       dat_header_value, dd[i], keywords[j], get=val
       values[j] = str_comma_list(val)
      end
     print, cor_name(dd[i]) + ': ' + str_comma_list(values, delim=' ')
    end
  end




end
;=============================================================================
