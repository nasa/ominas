;=============================================================================
;+
; NAME:
;       cas_mx_wac_to_nac
;
;
; PURPOSE:
;	Computes a matrix that rotates between cassini WAC and NAC orientations.
;
;
; CATEGORY:
;       UTIL/CASSINI
;
;
; CALLING SEQUENCE:
;       result = cas_mx_wac_to_nac()
;
;
; ARGUMENTS: NONE
;
; KEYWORDS: NONE
;
;
; RETURN:
;        Transformation matrix.
;
;
; STATUS:
;       Incomplete
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale 8/2002 
;                       
;-
;=============================================================================
function cas_mx_wac_to_nac

 scale = cas_nac_scale()

 hx = (580.3d - 511.5)*scale		; these numbers from cas_wac_to_nac.pro
 hy = -(404.2d - 511.5)*scale

 Rx = [ [cos(hx), -sin(hx), 0d], $
        [sin(hx),  cos(hx), 0d], $
        [0d,       0d,      1d] ]

 Ry = [ [1d, 0d,       0d], $
        [0d, cos(hy), -sin(hy)], $
        [0d, sin(hy),  cos(hy)] ]

 return, Rx#Ry
end
;=============================================================================
