;=============================================================================
;+
; NAME:
;       pixel_grid
;
;
; PURPOSE:
;	Plots grid lines aligned with the data coordinate system.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       pixel_grid, xsize, ysize
;
;
; ARGUMENTS:
;  INPUT: 
;	xsize:		Number of pixels in x direction.
;
;	ysize:		Number of pixels in y direction.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: 
;	spacing:	Distance in pixels between grid lines.
;
;	np:		Number of points on each grid line.
;
;	wnum:		Window number for determining grid size.  If not set,
;			the current grapics window is used.
;
;	label:		If set, the grid lines are labeled.
;
;	color:		Grid color.
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
pro pixel_grid, xsize, ysize, spacing=spacing, np=np, wnum=wnum, label=label, color=color

 if(keyword_set(wnum)) then wset, wnum

 if(NOT keyword_set(spacing)) then spacing = 100
 if(NOT keyword_set(np)) then np = 150			; # points per grid line

 nx = xsize / spacing + 1
 ny = ysize / spacing +1 

 xx = (dindgen(nx))*spacing
 yy = (dindgen(ny))*spacing

 px = dblarr(2,np*nx)
 px[0,*] = reform(xx ## make_array(np,val=1d), nx*np)
 px[1,*] = reform(dindgen(np)/np * ysize # make_array(nx,val=1d), nx*np)

 py = dblarr(2,np*ny)
 py[0,*] = reform(dindgen(np)/np * xsize # make_array(ny,val=1d), ny*np)
 py[1,*] = reform(yy ## make_array(np,val=1d), ny*np)

 p = dblarr(2,np*(nx+ny))
 p[*,0:nx*np-1] = px
 p[*,nx*np:*] = py

 plots, p, psym=3, color=color
 


 if(keyword_set(label)) then $
  begin
   origin = convert_coord([0,0], /data, /to_device)
   corners = convert_coord(transpose([transpose([0,0]), $
                                      transpose([!d.x_size,!d.y_size]-1)]), /device, /to_data)
   xflip = (yflip = 0)
   if(corners[0,0] GT corners[0,1]) then xflip = 1
   if(corners[1,0] GT corners[1,1]) then yflip = 1

   xxx = dblarr(nx) & xalign=1.0-xflip
   yyy = dblarr(ny) & yalign=1.0-yflip

   if(origin[0] LT 0) then $
    begin
     xxx[*] = corners[0,xflip]
     xalign = xflip
    end
   if(origin[0] GE !d.x_size) then $
    begin
     xxx[*] = corners[0,1-xflip]
     xalign = 1.0-xflip
    end

   if(origin[1] LT 0) then $
    begin
     yyy[*] = corners[1,1-yflip]
     yalign = 1.0-yflip
    end
   if(origin[1] GE !d.y_size) then $
    begin
     yyy[*] = corners[1,yflip]
     yalign = yflip
    end

   xyouts, xx, yyy, strtrim(fix(xx),2), align=yalign, orientation=90
   xyouts, xxx, yy, strtrim(fix(yy),2), align=xalign
   xyouts, 0, 0, '0', align=1.0-xflip
  end


end
;==============================================================================
