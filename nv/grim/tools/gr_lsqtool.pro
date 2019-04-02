;=============================================================================
;+
; NAME:
;	gr_lsqtool
;
;
; DESCRIPTION:
;	Graphical least-squares navigation tool. 
;
;
; CALLING SEQUENCE:
;	
;	gr_lsqtool
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;
;  OUTPUT: NONE
;
;
; LAYOUT:
;	The gr_lsqtool layout consists of the following items:
;
;	 Scan width:
;		Width if the scan about the model points.
;
;	 Edge proximity:
;		Points closer than this to the edge of the image are not
;		scanned.
;
;	 Min correlation:
;		Miniumum acceptable correlation coefficient in the scan.
;
;	 Max correlation:
;		Maxiumum acceptable correlation coefficient in the scan.
;
;	Scan button:
;		Scans the image according to the current widget settings.
;		The resulting points are entered as user points in the
;		appropriate GRIM widget. 
;
;	Fix buttons:
;		Select fit parameters to fix.  x and y are the image offsets 
;		in the repective direction, theta is the rotation about the
;		center given by the parameter center_ptdp.  If center_ptdp
;		contains no points, then theta is automatically fixed.
;
;	Fit button:
;		Performs a simultaneous linear least-square fit to all of the
;		objects that have been scanned.  This button causes the given
;		camera descriptor to be modified.
;
;	Close button
;		Causes gr_lsqtool to exit.		
;
;
;
; OPERATION:
;   gr_lsqtool allows the user to produce a subpixel  pointing correction
;   by fitting model points to those observed in the image.  When the 
;   "Scan" button is pressed, an image scan is performed for each active 
;   array in the primary grim window.  Limbs, terminators, and rings are 
;   scanned as edges, while stars and planet centers are scanned as point 
;   sources.  Scans may also be performed individually on different objects. 
;   The "Scan Width" entry specifies the width of the scan about each active
;   array.  The "Edge Proximity" field specifies the closest that a scan 
;   will come to the image edge.  The correlation fields give the 
;   correlation criterion for accepting scanned points.
;  
;   After you have scanned your points, you can use the "Fit" button to 
;   perform a least-square fit between each active object and the 
;   corresponding scanned points.  The Fit statistics are displayed in 
;   the text window at the bottom.  You can specify which parameters to
;   fix using the "Fix" buttons.
;  
;   Because this fit is linear, it requires the initial guess to be close
;   to the actual solution.  You may need to iterate to converge to a
;   good solution; you must rescan your points each time, however.
;
;
; STATUS:
;	Incomplete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale 7/2002
;	
;-
;=============================================================================

;=============================================================================
; lsq_descriptor__define
;
;=============================================================================
pro lsq_descriptor__define

 struct = $
    { lsq_descriptor, $
	 algorithm	:	'', $
	 model_fn	:	'', $
	 invert		:	0b, $
	 fix		:	intarr(3), $
	 scanned	:	0b, $
	 min		:	0d, $
	 max		:	0d, $
	 width		:	0l, $
	 edge		:	0l $
	}

end
;=============================================================================



;=============================================================================
; grlsq_print
;
;=============================================================================
pro grlsq_print, data, s, clear=clear

 if(keyword__set(clear)) then ss = '' $
 else widget_control, data.text, get_value=ss

 sss = ss
 n = n_elements(s)
 for i=0, n-1 do sss = [sss, s[i]]

 if(ss[0] EQ '') then sss = sss[1:*]

 widget_control, data.text, set_value=sss

end
;=============================================================================



;=============================================================================
; grlsq_descriptor
;
;=============================================================================
function grlsq_descriptor, $
        min=min, max=max, width=width, edge=edge, fix=fix, scanned=scanned, $
        algorithm=algorithm, model_fn=model_fn, invert=invert

 lsqd = {lsq_descriptor}

 if(defined(scanned)) then lsqd.scanned=scanned
 if(defined(invert)) then lsqd.invert=invert
 if(keyword_set(fix)) then lsqd.fix = fix 	else lsqd.fix = [0,0,1]

 if(keyword_set(min)) then lsqd.min = min 	else lsqd.min = 0.
 if(keyword_set(max)) then lsqd.max = max	else lsqd.max = 1.0d
 if(keyword_set(width)) then lsqd.width = width	else lsqd.width = 40
 if(keyword_set(edge)) then lsqd.edge = edge	else lsqd.edge = 20
 if(keyword_set(algorithm)) then lsqd.algorithm = algorithm	else lsqd.algorithm = 'Model'
 if(keyword_set(model_fn)) then lsqd.model_fn = model_fn	else lsqd.model_fn = 'Auto'

 return, lsqd
end
;=============================================================================



