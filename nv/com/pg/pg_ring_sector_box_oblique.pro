;=============================================================================
;+
; NAME:
;	pg_ring_sector_box_oblique
;
; PURPOSE:
;	Allows the user to select an oblique box to use with pg_profile_ring.
; 
; CATEGORY:
;       NV/PG
;
; CALLING SEQUENCE:
;     outline_ptd=pg_ring_sector_box_oblique()
;     outline_ptd=pg_ring_sector_box_oblique(corners)
;
;
; ARGUMENTS:
;  INPUT:
;      corners:	    Array of image points giving the four corners of the box.
;		    If not given, the user is prompted to select a box. 
;
;
;  OUTPUT:
;	NONE
;
;
;
; KEYWORDS:
;  INPUT: 
;      win_num:     Window number of IDL graphics window in which to select
;                   box, default is current window.
;
;      restore:     Do not leave the box in the image.
;
;           p0:     First corner of box.  If set, then the routine immediately 
;                   begins to drag from that point until a button is released.
;
;        color:     Color to use for rectangle, default is !color.
;
;        slope:     This keyword allows the longitude to vary from the
;                   perpendicular direction as a function of radius as: 
;                   lon = slope*(rad - rad0).
;
; xor_graphics:     If set, the sector outline is drawn and erased using xor
;                   graphics instead of a pixmap.
;
;    noverbose:     If set, messages are suppressed.
;
;       sample:     Grid sampling, default is 1.
;
;
;  OUTPUT:
;         NONE
;
;
; RETURN: 
;      POINT object containing points on the sector outline.  The point
;      spacing is determined by the sample keyword.  The POINT object
;      also contains the disk coordinate for each point and the user fields
;      'nrad' and 'nlon' giving the number of points in radius and longitude.
;
; KNOWN BUGS:
;	The sector flips when it hits zero azimuth rather than retaining a 
;	consistent sense.
;
;
; ORIGINAL AUTHOR : J. Spitale ; 9/2006
;
;-
;=============================================================================



;=============================================================================
; pg_ring_sector_box_oblique
;
;=============================================================================
function pg_ring_sector_box_oblique, p, $
                         lon=lon, sample=sample, $
                         win_num=win_num, $
                         restore=restore, $
                         p0=_p0, xor_graphics=xor_graphics, $
                         color=color, noverbose=noverbose

 if(NOT keyword__set(win_num)) then win_num=!window
 if(NOT keyword__set(color)) then color=!p.color
 xor_graphics = keyword__set(xor_graphics)
 if(NOT keyword_set(sample)) then sample = 1

 if(keyword_set(p)) then outline_pts = tr([tr(p),tr(p[*,0])]) $
 else $
  begin
   ;-----------------------------------
   ; setup pixmap
   ;-----------------------------------
   wset, win_num
   if(xor_graphics) then device, set_graphics=6 $               ; xor mode
   else $
    begin
     window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
     pixmap = !d.window
     device, copy=[0,0, !d.x_size,!d.y_size, 0,0, win_num]
     wset, win_num
    end



   if(NOT keyword__set(noverbose)) then $
     nv_message, 'Drag and release to define length od box', /continue


   ;-----------------------------------
   ; initial point
   ;-----------------------------------
   if(NOT keyword__set(_p0)) then $
    begin
     cursor, px, py, /down
     _p0 = [px, py]
    end


   ;----------------------------------------------------------
   ; select first side of box
   ;----------------------------------------------------------
   pp0 = (convert_coord(double(_p0), /data, /to_device))[0:1,*]
   pp = tvline(p0=pp0, color=color)
   points = (convert_coord(double(pp), /to_data, /device))[0:1,*]
   p0 = points[*,1]

   ;----------------------------------------------------------
   ; select width of box
   ;----------------------------------------------------------
   if(NOT keyword__set(noverbose)) then $
            nv_message, 'Drag and click to define width of box', /continue


   px = p0[0] & py = p0[1]
   point = [px,py]

   xarr = [px,px,px,px,px]
   yarr = [py,py,py,py,py]
   old_qx = px
   old_qy = py

   ;--------------------------
   ; select sector
   ;--------------------------
   nrad = 200 & nlon = 100

   done = 0
   repeat begin
    plots, xarr, yarr, color=color, psym=-3
    cursor, qx, qy, /change
    button=!err

    if(button NE 0) then done = 1 $
    else $
     begin
      if(qx EQ -1) then qx = old_qx
      if(qy EQ -1) then qy = old_qy

      oldxarr = xarr
      oldyarr = yarr

      point = [qx,qy]

      ;--------------------------------------------
      ; make arrays of radius and longitude values
      ; sample at approx every 5 pixels
      ;--------------------------------------------
      v = point - points[*,1]
      point1 = points[*,0] + v

      xarr = [points[0,0], points[0,1], point[0], point1[0], points[0,0]]
      yarr = [points[1,0], points[1,1], point[1], point1[1], points[1,0]]

      ;--------------------------------------------
      ; erase
      ;--------------------------------------------
      if(xor_graphics) then $
        plots, oldxarr, oldyarr, color=color, psym=-3 $
      else device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]

      old_qx = qx
      old_qy = qy

     end
   endrep until(done)

   if(NOT keyword__set(restore)) then plots, xarr, yarr, color=color, psym=-3

   if(xor_graphics) then device, set_graphics=3 $
   else wdelete, pixmap


   outline_pts = tr([tr([xarr[0], yarr[0]]), $
                     tr([xarr[1], yarr[1]]), $
                     tr([xarr[2], yarr[2]]), $
                     tr([xarr[3], yarr[3]]), $
                     tr([xarr[4], yarr[4]])])
  end

 ;-----------------------------------------
 ; package the result
 ;-----------------------------------------
 outline_ptd = pnt_create_descriptors(points = outline_pts, $
                      desc = 'PG_RING_SECTOR_BOX_OBLIQUE')
 cor_set_udata, outline_ptd, 'sample', [sample]

 return, outline_ptd
end
;=====================================================================


pro test
grift, dd=dd, cd=cd, pd=pd, rd=rd

outline_ptd = pg_ring_sector_box_oblique()

pg_draw,outline_ptd, col=ctred(), psym=-3

profile = pg_profile_ring(dd, cd=cd, dkx=rd, $
                                   outline_ptd, dsk_pts=dsk_pts, $
                                   sigma=sigma)
rads = dsk_pts[*,0]
lons = dsk_pts[*,1]

plot, rads, profile
end
