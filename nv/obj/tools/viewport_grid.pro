;=============================================================================
;+
; NAME:
;       viewport_grid
;
;
; PURPOSE:
;	Plots grid lines aligned with the viewport window.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       viewport_grid
;
;
; ARGUMENTS:
;  INPUT: NONE
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
pro viewport_grid, spacing=spacing, np=np, wnum=wnum, color=color, label=label

 if(keyword_set(wnum)) then wset, wnum

 if(NOT keyword__set(spacing)) then spacing = 100	; device spacing
 if(NOT keyword__set(np)) then np = 150			; # points per grid line

 nx = !d.x_size / spacing
 ny = !d.y_size / spacing

 xx = (dindgen(nx)+1)*spacing
 yy = (dindgen(ny)+1)*spacing

 px = dblarr(2,np*nx)
 px[0,*] = reform(xx ## make_array(np,val=1d), nx*np)
 px[1,*] = reform(dindgen(np)/np * !d.y_size # make_array(nx,val=1d), nx*np)

 py = dblarr(2,np*ny)
 py[0,*] = reform(dindgen(np)/np * !d.x_size # make_array(ny,val=1d), ny*np)
 py[1,*] = reform(yy ## make_array(np,val=1d), ny*np)

 p = dblarr(2,np*(nx+ny))
 p[*,0:nx*np-1] = px
 p[*,nx*np:*] = py

 p = (convert_coord(/device, /to_data, double(p[0,*]), double(p[1,*])))[0:1,*]

 plots, p, psym=3, color=color

end
;==============================================================================
