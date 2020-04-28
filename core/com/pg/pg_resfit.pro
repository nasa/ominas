;=============================================================================
;+
; NAME:
;	pg_resfit
;
;
; PURPOSE:
;	Computes polynomial coefficients for a camera distortion model by
;	comparing detected reseaus with the known focal plane locations.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_resfit, scan_ptd, foc_ptd, n, cd=cd
;
;
; ARGUMENTS:
;  INPUT:
;	scan_ptd:	POINT object containing image coordinates of 
;			the scanned reseau candidates as output by pg_resloc.
;
;	foc_ptd:	POINT object containing the known focal
;			coordinates of the reseau marks.
;
;	n:		Order of polynomial to fit.  Default is 4.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;       cd:		Camera descriptor to be modified.
;
;       gd:		Generic descriptor containing the camera descriptor 
;			to be modified.
;
;       range:		Range to use in associating candidate reseaus
;			with known reseaus. default is 10 pixels.
;
;	assoc:		If set, the program returns after generating 
;			the scan_sub array, but before fitting the polynomial
;			coefficients.
;
;	nom_ptd:		If given, this POINT contains image
;			coordinates of nominal reseau locations corresponding 
;			to each point in foc_ptd.  The positions of each mark 
;			for which there is no scan_ptd match is computed 
;			as the nominal position plus an offset determined
;			by looking at the differences between neighboring
;			scanned marks and their corresponding nominal positions.
;
;	use_nom:	If set, scan_ptd will be ignored and nom_ptd will be used
;			instead.
;
;  OUTPUT:
;	res_ptd:	POINT object containing the new image
;			coordinates of the known reseau marks.
;
;	fcp:		POINT returning the focal points from foc_ptd
;			that were able to be associated with a scanned
;			reseau.
;
;	scp:		POINT returning the scanned points from scan_ptd
;			that were able to be associated with a
;			known location.
;
; RETURN:
;	NONE
;
;
; PROCEDURE:
;	First, candidate reseaus are associated with nominal reseaus by 
;	choosing the candidate with the highest correlation coefficient 
;	within a given number of pixels surrounding each known reseau.
;
;	Next, coefficients for a polynomial of order n are derived using a
;	least-squares fit.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_resloc, pg_linearize_image, pg_blemish
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2002
;	
;-
;=============================================================================


;=============================================================================
; associate_marks
;
; Returns array giving best candidate subscript for each nominal.  -1
; for known reseaus with no good candidates.
;
;=============================================================================
function pgrf_associate_marks, scan_pts, foc_pts, cc, range

 nscan = n_elements(scan_pts)/2
 nfoc = n_elements(foc_pts)/2

 ;------------------------------------------------------------
 ; compute distance from each known reseau to each candidate
 ;------------------------------------------------------------
 foc_x = foc_pts[0,*]##make_array(nscan, val=1d)
 foc_y = foc_pts[1,*]##make_array(nscan, val=1d)

 scan_x = reform(scan_pts[0,*], nscan, /over)#make_array(nfoc, val=1d)
 scan_y = reform(scan_pts[1,*], nscan, /over)#make_array(nfoc, val=1d)

 d2 = (foc_x - scan_x)^2 + (foc_y - scan_y)^2


 ;------------------------------------------------------------
 ; find indices of all candidates within range
 ;------------------------------------------------------------
 w = where(d2 LT range^2)
 if(w[0] EQ -1) then return, 0


 ;---------------------------------------------------------------
 ; create array of corresponding correlation coeff's, removing
 ; extraneous zeroes
 ;---------------------------------------------------------------
 ss = (lindgen(nscan)+1)#make_array(nfoc, val=1l)	; the +1 is needed to
 sss = lonarr(nscan, nfoc)				; to avoid sending a 0 
 sss[w] = ss[w]						; index to
							; collapse_array
 sss = collapse_array(sss) - 1 
 nn = (size(sss))[1]

 ccc = cc[sss]
 ccc[where(sss EQ -1)] = 0


 ;------------------------------------------------------------
 ; find max correlation coeff for each known reseau
 ;------------------------------------------------------------
 ccmax = nmax(ccc, 0, sub=sub)

 assc_scan = lonarr(nfoc)
 assc_scan[*] = sss[lindgen(nfoc)*nn + sub]

 return, assc_scan
end
;=============================================================================



