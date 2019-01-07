;===============================================================================
; grim_filter_apparent_size
;
;===============================================================================
pro grim_filter_apparent_size, bx, cd=cd

 rad = body_radius(bx)
 dist = v_mag(bod_pos(bx) - (bod_pos(cd))[linegen3z(1,3,n_elements(bx))])

 minpix = 1d-3
 w = where(rad/dist/min(cam_scale(cd)) GT minpix)
 if(w[0] EQ -1) then bx = 0 $
 else bx = bx[w]
 
end
;===============================================================================



;===============================================================================
; grim_compute_center
;
;===============================================================================
function grim_compute_center, map=map, clip=clip, hide=hide, $
                              gd=gd, bx=bx, ptd=ptd, $
                              data=data, $
                              npoints=npoints

 grim_message, /clear

 gbx = cor_select(bx, 'GLOBE', /class, exclude_name='SKY')
 if(NOT keyword_set(gbx)) then return, 0

 cd = cor_dereference_gd(gd, /cd)

 ;-------------------------------------------------------------
 ; filter out objects whose apparent sizes are too small
 ;-------------------------------------------------------------
 if(NOT map) then grim_filter_apparent_size, gbx, cd=cd
 if(NOT keyword_set(gbx)) then return, 0

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing centers...'
 center_ptd = pg_center(cd=cd, bx=gbx)
 grim_message

 grim_print, 'Done', /append
 return, center_ptd
end
;===============================================================================



;===============================================================================
; grim_symsize_center
;
;===============================================================================
function grim_symsize_center, data, ptd
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_center
;
;===============================================================================
function grim_shade_center, data, ptd
 return, 1.0
end
;===============================================================================



;===============================================================================
; grim_compute_limb
;
;===============================================================================
function grim_compute_limb, map=map, clip=clip, hide=hide, $
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 gbx = cor_select(bx, 'GLOBE', /class, exclude_name='SKY')
;; all_gbx = cor_select(cor_dereference_gd(gd), 'GLOBE', /class)
;; all_gbx = cor_dereference_gd(gd, 'GLOBE', /class)
 if(NOT keyword_set(gbx)) then return, 0

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
 rd = cor_dereference_gd(gd, /rd)
 pd = cor_dereference_gd(gd, /pd)
 ltd = (cor_dereference_gd(gd, /ltd))[0]

 ;-------------------------------------------------------------
 ; filter out objects whose apparent sizes are too small
 ;-------------------------------------------------------------
 if(NOT map) then grim_filter_apparent_size, gbx, cd=cd
 if(NOT keyword_set(gbx)) then return, 0
 if(map) then gbx = cor_select(gbx, cor_name(cd), /name)

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing limbs...'
 limb_ptd = pg_limb(cd=cd, gbx=gbx, od=od, clip=clip, npoints=npoints)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 pg_hide, limb_ptd, cd=cd, od=od, dkx=rd, gbx=gbx, hide_ptd, /dissoc, /cat
 grim_message

 pg_hide, limb_ptd, cd=cd, gbx=gbx, od=ltd, /assoc, hide_ptd_term, /cat
 pg_hide, hide_ptd_term, cd=cd, od=od, dkx=rd, gbx=gbx, /dissoc, /cat
 grim_message

 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = append_array(limb_ptd, hide_ptd_term)
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_limb
;
;===============================================================================
function grim_symsize_limb, data, ptd
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
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 pds = cor_select(bx, 'PLANET', /class)
 if(NOT keyword_set(pds)) then return, 0

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
 rd = cor_dereference_gd(gd, /rd)
 ltd = cor_dereference_gd(gd, /ltd)
 if(NOT keyword_set(ltd)) then return, 0

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing terminators...'
 for i=0, n_elements(ltd)-1 do $
  begin
   term_ptd = append_array(term_ptd, $
                 pg_limb(cd=cd, od=ltd[i], gbx=pds, clip=clip, npoints=npoints))
   grim_message
  end

 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then pg_hide, term_ptd, cd=cd, gbx=pds, dkx=rd, hide_ptd, /cat
 grim_message

 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = term_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_terminator
;
;===============================================================================
function grim_symsize_terminator, data, ptd
 return, -1
end
;===============================================================================



