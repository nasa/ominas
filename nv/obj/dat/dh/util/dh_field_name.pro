;===========================================================================
; dh_field_name
;
;
;===========================================================================
function dh_field_name, field, prefix

 ;-------------------------------------------------------
 ; remove any pointer suffix
 ;-------------------------------------------------------
 if(strmid(field, strlen(field)-2, 2) EQ '_P') then $
				field = strmid(field, 0, strlen(field)-2)

 ;-------------------------------------------------------
 ; remove any object suffix
 ;-------------------------------------------------------
 if(strmid(field, strlen(field)-3, 3) EQ '_XD') then $
				field = strmid(field, 0, strlen(field)-3)

 ;-------------------------------------------------------
 ; remove __PROTECT__ prefix
 ;-------------------------------------------------------
 if(strmid(field, 0, 11) EQ '__PROTECT__') then $
				field = strmid(field, 11, strlen(field))

 name = strlowcase(prefix + '_' + field)


 return, name
end
;===========================================================================
