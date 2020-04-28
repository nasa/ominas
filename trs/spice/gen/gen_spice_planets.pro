;===========================================================================
; gen_spice_planets
;
;===========================================================================
function gen_spice_planets, dd, ref, target=target, time=sc_time, $
                            planets=planets, $
                            n_obj=n_obj, dim=dim, status=status, $ 
                            targ_list=targ_list, constants=constants, obs=obs, values=values

 ndd = n_elements(dd)
 if(NOT keyword_set(sc)) then sc = 0l

 if(NOT defined(sc_time)) then sc_time = dblarr(ndd)

 ;----------------------------------------------------------------
 ; request all relevant planets if none specified
 ; if no targ_list file, then spice interface will get all bodies
 ;----------------------------------------------------------------
 if(NOT keyword_set(planets)) then planets = spice_read_targets(targ_list)

 ;----------------------------------------------------------------------------
 ; Move primary target to front of list 
 ;   If no planet names have been specified, or if TARGET_NAME was not in the
 ;   list, then the spice interface will retrieve all possible bodies from
 ;   the kernel pool.  In that case, TARGET_NAME is lost, so here, we 
 ;   record that string in the data descriptor.  
 ;----------------------------------------------------------------------------
 if(NOT keyword_set(target)) then target = make_array(ndd, val='UNKNOWN') $
 else if(keyword_set(planets)) then $
  begin
   nplanets = n_elements(planets)
   names = strarr(nplanets,ndd)
   for i=0, ndd-1 do $
    begin
     w = where(planets EQ target[i])
     if(w[0] EQ -1) then names[*,i] = planets $
     else $
      begin
       if(nplanets EQ 1) then names[i] = target[i] $
       else names[*,i] = [target[i], rm_list_item(planets, w[0], only='')]
      end
    end
  end
 for i=0, ndd-1 do cor_set_udata, dd[i], 'TARGET', target[i]
;;; something is stupid here: one can specify a planet, but it never gets specifically
;;; requested in this call, so all planets are retreived wasting ahuge amouint of time. 
;;; wtf

 ;-----------------------------------------------------------
 ; get the descriptors 
 ;-----------------------------------------------------------
 return, gen_to_ominas( $
            spice_planets(dd, ref, $
		time = sc_time, $
		target = target, $
		name = names, $
		n_obj=n_obj, dim=dim, status=status, constants=constants, obs=obs) )

end
;===========================================================================



