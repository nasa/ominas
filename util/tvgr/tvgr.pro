;=============================================================================
;+
; NAME:
;       tvgr
;
;
; PURPOSE:
;       Displays a graph in an IDL window, sets display properties
;       (xrange, yrange, and position) and maintains a data coordinate 
;	system for the window.
;
;
; CATEGORY:
;       UTIL/TVGR
;
;
; CALLING SEQUENCE:
;	tvgr, arg1 <, arg2, arg3>
;
;
; ARGUMENTS:
;  INPUT:
;           arg1:     May be window number, x-array, or y-array.
;
;           arg2:     If arg1 is the x-array then arg2 is the y-array.  If 
;	              arg1 is a window number, then arg2 may be the x-array 
;                     or y-array.
;
;	    arg3:     If arg3 exists, it is taken as the y-array.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;         silent:     If set, supresses output of messages.
;
;            new:     If set, creates a new window.
;
;        inherit:     If set, window will inherit the settings of the
;                     current tvgr window.
;
;          xsize:     Set the x size of the window to this amount.
;
;          ysize:     Set the y size of the window to this amount.
;
;            all:     If set, print all display properties (not implemented)
;
;        default:     If set, use default properties.
;
;         entire:     If set, ranges are set such that the entire 
;                     plot is visible in the current window.
;
;       previous:     If set, restore last-used properties.
;
;        restore:     If set, use saved properties.
;
;             dx:     Change the xrange by this amount.
;
;             dy:     Change the yrange by this amount.
;
;           save:     Save the current properties.
;
;           flip:     If set, reverse display order.
;
;          erase:     If set, erase the display window before displaying image.
;
;         noplot:     If set, do all the calculations but do not display the
;                     image.
;
;         pixmap:     If set and if this is a new window, the window will 
;                     be a pixmap.
;
;           list:     If set, the "wnum" keyword will return a list
;                     valid tvgr window numbers.
;
;        no_wset:     If set, the window number is not changed.
;
;       no_coord:     If set, the coordinate system is not changed.
;
;         nodraw:     If set, no plot is drawn.
;
;         xrange:     See PLOT.
;
;         yrange:     See PLOT.
;
;         xtitle:     See PLOT. 
;
;         ytitle:     See PLOT. 
;
;          title:     See PLOT. 
;
;          thick:     See PLOT. 
;
;          color:     See PLOT. 
;
;           psym:     See PLOT. 
;
;        symsize:     See PLOT. 
;
;        ticklen:     See PLOT. 
;
;       position:     See PLOT. 
;
;           nsum:     See OPLOT.
;
;
;  OUTPUT:
;       wnum:		Window number of current tvgr instance.
;
;	get_info:	Returns the tvgr data structure for the current
;			window, see tvgr_data__define below.
;
;
; COMMON BLOCKS:
;      tvgr_block:     tvd, tvgr_top
;
;
; SEE ALSO:
;       tvim
;
; MODIFICATION HISTORY:
;       Written by:     Spitale		5/2003
;
;-
;=============================================================================
;===========================================================================
; tvgr_data__define
;
;
;===========================================================================
pro tvgr_data__define

 s={tvgr_data, $
		wnum:		0, $
		xrange:		dblarr(2), $
		yrange:		dblarr(2), $
		position:	dblarr(4), $
		xrange_save:	dblarr(2), $
		yrange_save:	dblarr(2), $
		position_save:	dblarr(4), $
		xrange_prev:	dblarr(2), $
		yrange_prev:	dblarr(2), $
		position_prev:	dblarr(4), $
		prev:		byte(0) $
	}


end
;===========================================================================


;=============================================================================
; NAME:
;       tvgr_get_index
;
;
; PURPOSE:
;       Returns index into the tvd structure for the specified window.
;       Will also add to the tvd structure if /create specified.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       result = tvgr_get_index(wnum, create=create)
;
; ARGUMENTS:
;  INPUT:
;           wnum:     IDL window number
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;         create:     If set, will create a new display window
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Index of tvd structure for given window number.
;
; COMMON BLOCKS:
;      tvgr_block:     tvd, tvgr_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;=============================================================================
function tvgr_get_index, wnum, create=create
common tvgr_block, tvd, tvgr_top

 i=(where(tvd.wnum EQ wnum))[0]
 if(i EQ -1) then $ 
  if(keyword__set(create)) then $
   begin
    tvd=[tvd,{tvgr_data}]
    i=n_elements(tvd)-1
    tvd[i].wnum=wnum
   end

 return, i
