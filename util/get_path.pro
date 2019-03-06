;=============================================================================
;+
; NAME:
;	get_path
;
;
; PURPOSE:
;	Obtains a path list from a specified path variable using the 
;	same syntax used for IDL paths.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	paths = get_path(path)
;
;
; ARGUMENTS:
;  INPUT:
;	path:	 Strings giving path specifications.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	extesion:	File extension to match.  If given, only directories
;		 	containing files of this type are returned.
;
;	file:		File name to match.  If given, only directories
;			containing files with this name are returned.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	An array of directories produced by expanding the value of the
;	given path using the IDL path syntax.  See the IDL routine
;	EXPAND_PATH.  The result is narrowed based on the EXTENSION and
;	FILE keywords, if present.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2011
;	
;-
;=============================================================================
function get_path, path, extesion=extesion, file=file

 for i=0, n_elements(path)-1 do $
        dirs = append_array(dirs, expand_path(path[i], /all, /array))

 match = ''

 if(keyword_set(extension)) then match = '*.' + extension $
 else if(keyword_set(file)) then match = file

 result = dirs
 if(keyword_set(match)) then $
  begin
   result = ''
   for i=0, n_elements(dirs)-1 do $
    begin
     ff = findfile(dirs[i] + path_sep() + match)
     if(keyword_set(ff[0])) then result = append_array(result, dirs[i])
    end
  end

 return, result
end
;===========================================================================
