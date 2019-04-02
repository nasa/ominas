;=============================================================================
;+
; NAME:
;	dat_detect_instrument
;
;
; PURPOSE:
;	Attempts to detect the instrument for a data set by calling the 
;	detectors in the instrument detectors table.  Detectors that 
; 	crash are ignored and a warning is issued.  This behavior is disabled 
;	if $NV_DEBUG is set.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	instrument = dat_detect_instrument(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.  
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	String giving the instrument, or 'DEFAULT' if none detected.
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
function dat_detect_instrument, dd
@nv_block.common
@core.include

 ;=====================================================
 ; read the instrument table if it doesn't exist
 ;=====================================================
 stat = 0
 if(NOT keyword_set(*nv_state.ins_table_p)) then $
   dat_read_config, 'NV_INS_DETECT', stat=stat, $
              nv_state.ins_table_p, nv_state.ins_detectors_filenames_p
 if(stat NE 0) then $
   nv_message, $
     'No instrument table.', /con, $
       exp=['The instrument table specifies the names of instrument detector functions.', $
            'Without this table, OMINAS cannot determine which translators to use.']

 table = *nv_state.ins_table_p


 ;==============================================================
 ; Call instrument detectors of the specified filetype until 
 ; non-null string is returned.
 ;
 ; Crashes in the detects are handled by issuing a warning and 
 ; contnuing to the next detector.
 ;==============================================================
 catch_errors = NOT keyword_set(getenv('NV_DEBUG'))
 s = size(table)
 n_ins = s[1]
 for i=0, n_ins-1 do $
  begin
   detect_fn = table[i,0]

   if(NOT catch_errors) then err = 0 $
   else catch, err
   if(err EQ 0) then string = call_function(detect_fn, dd) $
   else nv_message, /warning, $
           'Instrument detector ' + strupcase(detect_fn) + ' crashed; ignoring.'
   catch, /cancel

   if(keyword_set(string)) then return, string
  end


 ;==============================================================
 ; Instrument is DEFAULT if none detected
 ;==============================================================
 nv_message, verb=0.9, 'No instrument detected; setting to DEFAULT.'
 return, 'DEFAULT'
end
;===========================================================================
