;=============================================================================
;+
; NAME:
;	cor_replace_gd
;
;
; PURPOSE:
;	Replaces generic descriptor objects.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_replace_gd, gd, xd, xd_new
;
;
; ARGUMENTS:
;  INPUT:
;	xd0:	Objects containing generic descriptors to be modified.
;
;	xd:	Objects to replace in gd.
;
;	xd_new:	New objects; one for each elements in xd.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
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
   if(w[0] NE -1) then xds[i] = xd_new[w]
  end

 return, xds
end
;=============================================================================



;=============================================================================
; cor_replace_gd
;
;=============================================================================
pro cor_replace_gd, xd0, xd, xd_new, noevent=noevent

 if(NOT keyword_set(xd0)) then return

 
 ;--------------------------------------
 ; make substitutions in each gd
 ;--------------------------------------
 for i=0, n_elements(xd0)-1 do $ 
  begin
   gd = cor_gd(xd0[i], noevent=noevent)
   tags = tag_names(gd)
   for j=0, n_elements(tags)-1 do gd.(j) = crgd_replace(gd.(j), xd, xd_new)
   cor_set_gd, xd0[i], gd, noevent=noevent
  end


end
;===========================================================================
