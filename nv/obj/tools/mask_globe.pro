;=============================================================================
;+
; NAME:
;       mask_globe
;
;
; PURPOSE:
;	Computes an image mask for a globe.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       result = mask_globe(cd, gbx)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	gbx:	Any subclass of GLOBE.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	slop:	Fractional amount by which to increase the globe
;		radii before computing the mask.
;
;	oversample:	Factor by wich to oversample the grid to reduce
;			aliasing.
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Angle in radians.
;
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function mask_globe, cd, _gbx, oversample=oversample, slop=slop, sub=valid

 if(NOT keyword_set(oversample)) then oversample = 1
 if(NOT keyword_set(slop)) then slop = 0.1

 gbx = nv_clone(_gbx, 'GLOBE')
 glb_set_radii, gbx, glb_radii(gbx)*(1d + slop)


 ;-----------------------------------
 ; determine sub-region to search
 ;-----------------------------------
 limb_pts = body_to_image_pos(cd, gbx, $
             glb_get_limb_points(gbx, $
                  bod_inertial_to_body_pos(gbx, bod_pos(cd)), 0, 0, 1))

 nxy = cam_size(cd)
 ii = polyfillv(limb_pts[0,*], limb_pts[1,*], nxy[0], nxy[1])
 nii = n_elements(ii)


 ;-----------------------------------
 ; build mask
 ;-----------------------------------
 mask = fltarr(nxy[0],nxy[1])
 
 image_pts0 = w_to_xy(0, ii, sx=nxy[0], sy=nxy[1])
 image_pts = dblarr(2,nii, /nozero)
 h = oversample/2
 for i=-h, h do $
  for j=-h, h do $
   begin
    image_pts[0,*] = image_pts0[0,*] + float(i)/oversample
    image_pts[1,*] = image_pts0[1,*] + float(j)/oversample
    globe_pts = image_to_globe(cd, gbx, image_pts, valid=valid)
    if(valid[0] NE -1) then mask[ii[valid]] = mask[ii[valid]] + 1
   end

 mask = mask / oversample / oversample


 nv_free, gbx
 return, mask
end
;=================================================================================
