;=============================================================================
;+
; NAME:
;	dat_read
;
;
; PURPOSE:
;	Reads a data file of arbitrary format and produces a data descriptor.
;	Input methods that crash are ignored and a warning is issued.  This 
; 	behavior is disabled if $NV_DEBUG is set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dd = dat_read(filespec, data, header)
;	dd = dat_read(filespec, keyvals, data, header)
;
;
; ARGUMENTS:
;  INPUT:
;	filespec:	Array of strings giving file specifications for
;			file to read.  Each file specificaton must refer to
;			files of a uniform filetype.
;
;	keyvals:	String giving keyword-value pairs to be passed to the 
;			input method.
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
;	name:		Core name to assign to each data descriptor instead of 
;			deriving it from the file name.
;
;	extensions:	If given, these extensions are attempted for each file
;			specification, in addition to no extension.  If a file 
;			with the extension is not found, then the next extension 
;			is tried until no extensions are left to try.  If no 
;			extensions work, then the raw filename is attempted.  
;			This extension is not included in core name of the data 
;			descriptor.  The first character of the extension is
;			taken as the delimiter, so any delimiter may be used.
;			However, the delimiter must be conistent for all 
;			extensions.
;
;			Directives may be provided to control the selection of
;			file extensions using square brackets.  The following
;			directives are recognized:
;
;			+  select the file with the greatest number of extensions.
;
;			-  select the file with the smallest number of extensions.
;
;			n  select files with this number of extensions. 
;
;			n+ select files with this many or greater extensions. 
;
;			n- select files with this many or fewer extensions. 
;
;			Examples:
;			
;			 - To preferentially select files with a '.cal'
;			   extension, use:
;
;				extensions='.cal'
;
;			 - To preferentially select files with a '.cal'
;			   extension, or secondarily with a '.pht' extension, use:
;
;				extensions=['.cal','.pht']
;
;			 - To select only files with two extensions, use:
;
;				extensions=['.[2]']
;
;			 - To select only files with two or more extensions, use:
;
;				extensions=['.[2+]']
;
;	slice:		If set, and scalar (i.e., /slice), then the data are 
;			sliced by 1 dimension.  If not scalar, then the data
;			are sliced using these slice coordinates.
;
;
;  OUTPUT: 
;	abscissa:	Data abscissa.
;
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
function drd_read, filename, data, header, keyvals=keyvals, $
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
		  name=name, nhist=nhist


 count = 0

 ;---------------------------------
 ; read detached header
 ;---------------------------------
 dh_fname = dh_fname(filename)
 dh = dh_read(dh_fname)
 if(NOT dh_validate(dh)) then $
       nv_message, /con, name='dat_read', 'Invalid detached header: ' + dh_fname

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
 dat_lookup_io, filetype, input_fn, output_fn, keyword_fn, io_keyvals

 if(keyword_set(_input_fn)) then input_fn = _input_fn
 if(keyword_set(_output_fn)) then output_fn = _output_fn
 if(keyword_set(_keyword_fn)) then keyword_fn = _keyword_fnfn

 if(output_fn EQ '') then nv_message, verb=0.5, 'No output function available.'
 if(input_fn EQ '') then nv_message, verb=0.5, 'No input function available.'

 dat_add_io_transient_keyvals, dd, keyvals
 io_keyvals = dat_parse_keyvals(io_keyvals)


 ;-----------------------------------------
 ; add I/O functions to dd
 ;-----------------------------------------
 dat_assign, dd, /noevent, $
          filetype=filetype, $
          input_fn=input_fn, $
          output_fn=output_fn, $
          keyword_fn=keyword_fn, $
          io_keyvals=io_keyvals


 ;-----------------------------------------
 ; read data parameters and header
 ;-----------------------------------------
 catch_errors = NOT keyword_set(getenv('NV_DEBUG'))
 if(NOT keyword_set(nodata)) then $
		 nv_message, verb=0.1, 'Reading ' + filename

 if(NOT catch_errors) then err = 0 $
 else catch, err

 if(err EQ 0) then $
     _data = call_function(input_fn, dd, $
        	          _header, _dim, _typecode, _min, _max, $
        	                            /nodata, sample=sample, gff=gff) $
 else $
  begin
   nv_message, /warning, $
              'Input method ' + strupcase(input_fn) + ' crashed; ignoring.'
   return, 0
  end

 catch, /cancel



 if(NOT defined(_typecode)) then $
  begin
   if(defined(_data)) then _typecode = size(_data, /type) $
   else $
    begin
     nv_message, /warning, name='dat_read', $
                       'Type code not determined, converting to byte.'
     _typecode = 1
    end
  end

 if(NOT defined(_dim)) then $
  begin
   if(defined(_data)) then _dim = size(_data, /dim) $
   else $
    begin
     nv_message, /warning, name='dat_read', 'Dimensions not determined.'
     _dim = 0
    end
  end

 if(NOT defined(_min)) then $
  begin
   if(defined(_data)) then _min = min(_data) $
   else $
    begin
     nv_message, name='dat_read', /warning, $
                                   'Minimum data value not determined.'
     _min = 0
    end
  end

 if(NOT defined(_max)) then $
  begin
   if(defined(_data)) then _max = max(_data) $
   else $
    begin
     nv_message, /warning, name='dat_read', $
                                   'Maximum data value not determaxed.'
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
       input_translators, output_translators, tr_keyvals

     if(keyword_set(_input_translators)) then $
				   input_translators = _input_translators
     if(keyword_set(_output_translators)) then $
				   output_translators = _output_translators

     tr_keyvals = dat_parse_keyvals(tr_keyvals)
    end

   ;---------------------------------
   ; transforms
   ;--------------------------------- 
   if(keyword_set(instrument)) then $
    begin
     dat_lookup_transforms, instrument, tab_transforms=tab_transforms, $
       input_transforms, output_transforms, tf_keyvals

     if(keyword_set(_input_transforms)) then $
				   input_transforms = _input_transforms
     if(keyword_set(_output_transforms)) then $
				   output_transforms = _output_transforms

     dat_add_tf_transient_keyvals, dd, keyvals
     tf_keyvals = dat_parse_keyvals(tf_keyvals)
    end

   ;--------------------------
   ; complete data descriptor
   ;--------------------------
   dat_assign, dd, /noevent, $
         gff=gff, $
         instrument=instrument, $
         input_transforms=input_transforms, $
         output_transforms=output_transforms, $
         tf_keyvals=tf_keyvals, $
         input_translators=input_translators, $
         output_translators=output_translators, $
         tr_keyvals=tr_keyvals
  end


 return, dd
