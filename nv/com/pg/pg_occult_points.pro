;=============================================================================
;+
; NAME:
;	pg_occult_points
;
;
; PURPOSE:
;	Determines whether each given point is occulted by the given object
;	relative to the given observer.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_occult_points, object_ptd, od=od, bx=bx
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing inertial vectors
;			to occult.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the source from which points are projected.  If no observer
;		descriptor is given, then the light descriptor in gd is used.
;		Only one observer is allowed.
;
;	bx:	Array (nbx, n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY describing the occulting
;		bodies.
;
;	gd:	Generic descriptor.  If given, the od and bx inputs 
;		are taken from the corresponding fields of this structure
;		instead of from those keywords.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	Occulted points are flagged as invisible.
;
;
; STATUS: Complete
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2017
;	
;-
;=============================================================================
pro pg_occult_points, od=od, bx=bx, gd=gd, object_ptd
@pnt_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)


 ;---------------------------------------------------------
 ; set up rays from the object points to the observer
 ;---------------------------------------------------------
 v_inertial = pnt_vectors(object_ptd)
 nv = (size(v_inertial))[1]

 pos = bod_pos(od)##make_array(nv, val=1d)
 r_inertial = pos - v_inertial
 
 r_body = bod_inertial_to_body(bx, r_inertial)
 v_body = bod_inertial_to_body_pos(bx, v_inertial)

 hit_pts = glb_intersect(hit=hit, miss=miss, bx, v_body, r_body)


 ;---------------------------------------------------------
 ; set flags for occulted points, if any
 ;---------------------------------------------------------
 if(hit[0] EQ -1) then return

 flags = pnt_flags(object_ptd)
 flags[hit] = flags[hit] OR PTD_MASK_INVISIBLE

 pnt_set_flags, object_ptd, flags

end
;=============================================================================
