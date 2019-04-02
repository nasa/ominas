;===========================================================================
; spice_get_cameras
;
;
;===========================================================================
function spice_get_cameras, sc, inst, plat, ref, et, tol, $
                        cam_pos, cam_vel, cmat, cam_avel, pos_only, obs=obs


 ;----------------------------------------------------------------------
 ; convert obs name to id if necessary
 ;----------------------------------------------------------------------
 if(NOT keyword_set(obs)) then obs = 0 $
 else $
  begin
   tp = size(obs, /type)
   if (tp EQ 7 ) then cspice_bodn2c, obs, obs, name_found
  end


 ;--------------------------------------------------------------------
 ; spacecraft position and velocity w.r.t. SS barycenter
 ;--------------------------------------------------------------------
 cspice_spkgeo, sc, et, ref, obs, sc_state, ltime
 cam_pos = transpose(sc_state[0:2])
 cam_vel = transpose(sc_state[3:5])

 if(keyword_set(pos_only)) then return, 0


 ;--------------------------------------------------------------
 ; Get C-matrix
 ;--------------------------------------------------------------
 cspice_sce2c, sc, et, sclk

 id = inst
 if(keyword_set(plat)) then id = plat

 cspice_ckgpav, id, sclk, tol, ref, pmat, avel, clkout, found
 if(NOT found) then $
  begin
   cspice_ckgp, id, sclk, tol, ref, pmat, clkout, found
   if(NOT found) then begin
     nv_message, /warning, verb=0.1, 'no orientation data avaliable.'
     return, -1
   endif
   nv_message, /warning, verb=0.1, 'no angular velocity data avaliable.'
  end


 ;--------------------------------------------------------------
 ; If a platform id is given, rotate to find C-matrix
 ;  This algorithm derived from naiflib routine tkfram.  Not all 
 ;  transformations are implemented.
 ;--------------------------------------------------------------
 if(keyword_set(plat)) then $
  begin
   cspice_frmnam, inst, name_inst
   cspice_frmnam, plat, name_plat
   cspice_pxform, name_inst, name_plat, et, _M

   M = dblarr(3,3, /nozero)
   M[*,0] = -_M[0,*]
   M[*,1] = -_M[1,*]
   M[*,2] = _M[2,*]

   cmat = M ## pmat
  end $
 else cmat = pmat


 return, 0
end
;===========================================================================


