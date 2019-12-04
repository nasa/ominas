;=============================================================================
;+
; NAME:
;       image_origin
;
;
; PURPOSE:
;	Returns the origin of a map or camera image.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       image_origin(xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:      Camera or map descriptor
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;   INPUT: NONE
;
;   OUTPUT: NONE
;
;
; RETURN: 
;	2-element array giving the origin in the x and y directions.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;-
;=============================================================================
function image_origin, cd

 class = (cor_class(cd))[0]

 case class of 
  'MAP' : return, map_origin(cd)
  'CAMERA' : return, cam_oaxis(cd)
  else :
 endcase


end
;=============================================================================
