;=============================================================================
;+
; NAME:
;       gen_spice_spk_detect
;
;
; PURPOSE:
;       Return filenames of SPKs approprate to given time, in correct order
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       files = gen_spice_spk_detect(dd, kpath, time=time) 
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;       kpath:          Path of the SPK files
;
;  OUTPUT: 
;	files:		Array of SPK filenames for use with cspice_furnsh
;
;
; KEYWORDS:
;  INPUT:
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for SPK coverage (optional if using /all)
;
;	all:		Return all SPKs
;
;	strict:		No function.  Included for consistent interface.
;
;  OUTPUT: NONE
;
;
; PROCEDURE:		Read SPK database
;                       Deterimine SPKs which have coverage for given time (or all)
;			Determine which time base to use for ordering: file system, PDS LBL time, or OMINAS timestamp
;                       Return ordered file list
;
; RESTRICTIONS:
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
function gen_spice_spk_detect, dd, kpath, $
                        sc=sc, all=all, time=_time, strict=strict

 return, gen_spice_kernel_detect(dd, kpath, 'sp', $
               djd=0d, sc=sc, time=_time, all=all, strict=strict)

end
;=============================================================================
