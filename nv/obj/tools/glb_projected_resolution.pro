;==============================================================================
; glb_projected_resolution  **incomplete**
;
; p is point on globe in inertial coordinates.
;
;==============================================================================
pro glb_projected_resolution, gbd, cd, p, scale, $
	min=resmin, $		; min dist/pixel 
	max=resmax, $		; max dist/pixel 
	rr=rr			; intercept radius


 if(NOT keyword_set(scale)) then scale = (cam_scale(cd))[0]

 nv = n_elements(p)/3					; assume  nt = 1
 mm = make_array(nv, val=1d)
 m = make_array(3, val=1d)


 cam_pos = bod_pos(cd) ## mm
 glb_pos = bod_pos(gbd) ## mm

 v = image_to_surface(cd, gbd, p, dis=dis, body_pts=body_pts)
 

 scale*


end
;==============================================================================
