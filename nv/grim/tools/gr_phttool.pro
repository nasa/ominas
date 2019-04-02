;=============================================================================
;+
; NAME:
;	gr_phttool
;
;
; DESCRIPTION:
;	Graphical photometric correction tool. 
;
;
; CALLING SEQUENCE:
;	
;	gr_phttool
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
; ENVIRONMENT VARIABLES:
;	GR_PHT_DIR:	Sets the directory in which to find the photometric 
;			functions.
;
;
; LAYOUT:
;	The gr_phttool layout consists of the following items:
;
;	 Reflectance function controls:
;		A reflectance function is selected using the droplist and 
;		the relevant parameters (whose purpose depend on the specific
;		function) are input using the text widgets below.
;
;	 Phase function controls:
;		A phase function is selected using the droplist and 
;		the relevant parameters (whose purpose depend on the specific
;		function) are input using the text widgets below. 
;
;	   Reflectance and phase functions are determined by looking for any
;	   complied function whose name starts with 'pht_refl_' or 'pht_phase',
;	   or any routines in the directory pointed to by the environment variable
;	   GR_PHT_DIR. The function lists may be updated using the corresponding 
;	   'Refresh' button.  The calling sequences are as follows:
;
;	   refl_corr = refl_fn(mu, mu0, refl_parm)
;	   phase_corr = phase_fn(g, phase_parm)
;
;	   where the photometric arguments are all cosines, and the *_parm 
;	   arguments come from the corresponding input text widgets.
;
;
;	'Ok' button:
;		Applies the photometric correction described by the current
;		widget settings and exits.  
;
;	'Apply' button:
;		Applies the photometric correction described by the current
;		widget settings without exiting.  
;
;	'Apply All' button:
;		Applies the photometric correction described by the current
;		widget settings to all planes of the primary grim window for
;		which outline points have been activated. 
;
;	'Cancel' button
;		Exits with no photometric correction.		
;
;
;
; OPERATION:
;	gr_phttool allows the user to apply photometric corrections to images
;	using a simple graphical interface.  Corrections are applied to data 
;	within any active limb points.  
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
; pht_descriptor__define
;
;=============================================================================
pro pht_descriptor__define

 struct = $
    { pht_descriptor, $
	 refl_fn	:	'', $
	 phase_fn	:	'', $
	 n_refl_parm	:	0, $
	 n_phase_parm	:	0, $
	 refl_parm_p	:	nv_ptr_new(), $
	 phase_parm_p	:	nv_ptr_new() $
	}

end
;=============================================================================



;=============================================================================
; grpht_get_prefix
;
;=============================================================================
function grpht_get_prefix, type
 return, 'pht_' + type + '_'
end
;=============================================================================



;=============================================================================
; grpht_descriptor
;
;=============================================================================
function grpht_descriptor, refl_fn=refl_fn, phase_fn=phase_fn, $
            refl_parm=refl_parm, phase_parm=phase_parm, $
            n_refl_parm=n_refl_parm, n_phase_parm=n_phase_parm

 phtd = {pht_descriptor}
 phtd.refl_parm_p = nv_ptr_new([0,0,0])
 phtd.phase_parm_p = nv_ptr_new([0,0,0])

 if(keyword_set(refl_fn)) then phtd.refl_fn = refl_fn
 if(keyword_set(phase_fn)) then phtd.phase_fn = phase_fn
 if(keyword_set(refl_parm)) then *phtd.refl_parm_p = refl_parm
 if(keyword_set(phase_parm)) then *phtd.phase_parm_p = phase_parm
 if(keyword_set(n_refl_parm)) then phtd.n_refl_parm = n_refl_parm
 if(keyword_set(n_phase_parm)) then phtd.n_phase_parm = n_phase_parm

 return, phtd
end
;=============================================================================



;=============================================================================
; grpht_get_phtd
;
;=============================================================================
function grpht_get_phtd, data, refl_fn, index=index

 refl_fns = data.phtds.refl_fn
 w = where(refl_fns EQ strupcase(refl_fn))
 index = w[0]

 return, data.phtds[index]
end
;=============================================================================



;=============================================================================
; grpht_apply_correction
;
;=============================================================================
pro grpht_apply_correction, data, phtd, dd, cd, pd, ltd, outline_ptd

 ;-----------------------------------
 ; compute correction
 ;-----------------------------------
 refl_fn = grpht_get_prefix('refl') + phtd.refl_fn
 phase_fn = grpht_get_prefix('phase') + phtd.phase_fn

 widget_control, /hourglass
 dd_cor = pg_photom(dd, cd=cd, gbx=pd[0], ltd=ltd[0], outline=outline_ptd, $
             refl_fn=refl_fn, refl_parm=*phtd.refl_parm_p, $
             phase_fn=phase_fn, phase_parm=*phtd.phase_parm_p, /over)

