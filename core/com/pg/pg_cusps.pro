;=============================================================================
;+
; NAME:
;	pg_cusps
;
;
; PURPOSE:
;	Computes image points at the limb/terminator cusps for each given 
;	globe object.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	cusp_ptd = pg_cusps(cd=cd, od=od, gbx=gbx)
;	cusp_ptd = pg_cusps(gd=gd)
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
;	cd:	 Array (n_timesteps) of camera descriptors.
;
;	od:	 Array (n_timesteps) of descriptors for the observer, 
;		 default is ltd if gd given.
;
;	gbx:	 Array (n_objects, n_timesteps) of descriptors of objects 
;		 which must be a subclass of GLOBE.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	epsilon: Maximum angular error in the result.  Default is 1e-3.
;
;	reveal:	 Normally, points computed for objects whose opaque flag
;		 is set are made invisible.  /reveal suppresses this behavior.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_objects) of POINT objects containing image
;	points and the corresponding inertial vectors.
;
;
; PROCEDURE:
;	This program uses an iterative scheme to find the two points on 
;	the surface of the globe where the surface normal is simultaneously
;	perpendicular to the vectors from the camera and the light source.
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2010
;	
;-
;=============================================================================
function pg_cusps, cd=cd, od=od, gbx=gbx, dd=dd, gd=gd, epsilon=epsilon, reveal=reveal
@pnt_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(ltd)) then ltd = dat_gd(gd, dd=dd, /ltd)


 if(NOT keyword_set(cd)) then return, obj_new() 
 if(NOT keyword_set(gbx)) then return, obj_new()

 ;-------------------------------------------------
 ; default observer is light source, if present
 ;-------------------------------------------------
 if(NOT keyword_set(od)) then od=ltd

 ;-----------------------------------
 ; default iteration parameters
 ;-----------------------------------
 if(NOT keyword_set(npoints)) then npoints=1000
 if(NOT keyword_set(epsilon)) then epsilon=1e-3


 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 nt1 = n_elements(od)
 cor_count_descriptors, gbx, nd=n_objects, nt=nt2
 if(nt NE nt1 OR nt1 NE nt2) then nv_message, 'Inconsistent timesteps.'


 ;-----------------------------------------------
 ; contruct data set description
 ;-----------------------------------------------
 desc = 'CUSP'
 hide_flags = make_array(npoints, val=PTD_MASK_INVISIBLE)

 ;---------------------------------------------------------
 ; get cusps for each object for all times
 ;---------------------------------------------------------
 cusp_ptd = objarr(n_objects)

 obs_pos = bod_pos(od)
 cam_pos = bod_pos(cd)
 for i=0, n_objects-1 do $
  begin
   xd = reform(gbx[i,*], nt)				; Object i for all t.

   Rs = bod_inertial_to_body_pos(xd, obs_pos)		; Source position
							; in object i's body
							; frame for all t.

   Rc = bod_inertial_to_body_pos(xd, cam_pos)		; Camera position
							; in object i's body
							; frame for all t.

   cusp_pts = glb_get_cusp_points(xd, Rc, Rs, epsilon)	; for all t.

   flags = bytarr(n_elements(cusp_pts[*,0]))
   points = body_to_image_pos(cd, xd, cusp_pts, inertial=inertial_pts, valid=valid)
   if(keyword__set(valid)) then $
    begin
     invalid = complement(cusp_pts[*,0], valid)
     if(invalid[0] NE -1) then flags[invalid] = PTD_MASK_INVISIBLE
    end
   cusp_ptd[i] = pnt_create_descriptors(name = cor_name(xd), $
			desc=desc, $
			gd={gbx:gbx[i,0], od;od[0], cd:cd[0]}, $
			assoc_xd = xd, $
                        points = points, $
			flags = flags, $
                        vectors = inertial_pts)
   if(NOT bod_opaque(gbx[i,0])) then pnt_setflags, cusp_ptd[i], hide_flags
  end



 return, cusp_ptd
end
;=============================================================================
