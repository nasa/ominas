;=============================================================================
;+
; NAME:
;	pg_station
;
;
; PURPOSE:
;	Computes image points for given station descriptors.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	station_ptd = pg_station(gd=gd)
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
;	std:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of STATION.
;
;	gbx:	Array (n_xd, n_timesteps) of descriptors of objects 
;		that must be a subclass of GLOBE.
;
;	dkx:	Array (n_xd, n_timesteps) of descriptors of objects 
;		that must be a subclass of DISK.
;
;	bx:	Array (n_xd, n_timesteps) of descriptors of objects 
;		that must be a subclass of BODY, instead of gbx or dkx.  
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	clip:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the clip keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_objects) of POINT containing image points and
;	the corresponding inertial vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
function pg_station, cd=cd, std=std, gbx=gbx, dkx=dkx, bx=bx, dd=dd, gd=gd, $
                                                         clip=clip, cull=cull
@pnt_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)
 if(NOT keyword_set(std)) then std = dat_gd(gd, dd=dd, /std)


 if(keyword_set(gbx)) then if(NOT keyword_set(bx)) then bx = gbx
 if(keyword_set(dkx)) then if(NOT keyword_set(bx)) then bx = dkx

 if(keyword_set(clip)) then slop = (image_size(cd[0]))[0]*(clip-1) > 1

 cor_count_descriptors, std, nd=n_objects, nt=nt


 ;-----------------------------------
 ; compute points for each station
 ;-----------------------------------
 hide_flag = PTD_MASK_INVISIBLE

 station_ptd = objarr(n_objects)

 for i=0, n_objects-1 do $
  begin
   xd = 0
   if(keyword_set(bx)) then $
    begin
     xd0 = get_primary(std[i,0])
     w = where(xd0[0] EQ bx[*,0])

     if(w[0] NE -1) then $
      begin
       xd = reform(bx[w[0],*], nt)
       gd_input = {bx:xd[0], cd:cd[0]}
      end
    end

   surf_pts = stn_surface_pt(std[i,*])
   map_pts = surface_to_map(cd, xd, surf_pts)

   points = map_to_image(cd, cd, xd, map_pts, valid=valid, body=body_pts)
   inertial_pts = 0
   if(keyword_set(bx)) then $
    if(keyword_set(body_pts)) then $
     inertial_pts = bod_body_to_inertial_pos(xd, body_pts)

;   name = cor_name(xd) + ':' + cor_name(std[i])
   name = cor_name(std[i])

   ;-----------------------------------
   ; store grid
   ;-----------------------------------
   station_ptd[i] = pnt_create_descriptors(name = strupcase(name), $
		           desc = 'STATION', $
		           gd = gd_input, $
		           assoc_xd = xd, $
		           points = points, $
		           vectors = inertial_pts)
   cor_set_udata, station_ptd[i], 'SURFACE_PTS', surf_pts
   flags = pnt_flags(station_ptd[i])
   if(NOT keyword__set(valid)) then flags[*] = PTD_MASK_INVISIBLE
   pnt_set_flags, station_ptd[i], flags

   if(keyword_set(xd)) then $
     if(NOT bod_opaque(xd[0])) then pnt_set_flags, station_ptd[i], hide_flag
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(clip)) then $
  begin
   pg_crop_points, station_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then station_ptd = pnt_cull(station_ptd)
  end


 if(keyword_set(__lat)) then _lat = __lat
 if(keyword_set(__lon)) then _lon = __lon

 return, station_ptd
end
;=============================================================================