;=============================================================================
; grlsq_parse_entry
;
;=============================================================================
function grlsq_parse_entry, ids, tags, tag, drop=drop

 i = (where(tags EQ tag))[0]

 if(NOT keyword__set(drop)) then $
  begin   
   widget_control, ids[i], get_value=value
   if(size(value, /type) EQ 7) then value = str_sep(strtrim(value,2), ' ')
  end $
 else value = widget_info(ids[i], /droplist_select)

 return, value
end
;=============================================================================



;=============================================================================
; grlsq_set_entry
;
;=============================================================================
pro grlsq_set_entry, ids, tags, tag, value, drop=drop, sensitive=sensitive, button=button

 i = (where(tags EQ tag))[0]

 if(n_elements(sensitive) NE 0) then widget_control, ids[i], sensitive=sensitive
 if(n_elements(value) EQ 0) then return

 if(keyword_set(drop)) then $
     widget_control, ids[i], set_droplist_select=value $
 else if(keyword_set(button)) then  $
         widget_control, ids[i], set_value = value $
 else widget_control, ids[i], set_value = strtrim(value,2) + ' ' 

end
;=============================================================================



;=============================================================================
; grlsq_form_to_lsqd
;
;=============================================================================
function grlsq_form_to_lsqd, data, object=object


scanned = data.lsqd.scanned
 algorithm = strupcase(data.algorithms[ $
               grlsq_parse_entry(data.ids, data.tags, 'ALGORITHM', /drop)])
 model_fn = strupcase(data.model_fns[ $
               grlsq_parse_entry(data.ids, data.tags, 'MODEL_FN', /drop)])

 invert = byte(grlsq_parse_entry(data.ids, data.tags, 'INVERT'))

 width = long(grlsq_parse_entry(data.ids, data.tags, 'WIDTH'))
 edge = long(grlsq_parse_entry(data.ids, data.tags, 'EDGE'))
 min = double(grlsq_parse_entry(data.ids, data.tags, 'MIN'))
 max = double(grlsq_parse_entry(data.ids, data.tags, 'MAX'))

 fix = long(grlsq_parse_entry(data.ids, data.tags, 'FIX'))

 lsqd = grlsq_descriptor( $
		algorithm=algorithm, $
		model_fn=model_fn, $
		invert=invert, $
		fix=fix, $
		min=min, $
		max=max, $
		scanned=scanned, $
		width=width, $
		edge=edge )

 return, lsqd
end
;=============================================================================



;=============================================================================
; grlsq_lsqd_to_form
;
;=============================================================================
pro grlsq_lsqd_to_form, data, lsqd

 grlsq_set_entry, data.ids, data.tags, 'INVERT', lsqd.invert, /button

 grlsq_set_entry, data.ids, data.tags, 'WIDTH', lsqd.width
 grlsq_set_entry, data.ids, data.tags, 'EDGE', lsqd.edge

 is_model = strupcase(lsqd.algorithm) EQ 'MODEL'
 grlsq_set_entry, data.ids, data.tags, 'MODEL_FN', sensitive=is_model
 grlsq_set_entry, data.ids, data.tags, 'MIN', lsqd.min, sensitive=is_model
 grlsq_set_entry, data.ids, data.tags, 'MAX', lsqd.max, sensitive=is_model
 if(NOT is_model) then $
  begin
   wset, data.model_wnum
   erase
  end

 fix = lsqd.fix
 grlsq_set_entry, data.ids, data.tags, 'FIX', lsqd.fix
 grlsq_set_entry, data.ids, data.tags, 'FIT', sensitive=lsqd.scanned

end
;=============================================================================



;=============================================================================
; grlsq_get_ptdps
;
;=============================================================================
function grlsq_get_ptdps, grim_data, data, lsqd, pds=pds, rds=rds, sds=sds
 ptdps = nv_ptr_new()

