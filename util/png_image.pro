;==============================================================================
; png_image
;
;
;==============================================================================
pro png_image, filename, wnum=wnum, mono=mono, quantize=quantize, order=order, channel=channel, $
       verbose=verbose

 if(defined(wnum)) then wset, wnum

 if(NOT keyword_set(channel)) then channel = 1

 if(NOT keyword_set(order)) then order = 1 $
 else order = 0

 if(idl_v_chrono(!version.release) GT (idl_v_chrono('5.3'))) then order = 1-order

 if(keyword_set(mono)) then xx = tvrd(ch=channel, order=order) $
 else if(keyword_set(quantize)) then $
  begin
   xx1 = tvrd(ch=1, order=order)
   xx2 = tvrd(ch=2, order=order)
   xx3 = tvrd(ch=3, order=order)
   xx = color_quan(xx1, xx2, xx3, r, g, b)
  end $
 else $
  begin
   xx1 = tvrd(ch=1, order=order)
   xx2 = tvrd(ch=2, order=order)
   xx3 = tvrd(ch=3, order=order)
   dim = size(xx1, /dim)
   xx = bytarr(3,dim[0],dim[1])
   xx[0,*,*] = xx1
   xx[1,*,*] = xx2
   xx[2,*,*] = xx3
  end


 if(keyword_set(verbose)) then print, 'Writing ' + filename
 write_png, filename, xx, r, g, b


end
;==============================================================================
