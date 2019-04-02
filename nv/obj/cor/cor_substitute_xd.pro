;=============================================================================
;+
; NAME:
;	cor_substitute_xd
;
;
; PURPOSE:
;	Replaces objects in generic descriptors and arrays.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_substitute_xd, xd0, xd, xd_new
;
;
; ARGUMENTS:
;  INPUT:
;	xd0:	Objects containing generic descriptors to be modified, or
;		to be directly substituted.
;
;	xd:	Objects to replace in xd0.
;
;	xd_new:	New objects; one for each elements in xd.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	use_gd:	If set, the objects to replace are in the generic descriptors
;		of xd0.
;
;	noevent:
;		If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================



;=============================================================================
; crgd_replace
;
;=============================================================================
function crgd_replace, xds, xd, xd_new

 for i=0, n_elements(xds)-1 do $
  begin
   w = where(xd EQ xds[i])
   if(w[0] NE -1) then xds[i] = xd_new[w[0]]
  end

 return, xds
end
;=============================================================================



;=============================================================================
; cor_substitute_xd
;
;=============================================================================
pro cor_substitute_xd, xd0, xd, xd_new, use_gd=use_gd, noevent=noevent

 if(NOT keyword_set(xd0)) then return

 ;--------------------------------------
 ; make substitutions in object array
 ;--------------------------------------
 if(NOT keyword_set(use_gd)) then $
  begin
   xd0 = crgd_replace(xd0, xd, xd_new)
   return
  end

 ;--------------------------------------
 ; make substitutions in each gd
 ;--------------------------------------
 for i=0, n_elements(xd0)-1 do $ 
  begin
   gd = cor_gd(xd0[i], noevent=noevent)
   if(keyword_set(gd)) then $
    begin 
     ntags = n_tags(gd)
     for j=0, ntags-1 do gd.(j) = crgd_replace(gd.(j), xd, xd_new)
     cor_set_gd, xd0[i], gd, noevent=noevent
    end 
  end


end
;===========================================================================
