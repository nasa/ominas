;=============================================================================
;+
; NAME:
;	pg_shadow_points
;
;
; PURPOSE:
;	Determines whether each given point is shadowed by the given object.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_shadow_points, object_ptd, cd=cd, od=od, bx=bx
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing inertial vectors
;			to shadow.
;
;  OUTPUT: 
;	shadow_ptd:	Array of POINT containing the shadowed
;			points.
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	bx:	Array (nbx, n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY describing the shadowing
;		bodies.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the source from which points are projected.  If no observer
;		descriptor is given, then the light descriptor in gd is used.
;		Only one observer is allowed.
;
;	gd:	Generic descriptor.  If given, the cd and bx inputs 
;		are taken from the corresponding fields of this structure
;		instead of from those keywords.
;
;	clip:	 If set shadow points are cropped to within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;	edge:	 If set, only points near the edge of the shadow are returned.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	Shadowed points are flagged as invisible.
;
;
; STATUS:
;	
;
;
; SEE ALSO:
;	pg_shadow, pg_shadow_globe, pg_shadow_disk
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
pro pg_shadow_points, cd=cd, od=od, bx=bx, gd=gd, object_ptd, shadow_ptd, $
                           nocull=nocull, edge=edge, nosolve=nosolve, $
                           clip=clip, cull=cull
                           
@pnt_include.pro


 backshadow = 1 - keyword_set(_backshadow)

 shad_ptd = pg_shadow(object_ptd, cd=cd, od=od, bx=bx, gd=gd, $
                       all=all, clip=clip, nocull=NOT keyword_set(cull), $
                       nosolve=nosolve)

 object_flags = pnt_flags(object_ptd)
 shad_flags = pnt_flags(shad_ptd)

 flags = object_flags OR NOT shad_flags
 shadow_flags = object_flags OR shad_flags

 pnt_set_flags, object_ptd, flags

 if(arg_present(shadow_ptd)) then $
  begin
    shadow_ptd = nv_clone(object_ptd)
    pnt_set_flags, shadow_ptd, shadow_flags
  end


end
;=============================================================================
