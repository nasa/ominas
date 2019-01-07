;=============================================================================
;+
; NAME:
;	tvrec
;
;
; PURPOSE:
;	Returns device coordinates of the upper left and lower right corner 
;	of a user-selected box.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	box = tvrec()
;
;
; ARGUMENTS:
;  INPUT: 
;	win_num:	Window number of IDL graphics window in which to select
;			box, default is current window.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	thick:		Thickness of box outline.
;
;	restore:	If set, the box is not left in the image.
;
;	p0:		First corner of box.  If set, then the routine
;			immediately begins to drag from that point until a
;			button is released.
;
;	grid_function:	Function which will quantize a point onto
;			a grid.  It should take an orderered
;			pair as its only argument and return an
;			ordered pair.  Default is the identity function.
;
;	linestyle:	Linestyle to use for rectangle, default is 0.
;
;	color:		Color to use for rectangle, default is !color.
;
;	aspect:		Aspect ratio (y/x) to maintain when drawing the 
;			dragged zoom box.
;
;	all_corners:	If set, coordinates of all four corners are returned.
;
;	vline:		If set, only one line of the box is drawn: the vertical
;			line touching the start point.
;
;	hline:		If set, only one line of the box is drawn: the horizotal
;			line touching the start point.
;
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	2x2 array containing the two selected corners of the box as:
;	[p,q] where p and q are 2D arrays in device coordinates.
;
;
; PROCEDURE:
;	The box is selected by clicking at the location of the first corner
;	and dragging to opposite corner and releasing.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	tvdrag, tvline, tvpath, tvcursor
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/1994
;
;-
;=============================================================================



;=============================================================================
; tvrec_identity
;
;=============================================================================
function tvrec_identity, p
 return, p
end
;=============================================================================



;=============================================================================
; tvrec_constrain
;
;=============================================================================
pro tvrec_constrain, px, py, qx, qy, aspect

 if(NOT keyword_set(aspect)) then return

 dy = aspect*abs(qx - px)

 qy = fix(py + sign(qy-py)*dy)

end
;=============================================================================



;=============================================================================
; tvrec
;
;=============================================================================
function tvrec, win_num, $
                thick=thick, $
                restore=restore, $
                p0=p0, grid_function=grid_function, $
                linestyle=linestyle, color=color, cursor=cursor, $
                aspect=aspect, xor_graphics=xor_graphics, all_corners=all_corners, $
                vline=vline, hline=hline

 if(NOT keyword_set(win_num)) then win_num=!window
 if(NOT keyword_set(linestyle)) then linestyle=0
 if(NOT keyword_set(color)) then color=!p.color
 if(NOT keyword_set(grid_function)) then grid_function='tvrec_identity'
 xor_graphics = keyword__set(xor_graphics)

 if(NOT keyword_set(thick)) then thick=0

 wset, win_num
 if(xor_graphics) then device, set_graphics=6  $                ; xor mode
 else $
  begin
   window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
   pixmap = !d.window
   device, copy=[0,0, !d.x_size,!d.y_size, 0,0, win_num]
   wset, win_num
  end

 if(NOT keyword_set(p0)) then cursor, px, py, /device, /down $
 else begin
       px = p0[0]
       py = p0[1]
      end

 p = call_function(grid_function, [px, py])
 px = p[0]
 py = p[1]

 xarr = [px,px,px,px,px]
 yarr = [py,py,py,py,py]
 old_qx = px
 old_qy = py


 released = 0
 repeat begin
  plots, xarr, yarr, /device, thick=thick, linestyle=linestyle, color=color
  cursor, qx, qy, /device, /change
  if(keyword_set(button)) then old_button = button
  button = !mouse.button

help, button
;;;  if((qx EQ old_qx) AND (qy EQ old_qy)) then stop
;;;  if((qx EQ old_qx) AND (qy EQ old_qy)) then released = 1
  if(button EQ 0) then released = 1 

  if(qx EQ -1) then qx = old_qx
  if(qy EQ -1) then qy = old_qy

  q = call_function(grid_function, [qx, qy])
  qx = q[0]
  qy = q[1]

  oldxarr = xarr
  oldyarr = yarr
  old_qx = qx
  old_qy = qy
  tvrec_constrain, px, py, qx, qy, aspect

  xarr = [px, qx, qx, px, px]
  yarr = [py, py, qy, qy, py]
  if(keyword_set(vline)) then $
   begin
    xarr = [px, px]
    yarr = [qy, py]
   end $
  else if(keyword_set(hline)) then $
   begin
    xarr = [px, qx]
    yarr = [py, py]
   end

  if(xor_graphics) then $
     plots, oldxarr, oldyarr, /device, thick=thick, linestyle=linestyle, $
	color=color $
  else device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]


 endrep until(released)


 if(NOT keyword_set(restore)) then $
                  plots, xarr, yarr, /device, thick=thick, color=color

 if(xor_graphics) then device, set_graphics=3 $
 else wdelete, pixmap

 if(NOT keyword_set(all_corners)) then result = [ [px,py],[qx,qy] ] $
 else result = [[px,py], [px,qy], [qx,qy], [qx,py], [px,py]]

 return, result
end
;=====================================================================
