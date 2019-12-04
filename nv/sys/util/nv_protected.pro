;=============================================================================
;+
; NAME:
;	nv_protected
;
;
; PURPOSE:
;	Tests whether a structure or field is protected.  Protected fields
;	are not freed by nv_free, nor are they descended by nv_free
;	or nv_clone.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	test = nv_protected(tag)
;
;
; ARGUMENTS:
;  INPUT:
;	tag:		Structure tag to test.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	1 if protected, 0 if not.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2016
;	
;-
;=============================================================================
function nv_protected, arg

 if(n_elements(arg) GT 1) then return, 0

 type = size(arg, /type)

 if(type EQ 8) then $
  begin
   tags = tag_names(arg)
   if(tags[0] EQ '__PROTECT__') then return, 1
   return, 0
  end
 
 if(type EQ 7) then $
  begin
   token = '__PROTECT__'
   if(strmid(arg, 0, strlen(token)) EQ token) then return, 1
   return, 0
  end

 return, 0
end
;===========================================================================



