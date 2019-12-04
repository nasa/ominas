;=============================================================================
;+
; NAME:
;       image_size
;
;
; PURPOSE:
;	Returns the size of a map or camera image.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       image_size(xd)
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
;	2-element array giving the size in the x and y directions.
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
function image_size, cd

 class = (cor_class(cd))[0]

 case class of 
  'MAP' : return, map_size(cd)
  'CAMERA' : return, cam_size(cd)
  else :
 endcase


end
;=============================================================================
