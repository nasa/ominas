;=============================================================================
;+
; NAME:
;	dat_set_data
;
;
; PURPOSE:
;	Replaces the data array associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_data, dd, data
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	data:	New data array.
;
;  OUTPUT:
;	dd:	Modified data descriptor.
;
;
; KEYWORDS:
;  INPUT: 
;	abscissa: If set, the given array is taken as the abscissa.
;
;	update:	Update mode flag.  If not given, it will be taken from dd.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Does not yet support sampling.
;
;
; SEE ALSO:
;	dat_data
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_set_data, dd, _data, update=update, noevent=noevent, $
       abscissa=_abscissa, sample=sample
@core.include
 _dd = cor_dereference(dd)

 if(NOT defined(update)) then update = (*_dd.dd0p).update
 if(update EQ -1) then return

 if((*_dd.dd0p).maintain GT 0) then $
  nv_message, /warning, verb=0.1, $
   'Changes to data array may be lost due to the maintainance level.'

 if(keyword_set(_abscissa)) then abscissa = _abscissa
 if(keyword_set(_data)) then data = _data
 if(NOT keyword_set(sample)) then sample = -1


; ;--------------------------------------------------------------
; ; compute slice offset
; ;--------------------------------------------------------------
; if(ptr_valid(_dd.slice_struct.slice_p)) then $
;  begin
;   offset = dat_slice_offset(_dd)
;   if(NOT keyword_set(_samples)) then $
;    begin
;     _samples = lindgen(nelm)
;     full_array = 1
;    end
;  end


 ;----------------------------------------------
 ; incorporate new samples
 ;----------------------------------------------
 if(sample[0] NE -1) then $
  begin
   sample0 = *(*_dd.dd0p).sample_p
   if(sample0[0] NE -1) then $
    begin
     data0 = data_archive_get((*_dd.dd0p).data_dap, (*_dd.dd0p).dap_index)
     abscissa0 = data_archive_get((*_dd.dd0p).abscissa_dap, (*_dd.dd0p).dap_index)
     order0 = *(*_dd.dd0p).order_p

     sample = set_union(sample0, sample, ii)
     data = ([data0, data])[ii]
     if(keyword_set(abscissa)) then abscissa = ([abscissa0, abscissa])[ii]

     order = make_array(n_elements(sample), val=max(order0)+1)
     order = ([order0, order])[ii]
     order = order - min(order)
    end
  end


 ;--------------------------------------------
 ; modify data array if update = 0
 ;--------------------------------------------
 if(NOT keyword_set(update)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - -
   ; do not archive if maintain > 0
   ;- - - - - - - - - - - - - - - - - - - - - - -
   index = 0
   if((*_dd.dd0p).maintain GT 0) then index = (*_dd.dd0p).dap_index

   dap = 0
   if(keyword_set((*_dd.dd0p).data_dap)) then dap = (*_dd.dd0p).data_dap
   data_archive_set, dap, data, index=index
   (*_dd.dd0p).data_dap = dap

   if(keyword_set(abscissa)) then $
    begin
     dap = 0
     if(keyword_set((*_dd.dd0p).abscissa_dap)) then $
                                       dap = (*_dd.dd0p).abscissa_dap
     data_archive_set, dap, abscissa, index=index
     (*_dd.dd0p).abscissa_dap = dap
    end

   if(keyword_set(sample)) then *(*_dd.dd0p).sample_p = sample
   if(keyword_set(order)) then *(*_dd.dd0p).order_p = order

   (*_dd.dd0p).dap_index = 0

   if(keyword_set(_data)) then $
        if(sample[0] EQ -1) then dat_set_dim, _dd, size(_data, /dim)
  end


 ;--------------------------------------------
 ; compress data if necessary
 ;--------------------------------------------
 _dat_compress_data, _dd


 ;-----------------------------------------------------------------------------
 ; if update = 1, put the new data on a new descriptor; output the new pointer
 ;-----------------------------------------------------------------------------
 if(update EQ 1) then $
  begin
   dd_new = nv_clone(dd)
   dat_set_sibling, dd, dd_new
   dat_set_update, dd_new, 0
;;;   dat_set_data, dd_new, data, update=0, abscissa=abscissa, sample=sample
   dd = dd_new
  end


 ;----------------------------------------------
 ; update description
 ;----------------------------------------------
 (*_dd.dd0p).typecode = size(data, /type)
 if ((*_dd.dd0p).typecode ne 8) then begin
   _dd.min = min(data)
   _dd.max = max(data)
 endif

 if(keyword_set(_abscissa)) then $
  begin
   _dd.abmin = min(abscissa)
   _dd.abmax = max(abscissa)
  end $
 else $
  begin
   _dd.abmin = 0
   _dd.abmax = long(product(dat_dim(_dd)))
  end


 ;----------------------------------------------
 ; generate write event on original descriptor
 ;----------------------------------------------
 cor_rereference, dd, _dd
 nv_notify, dd, type=0, desc='DATA', noevent=noevent
 nv_notify, /flush, noevent=noevent

end
;===========================================================================



