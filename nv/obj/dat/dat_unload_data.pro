;=============================================================================
;+
; NAME:
;	dat_unload_data
;
;
; PURPOSE:
;	Unloads the dat descriptor data array and removes dd from the NV
;	state maintained list if present.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_unload_data, dd
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
;	all:	If set, all maintained data descriptors are unloaded.
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
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_unload_data, dd, all=all
@nv_block.common
@core.include

 if(keyword_set(all)) then dd = *nv_state.dds_p
 if(NOT obj_valid(dd)) then return
;;; if(NOT keyword_set(*dd[0])) then return

 ndd = n_elements(dd)
 for i=0, ndd-1 do $
  begin
   _dd = cor_dereference(dd[i])

   data_archive_free, (*_dd.dd0p).data_dap

   dds =*nv_state.dds_p
   dds = rm_list_item(dds, 0, only=0)
   *nv_state.dds_p = dds
  end
end
;=============================================================================
