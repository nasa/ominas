;=============================================================================
;+
; NAME:
;	dat_abscissa
;
;
; PURPOSE:
;	Returns the abscissa associated with a data descriptor, or !null.
;
;
; CATEGORY:
;	OBJ/DAT
;
;
; CALLING SEQUENCE:
;	abscissa = dat_abscissa(dd)
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
;	samples:  Sampling indices.  If set, only these data elements are
;		  returned.  May be 1D or the same number of dimensions as
;		  the data array.  
;
;	slice:	  Slice coordinates.
;
;	current:  If set, the current loaded samples are returned.  In this
;		  case, the sample indices are returned in the "samples"
;		  keyword.
;
;	nd:       If set, the samples input is taken to be an ND coordinate
;	          rather than a 1D subscript.  DAT_DATA can normally tell
;	          the difference automatically, but there is an ambiguity
;	          if a single ND point is requested.  In that case, DAT_DATA
;	          interprets that as an array of 1D subscripts, unless /nd
;	          is set.
;
;	true:     If set, the actual data array is returned, even if there is
;	          a sampling function.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	abscissa associated with a data descriptor, or !null if none exists.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2018
;	
;-
;=============================================================================
function dat_abscissa, dd, noevent=noevent, $
                samples=samples, current=current, slice=slice, nd=nd, true=true
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 dd0p = *_dd.dd0p
 if(NOT ptr_valid(dd0p.abscissa_dap)) then return, !null

;;; abscissa = data_archive_get(dd0p.abscissa_dap, dd0p.dap_index, samples=samples)

 abscissa = dat_data(dd, /abscissa, $
              samples=samples, current=current, slice=slice, nd=nd, true=true)

 return, abscissa
end
;===========================================================================



