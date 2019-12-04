;==============================================================================
; corot_to_disk
;
;==============================================================================
function corot_to_disk, corot_pts, cd=cd, dkx=dkx, gbx=gbx, t0=t0, $
           dmldt=dmldt, times=times

 disk_pts = corot_pts
 disk_pts[*,1,*] = $
     corot_to_disk_lon(corot_pts[*,1,*], cd=cd, dkx=dkx, gbx=gbx, t0=t0, $
           dmldt=dmldt, times=times)

 return, disk_pts
end
;==============================================================================
