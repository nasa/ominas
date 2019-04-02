;=============================================================================
;+
; NAME:
;       bat_expand
;
; PURPOSE:
;       Expands file specifications using read_txt_file.  Also, defines
;	global keywords for OMINAS shell commands.
;
;	  
; CATEGORY:
;       BAT
;
;
; CALLING SEQUENCE:
;       filespecs = bat_expand(list, path, sample, select)
;
;
; ARGUMENTS:
;  INPUT: 
;	list:	String array giving names of files to be read using
;	             	read_txt_file.  
;
;	path:	 	File list path.
;
;	sample:   	File list sampling; see read_txt_file.
;
;	select:   	File list selection criterion; see read_txt_file.
;
;  OUTPUT: NONE
;
;
; KEYWORDS: NONE
;
;
; RETURN:
;	String array giving the concatanated results of reading every 
;	input file, subject to the rules of read_txt_file.  Note that
;	the special keyowrds 'file_sample' and 'file_select' are detected
;	and passed to read_txt_file.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function bat_expand, filespecs, list, path, sample, select

 ;----------------------------------------------------------------
 ; expand file specs
 ;----------------------------------------------------------------
 if(keyword_set(list)) then $
  for i=0, n_elements(list)-1 do $
       filespecs = append_array(filespecs, $
          decrapify(read_txt_file(list[i], sample=sample, select=select)))

 if(NOT keyword_set(filespecs)) then return, ''
 return, path + filespecs
end
;==============================================================================
