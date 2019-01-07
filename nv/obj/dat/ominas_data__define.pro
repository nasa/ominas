;=============================================================================
; ominas_data::init
;
;=============================================================================
function ominas_data::init, _ii, crd=crd0, dd=dd0, $
@dat__keywords_tree.include
end_keywords
@core.include

 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(dd0)) then struct_assign, dd0, self
 void = self->ominas_core::init(ii, crd=crd0, $
@cor__keywords.include
end_keywords)


 ;-------------------------------------------------------------------------
 ; Handle index errors: set index to zero and try again.  This allows a 
 ; single input to be applied to multiple objects, via multiple calls to
 ; this method.  In that case, all inputs must be given as single inputs.
 ;-------------------------------------------------------------------------
 catch, error
 if(error NE 0) then $
  begin
   ii = 0
   catch, /cancel
  end

 
 ;---------------------------------------------------------------
 ; assign initial values
 ;---------------------------------------------------------------
 self.abbrev = 'DAT'
 self.tag = 'DD'

 if(NOT keyword_set(nhist)) then nhist = 1
 _nhist = getenv('NV_NHIST')
 if(keyword_set(_nhist)) then nhist = fix(_nhist)

 ;-----------------------
 ; data structure
 ;-----------------------
 self.dd0p = nv_ptr_new({dat_dd0_struct})

 ;-----------------------
 ; filename
 ;-----------------------
 if(keyword_set(filename)) then (*self.dd0p).filename = filename

 ;-----------------------
 ; maintain
 ;-----------------------
 if(keyword_set(maintain)) then (*self.dd0p).maintain = maintain

 ;-----------------------
 ; compress
 ;-----------------------
 if(keyword_set(compress)) then (*self.dd0p).compress = compress

 ;-----------------------
 ; typecode
 ;-----------------------
 if(keyword_set(typecode)) then (*self.dd0p).typecode = typecode

 ;-----------------------
 ; gff
 ;-----------------------
 (*self.dd0p).gffp = nv_ptr_new(0)
 if(keyword_set(gff)) then *(*self.dd0p).gffp = gff

 ;-----------------------
 ; dh
 ;-----------------------
 (*self.dd0p).dhp = nv_ptr_new('')
 if(keyword_set(dh)) then *(*self.dd0p).dhp = dh

 ;-----------------------
 ; file properties
 ;-----------------------
 if(keyword_set(filetype)) then (*self.dd0p).filetype = filetype $
 else (*self.dd0p).filetype = dat_detect_filetype(/default)

 if(keyword_set(htype)) then (*self.dd0p).htype = htype $
 else (*self.dd0p).htype = dat_detect_filetype(/default)

 ;----------------------------
 ; data and abscissa labels
 ;----------------------------
 (*self.dd0p).label_data = 'Data'
 if(keyword_set(label_data)) then (*self.dd0p).label_data = label_data

 (*self.dd0p).label_abscissa = 'Abscissa'
 if(keyword_set(label_abscissa)) then (*self.dd0p).label_abscissa = label_abscissa


 ;-----------------------
 ; I/O methods
 ;-----------------------
 self.io_keyvals_p = nv_ptr_new('')

 if((NOT keyword_set(input_fn)) OR (NOT keyword_set(output_fn))) then $
    dat_lookup_io, (*self.dd0p).filetype, $
               _input_fn, _output_fn, _keyword_fn, io_keyvals

 if(keyword_set(input_fn)) then self.input_fn = input_fn $
 else if(keyword_set(_input_fn)) then self.input_fn = _input_fn $
    else nv_message, /continue, $
              'No input method available for ' + (*self.dd0p).filetype + '.'

 if(keyword_set(output_fn)) then self.output_fn = output_fn $
 else if(keyword_set(_output_fn)) then self.output_fn = _output_fn $
    else nv_message, /continue, $
              'No output method available for ' + (*self.dd0p).filetype + '.'

 if(keyword_set(keyword_fn)) then self.keyword_fn = keyword_fn $
 else if(keyword_set(_keyword_fn)) then self.keyword_fn = _keyword_fn

 if(keyword_set(io_keyvals)) then $
      self.io_keyvals_p = nv_ptr_new(dat_parse_keyvals(io_keyvals))


 ;-----------------------
 ; instrument
 ;-----------------------
 if(keyword_set(instrument)) then self.instrument = instrument $
 else self.instrument = dat_detect_instrument(self)
 if(self.instrument EQ '') then $
                   nv_message, /continue, 'Unable to detect instrument.'


 ;-----------------------
 ; translators
 ;-----------------------
 self.input_translators_p = nv_ptr_new('')
 self.output_translators_p = nv_ptr_new('')
 self.tr_keyvals_p = nv_ptr_new('')
 if((NOT keyword_set(input_translators)) OR $
                        (NOT keyword_set(output_translators))) then $
  if(keyword_set(self.instrument)) then $
   begin
    dat_lookup_translators, self.instrument, tab_translators=tab_translators, $
                             _input_translators, _output_translators, tr_keyvals

    if(keyword_set(input_translators)) then *self.input_translators_p = input_translators $
    else if(keyword_set(_input_translators)) then *self.input_translators_p = _input_translators $
    else nv_message, /continue, $
              'No input translators available for ' + self.instrument + '.'

    if(keyword_set(output_translators)) then *self.output_translators_p = output_translators $
    else if(keyword_set(_output_translators)) then *self.output_translators_p = _output_translators $
    else nv_message, /continue, $
              'No output translators available for ' + self.instrument + '.'

    if(keyword_set(tr_keyvals)) then $
                   self.tr_keyvals_p = nv_ptr_new(dat_parse_keyvals(tr_keyvals))
   end



 ;---------------------------------
 ; handle giving last sibling
 ;---------------------------------
 if(NOT keyword_set(self.sibling_dd_h)) then self.sibling_dd_h = handle_create()

 ;---------------------------------
 ; dimensions
 ;---------------------------------
 if(keyword_set(dim)) then *self.dim = dim		;;;;;


 ;-----------------------
 ; cache size
 ;-----------------------
 if(keyword_set(cache)) then (*self.dd0p).cache = cache $
 else (*self.dd0p).cache = dat_cache()


 ;---------------------------------
 ; transforms
 ;---------------------------------
 self.input_transforms_p = nv_ptr_new('')
 self.output_transforms_p = nv_ptr_new('')
 self.tf_keyvals_p = nv_ptr_new('')
 if((NOT keyword_set(input_transforms)) OR $
                        (NOT keyword_set(output_transforms))) then $
  if(keyword_set(self.instrument)) then $
   begin
    dat_lookup_transforms, self.instrument, tab_transforms=tab_transforms, $
                             _input_transforms, _output_transforms, tf_keyvals

    if(keyword_set(input_transforms)) then *self.input_transforms_p = input_transforms $
    else if(keyword_set(_input_transforms)) then *self.input_transforms_p = _input_transforms $
    else nv_message, verb=0.5, $
              'No input transforms available for ' + self.instrument + '.'

    if(keyword_set(output_transforms)) then *self.output_transforms_p = output_transforms $
    else if(keyword_set(_output_transforms)) then *self.output_transforms_p = _output_transforms $
    else nv_message, verb=0.5, $
              'No output transforms available for ' + self.instrument + '.'

    if(keyword_set(tr_keyvals)) then $
                   self.tf_keyvals_p = nv_ptr_new(dat_parse_keyvals(tf_keyvals))
   end



 ;-----------------------
 ; data limits
 ;-----------------------
 self.max = -1d100
 self.min = 1d100

 if(defined(min)) then self.min = min
 if(defined(max)) then self.max = max

 if(defined(data)) then $
  begin
   self.max = max(data)
   self.min = min(data)
  end
 

 self.abmax = -1d100
 self.abmin = 1d100

 if(defined(abmin)) then self.abmin = abmin
 if(defined(abmax)) then self.abmax = abmax

 if(defined(abscissa)) then $
  begin
   self.abmax = max(abscissa)
   self.abmin = min(abscissa)
  end
 

 ;-----------------------
 ; data and header
 ;-----------------------
 (*self.dd0p).sample_p = nv_ptr_new(-1)
 (*self.dd0p).order_p = nv_ptr_new(-1)

 if(defined(data)) then dat_set_data, self, data, abscissa=abscissa, /noevent


 dat_set_nhist, self, nhist, /noevent


 _header = ''
 if(keyword_set(header)) then _header = header
 dat_set_header, self, _header, /noevent


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_data__define
;
;
; PURPOSE:
;	Structure defining the data descriptor.
;
;
; CATEGORY:
;	NV/SYS/DAT
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	data_dap:	Pointer to data archive containing the data 
;			and nhist past versions.
;
;	abscissa_dap:	Pointer to data archive containing the abscissa 
;			and nhist past versions.
;
;	header_dap:	Pointer to data archive containing the header 
;			and nhist past versions.
;
;	dap_index:	Index of archived data to use.  
;
;	dhp:		Pointer to detached header.
;
;	max:		Maximum data value.
;
;	min:		Minimum data value.
;
;	abmax:		Maximum abscissa value.
;
;	abmin:		Minimum abscissa value.
;
;	cache:		Max cache size data array.  Used to determine whether 
;			to load / unload data samples.  0 means infinite.
;
;	dim:		Array giving data dimensions.
;
;	slice_struct:	Structure containing array giving coordinates for a 
;			subarray.  If slice coordinates exist, the dat methods 
;			act as if the data descriptor contains only this slice of 
;			data.  Dimensions, min, and max are set accordingly.  
;			Dimensions of the subarray are the difference between 
;			the dimensions of the full array and the dimensionality 
;			of the slice coordinates.
;
;	typecode:	Data type code.
;
;	filename:	Name of data file.
;
;	filetype:	File type string determined by dat_detect_filetype.
;
;	htype:		Header type string determined by dat_detect_filetype.
;
;	input_transforms_p:	Pointer to list of input transform 
;				functions determined by dat_lookup_transforms.
;
;	output_transforms_p:	Pointer to list of output transform 
;				functions determined by dat_lookup_transforms.
;
;	input_fn:	Name of function to read data file.
;
;	output_fn:	Name of function to write data file.
;
;	keyword_fn:	Name of function to read/write header keywords.
;
;	instrument:	Instrument string from dat_detect_instrument.
;
;	input_translators_p:	Pointer to list of input translator 
;				functions determined by dat_lookup_translators.
;
;	output_translators_p:	Pointer to list of output translator 
;				functions determined by dat_lookup_translators.
;
;	tr_keyvals_p:		Keyword/value pairs for translators.
;
;	tr_transient_keyvals_p:	Transient keyword/value pairs found in the 
;				translator argument string.
;
;	io_keyvals_p:		Keyword/value pairs for I/O methods.
;
;	io_transient_keyvals_p:	Transient keyword/value pairs found in the 
;				io method argument string.
;
;	sampling_fn:		Optional function to perform a transformation
;				on the samples given to dat_data():
;
;				function sampling_fn, dd, samples, data
;
;	dim_fn:			Optional function to cause dat_dim() to report
;				dimensions other than those stored in the
;				data descriptor:
;
;				function dim_fn, dd, data
;
;	compress:	Compression suffix.  The full name of the 
;			compression function is dat_compress_data_<suffix>.
;
;	compress_data_p:	Data for compression function.
;
;	maintain:	Data maintenance mode:
;				  0: load initially
;				  1: load when needed; retain
;				     only ndd data descriptor
;				     arrays in memory.
;				  2: Load when needed, but
; 				     do not retain.
;
;	update:		Data update mode:
;				 -1: Locked; applies to data, header,
;				     and udata.
;				  0: Normal
;				  1: Clone a new descriptor 
;				     and leave original dd
;				     unchanged.
;
;	sibling_dd_h:	Handle giving dd spawned as a result of writing to 
;			this descriptor while update = 1.  Handle is used 
;			to protect this dd from nv_free.
;;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================



