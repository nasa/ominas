;=============================================================================
;+
; NAME:
;	gr_maptool
;
;
; DESCRIPTION:
;	Graphical map projection tool. 
;
;
; CALLING SEQUENCE:
;	
;	gr_maptool
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
;	The gr_maptool layout consists of the following items:
;
;	 'Projection':
;		Controls which map projection to use.
;
;	 'Size':
;		Sets the size of the map in pixels.
;
;	 'Center':
;		Sets the center of the map in map units (e.g. radians for 
;		GLOBEs).  If empty, the center is computed from the GRIM pointer.
;
;	 'Uniform Scale':
;		If set, the length scale at the map center is uniform in 
;		both directions.
;
;	 'Full Range':
;		If set, the full range is used for the map instead of computing;
;		a narrower map based on the current viewport.
;
;	 'Ok':
;		Creates the map projection described by the current widget
;		settings and exits.
;
;	 'Apply':
;		Creates the map projection described by the current widget
;		settings without exiting.
;
;	 'Cancel' button
;		Exits with no map projection.		
;
; OPERATION
;	The target is selected using the GRIM pointer.  Any active objects
;	are used for hiding.  
;
;
; STATUS
;	Incomplete:
;	- grmt_compute_globe is not complete
;	- Uniform scaling not imlpemented for globe maps
;	- Should be extended to project from a map
;	- Project all visible planes and transfer plane settings
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale 7/2002
;	Reworked:	Spitale 2/2019
;	
;-
;=============================================================================



;=============================================================================
; grmt_get_target
;
;=============================================================================
function grmt_get_target, cd, bx

 raytrace, grim_get_pointer(), cd=cd, bx=bx, hit_indices=hits
 if(hits[0] EQ -1) then return, 0
 return, bx[hits[0]]
end
;=============================================================================



;=============================================================================
; grmt_get_descriptors
;
;=============================================================================
function grmt_get_descriptors, dd=dd, cd=cd, ltd=ltd, pd=pd, rd=rd, bx=bx

 ;----------------------------------------
 ; get scene
 ;----------------------------------------
 grift, dd=dd, cd=cd, ltd=ltd, bx=all_bx
 if(cor_class(cd) NE 'CAMERA') then $
  begin
   grim_message, 'Input must ba a CAMERA image.'
   return, 0
  end

 grift, /active, pd=pd, rd=rd

 ;----------------------------------------
 ; determine object to project
 ;----------------------------------------
 bx = grmt_get_target(cd, all_bx)

 ;----------------------------------------
 ; make gd
 ;----------------------------------------
 gd = {dd:	dd, $
       cd:	cd, $
       ltd:	keyword_set(ltd) ? ltd:0, $
       pd:	keyword_set(pd) ? pd:0, $
       rd:	keyword_set(rd) ? rd:0, $
       bx:	bx}

 return, gd
end
;=============================================================================



;=============================================================================
; grmt_get_md
;
;=============================================================================
function grmt_get_md, data, projection, index=index

 projections = map_projection(data.mds)
 w = where(projections EQ strupcase(projection))
 index = w[0]

 return, data.mds[index]
end
;=============================================================================



;=============================================================================
; grmt_query_setting
;
;=============================================================================
function grmt_query_setting, ids, tags, tag

 i = (where(tags EQ tag))[0]
 widget_control, ids[i], get_value=value

 return, value
end
;=============================================================================



;=============================================================================
; grmt_parse_entry
;
;=============================================================================
function grmt_parse_entry, ids, tags, tag, drop=drop

 i = (where(tags EQ tag))[0]

 if(NOT keyword__set(drop)) then $
  begin   
   widget_control, ids[i], get_value=value
   value = str_sep(strtrim(value,2), ' ')
  end $
 else value = widget_info(ids[i], /droplist_select)

 return, value
end
;=============================================================================



;=============================================================================
; grmt_set_entry
;
;=============================================================================
pro grmt_set_entry, ids, tags, tag, value, drop=drop

 i = (where(tags EQ tag))[0]

 if(NOT keyword__set(drop)) then $
         widget_control, ids[i], set_value = strtrim(value,2) + ' ' $
 else widget_control, ids[i], set_droplist_select=value

end
;=============================================================================



