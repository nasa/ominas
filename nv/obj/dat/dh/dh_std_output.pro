;=============================================================================
;+-+
; NAME:
;	dh_std_output
;
;
; PURPOSE:
;	Output translator for detached headers.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_put_value):
;	dh_std_output, dd, keyword, value
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity to
;			write.
;
;	value:		The data to write.
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
;	status:		Zero unless a problem occurs.
;
;
;  TRANSLATOR KEYWORDS:
;	format:		String giving the name of the output representation. 
;			Default is OMINAS internal representation.  The null  
;			string, '', indicates the default.
;
;	dh_out:		String giving the name of the new detached header to 
;			write.  If the file base name is 'auto', then the name is
;			taken from the core name property of the data descriptor,
;			with any extension replaced by '.dh'.
;
;
; SIDE EFFECTS:
;	The detached header in the data descriptor is modified.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dh_std_input
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================



;=============================================================================
; dhso_put
;
;=============================================================================
pro dhso_put, dd, dh, _od, prefix, obj=obj

 ;--------------------------
 ; get object fields
 ;--------------------------
 fields = tag_names(_od)
 nfields = n_elements(fields)

 ;------------------------------------------------------
 ; write fields to dh; first 3 fields are internal
 ;------------------------------------------------------
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
     ; write object fields
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     val = _od.(i)
     type = size(val, /type)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; convert data if necessary
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     value = !null
     if(type LE 7) then value = val $
     else if(type EQ 11) then value = cor_name(val) $
     else if(type EQ 10) then if(ptr_valid(val)) then value = *val; $
;     else nv_message, 'Invalid object member type: ' + name

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; handle ASSOC field specially: do not write if assigned to dd
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(field EQ 'ASSOC') then if(val EQ dd) then value = !null

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; handle GD field specially: do not write
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(field EQ 'GDP') then value = !null

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; update header
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(defined(value)) then $
        dh_put_value, dh, name, value, obj=obj, section=section, comment=comment

    end   
  end

end
;=============================================================================



;=============================================================================
; dh_std_output
;
;=============================================================================
pro dh_std_output, dd, keyword, value, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 status = 0

 ;--------------------------
 ; get detached header
 ;--------------------------
 dh = dat_dh(dd)

 ;-----------------------------------------------
 ; translator keywords
 ;-----------------------------------------------
 format = dat_keyword_value(dd, 'format')
 if(keyword_set(format)) then ods = dh_from_ominas(format, value) $
 else ods = value

 _ods =  cor_dereference(ods)
 prefix = strlowcase(str_nnsplit(keyword, '_'))

 dh_file = dat_keyword_value(dd, 'dh_out')
 if(keyword_set(dh_file)) then $
  begin
   dh_dir = (file_search(file_dirname(dh_file)))[0]
   dh_name = file_basename(dh_file)
   if(strupcase(dh_name) EQ 'AUTO') then dh_name = dh_fname(/write, cor_name(dd))
   dh_file = dh_dir + path_sep() + dh_name
  end



 ;--------------------------
 ; add update comment
 ;--------------------------
 time = get_juliandate(stime=stime, format=jdformat)

 dh_put_value, dh, '', 0, comment=$
    '-------------------------------------------------------------------- /'
 dh_put_value, dh, '', 0, comment=$
    cor_class(ods[0]) +' descriptor -- updated ' + stime
 dh_put_value, dh, '', 0, comment=$
    '-------------------------------------------------------------------- /'

 dh_put_value, dh, prefix + '_update_time', time

 ;-----------------------------------------------
 ; add descriptor
 ;-----------------------------------------------
 n = n_elements(ods)
 for i=0, n-1 do dhso_put, dd, dh, _ods[i], prefix, obj=i

 ;--------------------------
 ; modify detached header
 ;--------------------------
 dat_set_dh, dd, dh

 ;-------------------------------------------
 ; write detached header if file name given
 ;-------------------------------------------
 if(keyword_set(dh_file)) then dh_write, dh_file, dh


end
;===========================================================================
