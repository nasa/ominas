;=============================================================================
;+
; NAME:
;	map_get_grid_points
;
;
; PURPOSE:
;	Generates a lat/lon grid of points.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_pts = map_get_grid_points(lat=lat, lon=lon)
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
;	lat:	Array giving the latitudes for each constant latitude line.
;
;	lon:	Array giving the longitudes for each constant longitude line.
;
;	nt:	Number of grids to produce.
;
;	scan_lat:	Latitudes to scan for each constant longitude line.
;
;	scan_lon:	Longitudes to scan for each constant latitude line.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (2,np,nt) of map coordinate points where np is the number of
;	scan_lats times the number of scan_lons.
;
;
; STATUS:
;	Complete
; 	Adapted by:	Spitale, 5/2016
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
function map_get_grid_points, lat=lat, lon=lon, nt=nt, $
                                 scan_lat=scan_lat, scan_lon=scan_lon
     
 if(NOT keyword_set(nt)) then nt = 1      
 Mt = make_array(nt, val=1)

 nplat = n_elements(scan_lat)
 nplon = n_elements(scan_lon)


 ;==============================
 ; generate longitude circles
 ;==============================
 nlat = n_elements(lat)
 np = nplon*nlat
 if(nlat GT 0) then $
  begin
   lats = reform([lat] ## $
                     make_array(nplon, val=1), np, /overwrite)#Mt
   lons = reform([scan_lon]#make_array(nlat, val=1), np, /overwrite)#Mt

   rlon_map = [tr(lats), tr(lons)]
  end


 ;==============================
 ; generate latitude circles
 ;==============================
 nlon = n_elements(lon)
 np = nplat*nlon
 if(nlon GT 0) then $
  begin
   lons = reform([lon] ## $
                      make_array(nplat, val=1), np, /overwrite)#Mt
   lats = reform([scan_lat]#make_array(nlon, val=1), np, /overwrite)#Mt

   rlat_map = [tr(lats), tr(lons)]
  end


 ;==================================
 ; Combine the results and return.
 ;==================================
 rgrid_map = tr(append_array(tr(rlat_map) , tr(rlon_map)))

 return, rgrid_map
end
;============================================================================
