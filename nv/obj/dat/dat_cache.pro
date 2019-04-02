;=============================================================================
;+
; NAME:
;	dat_cache
;
;
; PURPOSE:
;	Returns a long integer indicating the maximum size of a data array.
;	This value may be adjusted using the environment variable 'DAT_CACHE'. 
;	-1 is returned if it cannot be determined.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	cache = dat_cache()
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;
;  OUTPUT: NONE
;
;
; ENVIRONMENT VARIABLES:
;	DAT_CACHE:	Sets the size of the cache.
;
;
; RETURN:
;	Current cache value.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2016
;	
;-
;=============================================================================
function dat_cache
@core.include

 cache = 0

 string = getenv('DAT_CACHE')
 if(keyword_set(string)) then cache = long(string) $
 else nv_message, verb=0.2, $
    'DAT_CACHE environment variable undefined.', $
     exp=['DAT_CACHE specifies that maximum size (Mb) for a data array in', $
          'maintenance modes 1 and 2.  Arrays smaller than this size are', $
          'held in memory.  Larger arrays are sampled as needed.  Set this', $
          'variable to enable caching.']

 return, cache
end
;===========================================================================



