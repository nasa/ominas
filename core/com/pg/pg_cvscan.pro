;=============================================================================
;+
; NAME:
;	pg_cvscan
;
;
; PURPOSE:
;	Attempts to find points of highest correlation with a given model along
;	curves in an image.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	scan_ptd = pg_cvscan(dd, curve_ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor
;
;	cd:		Camera descriptor.  not required, but some
;			interpolation schemes will not work without it.
;
;	bx:		Descriptor specifying the body associated with
;			each POINT object.  Not required, but some algorithms
;			will not work properly without it.
;
;	gd:		Generic descriptor.
;
;	curve_ptd:	Array (n_curves) of POINT objects giving the curves.
;			Only the image coordinates of the curves need to be
;			specified in the POINT object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	model_p:	Array (n_curves) of pointers to model arrays.  Each
;			model array has dimensions (n_points,nm), where n_points
;			is the number of points in the curve and nm is the 
;			number of points in the model.  Thus, a model may be
;			specified for each point on the curve.  Default
;			model is edge_model_atan().
;
;	mzero:		Array (n_curves) or (n_curves,n_points) of zero-point
;			offsets for each model in model_p.  mzero must be
;			specified if model_p is given.
;
;	width:		Number of pixels to scan on either side of the curve.
;			Default is 20.
;
;	edge:		Distance from the edge of the image within which 
;			curve points will not be scanned.  Default is 0.
;
;	algorithm:	Name of alrogithm to use to detect the edge.
;			Choices are 'MODEL', 'GRAD', and 'HALF'.
;			Default is 'MODEL'.
;
;	arg:		Argument passed to the edge detection routine.
;			For the GRAD algorithm, this argument specifies
;			whether each edge is interior (arg=1) or 
;			exterior (arg=0).
;
;	scan_ptd:	If given, these previously scanned points are updated
;			to be consistent with the given data points.  The image
;			is not scanned.
;
;	dir:		If given the scan will be performed in this direction
;			instead of normal to the curve.  Must be a 2-element
;			unit vector.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_curves) of POINT objects containing resulting image points,
;	as well as additional scan data to be used by pg_cvscan_coeff and
;	possibly other programs.  The scan data is as follows:
;
;		 tag			 description
;	 	-----			-------------
;		scan_cos		Cosine of normal at each point.
;		scan_sin		Sine of normal at each point.
;		scan_offsets		Raw offsets from computed curve.
;		scan_cc			Correlation coefficient for each scanned
;					point.
;		scan_sigma		Scan offset uncertainties.
;		scan_model_xpts		Model points corresponding to each
;		scan_model_ypts		 scanned point
;
;
; RESTRICTIONS:
;	Currently does not work for multiple time steps.
;
;
; PROCEDURE:
;	Normal sines and cosines are computed using icv_compute_directions.
;	These directions are input to icv_strip_curve along with the image
;	in order to extract an image strip to be scanned.  icv_scan_strip is 
;	then used to find the optimum scan offsets and icv_convert_scan_offsets
;	is used to obtain image coordinates corresponding to each scan offset.
;	See the documentation for each of those routines for more details.
;
;
; EXAMPLE:
;	The following command scans for a limb in the image contained in the
;	given data descriptor, dd:
;
;	scan_ptd = pg_cvscan(dd, limb_ptd, width=40, edge=20)
;
;	In this call, limb_ptd is a POINT containing computed limb
;	points.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_cvscan_coeff, pg_cvchisq, pg_ptscan, pg_ptscan_coeff, pg_ptchisq, 
;	pg_fit, pg_threshold
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function pg_cvscan, dd, algorithm=algorithm, cd=cd, bx=bx, gd=gd, object_ptd, $
                    model_p=model_p, mzero=mzero, dir=dir, $
                    width=width, edge=edge, arg=arg, scan_ptd=_scan_ptd
 @pnt_include.pro
   
 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)

 image = dat_data(dd)

 n_objects = n_elements(object_ptd)
 s = size(image)

 smz = size(mzero)
 extend_mz = (smz[0] EQ 1)

 ;-----------------------------
 ; default width is 20 pixels
 ;-----------------------------
 if(NOT keyword_set(width)) then width = make_array(n_objects,val=20) $
 else if(n_elements(width) EQ 1) then width = make_array(n_objects,val=width[0])

 ;-----------------------------------
 ; default edge offset is 0 pixels
 ;-----------------------------------
 if(NOT keyword_set(edge)) then edge = intarr(n_objects) $
 else if(n_elements(edge) EQ 1) then edge = make_array(n_objects,val=edge[0])


 if(NOT keyword_set(algorithm)) then algorithm = 'MODEL' 
 if(NOT keyword_set(arg)) then arg = 0

 if(n_elements(algorithm) EQ 1) then algorithm = make_array(n_objects, val=algorithm)
 if(n_elements(arg) EQ 1) then arg = make_array(n_objects, val=arg)


 ;=========================
 ; scan each object
 ;=========================
 scan_ptd = objarr(n_objects)
 for i=0, n_objects-1 do $
  begin
   ;-----------------------------------
   ; get all points
   ;-----------------------------------
   pnt_query, object_ptd[i], points=all_pts, flags=flags, /visible
   if(keyword_set(all_pts)) then $
    begin
     ;-----------------------------------
     ; determine center if possible
     ;-----------------------------------
     center = 0
     if(keyword_set(cd) AND keyword_set(bx)) then $
                          center = pnt_points(pg_center(cd=cd, bx=bx[i]))

     ;-----------------------------------------------
     ; compute curve normals at all points and save
     ;-----------------------------------------------
     n_pts_all=(size(all_pts))[2]

     if(keyword_set(dir)) then $
      begin
       all_cos_alpha = make_array(n_pts_all, val=dir[0])
       all_sin_alpha = make_array(n_pts_all, val=dir[1])
      end $
     else icv_compute_directions, all_pts, center=center, $
                              cos_alpha=all_cos_alpha, sin_alpha=all_sin_alpha

     ;------------------------------------------------------
     ; trim points that are invisible or too close to edge
     ;------------------------------------------------------
     x0=edge[i] & y0=edge[i]
     x1=s[1]-1-edge[i] & y1=s[2]-1-edge[i]
     im_pts = trim_external_points(all_pts, sub=sub, x0, x1, y0, y1)

     if(sub[0] NE -1) then $
      begin
       ;------------------------------------------------------
       ; if scan_ptd given, just update the relevant offsets
       ;------------------------------------------------------
       if(keyword_set(_scan_ptd)) then $
        begin 
         pnt_query, _scan_ptd[i], data=scan_data, points=scan_pts
         cos_alpha = scan_data[0,*]
         sin_alpha = scan_data[1,*]
         scan_offsets = scan_data[2,*]
         cc = scan_data[3,*]
         sigma = scan_data[4,*]
         all_pts = scan_data[5:6,*]

         scan_offsets = icv_invert_scan_offsets(im_pts, scan_pts, cos_alpha, sin_alpha)
        end $
       ;------------------------------------------------------
       ; otherwise perform the image scan
       ;------------------------------------------------------
       else $
        begin
         cos_alpha = all_cos_alpha[sub]
         sin_alpha = all_sin_alpha[sub]

         ;-----------------------------------
         ; get the image strip
         ;-----------------------------------
         n_pts = (size(im_pts))[2]
         strip = icv_strip_curve(cd, image, zero=szero, $
                             im_pts, width[i], width[i], cos_alpha, sin_alpha)

         ;------------------------------------------------------
         ; determine the edge model - use atan model by default
         ;------------------------------------------------------
         if(NOT keyword_set(model_p)) then $
          begin
           model = edge_model_atan(width[i],1,zero=mzero)##make_array(n_pts,val=1.0)
           mzeros = make_array(n_pts,val=mzero)
          end $
         else $
          begin
           model = *model_p[i]##make_array(n_pts,val=1.0)
           if(extend_mz) then mzeros = make_array(n_pts,val=mzero[i]) $
           else mzeros = mzeros[i,*]
          end

         ;-------------------
         ; perform the scan
         ;-------------------
         if((keyword_set(model_p)) AND (algorithm[0] EQ 'MODEL')) then $
           if((size(strip))[2] LE (size(model))[2]) then $
                     nv_message, 'Model width must be less than scan width.' 


         scan_offsets = $
            icv_scan_strip(strip, model, szero, mzeros, $
                      algorithm=algorithm[i], arg=arg[i], cc=cc, sigma=sigma)


         scan_pts = icv_convert_scan_offsets(im_pts, $
                                       scan_offsets, cos_alpha, sin_alpha)
        end 

       ;--------------------
       ; save the scan data
       ;--------------------
       scan_data = dblarr(7,n_pts_all)
       tags = strarr(7)
       scan_data[0,*] = all_cos_alpha  & tags[0] = 'scan_cos'	  ; cosines
       scan_data[1,*] = all_sin_alpha  & tags[1] = 'scan_sin'	  ; sines
       scan_data[2,sub] = scan_offsets & tags[2] = 'scan_offsets'	  ; offsets
       scan_data[3,sub] = cc	   & tags[3] = 'scan_cc'		  ; correlation
       scan_data[4,sub] = sigma	   & tags[4] = 'scan_sigma'	  ; offset error
       scan_data[5,sub] = all_pts[0,sub] & tags[5] = 'scan_model_xpts' ; model pts
       scan_data[6,sub] = all_pts[1,sub] & tags[6] = 'scan_model_ypts'	

       scan_pts_all = dblarr(2,n_pts_all)
       scan_pts_all[*,sub] = scan_pts

       tsub = complement(flags, sub)
       if(tsub[0] NE -1) then flags[tsub] = flags[tsub] OR PTD_MASK_INVISIBLE

       scan_ptd[i] = pnt_create_descriptors(points = scan_pts_all, $
                          desc = 'CVSCAN', $
                          data = scan_data, $
                          flags = flags, $
                          tags = tags)
      end
    end
  end



 return, scan_ptd
end
;===========================================================================
