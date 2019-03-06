;=============================================================================
;+
; NAME:
;	dat_header_info
;
;
; PURPOSE:
;	Obtains header info specific to the given data descriptor by calling
;	an application-specific header program.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	info = dat_header_info(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.  
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	instrument:
;               Instrument stsring to use instead of that contained in the 
;               data descriptor.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Anonymous structure containing info relevant to the calling application.
;	An application specific program named <instrument>_<htype>_header_info()
;	Is called with the header as the only argmuent.  The output of that
;	program is returned by DAT_HEADER_INFO.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2017
;	
;-
;=============================================================================
function dat_header_info, dd, instrument=instrument, noevent=noevent
@core.include
 nv_notify, dd, type = 1, noevent=noevent

 _dd = cor_dereference(dd)

 if(NOT keyword_set(instrument)) then $
                            instrument = dat_instrument(_dd, noevent=noevent)
 htype = dat_htype(_dd, noevent=noevent)

 fn = strlowcase(instrument) + '_' + strlowcase(htype) + '_' + 'header_info'

 if(NOT routine_exists(fn)) then return, 0
 return, call_function(fn, dd)
end
;===========================================================================



