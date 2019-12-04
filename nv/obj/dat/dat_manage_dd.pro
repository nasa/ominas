;=============================================================================
;+
; NAME:
;	dat_manage_dd
;
;
; PURPOSE:
;	Adds a data descriptor to the NV state maintained list.  If the list
;	is full, the oldest descriptor is unloaded and removed.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_manage_dd, dd
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
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
pro dat_manage_dd, dd
@nv_block.common

 ;------------------------------------------------
 ; add dd to list
 ;------------------------------------------------
 dds = *nv_state.dds_p

 if(keyword_set(dds)) then $
  begin
   w = where(dds EQ dd)
   if(w[0] NE -1) then return
  end

 dds = append_array(dds, dd)

 *nv_state.dds_p = dds
 ndd = n_elements(dds)

 ;------------------------------------------------
 ; unload any extra dds
 ;------------------------------------------------
 if(nv_state.ndd EQ 0) then return

 if(ndd GE nv_state.ndd) then dat_unload_data, dds[0]

end
;=============================================================================
