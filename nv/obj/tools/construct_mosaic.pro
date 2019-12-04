;=============================================================================
; cm_combine_edge1
;
;  This routine is obsolete.  It is now accomplished using 
;  cm_wt_edge1 and cm_combine_mean.
;
;=============================================================================
function cm_combine_edge1, maps, data

 width = 15

 if(keyword_set(data)) then $
  begin
  end

 s = size(maps)
 n = s[3]

 wts = fltarr(s[1], s[2], s[3])
 masks = fltarr(s[1], s[2], s[3])

 ;--------------------------
 ; compute weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   map = maps[*,*,i]

   ;- - - - - - - - - - - - - - - - -
   ; compute mask
   ;- - - - - - - - - - - - - - - - -
   w0 = where(map NE 0)	
   mask = masks[*,*,i]
   mask[w0] = 1d
   masks[*,*,i] = mask

   ;- - - - - - - - - - - - - - - - -
   ; compute weight
   ;- - - - - - - - - - - - - - - - -
   _mask = fltarr(s[1]+3d*width, s[2]+3d*width)
   _mask[width+1:width+s[1],width+1:width+s[2]] = mask

   kernel = gauss_2d(0, 0, width/2d, 2d*width, 2d*width)
   _wt = convol(_mask, kernel, /center)
   _wt = _wt[width+1:width+s[1],width+1:width+s[2]]
   _wt = _wt - min(_wt)
   wt = _wt & wt[*] = 0
   wt[w0] = _wt[w0]

   wts[*,*,i] = wt
  end


 ;--------------------------
 ; normalize weights
 ;--------------------------
 wsum = total(wts,3)
 for i=0, n-1 do $
  begin
   mask = masks[*,*,i]
   w = where(mask EQ 1)
   if(w[0] NE -1) then $
    begin
     wt = wts[*,*,i]
     ww = where(wsum[w] NE 0)
     wt[w[ww]] = wt[w[ww]] / wsum[w[ww]]
     wts[*,*,i] = wt
    end
  end


 ;--------------------------------
 ; apply weights
 ;--------------------------------
 return, total(maps*wts,3)
end
;=============================================================================



;=============================================================================
; cm_combine_edge
;
;  This routine is obsolete.  It is now accomplished using 
;  cm_wt_edge and cm_combine_mean.
;
;=============================================================================
function cm_combine_edge, maps, data

 pp = 1d
 if(defined(data)) then pp = data

 s = size(maps)
 n = s[3]

 wts = fltarr(s[1], s[2], s[3])
 masks = lonarr(s[1], s[2], s[3])

 ;--------------------------
 ; compute weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   map = maps[*,*,i]

   ;- - - - - - - - - - - - - - - - -
   ; compute mask and bounds
   ;- - - - - - - - - - - - - - - - -
   w0 = where(map NE 0)				; basic mask; gives bounds
   xy = w_to_xy(map, w0)

   xmin = min(xy[0,*])
   xmax = max(xy[0,*])
   ymin = min(xy[1,*])
   ymax = max(xy[1,*])

   ; this mask ignores holes in the map
   mask = masks[*,*,i]
   ww = polyfillv([xmin, xmax, xmax, xmin], [ymin, ymin, ymax, ymax], s[1], s[2])
   xxx = lindgen(s[1])#make_array(s[2],val=1l)
   yyy = lindgen(s[2])##make_array(s[1],val=1l)
   ww = where((xxx GE xmin) AND (xxx LE xmax) AND (yyy GE ymin) AND (yyy LE ymax))

   if(ww[0] NE -1) then $
    begin
     mask[ww] = 1
     masks[*,*,i] = mask
     w = where(mask EQ 1)

     ;- - - - - - - - - - - - - - - - - - - - - - 
     ; compute weight
     ;- - - - - - - - - - - - - - - - - - - - - - 
     xx = fltarr(s[1], s[2])
     xmm = xmax-xmin
     ymm = ymax-ymin
     xx[w] = findgen(xmm+1)#make_array(ymm+1, val=1d) + xmin
     yy = fltarr(s[1], s[2])
     yy[w] = findgen(ymax-ymin+1)##make_array(xmax-xmin+1, val=1d) + ymin

     wtx = fltarr(s[1], s[2])
     wty = fltarr(s[1], s[2])

