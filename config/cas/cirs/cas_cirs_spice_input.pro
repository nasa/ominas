;=============================================================================
;NOT FINISHED YET, COPIED FROM cas_iss_spice_input.pro FIRST
;+
; NAME:
;	cas_cirs_spice_input
;
;
; PURPOSE:
;	NAIF/SPICE input translator for Cassini CIRS. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = spice_input(dd, keyword)
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
;	cas_cirs_spice_output
;
;
; MODIFICATION HISTORY:
; 	Edited by:	Paulo Penteado, 3/2018
;	
;-
;=============================================================================



;===========================================================================
; cas_cirs_spice_parse_labels
;
;===========================================================================
pro cas_cirs_spice_parse_labels, dd, _time, $
     exposure=exposure, size=size, filters=filters, oaxis=oaxis, target=target

 ndd = n_elements(dd)

 time = dblarr(ndd)
 exposure = dblarr(ndd)
 size = make_array(2,ndd, val=1024,/long)
 filters = strarr(2,ndd)
 target = strarr(ndd)
 oaxis = dblarr(2,ndd)

 for i=0, ndd-1 do $
  begin
   label = dat_header(dd[i])
   if(keyword_set(label)) then $
    begin
     ;-----------------------------------
     ; time
     ;-----------------------------------
     if(NOT keyword_set(_time)) then time[i] = cas_cirs_spice_time(dd[i])

     ;-----------------------------------
     ; exposure time
     ;-----------------------------------
     tim=cas_cirs_spice_time(dd[i],exposure=exp)
     exposure[i] = exp

     ;-----------------------------------
     ; image size
     ;-----------------------------------
     size[*,i] = dat_dim(dd)

     ;-----------------------------------
     ; filters
     ;-----------------------------------
     filters[*,i] = 'CIRS'

     ;-----------------------------------
     ; target
     ;-----------------------------------
     target[i] = pdspar(label.label, 'OBSERVATION_ID')
    end

   ;-----------------------------------
   ; optic axis
   ;-----------------------------------
   oaxis[*,i] = [0,0]
  end

 if(NOT keyword_set(_time)) then _time = time

end 
;=============================================================================



;===========================================================================
; cas_cirs_spice_cameras
;
;===========================================================================
function cas_cirs_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

 cas_cirs_spice_parse_labels, dd, time, $
       exposure=exposure, size=size, filters=filters, oaxis=oaxis

 bin = 1
 label=dat_header(dd)
 table=label.table
 
 cdtmp=objarr(size[0])

case 1 of 
  table[0].det eq 0: ifp=0 ;detector is FP1
  (table[0].det ge 1) && (table[0].det le 20): ifp=1; FP3
  (table[0].det ge 21) && (table[0].det le 40): ifp=2; FP4
endcase

inst=-82890L-ifp
scale=ifp eq 0 ? [1,1]*0.223d0*!dpi/180d0 : [0.0172d0,0.0172d0]*!dpi/180d0
oaxis=[0d0,0d0]
case 1 of
  table[0].det eq 0: oaxis=[5.7d-3/scale[0],0d0] ;FP1
  (table[0].det ge 1) && (table[0].det le 5): begin ;FP3 pair
    oaxis=[(1.7d-3-.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=6d0-table[0].det*2
    scale[1]*=2d0
  end
  (table[0].det ge 6) && (table[0].det le 10): begin ;FP3 center
    oaxis=[(1.7d-3-.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=7.5d0-table[0].det
  end
  (table[0].det ge 11) && (table[0].det le 20): begin ;FP3 odd/even
    oaxis=[(1.7d-3-.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=15.5d0-table[0].det
  end
  (table[0].det ge 21) && (table[0].det le 30): begin ;FP4 odd/even
    oaxis=[(1.7d-3+.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=-25.5d0+table[0].det
  end
  (table[0].det ge 31) && (table[0].det le 35): begin ;FP4 center
    oaxis=[(1.7d-3+.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=-33.5d0+table[0].det
  end  
  (table[0].det ge 36) && (table[0].det le 40): begin ;FP4 pair
    oaxis=[(1.7d-3+.47d-3)/scale[0],-0.04d-3/scale[1]]
    oaxis[1]+=-76d0+table[0].det*2
    scale[1]*=2d0
  end
endcase

orient_fn = 'cas_cmat_to_orient'

cam=spice_cameras(dd, ref, '', '', pos=pos, $`
  sc = sc, $
  inst = inst, $
  plat = plat, $
  orient = orient, $
  cam_time = time, $
  cam_scale = scale, $
  cam_oaxis = oaxis, $
  cam_fn_psf = make_array(ndd, val=''), $
  cam_filters = filters, $
  cam_size = size, $
  cam_exposure = exposure, $
  cam_fn_focal_to_image = make_array(ndd, val='cas_cirs_focal_to_image'), $
  cam_fn_image_to_focal = make_array(ndd, val='cas_cirs_image_to_focal'), $
  cam_fi_data = [ptrarr(ndd)], $
  n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs)

cd=cas_to_ominas(cam,orient_fn )
 
foreach t,table,icd do begin


    jd=julday(1,1,1970,0,0,0)+t.scet/86400d0
    time=spice_str2et('JD'+string(jd,format='(F018.10)'))
    cam=spice_cameras(dd, ref, '', '', pos=pos, $`
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = time, $
		cam_scale = scale, $
		cam_oaxis = oaxis, $
		cam_fn_psf = make_array(ndd, val=''), $
		cam_filters = filters, $
		cam_size = size, $
		cam_exposure = exposure, $
		cam_fn_focal_to_image = make_array(ndd, val='cas_cirs_focal_to_image'), $
		cam_fn_image_to_focal = make_array(ndd, val='cas_cirs_image_to_focal'), $
		cam_fi_data = [ptrarr(ndd)], $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs)
		
    cdtmp[icd]=cas_to_ominas(cam,orient_fn )
endforeach

orients=bod_orient(cdtmp)
poss=bod_pos(cdtmp)
cam_set_fi_data,cd,{orients:orients,poss:poss}

return,cdtmp
end
;===========================================================================



;===========================================================================
; cas_cirs_spice_planets
;
;===========================================================================
function cas_cirs_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 cas_cirs_spice_parse_labels, dd, time, target=target

 return, gen_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_cirs_spice_sun
;
;===========================================================================
function cas_cirs_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 cas_cirs_spice_parse_labels, dd, time

 return, gen_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_cirs_spice_input.pro
;
;
;===========================================================================
function cas_cirs_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 return, spice_input(dd, keyword, 'cas', 'cirs', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================
