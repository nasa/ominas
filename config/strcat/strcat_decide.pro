;=============================================================================
; strcat_decide
;
;=============================================================================
function strcat_decide, nstars, maxstars, ra_fov, dec_fov, nbright, force, $
                               dradec=dradec, radius=radius, sa=sa

 ;---------------------------------------------------------
 ; compute FOV geometry
 ;---------------------------------------------------------
 radec = strcat_radec_box([ra1, ra2]*!dpi/180d, [dec1, dec2]*!dpi/180d, $
                                              dradec=dradec, radius=radius, sa=sa)

 ;---------------------------------------------------------
 ; no need to continue if /force
 ;---------------------------------------------------------
 if(keyword_set(force)) then return, 0

 ;---------------------------------------------------------
 ; estimate # catalog stars in FOV
 ;---------------------------------------------------------
 ncat = nstars * sa/4d/!dpi

 ;---------------------------------------------------------
 ; if nbright specified, adjust magnitude limit if needed
 ; otherwise, check if max # stars exceeded
 ;---------------------------------------------------------
 if(keyword_set(nbright)) then $
  begin
   _faint = ..
   if(defined(faint)) then faint = faint > _faint
  end $
 else if(ncat GT maxstars) then return, -1


 return, 0
end
;=============================================================================