;     wtx[w] = (xx[w]-xmin)^pp*(xx[w]-xmax)^pp
;     wty[w] = (yy[w]-ymin)^pp*(yy[w]-ymax)^pp
xmax = xmax + 1
xmin = xmin - 1
     wtx[w] = abs((xx[w]-xmin)/xmm)^pp*abs((xx[w]-xmax)/xmm)^pp
     wty[w] = abs((yy[w]-ymin)/ymm)^pp*abs((yy[w]-ymax)/ymm)^pp

     wt = wtx*wty
     wt = wt / max(wt)

     ww0 = complement(map, w0)
     wt[ww0] = 0				; mask out holes

     wts[*,*,i] = wt
    end
  end


;if(counter() EQ 50) then stop
  wsum = total(wts,3)

 ;--------------------------
 ; normalize weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   mask = masks[*,*,i]
   w = where(mask EQ 1)
   if(w[0] NE -1) then $
    begin
     wt = wts[*,*,i]
     ww = where(wsum[w] NE 0)
     wt[w[ww]] = wt[w[ww]] / wsum[w[ww]]
     wts[*,*,i] = wt
    end
  end

 ;--------------------------------
 ; apply weights
 ;--------------------------------
 return, total(maps*wts,3)
end
;=============================================================================



;=============================================================================
; cm_combine_emm
;
; emm^x weighting with emmision angle limits
;
; data is taken to be a structure with the following possible fields:
;
; emm:	Emmission cosine arrays. 
; x:	Emmission cosine power for weighting. 
; emm0:	Minimum allowable emission cosine. 
;
; This routine is obsolete.  It is now accomplished using 
; cm_wt_emm and cm_combine_sum
;
;=============================================================================
function cm_combine_emm, maps, data

 s = size(maps)
 xsize = s[1]
 ysize = s[2]
 n = 1
 if(s[0] EQ 3) then n = s[3]

 x = 5d
 emm0 = 0d

 tags = tag_names(data)

 w = where(tags EQ 'EMM')
 if(w[0] NE -1) then emms = data.emm

 w = where(tags EQ 'X')
 if(w[0] NE -1) then x = data.x

 w = where(tags EQ 'EMM0')
 if(w[0] NE -1) then emm0 = data.emm0

 w = where(emms LE emm0)
 if(w[0] NE -1) then emms[w] = 0

 wt = emms^x

 norm = (total(wt, 3))[linegen3z(xsize,ysize,n)]
 w = where(norm EQ 0)
 if(w[0] NE -1) then norm[w] = 1
 wt = wt / norm
 if(w[0] NE -1) then wt[w] = 0

 return, total(maps*wt,3)
end
;=============================================================================



;=============================================================================
; cm_combine_emm5
;
; emm^5 weighting suggested by Ashwin Vasavada.
;
; If data is given, it is taken to be the emission angle array generated by
; pg_photom and reprojected by pg_map.  
;
; This routine is obsolete.  It is now accomplished using 
; cm_wt_emm5 and cm_combine_sum
;
;=============================================================================
function cm_combine_emm5, maps, data

 s = size(maps)
 xsize = s[1]
 ysize = s[2]
 n = 1
 if(s[0] EQ 3) then n = s[3]

 emms = data

 wt = emms^5

 norm = (total(wt, 3))[linegen3z(xsize,ysize,n)]
 w = where(norm EQ 0)
 if(w[0] NE -1) then norm[w] = 1
 wt = wt / norm
 if(w[0] NE -1) then wt[w] = 0

 return, total(maps*wt,3)
end
;=============================================================================












;=============================================================================
; cm_wt_edge1
;
;=============================================================================
function cm_wt_edge1, maps, data, aux

 width = 15

 if(keyword_set(data)) then $
  begin
  end

 s = size(maps)
 n = s[3]

 wts = fltarr(s[1], s[2], s[3])
 masks = fltarr(s[1], s[2], s[3])

 ;--------------------------
 ; compute weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   map = maps[*,*,i]

   ;- - - - - - - - - - - - - - - - -
   ; compute mask
   ;- - - - - - - - - - - - - - - - -
   w0 = where(map NE 0)	
   mask = masks[*,*,i]
   mask[w0] = 1d
   masks[*,*,i] = mask

   ;- - - - - - - - - - - - - - - - -
   ; compute weight
   ;- - - - - - - - - - - - - - - - -
   _mask = fltarr(s[1]+3d*width, s[2]+3d*width)
   _mask[width+1:width+s[1],width+1:width+s[2]] = mask

   kernel = gauss_2d(0, 0, width/2d, 2d*width, 2d*width)
   _wt = convol(_mask, kernel, /center)
   _wt = _wt[width+1:width+s[1],width+1:width+s[2]]
   _wt = _wt - min(_wt)
   wt = _wt & wt[*] = 0
   wt[w0] = _wt[w0]

   wts[*,*,i] = wt
  end


 ;--------------------------
 ; normalize weights
 ;--------------------------
 wsum = total(wts,3)
 for i=0, n-1 do $
  begin
   mask = masks[*,*,i]
   w = where(mask EQ 1)
   if(w[0] NE -1) then $
    begin
     wt = wts[*,*,i]
     ww = where(wsum[w] NE 0)
     wt[w[ww]] = wt[w[ww]] / wsum[w[ww]]
     wts[*,*,i] = wt
    end
  end


 ;--------------------------------
 ; apply weights
 ;--------------------------------
 return, wts