end
;===========================================================================



;=============================================================================
; drd_delim
;
;=============================================================================
function drd_delim, extensions

 delim = strmid(extensions, 0, 1)
 w = where(delim NE delim[0])
 if(n_elements(w) GT 1) then $
        nv_message, name='dat_read', 'All extension delimiters must be the same.'
 return, delim[0]
end
;=============================================================================



;=============================================================================
; drd_extensions
;
;=============================================================================
function drd_extensions, filename, delim
 s = str_nsplit(filename, delim)
 if(n_elements(s) EQ 1) then return, ''
 return, delim + s[1:*]
end
;=============================================================================



;=============================================================================
; drd_match_extensions
;
;=============================================================================
function drd_match_extensions, filename, extensions, all=all

 delim = drd_delim(extensions)

 if(keyword_set(all)) then $
  begin
   base = file_basename(filename)
   junk = str_nnsplit(base, delim, rem=ext)
   return, delim + ext
  end

 ff = str_flip(filename)
 ext = delim + str_flip(str_nnsplit(ff, delim))

 result = strarr(n_elements(filename))
 for k=n_elements(extensions)-2, 0, -1 do $
  begin
   w = where(ext EQ extensions[k])
   if(w[0] NE -1) then result[w] = extensions[k]
  end

 return, result
end
;=============================================================================



;=============================================================================
; drd_directives_exist
;
;=============================================================================
function drd_directives_exist, extensions
 p = strpos(extensions, '[')
 w = where(p NE -1)
 if(w[0] NE -1) then return, 1
 return, 0
end
;=============================================================================



;=============================================================================
; drd_strip
;
;=============================================================================
function drd_strip, filename, extensions

 if(NOT keyword_set(filename)) then return, ''

 if(drd_directives_exist(extensions)) then all=1
 ext = drd_match_extensions(filename, extensions, all=all)

 extlen = strlen(ext)
 len = strlen(filename)

 return, strmid_11(filename, 0, len-extlen)
end
;=============================================================================



;=============================================================================
; drd_match
;
;=============================================================================
function drd_match, filenames, filename, extensions, sub=w

 stripnames = drd_strip(filenames, extensions)
 stripname = drd_strip(filename, extensions)

 w = where(stripnames EQ stripname)

 return, w
end
;=============================================================================



