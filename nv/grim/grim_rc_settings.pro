;=============================================================================
; grim_rc_select
;
;=============================================================================
function grim_rc_select, keyvals

 cor_class_info, abbrev=abbrev

 for i=0, n_elements(abbrev)-1 do $
     kv = append_struct(kv, struct_extract(keyvals, abbrev[i]+'_', /retain))

 return, kv
end
;=============================================================================



;=============================================================================
; grim_rc_settings
;
;=============================================================================
pro grim_rc_settings, rcfile=rcfile, keyvals=keyvals, $
	cmd=cmd, $
	new=new, xsize=xsize, ysize=ysize, mode_init=mode_init, npoints=npoints, $
	zoom=zoom, rotate=rotate, order=order, offset=offset, filter=filter, retain=retain, $
	path=path, save_path=save_path, load_path=load_path, symsize=symsize, $
        overlays=overlays, menu_fname=menu_fname, cursor_swap=cursor_swap, $
	fov=fov, clip=clip, menu_extensions=menu_extensions, button_extensions=button_extensions, $
	cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, stn_trs=stn_trs, arr_trs=arr_trs, lgt_trs=lgt_trs, $
	filetype=filetype, hide=hide, mode_args=mode_args, xzero=xzero, rgb=rgb, $
        psym=psym, nhist=nhist, maintain=maintain, ndd=ndd, workdir=workdir, $
        activate=activate, frame=frame, compress=compress, loadct=loadct, maxdat=maxdat, $
	arg_extensions=arg_extensions, extensions=extensions, beta=beta, rendering=rendering, $
        plane_syncing=plane_syncing, tiepoint_syncing=tiepoint_syncing, curve_syncing=curve_syncing, action_syncing=action_syncing, activation_syncing=activation_syncing, visibility=visibility, channel=channel, $
        render_numbra=render_numbra, render_sampling=render_sampling, render_minimum=render_minimum, slave_overlays=slave_overlays, $
        delay_overlays=delay_overlays, auto_stretch=auto_stretch, lights=lights, $
        render_rgb=render_rgb, render_current=render_current, render_spawn=render_spawn, render_auto=render_auto, render_sky=render_sky, $
	guideline=guideline, integer_zoom=integer_zoom, exclude_overlays=exclude_overlays, $
	settings_overlays=settings_overlays


 ;----------------------------------------------------
 ; return if no resource file
 ;----------------------------------------------------
 defsysv, '!grimrc', exists=exists
 if(exists) then rcname = !grimrc $
 else rcname = getenv('HOME') + path_sep() + rcfile
 if(NOT keyword_set(rcname)) then return

 fname = file_search(rcname)
 if(NOT keyword_set(fname)) then $
  begin
   nv_message, verb=0.5, 'GRIM resource file not found: ' + rcname +'.'
   return
  end

 ;----------------------------------------------------
 ; read file and strip comments
 ;----------------------------------------------------
 lines = read_txt_file(fname[0])
 w = where(strmid(lines, 0, 1) NE '#')
 if(w[0] NE -1) then lines = lines[w]

 ;----------------------------------------------------
 ; parse the keyvals
 ;----------------------------------------------------
 kvrc = dat_parse_keyvals(lines, /extra)

 ;----------------------------------------------------
 ; add rc file keywords
 ;----------------------------------------------------
 kv = append_struct(kvrc, keyvals) 

 ;----------------------------------------------------
 ; handle colormap keywords
 ;----------------------------------------------------
 cmd = struct_extract(keyvals, 'CMD_')


 ;----------------------------------------------------
 ; extract any undefined values
 ;----------------------------------------------------
 if(n_elements(fov) EQ 0) then _fov = extra_value(kv, 'FOV') $
 else _fov = fov
 if(keyword_set(_fov)) then fov = float(_fov)

 if(n_elements(clip) EQ 0) then _clip = extra_value(kv, 'CLIP') $
 else _clip = clip
 if(keyword_set(_clip)) then clip = float(_clip)

 if(n_elements(hide) EQ 0) then _hide = extra_value(kv, 'HIDE') $
 else _hide = hide
 if(keyword_set(_hide)) then hide = fix(_hide)

 if(n_elements(auto_stretch) EQ 0) then $
                         _auto_stretch = extra_value(kv, 'AUTO_STRETCH') $
 else _auto_stretch = auto_stretch
 if(keyword_set(_auto_stretch)) then auto_stretch = fix(_auto_stretch)

 if(n_elements(xzero) EQ 0) then _xzero = extra_value(kv, 'XZERO') $
 else _xzero = xzero
 if(keyword_set(_xzero)) then xzero = fix(_xzero)

 if(n_elements(new) EQ 0) then _new = extra_value(kv, 'NEW') $
 else _new = new
 if(keyword_set(_new)) then new = fix(_new)

 if(n_elements(xsize) EQ 0) then _xsize = extra_value(kv, 'XSIZE') $
 else _xsize = xsize
 if(keyword_set(_xsize)) then xsize = fix(_xsize)

 if(n_elements(ysize) EQ 0) then _ysize = extra_value(kv, 'YSIZE') $
 else _ysize = ysize
 if(keyword_set(_ysize)) then ysize = fix(_ysize)

 if(n_elements(rotate) EQ 0) then _rotate = extra_value(kv, 'ROTATE') $
 else _rotate = rotate
 if(keyword_set(_rotate)) then rotate = fix(_rotate)

 if(n_elements(zoom) EQ 0) then _zoom = extra_value(kv, 'ZOOM') $
 else _zoom = zoom
 if(keyword_set(_zoom)) then zoom = double(_zoom)

 if(n_elements(order) EQ 0) then _order = extra_value(kv, 'ORDER') $
 else _order = order
 if(keyword_set(_order)) then order = fix(_order)

 if(n_elements(cursor_swap) EQ 0) then $
                              _cursor_swap = extra_value(kv, 'CURSOR_SWAP') $
 else _cursor_swap = cursor_swap
 if(defined(_cursor_swap)) then cursor_swap = fix(_cursor_swap)

 if(n_elements(offset) EQ 0) then _offset = extra_value(kv, 'OFFSET') $
 else _offset = offset
 if(keyword_set(_offset)) then offset = double(_offset)

 if(n_elements(path) EQ 0) then _path = extra_value(kv, 'PATH') $
 else _path = path
 if(keyword_set(_path)) then path = _path

 if(n_elements(save_path) EQ 0) then _save_path = extra_value(kv, 'SAVE_PATH') $
 else _save_path = save_path
 if(keyword_set(_save_path)) then save_path = _save_path

 if(n_elements(load_path) EQ 0) then _load_path = extra_value(kv, 'LOAD_PATH') $
 else _load_path = load_path
 if(keyword_set(_load_path)) then load_path = _load_path

 if(n_elements(workdir) EQ 0) then _workdir = extra_value(kv, 'WORKDIR') $
 else _workdir = workdir
 if(keyword_set(_workdir)) then workdir = _workdir

 if(n_elements(menu_fname) EQ 0) then $
                                 _menu_fname = extra_value(kv, 'MENU_FNAME') $
 else _menu_fname = menu_fname
 if(keyword_set(_menu_fname)) then menu_fname = _menu_fname

 if(n_elements(filter) EQ 0) then _filter = extra_value(kv, 'FILTER') $
 else _filter = filter
 if(keyword_set(_filter)) then filter = _filter

 if(n_elements(mode_init) EQ 0) then $
                     _mode_init = extra_value(kv, 'MODE_INIT') $
 else _mode_init = mode_init
 if(keyword_set(_mode_init)) then mode_init = _mode_init

 if(n_elements(retain) EQ 0) then _retain = extra_value(kv, 'RETAIN') $
 else _retain = retain
 if(keyword_set(_retain)) then retain = fix(_retain)

 if(n_elements(lights) EQ 0) then _lights = extra_value(kv, 'LIGHTS') $
 else _lights = lights
 if(keyword_set(_lights)) then lights = _lights

 if(n_elements(overlays) EQ 0) then _overlays = extra_value(kv, 'OVERLAYS') $
 else _overlays = overlays
 if(keyword_set(_overlays)) then overlays = _overlays

 if(n_elements(delay_overlays) EQ 0) then $
                   _delay_overlays = extra_value(kv, 'DELAY_OVERLAYS') $
 else _delay_overlays = delay_overlays
 if(keyword_set(_delay_overlays)) then delay_overlays = _delay_overlays

 if(n_elements(frame) EQ 0) then _frame = extra_value(kv, 'FRAME') $
 else _frame = frame
 if(keyword_set(_frame)) then frame = _frame

 if(n_elements(menu_extensions) EQ 0) then $
               _menu_extensions = extra_value(kv, 'MENU_EXTENSIONS') $
 else _menu_extensions = menu_extensions
 if(keyword_set(_menu_extensions)) then menu_extensions = _menu_extensions

 if(n_elements(button_extensions) EQ 0) then $
              _button_extensions = extra_value(kv, 'BUTTON_EXTENSIONS') $
 else _button_extensions = button_extensions
 if(keyword_set(_button_extensions)) then button_extensions = _button_extensions

 if(n_elements(arg_extensions) EQ 0) then $
               _arg_extensions = extra_value(kv, 'ARG_EXTENSIONS') $
 else _arg_extensions = arg_extensions
 if(keyword_set(_arg_extensions)) then arg_extensions = _arg_extensions

 if(n_elements(cam_trs) EQ 0) then _cam_trs = extra_value(kv, 'CAM_TRS') $
 else _cam_trs = cam_trs
 if(keyword_set(_cam_trs)) then cam_trs = _cam_trs

 if(n_elements(plt_trs) EQ 0) then _plt_trs = extra_value(kv, 'PLT_TRS') $
 else _plt_trs = plt_trs
 if(keyword_set(_plt_trs)) then plt_trs = _plt_trs

 if(n_elements(rng_trs) EQ 0) then _rng_trs = extra_value(kv, 'RNG_TRS') $
 else _rng_trs = rng_trs
 if(keyword_set(_rng_trs)) then tr_rds = _rng_trs

 if(n_elements(str_trs) EQ 0) then _str_trs = extra_value(kv, 'STR_TRS') $
 else _str_trs = str_trs
 if(keyword_set(_str_trs)) then str_trs = _str_trs

 if(n_elements(stn_trs) EQ 0) then _stn_trs = extra_value(kv, 'STN_TRS') $
 else _stn_trs = stn_trs
 if(keyword_set(_stn_trs)) then stn_trs = _stn_trs

 if(n_elements(arr_trs) EQ 0) then _arr_trs = extra_value(kv, 'ARR_TRS') $
 else _arr_trs = arr_trs
 if(keyword_set(_arr_trs)) then arr_trs = _arr_trs

 if(n_elements(lgt_trs) EQ 0) then _lgt_trs = extra_value(kv, 'LGT_TRS') $
 else _lgt_trs = lgt_trs
 if(keyword_set(_lgt_trs)) then lgt_trs = _lgt_trs

 if(n_elements(filetype) EQ 0) then _filetype = extra_value(kv, 'FILETYPE') $
 else _filetype = filetype
 if(keyword_set(_filetype)) then filetype = _filetype

 if(n_elements(mode_args) EQ 0) then _mode_args = extra_value(kv, 'MODE_ARGS') $
 else _mode_args = mode_args
 if(keyword_set(_mode_args)) then mode_args = _mode_args

 if(n_elements(psym) EQ 0) then _psym = extra_value(kv, 'PSYM') $
 else _psym = psym
 if(keyword_set(_psym)) then psym = long(_psym)

 if(n_elements(symsize) EQ 0) then _symsize = extra_value(kv, 'SYMSIZE') $
 else _symsize = symsize
 if(keyword_set(_symsize)) then symsize = fix(_symsize)

 if(n_elements(nhist) EQ 0) then _nhist = extra_value(kv, 'NHIST') $
 else _nhist = nhist
 if(keyword_set(_nhist)) then nhist = fix(_nhist)

 if(n_elements(maintain) EQ 0) then _maintain = extra_value(kv, 'MAINTAIN') $
 else _maintain = maintain
 if(keyword_set(_maintain)) then maintain = fix(_maintain)

 if(n_elements(compress) EQ 0) then _compress = extra_value(kv, 'COMPRESS') $
 else _compress = compress
 if(keyword_set(_compress)) then compress = fix(_compress)

 if(n_elements(activate) EQ 0) then _activate = extra_value(kv, 'ACTIVATE') $
 else _activate = activate
 if(keyword_set(_activate)) then activate = fix(_activate)

 if(n_elements(ndd) EQ 0) then _ndd = extra_value(kv, 'NDD') $
 else _ndd = ndd
 if(keyword_set(_ndd)) then ndd = long(_ndd)

 if(n_elements(loadct) EQ 0) then _loadct = extra_value(kv, 'LOADCT') $
 else _loadct = loadct
 if(keyword_set(_loadct)) then loadct = fix(_loadct)

 if(n_elements(maxdat) EQ 0) then _maxdat = extra_value(kv, 'MAXDAT') $
 else _maxdat = maxdat
 if(keyword_set(_maxdat)) then maxdat = double(_maxdat)

 if(n_elements(extensions) EQ 0) then _extensions = extra_value(kv, 'EXTENSIONS') $
 else _extensions = extensions
 if(keyword_set(_extensions)) then extensions = _extensions

 if(n_elements(beta) EQ 0) then _beta = extra_value(kv, 'BETA') $
 else _beta = beta
 if(keyword_set(_beta)) then beta = fix(_beta)

 if(n_elements(rendering) EQ 0) then _rendering = extra_value(kv, 'RENDERING') $
 else _rendering = rendering
 if(keyword_set(_rendering)) then rendering = fix(_rendering)

 if(n_elements(npoints) EQ 0) then _npoints = extra_value(kv, 'NPOINTS') $
 else _npoints = npoints
 if(keyword_set(_npoints)) then npoints = fix(_npoints)

 if(n_elements(plane_syncing) EQ 0) then $
                        _plane_syncing = extra_value(kv, 'PLANE_SYNCING') $
 else _plane_syncing = plane_syncing
 if(keyword_set(_plane_syncing)) then plane_syncing = fix(_plane_syncing)

 if(n_elements(tiepoint_syncing) EQ 0) then $
                  _tiepoint_syncing = extra_value(kv, 'TIEPOINT_SYNCING') $
 else _tiepoint_syncing = tiepoint_syncing
 if(keyword_set(_tiepoint_syncing)) then tiepoint_syncing = fix(_tiepoint_syncing)

 if(n_elements(curve_syncing) EQ 0) then $
                       _curve_syncing = extra_value(kv, 'CURVE_SYNCING') $
 else _curve_syncing = curve_syncing
 if(keyword_set(_curve_syncing)) then curve_syncing = fix(_curve_syncing)

 if(n_elements(activation_syncing) EQ 0) then $
                       _activation_syncing = extra_value(kv, 'ACTIVATION_SYNCING') $
 else _activation_syncing = activation_syncing
 if(keyword_set(_activation_syncing)) then activation_syncing = fix(_activation_syncing)

 if(n_elements(action_syncing) EQ 0) then $
                       _action_syncing = extra_value(kv, 'ACTION_SYNCING') $
 else _action_syncing = action_syncing
 if(keyword_set(_action_syncing)) then action_syncing = fix(_action_syncing)

 if(n_elements(rgb) EQ 0) then _rgb = extra_value(kv, 'RGB') $
 else _rgb = rgb
 if(keyword_set(_rgb)) then rgb = fix(_rgb)

 if(n_elements(visibility) EQ 0) then $
                               _visibility = extra_value(kv, 'VISIBILITY') $
 else _visibility = visibility
 if(keyword_set(_visibility)) then visibility = fix(_visibility)

 if(n_elements(channel) EQ 0) then _channel = extra_value(kv, 'CHANNEL') $
 else _channel = channel
 if(keyword_set(_channel)) then channel = fix(_channel)

 if(n_elements(render_minimum) EQ 0) then $
                        _render_minimum = extra_value(kv, 'RENDER_MINIMUM') $
 else _render_minimum = render_minimum
 if(keyword_set(_render_minimum)) then render_minimum = fix(_render_minimum)

 if(n_elements(render_numbra) EQ 0) then $
                        _render_numbra = extra_value(kv, 'RENDER_NUMBRA') $
 else _render_numbra = render_numbra
 if(keyword_set(_render_numbra)) then render_numbra = fix(_render_numbra)

 if(n_elements(render_sampling) EQ 0) then $
                        _render_sampling = extra_value(kv, 'RENDER_SAMPLING') $
 else _render_sampling = render_sampling
 if(keyword_set(_render_sampling)) then render_sampling = fix(_render_sampling)

 if(n_elements(slave_overlays) EQ 0) then $
                      _slave_overlays = extra_value(kv, 'SLAVE_OVERLAYS') $
 else _slave_overlays = slave_overlays
 if(keyword_set(_slave_overlays)) then slave_overlays = fix(_slave_overlays)

 if(n_elements(render_rgb) EQ 0) then $
                      _render_rgb = extra_value(kv, 'RENDER_RGB') $
 else _render_rgb = render_rgb
 if(keyword_set(_render_rgb)) then render_rgb = fix(_render_rgb)

 if(n_elements(render_current) EQ 0) then $
                _render_current = extra_value(kv, 'RENDER_CURRENT') $
 else _render_current = render_current
 if(keyword_set(_render_current)) then render_current = fix(_render_current)

 if(n_elements(render_spawn) EQ 0) then $
                      _render_spawn = extra_value(kv, 'RENDER_SPAWN') $
 else _render_spawn = render_spawn
 if(keyword_set(_render_spawn)) then render_spawn = fix(_render_spawn)

 if(n_elements(render_auto) EQ 0) then $
                      _render_auto = extra_value(kv, 'RENDER_AUTO') $
 else _render_auto = render_auto
 if(keyword_set(_render_auto)) then render_auto = fix(_render_auto)

 if(n_elements(render_sky) EQ 0) then $
                      _render_sky = extra_value(kv, 'RENDER_SKY') $
 else _render_sky = render_sky
 if(keyword_set(_render_sky)) then render_sky = fix(_render_sky)

 if(n_elements(guideline) EQ 0) then $
                      _guideline = extra_value(kv, 'GUIDELINE') $
 else _guideline = guideline
 if(keyword_set(_guideline)) then guideline = fix(_guideline)

 if(n_elements(integer_zoom) EQ 0) then $
                      _integer_zoom = extra_value(kv, 'INTEGER_ZOOM') $
 else _integer_zoom = integer_zoom
 if(keyword_set(_integer_zoom)) then integer_zoom = fix(_integer_zoom)

 if(n_elements(exclude_overlays) EQ 0) then $
                      _exclude_overlays = extra_value(kv, 'EXCLUDE_OVERLAYS') $
 else _exclude_overlays = exclude_overlays
 if(keyword_set(_exclude_overlays)) then exclude_overlays = _exclude_overlays

 if(n_elements(settings_overlays) EQ 0) then $
                      _settings_overlays = extra_value(kv, 'SETTINGS_OVERLAYS') $
 else _settings_overlays = settings_overlays
 if(keyword_set(_settings_overlays)) then settings_overlays = _settings_overlays


 ;-----------------------------------------------------------------
 ; add object-specific keywords from rc file to keyvals list
 ;-----------------------------------------------------------------
 keyvals = append_struct(grim_rc_select(kvrc), keyvals, /replace)
end
;=============================================================================
