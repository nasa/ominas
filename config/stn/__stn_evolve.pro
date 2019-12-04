;===========================================================================
; stn_evolve
;
;  Recomputes inertial position of stations given in cds for the planet
;  with state pd.
;
;===========================================================================
pro stn_evolve, cds, pd

 ncd = n_elements(cds)
 pos_surf = transpose(cor_udata(cds, 'POS_SURF'))

 pos = bod_body_to_inertial_pos(pd, $
         glb_globe_to_body(pd, pos_surf))
 bod_set_pos, cds, reform(transpose(pos), 1, 3, ncd)

end
;===========================================================================
