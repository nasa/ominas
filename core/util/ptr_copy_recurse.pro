;=============================================================================
;+
; NAME:
;	ptr_copy_recurse
;
;
; PURPOSE:
;	Copies data from the given pointer and from all pointers pointed to 
;	by it.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = ptr_copy_recurse(p)
;
;
; ARGUMENTS:
;  INPUT:
;	p:	Pointer to be copied.
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
;	NONE
;
;
; STATUS:
;	xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale,  6/2002
;	
;-
;=============================================================================

;=============================================================================
; pcr_recurse
;=============================================================================
function pcr_recurse, p

 type = size(p, /type)

 if(type EQ 10) then $
  begin
   n = n_elements(p)
   pp = ptrarr(n)
   for i=0, n-1 do $
    begin
     if(ptr_valid(p[i])) then pp[i] = nv_ptr_new(pcr_recurse(*p[i])) $
     else pp[i] = nv_ptr_new()
    end
   return, pp
  end $
 else return, p


end
;=============================================================================



;=============================================================================
; ptr_copy_recurse
;
;=============================================================================
function ptr_copy_recurse, p

 return, pcr_recurse(p)
end
;=============================================================================
