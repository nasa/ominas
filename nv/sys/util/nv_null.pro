;=============================================================================
;+
; NAME:
;       nv_null
;
; PURPOSE:
;       Returns !null unless an alternate null value is specifed.  
;
;
; CATEGORY:
;       NV/SYS/ARGV
;
;
; CALLING SEQUENCE:
;       val = nv_null(null=null)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS: 
;  INPUT: 
;	null:	Value to return instead of !null.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;       !null or any value given as an argument.
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Adapted from xidl_argv by:     Spitale 6/2018
;
;-
;=============================================================================
function nv_null, null=null
 if(defined(null)) then return, null
 return, !null
end
;=============================================================================
