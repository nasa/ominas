;=============================================================================
;+
; NAME:
;	cor_cat_gd
;
;
; PURPOSE:
;	Produces an array of object descriptors from a generic descriptor.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	xds = cor_cat_gd(gd)
;
;
; ARGUMENTS:
;  INPUT: 
;	gd:	Generic descriptor.
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
;	Array of object descriptors taken from the given generic descriptors.  
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		
;	Moved to CORE	Spitale		2/2017
;	
;-
;=============================================================================
function cor_cat_gd, gd

 if(NOT keyword_set(gd)) then return, !null

 for j=0, n_elements(gd)-1 do $
  begin
   tags = tag_names(gd[j])
   ntags = n_elements(tags)

   for i=0, ntags-1 do $
             if(keyword_set(gd[j].(i))) then xds = append_array(xds, gd[j].(i))
  end

 return, xds
end
;==================================================================================
