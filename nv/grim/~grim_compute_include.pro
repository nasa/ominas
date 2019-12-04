;===============================================================================
; grim_compute_planet_center
;
;===============================================================================
function grim_compute_planet_center, map=map, clip=clip, hide=hide, $
                              gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                              data=data, $
                              npoints=npoints

 grim_message, /clear

 pds = cor_select(active_xds, 'PLANET', /class)
 if(NOT keyword_set(pds)) then pds = cor_dereference_gd(gd, /pd)

 cd = cor_dereference_gd(gd, /cd)

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing planet centers...'
 center_ptd = pg_center(cd=cd, bx=pds)
 grim_message

 grim_print, 'Done', /append
 return, center_ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_planet_center
;
;===============================================================================
function grim_symsize_planet_center, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_planet_center
;
;===============================================================================
function grim_shade_planet_center, data, ptd
 return, 1.0
end
;===============================================================================



;===============================================================================
; grim_compute_limb
;
;===============================================================================
function grim_compute_limb, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 od = cor_dereference_gd(gd, /od)
 grim_message, /clear

 pds = cor_select(active_xds, 'GLOBE', /class)
 if(NOT keyword_set(pds)) then pds = cor_dereference_gd(gd, /pd)
 npd = n_elements(pds)

 cd = cor_dereference_gd(gd, /cd)
 rd = cor_dereference_gd(gd, /rd)
 pd = cor_dereference_gd(gd, /pd)
 sund = cor_dereference_gd(gd, name='SUN')


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing limbs...'
 limb_ptd = pg_limb(cd=cd, gbx=pds, od=od, clip=clip, npoints=npoints)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 pg_hide, limb_ptd, cd=cd, od=od, dkx=rd, gbx=pd, hide_ptd, /cat
 grim_message

 if(keyword_set(sund)) then $
 pg_hide, limb_ptd, cd=cd, gbx=pds, od=sund, /assoc, hide_ptd_term, /cat
