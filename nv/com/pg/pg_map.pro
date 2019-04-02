;=============================================================================
;+
; NAME:
;	pg_map
;
;
; PURPOSE:
;	Generates map projections.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_map(dd, md=md, cd=cd, gbx=gbx, ltd=ltd)
;	result = pg_map(dd, gd=gd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing image to be projected.
;
; KEYWORDS:
;  INPUT:
;	md:	Map descriptor describing the projection.
;
;	cd:	Camera descriptor describing the image to be projected.
;
;	bx:	Subclass of BODY giving the body to be projected.  Can be
;		GLOBE or RING.  Only bodies whose names match that in the
;		map descriptor are mapped.
;
;	gbx:	Globe descriptor describing the body to be projected.  
;		This argument is kept for compatibility with earlier
;		code.  It is recommended that you use the 'bx' argument
;		instead.
;
;	dkx:	Disk descriptor describing the body to be projected.  
;		This argument is kept for compatibility with earlier
;		code.  It is recommended that you use the 'bx' argument
;		instead.
;
;	ltd:	Star descriptor for a light source.  If given, points behind the
;		terminator are excluded.
;
;	gd:	Generic descriptor.  If given, the above descriptor inputs 
;		are taken from the corresponding fields of this structure
;		instead of from those keywords.
;
;	hide_fn:
;		String giving the name of a function whose purpose
;		is to exclude hidden points from the map.  Options are:
;		   pm_hide_ring
;		   pm_hide_globe
;		   pm_rm_globe_shadow
;		   pm_rm_globe
;
;	hide_bx:
;		Array of BODY objects for the hide functions; one per
;		function.
;
;	aux_names:	
;		Array (naux) giving udata names for additional data
;		descriptor planes to reproject.  The dimensions of these
;		planes must be the same as the image. 
;
;	pc_xsize, pc_ysize:	
;		The map is generated in pieces of size pc_xsize
;		x pc_ysize.   Default is 100 x 100 pixels.
;
;	bounds:		
;		Projection bounds specified as [lat0, lat1, lon0, lon1].
;
;	edge:	Minimum proximity to image edge.  Default is 0.
;
;	roi:	Subscripts in the output map specifying the map region
;		to project, instead of the whole thing.
;
;	interp:	Type of interpolation, see image_interp_cam.
;
;	arg_interp:	Interpolation argument, see image_interp_cam.
;
;	offset:	Offset in [lat,lon] to apply to map coordinates before 
;		projecting.
;
;	smooth:	If set, the input image is smoothed before reprojection.
;
;	test_factor:	If set, a test map, reduced in size by this factor,
;			is projected to determine the roi.  For maps with
;			large blank areas, this may speed up the projection
;			greatly.
;
;
;  OUTPUT:
;	map:	For convenience, the generated map is returned here as
;		well as in the returned data descriptor.
;
;
; RETURN:
;	Data descriptor containing the output map.  The instrument field is set
;	to 'MAP'.  User data arrays are created for the reprojected aux_names
;	arrays.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_mosaic
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	Modified:	Daiana DiNino; 7, 2011 : test_factor
;	
;-
;=============================================================================
function pg_map, dd, md=md, cd=cd, bx=bx, gbx=_gbx, dkx=dkx, ltd=ltd, gd=gd, $
                   hide_fn=hide_fn, hide_bx=hide_bx, map=map, $
                   aux_names=aux_names, pc_xsize=pc_xsize, pc_ysize=pc_ysize, $ 
                   bounds=bounds, interp=interp, arg_interp=arg_interp, $
                   offset=offset, edge=edge, shear_fn=shear_fn, shear_data=shear_data, $
                   smooth=smooth, roi=roi, test_factor=test_factor

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(dd)) then dd = dat_gd(gd, /dd)
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(_gbx)) then _gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)
 if(NOT keyword_set(ltd)) then ltd = dat_gd(gd, dd=dd, /ltd)
 if(NOT keyword_set(md)) then md = dat_gd(gd, dd=dd, /md)
 map = !null

 if(keyword_set(_gbx)) then gbx = _gbx
 if(NOT keyword_set(bx)) then $
  begin
   if(keyword_set(dkx)) then bx = dkx 
   if(keyword_set(_gbx)) then bx = _gbx 
  end


 ;---------------------------------------
 ; create map data descriptor
 ;---------------------------------------
 dd_map = dat_create_descriptors(1, $
       instrument='MAP', filetype=dat_filetype(dd), $
       name=cor_name(bx))


 ;------------------------------------------------------------------
 ; combine any auxilliary arrays with image array for reprojection
 ;------------------------------------------------------------------
 naux = n_elements(aux_names)
 if(naux GT 0) then $
  begin
   _image = dat_data(dd)
   s = size(_image)
   xsize = s[1] & ysize = (s[0] gt 1 ? s[2] : 1)

   aux_flags = bytarr(naux)
   image = dblarr(xsize, ysize, naux+1, /nozero)
   image[*,*,0] = _image
   nn = 1

   for i=0, naux-1 do $
    begin
     temp = cor_udata(dd, aux_names[i])
     if(keyword_set(temp)) then $
      begin
       aux_flags[i] = 1
       image[*,*,nn] = temp
       nn = nn + 1
      end
    end

   if(nn LT naux) then image = image[*,*,0:nn+1]
  end $
 else image = dat_data(dd)


 ;---------------------------------------
 ; determine size of map pieces 
 ;---------------------------------------
 if(NOT keyword_set(pc_xsize)) then pc_xsize = 200
 if(NOT keyword_set(pc_ysize)) then pc_ysize = 200