;=============================================================================
; grmt_form_to_md
;
;=============================================================================
function grmt_form_to_md, data, projection=projection

 class = strupcase(data.classes[ $
               grmt_parse_entry(data.ids, data.tags, 'CLASS', /drop)])

 size = long(grmt_parse_entry(data.ids, data.tags, 'SIZE'))

 center = grmt_parse_entry(data.ids, data.tags, 'CENTER')
 if(NOT keyword_set(center[0])) then center = [!values.d_nan, !values.d_nan] $
 else center = double(center)

 if(NOT keyword__set(projection)) then $
  begin
   projection_index = long(grmt_parse_entry(data.ids, data.tags, 'PROJECTION', /drop))
   projection = strupcase(data.projections[projection_index])
  end

 md = map_create_descriptors(1, $
		projection=projection, $
		center=center, $
		size=size, $
                origin=size/2d)

 cor_set_udata, md, 'CLASS', class

 return, md
end
;=============================================================================



;=============================================================================
; grmt_md_to_form
;
;=============================================================================
pro grmt_md_to_form, data, md

 grmt_set_entry, data.ids, data.tags, 'SIZE', map_size(md)

 center = map_center(md)
 w = where(finite(center))
 if(w[0] EQ -1) then center = ''
 grmt_set_entry, data.ids, data.tags, 'CENTER', center

 projection_index = (where(strupcase(data.projections) EQ map_projection(md)))[0]
 grmt_set_entry, data.ids, data.tags, 'PROJECTION', projection_index, /drop

 data.last_projection = data.projections[projection_index]
 widget_control, data.base, set_uvalue=data

end
;=============================================================================



;=============================================================================
; grmt_compute_globe
;
;=============================================================================
function grmt_compute_globe, data, md

 ;----------------------------------------
 ; get settings
 ;----------------------------------------
 gd = grmt_get_descriptors(dd=dd, cd=cd, bx=pd)
 uniform = grmt_query_setting(data.ids, data.tags, 'UNIFORM')
 full = grmt_query_setting(data.ids, data.tags, 'FULL')


 ;----------------------------------------
 ; get map center
 ;----------------------------------------
 center = map_center(md)
 w = where(finite(center))
 if(w[0] EQ -1) then $
  begin
   center_image = grim_get_pointer()
   center_globe = image_to_globe(cd, pd, center_image)
  end $
 else center_globe = double(center)


 ;----------------------------------------
 ; get map scale
 ;----------------------------------------
 size = map_size(md)
 glb_image_bounds, cd, pd, $
    latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax, /viewport
 reslat = 1.1*abs(latmax-latmin)/size[1]
 reslon = 1.1*abs(lonmax-lonmin)/size[0]


; ;----------------------------------------
; ; correction for uniform scaling
; ;----------------------------------------
; if(uniform) then $
;  begin
;  end


 ;----------------------------------------
 ; implement full map
 ;----------------------------------------
 if(full) then $
  begin
   center_globe = [0d,0d]
   reslat = !dpi/size[1]
   reslon = 2d*!dpi/size[0]
  end


 ;----------------------------------------
 ; update map descriptor
 ;----------------------------------------
 map_assign, md, $
      center=center_globe[0:1]

 return, md
end
;=============================================================================



;=============================================================================
; grmt_compute_disk
;
;=============================================================================
function grmt_compute_disk, data, md

 ;----------------------------------------
 ; get settings
 ;----------------------------------------
 gd = grmt_get_descriptors(dd=dd, cd=cd, bx=rd)
 uniform = grmt_query_setting(data.ids, data.tags, 'UNIFORM')
 full = grmt_query_setting(data.ids, data.tags, 'FULL')


 ;----------------------------------------
 ; get map center
 ;----------------------------------------
 center = map_center(md)
 w = where(finite(center))
 if(w[0] EQ -1) then $
  begin
   center_device = 0.5*[!d.x_size, !d.y_size]
   center_image = (convert_coord(/device, /to_data, center_device))[0:1]
   center_disk = image_to_disk(cd, rd, center_image)
  end $
 else center_disk = double(center)


 ;----------------------------------------
 ; get map scale
 ;----------------------------------------
 size = map_size(md)
 dsk_image_bounds, cd, rd, $
    radmin=radmin, radmax=radmax, lonmin=lonmin, lonmax=lonmax, /viewport
 resrad = 1.1*abs(radmax-radmin)/size[1]
 reslon = 1.1*abs(lonmax-lonmin)/size[0]


 ;----------------------------------------
 ; correction for uniform scaling
 ;----------------------------------------
 if(uniform) then $
  begin
   urad = reslon*center_disk[0]
   ulon = resrad/center_disk[0]
   if(urad GT ulon) then resrad = urad $
   else reslon = ulon
  end


 ;----------------------------------------
 ; implement full map
 ;----------------------------------------
 if(full) then $
  begin
   sma = (dsk_sma(rd))[0,*]
   center_disk = [mean(sma),0d]
   resrad = (sma[1]-sma[0])/size[1]
   reslon = 2d*!dpi/size[0]
  end


 ;----------------------------------------
 ; update map descriptor
 ;----------------------------------------
 map_assign, md, $
      center=center_disk[0:1], $
      units=map_units_disk(md, resrad=resrad, reslon=reslon)

 return, md
