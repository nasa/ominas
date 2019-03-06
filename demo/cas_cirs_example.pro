; docformat = 'rst'
;=======================================================================
;+
; CIRS EXAMPLE
; ------------
; 
;   This script demonstrates reading a Cassini CIRS cube and projecting it
;   onto an orthographical map for display with a Cassini ISS image of Mimas.
;   
;   Setup: The instrument detectors, translators and transforms must contain the
;   CIRS and ISS definitions, as is included in `demo/data/instrument_detectors.tab`,
;   `demo/data/translators.tab`, and `demo/data/transforms.tab`.
;
;   This example requires SPICE/Icy to have been setup.  It also requires
;   the OMINAS demo package to be configured.  It can be run by doing::
;
;     .run cas_cirs_example
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
; Extract CIRS files
; ------------------
; 
;   The cubes from PDS are too large to include in the OMINAS repository uncompressed,
;   so we will uncompress the tar files included with OMINAS::
;   
;     ;Extract the CIRS files, if needed
;     ldir='~/ominas_data/cirs'
;     spawn,'eval echo '+ldir,res
;     ldir=res
;     imgs=ldir[0]+path_sep()+['126MI_FP3DAYMAP001_CI006_601_F3_039E.DAT','126MI_FP3DAYMAP001_CI004_601_F3_039E.DAT']
;     foreach img,imgs do if ~file_test(img,/read) then begin
;       print,'CIRS DAT file needed for the demo not found. Extracting it from the tar.gz file provided with OMINAS...'
;       file_untar,getenv('OMINAS_DEMO')+path_sep()+'data'+path_sep()+file_basename(img,'.DAT')+'.tar.gz',ldir,/verbose
;     endif
;
; 
;
;-
;-------------------------------------------------------------------------

;Extract the CIRS files, if needed
ldir='~/ominas_data/cirs'
spawn,'eval echo '+ldir,res
ldir=res
imgs=ldir[0]+path_sep()+['126MI_FP3DAYMAP001_CI006_601_F3_039E.DAT','126MI_FP3DAYMAP001_CI004_601_F3_039E.DAT']
foreach img,imgs do if ~file_test(img,/read) then begin
  print,'CIRS DAT file needed for the demo not found. Extracting it from the tar.gz file provided with OMINAS...'
;  file_untar,getenv('OMINAS_DEMO')+path_sep()+'data'+path_sep()+file_basename(img,'.DAT')+'.tar.gz',ldir,/verbose
  file_untar,'./data'+path_sep()+file_basename(img,'.DAT')+'.tar.gz',ldir,/verbose
endif



;Read the CIRS files 
dd=dat_read(file_search(ldir+path_sep()+'126MI_FP3DAYMAP001_CI00*_601_F3_039E.LBL'))

;-------------------------------------------------------------------------
;+
; Display CIRS files
; ------------------
;
;   Since the cubes have many wavelenghts, create a single-band product for
;   visualization, by adding the flux on all bands::
;   
;     for i=0,1 do begin
;       da=dat_data(dd[i])
;       dat_set_data,dd[i],reverse(total(da.core,3),2)
;       tvim,dat_data(dd[i]),/order,/new
;     endfor
;  
;   .. image:: graphics/cirs_ex1_1.png
;   .. image:: graphics/cirs_ex1_2.png
;
;-
;-------------------------------------------------------------------------
for i=0,1 do begin
  da=dat_data(dd[i])
  dat_set_data,dd[i],reverse(total(da,3),2)
  tvim,dat_data(dd[i]),/order,/new
endfor
;-------------------------------------------------------------------------
;+
; Map CIRS and ISS files
; ----------------------
;
;   CIRS cube data are provided in PDS as a map on the target, in a rectangular projection, shown above. 
;   To use them, first we need to obtain the proper map descriptor from the data object::
;
;
;   Create the new map descriptor::
;     map_xsize = 1000
;     map_ysize = 1000
;     
;     mdp= pg_get_maps(/over,  $
;       name='MIMAS',$
;       projection='ORTHOGRAPHIC', $
;       size=[map_xsize,map_ysize], $
;       origin=[map_xsize,map_ysize]/2, $
;       center=[0d0,-0.7d0*!dpi])
;
;   Now, read the ISS image and put it into an array with the CIRS cubes::
;
;     dd=[(dat_read(getenv('OMINAS_DIR')+'/demo/data/N1644787857_1.IMG'))[0],dd]
;
;   Get the necessary camera, map, planet descriptors::
;   
;     nv=3
;     mdr=objarr(nv) & cd=objarr(nv) & pd=objarr(nv) & ltd=objarr(nv) & dd_map=objarr(nv)
;     gd = replicate({cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}, nv)
;     for i=0,nv-1 do begin
;       gd[i].cd = pg_get_cameras(dd[i])
;       gd[i].gbx = pg_get_planets(dd[i], od=cd[i],name='MIMAS')
;       gd[i].ltd = pg_get_stars(dd[i], od=cd[i], name='SUN')
;       if i gt 0 then begin
;         mdr[i]=pg_get_maps(dd[i])
;         dd_map[i]=pg_map(dd[i],md=mdp,cd=mdr[i],pc_xsize=500,pc_ysize=500)
;       endif else begin
;         dd_map[i]=pg_map(dd[i], md=mdp, gd=gd[i],aux=['EMM'])
;       endelse
;       ;Scale the data in all bands to the same range (0-1)
;       da=dat_data(dd_map[i])
;       r=minmax(da)
;       dat_set_data,dd_map[i],(da-r[0])/(r[1]-r[0])
;     endfor
;
;   Visualize the result, now with grim::
; 
;     grim,dd_map,cd=replicate(mdp,3),od=gd.cd,ltd=gd.ltd,pd=gd.gbx,channel=[1b,2b,2b],overlays=['planet_grid'],/new,vis=1
;   
;   .. image:: graphics/cirs_ex1_3.png
;   
;-
;-------------------------------------------------------------------------

