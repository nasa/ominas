;=============================================================================
;	NOTE:	remove the second '+' on the next line for this header
;		to be recognized by extract_doc.
;++
; NAME:
;	gr_
;
;
; PURPOSE:
;	xx
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	result = xx(xx, xx)
;	xx, xx, xx
;
;
; ARGUMENTS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; KEYWORDS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; ENVIRONMENT VARIABLES:
;	xx:	xx
;
;	xx:	xx
;
;
; RETURN:
;	xx
;
;
; COMMON BLOCKS:
;	xx:	xx
;
;	xx:	xx
;
;
; SIDE EFFECTS:
;	xx
;
;
; RESTRICTIONS:
;	xx
;
;
; PROCEDURE:
;	xx
;
;
; EXAMPLE:
;	xx
;
;
; STATUS:
;	xx
;
;
; SEE ALSO:
;	xx, xx, xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	xx, xx/xx/xxxx
;	
;-
;=============================================================================
pro gr_draw, pp, gd=gd, cd=_cd, pd=_pd, rd=_rd, sd=_sd, ard=_ard, std=_std, sund=_sund, od=_od, $
       psym=psym, symsize=symsize, color=_color, tag=tag, pn=pn, grnum=grnum

 type = size(pp, /type)
 if(type EQ 11) then object_ptd = pp $
 else object_ptd = pnt_create_descriptors(points=pp)
 dim = size(object_ptd, /dim)

 if(keyword_set(grnum)) then $
                     grim_data = grim_get_data(grim_grnum_to_top(grnum)) $
 else grim_data = grim_get_data(/primary)

 refresh = 0

 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 if(NOT defined(pn)) then $
    if(n_elements(dim) EQ 1) then pn = plane.pn

 if(defined(pn)) then $
  begin
   w = where(grim_data.pn EQ pn)
   if(w[0] NE -1) then refresh = 1
   planes = planes[pn]
  end $
 else refresh = 1

 nplanes = n_elements(planes)
 nobj = dim[0]

 if(n_elements(dim) EQ 1) then $
   if(nplanes GT 1) then $
               nv_message, 'Number of planes must match number of objects.'

 if(n_elements(dim) EQ 2) then $
    if(dim[1] NE nplanes) then $ 
      nv_message, name='GR_DRAW', 'Number of planes must match number of objects.'

 if(keyword__set(_color)) then $
    if(size(_color, /type) NE 7) then __color = ctlookup(_color)
 if(keyword__set(__color)) then color = __color


 


 ;---------------------------------
 ; dereference generic descriptor
 ;---------------------------------
 if(NOT keyword_set(_cd)) then _cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(_gbx)) then _gbx = dat_gd(gd, dd=dd, /gbx)
 if(NOT keyword_set(_dkx)) then _dkx = dat_gd(gd, dd=dd, /dkx)
 if(NOT keyword_set(_sund)) then _sund = dat_gd(gd, dd=dd, /sund)
 if(NOT keyword_set(_sd)) then _sd = dat_gd(gd, dd=dd, /sd)
 if(NOT keyword_set(_od)) then _od = dat_gd(gd, dd=dd, /od)
 if(NOT keyword_set(_pd)) then _pd = dat_gd(gd, dd=dd, /pd)
 if(NOT keyword_set(_rd)) then _rd = dat_gd(gd, dd=dd, /rd)
 if(NOT keyword_set(_std)) then _std = dat_gd(gd, dd=dd, /std)
 if(NOT keyword_set(_ard)) then _ard = dat_gd(gd, dd=dd, /ard)


 if(NOT keyword_set(_pd)) then if(keyword__set(_gbx)) then _pd = _gbx
 if(NOT keyword_set(_rd)) then if(keyword__set(_dkx)) then _rd = _dkx


 for j=0, nplanes-1 do $
  begin
   ;-------------------------------------------------------------
   ; if no descriptors given, treat all points as user points
   ;-------------------------------------------------------------
   if(NOT keyword_set(gd) AND $
      NOT keyword_set(_cd) AND  $
      NOT keyword_set(_pd) AND $
      NOT keyword_set(_rd) AND $
      NOT keyword_set(_sd) AND $
      NOT keyword_set(_std) AND $
      NOT keyword_set(_ard) AND $
      NOT keyword_set(_sund) AND $
      NOT keyword_set(_od) ) then user_ptd = object_ptd $
   ;------------------------------
   ; otherwise, determine types
   ;------------------------------
   else $
    begin
     if(keyword_set(_cd)) then cd = _cd[j]
     if(keyword_set(_pd)) then pd = _pd[*,j]
     if(keyword_set(_rd)) then rd = _rd[*,j]
     if(keyword_set(_sd)) then sd = _sd[*,j]
     if(keyword_set(_sund)) then sund = _sund[j]
     if(keyword_set(_std)) then std = _std[*,j]
     if(keyword_set(_ard)) then ard = _ard[*,j]
     if(keyword_set(_od)) then od = _od[j]

     ;---------------------
     ; add descriptors
     ;---------------------
     grim, cd=cd, pd=pd, rd=rd, sd=sd, sund=sund, std=std, ard=ard, od=od, /no_erase, pn=pn

     ;---------------------
     ; add overlay points
     ;---------------------
     limb_ptd = 0
     ring_ptd = 0
     term_ptd = 0
     star_ptd = 0
     center_ptd = 0
     station_ptd = 0
     array_ptd = 0
     user_ptd = 0

     for i=0, nobj-1 do $
      begin
       desc = pnt_desc(object_ptd[i,j])

       if(NOT keyword_set(desc)) then $
                    user_ptd = append_array(user_ptd, object_ptd[i,j]) $
       else $
        begin
