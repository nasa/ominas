;=============================================================================
;+
; NAME:
;	dat_slice_select
;
;
; PURPOSE:
;	Selects descriptors from a list based on the slice coordinates in a data
;	descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	dd0 = dat_slice_select(dd, xd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	xd:	Array of descriptors from which to select.
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
;	Selected xd.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		7/2018
;	
;-
;=============================================================================
function dat_slice_select, dd, xd, noevent=noevent

 ndd = n_elements(dd)

 for i=0, ndd-1 do $
  begin
   slice = dat_slice(dd[i], dd0=dd0, noevent=noevent)

   dd_assoc = dd[i]
   if(keyword_set(dd0)) then dd_assoc = dd0
   _xd = cor_associate_gd(xd, dd_assoc)

if(keyword_set(dd0)) then _xd = _xd[slice]	; for now; need to do this right

   xds = append_array(xds, _xd)
  end

; need to free xds that don't get selected unless /nofree

 return, xds
end
;===========================================================================




