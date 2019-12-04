;=============================================================================
;+
; NAME:
;	pg_hide
;
;
; PURPOSE:
;	Hides the given points with respect to each given object and observer
;	using the hide methods of the given bodies.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_hide, point_ptd, cd=cd, od=od, bx=bx
;
;
; ARGUMENTS:
;  INPUT:
;	point_ptd:	Array of POINT containing inertial vectors.
;
;  OUTPUT: 
;	hide_ptd:	Array (n_disks, n_timesteps) of POINT 
;			containing the hidden points.
;
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of GLOBE.
;
;	dkx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of DISK.
;
;	bx:	Array (n_bodies, n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the observer from which points are hidden.  If no observer
;		descriptor is given, the camera descriptor is used.
;
;	gd:	Generic descriptor.  If given, the descriptor inputs 
;		are taken from this structure if not explicitly given.
;
;	dd:	Data descriptor containing a generic descriptor to use
;		if gd not given.
;
;	reveal:	 Normally, objects whose opaque flag is set are ignored.  
;		 /reveal suppresses this behavior.
;
;	cat:	If set, the hide_ptd points are concatentated into a single
;		POINT object.
;
;	rm:	If set, points are flagged for being in front of or behind
;		the body, rather then just behind it.
;
;	limb:	If set, hide wrt to limb, where applicable.  Assumes points lie
;		on the surface of the body.  Not that when /limb is not set,
;		the limb algorithm is still used to hide points with respect
;		to their associated body.
;
;	assoc:	If set, points are only hidden wrt their associated body.
;		This is typically much faster because the calculations for
;		each points array are carried out for a single body instead 
;		of all given bodies.  This is useful, for example, for hiding
;		points that lie on the surface of a planet wrt to only that
;		planet.
;
;	dissoc:	If set, points are not hidden wrt their associated body.
;		This is useful, for example, for points lying on the limb
;		of a body as seen from the specified observer.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	The flags arrays in point_ptd are modified.
;
;
; PROCEDURE:
;	For each object in point_ptd, hidden points are computed and
;	PTD_MASK_INVISIBLE in the POINT is set.  No points are
;	removed from the array.
;
;
; EXAMPLE:
;	The following command hides all points which are behind a planet as
;	seen by the camera:
;
;	pg_hide, point_ptd, cd=cd, bx=pd
;
;	In this call, pd is a planet descriptor, and cd is a camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_hide_limb
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2017, generalized pg_hide_globe and pg_hide_disk
;	
;-
;=============================================================================



;=============================================================================
; pgh_select_by_dissoc
;
;=============================================================================
function pgh_select_by_dissoc, bx, point_ptd
 if(NOT keyword_set(bx)) then return, !null

 w = where(pnt_assoc_xd(point_ptd) NE bx[*,0])
 if(w[0] NE -1) then return, bx[w,*]

 return, !null
end
;=============================================================================



;=============================================================================
; pgh_select_by_assoc
;
;=============================================================================
function pgh_select_by_assoc, bx, point_ptd
 if(NOT keyword_set(bx)) then return, !null

 w = where(pnt_assoc_xd(point_ptd) EQ bx[*,0])
 if(w[0] NE -1) then return, bx[w,*]

 return, !null
end
;=============================================================================



;=============================================================================
; pgh_select_by_bounding_box
;
;=============================================================================
function pgh_select_by_bounding_box, _cd, bx, point_ptd
;;;common pgh_select_by_bounding_box_block
 n = n_elements(bx)

 cd = make_array(n, val=_cd)
 bod_pos = bod_pos(bx)
 cam_pos = bod_pos(cd)

 rad = reform(body_radius(bx[*,0]) ## make_array(3,val=1d), 1,3,n, /over)

 orient = bod_orient(cd)
 xx = orient[0,*,*]
 yy = orient[2,*,*]

 pp = dblarr(2,4,n)
 pp[*,0,*] = inertial_to_image_pos(cd, bod_pos + rad*(xx+yy))
 pp[*,1,*] = inertial_to_image_pos(cd, bod_pos + rad*(xx-yy))
 pp[*,2,*] = inertial_to_image_pos(cd, bod_pos + rad*(-xx+yy))
 pp[*,3,*] = inertial_to_image_pos(cd, bod_pos + rad*(-xx-yy))

 xxmax = reform(nmax(pp[0,*,*], 1), /over)
 xxmin = reform(nmin(pp[0,*,*], 1), /over)
 yymax = reform(nmax(pp[1,*,*], 1), /over)
 yymin = reform(nmin(pp[1,*,*], 1), /over)


 p = pnt_points(point_ptd, /visible)
 if(NOT keyword_set(p)) then return, !null

 xmax = make_array(n, val=max(p[0,*], min=xmin))
 ymax = make_array(n, val=max(p[1,*], min=ymin))
 xmin = make_array(n, val=xmin)
 ymin = make_array(n, val=ymin)

 w = where((xxmax GT xmin) AND (xmax GT xxmin) AND $
           (yymax GT ymin) AND (ymax GT yymin))

 if(w[0] NE -1) then return, bx[w,*]

 return, !null
end
;=============================================================================



;=============================================================================
; pg_hide
;
;=============================================================================
pro pg_hide, cd=cd, od=od, bx=bx, gbx=gbx, dkx=dkx, dd=dd, gd=gd, _point_ptd, hide_ptd, $
              reveal=reveal, compress=compress, cat=cat, rm=rm, assoc=assoc, $
              limb=_limb, dissoc=dissoc
@pnt_include.pro

 hide_output = arg_present(hide_ptd)
 if(NOT keyword_set(_point_ptd)) then return

 ;----------------------------------------------------------
 ; if /compress, assume all point_ptd have same # of points
 ;----------------------------------------------------------
;stop
;compress=1
; if(keyword_set(compress)) then point_ptd = pnt_compress(_point_ptd) $
; else 
point_ptd = _point_ptd

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(cd)) then cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)
 if(NOT keyword_set(gbx)) then gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(dkx)) then dkx = dat_gd(gd, dd=dd, /dkx)

 if(NOT keyword_set(bx)) then bx = append_array(gbx, dkx)


 if(NOT keyword_set(bx)) then return

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(od)
 cor_count_descriptors, bx, nd=n_bodies, nt=nt1
 if(nt NE nt1) then nv_message, 'Inconsistent timesteps.'


 ;------------------------------------
 ; hide object points wrt each body
 ;------------------------------------
 n_objects = n_elements(point_ptd)
 if(hide_output) then hide_ptd = objarr(n_objects, n_bodies)

 obs_pos = bod_pos(od)
 for j=0, n_objects-1 do if(obj_valid(point_ptd[j])) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - 
   ; select bodies for hiding
   ;- - - - - - - - - - - - - - - - - - - - - - - - - 
   bxx = bx

   ;- - - - - - - - - - - - - - - - - - - - -
   ; associated bodies
   ;- - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(assoc)) then bxx = pgh_select_by_assoc(bxx, point_ptd[j])

   ;- - - - - - - - - - - - - - - - - - - - -
   ; dissociated bodies
   ;- - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(dissoc)) then bxx = pgh_select_by_dissoc(bxx, point_ptd[j])

   ;- - - - - - - - - - - - - - - - - - - - -
   ; select using bounding radii
   ;- - - - - - - - - - - - - - - - - - - - -
   if(n_elements(bxx) GT 1) then $
                      bxx = pgh_select_by_bounding_box(cd, bxx, point_ptd[j])

   ;- - - - - - - - - - - - - - - - - - - - - - - - - 
   ; hide wrt selected bodies
   ;- - - - - - - - - - - - - - - - - - - - - - - - - 
   for i=0, n_elements(bxx)-1 do $
    if((bod_opaque(bxx[i,0])) OR (keyword_set(reveal))) then $
     begin
      xd = reform(bxx[i,*], nt)

      limb = pnt_assoc_xd(point_ptd[j]) EQ xd
      if(keyword_set(_limb)) then limb = 1

      Rs = bod_inertial_to_body_pos(xd, obs_pos)

      pnt_query, point_ptd[j], p=p, vectors=vectors, flags=flags
      object_pts = bod_inertial_to_body_pos(xd, vectors)

      w = hide_points(xd, Rs, object_pts, rm=rm, limb=limb)
      if(w[0] NE -1) then $
       begin
        _flags = flags
        _flags[w] = _flags[w] OR PTD_MASK_INVISIBLE
        pnt_set_flags, point_ptd[j], _flags
       end

      if(hide_output) then $
       begin
        hide_ptd[j,i] = nv_clone(point_ptd[j])

        pnt_query, hide_ptd[j,i], desc=desc, gd=gd0

        ww = complement(flags, w)
        _flags = flags
        if(ww[0] NE -1) then _flags[ww] = _flags[ww] OR PTD_MASK_INVISIBLE

        pnt_assign, /noevent, hide_ptd[j,i], flags=_flags, $
                  desc=desc+'-hide_'+strlowcase(cor_class(bxx[i,0])), $
                  gd=append_struct(gd0, {bx:bxx[i,0], od:od[0], cd:cd[0]})
       end
     end
  end


 ;---------------------------------------------------------
 ; if desired, concatenate all hide_ptd for each object
 ;---------------------------------------------------------
 if(hide_output AND keyword_set(cat)) then $
  begin
   for j=0, n_objects-1 do hide_ptd[j,0] = pnt_compress(hide_ptd[j,*])
   if(n_bodies GT 1) then $
    begin
     nv_free, hide_ptd[*,1:*]
     hide_ptd = hide_ptd[*,0]
    end
  end


; ;----------------------------------------------------------
; ; if /compress, expand result
; ;----------------------------------------------------------
; if(keyword_set(compress)) then $
;  begin
;   pnt_uncompress, point_ptd, _point_ptd, i=ww
;   pnt_uncompress, hide_ptd, _hide_ptd, i=w
;  end $
; else point_ptd = _point_ptd


end
;=============================================================================
