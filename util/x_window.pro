;===================================================================================
; x_window
;
;  Like window, but uses a draw widget.  This routine was written to work
; around retain problems encountered on some servers.  Graphics windows 
; created with the 'window' command would not refresh, while those opened
; as draw widgets would.
;
;===================================================================================
pro x_window, free=free, xsize=xsize, ysize=ysize, pixmap=pixmap, retain=retain, $
     title=title, base=base
common x_window_block, __wnums, __ids

 if(NOT defined(retain)) then retain = 2

 if(keyword_set(pixmap)) then $
  begin
   window, free=free, xsize=xsize, ysize=ysize, /pixmap
   return
  end

 base = widget_base(xsize=xsize, ysize=ysize, title=title)
 draw = widget_draw(base, xsize=xsize, ysize=ysize, retain=retain)

 widget_control, base, /realize

 if(NOT keyword_set(title)) then $
         widget_control, base, tlb_set_title='idl ' + strtrim(!d.window, 2)
 
 __wnums = append_array(__wnums, !d.window, /def)
 __ids = append_array(__ids, draw, /def)
end
;===================================================================================
