;=============================================================================
;+
; NAME:
;	pg_ray
;
;
; PURPOSE:
;	Computes image points on each specified ray.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	ray_ptd = pg_ray(cd=cd, r=r, v=v)
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
;	cd:	 Array (nt) of camera descriptors.
;
;	bx:	 Array (nt) of body descriptors to be used for transforming
;		 the points instead of the camera descriptor.  Use this
;		 input if cd is a map.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	r:	 Array (nv,3,nt) of inertial vectors giving the starting
;		 point for each ray.
;
;	v:	 Array (nv,3,nt) of inertial unit vectors giving the direction
;		 for each ray.
;
;	len:	 Array (nv,nt) giving the length for each ray.  Lengths 
;		 default to 1 if not given.
;
;	npoints: Number of points to compute per ray.  Default is 1000.
;
;	clip:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;	cat:	 If set, all points for each descriptor are concatenated
;		 into a single array of nv*npoints points.
;
;	dispersion: If set, points will be randomly dispersed in a cone
;	            of this opening angle about the ray.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nt) of POINT each containing image points (2,nv,npoints) and 
;	the corresponding inertial vectors (nv,3,npoints).  
;
;
;
; STATUS:
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================


;=============================================================================
; pgr_density_uniform
;
;=============================================================================
function pgr_density_uniform, np, nv, len
 return, len * reform(transpose((dindgen(np)/double(np) $
                   # make_array(3, val=1d))[linegen3z(np,3,nv)]), nv,3,np)
end
;=============================================================================



;=============================================================================
; pg_ray
;
;=============================================================================
function pg_ray, r=r, v=v, len=_len, cd=cd, bx=bx, dd=dd, gd=gd, clip=clip, cull=cull, $
             npoints=npoints, cat=cat, density_fn=density_fn, dispersion=dispersion
@pnt_include.pro

 if(NOT keyword_set(npoints)) then npoints = 1000
 if(NOT keyword_set(density_fn)) then density_fn = 'pgr_density_uniform'

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(bx)) then bx = cd 

 if(keyword_set(clip)) then slop = (image_size(cd[0]))[0]*(clip-1) > 1


 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)

 rdim = size(r, /dim)
 nvr = rdim[0]
 ntr = 1
 if(n_elements(rdim) GT 2) then ntr = rdim[2]

 vdim = size(v, /dim)
 nvv = vdim[0]
 ntv = 1
 if(n_elements(vdim) GT 2) then ntv = vdim[2]

 if((nt NE ntr) OR (nt NE ntv)) then nv_message, 'Inconsistent timesteps.'
 if(nvr NE nvv) then nv_message, 'Inconsistent dimensions.'

 nv = nvr

 if(NOT keyword_set(_len)) then len = make_array(nt,nv, val=1d) $
 else if(n_elements(_len) EQ 1) then len = make_array(nt,nv, val=_len) $
 else len = _len


 ;-----------------------------------------------
 ; contruct data set description
 ;-----------------------------------------------
 desc = 'RAY'


 ;---------------------------------------------------------
 ; get ray points 
 ;---------------------------------------------------------
 ray_ptd = objarr(nt)
 ii = linegen3y(nv,3,npoints)
 jj = linegen3z(nv,3,npoints)
 
 for i=0, nt-1 do $
  begin
   t = call_function(density_fn, npoints, nv, len[ii])

   rr = (r[*,*,i])[jj]
   vv = (v[*,*,i])[jj]

   if(keyword_set(dispersion)) then $
    begin
     theta = randomu(0, nv,npoints) * dispersion#make_array(npoints,val=1d)
     phi = randomu(0, nv,npoints) * 2d*!dpi

     ref = ([1d,0,0]##make_array(nv,val=1d))[linegen3z(nv,3,npoints)]
     ax0 = v_cross(vv, ref)
     ax = v_rotate_11(ax0, vv, sin(phi), cos(phi))
     vv = v_rotate_11(vv, ax, sin(theta), cos(theta))
    end

   ray_pts = rr + vv*t

   cdt = make_array(npoints, val=cd)
   bxt = make_array(npoints, val=bx)
   points = body_to_image_pos(cdt, bxt, $
              bod_inertial_to_body_pos(bxt, ray_pts))

   if(keyword_set(cat)) then $
    begin 
     ray_pts = reform(transpose(ray_pts, [0,2,1]), nv*npoints,3, /over)
     points = reform(points, 2, nv*npoints, /over)
    end

   ray_ptd[i] = pnt_create_descriptors(desc=desc, $
                       gd={cd:cd[0]}, $
                       points = points, $
                       vectors = ray_pts)
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, ray_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then ray_ptd = pnt_cull(ray_ptd)
  end



 return, ray_ptd
end
;=============================================================================
