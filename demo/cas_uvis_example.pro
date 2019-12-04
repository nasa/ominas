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
files=files[0]
;files='~/uvis/W1568137841_2_CALIB.IMG'
;files='~/uvis/iap/FUV2007_253_18_54.LBL'
files='data/FUV2007_253_17_19.LBL'
dd = dat_read(files)
dat_set_data,dd[0],reverse(transpose(dat_data(dd[0]),[2,1,0]),2)


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

       gd = {cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}
       gd.cd = pg_get_cameras(dd[0])
       gd.gbx = pg_get_planets(dd[0], od=gd[0].cd, name='IAPETUS')
       gd.ltd = pg_get_stars(dd[0], od=gd[0].cd, name='SUN')
       
;     Compute the limb
     
       limb_ps = pg_limb(gd=gd);


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
zoom=8
offset=[-20,-20]


tvim, total(dat_data(dd[0]),3),zoom=zoom,/order, /new,offset=offset,xsize=xsize,ysize=ysize
pg_draw, limb_ps
tvim, /list, wnum=ww

;end
imc=0
n=1
for i=0,n-1 do begin
  grid_ps = pg_grid(gd=gd[i], lat=lat, lon=lon)
  pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx
  pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx,$
    od=gd[i].ltd
  pg_draw, grid_ps, color=ctblue(),wnum=ww[i]
  plat_ps = pg_grid(gd=gd[i],slon=!dpi/2d,lat=lat,nlon=0)
  pg_hide, plat_ps[0], cd=gd[i].cd, gbx=gd[0].gbx
  pg_draw, plat_ps[0], psym=3, $
    plabel=strtrim(round(lat*180d/!dpi),2),$
    /label_p,wnum=ww[i]
  plon_ps = pg_grid(gd=gd[i], slat=0d, lon=lon, nlat=0)
  pg_hide, plon_ps[0], cd=gd[i].cd, gbx=gd[i].gbx
  pg_draw, plon_ps[0], psym=3, $
    plabel=strtrim(round(lon*180d/!dpi),2),$
    /label_p,wnum=ww[i]
;    write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
endfor


end

;+
; Create a 3-band mosaic
; ----------------------
;
;     Correct the illumination with a Lambertian function::
;     
;       dd_pht = objarr(n)
;       for i=0, n-1 do dd_pht[i] = pg_photom(dd[i], gd=gd[i],
;         refl_fn='pht_lamb', refl_parm=[0.9d], outline=limb_ps[i])
;       phtdata=list()
;       for i=0,n-1 do phtdata.add,(dat_data(dd_pht[i]))
;
;     Set up the mosaic::
;     
;       bands=[70,104,106]
;       map_xsize = 1600
;       map_ysize = 800
;       moslim=[[0d0,0.2d0],[0d0,0.01d0],[0d0,0.1d0]]
;       mosaics=list()
;    
;     Loop over bands, projecting and displaying each image::
;     
;       foreach band,bands,iband do begin
;         for i=0,n-1 do dat_set_data,dd_pht[i],phtdata[i,*,*,band]
;         md = pg_get_maps(/over, gbx = pd1, name='TITAN',$
;          projection='RECTANGULAR',fn_data=ptr_new(),$
;          size=[map_xsize,map_ysize],origin=[map_xsize,map_ysize]/2)
;         dd_map = objarr(n)
;         for i=0, n-1 do begin
;          dd_map[i]=pg_map(dd_pht[i],md=md,gd=gd[i],aux=['EMM'])
;          tvim,dat_data(dd_map[i])<max((dat_data(dd[i]))[*,*,band]),/new
;         endfor
;         
;     These projected images would look like: 
;         
;     .. image:: graphics/vims_ex_4.png
;
;     .. image:: graphics/vims_ex_5.png
;         
;     .. image:: graphics/vims_ex_6.png
;         
;     .. image:: graphics/vims_ex_7.png
;         
;     Combine the images in a mosaic and display it::
;     
;         dd_mosaic = pg_mosaic(dd_map, mosaic=mosaic, $
;           wt='emm', comb='sum', data={x:1, emm0:cos(90d*!dpi/180d)})
;         tvim,moslim[0,iband]>mosaic<moslim[1,iband],/new
;
;     Add a grid on top::
;     
;         pd = pg_get_planets(dd[0], od=gd[0].cd)
;         gdm={cd:md,od:(gd[0].cd)[0],gbx:cor_select(pd,'TITAN'),$
;          dkx:gd[0].dkx}
;         map_grid_ps=pg_grid(gd=gdm, lat=lat, lon=lon)
;         plat_ps=pg_grid(gd=gdm, slon=!dpi/2d, lat=lat, nlon=0)
;         plon_ps=pg_grid(gd=gdm, slat=0d, lon=lon, nlat=0)
;         pg_draw, map_grid_ps, col=ctgreen()
;         pg_draw,plat_ps,psym=7,$
;          plabel=strmid(strtrim(lat*180d/!dpi,2),0,3),/label_p
;         pg_draw,plon_ps,psym=7,$
;           plabel=strmid(strtrim(lon*180d/!dpi,2),0,3),/label_p
;         mosaics.add,mosaic
;       endforeach
;       
;     The mosaics would look like, for each band:: 
;
;     .. image:: graphics/vims_ex_8.png
;
;     .. image:: graphics/vims_ex_13.png
;
;     .. image:: graphics/vims_ex_18.png
;       
;-
;-------------------------------------------------------------------------
;

