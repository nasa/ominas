;==============================================================================
; copy_overlays
;
;
;==============================================================================
pro copy_overlays, src_pixmap

stop
 dst_wnum = !d.window
 dst = tvrd()

 wset, src_pixmap
 src = tvrd()

 w = where(src NE 0)

 dst[w] = src[w] 

 wset, dst_wnum
 tv, dst
end
;==============================================================================
