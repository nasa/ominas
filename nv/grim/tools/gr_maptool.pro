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
;	 Map projection control:
;		A map projection is selected using the droplist and 
;		the map parameters are input using the text widgets below.
;		Angles are in radians.
;
;	'Ok' button:
;		Creates the map projection described by the current widget
;		settings and exits.
;
;	'Apply' button:
;		Creates the map projection described by the current widget
;		settings without exiting.
;
;	'Cancel' button
;		Exits with no map projection.		
;
;
;
; OPERATION:
;	gr_ maptool allows the user to create map projections of images
;	using a simple graphical interface.  It is most easily run from within
;	GRIM, but may be run directly from the command line as well.
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
; grmt_create_map
;
;=============================================================================
pro grmt_create_map, data, md

 grift, dd=dd, cd=cd, ltd=ltd, pd=all_pd
 grift, /active, pd=pd, rd=rd
 class = cor_udata(md, 'CLASS')
 
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
 ; project map
 ;-----------------------------------
 widget_control, /hourglass

 case class of
  'GLOBE' : $
	begin
	 if(keyword_set(rd)) then $
	  begin
	   hide_fn = 'pm_hide_ring'
           hide_bx = rd
	  end

	 if(keyword_set(pd)) then $
          begin
           cor_set_name, md, cor_name(pd[0])
           gbx = pd[0]
	   map_pd = pd[0]
          end $
;         else cor_set_name, md, cor_name(cd)
         else $
          begin
           grim_message, 'No planet descriptor.'
           return
          end

	 aux= ['EMM']

	 dd_map = pg_map(dd, $
                    md=md, $
                    cd=cd, $
                    ltd=ltd, $
                    gbx=gbx, aux=['EMM'], $
                    hide_fn=hide_fn, hide_bx=hide_bx)
	end

  'DISK' : $
	begin
; need to sort out the map units...
 grim_message, 'Not complete.'
 return

	 if(NOT keyword_set(rd)) then $
	  begin
	   grim_message, 'No active ring descriptor.'
	   return
	  end
	 if(NOT keyword_set(all_pd)) then $
	  begin
	   grim_message, 'No globe descriptor.'
	   return
	  end

	 cor_set_name, md, cor_name(rd[0])

	 dd_map = pg_map(dd, bx=rd[0], $
                    md=md, $
                    cd=cd, $
                    ltd=ltd, $
                    gbx=all_pd, $
                    hide_fn=hide_fn, hide_bx=hide_bx)

	 map_rd = rd[0]
	end

 endcase


 ;-----------------------------------
 ; open map in grim
 ;-----------------------------------
 if(cor_class(cd) NE 'MAP') then od = cd
 grim, /new, dd_map, cd=md, od=od, ltd=ltd, pd=map_pd, rd=map_rd, $
              /tiepoint_sync, /curve_sync, order=1-data.order, $
              title=map_projection(md) + ' ' + cor_name(dd)


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
 scale = double(grmt_parse_entry(data.ids, data.tags, 'SCALE'))
 origin = double(grmt_parse_entry(data.ids, data.tags, 'ORIGIN'))

 units = double(grmt_parse_entry(data.ids, data.tags, 'UNITS'))
 center = double(grmt_parse_entry(data.ids, data.tags, 'CENTER'))

 if(class EQ 'DISK') then center[1] = center[1] * !dpi/180d $
 else center = center * !dpi/180d

 if(NOT keyword__set(projection)) then $
  begin
   projection_index = long(grmt_parse_entry(data.ids, data.tags, 'PROJECTION', /drop))
   projection = strupcase(data.projections[projection_index])
  end

 md = map_create_descriptors(1, $
		projection=projection, $
		size=size, $
		scale=scale, $
		origin=origin, $
		units=units, $
		center=center)

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
 grmt_set_entry, data.ids, data.tags, 'SCALE', map_scale(md)

 origin = strtrim(map_origin(md), 2)
 grmt_set_entry, data.ids, data.tags, 'ORIGIN', strmid(origin, 0, 6)

 units = strtrim(map_units(md), 2)
 grmt_set_entry, data.ids, data.tags, 'UNITS', strmid(units, 0, 6)

 center = strtrim(map_center(md) * 180d/!dpi, 2)
 grmt_set_entry, data.ids, data.tags, 'CENTER', strmid(center, 0, 6)

 projection_index = (where(strupcase(data.projections) EQ map_projection(md)))[0]
 grmt_set_entry, data.ids, data.tags, 'PROJECTION', projection_index, /drop

 data.last_projection = data.projections[projection_index]
 widget_control, data.base, set_uvalue=data

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


 if(NOT ptr_valid(data_p)) then return
 
 data = *data_p 
 w1 = where(data.tags EQ 'PROJECT')
 w2 = where(data.tags EQ 'OK')

 if(NOT widget_info(data.ids[w1], /valid_id)) then return
 if(NOT widget_info(data.ids[w2], /valid_id)) then return

 grift, dd=dd, cd=cd, ltd=ltd
 grift, /active, pd=pd, rd=rd

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
  ; 'Class' button --
  ;---------------------------------------------------------
  'CLASS' :  

  ;---------------------------------------------------------
  ; 'Auto' button --
  ;  Compute optimal map params based on current grim view.
  ;---------------------------------------------------------
  'AUTO' : $
	begin
	 md = grmt_form_to_md(data)
	 class = cor_udata(md, 'CLASS')
	 case class of
	  'GLOBE' : $
	 	begin
