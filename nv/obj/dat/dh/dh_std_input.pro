;=============================================================================
;+-+
; NAME:
;	dh_std_input
;
;
; PURPOSE:
;	Input translator for detached header
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = dh_std_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity to
;			read.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	NONE
;
;  OUTPUT:
;	status:		Zero if valid descriptors are returned
;
;
;  TRANSLATOR KEYWORDS:
;	history:	History index to use in matching the keyword.  If not 
;			specified, the keyowrd with the highest history index
;			is matched.
;
;	dh_in:		String giving the name of a detached header to load,
;			replacing any current detached header.  If the base name
;			is 'auto', then the name is taken from the core name 
;			property of the data descriptor, with any extension 
;			replaced by '.dh'.
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
; SEE ALSO:
;	dh_std_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================



;=============================================================================
; dhsi_associate_object
;
;=============================================================================
function dhsi_associate_object, name, dd, all_xds

 if(name EQ cor_name(dd)) then return, dd

 w = where(name EQ cor_name(all_xds))
 xd = all_xds[w]

 w = where(cor_gd(xd, /dd) EQ dd)

 return, xd[w[0]]
end
;=============================================================================



;=============================================================================
; dhsi_get
;
;=============================================================================
function dhsi_get, dh, prefix, dd, all_xds, obj=obj, hi=hi

 ;--------------------------
 ; create blank objects
 ;--------------------------
 fn = prefix + '_create_descriptors'
 xd = call_function(fn, gd=dd)
 _xd = cor_dereference(xd)

 ;--------------------------
 ; get object fields
 ;--------------------------
 fields = tag_names(_xd[0])
 nfields = n_elements(fields)

 ;------------------------------------------------------
 ; read fields from dh; first 3 fields are internal
 ;------------------------------------------------------
 nval = 0
 for i=3, nfields-1 do $
  begin
   field = fields[i]
   continue = 1

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; ignore user data (for now)
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   p = strpos(field, 'UDATA')
   if(p[0] NE -1) then continue = 0

   if(continue) then $
    begin   
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; create the field name
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     name = dh_field_name(field, prefix)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; read object field
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     val = dh_get_value(dh, name, history_index=hi, obj=obj, $
                                               section=section, /all_match)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; populate object field
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     type = size(_xd.(i), /type)

     if(keyword_set(val)) then $
      begin
       nval = nval + 1
       if(type LE 7) then _xd.(i) = val $
       else if(type EQ 11) then $
                       _xd.(i) = dhsi_associate_object(val[0], dd, all_xds) $
       else if(type EQ 10) then if(ptr_valid(_xd.(i))) then *_xd.(i) = val $
       else nv_message, 'Invalid object member type: ' + name
      end

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; handle GDP field specially: assign to dd if not matched
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(field EQ 'GDP') then cor_set_gd, _xd, {dd:dd}
    end   
  end

  if(nval GT 0) then return, _xd

  nv_free, xd
  return, !null
end
;=============================================================================



;=============================================================================
; dh_std_input
;
;=============================================================================
function dh_std_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords
common dhsi_block, all_xds


 status = -1
 n_obj = 0
 prefix = strlowcase(str_nnsplit(keyword, '_'))
 fn = prefix + '_create_descriptors'


 ;------------------------------------------------------------
 ; primary planet descriptors (key4) must not be present
 ;------------------------------------------------------------
 if(keyword_set(key4)) then $
  begin
   status = -1
   return, 0
  end


 ;-----------------------------------------------
 ; get descriptors
 ;-----------------------------------------------
 xds = !null
 ndd = n_elements(dd)
 for j=0, ndd-1 do $
  begin
   xd = !null

   ;- - - - - - - - - - - - - - - - -
   ; translator keywords
   ;- - - - - - - - - - - - - - - - -
   history = dat_keyword_value(dd[j], 'history')
   if(keyword_set(history)) then hi = fix(history)

   dh_file = dat_keyword_value(dd[j], 'dh_in')

   ;- - - - - - - - - - - - - - - - -
   ; get detached header
   ;- - - - - - - - - - - - - - - - -
   if(keyword_set(dh_file)) then $
    begin
     dh_dir = file_dirname(dh_file)
     dh_name = file_basename(dh_file)
     if(strupcase(dh_name) EQ 'AUTO') then $
                                 dh_name = dh_fname(/write, cor_name(dd[j]))
     dh_file = dh_dir + path_sep() + dh_name
     dh = dh_read(dh_file)
     dat_set_dh, dd[j], dh
    end

   dh = dat_dh(dd[j])
   if(keyword_set(dh)) then $
    begin
     ;- - - - - - - - - - - - - - - - -
     ; determine # objects
     ;- - - - - - - - - - - - - - - - -
     name = dh_get_string(dh, prefix + '_name', n_obj=n_obj, hi=hi, status=status)

     ;- - - - - - - - - - - - - - - - -
     ; get descriptors
     ;- - - - - - - - - - - - - - - - -
     _xd = !null
     for i=0, n_obj-1 do $
           _xd = append_array(_xd, $
                          dhsi_get(dh, prefix, dd[j], all_xds, obj=i, hi=hi))

     if(keyword_set(_xd)) then $
      begin
       xd = call_function(fn, n_obj, gd=make_array(n_obj, val=dd[j]))
       cor_rereference, xd, _xd
      end

     ;- - - - - - - - - - - - - - - - -
     ; add to output list
     ;- - - - - - - - - - - - - - - - -
     xds = append_array(xds, xd)
    end
  end


 ;------------------------------------------------------------
 ; record all xds that have been loaded via this translator
 ;------------------------------------------------------------
 all_xds = unique(append_array(all_xds, xds))

 return, xds
end
;===========================================================================
