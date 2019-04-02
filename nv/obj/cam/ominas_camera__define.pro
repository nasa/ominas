;=============================================================================
; ominas_camera::init
;
;=============================================================================
function ominas_camera::init, _ii, crd=crd0, bd=bd0, cd=cd0, $
@cam__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(cd0)) then struct_assign, cd0, self
 void = self->ominas_body::init(ii, crd=crd0, bd=bd0, $
@bod__keywords_tree.include
end_keywords)


 ;-------------------------------------------------------------------------
 ; Handle index errors: set index to zero and try again.  This allows a 
 ; single input to be applied to multiple objects, via multiple calls to
 ; this method.  In that case, all inputs must be given as single inputs.
 ;-------------------------------------------------------------------------
 catch, error
 if(error NE 0) then $
  begin
   ii = 0
   catch, /cancel
  end

 
 ;---------------------------------------------------------------
 ; assign initial values
 ;---------------------------------------------------------------
 self.abbrev = 'CAM'
 self.tag = 'CD'

 if(keyword_set(scale)) then self.scale = scale[*,ii]
 if(keyword_set(oaxis)) then self.oaxis = oaxis[*,ii]
 if(keyword_set(exposure)) then self.exposure = decrapify(exposure[ii])
 if(keyword_set(fn_psf)) then self.fn_psf = fn_psf[ii]
 if(keyword_set(filters)) then self.filters[0:(size(filters,/dim))[0]-1] = filters[*,ii]
 if(keyword_set(size)) then self.size = size[*,ii]
 if(keyword_set(fn_focal_to_image)) then $
                        self.fn_focal_to_image=decrapify(fn_focal_to_image[ii]) $
 else self.fn_focal_to_image = decrapify('cam_focal_to_image_linear')
 if(keyword_set(fn_image_to_focal)) then $
                          self.fn_image_to_focal=decrapify(fn_image_to_focal[ii]) $
 else self.fn_image_to_focal = decrapify('cam_image_to_focal_linear')
 if(keyword_set(fn_body_to_image)) then $
   self.fn_body_to_image=decrapify(fn_body_to_image[ii]) 
 if(keyword_set(fn_body_to_inertial)) then $
   self.fn_body_to_inertial=decrapify(fn_body_to_inertial[ii])

 if(keyword_set(fi_data)) then cam_set_fi_data, cd0, fi_data[ii], /noevent

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_camera__define
;
;
; PURPOSE:
;	Class structure fo the CAMERA class.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	scale:	2-element array giving the camera scale (radians/pixel) in 
;		each direction.  The meaning of this quantity depends on the
;		distortion model.
;
;		Methods: cam_scale, cam_set_scale
;
;
;	oaxis:	2-element array giving the image coordinates corresponding 
;		to the camera optic axis.
;
;		Methods: cam_oaxis, cam_set_oaxis
;
;
;	exposure:	Exposure duration.  BODY time refers to the 
;			center of this interval.
;
;			Methods: cam_exposure, cam_set_exposure
;
;
;	size:	Image size in pixels.
;
;		Methods: cam_size, cam_set_size
;
;	filters:	String array giving the names of each filter.
;
;
;	fn_focal_to_image:	String giving the name of a function
;				that transforms points in the focal
;				plane coordinate system to points in 
;				the image coordinate system.  Default is
;				cam_image_to_focal_linear().
;
;				Methods: cam_fn_focal_to_image, 
;				         cam_set_fn_focal_to_image
;
;
;	fn_image_to_focal:	String giving the name of a function
;				that transforms points in the image
;				coordinate system to points in the focal-
;				plane coordinate system.  Default is
;				cam_image_to_focal_linear().
;
;				Methods: cam_fn_image_to_focal 
;				         cam_set_fn_image_to_focal
;
;
;	fn_psf:	String giving the name of a function to be defined as 
;		follows:
;
;		function <name>, cd, x, y, default=default
;
;		The function should return an array of PSF values at the given 
;		coordinates, subject to the following rules:
;
;		1) If neither x nor y are given, then a PSF function is returned
;		   on some default grid, which is application-specific.
;
;		2) If only x is given, then PSF values are returned for each x, 
;		   with y values set to zero.
;
;		3) If x and y are given, then PSF values are returned at all 
;		   points (x,y).
;
;
;		Methods: cam_fn_psf, cam_set_fn_psf, cam_psf, cam_psf_attrib
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
pro ominas_camera__define

 nfilt = cam_nfilters()

 struct = $
    { ominas_camera, inherits ominas_body, $
	scale:		 dblarr(2), $		; camera scale in each direction
						; (radians/pixel)
	oaxis:		 dblarr(2), $		; image coordinates of optical
						; axis
	size:		 dblarr(2), $		; Image size, pixels
	exposure:	 0d, $			; exposure duration; body time
						; is specified at center of this
						; interval
	filters:	strarr(nfilt), $	; Filter names

	fn_psf:		'', $			; Point-spread fn.

	fn_focal_to_image:   '', $		; user procedures to tranform
	fn_body_to_image:'',$
  ;fn_body_to_inertial:'',$
	fn_image_to_focal:   '' $		; between focal and image
    }

end
;===========================================================================
