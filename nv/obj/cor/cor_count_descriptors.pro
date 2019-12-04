;=============================================================================
;+
; NAME:
;	cor_count_descriptors
;
;
; PURPOSE:
;	Determines dimensions of an array of input descriptors.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_count_descriptors, xds, nd=nd, nt=nt
;
;
; ARGUMENTS:
;  INPUT:
;	xds:		Array (nd,nt) of descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	nd:	First dimension, number of objects, default is 1.
;
;	nt:	Second dimension, number of 'timesteps', default is 1.
;
;
; RETURN: NONE
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	Copied to cor/:	Spitale 	2/2017
;	
;-
;=============================================================================
pro cor_count_descriptors, xds, nd=nd, nt=nt

 dim = size(xds, /dim)
 nd = 1
 if(dim[0] NE 0) then nd = dim[0]
 nt = 1
 if(n_elements(dim) GT 1) then nt = dim[1]

end
;=============================================================================
