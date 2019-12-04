;=============================================================================
;+
; NAME:
;	dat_set_ndd
;
;
; PURPOSE:
;	Sets a new ndd value in the NV state structure.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_ndd, ndd
;
;
; ARGUMENTS:
;  INPUT:
;	ndd:	New ndd value.
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
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================
pro dat_set_ndd, ndd
@nv_block.common

 nv_state.ndd = ndd

end
;=============================================================================
