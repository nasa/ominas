;=============================================================================
;+
; NAME:
;	dat_load_data
;
;
; PURPOSE:
;	Loads the data array for a given data descriptor.  Adds to 
;	NV state maintained list if maintain == 1.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_load_data, dd
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor to test.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	sample:		Requeseted data samples.  If not set, all samples are 
;			loaded.
;
;  OUTPUT: 
;	data:		Loaded data values.
;
;	abscissa:	Loaded abscissa values.
;
;
; RETURN: NONE
;
;
; KNOWN BUGS:
;	Subsampling (ie. caching) is unreliable.  Lines or other anomalies
;	often appear in subsampled images.  This does not seem to happen
;	with integer sampling (e.g. integer zooms in tvim or grim), so it
;	may be related to rounding or truncating of indices.  It may also be
;	a problem with the set arithmetic.  Enabling caching (setting DAT_CACHE
;	to some non-zero number) is not recommended.
;
;
; STATUS:
;	Some bugs.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro ___dat_load_data, dd, sample=sample, data=data, abscissa=abscissa
@nv_block.common
@core.include

;;;if(keyword_set(sample)) then s = w10n_sample_to_query(dat_dim(dd), unique(sample))
 _dd = cor_dereference(dd)

 ;----------------------------------------------------------------------
 ; if a data array aready exists, don't continue unless samples
 ; are requested
 ;----------------------------------------------------------------------
 sample0 = *(*_dd.dd0p).sample_p
 if(data_archive_defined((*_dd.dd0p).data_dap, $
                         (*_dd.dd0p).dap_index)) then $
                                         if(sample0[0] EQ -1) then return

 ;----------------------------------
 ; manage loaded data
 ;----------------------------------
 if((*_dd.dd0p).maintain EQ 1) then dat_manage_dd, dd
 if(NOT keyword_set(_dd.input_fn)) then return


 ;-------------------------------------------------------------
 ; determine samples such that no loaded samples are reloaded
 ;-------------------------------------------------------------
 if(keyword_set((*_dd.dd0p).cache)) then $
  begin
   if(keyword_set(sample)) then $
    begin
     requested_samples = [unique(sample)]

     samples_to_load = requested_samples
     if(sample0[0] NE -1) then $
      begin
       loaded_samples = set_intersection(sample0, requested_samples)
       if(loaded_samples[0] NE -1) then $
              samples_to_load = set_difference(loaded_samples, requested_samples)
      end
     if(samples_to_load[0] EQ -1) then return
    end


 ;-----------------------------------
 ; unload older samples if necessary
 ;-----------------------------------
;   overflow = $
;         _dat_compute_size(_dd, [loaded_samples, samples_to_load) - (*_dd.dd0p).cache
;   if(overflow GT 0) then _dat_unload_samples, _dd, overflow

  end


 ;----------------------------------
 ; read data
 ;----------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; First attempt to read using input function (usually the fastest)
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 data = call_function(_dd.input_fn, _dd, $
                       header, abscissa=abscissa, $
                       sample=samples_to_load, returned_samples=returned_samples)

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; If the input function fails (probably because it cannot subsample),
 ; then try the generic file reader
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(data)) then $
  begin
   if(ptr_valid((*_dd.dd0p).gffp)) then $
        data = gff_read(*(*_dd.dd0p).gffp, subscripts=samples_to_load) $
   else nv_message, 'Cannot load data array.'
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; test whether input fn actually sampled the data as requested
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(returned_samples)) then samples_to_load = returned_samples
 if(keyword_set(samples_to_load)) then $
   if(n_elements(data) NE n_elements(samples_to_load)) then samples_to_load = -1


; ;----------------------------------
; ; transform data
; ;----------------------------------
; data = dat_transform_input(_dd, data, header)

 ;----------------------------------
 ; set data on descriptor
 ;----------------------------------
 nv_suspend_events
 dat_set_data, dd, data, abscissa=abscissa, sample=samples_to_load
 if(keyword_set(udata)) then cor_set_udata, dd, '', udata
 if(keyword_set(header)) then dat_set_header, dd, header
 nv_resume_events


 ;----------------------------------
 ; transform data
 ;----------------------------------
 nv_suspend_events
 dat_transform_input, dd
 nv_resume_events


