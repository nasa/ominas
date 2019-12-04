;=============================================================================
;+
; NAME:
;	pg_retarg
;
;
; PURPOSE:
;	Modifies the camera orientation such that the optic axis points 
;	along a given vector, or toward a specified body.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_retarg, cd=cd, bx=bx
;
;
; ARGUMENTS:
;  INPUT: 
;	v:	Inertial vector giving new optic axis direction.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	 cd:	 Camera descriptor to repoint.
;
;	 bx:	 Body descriptor at which to point.
;
;	 gd:	 Generic descriptor.  If given, the descriptor inputs 
;		 are taken from this structure if not explicitly given.
;
;	 dd:	 Data descriptor containing a generic descriptor to use
;		 if gd not given.
;
;	 toward: Camera should be pointed toward bx (default).
;
;	 away:   Camera should be pointed away from bx.
;
;	along:   Index of bx axis along which to point.
;
;
;  OUTPUT:
;	NONE.
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	pg_retarg modifies cd and adds its name to the task list of each given
;	descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2007
;	
;-
;=============================================================================
pro pg_retarg, v, cd=cd, bx=bx, ref_bx=ref_bx, dd=dd, gd=gd, toward=toward, away=away, along=along

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)


 if(NOT keyword_set(v)) then v = bod_pos(bx) - bod_pos(cd)
 if(defined(along)) then $
  begin
   v = (bod_orient(bx))[abs(along),*,*]
   if(along LT 0) then away = 1
  end

 if(keyword_set(away)) then v = -v

 ;-----------------------------------------------
 ; repoint
 ;-----------------------------------------------
 orient = bod_orient(cd)
 oaxis = orient[1,*,*]

 axis = v_unit(v_cross(v, oaxis))
 angle = v_angle(v, oaxis)

 sin = sin(-angle)
 cos = cos(-angle)
 orient[0,*,*] = v_rotate_11(orient[0,*,*], axis, sin, cos)
 orient[1,*,*] = v_rotate_11(orient[1,*,*], axis, sin, cos)
 orient[2,*,*] = v_rotate_11(orient[2,*,*], axis, sin, cos)

 bod_set_orient, cd, orient




 cor_add_task, cd, 'pg_retarg'
end
;=============================================================================