end
;=============================================================================



;=============================================================================
; grpht_apply_correction_primary
;
;=============================================================================
pro grpht_apply_correction_primary, grim_data, data, phtd
@pnt_include.pro

 plane = grim_get_plane(grim_data)

 ;---------------------------
 ; get data
 ;----------------------------
 limb_ptd = grim_ptd(plane, /limb, /active)
 if(NOT keyword_set(limb_ptd)) then $
  begin
   grim_message, 'No active limb points.'
   return
  end

 outline_ptd = nv_clone(limb_ptd[0])
 flags = pnt_flags(outline_ptd) & flags[*] = NOT PTD_MASK_INVISIBLE & pnt_set_flags, outline_ptd, flags

 grift, dd=dd, cd=cd, ltd=ltd
 grift, /active, pd=pd

 if(NOT keyword_set(cd)) then $
  begin
   grim_message, 'No camera descriptor.'
   return
  end
 
 if(NOT keyword_set(pd)) then $
  begin
   grim_message, 'No active planet descriptor.'
   return
  end

 if(NOT keyword_set(ltd)) then $
  begin
   grim_message, 'No light descriptor.'
   return
  end

 ;----------------------------
 ; apply correction
 ;----------------------------
 grpht_apply_correction, data, phtd, dd, cd, pd, ltd, outline_ptd

 nv_free, outline_ptd
end
;=============================================================================



;=============================================================================
; grpht_apply_correction_all
;
;=============================================================================
pro grpht_apply_correction_all, grim_data, data, phtd

 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 for i=0, nplanes-1 do $
  begin
   grift, pn=i, dd=dd, cd=cd, ltd=ltd
   grift, pn=i, /active, pd=pd, limb_ptd=limb_ptd
   apply = 1

   ;---------------------------
   ; get data
   ;----------------------------
   if(NOT keyword__set(limb_ptd)) then apply = 0 $
   else outline_ptd = (limb_ptd)[0]

   if(NOT keyword__set(cd)) then apply = 0
   if(NOT keyword__set(pd)) then apply = 0 
   if(NOT keyword__set(ltd)) then apply = 0

   ;----------------------------
   ; apply correction
   ;----------------------------
   if(apply) then $
         grpht_apply_correction, data, phtd, dd, cd, pd, ltd, outline_ptd
  end


end
;=============================================================================



;=============================================================================
; grpht_parse_entry
;
;=============================================================================
function grpht_parse_entry, ids, tags, tag, null=null, drop=drop

 i = (where(tags EQ tag))[0]

 if(NOT keyword__set(drop)) then $
  begin   
   widget_control, ids[i], get_value=value

   null = 1
   if((strmid(value, 0, 1))[0] EQ '-') then return, 0
   null = 0

   if(size(value, /type) EQ 7) then value = str_sep(strtrim(value,2), ' ')
  end $
 else value = widget_info(ids[i], /droplist_select)


 return, value
end
;=============================================================================



;=============================================================================
; grpht_set_entry
;
;=============================================================================
pro grpht_set_entry, ids, tags, tag, value, drop=drop

 i = (where(tags EQ tag))[0]

 if(NOT keyword__set(drop)) then $
             widget_control, ids[i], set_value = strtrim(value,2) + ' ' $
 else widget_control, ids[i], set_droplist_select=value

end
;=============================================================================



