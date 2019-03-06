;=======================================================================
;                            MAP-GLOBE_EXAMPLE.PRO
;
;  Created by Joe Spitale
;
;  This example demonstrates various map projections on a globe 
;  using Cassini images and kernels that area not provided in the 
;  distribution.
;
;=======================================================================
!quiet = 1

;-------------------------------
; load image
;-------------------------------
file = './data/N1460002670_1.IMG'
dd = dat_read(file, im)
ctmod
tvim, im, zoom=0.5, /order, /new


;---------------------------------------
; get geometric info 
;---------------------------------------
cd = pg_get_cameras(dd)					
pd = pg_get_planets(dd, od=cd, name='SATURN')
rd = pg_get_rings(dd, pd=pd, od=cd, '/system')
ltd = pg_get_stars(dd, od=cd, name='SUN')

gd = {cd:cd, gbx:pd, dkx:rd, ltd:ltd}


;---------------------------------------
; rough pointing correction
;---------------------------------------
limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=ltd
pg_draw, limb_ptd, col=ctred()

edge_ptd = pg_edges(dd, edge=10)			
pg_draw, edge_ptd, col=ctblue()
dxy = pg_farfit(dd, edge_ptd, [limb_ptd])	
					 	
pg_repoint, dxy, 0d, gd=gd	

limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=ltd
tvim, im
pg_draw, limb_ptd


;------------------------------------------------------
; generate map projections
;------------------------------------------------------

;- - - - - - - - - -
; RECTANGULAR
;- - - - - - - - - -
md1 = pg_get_maps(/over, bx=pd, $
	projection='RECTANGULAR', $
	/graphic,  $
	size=[400,200] $
	)
dd_map1 = pg_map(dd, md=md1, gd=gd, bx=pd, map=map1, $
                             hide_fn='pm_hide_ring', hide_bx=rd)
tvim, /new, map1, title=map_projection(md1) + ' PROJECTION'



;- - - - - - - - - -
; ORTHOGRAPHIC
;- - - - - - - - - -
md2 = pg_get_maps(/over, bx=pd, $
	projection='ORTHOGRAPHIC', $
	fn_data=ptr_new(), $
	size=[400,400], $
	center=[-!dpi/6d,0d] $
	)
dd_map2 = pg_map(dd, md=md2, gd=gd, bx=pd, map=map2, $
                              hide_fn='pm_hide_ring', hide_bx=rd)
tvim, /new, map2, title=map_projection(md2) + ' PROJECTION'


;- - - - - - - - - -
; STEREOGRAPHIC
;- - - - - - - - - -
md3 = pg_get_maps(/over, bx=pd, $
	projection='STEREOGRAPHIC', $
	fn_data=ptr_new(), $
	scale=0.5, $
	size=[400,400], $
	center=[!dpi/2d,0d] $
	)
dd_map3 = pg_map(dd, md=md3, gd=gd, bx=pd, map=map3, $
                           hide_fn='pm_hide_ring', hide_bx=rd)
tvim, /new, map3, title=map_projection(md3) + ' PROJECTION'


;- - - - - - - - - -
; MERCATOR
;- - - - - - - - - -
md4 = pg_get_maps(/over, bx=pd, $
	projection='MERCATOR', $  
	fn_data=ptr_new(), $
	size=[400,200] $
	)
dd_map4 = pg_map(dd, md=md4, gd=gd, bx=pd, map=map4, $
                            hide_fn='pm_hide_ring', hide_bx=rd)
tvim, /new, map4, title=map_projection(md4) + ' PROJECTION'



;------------------------------------------------
; transform from one projection to another
;------------------------------------------------
_md1 = pg_get_maps(/over, bx=pd, $
	projection='ORTHOGRAPHIC', $
	fn_data=ptr_new(), $
	size=[400,400], $
	center=[-!dpi/8d,0d] $
	)

_dd_map1 = pg_map(dd_map1, md=_md1, cd=md1, map=_map1)
tvim, /new, _map1, title=map_projection(md1) + ' TO ' + map_projection(_md1) + ' PROJECTION'



;------------------------------------------------------------------
; Project a previous projection to a different camera perspective
;------------------------------------------------------------------
_cd = nv_clone(cd)

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Set camera position in terms of sclat, sclon, and altitude in 
; planetary radii
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pos_surf = tr([-30d	* !dpi/180d, $			; sclat
               0d	* !dpi/180d, $			; sclon
               500d 	* (glb_radii(pd))[0]])		; altitude
pos = bod_body_to_inertial_pos(pd, $
        glb_globe_to_body(pd, pos_surf))
bod_set_pos, _cd, pos


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Point camera back at planet
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
zzz = tr([0d,0d,1d])					; Inertial z axis
yy = v_unit(bod_pos(pd)-pos) 				; Optic axis
xx = v_unit(v_cross(yy, zzz)) 				; Focal plane axes
zz = v_unit(v_cross(xx,yy)) 
bod_set_orient, _cd, [xx,yy,zz] 


_dd = pg_map(dd_map1, md=_cd, cd=md1, gbx=pd, map=_im)
tvim, /new, z=0.5, _im, title=map_projection(md1) + ' TO CAMERA PROJECTION'


;--------------------------------------------------------------------
; Project from the original image to a different camera perspective
;--------------------------------------------------------------------
_dd = pg_map(dd, md=_cd, cd=cd, gbx=pd, map=_im)
tvim, /new, z=0.5, _im, title='CAMERA TO CAMERA PROJECTION'


;stop
;--------------------------------------------------------------------
; Write a map and map descriptor.  Note that in the default
; confguration, the map will be written as a vicar file and the 
; descriptor information will be written as a detached header.
;--------------------------------------------------------------------
pg_put_maps, dd_map1, md=md1			; create detached header on dd_map1
pg_put_cameras, dd_map1, cd=cd
;pg_put_planets, dd_map1, od=cd, pd=pd
;pg_put_rings, dd_map1, od=cd, pd=pd
dat_write, './outputs/globe-1.map', dd_map1		; write data file, and detached header










dd_map = dat_read('./outputs/globe-1.map')
md = pg_get_maps(dd_map)

grid_ptd = pg_grid(cd=md, gbx=pd)
limb_ptd = pg_limb(cd=md, od=cd, gbx=pd)