dd_pht = objarr(n)
for i=0, n-1 do dd_pht[i] = pg_photom(dd[i], gd=gd[i], refl_fn='pht_lamb', $
                                  refl_parm=[0.9d], outline=limb_ps[i])
phtdata=list()
for i=0,n-1 do phtdata.add,(dat_data(dd_pht[i]))

bands=[70,104,106]        
map_xsize = 1000
map_ysize = 500
moslim=[[0d0,0.2d0],[0d0,0.01d0],[0d0,0.1d0]]
mosaics=list()
foreach band,bands,iband do begin
  for i=0,n-1 do dat_set_data,dd_pht[i],phtdata[i,*,*,band]
  md = pg_get_maps(/over, gbx = pd1, name='TITAN',projection='RECTANGULAR',$
   fn_data=ptr_new(),size=[map_xsize,map_ysize],origin=[map_xsize,map_ysize]/2)
  dd_map = objarr(n)
  for i=0, n-1 do dd_map[i] = pg_map(dd_pht[i], md=md, gd=gd[i], aux=['EMM'])
  for i=0, n-1 do begin
    tvim, dat_data(dd_map[i])<max((dat_data(dd[i]))[*,*,band]), /new
;    write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
  endfor
  
  dd_mosaic = pg_mosaic(dd_map, mosaic=mosaic, $
                 wt='emm', comb='sum', data={x:1, emm0:cos(90d*!dpi/180d)})
  tvim,moslim[0,iband]>mosaic<moslim[1,iband],/new
  
  pd = pg_get_planets(dd[0], od=gd[0].cd)
  gdm={cd:md, od:(gd[0].cd)[0], gbx:cor_select(pd,'TITAN'), dkx:gd[0].dkx}
  map_grid_ps=pg_grid(gd=gdm, lat=lat, lon=lon)
    plat_ps=pg_grid(gd=gdm, slon=!dpi/2d, lat=lat, nlon=0)
    plon_ps=pg_grid(gd=gdm, slat=0d, lon=lon, nlat=0)
  pg_draw, map_grid_ps, col=ctgreen()
  pg_draw, plat_ps, psym=7, plabel=strmid(strtrim(lat*180d/!dpi,2),0,3), /label_p
  pg_draw, plon_ps, psym=7, plabel=strmid(strtrim(lon*180d/!dpi,2),0,3), /label_p
