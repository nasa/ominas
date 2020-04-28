;=============================================================================
;+
; NAME:
;	pg_ptassoc
;
;
; PURPOSE:
;	Associates points between two arrays by searching for the most
;	frequent offset between the two.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	assoc_scan_ptd = pg_ptassoc(scan_ptd, model_ptd, assoc_model_ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	scan_ptd:	POINT(s) containing first array, typically
;			an array of candidate points detected in an image.
;
;	model_ptd:	POINT(s) containing the second array, typically
;			an array of computed model points.
;
;  OUTPUT: 
;	assoc_model_ptd:	POINT containing the output model points.  
;			Each of these points is associated with a point
;			in the returned array.  If this argument is not
;			present, the model_ptd array is overwritten with
;			the output model points.
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	POINT containing an associated scan point for each output
;	model point in assoc_model_ptd.  
;
;
; PROCEDURE:
;	Points are associated by searching for the most frequent offset
;	between scan points and model points.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_cvscan, pg_cvscan_coeff, pg_ptscan, pg_ptscan_coeff, 
;	pg_cvchisq, pg_ptchisq, pg_threshold
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
function pg_ptassoc, scan_ptd, model_ptd, assoc_model_ptd, radius=radius, $
   dxy=dxy, maxcount=maxcount

 if(NOT keyword__set(maxcount)) then maxcount = 5
 if(NOT keyword__set(radius)) then radius = 5

 ;----------------------------------
 ; dereference points arrays
 ;----------------------------------
 scan_pts = pnt_points(/cat, /vis, scan_ptd)
 nscan = n_elements(scan_pts)/2
 model_pts = pnt_points(/cat, /vis, model_ptd)
 nmodel = n_elements(model_pts)/2
 n = nscan*nmodel

 if(NOT keyword__set(scan_pts)) then return, 0
 if(NOT keyword__set(model_pts)) then return, 0

 if(NOT arg_present(assoc_model_ptd)) then overwrite = 1

 ;-----------------------------------------------
 ; compute offsets between every possible pair
 ;-----------------------------------------------
 dxy = points_dxy(scan_pts, model_pts, $
                               x1=xscan, y1=yscan, x2=xmodel, y2=ymodel)

 ;-------------------------------------------------------------------
 ; find best offset
 ;  If more than one solution, reduce radius and try again until
 ;  either the solution becomes unique or the number of offsets
 ;  in the fullest bin becomes one.
 ;-------------------------------------------------------------------
 done = 0
 count = 0
 repeat $
  begin
   w = correlate_pairs(dxy, radius, mm=mm)
   if(n_elements(w) NE nscan) then w = -1
   if(w[0] EQ -1) then radius = radius / 1.09 $
   else $
    begin
     nw = n_elements(w)
     if(mm EQ 1) then return, 0
     if(nw EQ 1) then return, 0
     done = 1
    end
   count = count + 1
   if(count GT maxcount) then return, ''
  endrep until(done)
; there's a mem. leak in the above block, but I can't find it.



 ddxy =  reform(dxy, 2, n)
 dxy = total(ddxy[*,w],2)/nw

 ;-----------------------------------------------
 ; set up associated points arrays
 ;-----------------------------------------------
 assoc_scan_pts = dblarr(2,nw)
 assoc_model_pts = dblarr(2,nw)

 i = w mod nscan			; scan indices
 j = w / nscan				; model indices

 ii = complement(xscan, i)
 jj = complement(xmodel, j)

 scan_pts = scan_pts[*,i]
 model_pts = model_pts[*,j]

 assoc_scan_ptd = objarr(nw)
 assoc_model_ptd = objarr(nw)

 for k=0, nw-1 do $
  begin
   name = cor_name(model_ptd[j[k]])

   delta = ddxy[*,w[k]]

   scan_data=dblarr(5)
   tags=strarr(5)
   scan_data[0] = delta[0]	 & tags[0] = 'point_dx' 	; dx
   scan_data[1] = delta[1]	 & tags[1] = 'point_dy' 	; dy
   scan_data[2]=0                & tags[2]='Not_applicable'     ; 
   scan_data[3]=0                & tags[3]='Not_applicable'     ; 
   scan_data[4]=0                & tags[4]='Not_applicable'     ; 

   pnt_assign, assoc_scan_ptd[k], $
			points = scan_pts[*,k], $
			name = name, $
			desc = 'ptscan', $
			data = scan_data, $
			tags = tags

   pnt_assign, assoc_model_ptd[k], $
			points = model_pts[*,k], $
			name = name, $
			desc = 'ptassoc-model'
  end

 if(keyword__set(overwrite)) then model_ptd = assoc_model_ptd

 return, assoc_scan_ptd
end
;=============================================================================