;=============================================================================
; grpht_form_to_phtd
;
;=============================================================================
function grpht_form_to_phtd, data, refl_fn=refl_fn

 refl_parm0 = $
      double(grpht_parse_entry(data.ids, data.tags, 'REFL_PARM0', null=null0))
 refl_parm1 = $
      double(grpht_parse_entry(data.ids, data.tags, 'REFL_PARM1', null=null1))
 refl_parm2 = $
      double(grpht_parse_entry(data.ids, data.tags, 'REFL_PARM2', null=null2))

 n_refl = 0
 w = where([null0, null1, null2] NE 1)
 if(w[0] NE -1) then n_refl = n_elements(w)


 phase_parm0 = $
      double(grpht_parse_entry(data.ids, data.tags, 'PHASE_PARM0', null=null0))
 phase_parm1 = $
      double(grpht_parse_entry(data.ids, data.tags, 'PHASE_PARM1', null=null1))
 phase_parm2 = $
      double(grpht_parse_entry(data.ids, data.tags, 'PHASE_PARM2', null=null2))

 n_phase = 0
 w = where([null0, null1, null2] NE 1)
 if(w[0] NE -1) then n_phase = n_elements(w)


 if(NOT keyword__set(refl_fn)) then $
  begin
   refl_fn_index = $
          long(grpht_parse_entry(data.ids, data.tags, 'REFL_FN', /drop))
   refl_fn = strupcase(data.refl_fns[refl_fn_index])
  end

 phase_fn_index = $
        long(grpht_parse_entry(data.ids, data.tags, 'PHASE_FN', /drop))
 phase_fn = strupcase(data.phase_fns[phase_fn_index])


 return, grpht_descriptor( $
		refl_fn=refl_fn, $
		phase_fn=phase_fn, $
		n_refl=n_refl, $
		n_phase=n_phase, $
		refl_parm=[refl_parm0, refl_parm1, refl_parm2], $
		phase_parm=[phase_parm0, phase_parm1, phase_parm2])
end
;=============================================================================



;=============================================================================
; grpht_get_functions
;
;=============================================================================
function grpht_get_functions, type, default=_default

 default = 'minneart'
 if(type EQ 'phase') then default = 'isotropic'

 prefix = grpht_get_prefix(type)
 default = prefix + default

 which, default, output=output
 split_filename, output, dir, name

 env_dir = getenv('GR_PHT_DIR')

 names_dir = get_pro_by_prefix(prefix, dir=dir)
 names_dir = names_dir[where(names_dir NE prefix+'corr')]
 names_env_dir = get_pro_by_prefix(prefix, dir=env_dir)
 names_comp = get_pro_by_prefix(prefix)

 names = append_array(names_dir, names_comp)
 ss = sort(names)
 names = names[ss]
 uu = uniq(names)
 names = names[uu]

 if(n_elements(names) GT 1) then $
  begin
   w = where(strlowcase(names) EQ strlowcase(default))
   if(w[0] NE -1) then names = append_array(default, rm_list_item(names, w[0]))
  end

 names = strmid(names, strlen(prefix), 1000)
 return, names
end
;=============================================================================



;=============================================================================
; grpht_refresh_fn
;
;=============================================================================
pro grpht_refresh_fn, data, type
 w = where(data.tags EQ strupcase(TYPE) + '_FN')
 widget_control, data.ids[w], set_value=strupcase(grpht_get_functions(type))
end
;=============================================================================



;=============================================================================
; grpht_phtd_to_form
;
;=============================================================================
pro grpht_phtd_to_form, data, phtd

 null = '-------------'

 grpht_set_entry, data.ids, data.tags, 'REFL_PARM0', (*phtd.refl_parm_p)[0]
 grpht_set_entry, data.ids, data.tags, 'REFL_PARM1', (*phtd.refl_parm_p)[1]
 grpht_set_entry, data.ids, data.tags, 'REFL_PARM2', (*phtd.refl_parm_p)[2]

 if(phtd.n_refl_parm LE 0) then $
         grpht_set_entry, data.ids, data.tags, 'REFL_PARM0', null
 if(phtd.n_refl_parm LE 1) then $
         grpht_set_entry, data.ids, data.tags, 'REFL_PARM1', null
 if(phtd.n_refl_parm LE 2) then $
         grpht_set_entry, data.ids, data.tags, 'REFL_PARM2', null

 grpht_set_entry, data.ids, data.tags, 'PHASE_PARM0', (*phtd.phase_parm_p)[0]
 grpht_set_entry, data.ids, data.tags, 'PHASE_PARM1', (*phtd.phase_parm_p)[1]
 grpht_set_entry, data.ids, data.tags, 'PHASE_PARM2', (*phtd.phase_parm_p)[2]

 if(phtd.n_phase_parm LE 0) then $
         grpht_set_entry, data.ids, data.tags, 'PHASE_PARM0', null
 if(phtd.n_phase_parm LE 1) then $
         grpht_set_entry, data.ids, data.tags, 'PHASE_PARM1', null
 if(phtd.n_phase_parm LE 2) then $
         grpht_set_entry, data.ids, data.tags, 'PHASE_PARM2', null

 refl_fn_index = (where(strupcase(data.refl_fns) EQ phtd.refl_fn))[0]
 grpht_set_entry, data.ids, data.tags, 'REFL_FN', refl_fn_index, /drop

 phase_fn_index = (where(strupcase(data.phase_fns) EQ phtd.phase_fn))[0]
 grpht_set_entry, data.ids, data.tags, 'PHASE_FN', phase_fn_index, /drop

 data.last_refl_fn = data.refl_fns[refl_fn_index]

