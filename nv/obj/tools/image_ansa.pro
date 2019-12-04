;=============================================================================
;+
; NAME:
;       image_ansa
;
;
; PURPOSE:
;	Computes ring ansa true anomalies.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       tas = image_ansa(cd, rd, radius)
;
;
; ARGUMENTS:
;  INPUT:
;	cd:	Camera descriptor.
;
;	dkx:	Any subclass of DISK.
;
;	radius:	Disk radius at which to compute ansa.
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	image_pts:	Image points corresponding to each ansa true anomaly
;			at the given radius.
;
;
; RETURN: 
;	Array (2) of true anomalies
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================


;===================================================================================
; ia_compute
;
;===================================================================================
function ia_compute, cd, rd, radius, ta0, image_pt=image_pt

 ta = ta0

 nta = 100d
 range = !dpi

 prd = inertial_to_image_pos(cd, bod_pos(rd))#make_array(nta, val=1d)

 repeat $
  begin
   tas = (dindgen(nta) - nta/2d)*range/nta + ta

   body_pts = dsk_get_inner_disk_points(rd, ta=tas, disk=disk_pts)
   image_pts = body_to_image_pos(cd, rd, body_pts)

   r = p_mag(prd - image_pts)
   w = where(r EQ max(r))

   image_pt = image_pts[*,w]
   dp = p_mag(image_pt - image_pts[*,w+1])

   ta = disk_pts[w[0],1]
   range = range / (nta/2d)
  endrep until(dp LE 1)


 return, ta
end
;===================================================================================



;===================================================================================
; image_ansa
;
;===================================================================================
function image_ansa, cd, rd, radius, image_pts=image_pts

 tas = image_ansa_far(cd, rd)

 rdr = nv_clone(rd)
 sma = dsk_sma(rdr)
 sma[0] = radius
 dsk_set_sma, rdr, sma

 ta1 = ia_compute(cd, rdr, radius, tas[0], image_pt=image_pt1)
 ta2 = ia_compute(cd, rdr, radius, tas[1], image_pt=image_pt2)

 image_pts = transpose([transpose(image_pt1), transpose(image_pt2)])

 nv_free, rdr

 return, [ta1, ta2]
end
;===================================================================================
