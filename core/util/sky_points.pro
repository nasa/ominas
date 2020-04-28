;=============================================================================
; sky_points
;
;=============================================================================
function sky_points, _image, nsig, scale, mask=mask, umask=umask, extend=extend, $
                     nmax=nmax, edge=edge, all=all

 s = size(_image)


 ;----------------------------------------
 ; apply umask
 ;----------------------------------------
 if(keyword_set(umask)) then $
  begin
   w = where(umask EQ 1)
   if(w[0] NE -1) then _image[w] = 0
  end 


 ;----------------------------------------
 ; high-pass filter
 ;----------------------------------------
; bgim = image_bg(_image)
 bgim = activity(_image)


 ;----------------------------------------
 ; mask out extended objects if desired
 ;----------------------------------------
 ii = -1
 if(keyword__set(mask)) then $
  begin
   ii = sky_mask(_image, 2d*scale, extend=extend)
   if(ii[0] NE -1) then $
    begin
     image = dblarr(s[1],s[2])
     image[ii] = bgim[ii]
     sky = image[ii]
    end
  end 

 if(NOT keyword__set(mask) OR (ii[0] EQ -1)) then $
  begin
   image = bgim
   sky = image
  end
;tvim, image<25, z=0.3, /ord


 ;----------------------------------------
 ; identify points > nsig above the mean
 ;----------------------------------------
;;; this doesn't seem to get used
 sigma = stdev(sky, mean)

 done = 0
 repeat $
  begin
   w = where((image - mean) GT nsig*sigma)
   if(w[0] EQ -1) then return, 0
   if(NOT keyword__set(nmax)) then done = 1 $
   else if(n_elements(w) LE nmax) then done = 1 $
   else nsig = nsig + 1
  endrep until(done)

 
 ;----------------------------------------
 ; select cluster centers
 ;----------------------------------------
 im = dblarr(s[1], s[2])
 im[w] = 1
 if(keyword__set(scale)) then points = image_clusters(im, scale, all=all) $
 else points = w_to_xy(im, w)

 
 ;----------------------------------------
 ; discard detections too close to edge
 ;----------------------------------------
 if(keyword_set(edge)) then $
  begin
   w = where((points[0,*] GE edge) AND (points[0,*] LE s[1] - edge) $
             AND (points[1,*] GE edge) AND (points[1,*] LE s[2] - edge) )
   if(w[0] EQ -1) then return, 0
   points = points[*,w]
  end


 return, points
end
;=============================================================================
