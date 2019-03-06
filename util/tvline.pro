;=============================================================================
;+
; NAME:
;	tvline
;
;
; PURPOSE:
;	Returns device coordinates of the beginning and end points of a user-
;	selected line.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	line = tvline()
;
;
; ARGUMENTS:
;  INPUT:
;	win_num:	Window number of IDL graphics window in which to select
;			the line.  Default is current window.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	thick:		Thickness of line.
;
;	restore:	If set, the line is removed from the image at the end.
;
;	p0:		First point of line.  If set, then the routine
;			immediately begins to drag from that point until a
;			button is released.
;
;	grid_function:	Function that will quantize a point onto
; 			a grid.  It should take an orderered
;			pair as its only argument and return an
;			ordered pair.  Default is the identity function.
;
;	linestyle:	Linestyle to use for line, default is 0.
;
;	cancel_button:	Index of mouse button to be used as a cancel
;			button.  Default is no cancel button.
;
;	action_button:	Index of button to use as the action button
;			instead of the left button, 1.
;
;  OUTPUT:
;	cancelled:	1 if the cancel button was pressed, 0 otherwise.
;
;
; RETURN:
;	2D array containing the two selected endpoints of the line as
;	[p,q] where p and q are 2D arrays in device coordinates.
;
;
; PROCEDURE:
;	The line is selected by clicking the 'action button' at the location
;	of the first point and dragging to endpoint and releasing.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	tvdrag, tvpath, tvrec, tvcursor
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/1995
;	
;-
;=============================================================================


;=============================================================================
; tvline_identity
;
;=============================================================================
function tvline_identity, p
 return, p
end
;=============================================================================




;=============================================================================
; tvline
;
;=============================================================================
function tvline, win_num, $
                 thick=thick, color=color, $
                 fn_draw=fn_draw, fn_erase=fn_erase, fn_data=fn_data, $
                 restore=restore, nodraw=nodraw, $
                 p0=p0, grid_function=grid_function, linestyle=linestyle, $
                 cancel_button=cancel_button, cancelled=cancelled, $
                 action_button=action_button, xor_graphics=xor_graphics, $
                 pixmap=_pixmap

 if(NOT keyword_set(color)) then color = !p.color
 if(NOT keyword_set(cancel_button)) then cancel_button=-1
 if(NOT keyword_set(action_button)) then action_button=1
 if(NOT keyword_set(win_num)) then win_num=!window
 if(NOT keyword_set(linestyle)) then linestyle=0
 if(NOT keyword_set(grid_function)) then grid_function='tvline_identity'
 xor_graphics = keyword_set(xor_graphics)
 nodraw = keyword_set(nodraw)
 if(NOT keyword_set(fn_data)) then fn_data = 0

 if(NOT keyword_set(thick)) then thick=0

 wset, win_num
 if(xor_graphics) then device, set_graphics=6 $                ; xor mode
 else if(keyword_set(_pixmap)) then pixmap = _pixmap $
 else $
  begin
   window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
   pixmap = !d.window
   device, copy=[0,0, !d.x_size,!d.y_size, 0,0, win_num]
   wset, win_num
  end

 cancelled=0

 if(NOT keyword_set(p0)) then $
  begin
   repeat begin
    cursor, px, py, /device, /down
    button=!err
    if(button EQ cancel_button) then cancelled=1
   endrep until(button EQ action_button OR cancelled)

   if(cancelled) then return, 0
  end $
 else begin
       px = p0(0)
       py = p0(1)
      end

 p = call_function(grid_function, [px, py])
 px = p(0)
 py = p(1)

 xarr = [px,px]
 yarr = [py,py]
 old_qx = px
 old_qy = py


 released = 0

 repeat begin
  ;--------------------------
  ; draw
  ;--------------------------
  if(NOT nodraw) then plots, xarr, yarr, /device, thick=thick, linestyle=linestyle, color=color
  if(keyword_set(fn_draw)) then $
        call_procedure, fn_draw, fn_data, xarr, yarr, pixmap, win_num

  cursor, qx, qy, /device, /change
  button = !err

  if((qx EQ old_qx) AND (qy EQ old_qy)) then released = 1

  if(button EQ cancel_button) then cancelled=1

  if(qx EQ -1) then qx = old_qx
  if(qy EQ -1) then qy = old_qy

  q = call_function(grid_function, [qx, qy])
  qx = q(0)
  qy = q(1)

  oldxarr = xarr
  oldyarr = yarr
  xarr = [px, qx]
  yarr = [py, qy]

  ;--------------------------
  ; erase
  ;--------------------------
  if(keyword_set(fn_erase)) then $
             call_procedure, fn_erase, fn_data, oldxarr, oldyarr, pixmap, win_num
  if(NOT nodraw) then $
   begin
   if(xor_graphics) then $
     plots, oldxarr, oldyarr, /device, thick=thick, linestyle=linestyle, $
           color=color $
    else device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]
   end

  old_qx = qx
  old_qy = qy

 endrep until ((button EQ 0) OR (released))



 if(NOT nodraw) then $ 
  if(NOT keyword__set(restore)) then $
   begin    
    plots, xarr, yarr, /device, thick=thick, color=color
    if(keyword_set(fn_draw)) then $
          call_procedure, fn_draw, fn_data, xarr, yarr, pixmap, win_num
   end    

 if(xor_graphics) then device, set_graphics=3 $
 else if(NOT keyword_set(_pixmap)) then wdelete, pixmap

 result = [ [px,py],[qx,qy] ]


 return, result
end
;=====================================================================
