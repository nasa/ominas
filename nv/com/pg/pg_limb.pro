;=============================================================================
;+
; NAME:
;	pg_limb
;
;
; PURPOSE:
;	Computes image points on the limb of each given globe object.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	limb_ptd = pg_limb(cd=cd, gbx=gbx, ods=ods)
;	limb_ptd = pg_limb(gd=gd, od=od)
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
;	gbx:	 Array (n_objects, n_timesteps) of descriptors of objects 
;		 which must be a subclass of GLOBE.
;
;	od:	 Array (n_timesteps) of descriptors of objects 
;		 which must be a subclass of BODY.  These objects are used
;		 as the observer from which limb is computed.  If no observer
;		 descriptor is given, the camera descriptor is used.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	npoints: Number of points to compute.  Default is 1000.
;
;	epsilon: Maximum angular error in the result.  Default is 1e-3.
;
;	reveal:	 Normally, points computed for objects whose opaque flag
;		 is set are made invisible.  /reveal suppresses this behavior.
;
;	clip:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;  OUTPUT: 
;	count:	Number of descriptors returned.
;
;
; RETURN:
;	Array (n_objects) of POINT containing image
;	points and the corresponding inertial vectors.
;
;
; PROCEDURE:
;	By definition, the surface normal at a point on the limb of a body is
;	perpendicular to a vector from the observer to that same point, so the
;	dot product of the two vectors is zero.  This program uses an iterative
;	scheme to find points onthe surface at which this dot product is less
;	than epsilon.
;
;
; EXAMPLE:
;	The following command computes points on the planet which lie on the
;	terminator:
;
;	term_ptd = pg_limb,(cd=cd, gbx=pd, od=sd)
;
;	In this call, pd is a planet descriptor, cd is a camera descriptor, 
;	and sd is a star descriptor (i.e., the sun).
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
function pg_limb, cd=cd, od=od, gbx=gbx, dd=dd, gd=gd, clip=clip, cull=cull, $
                        npoints=npoints, epsilon=epsilon, reveal=reveal, count=count
@pnt_include.pro

 count = 0

 desc = 'LIMB'
; if(keyword_set(od)) then desc = 'TERMINATOR'
 if(keyword_set(od)) then desc = desc + '-' + cor_name(od)

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(gbx)) then return, obj_new()

 if(keyword_set(clip)) then slop = (image_size(cd[0]))[0]*(clip-1) > 1

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

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


 hide_flags = make_array(npoints, val=PTD_MASK_INVISIBLE)

 ;---------------------------------------------------------
 ; get limb for each object for all times
 ;---------------------------------------------------------
 limb_ptd = objarr(n_objects)

 obs_pos = bod_pos(od)
 for i=0, n_objects-1 do $
  begin
   xd = reform(gbx[i,*], nt)

   Rs = bod_inertial_to_body_pos(xd, obs_pos)		; Source position
							; in object i's body
							; frame for all t.
   ;- - - - - - - - - - - - - - - - -
   ; clip 
   ;- - - - - - - - - - - - - - - - -
   alpha = 0
   continue = 1
   if(keyword_set(clip)) then $
    begin
     test_pts_body = glb_get_limb_points(xd, Rs, npoints, epsilon, 1, alpha=alpha)
     test_pts_image = body_to_image_pos(cd, xd, test_pts_body)
     w = in_image(cd, test_pts_image, slop=slop)
     if(w[0] EQ -1) then continue = 0 $
     else alpha = alpha[w]
     a0 = alpha[0] & a1 = alpha[n_elements(w)-1]
     if(a1 LT a0) then a0 = a0 - 2d*!dpi
     alpha = dindgen(npoints)/npoints * (a1-a0) + a0 - !dpi
    end

   if(continue) then $
    begin
     limb_pts = glb_get_limb_points(alpha=alpha, $	; Limb pts for planet i
                           xd, Rs, npoints, epsilon)	; for all t.

     flags = bytarr(n_elements(limb_pts[*,0]))
     points = body_to_image_pos(cd, xd, limb_pts, inertial=inertial_pts, valid=valid)

     if(keyword__set(valid)) then $
      begin
       invalid = complement(limb_pts[*,0], valid)
       if(invalid[0] NE -1) then flags[invalid] = PTD_MASK_INVISIBLE
      end

     limb_ptd[i] = pnt_create_descriptors(name = cor_name(xd), $
                          task = 'PG_LIMB', $
                          desc=desc, $
                          gd={gbx:gbx[i,0], od:od[0], cd:cd[0]}, $
                          assoc_xd = xd, $
                          points = points, $
                          flags = flags, $
                          vectors = inertial_pts)
     if(NOT bod_opaque(gbx[i,0])) then pnt_set_flags, limb_ptd[i], flags
    end
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, limb_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then limb_ptd = pnt_cull(limb_ptd)
  end



 count = n_elements(limb_ptd)
 return, limb_ptd
end
;=============================================================================