end
;=============================================================================



;=============================================================================
; grmt_compute
;
;=============================================================================
function grmt_compute, data, bx

 md = grmt_form_to_md(data)

 classes = cor_tree(bx)
 for i=0, n_elements(classes)-1 do $
  begin
   fn = 'grmt_compute_' + strlowcase(classes[i])
   if(routine_exists(fn)) then return, call_function(fn, data, md)
  end

 return, !null
end
;=============================================================================



;=============================================================================
; grmt_cleanup
;
;=============================================================================
pro grmt_cleanup, base

 widget_control, base, get_uvalue=data

 grim_rm_refresh_callback, data.cb_data_p

end
;=============================================================================



;=============================================================================
; grmt_refresh_callback
;
;=============================================================================
pro grmt_refresh_callback, data_p
 @grim_block.include
return

 if(NOT ptr_valid(data_p)) then return
 
 data = *data_p 
 w1 = where(data.tags EQ 'PROJECT')
 w2 = where(data.tags EQ 'OK')

 if(NOT widget_info(data.ids[w1], /valid_id)) then return
 if(NOT widget_info(data.ids[w2], /valid_id)) then return

 gd = grmt_get_descriptors(dd=dd, cd=cd, ltd=ltd, pd=pd, rd=rd)

 if((NOT keyword__set(cd)) OR $
    (NOT keyword__set(pd)) OR $
    (NOT keyword__set(ltd))) then $
  begin
;   widget_control, data.ids[w1], sensitive=0
;   widget_control, data.ids[w2], sensitive=0
  end $
 else $
  begin
;   widget_control, data.ids[w1], sensitive=1
;   widget_control, data.ids[w2], sensitive=1
  end


end
;=============================================================================



;=============================================================================
; grmt_project_globe
;
;=============================================================================
function grmt_project_globe, gd, md, map_pd=map_pd, map_rd=map_rd

 if(keyword_set(gd.rd)) then $
  begin
   hide_bx = gd.rd
   hide_fn = make_array(n_elements(gd.rd), val='pm_hide_ring')
  end

 cor_set_name, md, cor_name(gd.bx)
 map_pd = gd.bx

 aux= ['EMM']

 dd_map = pg_map(gd.dd, /float, $
            md=md, $
            cd=gd.cd, $
            ltd=gd.ltd, $
            gbx=gd.bx, aux=['EMM'], $
            hide_fn=hide_fn, hide_bx=hide_bx)

 return, dd_map
end
;=============================================================================



;=============================================================================
; grmt_project_disk
;
;=============================================================================
function grmt_project_disk, gd, md, map_pd=map_pd, map_rd=map_rd

 if(keyword_set(gd.pd)) then $
  begin
   hide_bx = gd.pd
   hide_fn = make_array(n_elements(gd.pd), val='pm_hide_globe')
  end

 cor_set_name, md, cor_name(gd.bx)

 dd_map = pg_map(gd.dd, bx=gd.bx, /float, $
            md=md, $
            cd=gd.cd, $
            ltd=gd.ltd, $
            gbx=gd.pd, $
            hide_fn=hide_fn, hide_bx=hide_bx)

 map_rd = gd.bx

 return, dd_map
end
;=============================================================================



