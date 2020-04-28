;=============================================================================
;+
; NAME:
;	pg_shadow_globe
;
;
; PURPOSE:
;	Computes image coordinates of the given inertial vectors projected onto
;	surface of the given globe with respect to the given observer.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_shadow_globe(object_ptd, cd=cd, od=od, gbx=gbx)
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
;	reveal:	 Normally, disks whose opaque flag is set are ignored.  
;		 /reveal suppresses this behavior.
;
;	clip:	 If set shadow points are cropped to within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;	nosolve: If set, shadow points are not computed.  
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Array (n_globes,n_objects) of POINT containing image 
;	points and the corresponding inertial vectors.
;
;
; STATUS:
;	Soon to be obsolete.  This program will be merged with pg_shadow_disk
;	to make a more general program, which will replace pg_shadow.  
;
;
; SEE ALSO:
;	pg_shadow, pg_shadow_disk, pg_shadow_points
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function pg_shadow_globe, cd=cd, od=od, gbx=gbx, dd=dd, gd=gd, object_ptd, $
                          nocull=nocull, reveal=reveal, $
                          clip=clip, cull=cull, $
                          nosolve=nosolve
@pnt_include.pro


 if(NOT keyword_set(dis_epsilon)) then dis_epsilon = 1d-16

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(ltd)) then ltd = dat_gd(gd, dd=dd, /ltd)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(od)) then $
  if(keyword_set(ltd)) then od = ltd $
  else nv_message, 'No observer descriptor.'


 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 cor_count_descriptors, od, nd=n_observers, nt=nt
 if(n_observers GT 1) then nv_message, 'Only one observer descriptor allowed.'
 cor_count_descriptors, gbx, nd=n_globes, nt=nt1
 if(nt NE nt1) then nv_message, 'Inconsistent timesteps.'


 ;------------------------------------------------
 ; compute shadows for each object on each globe
 ;------------------------------------------------
 n_objects = n_elements(object_ptd)
 shadow_ptd = objarr(n_globes, n_objects)
; shadow_ptd = objarr(n_objects)

 obs_pos = bod_pos(od)
 for j=0, n_objects-1 do if(obj_valid(object_ptd[j])) then  $
  begin
   for i=0, n_globes-1 do $
    if((bod_opaque(gbx[i,0])) OR (keyword_set(reveal))) then $
     begin
      xd = reform(gbx[i,*], nt)

      ;---------------------------
      ; get object vectors
      ;---------------------------
      pnt_query, object_ptd[j], vectors=vectors, assoc_xd=assoc_xd
      if(xd NE assoc_xd) then $
       begin
        n_vectors = (size(vectors))[1]

        ;---------------------------------------
        ; source and ray vectors in body frame
        ;---------------------------------------
        v_inertial= obs_pos##make_array(n_vectors, val=1d)
        rr = vectors - v_inertial
        r_inertial = v_unit(rr)

        r_body = bod_inertial_to_body(xd, r_inertial)
        v_body = bod_inertial_to_body_pos(xd, vectors)

        ;---------------------------------
        ; project shadows in body frame
        ;---------------------------------
        shadow_pts = $
               glb_intersect(hit=hit, miss=miss, nosolve=nosolve, $
                                                   xd, v_body, r_body, dis=dis)

        ;---------------------------------------------------------------
        ; Compute and store image coords of any valid intersections.
        ;---------------------------------------------------------------
        if(hit[0] NE -1) then $
         begin
          flags = bytarr(n_vectors)
          flags[miss] = flags[miss] OR PTD_MASK_INVISIBLE

          points = $
            degen(body_to_image_pos(cd, xd, shadow_pts, inertial=inertial_pts))

          ;---------------------------------
          ; store points
          ;---------------------------------
          shadow_ptd[i,j] = $
              pnt_create_descriptors(points = points, $
         	 flags = flags, $
         	 name = 'SHADOW-' + cor_name(object_ptd[j]), $
         	 assoc_xd = xd, $
         	 task = 'PG_SHADOW_GLOBE', $
	         desc = 'GLOBE_SHADOW/' + pnt_desc(object_ptd[j]), $
	         gd = {gbx:gbx[i,0], od:od[0], srcd:object_ptd[j], cd:cd[0]}, $
	         vectors = inertial_pts)
         end
       end
     end
   end

 ;-------------------------------------------------------------------------
 ; by default, remove empty POINT objects and reform to one dimension 
 ;-------------------------------------------------------------------------
 shadow_ptd = reform(shadow_ptd, n_elements(shadow_ptd), /over)
 if(NOT keyword__set(nocull)) then shadow_ptd = pnt_cull(shadow_ptd)


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, shadow_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then shadow_ptd = pnt_cull(shadow_ptd)
  end


 return, shadow_ptd
end
;=============================================================================
