;=============================================================================
;+
; NAME:
;	station_input
;
;
; PURPOSE:
;	Input translator for planet-based stations.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = station_input(dd, keyword)
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
;	key2:  Primary body descriptor
;
;  OUTPUT:
;	status:  Zero if valid data is returned
;
;
; ENVIRONMENT VARIABLES:
;	NV_STATION_DATA:	Sets the directory in which to look for data 
;				files.
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
;	Written by: Spitale; 7/2007
; 
;-
;=============================================================================
function station_input, dd, keyword, prefix, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
 end_keywords

 ;--------------------------
 ; verify keyword
 ;--------------------------
 if(keyword NE 'STN_DESCRIPTORS') then $
  begin
   status = -1
   return, 0
  end


 ;----------------------------------------------
 ; check station catalog
 ;----------------------------------------------
 catpath = getenvs('NV_STATION_DATA')
 if(NOT keyword_set(catpath)) then $
  begin
   nv_message, /con, $
     'NV_STATION_DATA environment variable is undefined.'
       exp=['NV_STATION_DATA specifies the directory under which this translator', $
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
 if(NOT keyword_set(names)) then names= '' $
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
 ; station names passed as key8
 ;-----------------------------------------------
 if(keyword_set(key8) AND (NOT keyword_set(names))) then names = key8

 ;-----------------------------------------------
 ; set up station descriptors
 ;-----------------------------------------------
 if(keyword_set(bx)) then xd = bx $
 else if(keyword_set(od)) then xd = od $
 else nv_message, 'No primary descriptor.'

 n = n_elements(xd)
 for i=0, n-1 do $
  begin
   _stds = 0
   primary = cor_name(xd[i])

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; read relevant station catalog
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   catfile = 'stations_' + strlowcase(primary) + '.txt'
   dat = file_manage('station_read', catpath, catfile, reload=reload)

   if(keyword_set(dat)) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; if any requested names, select only those
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     continue = 1
     if(keyword_set(names)) then $
      begin
       ww = append_array(ww, nwhere(strupcase(dat.name), strupcase(names)))
       www = where(ww NE -1)
       if(www[0] EQ -1) then continue = 0 $
       else dat = dat[ww[www]]
      end

     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; construct descriptors
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     if(continue) then $
      begin
       ndat = n_elements(dat)
       _stds = stn_create_descriptors(ndat, gd=make_array(ndat, val=cor_create_gd(cor_gd(xd[i]), bx0=xd[i])))

       pos_surf = transpose([transpose([dat.lat]), transpose([dat.lon]), transpose([dat.alt])])

       cor_set_name, _stds, dat.name
       stn_set_surface_pt, _stds, reform(transpose(pos_surf), 1,3,ndat,/over)
      end
    end
   stds = append_array(stds, _stds)
  end


 if(NOT keyword_set(stds)) then $
  begin
   status = -1
   return, 0
  end


 return, stds
end
;===========================================================================



