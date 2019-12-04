;=============================================================================
;+
; NAME:
;	dat_read
;
;
; PURPOSE:
;	Reads a data file of arbitrary format and produces a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dd = dat_read(filespec [, data, header])
;
;
; ARGUMENTS:
;  INPUT:
;	filespec:	Array of strings giving file specifications for
;			file to read.  Each file specificaton must refer to
;			files of a uniform filetype.
;
;  OUTPUT:
;	data:		Data array from the last file read.  This is provided
;			as a convenience when reading single files so that
;			it is not necessary to call dat_data to get the array.
;
;	header:		Header array from the last file read.  This is provided
;			as a convenience when reading single files so that
;			it is not necessary to call dat_header to get the array.
;
;
; KEYWORDS:
;  INPUT:
;	filetype:	Overrides automatic file type detection.
;
;	htype:		Overrides automatic  header type detection.
;
;	input_fn:	Overrides input function lookup.
;
;	output_fn:	Overrides output function lookup.
;
;	tab_translators:	Name of translators table to use instead of 
;				that given by the environment variable
;				NV_TRANSLATORS.  If no path is given, then the
;				file is assumed to reside in the same directory
;				as the translator named by the NV_TRANSLATORS
;				environment variable.
;
;	input_translator:	Use this input translator name instead of
;				looking it up in the table.
;
;	output_translator:	Use this output translator name instead of
;				looking it up in the table.
;
;	instrument:	Use this instrument name instead of attempting to 
;			detect it.
;
;	sample:		Vector giving the sampling indices in the input data 
;			file.  This parameter is passed through to the input 
;			function, which may choose to ignore it.
;
;	
;
;	extensions:	If given, these extensions are attempted for each file.
;			If a file with the extension is not found, then the next
;			extension is tried until no extensions are left to try.
;			If no extensions work, then the raw filename is 
;			attempted.  This extension is not included in core name
;			of the data descriptor.
;
;
;  OUTPUT: 
;	count:		Number of descriptors returned.
;
;
;  ENVIRONMENT VARIABLES:
;	NV_TRANSLATORS:		Name(s) of the translators table(s) to use unless 
;				overridden by the tab_translators keyword.
;				Multiple table names are delimited with ':'.
;
;	NV_FTP_DETECT:		Name(s) of the filetype detectors table(s).		
;				Multiple table names are delimited with ':'.
;
;	NV_IO:			Name(s) of the I/O table(s).		
;				Multiple table names are delimited with ':'.
;
;	NV_INS_DETECT:		Name(s) of the instrument detectors table(s).			
;				Multiple table names are delimited with ':'.
;
;
; RETURN:
;	Array of data descriptors - one for each file resulting from the
;	expansion of the given file specifications.
;
;
; PROCEDURE:
;	For each file specification, DAT_READ detets the filetype and then 
;	expands the specification according to that filetype.  For each 
;	resulting file, DAT_READ looks up the I/O functions and calls the 
;	input function to read the file and build a data descriptor.  
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dat_write
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================



;=============================================================================
; drd_read
;
;=============================================================================
function drd_read, filename, data, header, $
		  filetype=filetype, $
		  htype=_htype, $
		  input_fn=_input_fn, $
		  output_fn=_output_fn, $
		  keyword_fn=_keyword_fn, $
		  instrument=_instrument, $
		  input_translators=_input_translators, $
		  output_translators=_output_translators, $
		  input_transforms=_input_transforms, $
		  output_transforms=_output_transforms, $
                  tab_translators=tab_translators, $
