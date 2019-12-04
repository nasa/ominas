;===========================================================================
; gen_spice_sun
;
;===========================================================================
function gen_spice_sun, dd, ref, n_obj=n_obj, dim=dim, $
                     status=status, time=sc_time, constants=constants, obs=obs

 if(NOT keyword_set(sc)) then sc = 0l
 ndd = n_elements(dd)

 ;------------------------------
 ; get planet descriptor for sun
 ;------------------------------
 pd = gen_to_ominas( $
	spice_planets(dd, ref, $
		time = sc_time, $
		name = make_array(1,ndd, val='SUN'), $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs) )
 if(status NE 0) then return, 0

 ;------------------------------
 ; convert to star descriptor
 ;------------------------------
 sd = str_create_descriptors(n_obj, $
		gd=dd, $
		name=cor_name(pd), $
		orient=bod_orient(pd), $
		avel=bod_avel(pd), $
		sp=make_array(1,ndd, val='G2'), $
		pos=bod_pos(pd), $
		lum=make_array(1,ndd, val=const_get('Lsun')), $
		mass=make_array(1,ndd, val=const_get('Msun')), $
		vel=bod_vel(pd), $
		time=bod_time(pd), $
		lref=glb_lref(pd), $
		radii=glb_radii(pd), $
		lora=glb_lora(pd))

 return, sd

end
;===========================================================================



