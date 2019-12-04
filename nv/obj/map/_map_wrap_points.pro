; docformat = 'rst rst'
;+
;
; :Private:
;
;-


;=============================================================================
;++
; NAME:
;	_map_wrap_points
;
;
; PURPOSE:
;	Forces all map image points to lie inside a specified map by wrapping
;	longitudes.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	wrap_image_pts = map_wrap_points(md, image_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	md	 	Array (nt) of MAP descriptors.
;
;	image_pts:	Array (2,nv,nt) of map image points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (2,nv,nt) of wrapped map image points.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
function _map_wrap_points, _md, _image_pts, _map_pts

 nt = n_elements(_md)
 np = n_elements(_image_pts)/2/nt

 pi2 = !dpi/2d

 image_pts = _image_pts
 map_pts = _map_pts

 ii = transpose(linegen3z(2,nt,np), [0,2,1])
 size = (_md.size)[ii]


 ;---------------------------------------
 ; wrap points that lie outside map 
 ;---------------------------------------
 lons = (mlons = (plons = map_pts[1,*,*]))

 ;- - - - - - - - - - - - - - - - - -
 ; try longitudes minus 2pi
 ;- - - - - - - - - - - - - - - - - -
 w = where(image_pts[0,*,*] LT 0 OR image_pts[0,*,*] GT size[0,*,*]-1 OR $
                 image_pts[1,*,*] LT 0 OR image_pts[1,*,*] GT size[1,*,*]-1)
 if(w[0] NE -1) then $
  begin
   ww = rowgen(2,np,nt, w)
   mlons[w] = lons[w] - 2d*!dpi
   map_pts[1,*,*] = mlons
   image_pts[ww] = map_map_to_image(_md, map_pts[ww], /nowrap, /all)
  end

 ;- - - - - - - - - - - - - - - - - -
 ; try longitudes plus 2pi
 ;- - - - - - - - - - - - - - - - - -
 w = where(image_pts[0,*,*] LT 0 OR image_pts[0,*,*] GT size[0,*,*]-1 OR $
                 image_pts[1,*,*] LT 0 OR image_pts[1,*,*] GT size[1,*,*]-1)
 if(w[0] NE -1) then $
  begin
   ww = rowgen(2,np,nt, w)
   plons[w] = lons[w] + 2d*!dpi
   map_pts[1,*,*] = plons
   image_pts[ww] = map_map_to_image(_md, map_pts[ww], /nowrap, /all)
  end

 return, image_pts
end
;===========================================================================



;=============================================================================
function __map_wrap_points, _md, _image_pts

 nt = n_elements(_md)
 np = n_elements(_image_pts)/2/nt

 pi2 = !dpi/2d

 image_pts = _image_pts

 ii = transpose(linegen3z(2,nt,np), [0,2,1])
 size = (_md.size)[ii]


 ;---------------------------------------
 ; determine full projected map size
 ;---------------------------------------
 map_corners = ([[-pi2,0], [pi2,2d*!dpi]])[linegen3z(2,2,nt)]
 image_corners = map_map_to_image(_md, map_corners, /nowrap, /all)
 full = image_corners[*,1,*] - image_corners[*,0,*]


 ;---------------------------------------
 ; wrap points that lie outside map 
 ;---------------------------------------
 px = image_pts[0,*,*]
 py = image_pts[1,*,*]
 fx = full[0,*,*]
 fy = full[1,*,*]
 sx = full[0,*,*]
 sy = full[1,*,*]


 w = where(px GE sx)
 if(w[0] NE -1) then px[w] = px[w] - fx[w]
 w = where(px LT 0)
 if(w[0] NE -1) then px[w] = px[w] + fx[w]
 w = where(py GE sy)
 if(w[0] NE -1) then py[w] = py[w] - fy[w]
 w = where(py LT 0)
 if(w[0] NE -1) then py[w] = py[w] + fy[w]

 image_pts[0,*,*] = px
 image_pts[1,*,*] = py

 return, image_pts
end
;===========================================================================



;=============================================================================
function _map_wrap_points, _md, _image_pts

 pi2 = !dpi/2d

 image_pts = _image_pts

 ;---------------------------------------
 ; determine full projected map size
 ;---------------------------------------
 map_corners = [[-pi2,0], [pi2,2d*!dpi]]
 image_corners = map_map_to_image(_md, map_corners, /nowrap)
 xfull = image_corners[0,1,*] - image_corners[0,0,*]
 yfull = image_corners[1,1,*] - image_corners[1,0,*]


 ;---------------------------------------
 ; wrap points that lie outside map 
 ;---------------------------------------
 w = where(image_pts[0,*] GE _md.size[0])
 if(w[0] NE -1) then image_pts[0,w] = image_pts[0,w] - xfull
 w = where(image_pts[0,*] LT 0)
 if(w[0] NE -1) then image_pts[0,w] = image_pts[0,w] + xfull

 w = where(image_pts[1,*] GE _md.size[1])
 if(w[0] NE -1) then image_pts[1,w] = image_pts[1,w] - yfull
 w = where(image_pts[1,*] LT 0)
 if(w[0] NE -1) then image_pts[1,w] = image_pts[1,w] + yfull


 return, image_pts
end
;===========================================================================
