;=============================================================================
;+
; NAME:
;       trim_external_points
;
;
; PURPOSE:
;       Trim external points from an array of image points.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = trim_external_points(points, x0, x1, y0, y1)
;
;
; ARGUMENTS:
;  INPUT:
;       points:         An array of image points.
;
;           x0:         Lower x bound.
;
;           x1:         Upper x bound.
;
;           y0:         Lower y bound.
;
;           y1:         Upper y bound.
;
;  OUTPUT:
;          sub:         Subscripts of the points that are not external
;
; RETURN:
;       An array of points that fall inside the rectangle whose corners
;       are (x0,y0) and (x1,y1).  The external points are trimmed.
;
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
function trim_external_points, points, x0, x1, y0, y1, sub=sub

 xpoints=points[0,*]
 ypoints=points[1,*]

 sub = where(xpoints GE x0 AND xpoints LE x1 AND $
                                              ypoints GE y0 AND ypoints LE y1)
 if(sub[0] EQ -1) then return, 0

 return, points[*,sub]
end
;===========================================================================
