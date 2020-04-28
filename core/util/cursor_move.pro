;=============================================================================
;+
; NAME:
;       cursor_move
;
;
; PURPOSE:
;       Moves an array of points by using the cursor and then to output
;       the change from the original position when finished.  In moving
;       the cursor, the mouse buttons control the motion:  LEFT to translate,
;       MIDDLE to rotate, RIGHT to accept.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       cursor_move, cx, cy, xpoints, ypoints, sub_xpoints, sub_ypoints, $
;                        dx=dx, dy=dy, dtheta=dtheta
;
;
; ARGUMENTS:
;  INPUT:
;            cx:        x position of center of rotation.
;
;            cy:        y position of center of rotation.
;
;       xpoints:        x positions of array of points to display
;
;       ypoints:         y positions of  rray of points to display
;
;   sub_xpoints:        Sub-sampled x points to display.
;
;   sub_ypoints:        Sub-sampled y points to display.
;
;  KEYWORDS:
;
;      symbol:          symbol to use for marking points, default is period
;
;      star_sub:	If given, these subscripts (into the sub-sampled arrays)
;			determine points that should be plotted using
;			star_symbol.
;
;  OUTPUT:
;            dx:        Change in x in pixels.
;
;            dy:        Change in y in pixels.
;
;        dtheta:        Change in rotation angle in radians.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================



;=============================================================================
; cm_plots
;
;=============================================================================
pro cm_plots, xpoints, ypoints, star_sub, color=color, $
              curve_sym=curve_sym, star_sym=star_sym, data=data, psize=psize, $
              fn_data=fn_data

 ;------------------------------------------
 ; sort points
 ;------------------------------------------
 if(keyword_set(star_sub)) then $
  begin
   curve_sub = complement(xpoints, star_sub)
   if(curve_sub[0] NE -1) then $
    begin
     curve_xpoints = xpoints[curve_sub]
     curve_ypoints = ypoints[curve_sub]
    end
   star_xpoints = xpoints[star_sub]
   star_ypoints = ypoints[star_sub]
  end $
 else $
  begin
   curve_xpoints = xpoints
   curve_ypoints = ypoints
  end


 ;------------------------------------------
 ; plot points
 ;------------------------------------------
 if(keyword_set(curve_xpoints)) then $
     plots, curve_xpoints, curve_ypoints, psym=curve_sym, data=data, color=color
 if(keyword_set(star_xpoints)) then $
      plots, star_xpoints, star_ypoints, psym=star_sym, $
                                      symsize=psize, data=data, color=color

end
;=============================================================================



;=============================================================================
; cursor_move
;
;=============================================================================
pro cursor_move, cx, cy, wnum=wnum, $
   xpoints, ypoints, sub_xpoints, sub_ypoints, $
   dx=dx, dy=dy, dtheta=dtheta, symbol=symbol, color=color, $
   star_symbol=star_symbol, star_sub=star_sub, xor_graphics=xor_graphics, $
   psize=psize, draw=draw, fn=fn, data=fn_data

 if(NOT keyword_set(fn)) then fn = 'cm_plots'
 if(NOT keyword_set(wnum)) then wnum=!window
 xor_graphics = keyword_set(xor_graphics)

 if(NOT keyword_set(psize)) then psize = 1.5

 n_points=n_elements(xpoints)
 rotated=0
 translated=0

 if keyword_set(symbol) then begin
   curve_sym = symbol
 endif else begin
   curve_sym = 3
 endelse

 if keyword_set(star_symbol) then begin
   star_sym = star_symbol
 endif else begin
   star_sym = 4
 endelse


 ;---------------------------
 ; set drawing mode
 ;---------------------------
 wset, wnum
 if(xor_graphics) then device, set_graphics=6  $                ; xor mode
 else $
  begin
   window, /free, /pixmap, xsize=!d.x_size, ysize=!d.y_size
   pixmap = !d.window
   device, copy=[0,0, !d.x_size,!d.y_size, 0,0, wnum]
   wset, wnum
  end
