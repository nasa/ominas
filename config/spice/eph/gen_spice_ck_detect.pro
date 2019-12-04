;=============================================================================
;+
; NAME:
;       gen_spice_ck_detect
;
;
; PURPOSE:
;       Return filenames of CKs approprate to given time, in correct order
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       files = gen_spice_ck_detect( ckpath, sc=sc, time=time ) 
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;       ckpath:         Path of the CK files
;
;  OUTPUT: 
;	files:		Array of CK filenames for use with cspice_furnsh
;
;
; KEYWORDS:
;  INPUT:
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for CK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;	all:		Return all CKs (time not needed in this case)
;	
;	strict:		No function.  Included for consistent interface.
;
;  OUTPUT: NONE
;
;
; PROCEDURE:		Read CK database
;                       Deterimine CKs which have coverage for given time (or all)
;			Determine which time base to use for ordering: file system, PDS LBL time, or OMINAS timestamp
;                       Return ordered file list
;
; RESTRICTIONS:
;			SCLK file and Leapseconds kernel need to be loaded
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     V. Haemmerle,  Feb. 2017
;	Addapted by:	J.Spitale      Feb. 2017
;-
;=============================================================================
function gen_spice_ck_detect, dd, ckpath, $
               djd=djd, sc=sc, time=_time, all=all, strict=strict

 return, gen_spice_kernel_detect(dd, ckpath, 'c', $
               djd=0d, sc=sc, time=_time, all=all, strict=strict)

end
;=============================================================================
