;=============================================================================
;++
; NAME:			***incomplete***
;	pg_limb_sector_oblique
;
; PURPOSE:
;	Allows the user to select an image sector along lines of constant
; 	azimuth and altitude above a planet by clicking and dragging.
; 
; CATEGORY:
;       NV/PG
;
; CALLING SEQUENCE:
;     outline_ptd=pg_limb_sector(cd=cd, gbx=gbx, dkd=dkd)
;
;
; ARGUMENTS:
;  INPUT:
;      NONE
;
;  OUTPUT:
;	NONE
;
;
;
; KEYWORDS:
;  INPUT: 
;           cd:     Camera descriptor.
;
;          gbx:     Globe descriptor for the planet whose limb is to be 
;                   scanned.
;
;           gd:     Generic descriptor containnig the above descriptors.
;
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
;       sample:     Sets the grid sampling in pixels.  Default is one.
;
; xor_graphics:     If set, the sector outline is drawn and erased using xor
;                   graphics instead of a pixmap.
;
;
;  OUTPUT:
;         dkd:      Disk desriptor in the skyplane, centered on the planet
;                   with 0 axis along the skyplane projection of the north 
;                   pole.  For use with pg_profile_ring.
;
;         azimuths: Array giving azimuth at each sample.
;
;        altitudes: Array giving altitude at each sample.
;
;    limb_pts_body: Body coordinates of each limb points on planet surface.
;
;
; RETURN: 
;      POINT containing points on the sector outline.  The point
;      spacing is determined by the sample keyword.  The POINT object
;      also contains the disk coordinate for each point, relative to the
;      returned disk descriptor, and the user fields 'nrad' and 'nlon' 
;      giving the number of points in altitude and azimuth.
;
; KNOWN BUGS:
;	The sector flips when it hits zero azimuth rather than retaining a 
;	consistent sense.
;
;
; MODIFICATION HISTORY : 
;	Spitale; 1/2007		original version
;
;-
;=============================================================================



;=============================================================================
; pg_limb_sector_oblique
;
;=============================================================================
function pg_limb_sector_oblique, cd=cd, gbx=_gbx, gd=gd, $
                         lon=lon, sample=sample, $
                         win_num=win_num, $
                         restore=restore, $
                         p0=_p0, p1=p1, width=width, xor_graphics=xor_graphics, $
                         color=color, silent=silent, nodsk=nodsk, $
                         dkd=dkd, altitudes=altitudes, azimuths=azimuths, $
                         limb_pts_body=limb_pts_body, cw=cw

 if(NOT keyword__set(win_num)) then win_num=!window
 if(NOT keyword__set(color)) then color=!color
 xor_graphics = keyword__set(xor_graphics)

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(_gbx)) then _gbx = dat_gd(gd, dd=dd, /gbx)

 if(NOT keyword__set(_gbx)) then nv_message, 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx)
 if(keyword__set(__gbx[0])) then gbx = __gbx $
 else  gbx = _gbx[0,*]

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 if(n_elements(cds) GT 1) then $
           nv_message, 'No more than one camera descriptor may be specified.'

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



 if(NOT keyword__set(silent)) then $
   nv_message, 'Drag and release to define radial extent of limb sector', /con


 ;-----------------------------------
 ; initial point
 ;-----------------------------------
 if(NOT keyword__set(_p0)) then $
  begin
   cursor, px, py, /down
   _p0 = [px, py]
  end


 ;----------------------------------------------------------
 ; select radial extent of sector
 ;----------------------------------------------------------
 pp0 = (convert_coord(double(_p0), /data, /to_device))[0:1,*]
 pp = tvline(p0=pp0, color=color)
 points = (convert_coord(double(pp), /to_data, /device))[0:1,*]
 p0 = points[*,1]

 ;----------------------------------------------------------
 ; select azimuthal extent of sector
 ;----------------------------------------------------------
 if(NOT keyword__set(silent)) then $
   nv_message, 'Drag and click to define azimuthal extent of limb sector', /con



 px = p0[0] & py = p0[1]
 point = [px,py]

 xarr = [px,px,px,px,px]
 yarr = [py,py,py,py,py]
 old_qx = px
 old_qy = py
 ;--------------------------
 ; select sector
 ;--------------------------
 nalt = 5 & naz = 10

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
    outline_pts = get_limb_profile_outline_oblique(cd, gbx, $
                                   nalt=nalt, naz=naz, points, point, dkd=dkd)
    outline_pts = reform(outline_pts)

    xarr = outline_pts[0,*]
    yarr = outline_pts[1,*]

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


stop
 ;--------------------------------------------
 ; resample
 ;--------------------------------------------
 dsk_outline_pts = image_to_disk(cd, dkd, outline_pts)
 rads = dsk_outline_pts[naz+lindgen(nalt),0]
 lons = dsk_outline_pts[lindgen(naz), 1]

 nazrad = get_ring_profile_n(outline_pts, cd, dkd, lons, rads, oversamp=sample)
 nalt = long(nazrad[1]) & naz = long(nazrad[0])

 outline_pts = get_limb_profile_outline_oblique(cd, gbx, $
                                points, point, nalt=nalt, naz=naz)
 if(keyword_set(cw)) then azimuths = 2d*!dpi - azimuths

 ;-------------------------------------------
 ; Return outline points
 ;-------------------------------------------
 dsk_outline_pts = 0
 if(NOT keyword_set(nodsk)) then $
                 dsk_outline_pts = image_to_disk(cd, dkd, outline_pts)

 outline_ptd = pnt_create_descriptors(points = outline_pts, $
                      desc = 'PG_LIMB_SECTOR', $
                      data = transpose(dsk_outline_pts))
 cor_set_udata, outline_ptd, 'nrad', [nalt]
 cor_set_udata, outline_ptd, 'nlon', [naz]

 return, outline_ptd
end
;=====================================================================
