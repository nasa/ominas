;=============================================================================
;+
; NAME:
;       radec_image_bounds
;
;
; PURPOSE:
;	Determines radec coordinate ranges visible in an image described
;	by a given camera descriptor.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       radec_image_bounds, cd, $
;	        ramin=ramin, ramax=ramax, decmin=decmin, decmax=decmax
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descripor.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	corners:	Array(2,2) giving corers of image region to consider.
;
;	slop:	Number of pixels by which to expand the image in each
;		direction.
;
;
;  OUTPUT: 
;	ramin:	Minimum RA in image.
;
;	ramax:	Maximum RA in image.
;
;	decmin:	Minimum DEC in image.
;
;	decmax:	Maximum DEC in image.
;
;	border_pts_im:	Array (2,np) of points along the edge of the image.
;
;	status:	-1 if no globe in the image, 0 otherwise.
;
;
; RETURN: NONE
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
pro radec_image_bounds, cd, slop=slop, border_pts_im=border_pts_im, $
               ramin=ramin, ramax=ramax, decmin=decmin, decmax=decmax, $
               corners=corners, status=status

 status = -1

 ;-----------------------------------
 ; compute image border points
 ;-----------------------------------
 if(NOT keyword_set(border_pts_im)) then $
              border_pts_im = get_image_border_pts(cd, corners=corners)
 np = n_elements(border_pts_im)/2

 center = total(corners, 2)/4


 ;-----------------------------------
 ; compute ra/dec
 ;-----------------------------------
 border_pts_radec = image_to_radec(cd, border_pts_im)
 center_radec = image_to_radec(cd, center)


 ;----------------------------------------------
 ; compute min/max ra/dec
 ;----------------------------------------------
 ra = reduce_angle(border_pts_radec[*,0])
 dec = border_pts_radec[*,1]
 decmin = min(dec) & decmax = max(dec)

 ;-  -  -  -  -  -  -  -  -  -  -
 ; test poles
 ;-  -  -  -  -  -  -  -  -  -  -
 pole_pts_radec = [ tr([0d, !dpi/2d, 1d]), $
                    tr([0d, -!dpi/2d, 1d]) ]
 pole_pts_image = radec_to_image(cd, pole_pts_radec)

 ramin = 0d & ramax = 2d*!dpi
 w = in_image(0, pole_pts_image, slop=slop, corners=corners)
 if((where(w EQ 0))[0] NE -1) then decmax = !dpi/2d 
 if((where(w EQ 1))[0] NE -1) then decmin = -!dpi/2d 
 if(w[0] EQ -1) then $
  begin
   ramin = min(ra) & ramax = max(ra)
   center_ra = reduce_angle(center_radec[0])
   if((center_ra GT ramax) OR (center_ra LT ramin)) then $
    begin
     x = ramax
     ramax = ramin
     ramin = x - 2d*!dpi
    end
  end

 status = 0
end
;===========================================================================
