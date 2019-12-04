;==============================================================================
; disk_to_corot_lon
;
;==============================================================================
function disk_to_corot_lon, disk_lons, cd=cd, dkx=dkx, gbx=gbx, t0=t0, $
           dmldt=dmldt, times=times

 if(NOT keyword_set(t0)) then t0 = 0d
;; nv = n_elements(disk_lons)

; maybe should compute dmldt based on radial coordinate of each point
 if(NOT keyword_set(dmldt)) then dmldt = orb_compute_dmldt(dkx, gbx)
 if(NOT keyword_set(times)) then times = bod_time(cd)

 lon0 = dmldt * (times - t0[0])

;; corot_lons = reduce_angle(disk_lons - lon0##make_array(nv,val=1d))
 corot_lons = reduce_angle(disk_lons - lon0)

 return, corot_lons
end
;==============================================================================
