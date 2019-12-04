;=============================================================================
;+
; NAME:
;	dat_slice_source
;
;
; PURPOSE:
;	Returns the source dd for a slice.  If the given dd is not a slice,
;	then it is returned.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	dd0 = dat_slice_source(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;  OUTPUT: NONE
;
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Source data descriptor if dd is a slice; otherwise dd.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		7/2018
;	
;-
;=============================================================================
function dat_slice_source, dd, noevent=noevent

 ndd = n_elements(dd)
 dd0 = objarr(ndd)

 for i=0, ndd-1 do $
  begin
   slice = dat_slice(dd[i], dd0=_dd0, noevent=noevent)
   if(keyword_set(_dd0)) then dd0[i] = _dd0 $
   else dd0[i] = dd[i]
  end

 return, decrapify(dd0)
end
;===========================================================================