;=============================================================================
; grmt_project
;
;=============================================================================
function grmt_project, gd, md, map_pd=map_pd, map_rd=map_rd

 classes = cor_tree(gd.bx)
 for i=0, n_elements(classes)-1 do $
  begin
   fn = 'grmt_project_' + strlowcase(classes[i])
   if(routine_exists(fn)) then $
                 return, call_function(fn, gd, md, map_pd=map_pd, map_rd=map_rd)
  end

 return, !null
end
;=============================================================================



;=============================================================================
; grmt_create_map
;
;=============================================================================
pro grmt_create_map, data, md

 ;-----------------------------------
 ; get scene descriptors
 ;-----------------------------------
 gd = grmt_get_descriptors(dd=dd, cd=cd, ltd=ltd, pd=pd, rd=rd, bx=bx)
 if(NOT keyword_set(gd)) then return

 if(NOT keyword__set(bx)) then $
  begin
   grim_message, 'No target under the pointer.'
   return
  end
 
 if(NOT keyword__set(cd)) then $
  begin
   grim_message, 'No camera descriptor.'
   return
  end

 if(NOT keyword__set(ltd)) then $
  begin
   grim_message, 'No light descriptor.'
   return
  end


 ;-----------------------------------
 ; compute map descriptor
 ;-----------------------------------
 md = grmt_compute(data, bx)


 ;-----------------------------------
 ; project map
 ;-----------------------------------
 widget_control, /hourglass
; grift, pn=pn, /visible
; for i=0, n_elements(pn)-1 do $
;   dd_map = append_array(dd_map, grmt_project(gd, md, map_pd=map_pd, map_rd=map_rd))

 dd_map = grmt_project(gd, md, map_pd=map_pd, map_rd=map_rd)


 ;-----------------------------------
 ; open map in grim
 ;-----------------------------------
 if(cor_class(cd) NE 'MAP') then od = cd
 grim, /new, /no_primary, dd_map, cd=md, od=od, ltd=ltd, pd=map_pd, rd=map_rd, $
              /tiepoint_sync, /curve_sync, order=1-data.order, $
              title=map_projection(md) + ' ' + cor_name(dd)

end
;=============================================================================



;=============================================================================
; gr_maptool_event
;
;=============================================================================
pro gr_maptool_event, event

 ;-----------------------------------------------
 ; get map form base and grim data structure
 ;-----------------------------------------------
 base = event.top
 widget_control, base, get_uvalue=data

 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value

 ;-----------------------------------------------
 ; get tag names, widget ids, and projections
 ;-----------------------------------------------
 tags = data.tags
 ids = data.ids
 projections = data.projections

 case event.tag of
  ;---------------------------------------------------------
  ; 'Close' button --
  ;  Just destroy the form and forget about it
  ;---------------------------------------------------------
  'CLOSE' :  widget_control, base, /destroy

  ;---------------------------------------------------------
  ; 'Project' button --
  ;  Create a map projection using the current settings.
  ;---------------------------------------------------------
  'PROJECT' : $
	begin
	 md = grmt_form_to_md(data)
	 grmt_create_map, data, md
	end

  ;---------------------------------------------------------
  ; 'Ok' button --
  ;  Create a map projection using the current settings
  ;  and destroy form.
  ;---------------------------------------------------------
  'OK' : $
	begin
	 md = grmt_form_to_md(data)
	 grmt_create_map, data, md
	 widget_control, base, /destroy
	end

  ;---------------------------------------------------------------
  ; Projection --
  ;  Save the current settings in the appropriate map descriptor
  ;  and restore the displayed settings to those of the new map 
  ;  descriptor.
  ;---------------------------------------------------------------
  'PROJECTION' : $
	begin
	 md_form = grmt_form_to_md(data, projection=data.last_projection)
	 md = grmt_get_md(data, data.last_projection, index=index)
	 nv_copy, md, md_form

	 md = grmt_get_md(data, projections[value.projection])
         grmt_md_to_form, data, md

	 widget_control, base, set_uvalue=data
	end
  else:
 endcase



end
;=============================================================================



;=============================================================================
; gr_maptool
;
;  - remove parameter entry and auto button
;  - always compute md based on current view
;  - remove globe/disk droplist, determine based on active xd.
;
;=============================================================================
pro gr_maptool, order=order

