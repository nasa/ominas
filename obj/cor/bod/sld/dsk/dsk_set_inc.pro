;=============================================================================
;+
; NAME:
;	dsk_set_inc
;
;
; PURPOSE:
;	Sets inc in each given disk descriptor.  This value is determined 
;	by the orientation of the BODY axes.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dsk_set_inc, bx, inc, frame_bd
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	 Array (nt) of any subclass of DISK.
;
;	inc:	 New inc value.
;
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One for each dkd.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
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
pro dsk_set_inc, dkd, inc, frame_bd
@core.include
 

 if(NOT keyword_set(frame_bd)) then nv_message, 'frame_bd required.'

 orb_set_inc, dkd, frame_bd, inc

end
;===========================================================================
