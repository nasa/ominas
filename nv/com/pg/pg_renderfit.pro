;=============================================================================
;+
; NAME:
;	pg_renderfit
;
;
; PURPOSE:
;	Searches for the offset (dx,dy) that gives the best agreement between
;	two uncorrelated sets of image points.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	dxy = pg_renderfit(dd, cd=cd, ltd=ltd, bx=bx)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	cd: 		Camera descriptor.
;
;	ltd:		Sun descriptor.
;
;	bx:		Array of body descriptors describing objects in the scene.
;
;	show:		If specified, some graphics are displayed illustrating 
;			aspects of the search.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	2-element array giving the fit offset as [dx,dy].
;
;
; PROCEDURE:
;	pg_renderfit finds the offset that gives the best correlation between
;	the given image and a simulated image.
;
;
; STATUS:
;	Some bugs.  One problem is that the current search grid wraps pixels
;	instead of truncating them.  This causes problems for images where
;	a large body is not entirly within the FOV.
;
;
; NOTES:
;	This could be improved by iterating, starting with a broader, more
;	coarsely sampled scene.
;
;
; SEE ALSO:
;	pg_farfit
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2017
;	
;-
;=============================================================================
function pg_renderfit, dd, cd=cd, ltd=ltd, bx=bx, show=show, fov=fov
 
 if(NOT keyword_set(fov)) then fov = 2d

 ;------------------------------------ 
 ; get input image
 ;------------------------------------ 
 im = dat_data(dd)

 ;------------------------------------ 
 ; render scene
 ;------------------------------------ 
 size0 = cam_size(cd)
 size = size0 * fov
 grid_pts = gridgen(size, p0=size0/2, /center, /rectangular)

 dd0 = pg_render(cd=cd, ltd=ltd, bx=bx, show=show, image_ptd=grid_pts)
 im0 = dat_data(dd0)

 ;------------------------------------ 
 ; find offset
 ;------------------------------------
 dxy0 = image_offset(im0, im, dxy=(size-size0)/2)
 dxy = dxy0 + grid_pts[*,0,0]


 return, -dxy
end
;=============================================================================
