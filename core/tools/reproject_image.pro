;=============================================================================
;++ **incomplete**
; NAME:
;       reproject_image
;
;
; PURPOSE:
;       xx
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       result = project_map(image, md=md, cd=cd, gbx=gbx, $
;                            pc_xsize, pc_ysize, $
;                            hide_fn=hide_fn, hide_data_p=hide_data_p)
;
;
; ARGUMENTS:
;  INPUT:
;          image:     Image of body.
;
;       pc_xsize:     x size of map workspace
;
;       pc_ysize:     y size of map workspace
;
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;             md:     Map descriptor.
;
;             cd:     Camera descriptor.
;
;            gbx:     Globe descriptor.
;
;        hide_fn:     Array of hide functions, e.g. 'pm_hide_ring'
;
;    hide_data_p:     Array of hide data pointers, e.g. nv_ptr_new(rd)
;
;            map:     Input map.  If given, the new map will be projected OVER
;                     this map.  This input map must be consistent with the
;                     given map desciptor.
;
; OUTPUT:
;	NONE
;
;
; RETURN:
;       The reprojected image.
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 6/1998
;
;-
;=============================================================================
function reproject_image, image, cd=cd, new_cd=new_cd, $
                      pc_xsize, pc_ysize, size=size, $
                      interp=interp, arg_interp=arg_interp


 new_xsize = long(size[0])
 new_ysize = long(size[1])

 ;=========================
 ; allocate the new image
 ;=========================
 s = size(image)
 image_xsize = long(s[1])
 image_ysize = long(s[2])
 type = s[s[0]+1]
 new_image = make_array(new_xsize, new_ysize, type=type)


 ;================================
 ; construct the map in pieces
 ;================================
 pc_xsize = pc_xsize < new_xsize
 pc_ysize = pc_ysize < new_ysize

 pc_nx = long(new_xsize/pc_xsize)
 pc_ny = long(new_ysize/pc_ysize)

 pc_xsize = long(pc_xsize)
 pc_ysize = long(pc_ysize)

 for j=0, pc_ny-1 do $
  for i=0, pc_nx-1 do $
   begin
    ;------------------------------------
    ; determine the size of this piece
    ;------------------------------------
    xsize = pc_xsize
    ysize = pc_ysize
    if(i EQ pc_nx-1) then xsize = new_xsize - (pc_nx-1)*pc_xsize
    if(j EQ pc_ny-1) then ysize = new_ysize - (pc_ny-1)*pc_ysize
    n = xsize*ysize

    ;------------------------------------
    ; construct pixel grid on this piece
    ;------------------------------------
    new_image_pts = dblarr(2,n, /nozero)
    x0 = i*pc_xsize & y0 = j*pc_ysize
    new_image_pts[0,*] = $
        reform((dindgen(xsize) + double(x0))#make_array(ysize,val=1), n, /over)
    new_image_pts[1,*] = $
        reform((dindgen(ysize) + double(y0))##make_array(xsize,val=1), n, /over)




    ;-----------------------------------------------------
    ; map new image coordinates to original image coords
    ;-----------------------------------------------------
    focal_pts = cam_image_to_focal(new_cd, new_image_pts)
    image_pts = cam_focal_to_image(cd, focal_pts)

    sub = external_points(image_pts, 0, image_xsize-1, 0, image_ysize-1)
    if(sub[0] NE -1) then image_pts[0,sub] = (image_pts[1,sub] = 0)


    ;------------------------------
    ; build the map for this piece
    ;------------------------------
    grid_x = reform(image_pts[0,*], xsize, ysize)
    grid_y = reform(image_pts[1,*], xsize, ysize)

    pc_map = image_interp_cam(cd=cd, image, double(grid_x), double(grid_y), $
                                                      arg_interp, interp=interp)
    if(sub[0] NE -1) then pc_map[sub] = 0

    ;------------------------------
    ; insert into the main map
    ;------------------------------
    new_image[x0:x0+xsize-1, y0:y0+ysize-1] = pc_map
   end



 return, new_image
end
;=============================================================================