; device, get_graphics=old_graphics
; device, set_graphics=6

 ;---------------------------
 ; save initial state
 ;---------------------------
 new_xpoints = sub_xpoints
 new_ypoints = sub_ypoints

 RR = (xpoints-cx)^2 + (ypoints-cy)^2
 ii = where(RR EQ max(RR))
 xp0 = xpoints[ii]
 yp0 = ypoints[ii]
 cx0 = cx
 cy0 = cy

 ;---------------------------
 ; move points
 ;---------------------------
 done=0
 while(NOT done) do $
  begin
   ;-------------------------------------------------------------------------
   ; wait for button press - 
   ;       left to translate, middle to rotate, right to accept
   ;-------------------------------------------------------------------------
   call_procedure, fn, xpoints, ypoints, star_sub, fn_data=fn_data, $
               curve_sym=curve_sym, star_sym=star_sym, color=color, psize=psize
   kb_cursor, x, y, /down, /data, draw=draw
   if(!mouse.button EQ 4) then done=1 $
   ;=================
   ; rotate
   ;=================
   else if(!mouse.button EQ 2) then $
    begin
     rotated = 1

     mx = convert_coord(double(!mouse.x), double(!mouse.y), /device, /to_data)

     call_procedure, fn, xpoints, ypoints, star_sub, fn_data=fn_data, $
        curve_sym=curve_sym, star_sym=star_sym, /data, color=color, psize=psize
     call_procedure, fn, new_xpoints, new_ypoints, star_sub, fn_data=fn_data, $
            curve_sym=curve_sym, star_sym=star_sym, /data, color=color, psize=psize

     if(mx[1] EQ cy AND mx[0] EQ cx) then theta0 = 0 $
     else theta0 = atan(mx[1]-cy, mx[0]-cx)

     dxpoints = xpoints-cx
     dypoints = ypoints-cy
     sub_dxpoints = sub_xpoints-cx
     sub_dypoints = sub_ypoints-cy

     ;-----------------------------------
     ; drag until button is released
     ;-----------------------------------
     released = 0
     while((!mouse.button EQ 2) AND (NOT released)) do $
      begin
       cursor, x, y, /change, /data
       if(!mouse.button EQ 2) then $
        begin
         mx=convert_coord(double(!mouse.x), double(!mouse.y), /device, /to_data)

         if(keyword_set(x1)) then $ 
           if((mx[0] EQ x1) AND (mx[1] EQ y1)) then released = 1
         x1 = mx[0] & y1 = mx[1]

         if(mx[1] EQ cy AND mx[0] EQ cx) then theta=0 $
         else theta = atan(mx[1]-cy, mx[0]-cx)

         sin_dtheta = sin(theta0-theta)
         cos_dtheta = cos(theta0-theta)

         if(xor_graphics) then $
            call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
                  curve_sym=curve_sym, star_sym=star_sym, color=color, /data, fn_data=fn_data $
         else device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]
         new_xpoints = sub_dxpoints*cos_dtheta+sub_dypoints*sin_dtheta + cx
         new_ypoints = -sub_dxpoints*sin_dtheta+sub_dypoints*cos_dtheta + cy
         call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data
        end
      end
     call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, color=color, fn_data=fn_data

     ;-----------------------------------
     ; rotate points
     ;-----------------------------------
     xpoints = dxpoints*cos_dtheta+dypoints*sin_dtheta + cx
     ypoints = -dxpoints*sin_dtheta+dypoints*cos_dtheta + cy
     sub_xpoints = sub_dxpoints*cos_dtheta+sub_dypoints*sin_dtheta + cx
     sub_ypoints = -sub_dxpoints*sin_dtheta+sub_dypoints*cos_dtheta + cy

    end $
   ;=================
   ; translate
   ;=================
   else $
    begin
     translated = 1

     call_procedure, fn, xpoints, ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data
     call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data

     mx=convert_coord(double(!mouse.x), double(!mouse.y), /device, /to_data)

     x0=mx[0]
     y0=mx[1]

     ;-----------------------------------
     ; drag until button is released
     ;-----------------------------------
     released = 0
     while((!mouse.button EQ 1) AND (NOT released)) do $
      begin
       cursor, x, y, /change, /data
       if(!mouse.button EQ 1) then $
        begin
         mx = convert_coord(double(!mouse.x), double(!mouse.y), /device, /to_data)
         if(keyword_set(x1)) then $ 
           if((mx[0] EQ x1) AND (mx[1] EQ y1)) then released = 1

         if(xor_graphics) then $
            call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
                  curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data $
         else device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]

         new_xpoints = sub_xpoints+mx[0]-x0
         new_ypoints = sub_ypoints+mx[1]-y0

         call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data
         x1 = mx[0]
         y1 = mx[1]
        end
      end
     call_procedure, fn, new_xpoints, new_ypoints, star_sub, psize=psize, $
               curve_sym=curve_sym, star_sym=star_sym, /data, color=color, fn_data=fn_data

     ;-----------------------------------
     ; translate points
     ;-----------------------------------
     xpoints=xpoints+x1-x0
     ypoints=ypoints+y1-y0
     sub_xpoints=sub_xpoints+x1-x0
     sub_ypoints=sub_ypoints+y1-y0
     cx=cx+x1-x0
     cy=cy+y1-y0

    end
  end

 ;---------------------------
 ; compute total offsets
 ;---------------------------
 dx=(dy=(dtheta=0))
 if(translated) then $
  begin
   dx=cx-cx0
   dy=cy-cy0
  end
 if(rotated) then $
          dtheta=atan(ypoints[ii]-cy, xpoints[ii]-cx) - atan(yp0-cy0, xp0-cx0) 

 ;---------------------------
 ; restore drawing mode
 ;---------------------------
; device, set_graphics=old_graphics
 if(xor_graphics) then device, set_graphics=3 $
 else wdelete, pixmap


end
;===========================================================================
