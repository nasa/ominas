;==============================================================================
; super_resolution_1d
;
;
;==============================================================================
function super_resolution_1d, scan_ps, factor

 nscans = double(n_elements(scan_ps))

 ;------------------------------------------------
 ; configure output array
 ;------------------------------------------------
 for i=0, nscans-1 do $
  begin
   scan = *scan_ps[i]
   x = scan[0,*]
   y = scan[1,*]
   n = double(n_elements(x))

   xmin = min(x)
   xmax = max(x)

   xmaxs = append_array(xmaxs, xmax)
   xmins = append_array(xmins, xmin)
   scales = append_array(scales, (xmax - xmin)/n)
  end 

 scale = total(scales)/nscans * factor
 xmin = max(xmins)
 xmax = min(xmaxs)

 n = double(fix((xmax - xmin) / scale))

 xout = (dindgen(n)/n * (xmax-xmin)) + xmin
 yy = dblarr(n, nscans)


 ;------------------------------------------------
 ; construct output array
 ;------------------------------------------------
 for i=0, nscans-1 do $
  begin
   scan = *scan_ps[i]
   x = scan[0,*]
   y = scan[1,*]
   yy[*,i] = interpol(y, x, xout)
  end

 yout = total(yy, 2)/nscans

 return, [transpose(xout), transpose(yout)]
end
;==============================================================================
