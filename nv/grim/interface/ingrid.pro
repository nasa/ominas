;=============================================================================
;+
; NAME:
;	INGRID
;
;
; PURPOSE:
;	INterface to GRIm Data -- command-line access to GRIM data.
;	The returned descriptors allow direct access to the memory images of
;	GRIM's descriptor set.  Therefore changes made from the command line
;	affect the descriptors that GRIM is using.  GRIM monitors those 
;	descriptors and updates itself whenever a change occurs.  
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	ingrid, arg, <xd>=<xd>
;
;
; ARGUMENTS:
;  INPUT:
;	arg:	GRIM window number or GRIM data struture.  If not given, the 
;		most recently accessed grim instance is used.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	plane:	Grim plane structure(s) instead of giving pn.  Note all planes
;		must belong to the same grim instance.
;
;	pn:	Plane numer(s) to access.  If not given, then current plane
;		is used.
;
;	all:	If set, all planes are used.
;
;  OUTPUT:
;	dd:	GRIM's data descriptor.
;
;	cd:	GRIM's camera descriptor.
;
;	od:	GRIM's observer descriptor.
;
;	sund:	GRIM's sun descriptor.
;
;	pd:	GRIM's planet descriptors.
;
;	rd:	GRIM's ring descriptors.
;
;	sd:	GRIM's star descriptors.
;
;	std:	GRIM's station descriptors.
;
;	ard:	GRIM's array descriptors.
;
;	gd:	Generic descriptor containing all of the above descriptors. 
;
;	center_ptd:
;		POINT object giving the planet centers.
;
;	limb_ptd:
;		POINT object giving the limb points.
;
;	ring_ptd:
;		POINT object giving the ring points.
;
;	star_ptd:
;		POINT object giving the star points.
;
;	term_ptd:
;		POINT object giving the terminator points.
;
;	station_ptd:
;		POINT object giving the station points.
;
;	array_ptd:
;		POINT object giving the array points.
;
;	plgrid_ptd:
;		POINT object giving the planet grid points.
;
;	shadow_ptd:
;		POINT object giving the shadow points.
;
;	object_ptd:
;		POINT object giving all overlay points.
;
;	tie_ptd:
;		POINT object giving the tie points.
;
;	curve_ptd:
;		POINT object giving the curve points.
;
;	active_*_ptd:
;		Returns same as above ptd outputs, except ony active arrays
;		are returned.
;
;
; EXAMPLE:
;	(1) Open a GRIM window, load an image, and compute limb points.
;
;	(2) At the command line, type:
;
;		IDL> ingrid, cd=cd
;		IDL> pg_repoint, [50,50], 0d, cd=cd
;
;	GRIM should detect the change to the camera descriptor and update
;	itself by recomputing the limb points and refreshing the display.
;
;
; KNOWN ISSUES:
;	This procedure has unresolved issues, is unreliable, behaves 
;	irrationally, is overly complicated, and has periodic breakdowns for 
;	no externally apparent reason.
;
;
; STATUS:
;	Has unresolved issues that need to be confronted and addressed.
;
;
; SEE ALSO:
;	grim, gr_draw
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro ingrid, arg, plane=planes, gd=_gd, $
         dd=_dd, cd=_cd, pd=_pd, rd=_rd, sd=_sd, std=_std, ard=_ard, sund=_sund, od=_od, $
         limb_ptd=_limb_ptd, ring_ptd=_ring_ptd, star_ptd=_star_ptd, station_ptd=_station_ptd, array_ptd=_array_ptd, term_ptd=_term_ptd, $
         plgrid_ptd=_plgrid_ptd, center_ptd=_center_ptd, object_ptd=_object_ptd, $
         tie_ptd=_tie_ptd, curve_ptd=_curve_ptd, shadow_ptd=_shadow_ptd, reflection_ptd=_reflection_ptd, pn=pn, all=all, grnum=_grnum, $
         active_pd=_active_pd, active_rd=_active_rd, active_sd=_active_sd, $
         active_std=_active_std, active_ard=_active_ard, active_xd=_active_xd, $
         active_limb_ptd=_active_limb_ptd, active_ring_ptd=_active_ring_ptd, $
         active_star_ptd=_active_star_ptd, active_term_ptd=_active_term_ptd, $
         active_plgrid_ptd=_active_plgrid_ptd, active_center_ptd=_active_center_ptd, $
         active_shadow_ptd=_active_shadow_ptd, active_reflection_ptd=_active_reflection_ptd, active_station_ptd=_active_station_ptd, $
         active_array_ptd=_active_array_ptd


 active = keyword_set(active)	; Looks like I was going to simplify this by 
				; having a /active keyword instead of a million
				; repeated keywords with "active_" in front
				; of their names.  That would be simpler.

 arg_type = size(arg, /type)
 if(arg_type EQ 8) then grim_data = arg $
 else if(arg_type NE 0) then grnum = arg

 if(defined(grnum)) then $
                     grim_data = grim_get_data(grim_grnum_to_top(grnum)) $
 else grim_data = grim_get_data(/primary)

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(planes[0])

 _grnum = grim_data.grnum

 
 if(NOT keyword_set(planes)) then $
  begin
   if(keyword_set(all)) then planes = grim_get_plane(grim_data, /all) $
   else planes = grim_get_plane(grim_data)
  end
 nplanes = n_elements(planes)


 for i=0, nplanes-1 do $
  begin
   plane = planes[i]
   if(arg_present(_dd)) then dd = append_array(dd, plane.dd)

   if(arg_present(_cd)) then cd = append_array(cd, *plane.cd_p)
   if(arg_present(_pd)) then pd = append_array(pd, tr(*plane.pd_p))
   if(arg_present(_rd)) then rd = append_array(rd, tr(*plane.rd_p))
   if(arg_present(_sd)) then sd = append_array(sd, tr(*plane.sd_p))
   if(arg_present(_std)) then std = append_array(std, tr(*plane.std_p))
   if(arg_present(_ard)) then ard = append_array(ard, tr(*plane.ard_p))
   if(arg_present(_sund)) then sund = append_array(sund, *plane.sund_p)
   if(arg_present(_od)) then od = append_array(od, *plane.od_p)

   if(arg_present(_active_pd)) then $
      active_pd = append_array(active_pd, grim_get_active_xds(plane, 'planet'))
   if(arg_present(_active_rd)) then $
      active_rd = append_array(active_rd, grim_get_active_xds(plane, 'ring'))
   if(arg_present(_active_sd)) then $
      active_sd = append_array(active_sd, grim_get_active_xds(plane, 'star'))
   if(arg_present(_active_std)) then $
      active_std = append_array(active_std, grim_get_active_xds(plane, 'station'))
   if(arg_present(_active_ard)) then $
      active_ard = append_array(active_ard, grim_get_active_xds(plane, 'station'))

   if(arg_present(_active_limb_ptd)) then $
      _active_limb_ptd = append_array(active_limb_ptd, $
   			grim_get_active_overlays(grim_data, 'limb'))
   if(arg_present(_active_ring_ptd)) then $
      _active_ring_ptd = append_array(active_ring_ptd, $
   			grim_get_active_overlays(grim_data, 'ring'))
   if(arg_present(_active_star_ptd)) then $
      _active_star_ptd = append_array(active_star_ptd, $
   			grim_get_active_overlays(grim_data, 'star'))
   if(arg_present(_active_term_ptd)) then $
      _active_term_ptd = append_array(active_term_ptd, $
   			grim_get_active_overlays(grim_data, 'terminator'))
   if(arg_present(_active_plgrid_ptd)) then $
      _active_plgrid_ptd = append_array(active_plgrid_ptd, $
   			grim_get_active_overlays(grim_data, 'planet_grid'))
   if(arg_present(_active_center_ptd)) then $
      _active_center_ptd = append_array(active_center_ptd, $
   			grim_get_active_overlays(grim_data, 'planet_center'))
   if(arg_present(_active_shadow_ptd)) then $
      _active_shadow_ptd = append_array(active_shadow_ptd, $
   			grim_get_active_overlays(grim_data, 'shadow'))
   if(arg_present(_active_reflection_ptd)) then $
      _active_reflection_ptd = append_array(active_reflection_ptd, $
   			grim_get_active_overlays(grim_data, 'reflection'))
   if(arg_present(_active_station_ptd)) then $
      _active_station_ptd = append_array(active_station_ptd, $
   			grim_get_active_overlays(grim_data, 'station'))
   if(arg_present(_active_array_ptd)) then $
      _active_array_ptd = append_array(active_array_ptd, $
   			grim_get_active_overlays(grim_data, 'array'))

   if(arg_present(_active_xd)) then $
   		  active_xd = append_array(active_xd, *plane.active_xd_p)

   if(arg_present(_limb_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'limb'))) then $
   		limb_ptd = append_array(limb_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'limb')))
   if(arg_present(_ring_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'ring'))) then $
   		ring_ptd = append_array(ring_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'ring')))
   if(arg_present(_star_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'star'))) then $
   		star_ptd = append_array(star_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'star'))) 
   if(arg_present(_term_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'terminator'))) then $
   		term_ptd = append_array(term_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'terminator'))) 
   if(arg_present(_plgrid_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_grid'))) then $
   		plgrid_ptd = append_array(plgrid_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_grid'))) 
   if(arg_present(_center_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_center'))) then $
   		center_ptd = append_array(center_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_center'))) 
   if(arg_present(_shadow_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'shadow'))) then $
   		shadow_ptd = append_array(shadow_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'shadow'))) 
   if(arg_present(_reflection_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'reflection'))) then $
   		reflection_ptd = append_array(reflection_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'reflection'))) 
   if(arg_present(_object_ptd)) then $
      object_ptd = append_array(object_ptd, grim_cat_points(grim_data))
   if(arg_present(_station_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'station'))) then $
   		station_ptd = append_array(station_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'station'))) 
   if(arg_present(_array_ptd)) then $
    if(ptr_valid(grim_get_overlay_ptdp(grim_data, plane=plane, 'array'))) then $
   		array_ptd = append_array(array_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'array'))) 

   if(arg_present(_tie_ptd)) then $
   		  tie_ptd = append_array(tie_ptd, *plane.tiepoint_ptdp)

   if(arg_present(_curve_ptd)) then $
   		curve_ptd = append_array(curve_ptd, *plane.curve_ptdp)
  end
 
 if(nplanes NE 1) then $
  begin
   if(keyword_set(pd)) then pd = transpose(pd)
   if(keyword_set(rd)) then rd = transpose(rd)
   if(keyword_set(sd)) then sd = transpose(sd)
   if(keyword_set(std)) then std = transpose(std)
   if(keyword_set(ard)) then ard = transpose(ard)
  end $
 else $
  begin
   if(keyword_set(pd)) then pd = reform(pd)
   if(keyword_set(rd)) then rd = reform(rd)
   if(keyword_set(sd)) then sd = reform(sd)
   if(keyword_set(std)) then std = reform(std)
   if(keyword_set(ard)) then ard = reform(ard)
  end

 if(keyword_set(dd)) then _dd = dd 
 if(keyword_set(cd)) then _cd = cd 
 if(keyword_set(pd)) then _pd = pd 
 if(keyword_set(rd)) then _rd = rd 
 if(keyword_set(sd)) then _sd = sd 
 if(keyword_set(std)) then _std = std 
 if(keyword_set(ard)) then _ard = ard 
 if(keyword_set(active_pd)) then _active_pd = active_pd 
 if(keyword_set(active_rd)) then _active_rd = active_rd 
 if(keyword_set(active_sd)) then _active_sd = active_sd 
 if(keyword_set(active_std)) then _active_std = active_std 
 if(keyword_set(active_ard)) then _active_ard = active_ard 
 if(keyword_set(sund)) then _sund = sund 
 if(keyword_set(od)) then _od = od
 if(keyword_set(active_limb_ptd)) then _active_limb_ptd = active_limb_ptd 
 if(keyword_set(active_ring_ptd)) then _active_ring_ptd = active_ring_ptd 
 if(keyword_set(active_star_ptd)) then _active_star_ptd = active_star_ptd 
 if(keyword_set(active_term_ptd)) then _active_term_ptd = active_term_ptd
 if(keyword_set(active_plgrid_ptd)) then _active_plgrid_ptd = active_plgrid_ptd 
 if(keyword_set(active_center_ptd)) then _active_center_ptd = active_center_ptd 
 if(keyword_set(active_station_ptd)) then _active_station_ptd = active_station_ptd 
 if(keyword_set(active_array_ptd)) then _active_array_ptd = active_array_ptd 
 if(keyword_set(limb_ptd)) then _limb_ptd = limb_ptd 
 if(keyword_set(ring_ptd)) then _ring_ptd = ring_ptd 
 if(keyword_set(star_ptd)) then _star_ptd = star_ptd 
 if(keyword_set(term_ptd)) then _term_ptd = term_ptd
 if(keyword_set(plgrid_ptd)) then _plgrid_ptd = plgrid_ptd 
 if(keyword_set(center_ptd)) then _center_ptd = center_ptd 
 if(keyword_set(station_ptd)) then _station_ptd = station_ptd 
 if(keyword_set(array_ptd)) then _array_ptd = array_ptd 
 if(keyword_set(object_ptd)) then _object_ptd = object_ptd

 w = where(pnt_valid(tie_ptd))
 if(w[0] NE -1) then _tie_ptd = tie_ptd[w]

 w = where(pnt_valid(curve_ptd))
 if(w[0] NE -1) then _curve_ptd = curve_ptd[w]

 if(keyword_set(shadow_ptd)) then _shadow_ptd = shadow_ptd
 if(keyword_set(reflection_ptd)) then _reflection_ptd = reflection_ptd

 gd = cor_create_gd(dd=dd, crd=crd, bd=bd, md=md, dkd=dkd, $
                    gbd=gbd, pd=pd, sd=sd, std=std, ard=ard, $
                    rd=rd, cd=cd, sund=sund, od=od)

 if(keyword_set(gd)) then _gd = gd

end
;=============================================================================