end
;=============================================================================



;=============================================================================
; cm_wt_edge
;
;  Maps are weighted so as to contribute nothing at their edges.
;
;=============================================================================
function cm_wt_edge, maps, data, aux

 pp = 1d
 if(defined(data)) then pp = data

 s = size(maps)
 n = s[3]

 wts = fltarr(s[1], s[2], s[3])
 masks = lonarr(s[1], s[2], s[3])

 ;--------------------------
 ; compute weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   map = maps[*,*,i]

   ;- - - - - - - - - - - - - - - - -
   ; compute mask and bounds
   ;- - - - - - - - - - - - - - - - -
   w0 = where(map NE 0)				; basic mask; gives bounds
   xy = w_to_xy(map, w0)

   xmin = min(xy[0,*])
   xmax = max(xy[0,*])
   ymin = min(xy[1,*])
   ymax = max(xy[1,*])

   ; this mask ignores holes in the map
   mask = masks[*,*,i]
   ww = polyfillv([xmin, xmax, xmax, xmin], [ymin, ymin, ymax, ymax], s[1], s[2])
   xxx = lindgen(s[1])#make_array(s[2],val=1l)
   yyy = lindgen(s[2])##make_array(s[1],val=1l)
   ww = where((xxx GE xmin) AND (xxx LE xmax) AND (yyy GE ymin) AND (yyy LE ymax))

   if(ww[0] NE -1) then $
    begin
     mask[ww] = 1
     masks[*,*,i] = mask
     w = where(mask EQ 1)

     ;- - - - - - - - - - - - - - - - - - - - - - 
     ; compute weight
     ;- - - - - - - - - - - - - - - - - - - - - - 
     xx = fltarr(s[1], s[2])
     xmm = xmax-xmin
     ymm = ymax-ymin
     xx[w] = findgen(xmm+1)#make_array(ymm+1, val=1d) + xmin
     yy = fltarr(s[1], s[2])
     yy[w] = findgen(ymax-ymin+1)##make_array(xmax-xmin+1, val=1d) + ymin

     wtx = fltarr(s[1], s[2])
     wty = fltarr(s[1], s[2])

;     wtx[w] = (xx[w]-xmin)^pp*(xx[w]-xmax)^pp
;     wty[w] = (yy[w]-ymin)^pp*(yy[w]-ymax)^pp
xmax = xmax + 1
xmin = xmin - 1
     wtx[w] = abs((xx[w]-xmin)/xmm)^pp*abs((xx[w]-xmax)/xmm)^pp
     wty[w] = abs((yy[w]-ymin)/ymm)^pp*abs((yy[w]-ymax)/ymm)^pp

     wt = wtx*wty
     wt = wt / max(wt)

     ww0 = complement(map, w0)
     wt[ww0] = 0				; mask out holes

     wts[*,*,i] = wt
    end
  end


;if(counter() EQ 50) then stop
  wsum = total(wts,3)

 ;--------------------------
 ; normalize weights
 ;--------------------------
 for i=0, n-1 do $
  begin
   mask = masks[*,*,i]
   w = where(mask EQ 1)
   if(w[0] NE -1) then $
    begin
     wt = wts[*,*,i]
     ww = where(wsum[w] NE 0)
     wt[w[ww]] = wt[w[ww]] / wsum[w[ww]]
     wts[*,*,i] = wt
    end
  end

 ;--------------------------------
 ; apply weights
 ;--------------------------------
 return, wts
end
;=============================================================================



;=============================================================================
; cm_combine_median
;
;
;=============================================================================
function cm_combine_median, maps, data, aux
 return, image_median(maps)
end
;=============================================================================



;=============================================================================
; cm_combine_sum
;
;
;=============================================================================
function cm_combine_sum, maps, data, aux
 return, size(maps,/n_dim) EQ 3 ? total(maps,3) : maps
end
;=============================================================================