end
;===========================================================================



;=============================================================================
; NAME:
;       tvgr_set
;
;
; PURPOSE:
;       Sets various display parameters.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvgr_set, current=current, $
;                 zoom=zoom, $
;                 order=order, $
;                 offset=offset
;
; ARGUMENTS:
;  INPUT:
;           zoom:     zoom factor
;
;         offset:     x and y pixel offset of corner
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;        current:     Use current saved values for parameters
;
;          order:     If set, y direction displays from top down
;
;  OUTPUT:
;       NONE
;
;
; COMMON BLOCKS:
;      tvgr_block:     tvd, tvgr_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;=============================================================================
pro tvgr_set, current=current, ticklen=ticklen, $
	xrange=_xrange, yrange=_yrange, position=_position, $
	xtitle=xtitle, ytitle=ytitle, title=title, nodraw=nodraw
common tvgr_block, tvd, tvgr_top

 if(keyword_set(_xrange)) then xrange = double(_xrange)
 if(keyword_set(_yrange)) then yrange = double(_yrange)
 if(keyword_set(_position)) then position = double(_position)
 if(NOT keyword_set(ticklen)) then ticklen = -0.02

 i = tvgr_get_index(!d.window, /create)

 set_previous=1

 if(keyword_set(current)) then $
  begin
   set_previous = 0
   xrange = tvd[i].xrange
   yrange = tvd[i].yrange
   position = tvd[i].position
  end


 ;-------------------------
 ; set window params
 ;-------------------------
 st = 1
 if(keyword_set(nodraw)) then st = 4

 plot, /data, /nodata, /noerase, [0], $
        xrange=xrange, yrange=yrange, position=position, xstyle=st, ystyle=st, $
        xtitle=xtitle, ytitle=ytitle, title=title, xticklen=ticklen, yticklen=ticklen


 ;-------------------------
 ; save window params
 ;-------------------------
 tvd[i].wnum=!d.window

 if( (position[0] EQ tvd[i].position[0]) $
      AND (position[1] EQ tvd[i].position[1]) $
      AND (position[2] EQ tvd[i].position[2]) $
      AND (position[3] EQ tvd[i].position[3]) $
      AND (xrange[0] EQ tvd[i].xrange[0]) $
      AND (xrange[1] EQ tvd[i].xrange[1]) $
      AND (yrange[1] EQ tvd[i].yrange[1]) $
      AND (yrange[1] EQ tvd[i].yrange[1]) ) then set_previous = 0

 if(set_previous) then $
  begin
   tvd[i].xrange_prev = tvd[i].xrange
   tvd[i].yrange_prev = tvd[i].yrange
   tvd[i].position_prev = tvd[i].position
   tvd[i].prev = 1
  end

 tvd[i].xrange = xrange
 tvd[i].yrange = yrange
 tvd[i].position = position


end
;===========================================================================


;=============================================================================
; NAME:
;       tvgr_set_num
;
;
; PURPOSE:
;       Sets the IDL window number for the current display.
;
;
; CATEGORY:
;       UTIL/TVIM
;
;
; CALLING SEQUENCE:
;       tvgr_set_num, wnum
;
; ARGUMENTS:
;  INPUT:
;           wnum:     IDL window number
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;       NONE
;
;  OUTPUT:
;       NONE
;
;
; COMMON BLOCKS:
;      tvgr_block:     tvd, tvgr_top
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale		
;
;=============================================================================
pro tvgr_set_num, wnum, no_wset=no_wset, no_coord=no_coord, nodraw=nodraw
common tvgr_block, tvd, tvgr_top

 if(NOT keyword__set(no_wset)) then wset, wnum

 i=tvgr_get_index(wnum)
 if(i NE -1) then if(NOT keyword__set(no_coord)) then tvgr_set, /current, nodraw=nodraw

end
;===========================================================================



