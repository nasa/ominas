; docformat = 'rst'
;=======================================================================
;+
; GEOTIFF EXAMPLE
; ---------------
; 
;   This script demonstrates reading a Mars MOLA DEM geotiff and projecting it
;   onto an orthographical map for display. The geotiff provided in the demo
;   directory was downsampled by a factor of 20 from the original MOLA DEM from
;   https://astrogeology.usgs.gov/search/map/Mars/GlobalSurveyor/MOLA/Mars_MGS_MOLA_ClrShade_merge_global_463m
;   
;
;   There is no need for SPICE/Icy for this example. It can be run by doing::
;
;     .run geotiff_example
;     
;   From within an OMINAS IDL session.
;    
;   
;-
;=======================================================================
compile_opt idl2,logical_predicate
!quiet = 1
;-------------------------------------------------------------------------
;+
; Read geotiff file 
; -----------------
; 
;     dd=dat_read(getenv('OMINAS_DEMO')+path_sep()+'data'+path_sep()+'Mars_MGS_MOLA_DEM_mosaic_global_9260m.tif')
;
;-
;-------------------------------------------------------------------------


;Read the file 
;dd=dat_read(getenv('OMINAS_DEMO')+path_sep()+'data'+path_sep()+'Mars_MGS_MOLA_DEM_mosaic_global_9260m.tif')
dd=dat_read('./data'+path_sep()+'Mars_MGS_MOLA_DEM_mosaic_global_9260m.tif')

;-------------------------------------------------------------------------
;+
; Display geotiff on grim
; -----------------------
;
;   Get a map descriptor and use it to show the DEM on grim with a map grid::
;  
;     md=pg_get_maps(dd)
;     ;subtract the minimum elevation, so that the data range starts at 0, for visualization
;     da=double(dat_data(dd))
;     damin=min(da)
;     da-=damin
;     dat_set_data,dd,da
;     grim,dd,cd=md,order=0,overlay=['planet_grid']
;     
;   .. image:: graphics/geotiff_example_1.png
;  
;
;-
;-------------------------------------------------------------------------

;Get a map descriptor and show DEM on grim with planet grid overlay
md=pg_get_maps(dd)
;subtract the minimum elevation, so that the data range starts at 0, for visualization
da=double(dat_data(dd))
damin=min(da)
da-=damin
dat_set_data,dd,da
grim,dd,cd=md,order=0,overlay=['planet_grid']

;-------------------------------------------------------------------------
;+
; Map into orthographic projection
; --------------------------------
;
;  
;   Now we will display it in an orthogonal projection. First we define it::
; 
;     map_xsize = 4000
;     map_ysize = 4000
;
;   Create the new map descriptor::
;     mdp= pg_get_maps(/over,  $
;       name='MARS',$
;       projection='ORTHOGRAPHIC', $
;       size=[map_xsize,map_ysize], $
;       origin=[map_xsize,map_ysize]/2, $
;       center=[0d0,-60d0*!dpi/180d0])
;
;   Now, do the projection::
;   
;     dd_map=pg_map(dd,md=mdp,cd=md,pc_xsize=800,pc_ysize=800)
;
;   Visualize the result, now with grim::
; 
;     grim,dd_map,cd=mdp,overlays=['planet_grid'],order=0,/new
;     
;   .. image:: graphics/geotiff_example_2.png
;   
;   
;-
;-------------------------------------------------------------------------

map_xsize = 2000
map_ysize = 2000
mdp= pg_get_maps(/over,  $
 name='MARS',$
 projection='ORTHOGRAPHIC', $
 size=[map_xsize,map_ysize], $
 origin=[map_xsize,map_ysize]/2, $
 center=[0d0,-60d0*!dpi/180d0])


dd_map=pg_map(dd,md=mdp,cd=md,pc_xsize=800,pc_ysize=800)
grim,dd_map,cd=mdp,overlays=['planet_grid'],order=0,/new


;-------------------------------------------------------------------------
;+
; Save geotiffs from OMINAS maps
; ------------------------------
;
;  
;   Put map descriptors in data descriptors::
;
;     cor_set_udata,dd_map,'md',mdp
;     cor_set_udata,dd,'md',md
;     ;scale data for geotiff
;     ndd=nv_clone(dd)
;     ndd_map=nv_clone(dd_map)
;     dat_set_data,ndd,bytscl(dat_data(ndd))
;     dat_set_data,ndd_map,bytscl(dat_data(ndd_map))
;     dat_write,'./outputs/geotiff_ex1.tif',ndd,filetype='GEOTIFF'
;     ;dat_write,'./outputs/geotiff_ex2.tif',ndd_map,filetype='GEOTIFF'
;
;
;   This is how the image looks like on GoogleEarth Pro
;        
;   .. image:: graphics/geotiff_example_4.jpg
;   
;   For comparison, this is GoogleEarth Pro's base layer, with the same perspective
;   
;   .. image:: graphics/geotiff_example_3.jpg
;   
;   
;-
;-------------------------------------------------------------------------

;Put map descriptors in data descriptors
cor_set_udata,dd_map,'md',mdp
cor_set_udata,dd,'md',md
;scale data for geotiff
ndd=nv_clone(dd)
ndd_map=nv_clone(dd_map)
dat_set_data,ndd,bytscl(dat_data(ndd))
dat_set_data,ndd_map,bytscl(dat_data(ndd_map))
dat_write,'./outputs/geotiff_ex1.tif',ndd,filetype='GEOTIFF'
;dat_write,'./outputs/geotiff_ex2.tif',ndd_map,filetype='GEOTIFF'


end
