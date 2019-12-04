;=============================================================================
;+
; NAME:
;	bod_reorient
;
;
; PURPOSE:
;	Rotates the orientation matrix of each body such that the specified 
;	axis vector is parallel to the given vector.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bod_reorient, bx, index, v
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	Array (nt) of any subclass of BODY.
;
;	index:	Integer giving the reference body axis: 0, 1, or 2.
;
;	v:	Array (nv,3,nt) of column vectors to align with the
;		each reference axis.
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
;	
;-
;=============================================================================
pro bod_reorient, bx, ii, _v

 nt = n_elements(bx)
 sv = size(_v)
 nv = sv[1]

 v = v_unit(_v)

 orient = bod_orient(bx)
 vv = orient[ii,*,*]

 axis = v_unit(v_cross(vv, v))
 angle = v_angle(vv, v) ## make_array(3,val=1d)

 _orient = v_rotate_11(orient, axis[linegen3x(3,3,nt)], sin(angle), cos(angle))

 bod_set_orient, bx, _orient
end
;=================================================================================
