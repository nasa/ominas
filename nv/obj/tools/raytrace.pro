;=============================================================================
;+
; NAME:
;	raytace
;
;
; PURPOSE:
;	Traces rays from a camera to a set of objects.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	raytrace, image_pts, cd=cd, bx=bx		; For primary rays
;		hit_matrix=hit_matrix, $
;		hit_indices=hit_indices, $
;		range_matrix=range_matrix, hit_list=hit_list
;
;	raytrace, bx=bx, sbx=sbx, $			; For secondary rays
;		hit_matrix=hit_matrix, $
;		hit_indices=hit_indices, $
;		range_matrix=range_matrix, hit_list=hit_list
;
;
; ARGUMENTS:
;  INPUT: 
;	image_pts:  Array (2,np) of image points relative to cd.  These
;	            points will be turned into rays to be traced from the 
;	            position of the camera.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	        Camera descriptor.
;
;	bx:	        Array of object descriptors; must be a subclass of BODY.
;
;	sbx:            Body descriptor for secondary ray tracing.  If set, 
;	                image_pts and cd are not used; instead, secondary rays 
;	                are traced from the given hit_matrix points to sbx.
;	                At present, only one sbx is allowed.
;
;	hit_matrix:     Body-frame points from prior call, to be used as
;	                source points for secondary rays.  
;
;	hit_indices:    Body index for each secondary ray.
;
;	limit_source :  If set, secondary vectors originating on a given
;	                body are not considered for targets that are the
;	                same body.  Default is off.
;
;	standoff:       If given, secondary vectors are advanced by this distance
;	                before tracing in order to avoid hitting target bodies
;	                through round-off error.  Default is 1 unit.
;
;	cloud_pts:	If present and (defined), secondary rays are traced to 
;			random points within in the secondary body rather than 
;			its center, and their inertial coordinates are returned 
;			in this output.
;
;  OUTPUT: 
;	hit_list:      Array (nhit) giving indices of all bx that have ray 
;	               intersections.  
;
;	hit_indices:   Array (nray) of body indices corresponding to the first 
;	               intersection for each ray.  
;
;	hit_matrix:    Array (nray,3,nhit) of body-frame points for nearest 
;	               ray intersections. 
;
;	range_matrix:  Array (nhit,nray) giving distance to the near-side
;	               ray intersection for each body in the hit_matrix.  
;
;	back_matrix:   Array (nray,3,nhit) of body-frame points for additional
;	               intersections with bodies in the hit_list, in order
;	               of distance.
;
;
; RETURN: NONE
;
;
; PROCEDURE:
;	
;
;
; EXAMPLE:
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================



;=============================================================================
; rt_trace
;
;=============================================================================
pro rt_trace, bx, view_pts, ray_pts, select, hit_matrix=hit_matrix, $
        hit_indices=hit_indices, range_matrix=range_matrix, hit_list=hit_list, $
        back_matrix=back_matrix, src_hit_indices=src_hit_indices, $
        standoff=standoff, limit_source=limit_source, show=show

;hit_matrix = 0
;range_matrix =0

 nray = n_elements(ray_pts)/3
 nbx = n_elements(bx)

 hit_matrix = dblarr(nray,3)
 back_matrix = dblarr(nray,3)
 range_matrix = make_array(nray, val=1d100)
 hit_indices = make_array(nray,val=-1)

 v = dblarr(nray,3)
 r = dblarr(nray,3)
 hits = dblarr(nray,3)
 back_hits = dblarr(nray,3)
 mark = bytarr(nray)

 ;- - - - - - - - - - - - - - - - - - -
 ; check each body
 ;- - - - - - - - - - - - - - - - - - -
 for i=0, nbx-1 do if(obj_valid(bx[i])) then $
  begin
   mark[select] = 1

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; deselect rays originating on this target
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(limit_source)) then $
    if(keyword_set(src_hit_indices)) then $
     begin 
      w = where(src_hit_indices EQ i)
      if(w[0] NE -1) then mark[w] = 0
     end

   ii = where(mark NE 0)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; find the intersections
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(ii[0] NE -1) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; convert rays to target body frame
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     v[ii,*] = bod_inertial_to_body_pos(bx[i], view_pts[ii,*])
     r[ii,*] = bod_inertial_to_body(bx[i], ray_pts[ii,*])

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; advance secondary source vectors by a small amount to
     ; avoid round-off intersections with that source body
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(keyword_set(sbx)) then $
        if(keyword_set(standoff)) then v[ii,*] = v[ii,*] + r[ii,*]*standoff

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; trace the rays
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     hit_pts = surface_intersect(bx[i], v[ii,*], r[ii,*], hit=hit, back_pts=back_pts)
     if(keyword_set(hit_pts)) then $
      begin
       nii = n_elements(ii)
       hits[ii,*] = hit_pts
       if(keyword_set(back_pts)) then back_hits[ii,*] = back_pts

       ;- - - - - - - - - - - - - - - - - - - - - - - - - -
       ; add closest result to intercept map
       ;- - - - - - - - - - - - - - - - - - - - - - - - - -
       if(hit[0] NE -1) then $
        begin
         hit = ii[hit]
         range = v_mag(v[hit,*] - hits[hit,*])
         ww = where(range LT range_matrix[hit])

         if(ww[0] NE -1) then $
          begin
           hit_matrix[hit[ww],*] = hits[hit[ww],*]
           back_matrix[hit[ww],*] = back_hits[hit[ww],*]
           hit_indices[hit[ww]] = i
           hit_list = append_array(hit_list, i, /pos)
           range_matrix[hit[ww]] = range[ww]
          end
        end
      end
    end
  end


