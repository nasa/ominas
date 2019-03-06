;=============================================================================
;+
; NAME:
;	split_filename
;
;
; PURPOSE:
;	Divides a path in to directory and filename.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	split_filename, filename, dir, name
;
;
; ARGUMENTS:
;  INPUT:
;	filename:	filenames to split
;
;  OUTPUT:
;	dir:	directories
;
;	name:	base filenames
;
;	ext:	If this argument is given, the file extension is returned
;		and the 'name' output contains only the base name without
;		the extension.
;
;
; RETURN:
;	NONE
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2001
;	
;-
;=============================================================================
pro split_filename, filename, dir, name, ext

 sep = path_sep()
 n = n_elements(filename)

 name = filename & dir = make_array(n, val='')


 w = where(strpos(filename, sep) NE -1)
 if(w[0] NE -1) then $
  begin
   ff = str_flip(filename[w])
   front = str_nnsplit(ff, sep, rem=back)
   dir[w] = str_flip(back)
   name[w] = str_flip(front)
  end

 if(arg_present(ext)) then $
  begin
   p = strpos(name, '.', /reverse_search)
   w = where(p EQ -1)
   if(w[0] NE -1) then p[w] = strlen(name[w])

    ext = strmid_11(name, p+1, strlen(name)-p-1)
    name = strmid_11(name, 0, p)
  end


end
;=============================================================================

