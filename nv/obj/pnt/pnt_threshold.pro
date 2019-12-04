;=============================================================================
;+
; NAME:
;	pnt_threshold
;
;
; PURPOSE:
;	Flags points whose given indicator falls below or above a given 
;	threshold.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	pnt_threshold, ptd, indicators, threshold, /above
;	pnt_threshold, ptd, indicators, threshold, /below
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:		POINT object.
;
;	indicators:	Values to be tested against the threshold.  One for 
;			each point in ptd.
;
;	threshold:	Threshold value.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	above:	If set, values above the theshold are allowed.
;
;	below:	If set, values below the theshold are allowed.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE.
;
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pgs_threshold
;	
;-
;=============================================================================
pro pnt_threshold, ptd, indicators, threshold, above=above, below=below
@pnt_include.pro

 if(NOT keyword__set(ptd)) then return

 ;-----------------------------
 ; apply threshold
 ;-----------------------------
 if(keyword_set(above)) then w = where(indicators LT threshold)
 else if(keyword_set(below)) then w = where(indicators GT threshold)

 if(w[0] EQ -1) then return

 ;-----------------------------
 ; set flags
 ;-----------------------------
 flags = pnt_flags(ptd)
 flags[w] = flags[w] AND PTD_MASK_INVISIBLE
 pnt_set_flags, ptd, flags

end
;===========================================================================