;  write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
  mosaics.add,mosaic
endforeach



end



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
dd = dat_read(files)


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

       gd = {cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}
       gd.cd = pg_get_cameras(dd[0])
       gd.gbx = pg_get_planets(dd[0], od=gd[0].cd, name='IAPETUS')
       gd.ltd = pg_get_stars(dd[0], od=gd[0].cd, name='SUN')
       
;     Compute the limb
     
       limb_ps = pg_limb(gd=gd);


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

xsize=600
ysize=600
zoom=8
offset=[-20,-20]

for i=0, n-1 do begin
  tvim, (dat_data(dd[i]))[*,*,70], $
    zoom=zoom,/order, /new,offset=offset,$
    xsize=xsize,ysize=ysize
  pg_draw, limb_ps[i]
endfor
tvim, /list, wnum=ww


imc=0
for i=0,n-1 do begin
  grid_ps = pg_grid(gd=gd[i], lat=lat, lon=lon)
  pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx
  pg_hide, grid_ps, cd=gd[i].cd, gbx=gd[i].gbx,$
    od=gd[i].ltd
  pg_draw, grid_ps, color=ctblue(),wnum=ww[i]
  plat_ps = pg_grid(gd=gd[i],slon=!dpi/2d,lat=lat,nlon=0)
  pg_hide, plat_ps[0], cd=gd[i].cd, gbx=gd[0].gbx
  pg_draw, plat_ps[0], psym=3, $
    plabel=strtrim(round(lat*180d/!dpi),2),$
    /label_p,wnum=ww[i]
  plon_ps = pg_grid(gd=gd[i], slat=0d, lon=lon, nlat=0)
  pg_hide, plon_ps[0], cd=gd[i].cd, gbx=gd[i].gbx
  pg_draw, plon_ps[0], psym=3, $
    plabel=strtrim(round(lon*180d/!dpi),2),$
    /label_p,wnum=ww[i]
;    write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
endfor




;+
; Create a 3-band mosaic
; ----------------------
;
;     Correct the illumination with a Lambertian function::
;     
;       dd_pht = objarr(n)
;       for i=0, n-1 do dd_pht[i] = pg_photom(dd[i], gd=gd[i],
;         refl_fn='pht_lamb', refl_parm=[0.9d], outline=limb_ps[i])
;       phtdata=list()
;       for i=0,n-1 do phtdata.add,(dat_data(dd_pht[i]))
;
;     Set up the mosaic::
;     
;       bands=[70,104,106]
;       map_xsize = 1600
;       map_ysize = 800
;       moslim=[[0d0,0.2d0],[0d0,0.01d0],[0d0,0.1d0]]
;       mosaics=list()
;    
;     Loop over bands, projecting and displaying each image::
;     
;       foreach band,bands,iband do begin
;         for i=0,n-1 do dat_set_data,dd_pht[i],phtdata[i,*,*,band]
;         md = pg_get_maps(/over, gbx = pd1, name='TITAN',$
;          projection='RECTANGULAR',fn_data=ptr_new(),$
;          size=[map_xsize,map_ysize],origin=[map_xsize,map_ysize]/2)
;         dd_map = objarr(n)
;         for i=0, n-1 do begin
;          dd_map[i]=pg_map(dd_pht[i],md=md,gd=gd[i],aux=['EMM'])
;          tvim,dat_data(dd_map[i])<max((dat_data(dd[i]))[*,*,band]),/new
;         endfor
;         
;     These projected images would look like: 
;         
;     .. image:: graphics/vims_ex_4.png
;
;     .. image:: graphics/vims_ex_5.png
;         
;     .. image:: graphics/vims_ex_6.png
;         
;     .. image:: graphics/vims_ex_7.png
;         
;     Combine the images in a mosaic and display it::
;     
;         dd_mosaic = pg_mosaic(dd_map, mosaic=mosaic, $
;           wt='emm', comb='sum', data={x:1, emm0:cos(90d*!dpi/180d)})
;         tvim,moslim[0,iband]>mosaic<moslim[1,iband],/new
;
;     Add a grid on top::
;     
;         pd = pg_get_planets(dd[0], od=gd[0].cd)
;         gdm={cd:md,od:(gd[0].cd)[0],gbx:cor_select(pd,'TITAN'),$
;          dkx:gd[0].dkx}
;         map_grid_ps=pg_grid(gd=gdm, lat=lat, lon=lon)
;         plat_ps=pg_grid(gd=gdm, slon=!dpi/2d, lat=lat, nlon=0)
;         plon_ps=pg_grid(gd=gdm, slat=0d, lon=lon, nlat=0)
;         pg_draw, map_grid_ps, col=ctgreen()
;         pg_draw,plat_ps,psym=7,$
;          plabel=strmid(strtrim(lat*180d/!dpi,2),0,3),/label_p
;         pg_draw,plon_ps,psym=7,$
;           plabel=strmid(strtrim(lon*180d/!dpi,2),0,3),/label_p
;         mosaics.add,mosaic
;       endforeach
;       
;     The mosaics would look like, for each band:: 
;
;     .. image:: graphics/vims_ex_8.png
;
;     .. image:: graphics/vims_ex_13.png
;
;     .. image:: graphics/vims_ex_18.png
;       
;-
;-------------------------------------------------------------------------
;

