;===========================================================================
; spice_get_planets
;
;
;===========================================================================
function spice_get_planets, names, ref, et, $
			pos, vel, avel, orient, radii, lora, $
			gm, jcoef, found, ids, rref, refl_fn, refl_parm, $
			phase_fn, phase_parm, albedo, constants=constants, obs=obs

 n = n_elements(names)

 ;----------------------------------------------------------------------
 ; convert obs name to id if necessary
 ;----------------------------------------------------------------------
 if(NOT keyword_set(obs)) then obs = 0 $
 else $
  begin
   tp = size(obs, /type)
   if (tp EQ 7 ) then cspice_bodn2c, obs, obs, name_found
  end

 pos = dblarr(3,n)
 vel = dblarr(3,n)
 radii = dblarr(3,n)
 avel = dblarr(3,n)
 jcoef = dblarr(128,n)
 orient = dblarr(3,3,n) & orient[diaggen(3,n)] = 1
 gm = dblarr(n)
 lora = dblarr(n)

 rref = dblarr(n)
 refl_fn = strarr(n)
 refl_parm = dblarr(10,n)
 phase_fn = strarr(n)
 phase_parm = dblarr(10,n)
 albedo = dblarr(n)

 ;-------------------------------------------------------
 ; get ephem for each specified object
 ;-------------------------------------------------------
 found = bytarr(n)
 ids = lonarr(n)

 for i=0, n-1 do $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; convert names into ids
   ;  If names starts with '!', then only position is requested.
   ;  If name is entirely numeric, then treat as naif id.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   name = names[i]

   pos_only = 0
   if(strmid(name, 0, 1) EQ '!') then $
    begin
     pos_only = 1
     name = strmid(name, 1, 128)
    end

   numeric_name = 1
   w = str_isnum(name)
   if(w[0] EQ -1) then numeric_name = 0

   if(numeric_name) then $
    begin
     id = long(name)
     name_found = 1
    end $
   else cspice_bodn2c, name, id, name_found 


   if(name_found) then $
    begin
     if(keyword_set(constants)) then found[i] = 1

     ;- - - - - - - - - - - - - - - - - - - -
     ; get body constants
     ;- - - - - - - - - - - - - - - - - - - -
     spice_bodvar, id, 'RADII', _radii
     spice_bodvar, id, 'LONG_AXIS', _lora
     spice_bodvar, id, 'GM', _gm
     spice_bodvar, id, 'JCOEF', _jcoef

     _rref = (_refl_fn = (_refl_parm = (_phase_fn = (_phase_parm = (_albedo = 0)))))
     spice_bodvar, id, 'RREF', _rref
     spice_stpool, id, 'REFL_FN', _refl_fn
     spice_bodvar, id, 'REFL_PARM', _refl_parm
     spice_stpool, id, 'PHASE_FN', _phase_fn
     spice_bodvar, id, 'PHASE_PARM', _phase_parm
     spice_bodvar, id, 'ALBEDO', _albedo

     if(keyword_set(_radii)) then radii[*,i] = _radii
     if(keyword_set(_lora)) then lora[i] = _lora
     if(keyword_set(_gm)) then gm[i] = _gm
     if(keyword_set(_jcoef)) then jcoef[0:n_elements(_jcoef)-1,i] = _jcoef

     if(keyword_set(_rref)) then rref[i] = _rref
     if(keyword_set(_refl_fn)) then refl_fn[i] = _refl_fn
     if(keyword_set(_refl_parm)) then refl_parm[0:n_elements(_refl_parm)-1,i] = _refl_parm
     if(keyword_set(_phase_fn)) then phase_fn[i] = _phase_fn
     if(keyword_set(_phase_parm)) then phase_parm[0:n_elements(_phase_parm)-1,i] = _phase_parm
     if(keyword_set(_albedo)) then albedo[i] = _albedo

     ;- - - - - - - - - - - - - - - - - - - - - -
     ; get body state w.r.t. SS barycenter
     ;- - - - - - - - - - - - - - - - - - - - - -
     catch, failed
     if(failed EQ 0) then cspice_spkgeo, id, et, ref, obs, targ_state, ltime
     catch, /cancel

     if(keyword_set(failed)) then $
      begin
       help, /last_message, output=message
       w = where(strmid(message, 0, 1) EQ '%')
       message = message[0:w[1]-1]
       nv_message, verb=0.7, 'SPKGEO failed with the following message:', $
            exp=message
      end

     if(failed EQ 0) then $
      begin
       found[i] = 1
       ids[i] = id

       pos[*,i] = transpose(targ_state[0:2])
       vel[*,i] = transpose(targ_state[3:5])

       if(NOT pos_only) then $
        begin
         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         ; get body orientation matrix --
         ;  Note that this routine does not have a cspice wrapper so 
         ;  we call the f2c'd routine directly.  
         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         orient[*,*,i] = idgen(3)

         catch, failed
         if(failed EQ 0) then cspice_tisbod, ref, id, et[0], tsipm
         catch, /cancel
         if(failed EQ 0) then $
          begin
           orient[*,*,i] = transpose(tsipm[0:2,0:2])
 
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
           ; angular velocity
           ; NOTE: precession angular velocities not included
           ;  See pck.req to interpret ra/dec rates in pck.
           ;  36525 days in julian century
           ; However, the returned orientation matrix comes from the 
           ;  ME matrix, which does account for precession.
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
           ;cspice_bodvar, id, "POLE_RA", pole_ra
           ;cspice_bodvar, id, "POLE_DEC", pole_dec
           ; pole_ra/dec[0] not used; need to convert pole_ra/dec[1] to precession 
           ; vector 

           spice_bodvar, id, "PM", pm

           w = 0
           if(n_elements(pm) GT 1) then w = pm[1] / 86400d * !dpi/180d

           avel[*,i] = w * orient[2,*,i]
          end
        end
      end
    end
  end


 return, 0
end
;===========================================================================
