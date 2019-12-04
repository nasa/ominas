;=============================================================================
;+
; NAME:
;       pg_tiepoints
;
;
; PURPOSE:
;       Computes tiepoint image offsets.
;
;
; CATEGORY:
;       NV/PG
;
;
; CALLING SEQUENCE:
;       tie_ptd = pg_tiepoints(cd=cd, bx=bx, body_pts=body_pts, ptd)
;
;
; ARGUMENTS:
;  INPUT:
;   ptd:         POINT containing the image points.
;
; KEYWORDS:
;  INPUT:
;         cd:	Camera descriptor.
;
;         bx:	Body descriptor; can be GLOBE or RING.
;
;        gbx:	Globe descriptor for each globe in image instead of
;		specifying bx.
;
;        dkx:	Disk descriptor for each globe in image instead of
;		specifying bx.
;
;	  gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	  dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;   body_pts:	Array of np column vectors giving the body-frame coordinates 
;		for each tie point.  If not given, then the given geometry
;		is used to compute it.
;
;
;  OUTPUT:
;   body_pts: 	Array of np column vectors giving the body-frame coordinates 
;		for each tie point.  If this keyword is given as an input,
;		then no output is generated.
;
; EXAMPLE:
;  1) Manually select a set of tiepoints in a set of images and fit
;     a pointing offset:
;
;	ndd = n_elements(dd)
;	for i=0, ndd-1 do ptd[i] = pg_select_points(dd[i], /ptd)
;
;	body_pts = 0
;	for i=0, ndd-1 do $
;	 begin &$
;	  tie_ptd = pg_tiepoints(cd=cd[i], bx=pd[i], ptd[i], body_pts=body_pts) &$
;	  tpcoeff = pg_ptscan_coeff(tie_ptd, fix=[2]) &$
;	  dxy = pg_fit(tpcoeff) &$
;	  pg_repoint, dxy, 0d, cd=cd[i] &$
;	 end
;	
;     In the above example, the first image is used as a reference; 
;     because body_pts is initially undefined, those points are computed
;     for the first image, but not subsequently.  Instead, the subsequent
;     images will have a nonzero offset stored in the tie_ptd structure,
;     which are then used by pg_ptscan_coeff to compute fit coefficients.
;
;
; STATUS:
;       Complete
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale, 8/2006
;
;-
;=============================================================================
function pg_tiepoints, cd=cd, bx=bx, gbx=gbx, dkx=dkx, dd=dd, gd=gd, ptd, body_pts=body_pts, dxy=dxy

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)

 if(NOT keyword_set(bx)) then $
  begin
   if(keyword_set(dkx)) then bx = dkx 
   if(keyword_set(gbx)) then bx = gbx 
  end

 ;-----------------------------------------------
 ; get body points if necessary
 ;-----------------------------------------------
 p = pnt_points(ptd, /cat)
 if(NOT keyword_set(body_pts)) then body_pts = image_to_body(cd, bx, p, hit=hit)

 ;-----------------------------------------------
 ; compute offsets
 ;-----------------------------------------------
 im_pts = reform(body_to_image_pos(cd, bx, body_pts))

 dxy = p - im_pts

 np = n_elements(dxy)/2
 tie_ptd = objarr(np)
 for i=0, np-1 do $
  begin
   delta = dxy[*,i]

   scan_data=dblarr(5)
   tags=strarr(5)
   scan_data[0]=delta[0]	 & tags[0]='point_dx' 	 	; dx
   scan_data[1]=delta[1]	 & tags[1]='point_dy' 		; dy
   scan_data[2]=0                & tags[2]='Not_applicable'     ; 
   scan_data[3]=1d		 & tags[3]='scan_cc'            ; correlation


   tie_ptd[i] = pnt_create_descriptors(points=p[*,i], $
                       name=name, $
                       desc='TIEPOINTS', $
                       data=scan_data, $
                       tags=tags, $
                       flags=flags)
  end


 return, tie_ptd
end
;=============================================================================

