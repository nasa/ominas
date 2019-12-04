;=============================================================================
; strcat_check
;
;=============================================================================
function strcat_check, nstars_cat, $
                ra_cat, dec_cat, faint_cat, bright_cat, parm, $
                                    dradec=dradec, radius=radius, sa=sa

 ra1 = parm.ra1 * !dpi/180d
 ra2 = parm.ra2 * !dpi/180d
 dec1 = parm.dec1 * !dpi/180d
 dec2 = parm.dec2 * !dpi/180d

 ;---------------------------------------------------------
 ; compute FOV geometry
 ;---------------------------------------------------------
 radec = strcat_radec_box([ra1, ra2], [dec1, dec2], dradec=dradec, radius=radius, sa=sa)

 ;---------------------------------------------------------
 ; no need to continue if /force
 ;---------------------------------------------------------
 if(keyword_set(force)) then return, 0

 ;---------------------------------------------------------
 ; check whether catalog falls within brightness limits
 ;---------------------------------------------------------
 if(finite(parm.faint)) then if(parm.faint LT bright_cat) then return, -1
 if(finite(parm.bright)) then if(parm.bright gt faint_cat) then return, -1

return, 0
 ;---------------------------------------------------------
 ; estimate # catalog stars in FOV
 ;---------------------------------------------------------
 nfov = nstars_cat * sa/4d/!dpi

 ;---------------------------------------------------------
 ; if nbright specified, adjust magnitude limit if needed
 ; otherwise, check if max # stars exceeded
 ;---------------------------------------------------------
 if(keyword_set(parm.nbright)) then $
  begin
;   _faint = ..
   if(finite(parm.faint)) then parm.faint = parm.faint > _faint
  end $
 else if(nfov GT parm.nmax) then return, -1


 return, 0
end
;=============================================================================
