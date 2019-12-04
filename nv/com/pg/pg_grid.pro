;=============================================================================
;+
; NAME:
;	pg_grid
;
;
; PURPOSE:
;	Computes image points on a surface coordinate grid.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	grid_ptd = pg_grid(cd=cd, gbx=gbx)
;	grid_ptd = pg_grid(gd=gd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of GLOBE.
;
;	dkx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of DISK.
;
;	bx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of BODY.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	lat:	Array giving grid-line latitudes in radians.
;
;	lon:	Array giving grid-line longitudes in radians.
;
;	nlat:	Number of equally-spaced latitude lines to generate if keyword
;		lat not given.  Default is 12.
;
;	flat:	This reference latitude line will be one of the latitude lines generated 
;		if nlat is specified.  Default is zero.
;
;	nlon:	Number of equally-spaced longitude lines to generate if keyword
;		lon not given.  Default is 12.
;
;	flon:	This reference longitude line will be one of the longitude lines generated 
;		if nlon is specified.  Default is zero.
;
;	clip:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;	npoints: Number of points to compute in each latitude or longitude line,
;		 per 2*pi radians; default is 360.
;
;	slat:	Latitudes to compute on each longitude circle.
;
;	slon:	Longitudes to compute on each latitude circle.
;
;
;  OUTPUT: 
;	lat:	Array giving grid-line latitudes in radians.
;
;	lon:	Array giving grid-line longitudes in radians.
;
;	count:	Number of descriptors returned.
;
;
; RETURN:
;	Array of POINT containing image points and the corresponding inertial 
;	vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function pg_grid, cd=cd, gbx=gbx, dkx=dkx, bx=bx, dd=dd, gd=gd, lat=_lat, lon=_lon, $
		nlat=nlat, nlon=nlon, flat=flat, flon=flon, npoints=npoints, $
		clip=clip, cull=cull, slat=slat, slon=slon, count=count
@pnt_include.pro

 count = 0

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)

 if(keyword_set(gbx)) then if(NOT keyword_set(bx)) then bx = gbx
 if(keyword_set(dkx)) then if(NOT keyword_set(bx)) then bx = dkx

 if(NOT defined(flat)) then flat = 0d
 if(NOT defined(flon)) then flon = 0d

 if(keyword_set(clip)) then slop = (image_size(cd[0]))[0]*(clip-1) > 1

 if(NOT keyword_set(npoints)) then npoints = 360
 nplat = npoints
 nplon = npoints

 cor_count_descriptors, bx, nd=n_objects


 ;-----------------------------------
 ; compute grid for each body
 ;-----------------------------------
 hide_flags = make_array(npoints, val=PTD_MASK_INVISIBLE)

 for i=0, n_objects-1 do $
  begin
   bxi = 0
   if(keyword_set(bx)) then bxi = bx[i,0]

   ranges = get_surface_ranges(cd, bxi)
   dranges = ranges[1,*]-ranges[0,*]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; generate latitides if not given
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(NOT defined(_lat)) then $
    begin
     if(NOT defined(nlat)) then nlat = 12

     if(nlat NE 0) then $  
       lat = dindgen(nlat+1)/nlat*dranges[0] + ranges[0,0] + flat
    end $
   else lat = _lat

   if(keyword_set(lat)) then $
    begin
     lat = reduce_range(lat, ranges[0,0], ranges[1,0], /inclusive)
     __lat = lat
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; generate longitudes if not given
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(NOT defined(_lon)) then $
    begin
     if(NOT defined(nlon)) then nlon = 24

     if(nlon NE 0) then $  
               lon = dindgen(nlon+1)/nlon*dranges[1] + ranges[0,1] + flon
    end $
   else lon = _lon

   if(keyword_set(lon)) then $
    begin
     lon = reduce_range(lon, ranges[0,1], ranges[1,1], /inclusive)
     __lon = lon
    end


   gd_input = {cd:cd[0]}
   if(keyword_set(bx)) then $
    begin
     xd = reform(bx[i,*])
     gd_input = append_struct(gd_input, {bx:bx[i,0]})
    end

   ;- - - - - - - - - - - - - - - - -
   ; clip 
   ;- - - - - - - - - - - - - - - - -
   scan_ranges = ranges
   scan_dranges = dranges
   continue = 1
   if(keyword_set(clip)) then $
    begin
     surface_image_bounds, cd, xd, slop=slop, $
         latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax, status=status
     if(status NE 0) then continue = 0 $
    else $
     begin
      if(lonmax LT lonmin) then lonmin = lonmin - 2d*!dpi

      scan_ranges[*,0] = [latmin, latmax]
      scan_ranges[*,1] = [lonmin, lonmax]
      scan_dranges = scan_ranges[1,*]-scan_ranges[0,*]
     end
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; generate map points along each lat and lon circle 
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(defined(slat)) then scan_lat = slat $
   else scan_lat = dindgen(nplat)/(nplat-1)*scan_dranges[0] + scan_ranges[0,0]

   if(defined(slon)) then scan_lon = slon $
   else scan_lon = dindgen(nplon)/(nplon-1)*scan_dranges[1] + scan_ranges[0,1]


   scan_lat = reduce_range(scan_lat, ranges[0,0], ranges[1,0], /inclusive)
   scan_lon = reduce_range(scan_lon, ranges[0,1], ranges[1,1], /inclusive)


   ;- - - - - - - - - - - - - - - - -
   ; compute points 
   ;- - - - - - - - - - - - - - - - -
   if(continue) then $
    begin
     grid_pts_map = map_get_grid_points(lat=lat, lon=lon, $
                                        scan_lat=scan_lat, scan_lon=scan_lon)
     flags = bytarr(n_elements(grid_pts_map[0,*]))
     points = map_to_image(cd, cd, xd, grid_pts_map, valid=valid, body=grid_pts)

     inertial_pts = 0
     if(keyword_set(bx)) then $
      if(keyword_set(grid_pts)) then $
       inertial_pts = bod_body_to_inertial_pos(xd, grid_pts)
 
     if(keyword__set(valid)) then $
      begin
       invalid = complement(points[0,*], valid)
       if(invalid[0] NE -1) then flags[invalid] = PTD_MASK_INVISIBLE
      end

     ;-----------------------------------
     ; store grid
     ;-----------------------------------
     _grid_ptd = pnt_create_descriptors(name = cor_name(xd), $
     		       desc = 'GLOBE_GRID', $
		       task = 'PG_GRID', $
     		       gd = gd_input, $
     		       assoc_xd = xd, $
     		       points = points, $
     		       flags = flags, $
     		       vectors = inertial_pts)
     if(keyword_set(bx)) then $
       if(NOT bod_opaque(bx[i,0])) then pnt_set_flags, _grid_ptd, hide_flags
     grid_ptd = append_array(grid_ptd, _grid_ptd)
    end
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, grid_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then grid_ptd = pnt_cull(grid_ptd)
  end


 if(keyword_set(__lat)) then _lat = __lat
 if(keyword_set(__lon)) then _lon = __lon

 count = n_elements(grid_ptd)
 return, grid_ptd
end
;=============================================================================
