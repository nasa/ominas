;=============================================================================
;+
; NAME:
;	clone_object
;
;
; PURPOSE :
;
; 	Clones a data object by recursively descending through pointers and 
;	structures, creating new pontersand copying data.
;
;
; CATEGORY:
;	NV/UTIL
;
;
; CALLING SEQUENCE :
;
;   result = clone_object(x)
;
;
; ARGUMENTS
;  INPUT : 
;	x:	Object to be cloned.
;
;  OUTPUT : NONE
;
;
;
; KEYWORDS 
;  INPUT : NONE
;
;  OUTPUT : NONE
;
;
; RETURN : 
;	An object identical to the input, with all new pointers.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================



;=============================================================================
; co_recurse
;
;=============================================================================
function co_recurse, x

 type = size(x, /type)

 if(type EQ 10) then $
  begin
   n = n_elements(x)
   for i=0, n-1 do if(ptr_valid(x[i])) then $
                             if(nvf_recurse(*x[i]) NE 0) then return, -1
   nv_ptr_free, x
  end $
 else if(type EQ 8) then $
  begin
   n = n_elements(x)
   for i=0, n-1 do $
    begin
     if(nv_get_directive(x[i]) EQ 'NV_STOP') then return, -1

     ntags = n_tags(x[i])
     for j=0, ntags-1 do if(nvf_recurse(x[i].(j)) NE 0) then return, -1
    end
  end

 return, 0
end
;=============================================================================



;=============================================================================
; clone_object
;
;=============================================================================
function clone_object, x
 return, co_recurse(x)
end
;=============================================================================
