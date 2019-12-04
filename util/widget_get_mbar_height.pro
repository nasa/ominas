;==================================================================================
; widget_get_mbar_height
;
;==================================================================================
function widget_get_mbar_height
common widget_get_mbar_height_block, height

 if(NOT keyword_set(height)) then $
  begin
   xsize = 100
   ysize = 50

   base = widget_base(mbar=mbar, /col, /tlb_size_events, ysize=ysize, xsize=xsize)
   menu = widget_button(mbar, val='Calibrating...')
   widget_control, base, /realize
   widget_control, base, tlb_get_size=size
   widget_control, base, /destroy

   base = widget_base(/col, /tlb_size_events, ysize=50, xsize=100)
   widget_control, base, /realize
   widget_control, base, tlb_get_size=size0
   widget_control, base, /destroy

   height = size[1] - size0[1]
  end

 return, height
end
;==================================================================================
