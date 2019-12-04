;=============================================================================
;+
; NAME:
;	dat_expand
;
;
; PURPOSE:
;	Expands file specifications.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	filenames = dat_expand(filetype, filespec, extension)
;
;
; ARGUMENTS:
;  INPUT:
;	filetype:	File type string from dat_detect_filetype.
;
;	filespec:	Array of file specification strings.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	filetype:	Detecte file type for each returned file.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 4/2018
;	
;-
;=============================================================================
function dat_expand, filetype, filespec

 if(NOT keyword_set(extensions)) then extensions = '' $
 else extensions = unique([extensions, ''])

 query_fn = strlowcase('query_' + filetype)
 if(NOT routine_exists(query_fn)) then query_fn = 'file_search'

 filenames = append_array(filenames, call_function(query_fn, filespec))

 return, filenames
end
;=============================================================================