end
;=============================================================================



;=============================================================================
; raytrace
;
;=============================================================================
pro raytrace, image_pts, cd=cd, bx=all_bx, sbx=sbx, $
               hit_matrix=hit_matrix, show=show, cloud_pts=cloud_pts, $
               hit_indices=hit_indices, range_matrix=range_matrix, $
               hit_list=hit_list, back_matrix=back_matrix, $
               standoff=standoff, limit_source=limit_source

 show = keyword_set(show)
 if(NOT keyword_set(all_bx)) then return
 bx = all_bx
 nbx = n_elements(bx)

 hit_list = -1

 if(NOT defined(standoff)) then standoff = 1d
 if(NOT defined(limit_source)) then limit_source = 0


 ;---------------------------------------------
 ; primary trace
 ;---------------------------------------------
 if(keyword_set(cd)) then $
  begin
   nray = n_elements(image_pts)/2l
   MM = make_array(nray,val=1d)

   view_pts = bod_pos(cd)##MM
   ray_pts = image_to_inertial(cd, image_pts)

   select = lindgen(nray)

   rt_trace, bx, view_pts, ray_pts, select, hit_matrix=hit_matrix, $
      hit_indices=hit_indices, range_matrix=range_matrix, hit_list=hit_list, $
      back_matrix=back_matrix, $
      standoff=standoff, limit_source=limit_source, show=show
  end $
 ;---------------------------------------------
 ; secondary trace
 ;---------------------------------------------
 else if(keyword_set(sbx)) then $
  begin
   cloud = arg_present(cloud_pts) AND defined(cloud_pts)

   ;- - - - - - - - - - - - - - - - - - - - -
   ; select rays to compute
   ;- - - - - - - - - - - - - - - - - - - - -
   w = where(hit_indices NE -1)
   if(w[0] EQ -1) then return
   select = w
   nselect = n_elements(select)

   nray = n_elements(hit_indices)
   MM = make_array(nray,val=1d)
   sbx_pos = bod_pos(sbx)##MM 

   view_pts = dblarr(nray,3)
   ray_pts = dblarr(nray,3)

   ;- - - - - - - - - - - - - - - - - - - - -
   ; select bodies to compute
   ;- - - - - - - - - - - - - - - - - - - - -
   w = where(bx NE sbx[0])
   bx = bx[w]
   nbx = n_elements(bx)

   ;- - - - - - - - - - - - - - - - - 
   ; compute sources
   ;- - - - - - - - - - - - - - - - - 
   for i=0, nbx-1 do if(obj_valid(bx[i])) then $
    begin
     w = where(hit_indices EQ i)
     if(w[0] NE -1) then $
             view_pts[w,*] = bod_body_to_inertial_pos(bx[i], hit_matrix[w,*])
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; compute termini; for the cloud calculation, each source traces
   ; to a random terminus within the secondary body
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   view_pts_select = view_pts[select,*]
   cloud_pts_center = sbx_pos[select,*]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; compute random termini for numbra > 1
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(NOT cloud) then cloud_pts = cloud_pts_center $
    else $
     begin
      cloud_pts_body = point_cloud(sbx, nselect)
      cloud_pts = bod_body_to_inertial_pos(sbx, cloud_pts_body)
     end
   ray_pts[select,*] = cloud_pts - view_pts_select
   src_hit_indices = hit_indices

   ;- - - - - - - - - - - - - - - - - - - - -
   ; trace
   ;- - - - - - - - - - - - - - - - - - - - -
   rt_trace, bx, view_pts, ray_pts, select, hit_matrix=hit_matrix, $
      hit_indices=hit_indices, range_matrix=range_matrix, hit_list=hit_list, $
      back_matrix=back_matrix, src_hit_indices=src_hit_indices, $
      standoff=standoff, limit_source=limit_source, show=show 
  end $
 else nv_message, 'Either cd or sbx must be specified. '


end
;=================================================================================
