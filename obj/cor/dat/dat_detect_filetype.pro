;=============================================================================
;+
; NAME:
;	dat_detect_filetype
;
;
; PURPOSE:
;	Attempts to detect the type of the file (or header) associated with the
;	given data descriptor by calling the detectors in the filetype detectors 
;	table.  Detectors that crash are ignored and a warning is issued.  This
;	behavior is disabled if $OMINAS_DEBUG is set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	filetype = dat_detect_filetype(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor containing filename or header to test.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	filename:	Filename to test.  If not given, it is taken from the
;			data descriptor.
;
;	header:		Header to test.  If not given, it is taken from the
;			data descriptor.
;
;	default:	If set, the 'DEFAULT' filetype is returned.
;			The default filetype is the first item in the table.
;
;	all:		If set, all filetypes in the table are returned.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	String giving the type, or null string if none detected.  Detector 
;	functions take a single data descriptor argument and return a string
;	specifying the type.  If the data descriptor contains a header, then
;	the header type (htype) must be returned, otherwise the file type
;	is expected.
;	
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
function dat_detect_filetype, dd, $
             filename=filename, header=header, all=all

 dat_sort_detectors, filetype_detectors=filetype_detectors

 if(keyword_set(dd)) then $
  begin
   if(NOT keyword_set(filename)) then filename = dat_filename(dd)
   if(NOT keyword_set(header)) then header = dat_header(dd)
  end
 if(NOT keyword_set(filename)) then filename = ''
 if(NOT keyword_set(header)) then header = ''

 return, dat_detect(dd, filetype_detectors, $
                               filename=filename, header=header, all=all)
end
;=============================================================================



;=============================================================================
function _dat_detect_filetype, dd, filename=filename, header=header, $
                                                default=default, all=all
@nv_block.common
@core.include


 ;=====================================================
 ; read the filetype table if it doesn't exist
 ;=====================================================
;;;table = nv_table(/filetype)

 stat = 0
 if(NOT keyword_set(*nv_state.ftp_table_p)) then $
   dat_read_config, 'OMINAS_FILETYPE_TABLE', stat=stat, $
                nv_state.ftp_table_p, nv_state.ftp_detectors_filenames_p
 if(stat NE 0) then $
   nv_message, $
     'No filetype table.', /con, $
       exp=['The filetype table specifies the names of file type detector functions.', $
            'Without this table, OMINAS cannot read input data.']

 table = *nv_state.ftp_table_p

 ;=====================================================
 ; default type is the first entry 
 ;=====================================================
 if(keyword_set(default)) then return, table[0,1] 


 ;=====================================================
 ; /all means just return all filetypes
 ;=====================================================
 if(keyword_set(all)) then return, table[*,1] 


 ;======================================================================
 ; Call filetype detectors until true is returned
 ; 
 ; Crashes in the detectors are handled by issuing a warning and 
 ; contnuing to the next detector.
 ;======================================================================
 if(keyword_set(dd)) then $
  begin
   if(NOT keyword_set(filename)) then filename = dat_filename(dd)
   if(NOT keyword_set(header)) then header = dat_header(dd)
  end
 if(NOT keyword_set(filename)) then filename = ''
 if(NOT keyword_set(header)) then header = ''

 catch_errors = NOT keyword_set(nv_getenv('OMINAS_DEBUG'))
 s = size(table)
 n_ftp = s[1]
 for i=0, n_ftp-1 do $
  begin
   fn = table[i,0]
   filetype = table[i,1]
   nv_message, verb=0.8, 'Calling detector ' + fn

   if(NOT catch_errors) then err = 0 $
   else catch, err
   if(err EQ 0) then $
;           result = call_function(fn, dd, filename=filename, header=header) $
     result = call_function(fn, dd, {filename:filename, header:header}) $
   else nv_message, /warning, $
                'File type detector ' + strupcase(fn) + ' crashed; ignoring.'
   catch, /cancel

   if(keyword_set(result)) then nv_message, verb=0.8, filetype + ' detected.'
   if(keyword_set(result)) then return, filetype
  end

 return, ''
end
;===========================================================================
