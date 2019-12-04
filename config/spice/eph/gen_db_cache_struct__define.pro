;=============================================================================
;+
; NAME:
;	gen_db_cache_struct__define
;
;
; PURPOSE:
;	Structure defining a cached kernel database.
;
;
; CATEGORY:
;	CONFIG/SPICE/EPH
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;
;
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro gen_db_cache_struct__define

 struct = $
    { gen_db_cache_struct, $
	filename:	'', $	
	dbp:		nv_ptr_new() $	
    }


end
;===========================================================================



