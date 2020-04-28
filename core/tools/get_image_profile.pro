;=============================================================================
;+
; NAME:
;       get_image_profile
;
;
; PURPOSE:
;	Extracts a profile from a rectangular, but not necessarily axis-aligned, 
;	image region using interpolation.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       profile = get_image_profile(image, cd, p, nl, nw, sample)
;
;
; ARGUMENTS:
;  INPUT:
;	image:	Image array.
;
;	cd:	Camera descriptor.
;
;	p:	Array (2,2) of image points giving the start and end points
;		for the scan.
;
;	nl:	Number of samples along the scan.
;
;	nw:	Number of samples across the scan.
;
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: 
;	interp:		Type of interpolation, see image_interp_cam.
;
;	arg_interp:	Interpolation argument, see image_interp_cam.
;
;  OUTPUT: 
;	image_pts:	Array (2,nl) of image points along the center of
;			the scan.
;
;	distance:	Array (nl) giving the distance along the scan.
;
;	sigma:		Standard deviation across the profile at each sample
;			along the profile.
;
;
; RETURN: 
;	Array (nl) containing the profile.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function get_image_profile, im, cd, p, nl, nw, sample, distance=distance, $
                      interp=interp, arg_interp=arg_interp, sigma=sigma, $
                      image_pts=image_pts

 ;-----------------------------------------------
 ; set up sampling grid
 ;-----------------------------------------------
 x = double(p[0,*])
 y = double(p[1,*])

 xmax = max(x) & xmin = min(x)
 ymax = max(y) & ymin = min(y)

 dx = x[1] - x[0]
 dy = y[1] - y[0]
 theta = -atan(dy,dx)

 distance = dindgen(nl)/sample
 grid_x = distance # make_array(nw,val=1d)
 grid_y = dindgen(nw)/sample ## make_array(nl,val=1d) - nw/sample/2.

 grid_xx = grid_x*cos(theta) + grid_y*sin(theta)
 grid_yy = -grid_x*sin(theta) + grid_y*cos(theta)

 grid_xx = grid_xx + x[0]
 grid_yy = grid_yy + y[0]

 if(nw EQ 1) then image_pts = [transpose(grid_xx), transpose(grid_yy)] $
 else image_pts = [transpose(total(grid_xx,2)), transpose(total(grid_yy,2))]/double(nw)


 ;-----------------------------------------------
 ; extract profile
 ;-----------------------------------------------
 imm = image_interp_cam(cd=cd, im, grid_xx, grid_yy, arg_interp, interp=interp)
 sigma = dblarr(nl)


 ;-----------------------------------------------
 ; zero out points that lie outside the image
 ;-----------------------------------------------
 s = size(im)
 ww = where((grid_xx LT 0) OR (grid_yy LT 0) $
              OR (grid_xx GT s[1]-1) OR (grid_yy GT s[2]-1))
 if(ww[0] NE -1) then imm[ww] = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; compute # valid points at each position in scan
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 simm = size(imm)
 immm = make_array(simm[1],simm[2], val=1)
 if(ww[0] NE -1) then immm[ww] = 0
 nww = total(immm,2)
 www = where(nww EQ 0)
 if(www[0] NE -1) then nww[www] = 1

 ;-----------------------------------------------
 ; compute mean and deviation along profile
 ;-----------------------------------------------
 profile = imm
 if(nw GT 1) then $
  begin
   profile = total(imm,2)/nww
   sigma = sqrt( total(imm^2,2)/nww - (total(imm,2)/nww)^2 )
  end 

 return, profile
end
;==============================================================================


