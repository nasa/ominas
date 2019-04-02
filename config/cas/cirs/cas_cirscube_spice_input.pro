




;==============================================================================
; cas_cirscube_spice_maps
;
;==============================================================================
function cas_cirscube_spice_maps, dd, status=status


compile_opt idl2,logical_predicate
status = 0


header=dat_header(dd)
items=pdspar(header,'CORE_ITEMS')
items=fix(strsplit(items,'(,)',/extract))
names=pdspar(header,'AXIS_NAME')
names=strupcase(strtrim(strsplit(names,'(,) ',/extract),2))
wl=where(names eq 'LINE')
ws=where(names eq 'SAMPLE')
wb=where(names eq 'BAND')
lines=items[wl]
samples=items[ws]
bands=items[wb]
origin=[lines,samples]/2d0


fsc=double(pdspar(header,'CSS:FIRST_SAMPLE_CENTER')); = 225
flc=double(pdspar(header,'CSS:FIRST_LINE_CENTER')); = 17
lsc=double(pdspar(header,'CSS:LAST_SAMPLE_CENTER')); = 117
llc=double(pdspar(header,'CSS:LAST_LINE_CENTER')); = -75

center=[mean([flc,llc]),-mean([fsc,lsc])]
units=[180d0,360d0]/[-(flc-llc),-(fsc-lsc)]

mdr=map_create_descriptors(name='CAS_CIRS',$
  projection='RECTANGULAR', $
  size=[lines,samples], $
  origin=origin, $
  ;pole=pole,$
  center=center*!dpi/180d0,$
  units=units,$
  gd=dd)

status=0
  
return,mdr
  
end
;==============================================================================



;===========================================================================
; cas_cirscube_spice_parse_labels
;
;===========================================================================
pro cas_cirscube_spice_parse_labels, dd, _time, target=target

 ndd = n_elements(dd)

 meta0 = {cas_cirscube_spice_label_struct}

 for i=0, ndd-1 do $
  begin
   _meta = dat_header_info(dd[i])
   if(NOT keyword_set(_meta)) then begin
    label=dat_header(dd[i])
    meta0.target=strsplit(pdspar(label,'TARGET_NAME'),'" ',/extract)
    _meta = meta0
   endif
   meta = append_array(meta, _meta)
  end

 if(NOT keyword_set(_time)) then _time = meta.time
 target = meta.target

end 
;=============================================================================



;===========================================================================
; cas_cirscube_spice_cameras
;
;===========================================================================
function cas_cirscube_spice_cameras, dd, ref, pos=pos, constants=constants, $
         n_obj=n_obj, dim=dim, status=status, time=time, orient=orient, obs=obs

 ndd = n_elements(dd)

 sc = -82l
 plat = -82000l

label=dat_header(dd[0])
fp=pdspar(label,'FOCAL_PLANE')
inst = fp eq 1 ? -82890 : (fp eq 3 ? -82891 : -82892)

 
 cas_cirscube_spice_parse_labels, dd, time, target=target

 orient_fn = 'cas_cmat_to_orient'

 return, cas_to_ominas( $
           spice_cameras(dd, ref, '', '', pos=pos, $
		sc = sc, $
		inst = inst, $
		plat = plat, $
		orient = orient, $
		cam_time = time, $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs), $
                  orient_fn )

end
;===========================================================================



;===========================================================================
; cas_cirscube_spice_planets
;
;===========================================================================
function cas_cirscube_spice_planets, dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs

 cas_cirscube_spice_parse_labels, dd, time, target=target

 return, gen_spice_planets(dd, ref, time=time, planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, $
                            target=target, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_cirscube_spice_sun
;
;===========================================================================
function cas_cirscube_spice_sun, dd, ref, n_obj=n_obj, dim=dim, constants=constants, $
                                   status=status, time=time, obs=obs

 cas_cirscube_spice_parse_labels, dd, time

 return, gen_spice_sun(dd, ref, n_obj=n_obj, dim=dim, $
            status=status, time=time, constants=constants, obs=obs)

end
;===========================================================================



;===========================================================================
; cas_cirscube_spice_input.pro
;
;
;===========================================================================
function cas_cirscube_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 if(keyword EQ 'MAP_DESCRIPTORS') then return, cas_cirscube_spice_maps(dd, status=status)

 return, spice_input(dd, keyword, 'cas', 'cirscube', values=values, status=status, $
; return, spice_input(dd, keyword, 'cas', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================


