;=============================================================================
;+
; NAME:
;       set_image_size
;
;
; PURPOSE:
;	Sets the size of a map or camera image.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       set_image_size, xd, size
;
;
; ARGUMENTS:
;  INPUT:
;	xd:      Camera or map descriptor
;
;	size: 	 Size argument as in map_set_size
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
;	NONE.
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
pro set_image_size, cd, size

 class = (cor_class(cd))[0]

 case class of 
  'MAP' : map_set_size, cd, size
  'CAMERA' : cam_set_size, cd, size
  default :
 endcase
end
;=============================================================================
