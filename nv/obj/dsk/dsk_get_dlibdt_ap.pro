;=============================================================================
;+
; NAME:
;	dsk_get_dlibdt_ap
;
;
; PURPOSE:
;	Determines dlibdt_ap for each given disk descriptor, based on the
;	orientation of its BODY axes.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dlibdt_ap = dsk_dlibdt_ap(dkd, frame_bd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	dkd:	 Array (nt) of any subclass of DISK.
;
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One for each dkd.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;  OUTPUT: NONE
;
;
; RETURN:
;	dlibdt_ap value associated with each given disk descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dsk_get_dlibdt_ap, dkd, frame_bd
@core.include
 

 if(NOT keyword_set(frame_bd)) then nv_message, 'frame_bd required.'

 dlibdt_ap = orb_get_dlibdt_ap(dkd, frame_bd)

 return, dlibdt_ap
end
;===========================================================================