dd_pht = objarr(n)
for i=0, n-1 do dd_pht[i] = pg_photom(dd[i], gd=gd[i], refl_fn='pht_lamb', $
                                  refl_parm=[0.9d], outline=limb_ps[i])
phtdata=list()
for i=0,n-1 do phtdata.add,(dat_data(dd_pht[i]))

bands=[70,104,106]        
map_xsize = 1000
map_ysize = 500
moslim=[[0d0,0.2d0],[0d0,0.01d0],[0d0,0.1d0]]
mosaics=list()
foreach band,bands,iband do begin
  for i=0,n-1 do dat_set_data,dd_pht[i],phtdata[i,*,*,band]
  md = pg_get_maps(/over, gbx = pd1, name='TITAN',projection='RECTANGULAR',$
   fn_data=ptr_new(),size=[map_xsize,map_ysize],origin=[map_xsize,map_ysize]/2)
  dd_map = objarr(n)
  for i=0, n-1 do dd_map[i] = pg_map(dd_pht[i], md=md, gd=gd[i], aux=['EMM'])
  for i=0, n-1 do begin
    tvim, dat_data(dd_map[i])<max((dat_data(dd[i]))[*,*,band]), /new
;    write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
  endfor
  
  dd_mosaic = pg_mosaic(dd_map, mosaic=mosaic, $
                 wt='emm', comb='sum', data={x:1, emm0:cos(90d*!dpi/180d)})
  tvim,moslim[0,iband]>mosaic<moslim[1,iband],/new
  
  pd = pg_get_planets(dd[0], od=gd[0].cd)
  gdm={cd:md, od:(gd[0].cd)[0], gbx:cor_select(pd,'TITAN'), dkx:gd[0].dkx}
  map_grid_ps=pg_grid(gd=gdm, lat=lat, lon=lon)
    plat_ps=pg_grid(gd=gdm, slon=!dpi/2d, lat=lat, nlon=0)
    plon_ps=pg_grid(gd=gdm, slat=0d, lon=lon, nlat=0)
  pg_draw, map_grid_ps, col=ctgreen()
  pg_draw, plat_ps, psym=7, plabel=strmid(strtrim(lat*180d/!dpi,2),0,3), /label_p
  pg_draw, plon_ps, psym=7, plabel=strmid(strtrim(lon*180d/!dpi,2),0,3), /label_p
;  write_png,'graphics/vims_ex_'+strtrim(imc++,2)+'.png',tvrd()
  mosaics.add,mosaic
endforeach



end