;         desc = strupcase(desc)
;         if((strpos(desc, 'LIMB'))[0] NE -1) then $
;                              limb_ptd = append_array(limb_ptd, object_ptd[i,j]) $
;         else if((strpos(desc, 'DISK_INNER'))[0] NE -1) then $
;                              ring_ptd = append_array(ring_ptd, object_ptd[i,j]) $
;          else if((strpos(desc, 'DISK_OUTER'))[0] NE -1) then $
;                              ring_ptd = append_array(ring_ptd, object_ptd[i,j]) $
;        else if((strpos(desc, 'TERMINATOR'))[0] NE -1) then $
;                              term_ptd = append_array(term_ptd, object_ptd[i,j]) $
;         else if((strpos(desc, 'STAR_CENTER'))[0] NE -1) then $
;                              star_ptd = append_array(star_ptd, object_ptd[i,j]) $
;         else if((strpos(desc, 'PLANET_CENTER'))[0] NE -1) then $
;                              center_ptd = append_array(center_ptd, object_ptd[i,j]) $
;         else user_ptd = append_array(user_ptd, object_ptd[i,j])

         case strupcase(desc) of
          'LIMB' : limb_ptd = append_array(limb_ptd, object_ptd[i,j])
          'DISK_INNER' : ring_ptd = append_array(ring_ptd, object_ptd[i,j])
          'DISK_OUTER' : ring_ptd = append_array(ring_ptd, object_ptd[i,j])
          'TERMINATOR' : term_ptd = append_array(term_ptd, object_ptd[i,j])
          'STAR_CENTER' : star_ptd = append_array(star_ptd, object_ptd[i,j])
          'PLANET_CENTER' : center_ptd = append_array(center_ptd, object_ptd[i,j])
          'ARRAY' : array_ptd = append_array(array_ptd, object_ptd[i,j])
          'STATION' : station_ptd = append_array(station_ptd, object_ptd[i,j])
          else : user_ptd = append_array(user_ptd, object_ptd[i,j])
         endcase

        end
      end

    end

   grim_data = grim_get_data(grnum=grnum)

   ;------------------------------
   ; set object points
   ;------------------------------
   if(keyword_set(limb_ptd)) then $
     grim_add_points, grim_data, limb_ptd, cd=cd, name='limb', plane=planes[j]
   if(keyword_set(ring_ptd)) then $
     grim_add_points, grim_data, ring_ptd, cd=cd, name='ring', plane=planes[j]
   if(keyword_set(term_ptd)) then $
     grim_add_points, grim_data, term_ptd, cd=cd, name='terminator', plane=planes[j]
   if(keyword_set(star_ptd)) then $
     grim_add_points, grim_data, star_ptd, cd=cd, name='star', plane=planes[j]
   if(keyword_set(center_ptd)) then $
     grim_add_points, grim_data, center_ptd, cd=cd, name='planet_center', plane=planes[j]
   if(keyword_set(station_ptd)) then $
     grim_add_points, grim_data, station_ptd, cd=cd, name='station', plane=planes[j]
   if(keyword_set(array_ptd)) then $
     grim_add_points, grim_data, array_ptd, cd=cd, name='array', plane=planes[j]


   ;------------------------------
   ; set user points
   ;------------------------------
   if(keyword_set(user_ptd)) then $
    begin
     if(keyword_set(tag)) then $
        grim_add_user_points, plane=planes[j], user_ptd, tag, $
                       psym=psym, symsize=symsize, color=color, /no_refresh $
     else $
      begin
       nuser = n_elements(user_ptd)
       all_tags = strarr(nuser)

       ;-------------------------
       ; determine unique tags
       ;-------------------------
       tags = ''
       for i=0, nuser-1 do $
        begin
         tag = pnt_desc(user_ptd[0])
         all_tags[i] = tag
         w = where(tags EQ tag)
         if(w[0] EQ -1) then tags = [tags, tag]
        end
       if(keyword_set(tags)) then tags = tags[1:*]

       ;-------------------------
       ; add points by tag
       ;-------------------------
       ntags = n_elements(tags)
       for i=0, ntags-1 do $
        begin
         w = where(all_tags EQ tags[i])
         grim_add_user_points, plane=planes[j], user_ptd[w], $
                      tags[i], psym=psym, symsize=symsize, color=color, /no_refresh
        end

      end
    end
  end


 if(refresh) then grim_refresh, grim_data;, /no_image

end
;=============================================================================
