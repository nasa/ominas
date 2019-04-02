;=============================================================================
;+
; NAME:
;	dat_add_io_transient_keyvals
;
;
; PURPOSE:
;	Records keyword/value pairs from a transient argument string.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_add_io_transient_keyvals, dd, trs
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor in which to record transient keyvals.
;
;	trs:	Transient argument string.
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
; 	Written by:	Spitale, 7/2018
;	
;-
;=============================================================================
pro dat_add_io_transient_keyvals, dd, trs
@core.include
 
 _dd = cor_dereference(dd)

 w = where(ptr_valid(_dd.io_transient_keyvals_p))
 if(w[0] NE -1) then nv_ptr_free, _dd[w].io_transient_keyvals_p

 ;--------------------------------------------
 ; parse any transient keyvals
 ;--------------------------------------------
 if(keyword_set(trs)) then $
  begin
   keyvals = transpose(dat_parse_transient_keyvals(trs))
   if(keyword_set(keyvals)) then $
             _dd.io_transient_keyvals_p = nv_ptr_new(dat_parse_keyvals(keyvals))
  end

 cor_rereference, dd, _dd
end
;===========================================================================




