;=============================================================================
;+
; NAME:
;	icv_invert_scan_offsets
;
;
; PURPOSE:
;	Uses scan image coordinates to produce scan offsets and angles.  This
;	routine is the reverse of icv_convert_scan_offsets.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	result = icv_invert_scan_offsets(curve_pts, scan_pts, $
;	                                       cos_alpha, sin_alpha)
;
; ARGUMENTS:
;  INPUT:
;	curve_pts:	Array (2, n_points) of image points making up the curve.
;
;	scan_pts:	Array (2, n_points) of image coordinates corresponding to each scan
;			offset.
;
;	cos_alpha:	Array (n_points) of direction cosines.
;
;	sin_alpha:	Array (n_points) of direction sines.
;
;  OUTPUT: NONE
;
;
; KEYWORDS: NONE
;
;
; RETURN:
;	Array (2, n_points) of image coordinates corresponding to each scan
;	offset.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function icv_invert_scan_offsets, curve_pts, scan_pts, cos_alpha, sin_alpha
 n = n_elements(scan_pts)/2

 offsets = dblarr(n)
 cos_alpha = dblarr(n)
 sin_alpha = dblarr(n)

 offsets = p_mag(scan_pts - curve_pts)
 cos_alpha = (transpose(scan_pts[0,*] - curve_pts[0,*]))/offsets
 sin_alpha = (transpose(scan_pts[1,*] - curve_pts[1,*]))/offsets

 return, offsets
end
;===========================================================================
