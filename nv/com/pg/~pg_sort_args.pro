;=============================================================================
;+
; NAME:
;	pg_sort_args
;
;
; PURPOSE:
;	Sorts arguments to pg_get_* programs.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_sort_args, arg1, arg2, dd=dd, trs=trs
;
;
; ARGUMENTS:
;  INPUT:
;	arg1, arg2:	Input arguments from caller
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	dd:	Data descriptor.  If noen given, a dummy is 
;
;	trs:	Transient arguments; Null string if not given.
;
; RETURN: NONE
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================
pro pg_sort_args, arg1, arg2, dd=dd, trs=trs

 trs = ''

 if(size(arg, /type) EQ 7) then trs = append_array(trs, arg) $
 else if(keyword_set(arg)) then dd = arg
 if(NOT keyword_set(dd)) then $
      dd = dat_create_descriptors(inst='DEFAULT', uname='DUMMY', udata=1)
;      dd = dat_create_descriptors(inst='CAS_ISSNA', uname='DUMMY', udata=1)


end
;=============================================================================
