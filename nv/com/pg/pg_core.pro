;=============================================================================
;+
; NAME:
;	pg_core
;
;
; PURPOSE:
;	Generates a dn profile through a cube, or stack of images.
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;    result = pg_core(dd, cd=cd, outline_ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	  dd:	 Data descriptor(s).  Multiple descriptors are given,
;		 the data arrays are stacked, so the 0 and 1 dimensions must 
;		 all agree.
;
; outline_ptd:   POINT descriptor giving the outline of the region to plot,
;                as produced by the pg_select_region.
;
;  OUTPUT:
;        NONE
;
; KEYWORDS:
;  INPUT:
;	  cd:	Camera descriptor.  Needed for sinc interpolation. (to get PSF)
;
;         gd:   Optional generic descriptor containing cd.
;
;     interp:   Type of interpolation to use.  Options are:
;               'nearest', 'mean', 'bilinear', 'cubic', 'sinc'.
;
;         bg:	Uniform value to subtract from profile.
;
; arg_interp:   Arguments to pass to the interpolation function.
;
;
;  OUTPUT:
;    profile:   The profile.
;
;      sigma:   Array giving the standard deviation at each point in the
;		profile.
;
;    distance:  Array giving the distance, in pixels, along the profile.
;
;   image_pts:  Image point for each point along the profile.
;
;
; RETURN:
;	Two data descriptors: the first contains the profile; the second contains
;	the profile sigma.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 7/2016
;	
;-
;=============================================================================
function pg_core, dd, cd=cd, gd=gd, outline_ptd, distance=distance, $
             interp=interp, arg_interp=arg_interp, sigma=sigma, profile=profile, $
             image_pts=image_pts, bg=bg

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 ndd = n_elements(dd)

 ;-----------------------------------
 ; construct the cube
 ;-----------------------------------
 for i=0, n_elements(dd)-1 do $
  begin
   data = dat_data(dd[i], abscissa=ab)
   dim = dat_dim(dd[i])

   is_cube = 1
   if(n_elements(dim) EQ 2) then is_cube = 0 $
   else if(dim[2] EQ 1) then is_cube = 0

   if(NOT is_cube) then $
    begin
     data = reform(data, 1, dim[0], dim[1], /over)
     ab = reform(ab, 1, dim[0], dim[1], /over)
    end $
   else $
    begin
     data = transpose(data, [2,0,1])
     ab = transpose(ab, [2,0,1])
    end

   cube = append_array(cube, data)
   abscissa = append_array(abscissa, ab)
  end
 cube = transpose(cube)
 abscissa = transpose(abscissa)
 dim = size(cube, /dim)
 if(n_elements(dim) EQ 2) then dim = [dim, 1]


 ;-----------------------------------
 ; get the sample points
 ;-----------------------------------
 outline_pts = pnt_points(outline_ptd)
 if(n_elements(outline_pts) EQ 2) then sub = xy_to_w(dim[0:1], outline_pts) $
 else sub = polyfillv(outline_pts[0,*], outline_pts[1,*], dim[0], dim[1])
 nsub = n_elements(sub)

 ;-----------------------------------------------
 ; extract core
 ;-----------------------------------------------
;; need to interpolate each channel using imageinterp_cam; see pg_profile_image
; core = get_cube_core(cube, cd, p, nl, nw, sample, $
;       distance=distance, interp=interp, arg_interp=arg_interp, sigma=sigma, image_pts=image_pts)



 cube = reform(cube, dim[0]*dim[1], dim[2], /over)
 abscissa = reform(abscissa, dim[0]*dim[1], dim[2], /over)
 cores = cube[sub,*]
 abscissas = abscissa[sub,*]

 core = total(cores, 1)/nsub
 abscissa = total(abscissas, 1)/nsub
 if(nsub GT 1) then sigma = sqrt( total(cores^2,1)/nsub - (total(cores,1)/nsub)^2 )

 dd_core = dat_create_descriptors(1, data=core, abscissa=abscissa, name=cor_name(dd[0]))
 dat_set_header, dd_core[0], dat_header(dd[0])

 if(keyword_set(sigma)) then $
  begin
   dd_core = [dd_core, $
     dat_create_descriptors(1, data=sigma, abscissa=abscissa, name=cor_name(dd[0]))]
   dat_set_header, dd_core[1], dat_header(dd[0])
  end

 return, dd_core





 ;-----------------------------------
 ; get the points
 ;-----------------------------------
 outline_pts = pnt_points(outline_ptd)
 nl = cor_udata(outline_ptd, 'nl')
 nw = cor_udata(outline_ptd, 'nw')
 sample = cor_udata(outline_ptd, 'sample')
 nl = nl[0] & nw = nw[0] & sample = sample[0]


 ;-----------------------------------------------
 ; set up sampling grid
 ;-----------------------------------------------
 if(nw EQ 1) then $
  begin
   p0 = outline_pts[*,0]
   p1 = outline_pts[*,nl-1]
  end $
 else $
  begin
   p0 = 0.5*(outline_pts[*,0] + outline_pts[*,nl+nw+nl])
   p1 = 0.5*(outline_pts[*,nl] + outline_pts[*,nl+nw])
  end
 p = tr([tr(p0), tr(p1)])

 
 ;-----------------------------------------------
 ; extract profile
 ;-----------------------------------------------
; need to sample data descriptor....

 profile = get_image_profile(im, cd, p, nl, nw, sample, $
       distance=distance, interp=interp, arg_interp=arg_interp, sigma=sigma, image_pts=image_pts)
 if(keyword_set(bg)) then profile = profile - bg[0]

 dd_prof = [ dat_create_descriptors(1, data=profile, abscissa=distance, name=cor_name(dd)), $
             dat_create_descriptors(1, data=sigma, abscissa=distance, name=cor_name(dd)) ]

 dat_set_header, dd_prof[0], dat_header(dd)
 dat_set_header, dd_prof[1], dat_header(dd)

 image_ptd = pnt_create_descriptors(points=image_pts)
 cor_set_udata, dd_prof[0], 'IMAGE_PTD', image_ptd
 cor_set_udata, dd_prof[1], 'IMAGE_PTD', image_ptd

 return, dd_prof
end
;==============================================================================


pro test
;grim ~/casIss/1495/N1495308131_1.IMG over=rings
grift, dd=dd, cd=cd

outline_ptd = pg_image_sector()
profile = pg_core(dd, outline_ptd, cd=cd, distance=distance)

;p = tvline()
;p = (convert_coord(/device, /to_data, double(p[0,*]), double(p[1,*])))[0:1,*]

;profile = pg_core(dd, cd=cd, p, distance=distance)
plot, distance, profile


end
