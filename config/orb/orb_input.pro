;=============================================================================
;+
; NAME:
;	orb_input
;
;
; PURPOSE:
;	Input translator for planetary orbits.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = orb_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor
;
;  OUTPUT:
;	status:		Zero if valid data is returned
;
;
; ENVIRONMENT VARIABLES:
;	NV_ORBIT_DATA:	Sets the directory in which to look for data files.
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
; 	Written by:	Spitale; 9/2007
;	
;-
;=============================================================================



;=============================================================================
; oi_clone
;
;=============================================================================
function oi_clone, _rd

 n = n_elements(_rd)
 rd = objarr(n)

 for i=0, n-1 do if(obj_valid(_rd[i])) then $
                           rd[i] = nv_clone(_rd[i])

 return, rd
end
;=============================================================================



;=============================================================================
; oi_get_element
;
;=============================================================================
pro oi_get_element, dat, tag, var

 tags = tag_names(dat)
 w = where(tags EQ strupcase(tag))
 defined = dat.(w[0]+1)
 if(NOT defined) then return
 var = dat.(w[0])

end
;=============================================================================



;=============================================================================
; orb_input
;
;=============================================================================
function orb_input, dd, keyword, prefix, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 ;--------------------------
 ; verify keyword
 ;--------------------------
 if(keyword NE 'PLT_DESCRIPTORS') then $
  begin
   status = -1
   return, 0
  end

 status = 0

 ;----------------------------------------------
 ; get catalog path
 ;----------------------------------------------
 catpath = getenvs('NV_ORBIT_DATA')
 if(NOT keyword_set(catpath)) then $
  begin
    nv_message, /con, $
     'NV_ORBIT_DATA environment variable is undefined.', $
       exp=['NV_ORBIT_DATA specifies directories in which this translator', $
 	    'searches for data files.']
   status = -1
   return, 0
  end
 catpath = parse_comma_list(catpath, delim=':')



 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------
 select_all = dat_keyword_value(dd, 'all')
 reload = dat_keyword_value(dd, 'reload')
; sel_names = str_nsplit(dat_keyword_value(dd, 'name'), ';')
 sel_names = dat_keyword_value(dd, 'name')
 if(NOT keyword_set(sel_names[0])) then sel_names= '' $
 else select_all = 1


; ;-----------------------------------------------
; ; camera descriptor passed as key1
; ;-----------------------------------------------
; if(keyword_set(key1)) then cd = key1 $
; else $
;  begin
;   nv_message, /con, 'Camera descriptor required.'
;   status = -1
;   return, 0
;  end


 ;-----------------------------------------------
 ; star descriptor passed as key2
 ;-----------------------------------------------
 if(keyword_set(key2)) then sd = key2
; if(keyword_set(sd)) then values = append_array(values, sd)

 ;------------------------------------------------------------
 ; primary planet descriptors must be passed as key4
 ; if not present, do not continue
 ;------------------------------------------------------------
 if(keyword_set(key4)) then pds = key4 $
 else $
  begin
   status = -1
   return, 0
  end

 ;-----------------------------------------------
 ; object names passed as key8
 ;-----------------------------------------------
 if(keyword_set(key8) AND (NOT keyword_set(sel_names))) then sel_names = key8



 ;-----------------------------------------------
 ; set up orbit descriptors
 ;-----------------------------------------------
 npds = n_elements(pds)
 for i=0, npds-1 do $
  begin
   planet = cor_name(pds[i])

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; read orbit catalog
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   catfile = 'orbcat_' + strlowcase(planet) + '.txt'
   dat = file_manage('orbcat_read', catpath, catfile, reload=reload)

   if(keyword_set(dat)) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; if any requested names, select only those
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     continue = 1
     if(keyword_set(sel_names)) then $
      begin
       for j=0, n_elements(sel_names)-1 do $
               ww = append_array(ww, where(strupcase(dat.name) EQ strupcase(sel_names[j])), /def)

       if(ww[0] EQ -1) then continue = 0 $
       else $
        begin
         w = ww[where(ww NE -1)]
         if(w[0] EQ -1) then continue = 0 $
         else dat = dat[w]
        end
      end


     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; construct planet descriptors
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     if(continue) then $
      begin
       ndat = n_elements(dat)
       for j=0, ndat-1 do $
        begin
         oi_get_element, dat[j], 'EPOCH', epoch
         oi_get_element, dat[j], 'PPT', ppt
         oi_get_element, dat[j], 'DAPDT', dapdt
         oi_get_element, dat[j], 'DLPDT', dlpdt
         oi_get_element, dat[j], 'DMLDT', dmldt
         oi_get_element, dat[j], 'DLANDT', dlandt
         oi_get_element, dat[j], 'DMADT', dmadt
         oi_get_element, dat[j], 'SMA', sma
         oi_get_element, dat[j], 'ECC', ecc
         oi_get_element, dat[j], 'INC', inc
         oi_get_element, dat[j], 'LAN', lan
         oi_get_element, dat[j], 'AP', ap
         oi_get_element, dat[j], 'MA', ma
         oi_get_element, dat[j], 'TA', ta
         oi_get_element, dat[j], 'TL', tl
         oi_get_element, dat[j], 'LP', lp
         oi_get_element, dat[j], 'ML', ml

         dkd = orb_construct_descriptor(pds[i], GG=GG, $
          name=dat[j].name, $
	   time = epoch, $
	   ppt = ppt, $
	   dapdt = dapdt, $
	   dlpdt = dlpdt, $
	   dmldt = dmldt, $
	   dlandt = dlandt, $
	   dmadt = dmadt, $
	   sma = sma, $
	   ecc = ecc, $
	   inc = inc, $
	   lan = lan, $
	   ap = ap, $
	   ma = ma, $
	   ta = ta, $
	   tl = tl, $
	   lp = lp, $
	   ml = ml)

         pos = orb_to_cartesian(dkd, vel=vel)
         
         _pd = plt_create_descriptors(1, $
		gd=dd, $
		name=cor_name(dkd), $
		pos=pos, $
		vel=vel, $
		time=bod_time(dkd))

         orb_pds = append_array(orb_pds, _pd)         
        end
      end
    end
  end


 if(NOT keyword_set(orb_pds)) then $
  begin
   status = -1
   return, 0
  end


 return, orb_pds
end
;===========================================================================