;=============================================================================
; dat_dd0_struct__define
;
;=============================================================================
pro dat_dd0_struct__define


 struct = $
    { dat_dd0_struct, $
	data_dap:		nv_ptr_new(), $	; Pointer to the data archive
	abscissa_dap:		nv_ptr_new(), $	; Pointer to the abscissa archive
	header_dap:		nv_ptr_new(), $	; Pointer to the generic header archive
        dap_index:		0, $		; data archive index
	dhp:			nv_ptr_new(), $	; Pointer to detached header.
	sample_p:		nv_ptr_new(), $	; Pointer to the array of loaded samples
	order_p:		nv_ptr_new(), $	; Pointer to the sample load order array

	label_data:		'', $		; Label for data array
	label_abscissa:		'', $		; Label for abscissa array

	filename:		'', $		; Name of source file.
	filetype:		'', $		; File type string
	htype:			'', $		; Header type string
	typecode:		0b, $		; Data type code

	gffp:			nv_ptr_new(), $	; GFF pointer

	cache:			0l, $		; Max. cache size for data array (Mb)
						;  Doesn't apply to maintenance 0

	compress:		'', $		; Data compression function suffix
	compress_data_p:	nv_ptr_new(), $

	maintain:		0b, $		; Data maintenance mode:
						;  0: load initially
						;  1: load when needed; retain
						;     only ndd data descriptor
						;     arrays in memory.
						;  2: Load when needed, but
						;     do not retain.

	update:			0 $		; Data update mode:
						; -1: Locked; applies to data, header,
						;     and udata.
						;  0: Normal
						;  1: Clone a new descriptor 
						;     and leave original dd
						;     unchanged.
    }