end
;=============================================================================



;=============================================================================
; gr_phttool_event
;
;=============================================================================
pro gr_phttool_event, event

 ;-----------------------------------------------
 ; get pht form base and data structure
 ;-----------------------------------------------
 grim_data = grim_get_data(/primary)
 if(NOT keyword_set(grim_data)) then return
 data = grim_get_user_data(grim_data, 'GRPHT_DATA')
 phtd = grpht_form_to_phtd(data)

 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value

 ;-----------------------------------------------
 ; get tag names, widget ids, and fns
 ;-----------------------------------------------
 tags = data.tags
 ids = data.ids
 refl_fns = data.refl_fns
 phase_fns = data.phase_fns

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

  'PHASE_PARM0'   :  update = 0
  'PHASE_PARM1'   :  update = 0
  'PHASE_PARM2'   :  update = 0

  'REFL_PARM0'   :  update = 0
  'REFL_PARM1'   :  update = 0
  'REFL_PARM2'   :  update = 0

  ;---------------------------------------------------------
  ; 'Refresh' button --
  ;  Refresh the reflectance function lists.
  ;---------------------------------------------------------
  'REFRESH_REFL' : $
	begin
	  grpht_refresh_fn, data, 'refl'
	end

  ;---------------------------------------------------------
  ; 'Refresh' button --
  ;  Refresh the phase function lists.
  ;---------------------------------------------------------
  'REFRESH_PHASE' : $
	begin
	  grpht_refresh_fn, data, 'phase'
	end

  ;-------------------------------------------------------------
  ; 'Ok' button --
  ;  Apply the correction using the current settings and exit.
  ;-------------------------------------------------------------
  'OK' : $
	begin
	  grpht_apply_correction_primary, grim_data, data, phtd
	  widget_control, data.base, /destroy
	  return
	end

  ;---------------------------------------------------------
  ; 'Apply' button --
  ;  Apply the correction using the current settings.
  ;---------------------------------------------------------
  'APPLY' : $
	begin
	  grpht_apply_correction_primary, grim_data, data, phtd
	end

  ;--------------------------------------------------------------------
  ; 'Apply All' button --
  ;  Apply the correction to all planes using the current settings.
  ;--------------------------------------------------------------------
  'APPLY_ALL' : $
	begin
	  grpht_apply_correction_all, grim_data, data, phtd
	end

  ;---------------------------------------------------------------
  ; Correction type --
  ;  Save the current setting in the appropriate pht descriptor
  ;  and restore the displayed settings to those of the new pht 
  ;  descriptor.
  ;---------------------------------------------------------------
  'REFL_FN' : $
	begin
	 phtd_form = grpht_form_to_phtd(data, refl_fn=data.last_refl_fn)
	 index = where(data.phtds.refl_fn EQ phtd_form.refl_fn)
	 data.phtds[index] = phtd_form

	 phtd = grpht_get_phtd(data, refl_fns[value.refl_fn])
         grpht_phtd_to_form, data, phtd
	end

  else:
 endcase


 if(update) then grpht_phtd_to_form, data, phtd
 data.phtd = phtd
 grim_set_user_data, grim_data, 'GRPHT_DATA', data


end
;=============================================================================



;=============================================================================
; grpht_primary_notify
;
;=============================================================================
pro grpht_primary_notify, init_data_p

 grim_data = grim_get_data(/primary)
 if(NOT keyword_set(grim_data)) then return
 data = grim_get_user_data(grim_data, 'GRPHT_DATA')
 if(NOT keyword_set(data)) then $
               grim_set_user_data, grim_data, 'GRPHT_DATA', *init_data_p $
 else grpht_phtd_to_form, data, data.phtd

end
;=============================================================================



;=============================================================================
; grpht_cleanup
;
;=============================================================================
pro grpht_cleanup, base

 widget_control, base, get_uvalue=data_p
 grim_rm_primary_callback, data_p

end
;=============================================================================