; pg_hide, hide_ptd_term, cd=cd, od=od, gbx=pds, od=sund, /assoc, hide_ptd_term, /cat
 grim_message

 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = append_array(limb_ptd, hide_ptd_term)
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_limb
;
;===============================================================================
function grim_symsize_limb, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_limb
;
;===============================================================================
function grim_shade_limb, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)
 ww = where(strpos(desc, 'HIDE_RING') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.5
 if(ww[0] NE -1) then shade[ww] = 0.1

 return, shade
end
;===============================================================================



;===============================================================================
; grim_compute_terminator
;
;===============================================================================
function grim_compute_terminator, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 sund = cor_dereference_gd(gd, name='SUN')
 if(NOT keyword_set(sund)) then return, 0

 grim_message, /clear

 pds = cor_select(active_xds, 'PLANET', /class)
 if(NOT keyword_set(pds)) then pds = cor_dereference_gd(gd, /pd)
 npd = n_elements(pds)

 cd = cor_dereference_gd(gd, /cd)
 sund = cor_dereference_gd(gd, name='SUN')
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing terminators...'
 term_ptd = pg_limb(cd=cd, od=sund, gbx=pds, clip=clip, npoints=npoints)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then pg_hide, term_ptd, cd=cd, gbx=pds, dkx=rd, hide_ptd, /cat
 grim_message

 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = term_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_terminator
;
;===============================================================================
function grim_symsize_terminator, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_terminator
;
;===============================================================================
function grim_shade_terminator, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)
 ww = where(strpos(desc, 'HIDE_RING') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.25
 if(ww[0] NE -1) then shade[ww] = 0.5

 return, shade
end
;===============================================================================



;=============================================================================
; grim_compute_planet_grid
;
;=============================================================================
function grim_compute_planet_grid, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 od = cor_dereference_gd(gd, /od)
 grim_message, /clear

 pds = cor_select(active_xds, 'GLOBE', /class)
 if(NOT keyword_set(pds)) then pds = cor_dereference_gd(gd, /pd)
 npd = n_elements(pds)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 sund = cor_dereference_gd(gd, name='SUN')


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing planet grids...'
 grid_ptd = pg_grid(cd=cd, bx=pds, clip=clip, npoints=npoints)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, grid_ptd, cd=cd, dkx=rd, od=od, gbx=pd, hide_ptd, /cat
   grim_message

   pg_hide, grid_ptd, cd=cd, gbx=pds, od=sund, /assoc, hide_ptd_term, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = append_array(grid_ptd, hide_ptd_term)
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;=============================================================================



;===============================================================================
; grim_symsize_planet_grid
;
;===============================================================================
function grim_symsize_planet_grid, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_planet_grid
;
;===============================================================================
function grim_shade_planet_grid, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)
 ww = where(strpos(desc, 'HIDE_RING') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.5
 if(ww[0] NE -1) then shade[ww] = 0.1

 return, shade
end
;===============================================================================



;=============================================================================
; grim_compute_station
;
;=============================================================================
function grim_compute_station, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, npoints=npoints

 od = cor_dereference_gd(gd, /od)
 grim_message, /clear

 ;--------------------------------------------------------
 ; determine primary
 ;--------------------------------------------------------
 if(NOT map) then $
  begin
   pds = cor_select(active_xds, 'PLANET', /class)
   if(NOT keyword_set(pds)) then bx = cor_dereference_gd(gd, /pd) $
   else bx = pds
  end


 stds = cor_dereference_gd(gd, /std)
 if(NOT keyword_set(stds)) then return, 0

 if(keyword_set(bx)) then $
  begin
   for i=0, n_elements(stds)-1 do $
     if((where(cor_name(get_primary(stds[i])) EQ cor_name(bx)))[0] NE -1) then select = append_array(select, i, /def)
   stds = stds[select]
  end
 nstd = n_elements(stds)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing stations...'
 station_ptd = pg_station(cd=cd, std=stds, bx=bx, clip=clip)
 grim_message


 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, station_ptd, cd=cd, gbx=bx, dkx=rd, hide_ptd, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = station_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;=============================================================================



;===============================================================================
; grim_symsize_station
;
;===============================================================================
function grim_symsize_station, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_station
;
;===============================================================================
function grim_shade_station, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)
 ww = where(strpos(desc, 'HIDE_RING') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.25
 if(ww[0] NE -1) then shade[ww] = 0.1

 return, shade
end
;===============================================================================



;=============================================================================
; grim_compute_array
;
;=============================================================================
function grim_compute_array, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 od = cor_dereference_gd(gd, /od)
 grim_message, /clear

 ;--------------------------------------------------------
 ; determine primary
 ;--------------------------------------------------------
 if(NOT map) then $
  begin
   pds = cor_select(active_xds, 'PLANET', /class)
   if(NOT keyword_set(pds)) then bx = cor_dereference_gd(gd, /pd) $
   else bx = pds
  end

 ards = cor_dereference_gd(gd, /ard)
 if(NOT keyword_set(ards)) then return, 0

 if(keyword_set(bx)) then $
  begin
   for i=0, n_elements(ards)-1 do $
     if((where(cor_name(get_primary(ards[i])) EQ cor_name(bx)))[0] NE -1) then select = append_array(select, i, /def)
   ards = ards[select]
  end
 nard = n_elements(ards)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing planet arrays...'
 array_ptd = pg_array(cd=cd, ard=ards, bx=bx, clip=clip)
 grim_message


 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, array_ptd, cd=cd, gbx=bx, dkx=rd, hide_ptd, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = array_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;=============================================================================



;===============================================================================
; grim_symsize_array
;
;===============================================================================
function grim_symsize_array, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_array
;
;===============================================================================
function grim_shade_array, data, ptd
 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)
 ww = where(strpos(desc, 'HIDE_RING') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.25
 if(ww[0] NE -1) then shade[ww] = 0.1

 return, shade
end
;===============================================================================



;===============================================================================
; grim_compute_star
;
;===============================================================================
function grim_compute_star, map=map, clip=clip, hide=hide, $
                            gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                            data=data, $
                            npoints=npoints

 grim_message, /clear

 sds = cor_dereference_gd(gd, /sd)
 nsd = n_elements(sds)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 if(NOT keyword_set(sds)) then return, 0
 grim_print, 'Computing stars...'
 star_ptd = pg_center(cd=cd, bx=sds, clip=clip)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 pg_hide, star_ptd, cd=cd, gbx=pd, dkx=rd, hide_ptd, /cat
 grim_message


 ;--------------------------------
 ; store some data
 ;--------------------------------
 if(keyword_set(data)) then _data = data $
 else _data = {__str_data, name_p:ptr_new(0), mag_p:ptr_new(0)}
 
 *_data.name_p = cor_name(sds)
 *_data.mag_p = str_get_mag(sds)
 data = _data


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = star_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_star
;
;===============================================================================
function grim_symsize_star, data
 mmax = 16d & mmin = 1d
 smax = 1d & smin = 0.1d

 mags = *data.mag_p < mmax > mmin
 norm = (mmax - mags)/(mmax-mmin)

 return, norm*(smax-smin) + smin

 max = max(mags) + 2
 return, (max - mags) / max
end
;===============================================================================



;===============================================================================
; grim_shade_star
;
;===============================================================================
function grim_shade_star, data, ptd
 mmax = 16d & mmin = 1d
 smax = 1d & smin = 0.25

 mags = *data.mag_p < mmax > mmin
 norm = (mmax - mags)/(mmax-mmin)

 return, norm*(smax-smin) + smin

 max = max(mags) + 2
 return, (max - mags) / max
end
;===============================================================================



;===============================================================================
; grim_compute_shadow
;
;===============================================================================
function grim_compute_shadow, map=map, clip=clip, hide=hide, $
                     gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                     data=data, $
                     npoints=npoints

 if(map) then return, 0
 if(NOT keyword__set(active_ptd)) then return, 0

 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 sund = cor_dereference_gd(gd, name='SUN')


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing shadows...'
 shadow_ptd = pg_shadow(active_ptd, epsilon=1d, /nocull, $
                                 cd=cd, od=sund, dkx=rd, gbx=pd, clip=clip)
 nshad = n_elements(shadow_ptd)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 pg_hide, shadow_ptd, cd=cd, gbx=pd, dkx=rd, hide_ptd, /cat
 grim_message

 ;-------------------------------------------------------------------
 ; note we don't care about dimensions because shadows are not
 ; associated with any objects and they are replaced each time
 ; they are recomputed
 ;-------------------------------------------------------------------
 ptd = shadow_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_shadow
;
;===============================================================================
function grim_symsize_shadow, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_shadow
;
;===============================================================================
function grim_shade_shadow, data, ptd
 return, 1.0
end
;===============================================================================



;===============================================================================
; grim_compute_reflection
;
;===============================================================================
function grim_compute_reflection, map=map, clip=clip, hide=hide, $
                     gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                     data=data, $
                     npoints=npoints

 if(map) then return, 0
 if(NOT keyword__set(active_ptd)) then return, 0
 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 sund = cor_dereference_gd(gd, name='SUN')

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing reflections...'
 reflection_ptd = pg_reflection(active_ptd, /nocull, $
                         cd=cd, od=sund, dkx=rd, gbx=pd, clip=clip)
 nref = n_elements(reflection_ptd)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 pg_hide, reflection_ptd, cd=cd, gbx=pd, dkx=rd, hide_ptd, /cat
 grim_message

 ;-------------------------------------------------------------------
 ; note we don't care about dimensions because reflections are not
 ; associated with any objects and they are replaced each time
 ; they are recomputed
 ;-------------------------------------------------------------------
 ptd = reflection_ptd
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_reflection
;
;===============================================================================
function grim_symsize_reflection, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_reflection
;
;===============================================================================
function grim_shade_reflection, data, ptd
 return, 1.0
end
;===============================================================================



;===============================================================================
; grim_compute_ring
;
;===============================================================================
function grim_compute_ring, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 sund = cor_dereference_gd(gd, name='SUN')


 ;--------------------------------------------------------
 ; if no active planet, then try to determine primary
 ;--------------------------------------------------------
; pds = cor_select(active_xds, 'PLANET', /class)
; if(NOT keyword_set(pds)) then pd = get_primary(cd, pd) $
; else pd = (get_primary(cd, pds))[0]
; if(NOT keyword_set(pds)) then pd = cor_dereference_gd(gd, /pd) $
; else pd = pds

 rds = cor_dereference_gd(gd, /rd)
 nrd = n_elements(rds)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing rings...'
 ring_ptd = pg_disk(cd=cd, dkx=rds, clip=clip, npoints=npoints)
 grim_message

 pg_hide, ring_ptd, cd=cd, bx=pd, hide_ptd, /cat
 grim_message

 pg_hide, ring_ptd, cd=cd, od=sund, bx=pd, hide_ptd_shad, /cat
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = append_array(ring_ptd, hide_ptd_shad)
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_ring
;
;===============================================================================
function grim_symsize_ring, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_ring
;
;===============================================================================
function grim_shade_ring, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.5

 return, shade
end
;===============================================================================



;===============================================================================
; grim_compute_ring_grid
;
;===============================================================================
function grim_compute_ring_grid, map=map, clip=clip, hide=hide, $
                             gd=gd, active_xds=active_xds, active_ptd=active_ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 ;--------------------------------------------------------
 ; if no active planet, then try to determine primary
 ;--------------------------------------------------------
 rds = cor_select(active_xds, 'RING', /class)
 if(NOT keyword_set(rds)) then rds = cor_dereference_gd(gd, /rd)
 if(NOT keyword_set(rds)) then return, 0

 nrd = n_elements(rds)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 sund = cor_dereference_gd(gd, name='SUN')


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing ring grids...'
 grid_ptd = pg_grid(cd=cd, bx=rds, clip=clip, npoints=npoints)
 grim_message

 pg_hide, grid_ptd, cd=cd, gbx=pd, hide_ptd, /cat
 grim_message

 pg_hide, grid_ptd, cd=cd, od=sund, gbx=pd, hide_ptd_shad, /cat
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 ptd = append_array(grid_ptd, hide_ptd_shad)
 if(NOT hide) then ptd = append_array(ptd, hide_ptd)

 grim_print, 'Done', /append
 return, ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_ring_grid
;
;===============================================================================
function grim_symsize_ring_grid, data
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_ring_grid
;
;===============================================================================
function grim_shade_ring_grid, data, ptd

 desc = pnt_desc(ptd)
 nptd = n_elements(ptd)

 w = where(strpos(desc, 'HIDE_PLANET') NE -1)

 shade = make_array(nptd, val=1.0)
 if(w[0] NE -1) then shade[w] = 0.5

 return, shade
end
;===============================================================================

pro grim_compute_include
a=!null
end








