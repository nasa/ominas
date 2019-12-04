;=============================================================================
;+
; NAME:
;       get_object_by_name
;
;
; PURPOSE:
;	Selects from a list of descriptors based on their name.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       xd = get_object_by_name(xds, name)
;
;
; ARGUMENTS:
;  INPUT:
;	xds:	Array of any subclass of CORE.
;
;	name:	Name to select.
;
;  OUTPUT:
;       NONE
;
;
; KEYOWRDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array descriptors whose CORE name field matches the given name.
;	If no matches are found, 0 is returned.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function get_object_by_name, xds, name

 if(NOT keyword_set(name)) then return, xds

 names = cor_name(xds)
 w = nwhere(names, strupcase(name))
 if(w[0] EQ -1) then return, 0

 return, xds[w]
end
;=============================================================================