map_xsize = 1000
map_ysize = 1000

mdp= pg_get_maps(/over,  $
  name='MIMAS',$
  projection='ORTHOGRAPHIC', $
  size=[map_xsize,map_ysize], $
  origin=[map_xsize,map_ysize]/2, $
  center=[0d0,-0.7d0*!dpi])

;dd=[(dat_read(getenv('OMINAS_DEMO')+path_sep()+'data'+path_sep()+'N1644787857_1.IMG'))[0],dd]
dd=[(dat_read('./data'+path_sep()+'N1644787857_1.IMG'))[0],dd]

nv=3
mdr=objarr(nv) & cd=objarr(nv) & pd=objarr(nv) & ltd=objarr(nv) & dd_map=objarr(nv)
gd = replicate({cd:obj_new(), gbx:obj_new(), dkx:obj_new(), ltd:obj_new()}, nv)
for i=0,nv-1 do begin

  gd[i].cd = pg_get_cameras(dd[i])
  gd[i].gbx = pg_get_planets(dd[i], od=cd[i],name='MIMAS')
  ;gd[i].ltd = pg_get_stars(dd[i], od=cd[i], name='SUN')
  
  if i gt 0 then begin    
    mdr[i]=pg_get_maps(dd[i])
    dd_map[i]=pg_map(dd[i],md=mdp,cd=mdr[i],pc_xsize=500,pc_ysize=500)
  endif else begin
    dd_map[i]=pg_map(dd[i], md=mdp, gd=gd[i],aux=['EMM'])
  endelse
  ;Scale the data in all bands to the same range (0-1)
  da=dat_data(dd_map[i])
  r=minmax(da)
  dat_set_data,dd_map[i],(da-r[0])/(r[1]-r[0])
endfor



grim,dd_map,cd=replicate(mdp,3),od=gd.cd,ltd=gd.ltd,pd=gd.gbx,channel=[1b,2b,2b],overlays=['planet_grid'],/new,vis=1


;-------------------------------------------------------------------------
;+
; Create composite images
; -----------------------
;
;   Combine the channels, as a grayscale ISS image, with a transparent color CIRS overlay::
;   
;     im0=image(dat_data(dd_map[0]),dimensions=[map_xsize,map_ysize],margin=0)
;     im1=image(dat_data(dd_map[1])>dat_data(dd_map[2]),/current,transparency=60,rgb_table=13)
;     
;   .. image:: graphics/cirs_ex1_4.png
;        
;   Now, combine using ISS as the intensity, CIRS as the hue for the image::  
;
;     s=dblarr(map_xsize,map_ysize) & l=s & h=s
;     s[*]=(dat_data(dd_map[1])) gt 0d0
;     l[*]=dat_data(dd_map[0])
;     h[*]=(dat_data(dd_map[1]))*240d0
;     color_convert,h,l,s,r,g,b,/hls_rgb
;     im2=image([[[r]],[[g]],[[b]]],dimensions=[map_xsize,map_ysize],margin=0)
;
;   .. image:: graphics/cirs_ex1_5.png
;
;-
;-------------------------------------------------------------------------


im0=image(dat_data(dd_map[0]),dimensions=[map_xsize,map_ysize],margin=0)
im1=image(dat_data(dd_map[1])>dat_data(dd_map[2]),/current,transparency=60,rgb_table=13)
;im1.save,'demo/cas_cirs_iss_example_1.png'
s=dblarr(map_xsize,map_ysize) & l=s & h=s
s[*]=(dat_data(dd_map[1])) gt 0d0
l[*]=dat_data(dd_map[0])
h[*]=(dat_data(dd_map[1]))*240d0
color_convert,h,l,s,r,g,b,/hls_rgb
im2=image([[[r]],[[g]],[[b]]],dimensions=[map_xsize,map_ysize],margin=0)
;im2.save,'demo/cas_cirs_iss_example_2.png'



end
