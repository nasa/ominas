;=============================================================================
;+
; NAME:
;	icv_reset_scan_precision
;
;
; PURPOSE:
;	Modifies the scan precision by rebinning the given image strip.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	icv_reset_scan_precision, strip, model, szero, mzero, precision
;
;
; ARGUMENTS:
;  INPUT:
;	strip:		Image strip to modify.
;
;	model:		Corresponding edge models.
;
;	szero:		Zero-offset position in the strip.
;
;	mzero:		Zero-offset position in the model.
;
;	precision:	New precision in inverse pixels.
;
;  OUTPUT: 
;	strip:		Modified image strip.
;
;	model:		Modified edge models.
;
;	szero:		Zero-offset position in the modified strip.
;
;	mzero:		Zero-offset position in the modified model.
;
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	NONE
;
;
; PROCEDURE:
;	The strip and model are rebinned by the specified precision factor
;	using cubic interpolation.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro icv_reset_scan_precision, strip, model, szero, mzero, precision

 ss=size(strip)
 sm=size(model)

 strip = rebin(strip, ss[1], precision*ss[2])
 model = rebin(model, sm[1], precision*sm[2])

 szero=szero*precision
 mzero=mzero*precision

end
;===========================================================================