;                  tab_transforms=tab_transforms, $
                  maintain=maintain, compress=compress, $
                  sample=sample, nodata=nodata, $
		  name=_name, extension=extension, nhist=nhist


 count = 0

 ;---------------------------------
 ; read detached header
 ;---------------------------------
 dh_fname = dh_fname(filename)
 dh = dh_read(dh_fname)
 if(NOT dh_validate(dh)) then $
                  nv_message, /con, 'Invalid detached header: ' + dh_fname

 ;-----------------------------------------------------------------
 ; use base filename as id string (minus any extra extension)
 ;-----------------------------------------------------------------
 if(keyword_set(_name)) then name = _name[i] $
 else name = file_basename(filename, extension)
  
 ;-----------------------------------------
 ; set up initial data descriptor
 ;-----------------------------------------
 dd = dat_create_descriptors(1, $
         filename=filename, $
         dh=dh, $
         name=name, $
         nhist=nhist, $
         maintain=maintain, $
         compress=compress, $
         tab_translators=tab_translators)


 ;------------------------
 ; look up I/O functions
 ;------------------------
 if(NOT keyword_set(_input_fn) OR NOT keyword__set(_output_fn)) then $
		     dat_lookup_io, filetype, input_fn, output_fn, keyword_fn

 if(keyword_set(_input_fn)) then input_fn = _input_fn
 if(keyword_set(_output_fn)) then output_fn = _output_fn
 if(keyword_set(_keyword_fn)) then keyword_fn = _keyword_fnfn

 if(output_fn EQ '') then nv_message, verb=0.5, 'No output function available.'
 if(input_fn EQ '') then nv_message, verb=0.5, 'No input function available.'


 ;-----------------------------------------
 ; add I/O functions to dd
 ;-----------------------------------------
 dat_assign, dd, /noevent, $
          filetype=filetype, $
          input_fn=input_fn, $
          output_fn=output_fn, $
          keyword_fn=keyword_fn


 ;-----------------------------------------
 ; read data parameters and header
 ;-----------------------------------------
 if(NOT keyword_set(nodata)) then $
		 nv_message, verb=0.1, 'Reading ' + filename
 _data = call_function(input_fn, dd, $
        	  _header, _dim, _typecode, _min, _max, $
        			   /nodata, sample=sample, gff=gff)

 if(NOT defined(_typecode)) then $
  begin
   if(defined(_data)) then _typecode = size(_data, /type) $
   else $
    begin
     nv_message, /con, 'WARNING: Type code not determined, converting to byte.'
     _typecode = 1
    end
  end

 if(NOT defined(_dim)) then $
  begin
   if(defined(_data)) then _dim = size(_data, /dim) $
   else $
    begin
     nv_message, /con, 'WARNING: Dimensions not determined.'
     _dim = 0
    end
  end

 if(NOT defined(_min)) then $
  begin
   if(defined(_data)) then _min = min(_data) $
   else $
    begin
     nv_message, /con, 'WARNING: Minimum data value not determined.'
     _min = 0
    end
  end

 if(NOT defined(_max)) then $
  begin
   if(defined(_data)) then _max = max(_data) $
   else $
    begin
     nv_message, /con, 'WARNING: Maximum data value not determaxed.'
     _max = 0
    end
  end

 ;---------------------------------
 ; check for multiple data arrays
 ;---------------------------------
 multi = 0
 nn = 1
 if(size(_dim, /type) EQ 10) then $
  begin
   multi = 1
   nn = n_elements(_dim)
  end

 ;---------------------------------
 ; loop over all data arrays 
 ;---------------------------------
 for j=0, nn-1 do $
  begin
   if(multi) then $
    begin
     if(keyword_set(_header)) then header = *_header[j]
     dim = *_dim[j]
     typecode = _typecode[j]
     min = _min[j]
     max = _max[j]
    end $
   else $
    begin
     if(keyword_set(_header)) then header = _header
     dim = _dim
     typecode = _typecode
     min = _min
     max = _max
    end 

   ;-----------------------------------------
   ; add data parameters and header to dd
   ;-----------------------------------------
   dat_assign, dd, /noevent, $
	 header=header, $
         min=min, $
         max=max, $
         dim=dim, $
         typecode=typecode

   ;------------------------------
   ; get header type
   ;------------------------------
   if(NOT keyword_set(_htype)) then htype = dat_detect_filetype(dd) $
   else htype = _htype
   dat_set_htype, dd, htype, /noevent

   ;-----------------------
   ; instrument
   ;-----------------------
   if(NOT keyword_set(_instrument)) then  $
    begin
     instrument = dat_detect_instrument(dd)
     nv_message, verb=0.9, 'Instrument = ' + instrument
    end $
   else instrument = _instrument

   ;---------------------------------
   ; translators
   ;--------------------------------- 
   if(keyword_set(instrument)) then $
    begin
     dat_lookup_translators, instrument, tab_translators=tab_translators, $
       input_translators, output_translators, $
       input_keyvals, output_keyvals

     if(keyword_set(_input_translators)) then $
				   input_translators = _input_translators
     if(keyword_set(_output_translators)) then $
				   output_translators = _output_translators
     if(keyword_set(_input_keyvals)) then input_keyvals = _input_keyvals
     if(keyword_set(_output_keyvals)) then output_keyvals = _output_keyvals

     input_keyvals = dat_parse_keyvals(input_keyvals)
     output_keyvals = dat_parse_keyvals(output_keyvals)
    end

   ;---------------------------------
   ; transforms
   ;--------------------------------- 
   if(keyword_set(instrument)) then $
    begin
     dat_lookup_transforms, instrument, tab_transforms=tab_transforms, $
       input_transforms, output_transforms

     if(keyword_set(_input_transforms)) then $
				   input_transforms = _input_transforms
     if(keyword_set(_output_transforms)) then $
				   output_transforms = _output_transforms
    end

   ;--------------------------
   ; complete data descriptor
   ;--------------------------
   dat_assign, dd, /noevent, $
         gff=gff, $
         instrument=instrument, $
         input_transforms=input_transforms, $
         output_transforms=output_transforms, $
         input_translators=input_translators, $
         output_translators=output_translators, $
         input_keyvals=input_keyvals, $
         output_keyvals=output_keyvals
  end


 return, dd