;=============================================================================
; cm_combine_mean
;
;
;=============================================================================
function cm_combine_mean, maps, data, aux
;-stop

 dim = size(maps, /dim)
 xsize = dim[0]
 ysize = dim[1]
 n = dim[2]

 norm = total((maps NE 0), 3)

 w = where(norm EQ 0)
 if(w[0] NE -1) then norm[w] = 1

 result = total(maps,3)/norm
 if(w[0] NE -1) then result[w] = 0

 return, result
end
;=============================================================================



;=============================================================================
; cm_combine_overlay
;
;  Each map is lain over the previous maps with no combination.
;
;=============================================================================
function cm_combine_overlay, maps, data, aux

 s = size(maps)
 n = s[3]

 for i=0, n-1 do $
  begin
   if(i EQ 0) then result = maps[*,*,0] $
   else $
    begin
     im = maps[*,*,i]
     w = where(im NE 0)
     if(w[0] NE -1) then result[w] = im[w]
    end
  end

 return, result
end
;=============================================================================



;=============================================================================
; cm_wt_rescale
;
;  Map brightnesses are uniformly scaled based on overlaps.
;
;=============================================================================
function cm_wt_rescale, maps, data, aux

 dim = size(maps, /dim)
 xsize = dim[0]
 ysize = dim[1]
 n = dim[2]


 ;------------------------------------------------
 ; compute overlap matrix if not given
 ;------------------------------------------------
 if(keyword_set(data)) then om = data $
 else $
  begin
   om = dblarr(n,n)			; total map-i dn in overlap of map i with map j
   scratch = make_array(dim=dim[0:1], val=0d)

   for i=0, n-1 do $
    for j=1+1, n-1 do $
     begin
      imi = maps[*,*,i]
      imj = maps[*,*,j]
      wi = where(imi NE 0)
      wj = where(imj NE 0)

      if((wi[0] NE -1) AND (wj[0] NE -1)) then $
       begin
        scratch[wi] = 1
        scratch[wj] = scratch[wj] + 1
        w = where(scratch EQ 2)
        if(w[0] NE -1) then $
         begin     
          om[i,j] = total((maps[*,*,i])[w])
          om[j,i] = total((maps[*,*,j])[w])
         end
       end

      scratch[*] = 0    
     end
  end


 ;-----------------------------------------
 ; find optimum corrections
 ;-----------------------------------------
 tom = transpose(om)
 A = - om*tom
 ii = diaggen(n,1)
 A[ii] = total(tom^2,1) - om[ii]^2
 b = transpose(total(om*(om-tom),1))

 delta = mbfit(A, b)
 wt = (1d + transpose((delta#make_array(ysize, val=1d))[linegen3z(n,ysize,xsize)]))

 return, wt
end
;=============================================================================



;=============================================================================
; cm_wt_emm
;
; emm^x weighting with emmision angle limits
;
; If data is given, it is taken to be a structure with the following 
; possible fields:
;
; emm:	Emmission cosine arrays.  
; x:	Emmission cosine power for weighting. 
; emm0:	Minimum allowable emission cosine.  
;
; If aux is given, it is taken to be a structure with the following 
; possible fields:
;
; emm:	Emmission cosine arrays.  
;
;=============================================================================
function cm_wt_emm, maps, data, aux

 s = size(maps)
 xsize = s[1]
 ysize = s[2]
 n = 1
 if(s[0] EQ 3) then n = s[3]

 x = 5d
 emm0 = 0d

 emms = aux.emm

 tags = tag_names(data)

 w = where(tags EQ 'X')
 if(w[0] NE -1) then x = data.x

 w = where(tags EQ 'EMM0')
 if(w[0] NE -1) then emm0 = data.emm0

 w = where(emms LE emm0)
 if(w[0] NE -1) then emms[w] = 0

 wt = emms^x

 norm = n gt 1 ? (total(wt, 3))[linegen3z(xsize,ysize,n)] : wt
 w = where(norm EQ 0)
 if(w[0] NE -1) then norm[w] = 1
 wt = wt / norm
 if(w[0] NE -1) then wt[w] = 0

 return, wt
end
;=============================================================================




;=============================================================================
; construct_mosaic
;
;=============================================================================
function construct_mosaic, maps, combine_fn=combine_fn, wt_fns=wt_fns, data=data, aux=aux


 ;---------------------------------------------
 ; weight the maps
 ;---------------------------------------------
 nwt = n_elements(wt_fns)
 for i=0, nwt-1 do maps = maps*call_function(wt_fns[i], maps, data, aux)


 ;------------------------------------------------------------------------
 ; combine the maps
 ;------------------------------------------------------------------------
 mosaic = call_function(combine_fn, maps, data, aux)



 return, mosaic
end
;=============================================================================



