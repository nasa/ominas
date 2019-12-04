;=============================================================================
;+
; NAME:
;	dat_gd
;
;
; PURPOSE:
;	Dereferences a given generic descriptor, or the generic descriptor
;	contained in a data descriptor.  Similar to cor_gd, but data
;	descriptors are handled specially.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	xd = dat_gd(gd, <descriptor keywords>)
;
;
; ARGUMENTS:
;  INPUT:
;	gd:	Generic descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	dd:	Data descriptor.  If gd is undefined, the generic descriptor 
;		contained in this data descriptor is used instead.  If this
;		keyword is set (i.e., /dd), then it is treated like the
;		other descriptor keywords and a data desctipro is returned
;		if one exists in the generic descriptor.
;	
;	<x>d:	Standard descriptor keywords.  Setting a keyword causes the
;		corresponding field of the generic descriptor to be returned
;		in the output array.
;
;  OUTPUT: NONE
;
;
; RETURN: Array of descriptors corresponding to the selected keywords. 
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
function dat_gd, _gd, dd=dd, _ref_extra=keys

 ;---------------------------------------------
 ; determine which generic descriptor to use
 ;---------------------------------------------
 if(keyword_set(_gd)) then gd = _gd
 if(NOT keyword_set(gd)) then if(cor_test(dd)) then gd = cor_gd(dd)
 if(NOT keyword_set(gd)) then return, !null


 ;----------------------------------------------------------
 ; look up requested descriptors
 ;----------------------------------------------------------
 xds = cor_dereference_gd(gd, _extra=keys)


 ;----------------------------------------------------------
 ; handle requested dd specially
 ;----------------------------------------------------------
 if(keyword_set(dd)) then if(NOT cor_test(dd)) then $
            xds = append_array(xds, cor_dereference_gd(gd, /dd))

 return, xds
end
;===========================================================================