;===============================================================================
; grim_shade_terminator
;
;===============================================================================
function grim_shade_terminator, data, ptd

 n = n_elements(ptd)
 shade = make_array(n)

 names = cor_name(ptd)
 unames = unique(names)

 for i=0, n_elements(unames)-1 do $
  begin
   w = where(names EQ unames[i])
   nw = n_elements(w)
   shade[w] = (1d/(1+dindgen(nw)) * 0.75) + 0.25
  end

 return, shade
end
;===============================================================================



;=============================================================================
; grim_compute_planet_grid
;
;=============================================================================
function grim_compute_planet_grid, map=map, clip=clip, hide=hide, $
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 gbx = cor_select(bx, 'GLOBE', /class)
; if(NOT keyword_set(gbx)) then return, 0

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 ltd = (cor_dereference_gd(gd, /ltd))[0]

 ;-------------------------------------------------------------
 ; filter out objects whose apparent sizes are too small
 ;-------------------------------------------------------------
; if(NOT map) then if(NOT keyword_set(gbx)) then return, 0
 if(NOT map) then grim_filter_apparent_size, gbx, cd=cd
 if(map) then gbx = cor_select(gbx, cor_name(cd), /name)

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing planet grids...'
 grid_ptd = pg_grid(cd=cd, bx=gbx, clip=clip, npoints=npoints)
 grim_message

 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, grid_ptd, cd=cd, dkx=rd, od=od, gbx=pd, hide_ptd, /cat
   grim_message

   pg_hide, grid_ptd, cd=cd, gbx=gbx, od=ltd, /assoc, hide_ptd_term, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = append_array(grid_ptd, hide_ptd_term)
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;=============================================================================



;===============================================================================
; grim_symsize_planet_grid
;
;===============================================================================
function grim_symsize_planet_grid, data, ptd
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
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, npoints=npoints

 grim_message, /clear

 ;--------------------------------------------------------
 ; determine primary
 ;--------------------------------------------------------
 if(NOT map) then $
  begin
   pds = cor_select(bx, 'PLANET', /class)
   if(NOT keyword_set(pds)) then return, 0
   bx0 = pds
  end


 stds = cor_dereference_gd(gd, /std)
 if(NOT keyword_set(stds)) then return, 0

 if(keyword_set(bx0)) then $
  begin
   for i=0, n_elements(stds)-1 do $
     if((where(cor_name(get_primary(stds[i])) EQ cor_name(bx0)))[0] NE -1) then select = append_array(select, i, /def)
   stds = stds[select]
  end
 nstd = n_elements(stds)

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing stations...'
 station_ptd = pg_station(cd=cd, std=stds, bx=bx0, clip=clip)
 grim_message


 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, station_ptd, cd=cd, gbx=bx0, dkx=rd, hide_ptd, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = station_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;=============================================================================



;===============================================================================
; grim_symsize_station
;
;===============================================================================
function grim_symsize_station, data, ptd
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
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 ;--------------------------------------------------------
 ; determine primary
 ;--------------------------------------------------------
 if(NOT map) then $
  begin
   pds = cor_select(bx, 'PLANET', /class)
   if(NOT keyword_set(pds)) then return, 0
   bx0 = pds
  end

 ards = cor_dereference_gd(gd, /ard)
 if(NOT keyword_set(ards)) then return, 0

 if(keyword_set(bx0)) then $
  begin
   for i=0, n_elements(ards)-1 do $
     if((where(cor_name(get_primary(ards[i])) EQ cor_name(bx0)))[0] NE -1) then select = append_array(select, i, /def)
   ards = ards[select]
  end
 nard = n_elements(ards)

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing planet arrays...'
 array_ptd = pg_array(cd=cd, ard=ards, bx=bx0, clip=clip)
 grim_message


 ;--------------------------------
 ; hide points
 ;--------------------------------
 if(NOT map) then $
  begin
   pg_hide, array_ptd, cd=cd, gbx=bx0, dkx=rd, hide_ptd, /cat
   grim_message
  end
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = array_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;=============================================================================



;===============================================================================
; grim_symsize_array
;
;===============================================================================
function grim_symsize_array, data, ptd
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
                            gd=gd, bx=bx, ptd=ptd, $
                            data=data, $
                            npoints=npoints

 grim_message, /clear

 sds = cor_dereference_gd(gd, /sd)
 nsd = n_elements(sds)

 cd = cor_dereference_gd(gd, /cd)
 od = cor_dereference_gd(gd, /od)
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
 