;=============================================================================
; drd_expand
;
;=============================================================================
function drd_expand, filespec, extensions, $
                       filetypes=filetypes, basenames=basenames

 n_spec = n_elements(filespec)
 n_ext = n_elements(extensions)

 ;--------------------------------------------------------------------------
 ; expand file specifications
 ;--------------------------------------------------------------------------
 for j=0, n_spec-1 do $
  begin
   filetype = !null
   filename = !null
   basename = !null
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
     _filetype = dat_detect_filetype(filename=ff)

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; Attempt to expand filespec.  If the file type was not detected,
     ; then dat_expand will not find a query function and the filespec 
     ; will be expanded as if it's a disk file.
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     _filename = dat_expand(_filetype, ff)
     _basename = file_basename(drd_strip(_filename, extensions))

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; record items for this extension
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     filename = append_array(filename, _filename, /def)
     basename = append_array(basename, _basename, /def)
     filetype = append_array(filetype, $
                          make_array(n_elements(_filename), val=_filetype), /def)
    end

   w  = where(filename NE '')
   if(w[0] EQ -1) then $
             nv_message, /con, name='dat_read', 'No match: ' + filespec[j]

   filenames = append_array(filenames, filename, /def)
   basenames = append_array(basenames, basename, /def)
   filetypes = append_array(filetypes, filetype, /def)
  end

 w = where(filenames NE '')
 if(w[0] EQ -1) then return, !null
 filenames = filenames[w]
 basenames = basenames[w]
 filetypes = filetypes[w]

 return, filenames
end
;=============================================================================



;=============================================================================
; drd_parse_directive
;
;=============================================================================
function drd_parse_directive, filenames, extension
 if(NOT drd_directives_exist(extension)) then return, -1

 n = n_elements(filenames)
 delim = drd_delim(extension)

 directive = strmid(extension, 2, strlen(extension)-3)
 ext = drd_match_extensions(filenames, extension, /all)

 n_ext = lonarr(n)
 for i=0, n-1 do n_ext[i] = n_elements(drd_extensions(filenames[i], delim))

 ;-------------------------------------------------
 ; select filename with most extensions -- [+]
 ;-------------------------------------------------
 if(directive EQ '+') then return, where(n_ext EQ max(n_ext))

 ;-------------------------------------------------
 ; select filename with fewest extensions -- [-]
 ;-------------------------------------------------
 if(directive EQ '-') then return, where(n_ext EQ min(n_ext))
 
 ;-----------------------------------------------------------------
 ; select filenames with specified number of extensions -- [nn]
 ;-----------------------------------------------------------------
 w = str_isnum(directive)
 if(w[0] NE -1) then return, where(n_ext EQ long(directive))


 ;-----------------------------------------------------------------
 ; directives with trailing modifiers
 ;-----------------------------------------------------------------
 sym = str_tail(directive, 1, rem=arg)
 w = str_isnum(arg)
 if(w[0] NE -1) then $
  begin
   num = long(arg)

   ;-------------------------------------------------------------------------
   ; select filenames with specified number of extensions or more -- [nn+]
   ;-------------------------------------------------------------------------
   if(sym EQ '+') then return, where(n_ext GE num)

   ;-------------------------------------------------------------------------
   ; select filenames with specified number of extensions or fewer -- [nn-]
   ;-------------------------------------------------------------------------
   if(sym EQ '-') then return, where(n_ext LE num)
  end


 return, -1
end
;=============================================================================



;=============================================================================
; drd_select
;
;=============================================================================
pro drd_select, filenames, filetypes, basenames, extensions

 delim = drd_delim(extensions)

 ;-------------------------------------------------------
 ; loop over filenames
 ;-------------------------------------------------------
 sub = -1
 for i=0, n_elements(filenames)-1 do $
  begin 
   ;- - - - - - - - - - - - - - - - - - - - -
   ; find all matches for this filename
   ;- - - - - - - - - - - - - - - - - - - - -
   w = drd_match(filenames, filenames[i], extensions)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; if only one match, select it, otherwise select highest priority match
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(w[0] NE -1) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; proceed only if this match has not already been checked
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ww = nwhere(sub, w)
     if(ww[0] EQ -1) then $
      begin
       ;- - - - - - - - - - - - - - - - -
       ; get final extensions
       ;- - - - - - - - - - - - - - - - -
       nw = n_elements(w)
       ext0 = strarr(nw)
       for j=0, nw-1 do $
        begin
         ext = rotate(drd_extensions(filenames[w[j]], delim), 2)
         ext0[j] = ext[0]
        end

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; select filenames based on directives
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(drd_directives_exist(extensions)) then $
        begin
        for k=0, n_elements(extensions)-2 do $
  	 begin
          ii = drd_parse_directive(filenames[w], extensions[k])
          if(ii[0] NE -1) then sub = append_array(sub, w[ii], /pos)
         end
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; or select filename with highest-priority extension
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         if(n_elements(w) EQ 1) then sub = append_array(sub, w[0], /pos) $
         else $
          for k=0, n_elements(extensions)-1 do $
           begin
            ww = where(ext0 EQ extensions[k])
            if(ww[0] NE -1) then $
             begin
              sub = append_array(sub, w[ww[0]], /pos)
              break
             end
           end
         end
      end
    end
  end

 if(sub[0] EQ -1) then $
  begin
   filenames = (basenames = (filetypes = ''))
   return
  end

 filenames = filenames[sub]
 basenames = basenames[sub]
 filetypes = filetypes[sub]

 filenames = unique(filenames, sub=sub, /desort)
 basenames = basenames[sub]
 filetypes = filetypes[sub]
