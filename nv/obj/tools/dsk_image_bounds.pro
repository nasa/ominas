;=============================================================================
;+
; NAME:
;       dsk_image_bounds
;
;
; PURPOSE:
;	Determines disk coordinate ranges visible in an image described
;	by a given camera descriptor.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       dsk_image_bounds, cd, dkx, $
;	        radmin=radmin, radmax=radmax, lonmin=lonmin, lonmax=lonmax
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descripor.
;
;	dkx:	Any subclass of DISK.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	np:	Number of border points to compute.
;
;	slop:	Number of pixels by which to expand the image in each
;		direction.
;
;	plane:	If set, the sma field in dkx is ignored, so an infinite
;		disk is considered.
;
;
;  OUTPUT: 
;	radmin:	Minimum disk radius in image.
;
;	radmax:	Maximum disk radius in image.
;
;	lonmin:	Minimum disk longitude in image.
;
;	lonmax:	Maximum disk longitude in image.
;
;	border_pts_im:	Array (2,np) of points along the edge of the image.
;
;	status:	-1 if no disk in the image, 0 otherwise.
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
pro dsk_image_bounds, cd, dkx, slop=slop, border_pts_im=border_pts_im, $
   radmin=radmin, radmax=radmax, lonmin=lonmin, lonmax=lonmax, np=npp, $
   plane=plane, status=status, crop=crop, corners=corners, viewport=viewport

 status = -1

 if(NOT keyword_set(np)) then npp = 1000

 ;-----------------------------------
 ; compute image border points
 ;-----------------------------------
 if(NOT keyword_set(border_pts_im)) then $
      border_pts_im = get_image_border_pts(cd, crop=crop, corners=corners, viewport=viewport)
 np = n_elements(border_pts_im)/2

 if(keyword_set(slop)) then corners = !null $
 else slop = 1


 ;-----------------------------------
 ; compute ring intersections
 ;-----------------------------------
 nv_suspend_events
 sma0 = dsk_sma(dkx)
 if(keyword_set(plane)) then $
  begin
   sma = sma0
   sma[0,0,*] = 0d & sma[0,1,*] = 1d100
   dsk_set_sma, dkx, sma
  end

 border_pts_disk = image_to_disk(cd, dkx, border_pts_im, hit=hit, body_pts=int_pts_body)

 dsk_set_sma, dkx, sma0
 nv_resume_events

 if(hit[0] NE -1) then $
  begin
   int_pts_body = int_pts_body[hit,*]
   int_pts = bod_body_to_inertial_pos(dkx, int_pts_body)
   all_pts = int_pts
  end


 ;-------------------------------------------------------
 ; compute ring edge points
 ;-------------------------------------------------------
 disk_pts = dsk_get_disk_points(dkx, npp)

 disk_inertial_pts0 = bod_body_to_inertial_pos(dkx, disk_pts[*,*,0])
 disk_inertial_pts1 = bod_body_to_inertial_pos(dkx, disk_pts[*,*,1])
 disk_inertial_pts = [disk_inertial_pts0, disk_inertial_pts1]

 disk_image_pts0 = reform(inertial_to_image_pos(cd, disk_inertial_pts0))
 disk_image_pts1 = reform(inertial_to_image_pos(cd, disk_inertial_pts1))
 disk_image_pts = tr([tr(disk_image_pts0), tr(disk_image_pts1)])

 w = in_image(cd, disk_image_pts, slop=slop, corners=corners)
 if(w[0] NE -1) then all_pts = append_array(all_pts, disk_inertial_pts[w,*])

 if(NOT keyword_set(all_pts)) then return


 ;--------------------------------------------------------
 ; compute min/max rad/lon 
 ;--------------------------------------------------------
 all_pts_dsk = inertial_to_disk_pos(dkx, all_pts)

 rad = all_pts_dsk[*,0]
 radmin = min(rad)
 radmax = max(rad)

 lon = reduce_angle(all_pts_dsk[*,1])
 nlon = n_elements(lon)

 if(nlon EQ 1) then lonmin = (lonmax = lon[0]) $
 else $
  begin
   ll = lon[sort(lon)]
   dll = ll[1:nlon-1] - ll[0:nlon-2]
   dllmax = max(dll)

   if(dllmax GT !dpi/2) then $
    begin
     w = where(dll EQ dllmax)
     lonmax = ll[w[0]]
     lonmin = ll[w[0]+1] - 2d*!dpi
    end $
   else $
    begin
     lonmin = ll[0]
     lonmax = ll[nlon-1]
    end
   end

 status = 0
end
;===========================================================================
