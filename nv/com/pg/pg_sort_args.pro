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
;	arg1, arg2:	Input arguments from caller.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	dd:	Data descriptor.  If none given, one is created using the 
;		DATA keywords (see below).
;
;	od:	Observer descriptor.  If no dd given, then thi descriptor
;		is used to determine the number of dd to create.
;
;	time:	Observation time.  If no dd or od given, then this array
;		is used to determine the number of dd to create.
;
;	trs:	Transient arguments; Null string if not given.
;
;	DATA Keywords
;	-------------
;	All DATA override keywords are accepted.  See dat__keywords.include. 
;	If the instrument keyword is no given, it is set to DEFAULT. 
;
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
pro pg_sort_args, arg1, arg2, dd=dd, od=od, time=time, $
                              trs=trs, free=free, $
                              @dat__keywords_tree.include
                              end_keywords

 trs = ''
 ddout = 0
 if(NOT keyword_set(instrument)) then instrument = 'DEFAULT'

 if(size(arg1, /type) EQ 7) then trs = arg1 $
 else if(keyword_set(arg1)) then $
  begin
   dd = arg1
   if(keyword_set(arg2)) then trs = arg2
  end $
 else ddout = 1

 if(NOT keyword_set(dd)) then $
  begin
    ndd = 1
    if(keyword_set(od)) then ndd = n_elements(od) $
    else if(keyword_set(time)) then ndd = n_elements(time)

    dd = dat_create_descriptors(ndd, $
                     @dat__keywords_tree.include
                     end_keywords )
    free = 1
  end

 if(ddout) then $
  begin
   arg1 = dd
   free = 0
  end


end
;=============================================================================
