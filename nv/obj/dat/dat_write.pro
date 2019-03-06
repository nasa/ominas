;=============================================================================
;+
; NAME:
;	dat_write
;
;
; PURPOSE:
;	Writes a data file of arbitrary format.  Output methods that crash 
;	are ignored and a warning is issued.  This behavior is disabled if 
;	$NV_DEBUG is set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_write, filespec, dd <, keyvals>
;	dat_write, dd <, keyvals>
;
;
; ARGUMENTS:
;  INPUT:
;	filespec:	Array of strings giving file specifications for
;			file to write.  Data descriptor filespec is
;			updated unless /override. 
;
;	dd:		Array of data descriptors.  dd can also be given as the
;			first argument, in which case, the file specifications
;			are taken from the filename field of dd.  The number of
;			dd must match the number of filenames.
;
;	keyvals:	String giving keyword-value pairs to be passed to the 
;			output method.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	filetype:	Overrides data descriptor filetype (and thus the 
;			output function).  Data descriptor filetype is
;			updated unless /override.
;
;	output_fn:	Overrides data descriptor output function.  Data 
;			descriptor output_fn is updated unless /override.
;
;	override:	If set, filespec, filetype, and output_fn inputs
;			are used for this call, but not updated in the data
;			descriptor.
;
;	directory:	Replaces the diretory for the output file
;
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; PROCEDURE:
;	dat_write expands all file specifications and attempts to write a
;	file corresponding to each given data descriptor.  An error results
;	if the filespec expands to a different number of files than the number
;	of given data descriptors. 
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dat_read
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_write, arg1, arg2, arg3, nodata=nodata, $
		  filetype=_filetype, $
		  output_fn=_output_fn, $
                  override=override, directory=directory
@core.include
; on_error, 1

 ;--------------------------------------------------------------------------
 ; decipher args
 ;--------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; data descriptor as first arg
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 if(size(arg1, /type) EQ 11) then $
  begin
   dd = arg1
   filespec = dat_filename(dd)
   if(keyword_set(arg2)) then keyvals = arg2
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; file specification as first arg
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   dd = arg2
   filespec = arg1
   if(keyword_set(arg3)) then keyvals = arg3
  end
 if(NOT keyword_set(filespec)) then nv_message, 'No filename given.'

 if(keyword_set(directory)) then filespec = dir_rep(filespec, directory)

 dat_add_io_transient_keyvals, dd, keyvals
 _dd = cor_dereference(dd)

 ;------------------------------
 ; expand filespec
 ;------------------------------
 filenames = ''
 for i=0, n_elements(filespec)-1 do $
  begin
   ff = file_search(filespec[i])
   if(ff[0] NE '') then filenames = append_array(filenames, ff) $
   else filenames = append_array(filenames, filespec[i])
  end

 n_files = n_elements(filenames)
 ndd = n_elements(_dd)

 ;--------------------------------------------------------------------
 ; test for multiple dd per file.  If detected, then all data arrays
 ; are sent to the first filename; the output routine must support
 ; this mechanism
 ;--------------------------------------------------------------------
 if(n_files NE ndd) then nv_message, $
            'Number of file names must equal number of data descriptors."

 ;========================================
 ; write each file
 ;========================================
 for i=0, ndd-1 do $
  begin
   filename = filenames[i]
   if(filename EQ '') then nv_message, 'No file name for dd[' + strtrim(i,2) + '].'
   filename0 = (*_dd[i].dd0p).filename
   dat_set_filename, dd[i], filename

   ;------------------------------
   ; write detached header
   ;------------------------------
   dh_write, dh_fname(/write, filename), dat_dh(dd[i])

   ;------------------------------
   ; get filetype
   ;------------------------------
   if(keyword_set(_filetype)) then filetype = _filetype $
   else filetype = (*_dd[i].dd0p).filetype
   if(filetype EQ '') then nv_message, 'No file type for dd[' + strtrim(i,2) + '].'

   ;------------------------------
   ; get name of output routine
   ;------------------------------
   if(keyword_set(_output_fn)) then output_fn = _output_fn $
   else dat_lookup_io, filetype, input_fn, output_fn
   if(NOT keyword_set(output_fn)) then output_fn = _dd[i].output_fn

   if(output_fn EQ '') then nv_message, 'No file output method for dd[' + strtrim(i,2) + '].'

   ;--------------------------------------------
   ; transform the data if necessary
   ;--------------------------------------------
   dat_transform_output, dd[i]

   ;--------------------------------------------
   ; write data
   ;--------------------------------------------
   catch_errors = NOT keyword_set(getenv('NV_DEBUG'))
   if(NOT keyword_set(nodata)) then nv_message, verb=0.1, 'Writing ' + filename

   if(NOT catch_errors) then err = 0 $
   else catch, err

   if(err EQ 0) then status = call_function(output_fn, dd[i], nodata=nodata) $
   else nv_message, /warning, $
              'Output method ' + strupcase(output_fn) + ' crashed; ignoring.'

   catch, /cancel

   ;--------------------------------------------
   ; update fields if not overridden 
   ;--------------------------------------------
   if(NOT keyword_set(override)) then $
    begin
     if(keyword_set(filetype)) then (*_dd[i].dd0p).filetype = filetype
     if(keyword_set(output_fn)) then _dd[i].output_fn = output_fn
    end $
   else if(keyword_set(filespec)) then (*_dd[i].dd0p).filename = filename0
  end

 ;--------------------------------------------
 ; register events if not overridden
 ;--------------------------------------------
 if(NOT keyword_set(override)) then $
  begin
   cor_rereference, dd, _dd
   nv_notify, dd, type = 0, noevent=noevent
   nv_notify, /flush, noevent=noevent
  end

end
;===========================================================================
