;=============================================================================
;+
; NAME:
;	rowgen
;
;
; PURPOSE:
;	Generates an array of subscripts to select only the desired row 
;	n-vectors from an array with dimensions n x nv x nt.
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = rowgen(n, nv, nt, w)
;
;
; ARGUMENTS:
;  INPUT:
;	n, nv, nt:	 Dimensions of array from which to select.
;
;	w:	1-d array of nw subscripts selecting from the (nv x nt) 
;		row vectors.
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
;	Array (n x nw) of subscripts.
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
function rowgen, n, nv, nt, w
 nw = n_elements(w)
 ww = (n*w)##make_array(n,val=1l) + lindgen(n)#make_array(nw,val=1l)
 return, ww
end
;=============================================================================
