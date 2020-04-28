;=============================================================================
;+
; NAME:
;	pg_disk
;
;
; PURPOSE:
;	Computes image points on the inner and outer edges of each given disk
;	object at all given time steps.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_disk(cd=cd, dkx=dkx)
;	result = pg_disk(gd=gd)
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
;	dkx:	 Array (n_objects, n_timesteps) of descriptors of objects 
;		 which must be a subclass of DISK.
;
;	od:	 Array (n_timesteps) of descriptors of objects 
;		 that must be a subclass of BODY.  These objects are used
;		 as the observer from which limb is computed.  If no observer
;		 descriptor is given, the camera descriptor is used.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	inner/outer: If either of these keywords are set, then only
;	             that edge is computed.
;
;	npoints: Number of points to compute around each edge.  Default is
;		 1000.
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
;	Array (2*n_objects) of POINT containing image points and
;	the corresponding inertial vectors.  The output array is arranged as
;	[inner, outer, inner, outer, ...] in the order that the disk
;	descriptors are given in the dkx argument.
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



;=============================================================================
; pgd_compute
;
;=============================================================================
function pgd_compute, cd, od, dkx, desc, npoints, inner=inner, outer=outer, clip=clip, slop=slop
@pnt_include.pro

 cor_count_descriptors, dkx, nd=n_disks, nt=nt
 hide_flags = make_array(npoints, val=PTD_MASK_INVISIBLE)

 suffix = keyword_set(inner) ? 'INNER' : 'OUTER'

 disk_ptd = objarr(n_disks)

 for i=0, n_disks-1 do $
  begin
   ii = dsk_valid_edges(dkx[i,*], /outer)
   if(ii[0] NE -1) then $
    begin
     xd = reform(dkx[i,ii], nt)

     ;- - - - - - - - - - - - - - - - -
     ; clip 
     ;- - - - - - - - - - - - - - - - -
     ta = 0
     continue = 1
     if(keyword_set(clip)) then $
      begin
       dsk_image_bounds, cd, xd, slop=slop, /plane, $
	       lonmin=lonmin, lonmax=lonmax, border_pts_im=border_pts_im
       if(NOT defined(lonmin)) then continue = 0 $
       else ta = dindgen(npoints)/double(npoints-1)*(lonmax-lonmin) + lonmin
      end

     ;- - - - - - - - - - - - - - - - -
     ; compute edge points
     ;- - - - - - - - - - - - - - - - -
     if(continue) then $
      begin
       disk_pts = dsk_get_disk_points(xd, npoints, $
                                          ta=ta, inner=inner, outer=outer)
       inertial_pts = bod_body_to_inertial_pos(xd, disk_pts)
       image_pts = cam_focal_to_image(cd, $
		     cam_body_to_focal(cd, $
		       bod_inertial_to_body_pos(cd, inertial_pts)))

       disk_ptd[i] = $
	  pnt_create_descriptors(name = cor_name(xd) + '-' + suffix, $ 
        	  task = 'PG_DISK', $
        	  desc = desc, $
        	  gd = {dkx:dkx[i,0], od:od[0], cd:cd[0]}, $
        	  assoc_xd = xd, $
        	  points = image_pts, $
        	  vectors = inertial_pts)

       if(NOT bod_opaque(dkx[i,0])) then pnt_set_flags, disk_ptd[i], hide_flags
      end
    end
  end

 return, disk_ptd
end
;=============================================================================



;=============================================================================
; pg_disk
;
;=============================================================================
function pg_disk, cd=cd, od=od, dkx=dkx, dd=dd, gd=gd, clip=clip, cull=cull, $
                  inner=inner, outer=outer, npoints=npoints, reveal=reveal, count=count
@pnt_include.pro

 count = 0

 desc_inner = 'DISK_INNER'
 desc_outer = 'DISK_OUTER'
 if(keyword_set(od)) then desc_inner = desc_inner + '-' + cor_name(od)
 if(keyword_set(od)) then desc_outer = desc_outer + '-' + cor_name(od)

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(dkx)) then return, obj_new()

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

 ;-----------------------------------
 ; default parameters
 ;-----------------------------------
 if(NOT keyword_set(npoints)) then npoints=1000
 both = (NOT keyword_set(inner) AND NOT keyword_set(outer))
 inner = keyword_set(inner) OR keyword_set(both)
 outer = keyword_set(outer) OR keyword_set(both)

 if(keyword_set(clip)) then slop = (cam_size(cd[0]))[0]*(clip-1) > 1

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 nt1 = n_elements(od)
 cor_count_descriptors, dkx, nd=n_disks, nt=nt2
 if(nt NE nt1 OR nt1 NE nt2) then nv_message, 'Inconsistent timesteps.'


 ;-----------------------------------------------------------------------
 ; compute disk points
 ;-----------------------------------------------------------------------
 outer_disk_ptd = pgd_compute(cd, od, dkx, desc_inner, npoints, /outer, clip=clip, slop=slop)
 inner_disk_ptd = pgd_compute(cd, od, dkx, desc_outer, npoints, /inner, clip=clip, slop=slop)


 ;--------------------
 ; concatenate disks
 ;--------------------
 if(NOT keyword__set(inner)) then disk_ptd=outer_disk_ptd $
 else if(NOT keyword__set(outer)) then disk_ptd=inner_disk_ptd $
 else $
  begin
   ii = 2*lindgen(n_disks)
   disk_ptd = objarr(2*n_disks)
   disk_ptd[ii] = inner_disk_ptd
   disk_ptd[ii+1] = outer_disk_ptd
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, disk_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then disk_ptd = pnt_cull(disk_ptd)
  end


 count = n_elements(disk_ptd)
 return, disk_ptd
end
;=============================================================================
