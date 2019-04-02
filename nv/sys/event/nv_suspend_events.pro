;=============================================================================
;+
; NAME:
;	nv_suspend_events
;
;
; PURPOSE:
;	Suspends data event tracking.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	nv_suspend_events
;
;
; ARGUMENTS:
;  INPUT: 
;	flush:		If set, the eent buffer is flushed before suspending
;			events.
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
pro nv_suspend_events, flush=flush
@nv_notify_block.common

 if(keyword_set(flush)) then nv_flush
 suspended = 1

end
;=============================================================================

