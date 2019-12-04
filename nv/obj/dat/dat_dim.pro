;=============================================================================
;+
; NAME:
;	dat_dim
;
;
; PURPOSE:
;	Returns the dimensions of the data array in the given data 
;	descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dim = dat_dim(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	true:	If set, the dimension function is not called and the true
;	 	dimensions of the dat are returned.
;
;	ndim: 	If set, the result will have this number of dimensions.  If 
;		there are fewer dimensions in the data set, then dimensions
;		of length one are appended.  If there are more dimensions
;		in the data set, then the extra dimensions are collapsed into
;		the highest desired dimension.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array giving the dimensions of the data in the data descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_dim, dd, true=true, ndim=ndim, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 w = where(_dd.dim NE 0)
 if(w[0] EQ -1) then return, 0

 if(keyword_set(true) OR (NOT keyword_set(_dd.dim_fn))) then return, _dd.dim[w]

 return, call_function(_dd.dim_fn, dd, dat_dim_data(dd))
end
;=============================================================================
