;=============================================================================
;+
; NAME:
;	dat_header_value
;
;
; PURPOSE:
;	Reads and write header keyword values.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_header_value, dd, keyword, get=get, set=set
;
;
; ARGUMENTS:
;  INPUT: 
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the keyword to get or set.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	set:	New value to write to the specified keyword.
;
;
;  OUTPUT: NONE
;	get:	Value of the specified keyword read from the header.
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro dat_header_value, dd, keyword, get=get, set=set, noevent=noevent
@core.include
 if(arg_present(get)) then nv_notify, dd, type = 1, noevent=noevent

 _dd = cor_dereference(dd)

 header = dat_header(dd, /noevent)


 ;--------------------------------------------
 ; read
 ;--------------------------------------------
 if(arg_present(get)) then call_procedure, _dd.keyword_fn, header, keyword, get=get


 ;--------------------------------------------
 ; write
 ;--------------------------------------------
 if(arg_present(set)) then $
  begin
   call_procedure, _dd.keyword_fn, header, keyword, set=set
   dat_set_header, _dd, header		; this generates the write event
  end

end
;===========================================================================
