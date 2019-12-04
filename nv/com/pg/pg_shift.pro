;=============================================================================
;+
; NAME:
;	pg_shift
;
;
; PURPOSE:
;	Shifts the given image by a non-integer offset and adjusts the camera
;	pointing accordingly.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_shift, dd, cd=cd, dxy
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Array of data descriptors giving images to shift.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array of camera descripors, one for each input image.
;
;	dxy:	Array (2,np) of shifts for each input image.
;
;	gd:	Generic descriptor containing the camera and body
;		descriptors or an array of generic descriptors, one for each
;		input image.
;
;
;  OUTPUT: NONE
;
;
; SIDE EFFECTS:
;	The given data and camera descriptors are modified: the images are
;	shifted and the camera descriptor optic axes are changed accordingly.
;
;
; STATUS:
;	xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2008
;	
;-
;=============================================================================
pro pg_shift, dd, dxy, cd=cd, gd=gd

 n = n_elements(dd)

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)

 
 ;-----------------------------------------------
 ; compute shift each image and cd
 ;-----------------------------------------------
 for i=0, n-1 do $ 
  if(max(abs(dxy[*,i] - fix(dxy[*,i]))) GT 0) then $
   dat_set_data, dd[i], image_shift(dat_data(dd[i]), dxy[0,i], dxy[1,i], cd=cd[i]) $
  else dat_set_data, dd[i], shift_image(dat_data(dd[i]), -dxy[0,i], -dxy[1,i]) 

 if(keyword_set(cd)) then $
  begin
   set_image_origin, cd, image_origin(cd) - dxy
   cor_add_task, cd, 'pg_shift' 
  end
  
 

end
;=============================================================================