;		 md = grmt_form_to_md(data)
;		 md = map_optimize(md=md, $
;		       lon=[lonmin,lonmax], $
;		       lat=[latmin,latmax])



;		 md = map_create_descriptors(1, $
;;			projection=projection, $
;;			size=size, $
;			scale=scale, $
;;			origin=origin, $
;			units=units, $
;			center=center)
;	         grmt_md_to_form, data, md
;		 widget_control, base, set_uvalue=data
		end
	  'DISK' : $
		begin
		end
	 endcase
	end

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
  ;  Save the current setting in the appropriate map descriptor
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

  ;---------------------------------------------------------
  ; 'Size' value --
  ;  Automatically change map origin
  ;---------------------------------------------------------
  'SIZE' : $
	begin
	 md = grmt_form_to_md(data)
	 map_set_origin, md, double(map_size(md))/2d
         grmt_md_to_form, data, md
	end

  else:
 endcase



end
;=============================================================================



;=============================================================================
; gr_maptool
;
;=============================================================================
pro gr_maptool, order=order

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
	  '0, DROPLIST,' + dl_classes + ',SET_VALUE=0' + $
	           ',LABEL_LEFT=Class            :, TAG=class', $
	  '0, DROPLIST,' + dl_projections + ',SET_VALUE=0' + $
	           ',LABEL_LEFT=Projection       :, TAG=projection', $
	  '0, TEXT,, LABEL_LEFT=Size             :   , WIDTH=20, TAG=size', $
	    '1, BASE,, ROW, FRAME', $
	    '2, BUTTON, Auto,, TAG=auto', $
;	    '2, BUTTON, Select,, TAG=select', $
	  '0, TEXT,, LABEL_LEFT=  Origin         :   , WIDTH=20, TAG=origin', $
	  '0, TEXT,, LABEL_LEFT=  Scale          :   , WIDTH=20, TAG=scale', $
	  '0, TEXT,, LABEL_LEFT=  Center(deg)    :   , WIDTH=20, TAG=center', $
	  '0, TEXT,, LABEL_LEFT=  Units(rad/unit):   , WIDTH=20, TAG=units', $
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
					   size = [800,400]), $
					  map_create_descriptors(1,$
					   projection='MERCATOR', $
					   size = [800,400]), $
					  map_create_descriptors(1,$
					   projection='ORTHOGRAPHIC', $
					   size = [400,400]), $
					  map_create_descriptors(1,$
					   projection='STEREOGRAPHIC', $
					   size = [400,400])   ]$;, $
;					  map_create_descriptors(1,$
;					   projection='SINUSOIDAL', $
;					   size = [800,400]), $
;					  map_create_descriptors(1,$
;					   projection='MOLLWEIDE', $
;					   size = [800,400]), $
;					  map_create_descriptors(1,$
;					   projection='OBLIQUE_DISK', $
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