end
;=============================================================================



;=============================================================================
; dat__read
;
;=============================================================================
function dat__read, filespec, data, header, keyvals=keyvals, abscissa=abscissa, $
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
		  name=_name, nhist=nhist, $
		  extensions=extensions, latest=latest, $
                  count=count, slice=slice
@core.include


 if(NOT keyword_set(maintain)) then maintain = 0
 nodata = keyword_set(nodata)

 if(NOT keyword_set(extensions)) then extensions = '' $
 else extensions = [extensions, '']


 ;--------------------------------------------------------------------------
 ; expand file specifications including any extensions
 ;--------------------------------------------------------------------------
 filenames = drd_expand(filespec, extensions, $
                              filetypes=filetypes, basenames=basenames)
 if(NOT keyword_set(filenames)) then return, !null


 ;--------------------------------------------------
 ; select highest-priority matches
 ;--------------------------------------------------
 if(keyword_set(extensions)) then $
               drd_select, filenames, filetypes, basenames, extensions


 ;--------------------------------------------------
 ; read files
 ;--------------------------------------------------
 if(NOT keyword_set(filenames)) then $
  begin
   nv_message, /con, 'No files.'
   return, !null
  end

 for i=0, n_elements(filenames)-1 do $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Second attempt to detect file type:
   ;  This time the filespec will have been expanded, so we make 
   ;  another attempt if there's still no filetype.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   filetype = filetypes[i]
   if(NOT keyword_set(filetype)) then $
 		 filetype = dat_detect_filetype(filename=filenames[i])

   if(NOT keyword_set(filetype)) then $
        nv_message, /con, 'Unable to detect file type: ' + filenames[i] $
   else $
    begin
      if(NOT keyword_set(_name)) then name = basenames[i] $
      else name = _name

      ddi = drd_read(filenames[i], data, header, keyvals=keyvals, $
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
;       	 tab_transforms=tab_transforms, $
        	 maintain=maintain, compress=compress, $
        	 sample=sample, nodata=nodata, $
        	 name=name, nhist=nhist)
      if(keyword_set(ddi)) then $
       begin
        if(keyword_set(slice)) then $
         begin
          if(size(slice, /dim) EQ 0) then $
                           ddi = dat_slices(ddi, data, abscissa=abscissa) $
          else ddi = dat_slices(ddi, slice, data, abscissa=abscissa)
         end $
        else if(arg_present(data)) then dat_load_data, ddi, data=data, abscissa=abscissa

        dd = append_array(dd, ddi)
        found = 1
       end
    end
  end

 if(NOT keyword_set(dd)) then $
  begin
   nv_message, /con, 'No files.'
   return, !null
  end

; drd_outputs, arg1, arg2, arg3, data, header

 count = n_elements(dd)
 return, dd
end
;===========================================================================




;=============================================================================
; dat_read
;
;=============================================================================
function dat_read, filespec, arg1, arg2, arg3, abscissa=abscissa, $
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
		  name=_name, nhist=nhist, $
		  extensions=extensions, latest=latest, $
                  count=count, slice=slice


 if(size(arg1, /type) EQ 7) then $
    return, dat__read(filespec, arg2, arg3, keyvals=arg1, abscissa=abscissa, $
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
		  name=_name, nhist=nhist, $
		  extensions=extensions, latest=latest, $
                  count=count, slice=slice )


 return, dat__read(filespec, arg1, arg2, abscissa=abscissa, $
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
		  name=_name, nhist=nhist, $
		  extensions=extensions, latest=latest, $
                  count=count, slice=slice )


end
;=============================================================================