;===========================================================================
; tvgr
;
;===========================================================================
pro tvgr, arg1, arg2, arg3, $
	silent=silent, new=new, inherit=inherit, xsize=wxsize, ysize=wysize, $
	all=all, default=default, previous=previous, restore=restore, $
	entire=entire, save=save, flip=flip, $
	xrange=_xrange, yrange=_yrange, position=_position, $
	get_info=get_info, $
	erase=erase, noplot=noplot, no_wset=no_wset, no_coord=no_coord, $
	wnum=_wnum, list, pixmap=pixmap, dx=dx, dy=dy, $
	xtitle=xtitle, ytitle=ytitle, title=title, thick=thick, nsum=nsum, $
        color=color, psym=psym, nodraw=nodraw, ticklen=ticklen, symsize=symsize
common tvgr_block, tvd, tvgr_top


 if(keyword_set(list) AND keyword__set(tvd)) then $
  begin
   _wnum = tvd.wnum
   w = where(_wnum GT 0)
   if(w[0] NE -1) then _wnum = _wnum[w]
   return
  end


 if(NOT keyword__set(tvd)) then tvd={tvgr_data}
; on_error, 1
 
; tvgr_set_num, !d.window, no_wset=no_wset, no_coord=no_coord

 if(keyword_set(top)) then tvgr_top = top


 ;===============================================================
 ; wnum is the scalar arg1
 ; yarr is 1-d arg1 or 1-d arg2 if xarr given as 1-d arg1
 ;===============================================================
 if(n_elements(arg1) NE 0) then $
  begin
   s = size(arg1)
   if(s[0] EQ 0) then wnum = arg1 $
   else yarr = arg1
  end

 if(n_elements(arg2) NE 0) then $
  begin
   yarr = arg2
   if(n_elements(wnum) EQ 0) then xarr = arg1
  end

 if(n_elements(arg3) NE 0) then $
  begin
   xarr = arg2
   yarr = arg3
  end



 ;========================================
 ; if wnum is given, then set the window
 ;========================================
 if(n_elements(wnum) NE 0) then $
          tvgr_set_num, wnum, no_wset=no_wset, no_coord=no_coord, nodraw=nodraw


 ;================================================================
 ; if /save, then just save the current params and return
 ;================================================================
 if(keyword__set(save)) then $
  begin
   i = tvgr_get_index(!d.window, /create)
   tvd[i].xrange_save = tvd[i].xrange
   tvd[i].yrange_save = tvd[i].yrange
   tvd[i].position_save = tvd[i].position
   return
  end

 ;======================
 ; interpret keywords
 ;======================
 window_exists=0
 if(!d.window NE -1 AND NOT keyword__set(new)) then window_exists=1

 all = keyword__set(all)
 inherit = keyword__set(inherit)
 default = keyword__set(default)
 entire = keyword__set(entire)
 previous = keyword__set(previous)
 restore = keyword__set(restore)
 flip = keyword__set(flip)
 coord_sys = 0

 override_size = 0
 if(keyword__set(wxsize) AND keyword__set(wysize)) then override_size=1


 ;============================================================
 ; if this is a new window or if /default, then use defaults 
 ;============================================================
 if((default OR NOT window_exists) AND NOT inherit) then $
  begin
   xrange = [min(xarr), max(xarr)]
   yrange = [min(yarr), max(yarr)]
   position = [0.1,0.1,0.95,0.95]
   new = 1
  end $
 ;======================================================================
 ; otherwise, get window parameters according to /previous, /restore, 
 ; /inherit, and /entire
 ;======================================================================
 else $
  begin
   i = tvgr_get_index(!d.window, /create)
   if(previous AND tvd[i].prev) then $
    begin
     if(NOT keyword__set(tvd[i].xrange_prev)) then return
     xrange = tvd[i].xrange_prev
     yrange = tvd[i].yrange_prev
     position = tvd[i].position_prev
    end $
   else if(restore AND keyword__set(tvd[i].xrange_save)) then $
    begin
     xrange = tvd[i].xrange_save
     yrange = tvd[i].yrange_save
     position = tvd[i].position_save
    end $
   else $
    begin
     xrange = tvd[i].xrange
     yrange = tvd[i].yrange
     position = tvd[i].position
    end

   if(entire) then $
    begin
     xrange = [min(xarr), max(xarr)]
     yrange = [min(yarr), max(yarr)]
     position = [0,0,1.,1.]
    end
  end


 ;==========================
 ; override parameters
 ;==========================
 if(keyword_set(_xrange)) then xrange = _xrange
 if(keyword_set(_yrange)) then yrange = _yrange
 if(keyword_set(_position)) then position = _position
 if(keyword_set(dx)) then xrange = xrange + dx[0]
 if(keyword_set(dy)) then yrange = yrange + dy[0]
 if(flip) then yrange = rotate(yrange, 2)


 ;=================================================================
 ; create window if size is overridden and there isn't already one
 ;=================================================================
 if(override_size AND NOT window_exists) then $
  if(NOT keyword_set(no_wset)) then $
   begin
    window, /free, xsize=wxsize, ysize=wysize, pixmap=pixmap
    window_exists=1
   end


 ;============================================================================
 ; if no args are given, then print the current wnum unless /silent
 ;============================================================================
 if(NOT keyword__set(image) AND NOT keyword__set(wnum)) then $
  if(NOT keyword__set(silent)) then $
   begin
    if(NOT all) then print, !d.window $
    else print, tvd.wnum