end
;===========================================================================



;===========================================================================
; ominas_data__define
;
;===========================================================================
pro ominas_data__define


 struct = $
    { ominas_data, inherits ominas_core, $
	dd0p:			nv_ptr_new(), $	; Pointer to basic data descriptor
						; fields.  This allows these fields
						; to apply to any slices of this
						; data descriptor.

	slice_struct:		{dat_slice}, $	; Slice structure

	max:			0d, $		; Maximum data value
	min:			0d, $		; Minimum data value
	abmax:			0d, $		; Maximum abscissa value
	abmin:			0d, $		; Minimum abscissa value
	dim:			lonarr(8), $	; data dimensions

	input_fn:		'', $		; Function to read file
	output_fn:		'', $		; Function to write file
	keyword_fn:		'', $		; Function to read/write header keywords
	io_keyvals_p:		nv_ptr_new(), $	; Keyvals for I/O methods
	io_transient_keyvals_p:	nv_ptr_new(), $	; Keyvals parsed per-command

	instrument:		'', $		; Instrument string

	input_translators_p:	nv_ptr_new(), $	; Names of input translators
	output_translators_p:	nv_ptr_new(), $	; Names of output translators
	tr_keyvals_p:		nv_ptr_new(), $	; Keyvals for translators
	tr_transient_keyvals_p:	nv_ptr_new(), $	; Keyvals parsed per-command

	input_transforms_p:	nv_ptr_new(), $	; Input transform function
	output_transforms_p:	nv_ptr_new(), $	; Output transform function
	tf_keyvals_p:		nv_ptr_new(), $	; Keyvals for transforms
	tf_transient_keyvals_p:	nv_ptr_new(), $	; Keyvals parsed per-command

	sampling_fn:		'', $		; Optional sampling function.
	dim_fn:			'', $		; Optional dimension function.

	sibling_dd_h:		0l $		; Handle giving dd spawned as a result
						;  of writing to this descriptor
						;  while update = 1.
						;  Handle is used to protect that dd
						;  from nv_free.
    }


end
;===========================================================================


