;=============================================================================
;+
; NAME:
;	dat_set_header
;
;
; PURPOSE:
;	Replaces the header array associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_set_header, dd, header
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	header:	New header array.
;
;  OUTPUT:
;	dd:	Modified data descriptor.
;
;
; KEYWORDS:
;  INPUT: 
;	update:	Update mode flag.  If not given, it will be taken from dd.
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
; SEE ALSO:
;	dat_header
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_set_header, dd, header, update=update, noevent=noevent
@core.include
 _dd = cor_dereference(dd)

 if(NOT defined(update)) then update = (*_dd.dd0p).update
 if(update EQ -1) then return


 if((*_dd.dd0p).maintain GT 0) then $
  nv_message, /warning, verb=0.1, $
   'Changes to header array may be lost due to the maintainance level.'


 ;-----------------------------
 ; modify header array 
 ;-----------------------------
 if(keyword_set((*_dd.dd0p).header_dap)) then dap = (*_dd.dd0p).header_dap
 data_archive_set, dap, header, index=(*_dd.dd0p).dap_index
 (*_dd.dd0p).header_dap = dap
 (*_dd.dd0p).dap_index = 0


 ;--------------------------------------------
 ; generate write event
 ;--------------------------------------------
 cor_rereference, dd, _dd
 nv_notify, dd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent

end
;===========================================================================



