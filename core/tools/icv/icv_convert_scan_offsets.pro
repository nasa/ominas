;=============================================================================
;+
; NAME:
;	icv_convert_scan_offsets
;
;
; PURPOSE:
;	Converts offsets produced by icv_scan_strip to image coordinates.
;
;
; CATEGORY:
;	NV/LIB/TOOLS/ICV
;
;
; CALLING SEQUENCE:
;	result = icv_convert_scan_offsets(curve_pts, scan_offsets, $
;	                                  cos_alpha, sin_alpha)
;
; ARGUMENTS:
;  INPUT:
;	curve_pts:	Array (2, n_points) of image points making up the curve.
;
;	scan_offsets:	Array (n_points) containing offset of best correlation 
;			at each point on the curve.  Produced by icv_scan_strip.
;
;	cos_alpha:	Array (n_points) of direction cosines computed by
;			icv_compute_directions.
;
;	sin_alpha:	Array (n_points) of direction sines computed by
;			icv_compute_directions.
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
function icv_convert_scan_offsets, curve_pts, scan_offsets, $
                                   cos_alpha, sin_alpha

 scan_pts = dblarr(2,n_elements(scan_offsets))

 offsets = double(scan_offsets)

 scan_pts[0,*] = curve_pts[0,*] + transpose(offsets*cos_alpha)
 scan_pts[1,*] = curve_pts[1,*] + transpose(offsets*sin_alpha)

 return, scan_pts
end
;===========================================================================
