;===========================================================================
; spice_planets
;
;
;===========================================================================
function spice_planets, dd, ref, $
		name=name, time=time, target=target, $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs

 ndd = n_elements(dd)
 if(NOT keyword_set(target)) then target = name[0,*]

 status = -1
 dim = [1]

 n_k_in = 0l
 if(NOT keyword_set(k_in)) then k_in = '' $
 else n_k_in = n_elements(k_in)

 n_uk_in = 0l
 if(NOT keyword_set(uk_in)) then uk_in = '' $
 else n_uk_in = n_elements(uk_in)


 ;----------------------------------------------------------------------
 ; get object names
 ;----------------------------------------------------------------------
 if(NOT keyword_set(name)) then name = spice_get_all_target_names()
 n = n_elements(name)
 
 _time = 0
 for i=0, ndd-1 do $
  begin
   if(defined(time)) then _time = time[i]
   status = spice_get_planets(name, ref, _time, constants=constants, $
			plt_pos, plt_vel, plt_avel, plt_orient, plt_radii, $
                        plt_lora, plt_gm, plt_j, found, ids, plt_rref, plt_refl_fn, plt_refl_parm, $
			plt_phase_fn, plt_phase_parm, plt_albedo, obs=obs)

   continue = 1
   if(status NE 0) then continue = 0 $
   else $
    begin
     status = -1
     n_obj = 0
     w = where(found)
     if(w[0] EQ -1) then continue = 0 
    end

   if(continue) then $
    begin
     n_obj = n_elements(w) 

     status = 0
     ids = ids[w]
     name = name[w]
     plt_time = make_array(n_obj, val=_time)
     plt_pos = reform(plt_pos[*,w], 1, 3, n_obj)
     plt_vel = reform(plt_vel[*,w], 1, 3, n_obj)
     plt_orient = plt_orient[*,*,w]
     plt_avel = reform(plt_avel[*,w], 1, 3, n_obj)
     plt_radii = plt_radii[*,w]
     plt_lora = plt_lora[w]
     plt_gm = plt_gm[w]
     plt_j = [dblarr(1,n_obj), plt_j[*,w]]

     plt_rref = plt_rref[w]
     plt_refl_fn = plt_refl_fn[w]
     plt_refl_parm = plt_refl_parm[*,w]
     plt_phase_fn = plt_phase_fn[w]
     plt_phase_parm = plt_phase_parm[*,w]
     plt_albedo = plt_albedo[w]

     plt_mass = plt_gm / (const_get('G')/1d9) 
     ww = where(plt_rref EQ 0)
     if(ww[0] NE -1) then plt_rref[ww] = plt_radii[0,ww]

     plt_lref = make_array(n_obj, val='III')		; for now!

     ;------------------------------
     ; create planet descriptors
     ;------------------------------
     pd = plt_create_descriptors(n_obj, $
		gd=make_array(n_obj, val=dd[i]), $
		name=name, $
		orient=plt_orient, $
		avel=plt_avel, $
		pos=plt_pos, $
		vel=plt_vel, $
		time=plt_time, $
		radii=plt_radii, $
		lref=plt_lref, $
		rref=plt_rref, $
		refl_fn=plt_refl_fn, $
		refl_parm=plt_refl_parm, $
		phase_fn=plt_phase_fn, $
		phase_parm=plt_phase_parm, $
		albedo=plt_albedo, $
		mass=plt_mass, $
		gm=plt_gm, $
		j=plt_j, $
		lora=plt_lora)
     cor_set_udata, pd, 'NAIF_ID', ids

     ;-----------------------------------------------------
     ; move target to front of list
     ;-----------------------------------------------------
     w = where(cor_name(pd) EQ target[i])
     target_unknown = 0
     if(w[0] EQ -1) then target_unknown = 1 $
     else $
      begin
       ppd = pd[w]
       pd[w] = pd[0]
       pd[0] = ppd
      end

     ;--------------------------------------------------------------------
     ; if target unknown, put empty planet descriptor at beginning of list
     ;--------------------------------------------------------------------
;     if(target_unknown) then $
;      begin
;       pd = [plt_create_descriptors(1, name='UNKNOWN', gd=dd), pd]
;       n_obj = n_obj + 1
;      end

     pds = append_array(pds, pd)
    end
  end



  return, pds
end
;===========================================================================