end
;=============================================================================




;=============================================================================
pro dat_load_data, dd, sample=sample, data=data, abscissa=abscissa
@nv_block.common
@core.include

;;;if(keyword_set(sample)) then s = w10n_sample_to_query(dat_dim(dd), unique(sample))
 _dd = cor_dereference(dd)

 ;----------------------------------------------------------------------
 ; if a data array aready exists, don't continue unless samples
 ; are requested
 ;----------------------------------------------------------------------
 sample0 = *(*_dd.dd0p).sample_p
 if(data_archive_defined((*_dd.dd0p).data_dap, $
                         (*_dd.dd0p).dap_index)) then $
                                         if(sample0[0] EQ -1) then return

 ;----------------------------------
 ; manage loaded data
 ;----------------------------------
 if((*_dd.dd0p).maintain EQ 1) then dat_manage_dd, dd
 if(NOT keyword_set(_dd.input_fn)) then return


 ;-------------------------------------------------------------
 ; determine samples such that no loaded samples are reloaded
 ;-------------------------------------------------------------
 if(keyword_set((*_dd.dd0p).cache)) then $
  begin
   if(keyword_set(sample)) then $
    begin
     requested_samples = [unique(sample)]

     samples_to_load = requested_samples
     if(sample0[0] NE -1) then $
      begin
       loaded_samples = set_intersection(sample0, requested_samples)
       if(loaded_samples[0] NE -1) then $
              samples_to_load = set_difference(loaded_samples, requested_samples)
      end
     if(samples_to_load[0] EQ -1) then return
    end


 ;-----------------------------------
 ; unload older samples if necessary
 ;-----------------------------------
;   overflow = $
;         _dat_compute_size(_dd, [loaded_samples, samples_to_load) - (*_dd.dd0p).cache
;   if(overflow GT 0) then _dat_unload_samples, _dd, overflow

  end


 ;----------------------------------
 ; read data
 ;----------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; If this is a slice, then get the source dd and convert the samples
 ; to offsets into the source array.  If no samples given, compute samples
 ; corresponding to the entire slice within the source array
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 dd = dat_slice_source(dd)
 _dd = cor_dereference(dd)

 dat_slice_convert, dd, samples_to_load


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; First, attempt to read using input function (usually the fastest)
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 catch_errors = NOT keyword_set(getenv('NV_DEBUG'))

 if(NOT catch_errors) then err = 0 $
 else catch, err

 if(err EQ 0) then $
    data = call_function(_dd.input_fn, _dd, $
                  header, abscissa=abscissa, $
                   sample=samples_to_load, returned_samples=returned_samples) $
 else nv_message, /warning, $
              'Input method ' + strupcase(_dd.input_fn) + ' crashed; ignoring.'

 catch, /cancel


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; If the input function fails (probably because it cannot subsample),
 ; then try the generic file reader
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(data)) then $
  begin
   if(keyword_set(*(*_dd.dd0p).gffp)) then $
        data = gff_read(*(*_dd.dd0p).gffp, subscripts=samples_to_load) $
   else $
    begin
     nv_message, /warning, 'Cannot load data array.'
     return
    end
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; test whether input fn actually sampled the data as requested
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(keyword_set(returned_samples)) then samples_to_load = returned_samples
 if(keyword_set(samples_to_load)) then $
   if(n_elements(data) NE n_elements(samples_to_load)) then samples_to_load = -1


; ;----------------------------------
; ; transform data
; ;----------------------------------
; data = dat_transform_input(_dd, data, header)

 ;----------------------------------
 ; set data on descriptor
 ;----------------------------------
 nv_suspend_events
 dat_set_data, dd, data, abscissa=abscissa, sample=samples_to_load
 if(keyword_set(udata)) then cor_set_udata, dd, '', udata
 if(keyword_set(header)) then dat_set_header, dd, header
 nv_resume_events


 ;----------------------------------
 ; transform data
 ;----------------------------------
 nv_suspend_events
 dat_transform_input, dd
 nv_resume_events

end
;=============================================================================




