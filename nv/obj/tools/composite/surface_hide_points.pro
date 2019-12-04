;===========================================================================
;+
; NAME:
;	surface_hide_points
;
;
; PURPOSE:
;	Hides points with respect to surface objects.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;	sub = surface_hide_points(bx, v, r)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	Array (nt) of any subclass of BODY descriptors with
;		the expected surface parameters.
;
;	v:	Array (nv,3,nt) giving viewer positions in the BODY frame.
;
;	r:	Array (nv,3,nt) giving points to hide in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	Subscripts of the points in p that are hidden by the object.  
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2016
;	
;-
;===========================================================================
function surface_hide_points, bx, v, r

 if(cor_isa(bx[0], 'GLOBE')) then return, glb_hide_points(bx, v, r) 
 if(cor_isa(bx[0], 'DISK')) then return, dsk_hide_points(bx, v, r) 

 return, -1
end
;===========================================================================
