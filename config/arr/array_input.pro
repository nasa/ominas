;=============================================================================
;+
; NAME:
;	array_input
;
;
; PURPOSE:
;	Input translator for arrays.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = array_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:  Data descriptor.
;
;	keyword: String giving the name of the translator quantity.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:  Body descriptor
;
;	key2:  Camera descriptor
;
;  OUTPUT:
;	status:  Zero if valid data is returned
;
;
; ENVIRONMENT VARIABLES:
;	NV_ARRAY_DATA:	Sets directory in which to look for data files.
;
;
; TRANSLATOR KEYWORDS:
;	NONE
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
;	Written by: Spitale; 10/2012
; 
;-
;=============================================================================
function array_input, dd, keyword, prefix, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
 end_keywords

 ;--------------------------
 ; verify keyword
 ;--------------------------
 if(keyword NE 'ARR_DESCRIPTORS') then $
  begin
   status = -1
   return, 0
  end


 ;----------------------------------------------
 ; check array catalog
 ;----------------------------------------------
 catpath = getenvs('NV_ARRAY_DATA')
 if(NOT keyword_set(catpath)) then $
  begin
   nv_message, /con, $
     'NV_ARRAY_DATA environment variable is undefined.', $
       exp=['NV_ARRAY_DATA specifies the directory under which this translator', $
            'searches for data files.']
   status = -1
   return, 0
  end


 status = 0


 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------
 select_all = dat_keyword_value(dd, 'all')
 reload = dat_keyword_value(dd, 'reload')
 names = str_nsplit(dat_keyword_value(dd, 'name'), ';')
 primaries = str_nsplit(dat_keyword_value(dd, 'primary'), ';')
 if(NOT keyword_set(names[0])) then names= '' $
 else select_all = 1


 ;-----------------------------------------------
 ; observer descriptor passed as key1
 ;-----------------------------------------------
 if(keyword_set(key1)) then od = key1
; if(NOT keyword_set(od)) then nv_message, 'No observer.'

 ;-----------------------------------------------
 ; primary descriptor passed as key2
 ;-----------------------------------------------
 if(keyword_set(key2)) then bx = key2

 ;-----------------------------------------------
 ; array names passed as key8
 ;-----------------------------------------------
 if(keyword_set(key8) AND (NOT keyword_set(names))) then names = key8


 ;-----------------------------------------------
 ; set up array descriptors
 ;-----------------------------------------------
 if(keyword_set(bx)) then xd = bx $
 else if(keyword_set(od)) then xd = od $
 else nv_message, 'No primary descriptor.'

 n = n_elements(xd)
 for i=0, n-1 do $
  begin
   _ards = 0
   primary = cor_name(xd[i])

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; read relevant array catalogs
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   sep = path_sep()
   dir = catpath + sep + strlowcase(primary) + sep
   files = file_search(dir + '*.arr')
   split_filename, files, dirs, files

   if(keyword_set(files)) then $
    begin
     nfiles = n_elements(files)

     if(NOT keyword_set(select_all)) then $ 
      if(keyword_set(names)) then $
       begin
        split_filename, files, _dir, name, ext
        w = nwhere(strupcase(name), strupcase(names))
        nfiles = n_elements(w)
        if(w[0] NE -1) then files = files[w] $
        else nfiles = 0
       end

     for j=0, nfiles-1 do $
      begin
       dat = file_manage('arr_read', dir, files[j], reload=reload)
       split_filename, files[j], _dir, name, ext

       if(keyword_set(dat)) then $
        begin
         ;- - - - - - - - - - - - - - - - - - - - - - - -
         ; construct descriptors
         ;- - - - - - - - - - - - - - - - - - - - - - - -
         _ards = arr_create_descriptors(gd=cor_create_gd(cor_gd(xd[i]), bx0=xd[i]))

         cor_set_name, _ards, name
         arr_set_surface_pts, _ards, dat
        end
       ards = append_array(ards, _ards)
      end
    end
  end


 if(NOT keyword_set(ards)) then $
  begin
   status = -1
   return, 0
  end


 return, ards
end
;===========================================================================



