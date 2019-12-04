;=============================================================================
;+
; NAME:
;       gen_spice_pck_detect
;
;
; PURPOSE:
;       Return filenames of PCKs approprate to given time, in correct order
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       files = gen_spice_pck_detect( pckpath, sc=sc, time=time ) 
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;       pckpath:         Path of the PCK files
;
;  OUTPUT: 
;	files:		Array of PCK filenames for use with cspice_furnsh
;
;
; KEYWORDS:
;  INPUT:
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for PCK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;	all:		Return all PCKs (time not needed in this case)
;	
;	strict:		No function.  Included for consistent interface.
;
;  OUTPUT: NONE
;
;
; PROCEDURE:		Read PCK database
;                       Deterimine PCKs which have coverage for given time (or all)
;			Determine which time base to use for ordering: file system, TEXT_KERNEL_ID time, or OMINAS timestamp
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
;       Modified by:    V. Haemmerle   Jun  2018
;-
;=============================================================================
function gen_spice_pck_detect, dd, pckpath, $
               djd=djd, sc=sc, time=_time, all=all, strict=strict

 return, gen_spice_kernel_detect(dd, pckpath, 'pc', $
               djd=0d, sc=sc, time=_time, all=all, strict=strict)

end
;=============================================================================