; need to desensitize projetions that don't apply to disks


 if(xregistered('gr_maptool')) then return


 ;-----------------------------------------------
 ; setup map form widget
 ;-----------------------------------------------
 base = widget_base(title = 'GRIM Map projection', group=top)

 classes = ['Globe', $
            'Disk']
 nclasses = n_elements(classes)
 dl_classes = classes[0]
 for i=1, nclasses-1 do dl_classes = dl_classes + '|' + classes[i]

 projections = ['Rectangular', $
          'Mercator', $
          'Orthographic', $
          'Stereographic'];, $
;          'Sinusoidal', $
;          'Mollweide', $
;          'Oblique Disk']
 nprojections = n_elements(projections)
 dl_projections = projections[0]
 for i=1, nprojections-1 do dl_projections = dl_projections + '|' + projections[i]

 desc = [ $
	'1, BASE,, COLUMN, FRAME', $
	  '0, DROPLIST,' + dl_projections + ',SET_VALUE=0' + $
	           ',LABEL_LEFT=Projection       :, TAG=projection', $
	  '0, TEXT,, LABEL_LEFT=Size             :   , WIDTH=20, TAG=size', $
	  '0, TEXT,, LABEL_LEFT=Center           :   , WIDTH=20, TAG=center', $
	  '1, BASE,, ROW', $
	   '0, LABEL,           Uniform Scale    :, LEFT', $
	   '2, BUTTON, Off|On, EXCLUSIVE , ROW, SET_VALUE=0, TAG=uniform', $
	  '1, BASE,, ROW', $
	   '0, LABEL,           Full Range       :, LEFT', $
	   '2, BUTTON, Off|On, EXCLUSIVE , ROW, SET_VALUE=0, TAG=full', $
	'1, BASE,, ROW, FRAME', $
	  '0, BUTTON, Ok, QUIT, TAG=ok', $
	  '0, BUTTON, Project,, TAG=project', $
	  '2, BUTTON, Close, QUIT, TAG=close']

 form = cw__form(base, desc, ids=ids, tags=tags)
 widget_control, form, set_uvalue={ids:ids, tags:tags, projections:projections}


 ;-----------------------------------------------
 ; main data structure
 ;-----------------------------------------------
 data = { $
	;---------------
	; widgets
	;---------------
		base		:	base, $
		form		:	form, $
		ids		:	ids, $
		tags		:	tags, $
		projections	:	projections, $
		classes		:	classes, $
		order		:	order, $
	;---------------
	; book keeping
	;---------------
		last_projection	:	'', $
		cb_data_p	:	nv_ptr_new(), $
	;-----------------------------
	; default map descriptors
	;-----------------------------
		mds 		:	[ map_create_descriptors(1,$
					   projection='RECTANGULAR', $
					   center = [!values.d_nan, !values.d_nan], $
					   size = [800,400]), $
					  map_create_descriptors(1,$
					   projection='MERCATOR', $
					   center = [!values.d_nan, !values.d_nan], $
					   size = [800,400]), $
					  map_create_descriptors(1,$
					   projection='ORTHOGRAPHIC', $
					   center = [!values.d_nan, !values.d_nan], $
					   size = [400,400]), $
					  map_create_descriptors(1,$
					   projection='STEREOGRAPHIC', $
					   center = [!values.d_nan, !values.d_nan], $
					   size = [400,400])   ]$;, $
;					  map_create_descriptors(1,$
;					   projection='SINUSOIDAL', $
;					   center = [!values.d_nan, !values.d_nan], $
;					   size = [800,400]), $
;					  map_create_descriptors(1,$
;					   projection='MOLLWEIDE', $
;					   center = [!values.d_nan, !values.d_nan], $
;					   size = [800,400]), $
;					  map_create_descriptors(1,$
;					   projection='OBLIQUE_DISK', $
;					   center = [!values.d_nan, !values.d_nan], $
;					   size = [400,400]) ] $ 
	     }

 data.projections = map_projection(data.mds)
 widget_control, base, set_uvalue=data

 data.cb_data_p = nv_ptr_new(data)
 grim_add_refresh_callback, 'grmt_refresh_callback', data.cb_data_p
 grmt_refresh_callback, data.cb_data_p


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'gr_maptool', base, /no_block, cleanup='grmt_cleanup'

 ;-----------------------------------------------------
 ; initial form settings
 ;-----------------------------------------------------
 grmt_md_to_form, data, grmt_get_md(data, 'RECTANGULAR') 


end
;=============================================================================