;=============================================================================
; gr_phttool
;
;=============================================================================
pro gr_phttool, top

 if(xregistered('gr_phttool')) then return


 ;-----------------------------------------------
 ; setup map form widget
 ;-----------------------------------------------
 base = widget_base(title = 'GRIM Photometry', group=top)

 refl_fns = strupcase(grpht_get_functions('refl'))
 nrefl = n_elements(refl_fns)
 dl_refl_fn = refl_fns[0]
 for i=1, nrefl-1 do dl_refl_fn = dl_refl_fn + '|' + refl_fns[i]

 phase_fns = strupcase(grpht_get_functions('phase'))
 nphase = n_elements(phase_fns)
 dl_phase_fn = phase_fns[0]
 for i=1, nphase-1 do dl_phase_fn = dl_phase_fn + '|' + phase_fns[i]

 desc = [ $
	'1, BASE,, COLUMN, FRAME', $
	'1, BASE,, ROW, FRAME', $
	'1, BASE,, COLUMN, FRAME', $
	  '0, LABEL, Reflectance function,,', $
	  '1, BASE,, ROW, FRAME', $
	    '0, DROPLIST,' + dl_refl_fn + ',SET_VALUE=0' + $
	           ',, TAG=refl_fn', $
	    '2, BUTTON, Refresh,, TAG=refresh_refl', $
	  '0, TEXT,, LABEL_LEFT=k0 :, WIDTH=20, TAG=refl_parm0', $
	  '0, TEXT,, LABEL_LEFT=k1 :, WIDTH=20, TAG=refl_parm1', $
	  '2, TEXT,, LABEL_LEFT=k2 :, WIDTH=20, TAG=refl_parm2', $
	'3, BASE,, COLUMN, FRAME', $
	  '0, LABEL, Phase function,,', $
	  '1, BASE,, ROW, FRAME', $
	    '0, DROPLIST,' + dl_phase_fn + ',SET_VALUE=0' + $
	           ',, TAG=phase_fn', $
	    '2, BUTTON, Refresh,, TAG=refresh_phase', $
	  '0, TEXT,, LABEL_LEFT=k0 :, WIDTH=20, TAG=phase_parm0', $
	  '0, TEXT,, LABEL_LEFT=k1 :, WIDTH=20, TAG=phase_parm1', $
	  '2, TEXT,, LABEL_LEFT=k2 :, WIDTH=20, TAG=phase_parm2', $

	'1, BASE,, ROW', $
	  '0, BUTTON, Ok,, TAG=ok', $
	  '0, BUTTON, Apply,, TAG=apply', $
	  '0, BUTTON, Apply All,, TAG=apply_all', $
	  '2, BUTTON, Close, QUIT, TAG=close']

 form = cw__form(base, desc, ids=ids, tags=tags)
 widget_control, form, $
           set_uvalue={ids:ids, tags:tags, $
                       refl_fns:refl_fns, phase_fns:phase_fns}

 nids = n_elements(ids)
 for i=0, nids-1 do widget_control, ids[i], /all_text_events 

 ;-----------------------------------------------
 ; main data structure
 ;-----------------------------------------------
 data = { $
	;---------------
	; widgets
	;---------------
		base		:	base, $
		phtd		:	grpht_descriptor(), $
		form		:	form, $
		ids		:	ids, $
		tags		:	tags, $
		refl_fns	:	refl_fns, $
		phase_fns	:	phase_fns, $
	;---------------
	; book keeping
	;---------------
		last_refl_fn	:	'', $
		grim_wnum	:	!d.window, $
	;-----------------------------
	; default pht descriptors
	;-----------------------------
		phtds 		:	[ grpht_descriptor( $
					   refl_fn='MINNEART', $
					   phase_fn='ISOTROPIC', $
					   n_refl=1, $
					   n_phase=0, $
					   refl_parm = [0.5, 0, 0]), $
					  grpht_descriptor( $
					   refl_fn='LUNAR', $
					   phase_fn='ISOTROPIC', $
					   n_refl=0, $
					   n_phase=0, $
					   refl_parm = [0, 0, 0]), $
					  grpht_descriptor( $
					   refl_fn='LUNAR_LAMBERT', $
					   phase_fn='ISOTROPIC', $
					   n_refl=2, $
					   n_phase=0, $
					   refl_parm = [0.5, 0.5, 0]) ] $
	     }

 data.refl_fns = data.phtds.refl_fn
; widget_control, base, set_uvalue=data


 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'gr_phttool', base, /no_block, cleanup='grpht_cleanup'

 ;-----------------------------------------------------
 ; initial form settings
 ;-----------------------------------------------------
 data.phtd = grpht_get_phtd(data, 'MINNEART')
 grpht_phtd_to_form, data, data.phtd

 data_p = nv_ptr_new(data)
 grim_add_primary_callback, 'grpht_primary_notify', data_p
 widget_control, base, set_uvalue=data_p

 grim_data = grim_get_data(top)
 grim_set_user_data, grim_data, 'GRPHT_DATA', data


end
;=============================================================================
