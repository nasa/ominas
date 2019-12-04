;=============================================================================
;+
; NAME:
;	bod_recenter
;
;
; PURPOSE:
;	Transforms a body descriptor into another body frame.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bod_recenter, bx, bx0
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	Descriptor to transform, array (nt) of any subclass of BODY.
;
;	bx0:	Frame to transform into, array (nt) of any subclass of BODY.
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
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
pro bod_recenter, bx, bx0

 bod_set_avel, bx, bod_inertial_to_body(bx0, bod_avel(bx))
 bod_set_vel, bx, bod_inertial_to_body_vel(bx0, bod_vel(bx))
 bod_set_orient, bx, bod_inertial_to_body(bx0, bod_orient(bx))
 bod_set_pos, bx, bod_inertial_to_body_pos(bx0, bod_pos(bx))

end
;==================================================================================
