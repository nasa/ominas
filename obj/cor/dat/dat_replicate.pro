;=============================================================================
;+
; NAME:
;	dat_replicate
;
;
; PURPOSE:
;	Replicates the given descriptor, producing an array of the given
;	dimensions containing cloned versions of the input descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	dds = dat_replicate(dd, dim)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	 Data deccriptor to replicate.
;
;	dim:	 Dimensions of the result.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	fn:	Name of the cloning function.  Default is nv_clone.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of the given dimensions containing cloned versions of the input 
;	data descriptor.
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
function dat_replicate, dd, dim, fn=fn
@core.include
 new_dd = dat_replicate(dd, dim, fn='nv_clone')
 return, new_dd
end
;=============================================================================
