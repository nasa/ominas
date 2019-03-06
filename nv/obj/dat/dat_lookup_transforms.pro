;=============================================================================
;+
; NAME:
;	dat_lookup_transforms
;
;
; PURPOSE:
;	Looks up the names of the data input and output functions in
;	the I/O table.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_lookup_transforms, instrument, input_transforms, output_transforms
;
;
; ARGUMENTS:
;  INPUT:
;	instrument:	Instrument string from dat_detect_instrument.
;
;  OUTPUT:
;	input_transforms:	Array giving the names of the input transform 
;				functions.
;
;	output_transforms:	Array giving the names of the output transform 
;				functions.
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
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
pro dat_lookup_transforms, instrument, $
       input_transforms, output_transforms, keyvals, $
        tab_transforms=tab_transforms
@nv_block.common
@core.include


 input_transforms = ''
 output_transforms = ''

 ;=====================================================
 ; read the transforms table if it doesn't exist
 ;=====================================================
 stat = 0
 if(NOT keyword_set(*nv_state.trf_table_p)) then $
   dat_read_config, 'NV_TRANSFORMS', stat=stat, /con, $
              nv_state.trf_table_p, nv_state.transforms_filenames_p
 if(stat NE 0) then $
   nv_message, /con, $
     'No transforms table.', $
       exp=['The transforms table specifies the names of programs to transform', $
            'data values as they are read or written.  OMINAS should work fine', $
            'without this table, but some data sources may have problems.']


 table = *nv_state.trf_table_p
 if(NOT keyword_set(table)) then return


 ;==============================================================
 ; lookup the instrument string
 ;==============================================================
 status = dat_tf_table_extract(table, instrument, $
                          input_transforms, output_transforms, keyvals)

end
;===========================================================================
