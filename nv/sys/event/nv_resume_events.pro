;=============================================================================
;+
; NAME:
;	nv_resume_events
;
;
; PURPOSE:
;	Resumes data event tracking.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	nv_resume_events
;
;
; ARGUMENTS:
;  INPUT: 
;	flush:		If set, the eent buffer is flushed after resuming
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
pro nv_resume_events, flush=flush
@nv_notify_block.common

 suspended = 0
 if(keyword_set(flush)) then nv_flush

end
;=============================================================================

