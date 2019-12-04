;=============================================================================
;+
; NAME:
;	cor_associate_gd
;
;
; PURPOSE:
;	Selects all input descriptors whose gd contains the given assoc_xd.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	xd = cor_associate_gd(xd, assoc_xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 	Array of objects or generic descriptors.  If generic
;			descriptors are given, then a generic descriptor is 
;			returned.
;
;	assoc_xd:	Object to test against.  If not given, all input 
;			descriptors are returned.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of objects or a generic descriptor of objects whose generic 
;	descriptors contain assoc_xd.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================



;=============================================================================
; _cor_associate_gd
;
;=============================================================================
function _cor_associate_gd, xd, assoc_xd

 result = 0

 for i=0, n_elements(xd)-1 do $
  begin
   gd = cor_gd(xd[i])
   w = where(cor_dereference_gd(gd) EQ assoc_xd)
   if(w[0] NE -1) then result = append_array(result, xd[i])
  end

 return, result
end
;=============================================================================



;=============================================================================
function cor_associate_gd, xd, assoc_xd

 if(NOT keyword_set(assoc_xd)) then return, xd
 result = !null

 ;---------------------------------------------
 ; generic descriptor input
 ;---------------------------------------------
 if(size(xd, /type) EQ 8) then $
  begin
   gd = xd
   tags = tag_names(gd)
   for j=0, n_elements(tags)-1 do $
    begin
     gdd = _cor_associate_gd(gd.(j), assoc_xd)
     if(keyword_set(gdd)) then $
                  result = append_struct(result, create_struct(tags[j], gdd))
    end
   return, result
  end


 ;---------------------------------------------
 ; object input
 ;---------------------------------------------
 result = _cor_associate_gd(xd, assoc_xd)
; for i=0, n_elements(xd)-1 do $
;  begin
;   gd = cor_gd(xd[i])
;   w = where(cor_dereference_gd(gd) EQ assoc_xd)
;   if(w[0] NE -1) then result = append_array(result, xd[i])
;  end

 return, result
end
;=============================================================================