;=============================================================================
; pgrf_get_matches
;
;=============================================================================
pro pgrf_get_matches, scan_sub, foc_pts, scan_pts, nom_ptd=nom_ptd, $
                      fp=fp, sp=sp

 ;---------------------------------------
 ; get matching points
 ;---------------------------------------
 w = where(scan_sub NE -1)
 fp = foc_pts[*,w]
 sp = scan_pts[*,scan_sub[w]]

 nn = n_elements(w)


 ;-----------------------------------------------------------------
 ; if nom_ptd given, use nominals to fill in missing points
 ;-----------------------------------------------------------------
 if(NOT keyword__set(nom_ptd)) then return

 ww = where(scan_sub EQ -1)
 if(ww[0] EQ -1) then return

 nom_pts = pnt_points(nom_ptd)

 n = n_elements(nom_pts)/2
 nnn = n - nn

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; determine local offsets and distances to detected nominals
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 _off = sp - nom_pts[*,w]

 dx = tr(nom_pts[0,ww])#make_array(nn,val=1d) - $
                                nom_pts[0,w]##make_array(nnn,val=1d)
 dy = tr(nom_pts[1,ww])#make_array(nn,val=1d) - $
                                nom_pts[1,w]##make_array(nnn,val=1d)

 dr2 = dx^2 + dy^2

 ;- - - - - - - - - - - - - - - - - - -
 ; find closest 4 detected nominals
 ;- - - - - - - - - - - - - - - - - - -
 _dr2 = dr2

 dr2_min1 = nmin(_dr2, 1, sub=sub1)
 xx1 = sub1*nnn + lindgen(nnn)
 _dr2[xx1] = 1d20

 dr2_min2 = nmin(_dr2, 1, sub=sub2)
 xx2 = sub2*nnn + lindgen(nnn)
 _dr2[xx2] = 1d20

 dr2_min3 = nmin(_dr2, 1, sub=sub3)
 xx3 = sub3*nnn + lindgen(nnn)
 _dr2[xx3] = 1d20

 dr2_min4 = nmin(_dr2, 1, sub=sub4)
 xx4 = sub4*nnn + lindgen(nnn)
 _dr2[xx4] = 1d20

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; compute average offsets weighted by distance
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 norm = 1d/dr2[xx1] + 1d/dr2[xx2] + 1d/dr2[xx3] + 1d/dr2[xx4]

 off = dblarr(2,nnn)
 off[0,*] = (_off[0,sub1]/dr2[xx1] + _off[0,sub2]/dr2[xx2] + $
             _off[0,sub3]/dr2[xx3] + _off[0,sub4]/dr2[xx4])/norm
 off[1,*] = (_off[1,sub1]/dr2[xx1] + _off[1,sub2]/dr2[xx2] + $
             _off[1,sub3]/dr2[xx3] + _off[1,sub4]/dr2[xx4])/norm

 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 ; insert nominal locations plus averaged offsets
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 _fp = dblarr(2,n)
 _sp = dblarr(2,n)

 _fp[*,0:nn-1] = fp
 _sp[*,0:nn-1] = sp

 _fp[*,nn:*] = foc_pts[*,ww]
 _sp[*,nn:*] = nom_pts[*,ww] + off

 fp = _fp
 sp = _sp

end
;=============================================================================



;=============================================================================
; pg_resfit
;
;=============================================================================
pro pg_resfit, scan_ptd, foc_ptd, n, cd=cd, gd=gd, range=range, nom_ptd=nom_ptd, $
                   res_ptd=res_ptd, scp=scp, fcp=fcp, assoc=assoc, use_nom=use_nom

 if(NOT keyword__set(range)) then range = 10
 if(NOT keyword__set(n)) then n = 4

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)


 ;------------------------------------------------------------
 ; dereference POINT objects
 ;------------------------------------------------------------
 _foc_pts = pnt_points(foc_ptd)
 scan_pts = pnt_points(scan_ptd)
 cc = pnt_data(scan_ptd)

 nscan = n_elements(scan_pts)/2
 nfoc = n_elements(foc_pts)/2

 cc = reform(cc, nscan, /over)


 ;------------------------------------------------------------
 ; use current camera transformation for initial guess at 
 ; image coords of known reseaus
 ;------------------------------------------------------------
 foc_pts_image = cam_focal_to_image(cd, _foc_pts)


 ;------------------------------------------------------------
 ; associate candidates with known reseaus
 ;------------------------------------------------------------
 if(NOT keyword__set(use_nom)) then $
  begin
   scan_sub = pgrf_associate_marks(scan_pts, foc_pts_image, cc, range)
   if(NOT keyword__set(scan_sub)) then return
  end


 ;------------------------------------------------------------
 ; perform least-squares fit to polynomial coefficients.
 ;------------------------------------------------------------ 

 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 ; extract points for which there is a match
 ;- - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword__set(use_nom)) then $
    pgrf_get_matches, scan_sub, _foc_pts, scan_pts, nom_ptd=nom_ptd, $
                     fp=foc_pts, sp=scan_pts $
 else $
  begin
   foc_pts = _foc_pts
   scan_pts = pnt_points(nom_ptd)
  end

 fcp = pnt_create_descriptors(points=foc_pts)
 scp = pnt_create_descriptors(points=scan_pts)

 if(keyword__set(assoc)) then return

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; find polynomial coeff's for map from focal plane to distorted image plane
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 polywarp, scan_pts[0,*], scan_pts[1,*], $
           foc_pts[0,*], foc_pts[1,*], n-1, XX, YY

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; find polynomial coeff's for inverse map  
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 polywarp, foc_pts[0,*], foc_pts[1,*], $
           scan_pts[0,*], scan_pts[1,*], n-1, PP, QQ

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; update camera descriptor with new distortion matrices
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 cam_set_poly_matrices, cd, transpose(XX), transpose(YY), $
                            transpose(PP), transpose(QQ)

 cam_set_fn_focal_to_image, cd, 'cam_focal_to_image_poly'
 cam_set_fn_image_to_focal, cd, 'cam_image_to_focal_poly'


 ;------------------------------------------------------------
 ; use current new transformation to compute image coords
 ; of reseaus
 ;------------------------------------------------------------
 res_pts = cam_focal_to_image(cd, _foc_pts)
 res_ptd = pnt_create_descriptors(points=res_pts)


end
;=============================================================================
