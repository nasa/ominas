;==============================================================================
; xshade
;
; Assumes true color visual
;
;==============================================================================
function xshade, p, shade, map=map, tv=tv, radius=radius, usemap=usemap, $
                           getmap=getmap, color=color, max=max, weight=weight

 if(NOT keyword_set(radius)) then radius = 1d
 if(NOT defined(weight)) then weight = 0.1d

 nlevels = 100d

 if(NOT keyword_set(map)) then $ 
  begin
   xsize = double(!d.x_size)
   ysize = double(!d.y_size)
  end else $
   begin
    dim = size(map, /dim)
    xsize = double(dim[0])
    ysize = double(dim[1])
   end

 n = xsize*ysize


 ;--------------------------------------------------
 ; compute image-plane indices of input points
 ;--------------------------------------------------
 if(keyword_set(tv)) then  pp = round((convert_coord(/data, /to_device, p))[0:1,*]) $
 else pp = round(p) 

 ii = xy_to_w(0, pp, sx=xsize, sy=ysize)
 

 ;--------------------------------------------------
 ; all out-of-map points will be shoved to (0,0)
 ;--------------------------------------------------
 w = in_image(0, pp, xmin=0, ymin=0, xmax=xsize-1, ymax=ysize-1)
 w = complement(ii, w)
 if(w[0] NE -1) then ii[w] = 0


 ;--------------------------------------------------
 ; construct map of summed shade values
 ;--------------------------------------------------
 if(NOT keyword_set(usemap)) then $
  begin
   ;- - - - - - - - - - - - - - - 
   ; decompose color
   ;- - - - - - - - - - - - - - - 
   r = color AND ctred()
   g = (color AND ctgreen())/256
   b = (color AND ctblue())/65536

   ;- - - - - - - - - - - - - - - 
   ; decompose map
   ;- - - - - - - - - - - - - - - 
   if(NOT keyword_set(map)) then map = dblarr(xsize, ysize, 3)
   rmap = map[*,*,0]
   gmap = map[*,*,1]
   bmap = map[*,*,2]

   ;- - - - - - - - - - - - - - - - - - - - - -
   ; get indices of shades in each level bin
   ;- - - - - - - - - - - - - - - - - - - - - -
   hh = histogram(shade*nlevels, rev=rr)
   w = where(hh NE 0)
   nw = n_elements(w)
 
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; add shade in each bin to the sum at each map location
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   width = 2*radius + 1
   for j=0, nw-1 do $
    begin
     i = w[j]
     ww = rr[rr[i]:rr[i+1]-1]
     nww = n_elements(ww)


     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; add point in gaussian if radius given
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     for xx=0, width-1 do $
      for yy=0, width-1 do $
       begin
        jj = ii[ww]
        fshade = 1d
        if(radius GT 0) then $
         begin
          dx = xx - radius
          dy = yy - radius
          dr2 = dx^2 + dy^2  
 
          djj = dx + dy*xsize
          jj = jj + djj

          fshade = exp(alog(weight)*dr2/radius^2)
         end

        rmap[jj] = rmap[jj] + r[ww]*shade[ww]*fshade
        gmap[jj] = gmap[jj] + g[ww]*shade[ww]*fshade
        bmap[jj] = bmap[jj] + b[ww]*shade[ww]*fshade
       end
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; recompose map; zero out garbage pixel so it doesn't affect normalization
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    rmap[0]=0
    gmap[0]=0
    bmap[0]=0

    map[*,*,0] = rmap
    map[*,*,1] = gmap
    map[*,*,2] = bmap
  end


 if(keyword_set(getmap)) then return, 0


 ;---------------------------------------------
 ; normalize map and extract new shade values
 ;---------------------------------------------
 shade = double(map[ii])
 shmax = max(shade)
 if(shmax GT 1) then shade = shade / shmax

 return, shade
end
;==============================================================================


;;ss = sort(ii)
;;ii = ii[ss]
;;shade = shade[ss]


; h = histogram(ii, min=0, max=n-1)
; map = reform(h, xsize, ysize)