end
;===========================================================================



;=============================================================================
; dat_read
;
;=============================================================================
function dat_read, filespec, data, header, $
		  filetype=filetype, $
		  input_fn=input_fn, $
		  output_fn=output_fn, $
		  keyword_fn=keyword_fn, $
		  instrument=instrument, $
		  input_translators=input_translators, $
		  output_translators=output_translators, $
		  input_transforms=input_transforms, $
		  output_transforms=output_transforms, $
                  tab_translators=tab_translators, $
;                  tab_transforms=tab_transforms, $
                  maintain=maintain, compress=compress, $
                  sample=sample, nodata=nodata, $
		  name=name, nhist=nhist, $
		  extensions=extensions, $
                  count=count
@core.include

 if(NOT keyword_set(maintain)) then maintain = 0
 nodata = keyword_set(nodata)

 if(NOT keyword_set(extensions)) then extensions = '' $
 else extensions = [extensions, '']

 n_spec = n_elements(filespec)
 n_ext = n_elements(extensions)

 ;--------------------------------------------------------------------------
 ; Read files
 ;--------------------------------------------------------------------------
 for j=0, n_spec-1 do $
  begin
   for k=0, n_ext-1 do $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; add extension
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ff = filespec[j] + extensions[k]

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Attempt to detect file type:
     ;  If the filespec contains wildcards, this may not work
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     filetype = dat_detect_filetype(filename=ff)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Attempt to expand filespec.  If the file type was not detected,
     ; then dat_expand will not find a query function and the filespec 
     ; will be expanded as if it's a disk file.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     filenames = dat_expand(filetype, ff)

     ;- - - - - - - - - - - - - - - - -
     ; read each file
     ;- - - - - - - - - - - - - - - - -
     if(keyword_set(filenames)) then $
      for i=0, n_elements(filenames)-1 do $
       begin
        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        ; Second attempt to detect file type:
        ;  This time the filespec will have been expanded, so we make 
        ;  another attempt if there's still no filetype.
        ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        if(NOT keyword_set(filetype)) then $
                      filetype = dat_detect_filetype(filename=filenames[i])

        if(NOT keyword_set(filetype)) then $
 	     nv_message, /con, 'Unable to detect file type: ' + filenames[i] $
        else $
         begin
           ddi = drd_read(filenames[i], data, header, $
			filetype=filetype, $
			input_fn=input_fn, $
			output_fn=output_fn, $
			keyword_fn=keyword_fn, $
			instrument=instrument, $
			input_translators=input_translators, $
			output_translators=output_translators, $
			input_transforms=input_transforms, $
			output_transforms=output_transforms, $
			tab_translators=tab_translators, $
;			tab_transforms=tab_transforms, $
			maintain=maintain, compress=compress, $
			sample=sample, nodata=nodata, $
			name=name, extension=extensions[k], $
 			nhist=nhist)
           if(arg_present(data)) then $
                        if(keyword_set(ddi)) then dat_load_data, ddi, data=data
           dd = append_array(dd, ddi)
           k = n_ext					; break out of the loop
         end
       end
    end
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; if loop over extensions finished natually, then no files were
   ; found for this filespec.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(k EQ n_ext) then $
          for k=0, n_ext-1 do $
                  nv_message, /con, 'Not found: ' + filespec[j] + extensions[k] 
  end

 if(NOT keyword_set(dd)) then return, !null


 count = n_elements(dd)
 return, dd
end
;===========================================================================


