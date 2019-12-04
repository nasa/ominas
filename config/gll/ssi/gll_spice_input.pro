;=============================================================================
;+
; NAME:
;	gll_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Galileo. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = gll_spice_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor.
;
;  OUTPUT:
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	ref:		Name of the reference frame for the output quantities.
;			Default is 'j2000'.
;
;	j2000:		/j2000 is equivalent to specifying ref=j2000.
;
;	b1950:		/b1950 is equivalent to specifying ref=b1950.
;
;	klist:		Name of a file giving a list of SPICE kernels to use.
;			If no path is included, the path is taken from the 
;			NV_SPICE_KER environment variable.
;
;	ck_in:		List of input C kernel files to use.  List must be 
;			delineated by semimcolons with no space.  The kernel
;			list file is still used, but these kernels take
;			precedence.  Entries in this list may be file
;			specification strings.
;
;	planets:	List of planets to for which to request ephemeris.  
;			Must be delineated by semicolons with no space.
;
;	reload:		If set, new kernels are loaded, as specified by the
;			klist and ck_in keywords.
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	gll_spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================


;===========================================================================
; gll_spice_parse_labels
;
;===========================================================================
pro gll_spice_parse_labels, dd, _time, $
      exposure=exposure, size=size, filters=filters, oaxis=oaxis, scale=scale, $
      target=target

 ndd = n_elements(dd)

 time = dblarr(ndd)
 exposure = dblarr(ndd)
 size = make_array(2,ndd, val=1024)
 filters = strarr(2,ndd)
 target = strarr(ndd)
 oaxis = dblarr(2,ndd)
 scale = dblarr(2,ndd)

 for i=0, ndd-1 do $
  begin
   label = dat_header(dd[i])
   if(keyword_set(label)) then $
    begin
     ;------------------------------
     ; time
     ;------------------------------
     if(NOT keyword_set(_time)) then time[i] = gll_spice_time(label)

     ;------------------------------
     ; exposure time
     ;------------------------------
     exposure[i] = vicgetpar(label, 'EXP')

     ;------------------------------------------------
     ; image size
     ;------------------------------------------------
     size[0,i] = double(vicgetpar(label, 'NS'))
     size[1,i] = double(vicgetpar(label, 'NL'))

     ;------------------------------------------------
     ; nominal optic axis coordinate, camera scale
     ;------------------------------------------------
     oaxis[*,i] = size[*,i]/2d
     scale[*,i] = [1.016d-05, 1.016d-05]		; from trial and error

     ;------------------------------------------------
     ; detect summation modes
     ;------------------------------------------------
     mode = vicgetpar(label, 'TLMFMT')
     if((mode EQ 'HIS') OR (mode EQ 'AI8')) then $
      begin
       oaxis[*,i] = oaxis[*,i] / 2d
       scale[*,i] = scale[*,i]*2d
      end

;     filters[*,i] = vicgetpar(label, 'FILTER_NAME')


     ;------------------------------------------------
     ; target
     ;------------------------------------------------
     target[i] = strupcase(vicgetpar(label, 'TARGET_NAME'))

    end
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================


;===========================================================================
; gll_spice_cameras
;
;===========================================================================
function gll_spice_cameras, dd, ref, pos=pos, constants=constants, $
          n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 ;-------------------------------------------------------------------
 ; instrument params
 ;  Actually, the instrument ID is -77036 and the platform ID is
 ;  -77001.  But the platform C-matrix is really what we'll need in
 ;  this case. 
 ;-------------------------------------------------------------------
 sc = -77l
 plat = 0l
 inst= -77001l
 orient_fn = 'gll_cmat_to_orient_ssi'

 gll_spice_parse_labels, dd, time, $
    exposure=exposure, size=size, filters=filters, oaxis=oaxis, scale=scale


 return, gll_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = time, $
		cam_scale = scale, $
		cam_oaxis = oaxis, $
		cam_fn_psf = make_array(ndd, val='gll_psf'), $
		cam_size = size, $
		cam_exposure = exposure, $
		cam_fn_focal_to_image = make_array(ndd, val='cam_focal_to_image_linear'), $
		cam_fn_image_to_focal = make_array(ndd, val='cam_image_to_focal_linear'), $
		cam_fi_data = [ptrarr(ndd)], $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                   orient_fn )

end
;===========================================================================



;===========================================================================
; gll_spice_planets
;
;===========================================================================
function gll_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 gll_spice_parse_labels, dd, time, target=target

 return, eph_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; gll_spice_sun
;
;===========================================================================
function gll_spice_sun, dd, ref, n_obj=n_obj, dim=dim, $
                   status=status, time=time, constants=constants, obs=obs

 gll_spice_parse_labels, dd, time

 return, eph_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
             status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; gll_spice_input.pro
;
;
;===========================================================================
function gll_spice_input, dd, keyword, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords


 return, spice_input(dd, keyword, 'gll', values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
