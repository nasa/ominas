;=============================================================================
;+
; NAME:
;	pg_center
;
;
; PURPOSE:
;	Computes image coordinates of the center of each object.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	center_ptd = pg_center(cd=cd, bx=bx)
;	center_ptd = pg_center(gd=gd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (nt) of camera descriptors.
;
;	bx:	Array (n_objects, nt) of descriptors of objects 
;		which must be a subclass of BODY.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	clip:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_objects) of POINT objets containing image points and
;	the corresponding inertial vectors.
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
function pg_center, cd=cd, bx=bx, dd=dd, gd=gd, clip=clip, cull=cull

 if(keyword_set(clip)) then slop = (cam_size(cd[0]))[0]*(clip-1) > 1

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)

 if(NOT keyword_set(bx)) then return, obj_new()

 ;-----------------------------------------------
 ; determine points description
 ;-----------------------------------------------
 desc = cor_class(bx) + '_center'

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 cor_count_descriptors, bx, nd=n_objects, nt=nt1
 if(nt NE nt1) then nv_message, 'Inconsistent timesteps.'


 ;-----------------------------------
 ; get center for each object
 ;-----------------------------------
; center_ptd = objarr(n_objects, nt) 
; for i=0, nt-1 do $
;  begin
;   xd = bx[*,i]
;   inertial_pts = transpose(bod_pos(xd))

;   _ptd = pnt_create_descriptors( $ 
;		points = inertial_to_image_pos(cd[i], inertial_pts), $
;		vectors = inertial_pts)

;   ptd = pnt_explode(_ptd)

;; pnt_assign, ptd, $
;;       name=cor_name(xd), $
;;       desc=desc[*,i], $
;;       gd={bx:bx[i,0], cd:cd[0]}, $
;;       assoc_xd=xd
;   cor_set_name, ptd, cor_name(xd)
;   pnt_set_desc, ptd, desc[*,i]
;   dat_set_gd, ptd, {bx:bx[i,0], cd:cd[0]}
;   pnt_set_assoc_xd, ptd, xd

;   center_ptd[*,i] = ptd
;  end





 center_ptd = objarr(n_objects) 
 for i=0, n_objects-1 do $
  begin
   xd = reform(bx[i,*], nt)
   inertial_pts = bod_pos(xd)

   center_ptd[i] = $
        pnt_create_descriptors(name = cor_name(xd), $
		task = 'PG_CENTER', $
		desc = desc[i], $
		gd = {bx:bx[i,0], cd:cd[0]}, $
		assoc_xd = xd, $
		points = inertial_to_image_pos(cd, inertial_pts), $
		vectors = inertial_pts)
  end



 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, center_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then center_ptd = pnt_cull(center_ptd)
  end


 return, center_ptd
end
;=============================================================================
