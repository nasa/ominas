;===========================================================================
; orb_compute_dmldt
;
;  Elliot and Nicholson (Planetary Rings) Eq. 4.
;
;===========================================================================
function orb_compute_dmldt, xd, gbx, GG=GG, sma=sma

 if(keyword_set(GG)) then GM = GG*sld_mass(gbx) $
 else GM = sld_gm(gbx)
 J = glb_j(gbx)
 if(keyword_set(sma)) then a = sma $
 else a = (orb_get_sma(xd))[0]
 R = glb_rref(gbx)

 ratio = R/a

 dmldt = sqrt(GM/a^3)*(   1d $
                      +  3./4.		* J[2]		* ratio^2 $
                      -  9./32.		* J[2]^2	* ratio^4 $
                      - 15./16.		* J[4]		* ratio^4 )

 return, dmldt
end
;===========================================================================


