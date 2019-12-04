;============================================================================
; rot_image
;
;  like rot, except preserves entire image
;
;============================================================================
function rot_image, image, angle, indices=indices

 s = size(image)
 smax = fix(sqrt(s[1]^2 + s[2]^2)*1.1)

 canvas = dblarr(smax, smax)
 icanvas = bytarr(smax, smax)

 x0 = smax/2.-s[1]/2. 
 y0 = smax/2.-s[2]/2. 

 canvas[x0:x0+s[1]-1, y0:y0+s[2]-1] = image
 icanvas[x0:x0+s[1]-1, y0:y0+s[2]-1] = 1

 canvas = rot(canvas, angle)
 icanvas = rot(icanvas, angle)

 xt = total(icanvas, 2)
 yt = total(icanvas, 1)

 wx = where(xt GT 0)
 wy = where(yt GT 0)

 result = canvas[min(wx):max(wx), min(wy):max(wy)]
 iresult = icanvas[min(wx):max(wx), min(wy):max(wy)]

 indices = where(icanvas EQ 1)

 return, result
end
;============================================================================
