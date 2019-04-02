;=============================================================================
;+
; NAME:
;	pg_photom_globe
;
;
; PURPOSE:
;	Photometric image correction for globe objects.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_photom_globe(dd, cd=cd, gbx=gbx)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing image to correct.
;
;
;  OUTPUT:
;	NONE
;
; KEYWORDS:
;  INPUT:
;	cd:	Camera descriptor
;
;	gbx:	Globe descriptor
;
;	ltd:	Light descriptor
;
;	gd:	Generic descriptor.  If present, cd and gbx are taken from 
;		here if contained.
;
; 	outline_ptd:	POINT with image points outlining the 
;			region of the image to correct.  To correct the entire
;			planet, this input could be generated using pg_limb(). 
;			If this keyword is not given, the entire image is used.
;
;	refl_fn:	String naming reflectance function to use.  Default is
;			'pht_refl_minneart'.
;
;	refl_parms:	Array of parameters for the photometric function named
;			by the 'refl_fn' keyword.
;
;	phase_fn:	String naming phase function to use.  Default is none.
;
;	phase_parms:	Array of parameters for the photometric function named
;			by the 'phase_fn' keyword.
;
;	overwrite:	If set, the output descriptor is the input descriptor
;			with the relevant fields modified.
;
;  OUTPUT:
;	emm_out:	Image emission angles.
;
;	inc_out:	Image incidence angles.
;
;	phase_out:	Image phase angles.
;
;
; RETURN:
;	New data descriptor containing the corrected image.  The photometric 
;	angles emm, inc, and phase are placed in the user data arrays with 
;	the tags'EMM', 'INC', and 'PHASE' respectively.  Unless /overwrite is
;	set, the nw descriptor is a clone of the input descriptor, with the 
;	relevant fields modified.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002 (pg_photom)
;	 Spitale, 6/2004:	changed to pg_photom_globe
;	
;-
;=============================================================================
function pg_photom_globe, dd, outline_ptd=outline_ptd, $
                  cd=cd, gbx=gbx, ltd=ltd, gd=gd, $
                  refl_fn=refl_fn, phase_fn=phase_fn, $
                  refl_parm=refl_parm, phase_parm=phase_parm, $
                  emm_out=emm_out, inc_out=inc_out, phase_out=phase_out, overwrite=overwrite

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(ltd)) then ltd = dat_gd(gd, dd=dd, /ltd)


 ;----------------------------------------------
 ; get phot functions; default is Lunar-Lambert
 ;----------------------------------------------
 if(NOT keyword_set(refl_fn)) then $
  begin
   refl_fn = sld_refl_fn(gbx)
   refl_parm = sld_refl_parm(gbx)
  end

 if(NOT keyword_set(phase_fn)) then $
  begin
   phase_fn = sld_phase_fn(gbx)
   phase_parm = sld_phase_parm(gbx)
  end

 if(NOT keyword_set(refl_fn)) then refl_fn = 'pht_refl_lunar_lambert'


 ;-----------------------------------------------
 ; validate descriptors
 ;-----------------------------------------------
 if(n_elements(cd) GT 1) then nv_message, 'Only one camera descriptor allowed.'
 if(n_elements(gbx) GT 1) then nv_message, 'Only one globe descriptor allowed.'
 if(n_elements(ltd) GT 1) then nv_message, 'Only one light descriptor allowed.'


 ;---------------------------------------
 ; dereference the data descriptor 
 ;---------------------------------------
 image = dat_data(dd)
 s = cam_size(cd)
 xsize = s[0] & ysize = s[1]

 xysize = xsize*ysize


 ;---------------------------------------
 ; find relevant image points 
 ;---------------------------------------
 if(keyword_set(outline_ptd)) then $
  begin
   p = pnt_points(outline_ptd)
   p = poly_rectify(p)
   indices = polyfillv(p[0,*], p[1,*], xsize, ysize)
  end $
 else indices = lindgen(xysize)

 xarray = indices mod ysize
 yarray = fix(indices / ysize) + 1
 ai = array_indices([xsize,ysize],indices,/dim)
 xarray = reform(ai[0,*])
 yarray = reform(ai[1,*])

 nn = n_elements(xarray)

 image_pts = dblarr(2, nn)
 image_pts[0,*] = xarray
 image_pts[1,*] = yarray


 ;---------------------------------------
 ; compute photometric angles
 ;---------------------------------------
 pht_angles, image_pts, cd, gbx, ltd, emm=mu, inc=mu0, g=g
 valid = where(mu0 NE 0)
 if(valid[0] EQ -1) then nv_message, 'No valid points in image region.'

 mu0 = mu0[valid] 
 mu = mu[valid] 
 g = g[valid] 
 indices = indices[valid]


 ;---------------------------------------
 ; correct the image
 ;---------------------------------------
 phase_corr = 1d
 if(keyword_set(phase_fn)) then $
                   phase_corr = call_function(phase_fn, g, phase_parm)
 refl_corr = call_function(refl_fn, mu, mu0, refl_parm)

 new_image = float(image)
 new_image[indices] = new_image[indices] / phase_corr / refl_corr
 new_image = new_image < max(image)

 ;---------------------------------------
 ; modify the data descriptor
 ;---------------------------------------
 if(keyword_set(overwrite)) then dd_pht = dd $
 else dd_pht = nv_clone(dd)
 dat_set_data, dd_pht, new_image

 ;---------------------------------------
 ; fill output arrays
 ;---------------------------------------
 emm = fltarr(xsize,ysize)
 emm[indices] = mu
 cor_set_udata, dd_pht, 'EMM', emm

 inc = fltarr(xsize,ysize)
 inc[indices] = mu0
 cor_set_udata, dd_pht, 'INC', inc

 phase = fltarr(xsize,ysize)
 phase[indices] = g
 cor_set_udata, dd_pht, 'PHASE', phase

 emm_out = emm
 inc_out = inc
 phase_out = phase_out

 return, dd_pht 
end
;=============================================================================