; *_data.name_p = cor_name(sds)
; *_data.mag_p = str_get_mag(sds, od=cd)
; data = _data


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = star_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_star
;
;===============================================================================
function grim_symsize_star, data, ptd
 mmax = 16d & mmin = 1d
 smax = 1d & smin = 0.1d

 sd = pnt_assoc_xd(ptd)
 gd = cor_gd(ptd)
 od = (gd.cd)[0]
 mags = str_get_mag(sd, od=od) < mmax > mmin

 norm = (mmax - mags)/(mmax-mmin)

; return, norm*(smax-smin) + smin

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

 sd = pnt_assoc_xd(ptd)
 gd = cor_gd(ptd)
 od = (gd.cd)[0]
 mags = str_get_mag(sd, od=od) < mmax > mmin

 norm = (mmax - mags)/(mmax-mmin)

; return, norm*(smax-smin) + smin

 max = max(mags) + 2
 return, (max - mags) / max
end
;===============================================================================



;===============================================================================
; grim_compute_shadow
;
;===============================================================================
function grim_compute_shadow, map=map, clip=clip, hide=hide, $
                     gd=gd, bx=bx, ptd=ptd, $
                     data=data, $
                     npoints=npoints

 if(map) then return, 0
 if(NOT keyword__set(ptd)) then return, 0

 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 ltd = cor_dereference_gd(gd, /ltd)
 if(NOT keyword_set(ltd)) then return, 0


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing shadows...'
 for i=0, n_elements(ltd)-1 do $
  begin
   shadow_ptd = append_array(shadow_ptd, $
                   pg_shadow(ptd, epsilon=1d, /nocull, $
                                 cd=cd, od=ltd[i], dkx=rd, gbx=pd, clip=clip))
   grim_message
  end

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
 result = shadow_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)
;stop

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_shadow
;
;===============================================================================
function grim_symsize_shadow, data, ptd
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
                     gd=gd, bx=bx, ptd=ptd, $
                     data=data, $
                     npoints=npoints

 if(map) then return, 0
 if(NOT keyword__set(ptd)) then return, 0
 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 ltd = cor_dereference_gd(gd, /ltd)

 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing reflections...'
 for i=0, n_elements(ltd)-1 do $
  begin
   reflection_ptd = append_array(reflection_ptd, $
                          pg_reflection(ptd, /nocull, $
                                  cd=cd, od=ltd[i], dkx=rd, gbx=pd, clip=clip))
   grim_message
  end

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
 result = reflection_ptd
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_reflection
;
;===============================================================================
function grim_symsize_reflection, data, ptd
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
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 ltd = (cor_dereference_gd(gd, /ltd))[0]


 ;--------------------------------------------------------
 ; if no active planet, then try to determine primary
 ;--------------------------------------------------------
; pds = cor_select(bx, 'PLANET', /class)
; if(NOT keyword_set(pds)) then return, 0
; pd = (get_primary(cd, pds))[0]
; if(NOT keyword_set(pds)) then return, 0
; pd = pds

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

 pg_hide, ring_ptd, cd=cd, od=ltd, bx=pd, hide_ptd_shad, /cat
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = append_array(ring_ptd, hide_ptd_shad)
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_ring
;
;===============================================================================
function grim_symsize_ring, data, ptd
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
                             gd=gd, bx=bx, ptd=ptd, $
                             data=data, $
                             npoints=npoints

 grim_message, /clear

 ;--------------------------------------------------------
 ; if no active planet, then try to determine primary
 ;--------------------------------------------------------
 rds = cor_select(bx, 'RING', /class)
 if(NOT keyword_set(rds)) then return, 0

 nrd = n_elements(rds)

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 ltd = (cor_dereference_gd(gd, /ltd))[0]


 ;--------------------------------
 ; compute points
 ;--------------------------------
 grim_print, 'Computing ring grids...'
 grid_ptd = pg_grid(cd=cd, bx=rds, clip=clip, npoints=npoints)
 grim_message

 pg_hide, grid_ptd, cd=cd, gbx=pd, hide_ptd, /cat
 grim_message

 pg_hide, grid_ptd, cd=cd, od=ltd, gbx=pd, hide_ptd_shad, /cat
 grim_message


 ;-------------------------------------
 ; set up output points
 ;-------------------------------------
 result = append_array(grid_ptd, hide_ptd_shad)
 if(NOT hide) then result = append_array(result, hide_ptd)

 grim_print, 'Done', /append
 return, result
end
;===============================================================================



;===============================================================================
; grim_symsize_ring_grid
;
;===============================================================================
function grim_symsize_ring_grid, data, ptd
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








