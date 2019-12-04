; docformat = 'rst'
;=======================================================================
;+
; UVIS EXAMPLE
; ------------
;
;   This script demonstrates reading Cassini RADAR UVIS cubes and projecting them
;   onto an equirectangular mosaic.
;
;   The data files are provided in the `demo/data directory`.
;
;   Setup: The instrument detectors, translators and transforms must contain the
;   VIMS definitions, as is included in `demo/data/instrument_detectors.tab`,
;   `demo/data/translators.tab`, and `demo/data/transforms.tab`.
;
;   This example requires SPICE/Icy to have been setup. It can be run just by doing::
;
;     .run cas_uvis_example
;
;   from within an OMINAS IDL session.
;
;-
;=======================================================================
compile_opt idl2,logical_predicate
;!quiet = 1
;-------------------------------------------------------------------------
;+
; Read UVIS files
; ---------------
;
;
;       files=getenv('OMINAS_DIR')+'/demo/data/FUV*.LBL'
;       dd = dat_read(files)
;
;-
;-------------------------------------------------------------------------
;
files=getenv('OMINAS_DIR')+'/demo/data/FUV*.LBL'

files=file_search(files)
files=files[1]
nv=n_elements(files)
;files='~/uvis/W1568137841_2_CALIB.IMG'
;files='~/uvis/iap/FUV2007_253_18_54.LBL'
dd = dat_read(files)
da=dat_data(dd[0])


;-------------------------------------------------------------------------
;+
; Set up descriptors needed to make the grids and mosaic
; ------------------------------------------------------
;
;     Create an array of global descriptors and populate it::
;
;       gd = {cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}
;       gd.cd = pg_get_cameras(dd[0])
;       gd.gbx = pg_get_planets(dd[0], od=gd[0].cd, name='IAPETUS')
;       gd.ltd = pg_get_stars(dd[0], od=gd[0].cd, name='SUN')
;       
;     Compute the limb::
;     
;       limb_ps = pg_limb(gd=gd);
;
;-
;-------------------------------------------------------------------------
;

;     Create an array of global descriptors and populate it

       gdv = {cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}
       gdv=replicate(gdv,nv)
       for i=0,nv-1 do begin
       gdv[i].cd = pg_get_cameras(dd[i])
       gdv[i].gbx = pg_get_planets(dd[i], od=gdv[i].cd, name='SATURN')

       gdv[i].ltd = pg_get_stars(dd[i], od=gdv[i].cd, name='SUN')
       
;     Compute the limb
     
       
       limb_ps = pg_limb(gd=gd);
       endfor

;-------------------------------------------------------------------------
;+
; Display an image of one of the bands with a limb and grid on top
; ----------------------------------------------------------------
;
;     Create an array of global descriptors and populate it::
;
;       xsize=800
;       ysize=800
;       zoom=8
;       offset=[-20,-20]
;       for i=0, n-1 do begin
;         tvim, (dat_data(dd[i]))[*,*,70], $
;           zoom=zoom,/order, /new,offset=offset,$
;           xsize=xsize,ysize=ysize
;         pg_draw, limb_ps[i]
;         write_png,tvrd()
;       endfor
;       tvim, /list, wnum=ww
;     
;     Create and draw the lat/lon grid and labels::
;     
;       imc=0
;       for i=0,n-1 do begin
;         grid_ps = pg_grid(gd=gd[i], lat=lat, lon=lon)
;         pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx
;         pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx,$
;           od=gd[i].ltd
;         pg_draw, grid_ps, color=ctblue(),wnum=ww[i]
;         plat_ps = pg_grid(gd=gd[i],slon=!dpi/2d,lat=lat,nlon=0)
;         pg_hide, plat_ps[0], cd=gd[i].cd, gbx=gd[0].gbx
;         pg_draw, plat_ps[0], psym=3, $
;           plabel=strtrim(round(lat*180d/!dpi),2),$
;           /label_p,wnum=ww[i]
;         plon_ps = pg_grid(gd=gd[i], slat=0d, lon=lon, nlat=0)
;         pg_hide, plon_ps[0], cd=gd[i].cd, gbx=gd[i].gbx
;         pg_draw, plon_ps[0], psym=3, $
;           plabel=strtrim(round(lon*180d/!dpi),2),$
;           /label_p,wnum=ww[i]
;       endfor
;              
;     These 4 images would look like
;
;     .. image:: graphics/vims_ex_0.png
;
;     .. image:: graphics/vims_ex_1.png
;
;     .. image:: graphics/vims_ex_2.png
;
;     .. image:: graphics/vims_ex_3.png
;     
;-
;-------------------------------------------------------------------------
;

xsize=900
ysize=900
zoom=6
offset=[-20,-20]

dat_set_data,dd[0],total(dat_data(dd[0]),3)
tvim, dat_data(dd[0]),zoom=zoom,/order, /new,offset=offset,xsize=xsize,ysize=ysize
pg_draw, limb_ps[0]
tvim, /list, wnum=ww

;end
imc=0
n=1
for i=0,n-1 do begin
  grid_ps = pg_grid(gd=gdv[i], lat=lat, lon=lon)
  pg_hide, grid_ps, cd=gdv[i].cd, gbx=gdv[i].gbx
;  pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx,$
;    od=gd[i].ltd
  pg_draw, grid_ps, color=ctblue(),wnum=ww[i]
  plat_ps = pg_grid(gd=gdv[i],slon=!dpi/2d,lat=lat,nlon=0)
  pg_hide, plat_ps[0], cd=gdv[i].cd, gbx=gdv[0].gbx
  pg_draw, plat_ps[0], psym=3, $
    plabel=strtrim(round(lat*180d/!dpi),2),$
    /label_p,wnum=ww[i]
  plon_ps = pg_grid(gd=gdv[i], slat=0d, lon=lon, nlat=0)
  pg_hide, plon_ps[0], cd=gdv[i].cd, gbx=gdv[i].gbx
  pg_draw, plon_ps[0], psym=3, $
    plabel=strtrim(round(lon*180d/!dpi),2),$
    /label_p,wnum=ww[i]
;    write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
endfor


map_xsize = 1000
map_ysize = 1000

mdp= pg_get_maps(/over,  $
  name='SATURN',$
  projection='RECTANGULAR', $
  size=[map_xsize,map_ysize], $
  origin=[map_xsize,map_ysize]/2, $
  center=[0.0d0*!dpi,0d0*!dpi])
  
dd_mapv=objarr(nv)
for i=0, nv-1 do dd_mapv[i] = pg_map(dd[i], md=mdp, gd=gdv[i]);, aux=['EMM'])


grim,dd_mapv,cd=replicate(mdp,nv),/new,vis=1,channel=[1b,2b],order=0
  
end