; grift, active_limb_ptd=limb_ptd, $
;         active_ring_ptd=ring_ptd, $
;         active_term_ptd=term_ptd, $
;         active_shadow_ptd=shadow_ptd, $
;         active_reflection_ptd=reflection_ptd, $
;         active_star_ptd=star_ptd, $
;         active_center_ptd=center_ptd, $
;         active_pd=pds, $
;         active_rd=rds, $
;         active_sd=sds
 grift, /active, $
         limb_ptd=limb_ptd, $
         ring_ptd=ring_ptd, $
         term_ptd=term_ptd, $
         shadow_ptd=shadow_ptd, $
         reflection_ptd=reflection_ptd, $
         star_ptd=star_ptd, $
         center_ptd=center_ptd, $
         pd=pds, $
         rd=rds, $
         sd=sds

 if(keyword__set(limb_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(limb_ptd))
 if(keyword__set(ring_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(ring_ptd))
 if(keyword__set(term_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(term_ptd))
 if(keyword__set(shadow_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(shadow_ptd))
 if(keyword__set(reflection_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(reflection_ptd))
 if(keyword__set(star_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(star_ptd))
 if(keyword__set(center_ptd)) then ptdps = append_array(ptdps, nv_ptr_new(center_ptd))

 if(n_elements(ptdps) EQ 0) then return, 0

; need to free these guys
 return, ptdps
end
;=============================================================================



;=============================================================================
; grlsq_invert_model
;
;=============================================================================
function grlsq_invert_model, model, mzero

 model = rotate(model,2)
 cc = 0.5d*double(n_elements(model)-1)
 mzero = cc - (mzero - cc)

 return, model
end
;=============================================================================



;=============================================================================
; grlsq_draw_models
;
;=============================================================================
pro grlsq_draw_models, data, model_p, mzero, tag

 wset, data.model_wnum
 erase

 utag = tag[sort(tag)]
 utag = utag[uniq(utag)]

 n = n_elements(utag)
 for ii=0, n-1 do $
  begin
   title = utag[ii]
   i = (where(tag EQ utag[ii]))[0]

   model = *model_p[i]
   lzero = mzero[i]

   pos = [[0.05, float(ii)/float(n) + 0.05, $
           0.98, float(ii+1)/float(n) - 0.05]]

   ww = max(model)-min(model)
   slop=0.05*ww
   plot, /noerase, [0], [0], xstyle=3, ystyle=3, $
       xrange=[0,n_elements(model)-1], $
       yrange=[min(model)-slop, max(model)+slop], $
       pos=pos, title=title, charsize=0.5
   oplot, model, symsize=0.5, col=ctred()
   oplot, model, psym=4, symsize=0.5, col=ctyellow()
   oplot, [lzero, lzero], [-1d10,1d10], col=ctblue()

  end

end
;=============================================================================



;=============================================================================
; grlsq_edge_model_psf_ring
;
;=============================================================================
function grlsq_edge_model_psf_ring, zero=zero, gd=gd, desc=desc

 cd = cor_dereference_gd(gd, /cd)
 rd = cor_dereference_gd(gd, /rd)

 model = edge_model_psf_ring(zero=zero, cd=cd)
 if(NOT keyword_set(rd)) then return, model

; f = v_inner(bod_pos(cd)-bod_pos(rd), (bod_orient(rd))[2,*])

; case desc of
;  'DISK_INNER' :	if(f[0] LT 0) then $
;			           model = grlsq_invert_model(model, zero)
;  'DISK_OUTER' :	if(f[0] GT 0) then $
;			           model = grlsq_invert_model(model, zero)
; endcase

 return, model
end
;=============================================================================



;=============================================================================
; grlsq_edge_model_nav_ring
;
;=============================================================================
function grlsq_edge_model_nav_ring, zero=zero, gd=gd, desc=desc
 cd = cor_dereference_gd(gd, /cd)
 return, edge_model_nav_ring(zero=zero, cd=cd)
end
;=============================================================================



;=============================================================================
; grlsq_edge_model_nav_limb
;
;=============================================================================
function grlsq_edge_model_nav_limb, zero=zero, gd=gd, desc=desc
 cd = cor_dereference_gd(gd, /cd)
 return, edge_model_nav_limb(zero=zero, cd=cd)
end
;=============================================================================



;=============================================================================
; grlsq_edge_model_atan
;
;=============================================================================
function grlsq_edge_model_atan, zero=zero, gd=gd, desc=desc
 cd = cor_dereference_gd(gd, /cd)
 return, edge_model_atan(zero=zero, 10, 5, cd=cd)
end
;=============================================================================



;=============================================================================
; grlsq_get_model_type
;
;=============================================================================
function  grlsq_get_model_type, _tag

 tag = strupcase(_tag)

 types = ['LIMB', 'TERMINATOR', 'SHADOW', 'REFLECTION', 'DISK_INNER', 'DISK_OUTER']
 ntypes = n_elements(types)

 for i=0, ntypes-1 do $
  if(strpos(tag, types[i]) EQ 0) then return, types[i]

 return, tag
end
;=============================================================================



;=============================================================================
; grlsq_get_model_fn
;
;=============================================================================
function  grlsq_get_model_fn, lsqd, tag

 fn = lsqd.model_fn

 if(strupcase(fn) NE 'AUTO') then return, 'grlsq_edge_model_' + fn
 if(NOT keyword_set(tag)) then return, ''

 type = grlsq_get_model_type(tag)

 case(strupcase(type)) of 
  'LIMB'		: return, 'grlsq_edge_model_atan'
  'TERMINATOR'		: return, 'grlsq_edge_model_atan'
  'SHADOW'		: return, 'grlsq_edge_model_nav_limb'
  'REFLECTION'		: return, 'grlsq_edge_model_nav_limb'
  'DISK_OUTER'		: return, 'grlsq_edge_model_psf_ring'
  'DISK_INNER'		: return, 'grlsq_edge_model_psf_ring' 
   else 		: return, 'grlsq_edge_model_atan'
 endcase

end
;=============================================================================



;=============================================================================
; grlsq_get_inner
;
;=============================================================================
function  grlsq_get_inner, cd, rd, tag

 type = grlsq_get_model_type(tag)

 case(strupcase(type)) of 
  'LIMB'		: return, 0
  'TERMINATOR'		: return, 0
  'SHADOW'		: return, 0
  'REFLECTION'		: return, 0
  'DISK_OUTER'		: return, 0
  'DISK_INNER'		: return, 1
   else			: return, 0
 endcase

end
;=============================================================================



;=============================================================================
; grlsq_get_model
;
;=============================================================================
function  grlsq_get_model, lsqd, tag, lzero, cd=cd, rd=rd

 model_fn = grlsq_get_model_fn(lsqd, tag)

 gd = cor_create_gd(cd=cd, rd=rd)
 model = call_function(model_fn, zero=lzero, gd=gd, desc=tag)

 type = grlsq_get_model_type(tag)

 cd = cor_dereference_gd(gd, /cd)
 rd = cor_dereference_gd(gd, /rd)

 if(keyword_set(rd)) then $
  begin
   f = v_inner(bod_pos(cd)-bod_pos(rd), (bod_orient(rd))[2,*])

   case type of
    'DISK_INNER' :	if(f[0] LT 0) then $
			           model = grlsq_invert_model(model, lzero)
    'DISK_OUTER' :	if(f[0] GT 0) then $
			           model = grlsq_invert_model(model, lzero)
   endcase
  end


 if(lsqd.invert) then model = grlsq_invert_model(model, lzero)

 return, model
end
;=============================================================================



;=============================================================================
; grlsq_make_tag
;
;=============================================================================
function grlsq_make_tag, ptd

 desc = pnt_desc(ptd)
 name = cor_name(ptd)

 return, strupcase(desc) + '_SCAN[' + strupcase(name) + ']'
end
;=============================================================================



;=============================================================================
; grlsq_scan
;
;=============================================================================
pro grlsq_scan, grim_data, data, nocreate=nocreate, $
                status=status, noscan=noscan, lsqd=lsqd

 widget_control, /hourglass
 tvim, data.grim_wnum

 status = -1

 ;-----------------------------------------------
 ; get tag names, widget ids, and lsq descriptor
 ;-----------------------------------------------
 tags = data.tags
 ids = data.ids

 if(NOT keyword_set(lsqd)) then lsqd = data.lsqd

 ;---------------------------------
 ; determine which arrays to use
 ;---------------------------------
 rds = 0
 object_ptdps = grlsq_get_ptdps(grim_data, data, lsqd, rds=rds)

 if(NOT keyword_set(object_ptdps)) then $
  begin
   grim_message, 'No appropriate overlay points available.'
   return
  end
 nobj = n_elements(object_ptdps)

 grift, dd=dd, cd=cd, pd=pd

 pmodel_p = 0
 pmzero = 0
 ptag = ''

 cam_psf_attrib, cd, fwhm=fwhm

 ;-------------------------------------
 ; loop over objects
 ;-------------------------------------
 for i=0, nobj-1 do $
  begin
   ptd = *object_ptdps[i]
   _ptd = ptd
   nptd = n_elements(_ptd)

   ;- - - - - - - - - - - - - - - - - 
   ; in the image?
   ;- - - - - - - - - - - - - - - - - 
   ptd = 0
   for k=0, nptd-1 do $
    begin
     p = pnt_points(_ptd[k])
     name = cor_name(_ptd[k])
     w = in_image(cd, p)
     if(w[0] NE -1) then ptd = append_array(ptd, _ptd[k])
    end

   if(keyword_set(ptd)) then $
    begin
     nptd = n_elements(ptd)
     desc = strupcase(pnt_desc(ptd))

     ;--------------------------------------------------------------
     ; point scan -- include planet centers as well as stars, but
     ;   only if planet disk is smaller than about the size of the 
     ;   psf, or one pixel if no psf exists.
     ;--------------------------------------------------------------
     center = 0

     if(desc[0] EQ 'STAR_CENTER') then center = 1

     if(desc[0] EQ 'PLANET_CENTER') then $
      begin
       center = 1
       names = cor_name(pd)
       _ptd = ptd
       ptd = 0
       for k=0, nptd-1 do $
        begin
         name = cor_name(_ptd[k])
         w = where(names EQ name)
         if(w[0] NE -1) then $
          begin
           w = w[0]
           dist = v_mag(bod_pos(pd[w]) - bod_pos(cd))
           rad = (glb_radii(pd[w]))[0]
           npix = rad/dist[0] / (cam_scale(cd))[0]
           if(NOT keyword_set(fwhm)) then fwhm = 1d 
           if(npix LE fwhm*4.) then ptd = append_array(ptd, _ptd[k])
          end
        end
       nptd = 0
       if(keyword_set(ptd)) then nptd = n_elements(ptd)
      end

     if(center) then $
      begin
       if(keyword_set(ptd)) then $
        begin
         scan_ptd = pg_ptscan(dd, [ptd], edge=lsqd.edge, width=lsqd.width)
         for l=0, n_elements(scan_ptd)-1 do $
                cor_set_udata, scan_ptd[l], 'grlsq_scan_data', {lsqd:lsqd.edge}
         for l=0, n_elements(scan_ptd)-1 do $
                       cor_set_udata, scan_ptd[l], 'grlsq_scanned', 1b
         psym = 1
        end
      end $
     ;--------------------------------------------------------------
     ; edge scan
     ;--------------------------------------------------------------
     else $
      begin
       model_p = nv_ptr_new()
       if(strupcase(lsqd.algorithm) EQ 'MODEL') then $
        begin
         model_p = ptrarr(nptd)
         mzero = dblarr(nptd)

         for k=0, nptd-1 do $
          begin
           rd = 0
           if(keyword_set(rds)) then rd = pnt_assoc_xd(ptd[k])
           model = grlsq_get_model(lsqd, desc[k], lzero, cd=cd, rd=rd)

           model_p[k] = nv_ptr_new(model)
           mzero[k] = lzero

           pmodel_p = append_array(pmodel_p, model_p[k])
           pmzero = append_array(pmzero, mzero[k])
           ptag = append_array(ptag, desc[k])
          end
        end

       inner = bytarr(nptd)
       for k=0, nptd-1 do $
        begin
         rd = 0
         if(keyword_set(rds)) then rd = pnt_assoc_xd(ptd[k])
        inner[k] = grlsq_get_inner(cd, rd, desc[k])
         if(lsqd.invert) then inner[k] = (NOT inner[k]) < 1 > 0
        end

       if(NOT keyword_set(noscan)) then $
        scan_ptd = $
          pg_cvscan(dd, cd=cd, bx=pnt_assoc_xd(ptd), [ptd], edge=lsqd.edge, width=lsqd.width, $
                                  model=model_p, mzero=mzero, $
                                  algorithm=lsqd.algorithm, arg=inner)

        for l=0, n_elements(scan_ptd)-1 do $
          if(pnt_valid(scan_ptd[l])) then $
            cor_set_udata, scan_ptd[l], 'grlsq_scan_data', $
                    {lsqd:lsqd, model_p:model_p, mzero:mzero, inner:inner}
        for l=0, n_elements(scan_ptd)-1 do $
           if(pnt_valid(scan_ptd[l])) then $
                       cor_set_udata, scan_ptd[l], 'grlsq_scanned', 1b
      end

     if(keyword_set(scan_ptd)) then $
      begin
       ;------------------
       ; threshold
       ;------------------
       n = n_elements(scan_ptd)
       pg_threshold, scan_ptd, $
         min=make_array(n, val=lsqd.min), max=make_array(n, val=lsqd.max);, /rel


       ;------------------------
       ; add scanned points
       ;------------------------
       for j=0, nptd-1 do if(pnt_valid(scan_ptd[j])) then $
        begin
         name = strupcase(cor_name(ptd[j]))

         new_tag = grlsq_make_tag(ptd[j])
         if(keyword_set(nocreate)) then $
          begin
           pptd = grim_get_user_ptd(new_tag)
           flags = pnt_flags(pptd)
           pnt_set_flags, scan_ptd[j], flag
          end

         grim_add_user_points, scan_ptd[j], $
                     new_tag, psym=psym, /nodraw, update=nocreate
        end
      end
    end
  end

 ;-------------------------------------------------
 ; draw edge models
 ;-------------------------------------------------
 if(keyword_set(ptag)) then $
  begin
   grlsq_draw_models, data, pmodel_p, pmzero, ptag
   nv_ptr_free, pmodel_p
  end

 status = 0
end
;=============================================================================



;=============================================================================
; grlsq_fit
;
;=============================================================================
pro grlsq_fit, grim_data, data, lsqd, status=status

 widget_control, /hourglass
 status = 0

 _fix = where(lsqd.fix NE 0)
 if(_fix[0] NE -1) then fix = _fix

 grift, dd=dd, cd=cd
 axis = cam_oaxis(cd)

 ;---------------------------------------------------------
 ; only fit objects for which the model points are active
 ;---------------------------------------------------------
 object_ptdps = grlsq_get_ptdps(grim_data, data, lsqd)

 if(NOT keyword_set(object_ptdps)) then $
  begin
   grim_message, 'No overlay points available.'
   return
  end
 nobj = n_elements(object_ptdps)

 for i=0, nobj-1 do $
  begin
   ptd = *object_ptdps[i]
   nptd = n_elements(ptd)

   for j=0, nptd-1 do $
    begin
     tag = grlsq_make_tag(ptd[j])
     _scan_ptd =  grim_get_user_ptd(tag, /active)

     if(keyword_set(_scan_ptd)) then $
      begin
       _scan_pts = pnt_points(_scan_ptd, /visible)
       if(keyword_set(_scan_pts)) then $
        begin
         scanned = cor_udata(_scan_ptd, 'grlsq_scanned')

;         if(NOT scanned) then $
;          begin
;           scan_data = cor_udata(_scan_ptd, 'grlsq_scan_data')
;           __scan_ptd = $
;             pg_cvscan(dd, scan_ptd=_scan_ptd, cd=cd, bx=rds, [ptd], edge=scan_data.lsqd.edge, $
;                          width=scan_data.lsqd.width, $
;                          model=scan_data.model_p, mzero=scan_data.mzero, $
;                          algorithm=scan_data.lsqd.algorithm, arg=scan_data.inner)
;          end

        scan_ptd = append_array(scan_ptd, _scan_ptd)

         ;-----------------------------------
         ; stars and planet centers
         ;-----------------------------------
         if(strpos(tag, 'CENTER') NE -1) then $
          begin
           _ptscan_cf = pg_ptscan_coeff(scan_ptd, axis=axis, fix=fix)
           ptscan_cf = append_array(ptscan_cf, _ptscan_cf)
           for l=0, n_elements(scan_ptd)-1 do  $
                          cor_set_udata, scan_ptd[l], 'grlsq_scanned', 0b
          end $
         ;-----------------------------------
         ; curves
         ;-----------------------------------
         else $
          begin
           _cvscan_cf = pg_cvscan_coeff(scan_ptd, axis=axis, fix=fix)
           cvscan_cf = append_array(cvscan_cf, _cvscan_cf)
           for l=0, n_elements(scan_ptd)-1 do  $
                          cor_set_udata, scan_ptd[l], 'grlsq_scanned', 0b
          end

        end
      end
    end

  end

 if(keyword_set(cvscan_cf)) then scan_cf = cvscan_cf
 if(keyword_set(ptscan_cf)) then $
  begin
   if(NOT keyword_set(scan_cf)) then scan_cf = ptscan_cf $
   else scan_cf = [scan_cf, ptscan_cf]
  end

 if(NOT keyword_set(scan_cf)) then $
  begin
   grim_message, 'No scanned points available.'
   return
  end


 ;--------------------------------------
 ; perform simultaneous linear fit
 ;--------------------------------------
 dxy = pg_fit([scan_cf], dtheta=dtheta)
 if((NOT finite(dxy[0])) OR (NOT finite(dxy[1]))) then $
  begin
   grim_message, 'Bad fit!'
   status = -1
   return
  end


 ;--------------------------------------
 ; print fit statistics
 ;--------------------------------------
 grlsq_print, data, /clear, $
     ['[dx, dy, dtheta] =', '     [' + $
           strtrim(dxy[0],2) + ', ' + strtrim(dxy[1],2) + ', ' + $
                                                    strtrim(dtheta,2) + ']']

 ;- - - - - - - - - - - -
 ; compute residuals
 ;- - - - - - - - - - - -
 res = pg_residuals(scan_ptd)
 nres = n_elements(res)/2

 res_rms = sqrt(total(res^2)/nres)


 ;- - - - - - - - - - - - - - - - - - - -
 ; compute covariance matrix and chisq
 ;- - - - - - - - - - - - - - - - - - - -
 covar = pg_covariance([scan_cf])
 chisq = pg_chisq(dxy, dtheta, scan_ptd, axis_ptd=axis_ptd, fix=fix)


 ;- - - - - - - - - - - - - - - - - - - -
 ; print data
 ;- - - - - - - - - - - - - - - - - - - -
 s = strtrim(covar, 2)
 ss = [' dx     : ',' dy     : ',' dtheta : '] + $
            transpose(str_pad(s[0,*],10) + '  ' + $
                           str_pad(s[1,*],10) + '  ' + str_pad(s[2,*],10))

 grlsq_print, data, ['', 'covariance = dx:        dy:       dtheta:', ss]
 grlsq_print, data, ['', 'chisq = ' + strtrim(chisq,2)]
 grlsq_print, data, ['', 'RMS residual = ' + strtrim(res_rms,2)]

 res_s = strarr(nres)
 for i=0, nres-1 do res_s[i] = $
     str_pad(strtrim(res[0,i],2), 15) + str_pad(strtrim(res[1,i],2), 15)
 grlsq_print, data, ['', 'residuals (x, y):', res_s]


 ;--------------------------------------
 ; repoint
 ;--------------------------------------
 pg_repoint, dxy, dtheta, axis=axis_ptd, cd=cd

end
;=============================================================================



;=============================================================================
; gr_lsqtool_event
;
;=============================================================================
pro gr_lsqtool_event, event

 ;-----------------------------------------------
 ; get data structure
 ;-----------------------------------------------
 grim_data = grim_get_data(/primary)
 if(NOT keyword_set(grim_data)) then return
 data = grim_get_user_data(grim_data, 'GRLSQ_DATA')
 lsqd = grlsq_form_to_lsqd(data)


 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value

 ;-----------------------------------------------
 ; get tag names, widget ids, and objects
 ;-----------------------------------------------
 tags = data.tags
 ids = data.ids

 update = 1

 case event.tag of
  ;---------------------------------------------------------
  ; 'Close' button --
  ;  Just destroy the form and forget about it
  ;---------------------------------------------------------
  'CLOSE' : $
 	begin
	 widget_control, data.base, /destroy
	 return
	end

  'MIN'   :  update = 0
  'MAX'   :  update = 0
  'EDGE'   :  update = 0
  'WIDTH'   :  update = 0

  ;---------------------------------------------------------
  ; 'Scan' button --
  ;  scan the selected object 
  ;---------------------------------------------------------
  'SCAN' : $
	begin
	 grlsq_scan, grim_data, data, stat=stat
 	 grlsq_set_entry, data.ids, data.tags, 'FIX', lsqd.fix
	 if(stat EQ 0) then lsqd.scanned = 1
	 grim_refresh, grim_data;, /use_pixmap
	 grlsq_print, data, '', /clear
	end

  ;---------------------------------------------------------
  ; 'Fit' button --
  ;  Perform a simultaneous fit 
  ;---------------------------------------------------------
  'FIT' : grlsq_fit, grim_data, data, lsqd, status=status

  ;----------------------------------------------------------------------
  ; One of the 'Fix' buttons --
  ;  If there is no planet center, make sure theta remains fixed 
  ;----------------------------------------------------------------------
  'FIX' : grlsq_set_entry, data.ids, data.tags, 'FIX', lsqd.fix

  ;----------------------------------------------------------------------
  ; 'Invert Model' --
  ;  update the model plots. 
  ;----------------------------------------------------------------------
  'INVERT' : $
	begin
         lsqd = grlsq_form_to_lsqd(data)
         data.lsqd = lsqd
 	 grlsq_scan, /noscan, grim_data, data
	end

  ;----------------------------------------------------------------------
  ; 'Algorithm' --
  ;  update the model plots. 
  ;----------------------------------------------------------------------
  'ALGORITHM' : $
	begin
         lsqd = grlsq_form_to_lsqd(data)
         data.lsqd = lsqd
 	 grlsq_scan, /noscan, grim_data, data
	end

  ;----------------------------------------------------------------------
  ; 'Model Function' --
  ;  update the model plots. 
  ;----------------------------------------------------------------------
  'MODEL_FN' : $
	begin
         lsqd = grlsq_form_to_lsqd(data)
         data.lsqd = lsqd
 	 grlsq_scan, /noscan, grim_data, data
	end

  else:
 endcase

 if(update) then grlsq_lsqd_to_form, data, lsqd
 data.lsqd = lsqd
 grim_set_user_data, grim_data, 'GRLSQ_DATA', data

end
;=============================================================================



;=============================================================================
; grlsq_primary_notify
;
;=============================================================================
pro grlsq_primary_notify, init_data_p

 grim_data = grim_get_data(/primary)
 if(NOT keyword_set(grim_data)) then return
 data = grim_get_user_data(grim_data, 'GRLSQ_DATA')
 if(NOT keyword_set(data)) then $
               grim_set_user_data, grim_data, 'GRLSQ_DATA', *init_data_p $
 else grlsq_lsqd_to_form, data, data.lsqd

end
;=============================================================================



;=============================================================================
; grlsq_cleanup
;
;=============================================================================
pro grlsq_cleanup, base

 widget_control, base, get_uvalue=data_p
 grim_rm_primary_callback, data_p

end
;=============================================================================



;=============================================================================
; gr_lsqtool
;
;=============================================================================
pro gr_lsqtool, top

 if(xregistered('gr_lsqtool')) then return

 ;-----------------------------------------------
 ; setup form widget
 ;-----------------------------------------------
 base = widget_base(title = 'GRIM Least-Squares fit', /column, group=top)

 objects = ['Limb      ', $
            'Ring      ', $
            'Terminator', $
            'Shadow    ', $
            'Reflection', $
            'Star      ', $
            'Center    ']
 nobj = n_elements(objects)
 dl_objects = objects[0]
 for i=1, nobj-1 do dl_objects = dl_objects + '|' + objects[i]

 fix = [ 'x', $
         'y', $
         'theta']
 nfix = n_elements(fix)
 button_fix = fix[0]
 for i=1, nfix-1 do button_fix = button_fix + '|' + fix[i]

 algorithms = ['Model', $
               'Grad', $
               'Grad_Norm', $
               'Half']
 nalgorithms = n_elements(algorithms)
 dl_algorithms = algorithms[0]
 for i=1, nalgorithms-1 do dl_algorithms = dl_algorithms + '|' + algorithms[i]

 model_fns = ['Auto', $
              'Atan', $
              'Nav_Limb', $
              'Nav_Ring', $
              'Psf_Ring']
 nmodel_fns = n_elements(model_fns)
 dl_model_fns = model_fns[0]
 for i=1, nmodel_fns-1 do dl_model_fns = dl_model_fns + '|' + model_fns[i]

 desc = [ $
	'1, BASE,, COLUMN', $
	'1, BASE,, COLUMN, FRAME', $
	  '0, TEXT,, LABEL_LEFT=Scan width           :  , WIDTH=15, TAG=width',$
	  '0, TEXT,, LABEL_LEFT=Edge proximity       :  , WIDTH=15, TAG=edge', $
	  '1, BASE,, ROW', $
	   '0, LABEL, Invert Model         :, LEFT', $
	   '2, BUTTON, Off|On, EXCLUSIVE , ROW, SET_VALUE=0, TAG=invert', $
	  '0, DROPLIST,' + dl_algorithms + ',SET_VALUE=0' + $
	           ',LABEL_LEFT=Algorithm            :, TAG=algorithm', $
	  '1, BASE,, COLUMN, FRAME, TAG=model_base', $
 	   '0, DROPLIST,' + dl_model_fns + ',SET_VALUE=0' + $
	           ',LABEL_LEFT=Model Function       :, TAG=model_fn', $
	   '0, TEXT,, LABEL_LEFT=Min. Correlation     :  , WIDTH=15, TAG=min', $
	   '2, TEXT,, LABEL_LEFT=Max. Correlation     :  , WIDTH=15, TAG=max', $

	  '0, BUTTON, Scan,, TAG=scan', $

	'3, BASE,, ROW, FRAME', $
	  '0, BUTTON, Fit,, TAG=fit', $
	  '0, BUTTON,' + button_fix + $
	          ', LABEL_LEFT=Fix :,ROW,TAG=fix', $
	  '2, BUTTON, Close, QUIT, TAG=close']

 form = cw__form(base, desc, ids=ids, tags=tags)
 widget_control, form, set_uvalue={ids:ids, tags:tags, objects:objects}

 w = where(strupcase(tags) EQ 'MODEL_BASE')
 model_base = ids[w[0]]
 model_draw = widget_draw(model_base, xsize=100, ysize=175)

 nids = n_elements(ids)
 for i=0, nids-1 do widget_control, ids[i], /all_text_events 

 text = widget_text(base, ysize=11, /scroll)

 ;-----------------------------------------------
 ; main data structure
 ;-----------------------------------------------
 data = { $
	;---------------
	; widgets
	;---------------
		base		:	base, $
		lsqd		:	grlsq_descriptor(), $
		form		:	form, $
		text		:	text, $
		ids		:	ids, $
		tags		:	tags, $
		algorithms	:	algorithms, $
		model_fns	:	model_fns, $
		model_draw	:	model_draw, $
		model_wnum	:	-1l, $
	;---------------
	; book keeping
	;---------------
		grim_wnum	:	!d.window $
	     }


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'gr_lsqtool', base, /no_block, cleanup='grlsq_cleanup'

 widget_control, model_draw, get_value=model_wnum
 data.model_wnum = model_wnum
 geom = widget_info(model_base, /geom)
 widget_control, model_draw, xsize=geom.xsize

 ;-----------------------------------------------------
 ; initial form settings
 ;-----------------------------------------------------
 grlsq_lsqd_to_form, data, data.lsqd

 data_p = nv_ptr_new(data)
 grim_add_primary_callback, 'grlsq_primary_notify', data_p
 widget_control, base, set_uvalue=data_p

 grim_data = grim_get_data(top)
 grim_set_user_data, grim_data, 'GRLSQ_DATA', data

end
;=============================================================================
