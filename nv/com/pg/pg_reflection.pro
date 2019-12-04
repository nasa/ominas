;=============================================================================
;+
; NAME:
;	pg_reflection
;
;
; PURPOSE:
;	Computes image coordinates of given inertial vectors projected onto
;	surface of the given disks and globes with respect to the given
;	observer.  Returns only the closest reflection point for each objoect 
;	point.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_reflection, object_ptd, cd=cd, ods=ods, dkx=dkx, gbx=gbx
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing inertial vectors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_globes, n_timesteps) of descriptors of objects 
;		which must be a subclass of GLOBE.
;
;	dkx:	Array (n_disks, n_timesteps) of descriptors of objects 
;		which must be a subclass of DISK.
;
;	bx:	Array (n_disks, n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the source from which points are projected.  If no observer
;		descriptor is given, then the light descriptor in gd is used.
;		Only one observer is allowed.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	  All other keywords are passed directly to pg_reflection_globe
;	  and pg_reflection_disk and are documented with those programs.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (n_disks,n_objects) of POINT containing image 
;	points and the corresponding inertial vectors.
;
;
; STATUS:
;	Soon to be replaced by a new program that merges pg_reflection_globe and
;	pg_reflection_disk.  The API for the new routine may be slightly different.
;
;
; SEE ALSO:
;	pg_reflection_disk, pg_reflection_globe, pg_reflection_points
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2016
;	
;-
;=============================================================================
function pg_reflection, cd=cd, od=od, dkx=dkx, gbx=gbx, bx=bx, dd=dd, gd=gd, object_ptd, $
              reveal=reveal, clip=clip, nocull=nocull, all=all

 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)

 ;----------------------------------
 ; extract objects from bx
 ;----------------------------------
 if(keyword_set(bx)) then $
  begin
   gbx = append_array(gbx, cor_select(bx, 'GLOBE', /class))
   dkx = append_array(dkx, cor_select(bx, 'DISK', /class))
  end

 ;----------------------------------
 ; project onto all globes
 ;----------------------------------
 if(keyword_set(gbx)) then $
   globe_reflection_ptd = $
       pg_reflection_globe(object_ptd, cd=cd, od=od, gbx=gbx, dd=dd, gd=gd, $
               /nocull, reveal=reveal, clip=clip)

 ;----------------------------------
 ; project onto all disks
 ;----------------------------------
;; if(keyword_set(dkx)) then $
;;   disk_reflection_ptd = $
;;       pg_reflection_disk(object_ptd, cd=cd, od=od, dkx=dkx, dd=dd, gd=gd, $
;;               /nocull, reveal=reveal, clip=clip)


 ;----------------------------------
 ; combine results
 ;----------------------------------
 if(keyword_set(globe_reflection_ptd)) then $
            reflection_ptd = append_array(reflection_ptd, globe_reflection_ptd)
 if(keyword_set(disk_reflection_ptd)) then $
            reflection_ptd = append_array(reflection_ptd, disk_reflection_ptd)

 if(NOT keyword_set(nocull)) then reflection_ptd = pnt_cull(reflection_ptd)

 return, reflection_ptd
end
;=============================================================================
