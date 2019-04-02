;=============================================================================
;+
; NAME:
;	pg_repoint
;
;
; PURPOSE:
;	Modifies the camera orientation matrix based on the given image
;	coordinate translation and rotation.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_repoint, cd=cd, dxy, dtheta, axis_ptd=axis_ptd
;	pg_repoint, cd=cd, ptd, /absolute, dtheta, axis_ptd=axis_ptd
;	pg_repoint, cd=cd, v
;
;
; ARGUMENTS:
;  INPUT:
;	arg:		Array (2,1,nt) or (2,1) specifying the translation as 
;			[dx,dy] in pixels.  
;				
;				or
;
;			Array of POINT objects; mainly useful with the /absolute 
;			option.
;				
;				or
;
;			Array of new pointing vectors (1,3,nt).
;
;	dtheta:		Array (nt) specifying the rotation angle in radians.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	 Array (nt) of camera descriptors.
;
;	gd:	 Generic descriptor.  If given, the cd input is taken from the
;		 cd field of this structure instead of from that keyword.
;
;	axis_ptd: POINT containing a single image point
;		 to be used as the axis of rotation.  Default is the camera
;		 optic axis.
;
;	bore_cd:  Array (nt) of camera descriptors from which to copy the 
;		  new orientation instead of using dxy, dtheta, and axis_ptd.
;
;	bore_rot: If given, the orientation from bore_cd will be rotated
;		  using this rotation matrix (3,3) before being copied.
;
;	bore_dxy: Boresight offset in pixels.
;
;	absolute: If set, the dxy argument represents an absolute image
;		  position rather than an offset.
;
;	north:	  If set, orientations set by vector input are aligned
;		  with celestial north.  Otherwise the original north alignment
;		  is retained.
;
;  OUTPUT:
;	cd:	 If given, the camera descriptor is modified with a new
;		 orientation matrix.
;
;	gd:	 If given in this way, the camera descriptor contained in the
;		 generic descriptor is modified with a new orientation matrix.
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	pg_repoint adds its name to the task list of each given camera
;	descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_fit, pg_drag
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro pg_repoint, cd=cd, gd=gd, _arg, _dtheta, axis_ptd=axis_ptd, $
                bore_cd=bore_cd, bore_rot=bore_rot, bore_dxy=bore_dxy, $
		absolute=absolute, north=north

 arg = 0
 if(keyword_set(_arg)) then arg = _arg

 dtheta = 0
 if(keyword_set(_dtheta)) then dtheta = _dtheta

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)

 ;-----------------------------------
 ; interpret argument
 ;-----------------------------------
 nt = n_elements(cd)
 dim = size(arg, /dim)
 if(obj_valid(arg[0])) then dxy = reform(pnt_points(dxy, /cat), 2, 1, nt) $
 else if(dim[0] EQ 2) then dxy = arg $
 else v = arg

 ;-------------------------------------------------------
 ; if vector argument, then point along that vector
 ;-------------------------------------------------------
 if(keyword_set(v)) then $
  begin
   y = 0
   if(NOT keyword_set(north)) then y = (bod_orient(cd))[2,*,*]
   bod_set_orient, cd, cam_radec_to_orient(y=y, $
                                        bod_body_to_radec(bod_inertial(nt), v))
  end $
 else $
  begin
   ;---------------------------------------
   ; check for boresight cd
   ;---------------------------------------
   if(keyword__set(bore_cd)) then $
    begin
     bore_orient = bod_orient(bore_cd)
     if(NOT keyword_set(bore_rot)) then orient = bore_orient $
     else orient = v_mxm(bore_rot[linegen3z(3,3, nt)], bore_orient)
     bod_set_orient, cd, orient

     if(keyword_set(bore_dxy)) then $
       dxy = dxy + bore_dxy*cam_scale(bore_cd)/cam_scale(cd)
    end 
  
   if(keyword_set(dxy)) then $
    begin
     ;-----------------------------------
     ; check number of parameters
     ;-----------------------------------
     if(n_elements(dtheta) EQ 1) then dtheta = replicate(dtheta[0], nt) 
     if(n_elements(dxy) EQ 2) then dxy = dxy[linegen3z(2,1,nt)]

     ;------------------------------------------------
     ; modify camera pointing for all times
     ;------------------------------------------------
     if(keyword__set(axis_ptd)) then axis = pnt_points(axis_ptd) $
     else axis = cam_oaxis(cd)
     cam_reorient, cd, axis, dxy[*,0,*], dtheta[*], absolute=absolute
    end
  end

 cor_add_task, cd, 'pg_repoint'
end
;=============================================================================



