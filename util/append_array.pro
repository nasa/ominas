;=============================================================================
;+
; NAME:
;	append_array
;
;
; PURPOSE:
;	Concatenates two arrays; even if one is undefined or "unset".
;	This routine is intended to be used as a replacement for the 
;	syntax: result = [array1, array2], except that neither array 
;	requires checking.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = append_array(array1, array2)
;
;
; ARGUMENTS:
;  INPUT:
;	array1:	First array.  If undefined, the second array is returned.
;
;	array2:	Second array.  If undefined, the first array is returned.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	def:		If set, new items simply must be defined instead of "set".
;
;	positive:	If set, a single value of -1 is taken as an undefined
;			array.
;
;	string:		If set, the null output wil be a null string instead
;			of 0.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Concatentated array.
;
;
; STATUS:
;	Complete
;
;

; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================



;=============================================================================
; append_array_null
;
;=============================================================================
function append_array_null, array
 if(size(array, /type) EQ 7) then return, ''
 return, 0
end
;=============================================================================



;=============================================================================
; append_array
;
;=============================================================================
function append_array, array, item, def=def, positive=positive, string=string

 null = 0
 if(defined(array)) then $
  begin
   if(size(array, /type) EQ 7) then null = ''
  end $
 else if(defined(item)) then if(size(item, /type) EQ 7) then null = ''

 if(keyword_set(string)) then null = ''


 if(keyword_set(def)) then $
  begin
   if(NOT defined(item)) then $
    begin
     if(defined(array)) then return, array
     return, null
    end

   if(NOT defined(array)) then return, [item]
   return, [array, item]
  end


 if(keyword_set(positive)) then $
  begin
   if(NOT defined(item)) then $
    begin
     if(defined(array)) then return, array
     return, null
    end

   if(NOT defined(array)) then return, [item]
   if(n_elements(array EQ 1) AND array[0] EQ -1) then return, [item]
   return, [array, item]
  end


 if(NOT keyword__set(item)) then $
  begin
   if(keyword__set(array)) then return, array
   return, null
  end

 if(NOT keyword__set(array)) then return, [item]
 return, [array, item]

end 
;=============================================================================