;    if(NOT all) then wnum=!d.window $
;    else print, wnum=tvd.wnum

;    print, 'wnum   = '+strtrim(wnum,2)
;    print, 'xrange = '+strtrim(tvd.xrange[0],2)+','+strtrim(tvd.xrange[1],2)
;    print, 'yrange = '+strtrim(tvd.yrange[0],2)+','+strtrim(tvd.yrange[1],2)
   end
 _wnum = !d.window


 ;============================
 ; make tvgr_info accessible
 ;============================
 i = tvgr_get_index(!d.window, /create)
 if(i NE -1) then get_info = tvd[i]


 if(keyword_set(erase)) then erase

 ;=========================================================================
 ; establish coordinate system  - do it first if a window exists
 ;=========================================================================
 if(window_exists) then $
  begin
   if(NOT keyword_set(no_coord)) then $
               tvgr_set, xrange=xrange, yrange=yrange, position=position, $
                         xtitle=xtitle, ytitle=ytitle, title=title, nodraw=nodraw, $
                         ticklen=ticklen
   coord_sys=1
  end


 ;======================================
 ; go no further if no array given
 ;======================================
 if(NOT keyword_set(yarr)) then return


 ;-------------------------------------------------------------------
 ; If necessary, bin arrays to correct for an early IDL bug where
 ; "plot" can't handle abscissa points spaced closer than floating-
 ; point precision.
 ;-------------------------------------------------------------------
 if(idl_v_chrono(!version.release) LE idl_v_chrono('5.3')) then $
  begin
   float_bin, xarr, yarr, bin=bin
   if(keyword_set(bin)) then $
    if(NOT keyword_set(silent)) then $
     message, /warning, 'binning data by a factor of ' + strtrim(bin,2) + ' to correct IDL plot bug.'
  end


 ;=========================================
 ; create window if it still doesn't exist
 ;=========================================
 if(NOT window_exists) then $
  if(NOT keyword_set(no_wset)) then $
   begin
    window, /free, xsize=400, ysize=400, pixmap=pixmap
    window_exists=1
   end


 ;=====================================================
 ; establish coordinate system if still necessary
 ;=====================================================
 if((NOT coord_sys) AND (NOT keyword_set(no_coord))) then $
               tvgr_set, xrange=xrange, yrange=yrange, position=position, $
                         xtitle=xtitle, ytitle=ytitle, title=title, nodraw=nodraw, $
                         ticklen=ticklen


 ;==========================
 ; plot array
 ;==========================
 if(keyword_set(nodraw)) then return

 ;- - - - - - - - - - - - - - - - -
 ; trim array to viewed range
 ;- - - - - - - - - - - - - - - - -
 plot = 1

 if(keyword_set(xrange)) then $
  begin
   w = where((xarr GE min(xrange)) AND (xarr LE max(xrange)))
   if(w[0] EQ -1) then plot = 0 $
   else $
    begin
     xarr = xarr[w]
     yarr = yarr[w]
    end
  end


 ;- - - - - - - - - - - - - - - - -
 ; plot
 ;- - - - - - - - - - - - - - - - -
 if(plot) then $
    oplot, xarr, yarr, thick=thick, nsum=nsum, color=color, psym=psym, symsize=symsize


end
;===========================================================================
