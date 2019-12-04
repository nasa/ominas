;=============================================================================
; ellipse
;
;
;=============================================================================
function ellipse, center, a, b, alpha, np=np

 a2 = double(a)^2
 b2 = double(b)^2
 alpha = double(alpha)
 if(NOT keyword_set(np)) then np = 1000.
 
 theta = (dindgen(np) / np * 2d*!dpi)

 r2 = a2*b2/(a2*sin(theta)^2 + b2*cos(theta)^2)
 r = sqrt(r2)

 x = r*cos(theta - alpha)
 y = r*sin(theta - alpha)

 return, [transpose(x), transpose(y)] + center #make_array(np, val=1d)
end
;=============================================================================