; ;---------------------------------------
; ; zero out pixels near image edge
; ;---------------------------------------
; if(keyword_set(edge)) then $
;  begin
;   s = size(image)
;   image[0:edge-1,*] = 0
;   image[*,0:edge-1] = 0
;   image[s[1]-edge:*,*] = 0
;   image[*,s[2]-edge:*] = 0
;  end


 ;-------------------------------------------------------------
 ; If test_factor given, project a small map to find ROI.
 ; This does not seem to work when md is a camera descriptor.
 ;-------------------------------------------------------------
 if(keyword_set(test_factor)) then $
  begin
   test_md = nv_clone(md)
   map_size = image_size(md)
   set_image_size, test_md, map_size/test_factor
   set_image_origin, test_md, image_origin(md)/test_factor

   if(cor_class(test_md) EQ 'CAMERA') then cam_set_scale, test_md, cam_scale(md)*test_factor

   test_map = project_map(image, bounds=bounds, interp=interp,  $
            md=test_md, cd=cd, bx=bx, ltd=ltd, pc_xsize, pc_ysize, $
;            hide_fn=hide_fn, hide_bx=hide_bx, $
            arg_interp=arg_interp, $
            offset=offset, shear_fn=shear_fn, shear_data=shear_data, edge=edge, $
            smooth=smooth, roi=roi, value=1)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   ; the smoothing routine seems to have a bug --> use shift in all
   ; directions to enlarge the sample of pixels
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   wt = where(test_map NE 0)
   if(wt[0] EQ -1) then map = bytarr(image_size(md)) $
   else $
    begin
     test_map = smooth(test_map, 5)
     test_map = smooth(congrid(test_map,map_size[0],map_size[1]), test_factor)
     roi = where(test_map NE 0)
     if (roi[0] EQ -1) then roi = 0
     nv_free, test_md
     test_map = 0
    end


;   wt = where(test_map NE 0)
;   if(wt[0] EQ -1) then map = bytarr(image_size(md)) $
;   else $
;    begin
;     test_map[wt] = 1

;     shifts = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]] * 1
;     sh_test_map = test_map
;     for i=0,7 do sh_test_map = sh_test_map + shift(test_map,shifts[*,i])

;     test_map = smooth(congrid(sh_test_map,map_size[0],map_size[1]), test_factor)
    
;     roi = where(test_map NE 0)
;     if (roi[0] EQ -1) then roi = 0

;     nv_free, test_md
;     test_map = 0
;    end
  end


 ;---------------------------------------
 ; create the map
 ;---------------------------------------
 if(NOT keyword_set(map)) then $
    map = project_map(image, bounds=bounds, interp=interp,  $
            md=md, cd=cd, bx=bx, ltd=ltd, pc_xsize, pc_ysize, $
            hide_fn=hide_fn, hide_bx=hide_bx, arg_interp=arg_interp, $
            offset=offset, shear_fn=shear_fn, shear_data=shear_data, edge=edge, $
            smooth=smooth, roi=roi)
 map = map > 0


 ;--------------------------------------------------------------------------
 ; extract reprojected auxilliary arrays and store in new data descriptor
 ;--------------------------------------------------------------------------
 if(naux GT 0) then $
  begin
   dat_set_data, dd_map, map[*,*,0]

   nn = 1
   for i=0, naux-1 do $
    if(aux_flags[i]) then $
     begin
      cor_set_udata, dd_map, aux_names[i], map[*,*,nn]
      nn = nn + 1
     end
  end $
 else dat_set_data, dd_map, map


 return, dd_map
end
;=============================================================================
