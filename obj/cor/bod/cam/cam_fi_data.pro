;=============================================================================
;+
; NAME:
;	cam_fi_data
;
;
; PURPOSE:
;	Returns the focal/image function data for a camera descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	data = cam_fi_data(cd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	cd:	 Camera descriptor.
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
;	Function data associated with the given camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Adapted by:	Spitale, 7/2016; adapted from cam_fi_data_p
;	
;-
;=============================================================================
function cam_fi_data, cd, noevent=noevent
@core.include
 return, cor_udata(cd, 'CAM_FI_DATA', noevent=noevent)
end
;===========================================================================
