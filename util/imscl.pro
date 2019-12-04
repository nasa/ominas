;=============================================================================
;+
; imscl
;
; PURPOSE :
;`
;  Scales the values of the given image similarly to tvscl.
;
;'
;
; CALLING SEQUENCE :
;
;  result=imscl(image, min, max)
;
;
; ARGUMENTS
;  INPUT : image - Image to be scaled.
;
;          min, max - New min and max values for image.
;
;  OUTPUT : NONE
;
;
;
; KEYWORDS 
;  INPUT : NONE
;
;  OUTPUT : NONE
;
;
;
; RETURN : Scaled image.
;
;
;
;
; ORIGINAL AUTHOR : J. Spitale ; 8/95
;
; UPDATE HISTORY : 
;
;-
;=============================================================================
function imscl, image, min, max

 newimage=(image<max)>min

 newimage(0,0)=min
 newimage(0,1)=max

 return, newimage
end
;=============================================================================
