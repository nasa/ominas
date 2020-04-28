;=============================================================================
;+
; NAME:
;       get_image_profile_outline
;
;
; PURPOSE:
;	Generates an outline of an oblique rectangular image region.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       profile = get_image_profile_outline(points, point, nw=nw, nl=nl)
;
;
; ARGUMENTS:
;  INPUT:
;	points:	Array (2,2) of image points defining corners at opposite ends
;		on one side of the sector.
;
;	point:	Image point defining and third corner.
;
;
;  OUTPUT:  NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nl:	Number of samples along the scan.
;
;	nw:	Number of samples across the scan.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;       Array of image points defining the outline of the sector.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function get_image_profile_outline, points, point, nw=nw, nl=nl, sample=sample

 if(NOT keyword_set(point)) then point = points[*,1]

 ;---------------------------------------
 ; perp. distance
 ;---------------------------------------
 dxy = points[*,1] - points[*,0]
 D = p_mag(dxy)

 dpxy = point-points[*,0]
 DP = p_mag(dpxy)

 cos = p_inner(dxy, dpxy) / (D*DP)
 h = DP * sin(acos(cos))

 if(NOT keyword_set(nl)) then $
   if(NOT keyword_set(sample)) then sample = 1.

 if(keyword_set(sample)) then $
  begin
   nl = fix(D*float(sample)) > 1
   nw = fix(h*float(sample)) > 1
  end

 nw = float(nw)
 nl = float(nl)

 MM = make_array(2,val=1d)
 Mnl = make_array(nl,val=1d)
 Mnw = make_array(nw,val=1d)

 ;---------------------------------------
 ; parallel line
 ;---------------------------------------
 v = p_unit([-dxy[1], dxy[0]])
 z =  p_cross(dxy, dpxy)
 if(z[0] LT 0) then v = -v

 vh = v*h

 pp = points + vh # MM

 ;---------------------------------------
 ; fill in lines
 ;---------------------------------------
 pts0 = ((dindgen(nl)##MM/(nl-1)) * (dxy#Mnl)) + (points[*,0]#Mnl)
 pts1 = ((dindgen(nw)##MM/(nw-1)) * ((pp[*,1]-points[*,1])#Mnw)) + (points[*,1]#Mnw)
 pts2 = ((dindgen(nl)##MM/(nl-1)) * (-dxy#Mnl)) + (pp[*,1]#Mnl)
 pts3 = ((dindgen(nw)##MM/(nw-1)) * ((points[*,0]-pp[*,0])#Mnw)) + (pp[*,0]#Mnw)

 if(nw EQ 1) then outline_pts = pts0 $
 else outline_pts = tr([tr(pts0), tr(pts1), tr(pts2), tr(pts3)])

return, outline_pts
end
;=============================================================================
