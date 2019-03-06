;=============================================================================
;+
; NAME:
;	dat_data
;
;
; PURPOSE:
;	Returns the data array associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	data = dat_data(dd)
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
;	abscissa: If set to 1, the abscissa is returned instead of the data.
;
;  OUTPUT: 
;	abscissa: The abscissa is returned in this array.
;
;	samples:  Output sample indices for /current.
;
;
; RETURN:
;	The data array associated with the data descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dat_set_data
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_data, dd, samples=_samples, current=current, slice=slice, $
                  nd=nd, true=true, noevent=noevent, abscissa=_abscissa
@core.include
 nv_notify, dd, type = 1, noevent=noevent
 _dd = cor_dereference(dd)

 return_abscissa = 0
 if(keyword_set(_abscissa)) then $
      if(n_elements(_abscissa) EQ 1) then $
           if(_abscissa[0] EQ 1) then return_abscissa = 1

 dim = dat_dim(_dd)
 nelm = product(dim)
 if(nelm EQ 0) then return, !null

 sampled = 0

 sample0 = *(*_dd.dd0p).sample_p
 if(keyword_set(current)) then if(sample0[0] NE -1) then _samples = sample0


 ;--------------------------------------------------------------
 ; compute slice offset
 ;--------------------------------------------------------------
 full_array = 0
 if(defined(slice)) then offset = dat_slice_offset({slice:slice, dd0:_dd}) $
 else if(ptr_valid(_dd.slice_struct.slice_p)) then offset = dat_slice_offset(_dd)

 if(defined(offset)) then $
  begin
   if(NOT keyword_set(_samples)) then $
    begin
     _samples = lindgen(nelm)
     full_array = 1
    end 
  end $
 else offset = 0


 ;-------------------------------------------------------------------------
 ; If there is a sampling function, but no samples are given, then 
 ; generate sampling for the entire data array.  This way the sampling
 ; function always gets called and a sensible result is obtained.
 ;-------------------------------------------------------------------------
 if(keyword_set(_dd.sampling_fn) $
        AND (NOT keyword_set(_samples)) $
               AND NOT keyword_set(true)) then $
  begin
   _samples = lindgen(nelm)
   full_array = 1
  end


 ;-------------------------------------------------------------------------
 ; Compute array sampling
 ;-------------------------------------------------------------------------
 if(keyword_set(_samples)) then $
  begin
   ; - - - - - - - - - - - - - - - - -
   ; call sampling function
   ; - - - - - - - - - - - - - - - - -
   samples = _samples
   if(keyword_set(_dd.sampling_fn)) then $
      samples = call_function(_dd.sampling_fn, dd, samples, $
                                                     dat_sampling_data(_dd))

   ; - - - - - - - - - - - - - - - - -
   ; convert samples to 1D
   ; - - - - - - - - - - - - - - - - -
   samples = round(samples)
   sdim = size(samples, /dim)
   if((n_elements(sdim) NE 1) OR keyword_set(nd)) then $
                                           samples = nd_to_w(dim, samples)
  end
 if(keyword_set(samples)) then samples = samples + offset


 ;-------------------------------------------------------------------------
 ; Load data array
 ;-------------------------------------------------------------------------
; dat_load_data, _dd, sample=samples
 dat_load_data, dd, sample=samples
 _dd = cor_dereference(dd)


 ;-------------------------------------------------------------------------
 ; Uncompress
 ;-------------------------------------------------------------------------
 _dat_uncompress_data, _dd


 ;-------------------------------------------------------------------------
 ; Subsample
 ;  if some samples are already loaded, determine subscripts into 
 ;  loaded array
 ;-------------------------------------------------------------------------
 if(keyword_set(samples)) then if(sample0[0] NE -1) then $
  begin
   int = set_intersection(long(sample0), long(samples), ii, jj, kk)
   if(defined(kk)) then samples = kk
  end

 data = data_archive_get((*_dd.dd0p).data_dap, $
                                (*_dd.dd0p).dap_index, samples=samples)
 abscissa = data_archive_get((*_dd.dd0p).abscissa_dap, $
                                 (*_dd.dd0p).dap_index, samples=samples)


 ;-------------------------------------------------------------------------
 ; Unload data array if maintain == 2
 ;-------------------------------------------------------------------------
 if((*_dd.dd0p).maintain EQ 2) then dat_unload_data, _dd


 ;-------------------------------------------------------------------------
 ; If possible, reorganize to the proper dimensions.  This is not possible
 ; if the data array is being subsampled.
 ;-------------------------------------------------------------------------
 if(full_array) then $
  begin
   data = reform(data, dim, /over)
   if(keyword_set(abscissa)) then abscissa = reform(abscissa, dim, /over)
  end


 ;-------------------------------------------------------------------------
 ; Compute data and abscissa ranges for numeric data types
 ;  These track the maximum and minimum values that have ever been loaded,
 ;  so if the data array is being subsampled, these values are not 
 ;  necessarily the true maxes and mins.  
 ;-------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - -
 ; data
 ;- - - - - - - - - - - - - - - - - -
 if(NOT isnum(data)) then $
  begin
;   max = !values.d_nan
;   min = !values.d_nan
   max = -1d100
   min = 1d100
  end $
 else $
  begin
   max = max(data)
   min = min(data)
   if(max GT _dd.max) then _dd.max = max
   if(min LT _dd.min) then _dd.min = min
  end

 ;- - - - - - - - - - - - - - - - - -
 ; abscissa
 ;- - - - - - - - - - - - - - - - - -
 if(NOT isnum(abscissa)) then $
  begin
;   abmax = !values.d_nan
;   abmin = !values.d_nan
   abmax =-1d100
   abmin = 1d100
  end $
 else $
  begin
   abmax = max(abscissa)
   abmin = min(abscissa)
   if(abmax GT _dd.abmax) then _dd.abmax = abmax
   if(abmin LT _dd.abmin) then _dd.abmin = abmin
  end


 ;-------------------------------------------------------------------------
 ; get abscissa for output
 ;-------------------------------------------------------------------------
 if(keyword_set(abscissa)) then _abscissa = abscissa $
 else $
  begin
   if(keyword_set(samples)) then _abscissa = samples $
   else _abscissa = lindgen(dim)
  end


 cor_rereference, dd, _dd


 ;-------------------------------------------------------------------------
 ; restore compression
 ;-------------------------------------------------------------------------
 _dat_compress_data, _dd

 if(return_abscissa) then return, _abscissa
 return, data
end
;===========================================================================



