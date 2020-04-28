;=============================================================================
; wcp_add_quad
;
;=============================================================================
pro wcp_add_quad, tri, i, j, quad, nquad, qtri, p0

 if(i EQ j) then qq = [tri[*,i], tri[0,i]] $
 else $
  begin
   qq = [tri[*,i], tri[*,j]]
   qq = qq[sort(qq)]
   qq = qq[uniq(qq)]
  end

 quad[*,nquad] = qq
 qtri[0,nquad] = i
 qtri[1,nquad] = j

 nquad = nquad + 1


;polyfill, p0[0,tri[*,i]], p0[1,tri[*,i]], col=ctred()
;polyfill, p0[0,tri[*,j]], p0[1,tri[*,j]], col=ctred()
;stop

end
;=============================================================================



;=============================================================================
; wcp_longest_side
;
;=============================================================================
pro wcp_longest_side, p0, tri, p, q

 L01 = sqrt((p0[0,tri[0]] - p0[0,tri[1]])^2 + $
            (p0[1,tri[0]] - p0[1,tri[1]])^2)
 L02 = sqrt((p0[0,tri[0]] - p0[0,tri[2]])^2 + $
            (p0[1,tri[0]] - p0[1,tri[2]])^2)
 L12 = sqrt((p0[0,tri[1]] - p0[0,tri[2]])^2 + $
            (p0[1,tri[1]] - p0[1,tri[2]])^2)

 l = [L01, L02, L12]
 w = where(l EQ max(l))

 case w[0] of
  0 : begin
	p = 0 & q = 1
      end
  1 : begin
	p = 0 & q = 2
      end
  2 : begin
	p = 1 & q = 2
      end
 endcase

end
;=============================================================================



;=============================================================================
; wcp_requadrangulate
;
;=============================================================================
function wcp_requadrangulate, p0, tri, qtri

 ntri = n_elements(tri)/3

 quad = lonarr(4,ntri)
 nquad = 0
 qtri = lonarr(2,ntri)
 qtri[*] = -1
 taken = lonarr(ntri)

 ;----------------------------------------------------------------
 ; combine all pairs of triangles that share their longest side
 ;----------------------------------------------------------------
 for i=0, ntri-1 do if(NOT taken[i]) then $
  begin
   ;---------------------------------
   ; find longest side
   ;---------------------------------
   wcp_longest_side, p0, tri[*,i], p, q

   ;---------------------------------
   ; find neighbor to that side
   ;---------------------------------
   trp = fix(where(tri EQ tri[p,i])/3)	; all triangles containing vertex p
   trq = fix(where(tri EQ tri[q,i])/3)	; all triangles containing vertex q
   trpq = trp[nwhere(trp, trq)]		; all triangles containing both vertices

   ;---------------------------------
   ; find neighbor to that side
   ;---------------------------------
   if(n_elements(trpq) GT 1) then $
    begin
     j = (trpq[where(trpq NE i)])[0]
     wcp_longest_side, p0, tri[*,j], pp, qq
     if( ((tri[p,i] EQ tri[pp,j]) AND (tri[q,i] EQ tri[qq,j])) OR $ 
         ((tri[p,i] EQ tri[qq,j]) AND (tri[q,i] EQ tri[pp,j])) ) then $
      begin
       wcp_add_quad, tri, i, j, quad, nquad, qtri, p0
       taken[i] = 1
       taken[j] = 1
      end
    end
  end


 ;----------------------------------------------------------------
 ; enter the rest of the triangles of degenerate quadrilaterals
 ;----------------------------------------------------------------
 for i=0, ntri-1 do if(NOT taken[i]) then $
                 wcp_add_quad, tri, i, i, quad, nquad, qtri, p0


 quad = quad[*,0:nquad-1]
 qtri = qtri[*,0:nquad-1]

 return, quad
end
;=============================================================================



;=============================================================================
; wcp_map_quad_coords
;
;=============================================================================
pro wcp_map_quad_coords, x0, y0, p0, p1, quad, x1, y1

 x1 = p0[0,quad[0]] & y1 = p0[1,quad[0]]
 x2 = p0[0,quad[1]] & y2 = p0[1,quad[1]]
 x3 = p0[0,quad[2]] & y3 = p0[1,quad[2]]
 x4 = p0[0,quad[3]] & y4 = p0[1,quad[3]]
 x1p = p1[0,quad[0]] & y1p = p1[1,quad[0]]
 x2p = p1[0,quad[1]] & y2p = p1[1,quad[1]]
 x3p = p1[0,quad[2]] & y3p = p1[1,quad[2]]
 x4p = p1[0,quad[3]] & y4p = p1[1,quad[3]]

 ;----------------------------------------------------------------------
 ; solve the x' equations
 ;----------------------------------------------------------------------
 AA = [[x1, y1, x1*y1, 1d], $
       [x2, y2, x2*y2, 1d], $
       [x3, y3, x3*y3, 1d], $
       [x4, y4, x4*y4, 1d]]
 bb = [x1p, x2p, x3p, x4p]

 ludc, AA, index, /double
 x = lusol(AA, index, bb, /double)
 a = x[0] & b = x[1] & c = x[2] & d = x[3]
 

 ;----------------------------------------------------------------------
 ; solve the y' equations
 ;----------------------------------------------------------------------
 bb = [y1p, y2p, y3p, y4p]

 x = lusol(AA, index, bb, /double)
 e = x[0] & f = x[1] & g = x[2] & h = x[3]


 x1 = a*x0 + b*y0 + c*x0*y0 + d
 y1 = e*x0 + f*y0 + g*x0*y0 + h

end
;=============================================================================



;=============================================================================
; wcp_map_quad
;
;=============================================================================
function wcp_map_quad, cd=cd, image, p0, p1, quad, tri, qtri, size, interp=interp

 nquad = n_elements(quad)/4
 new_image = dblarr(size[0], size[1])

 s = size(image)

 ;--------------------------------------------------------
 ; map quadrilateral regions one-by-one
 ;--------------------------------------------------------
 for i=0, nquad-1 do $
  begin
   ;----------------------------------------------------
   ; get output image subscripts in quadrilateral i
   ;----------------------------------------------------
   w = [0]
   w0 = polyfillv(p0[0,tri[*,qtri[0,i]]], $
                  p0[1,tri[*,qtri[0,i]]], size[0], size[1])
   if(w0[0] NE -1) then w = [w, w0]
   w1 = polyfillv(p0[0,tri[*,qtri[1,i]]], $
                  p0[1,tri[*,qtri[1,i]]], size[0], size[1])
   if(w1[0] NE -1) then w = [w, w1]

   ;----------------------------------------------------
   ; map back to input image
   ;----------------------------------------------------
   if(n_elements(w) GT 1) then $
    begin
     w = w[1:*]

     x0 = transpose(p0[0,quad[*,i]]) & y0 = transpose(p0[1,quad[*,i]])
     x1 = transpose(p1[0,quad[*,i]]) & y1 = transpose(p1[1,quad[*,i]])
; tvim, 33
; plots, x0, y0, psym=6
; tvim, 32
; plots, x1, y1, psym=6

     p = dblarr(2,n_elements(w))     
     p[0,*] = double(w mod size[0])
     p[1,*] = double(fix(w / size[0]))
; tvim, 33
; plots, p, psym=3

     ;--------------------------------------------------------------------
     ; if this quadrilateral is composed of two different triangles, 
     ; fit a polynomial warp
     ;--------------------------------------------------------------------
     if(qtri[0,i] NE qtri[1,i]) then $
      begin
       wcp_map_quad_coords, p[0,*], p[1,*], p0, p1, quad[*,i], xx, yy
       pp = [xx, yy]
;stop
;       polywarp, x1, y1, x0, y0, 1, mx, my
;       pp = poly_transform(transpose(mx), transpose(my), p)
; tvim, 32
; plots, pp, psym=3
      end $
     ;-------------------------------------------------------
     ; otherwise warp as a triangle
     ;-------------------------------------------------------
     else $
      begin
;stop
       wcp_map_tri_coords, p[0,*], p[1,*], p0, p1, tri[*,qtri[0,i]], xx, yy
       pp = [xx, yy]
; tvim, 32
; plots, pp, psym=3
      end

     pp[0,*] = pp[0,*] > 0
     pp[0,*] = pp[0,*] < s[1]-1
     pp[1,*] = pp[1,*] > 0
     pp[1,*] = pp[1,*] < s[2]-1
     new_image[w] = image_interp_cam(cd=cd, image, pp[0,*], pp[1,*], interp=interp)
    end

  end


 return, new_image
end
;=============================================================================



;=============================================================================
; wcp_map_tri_coords
;
;=============================================================================
pro wcp_map_tri_coords, x0, y0, p0, p1, tri, x1, y1

 x1 = p0[0,tri[0]] & y1 = p0[1,tri[0]]
 x2 = p0[0,tri[1]] & y2 = p0[1,tri[1]]
 x3 = p0[0,tri[2]] & y3 = p0[1,tri[2]]
 x1p = p1[0,tri[0]] & y1p = p1[1,tri[0]]
 x2p = p1[0,tri[1]] & y2p = p1[1,tri[1]]
 x3p = p1[0,tri[2]] & y3p = p1[1,tri[2]]

 ;----------------------------------------------------------------------
 ; solve the x' equations
 ;----------------------------------------------------------------------
 AA = [[x1, y1, 1d], $
       [x2, y2, 1d], $
       [x3, y3, 1d]]
 bb = [x1p, x2p, x3p]

 ludc, AA, index, /double
 x = lusol(AA, index, bb, /double)
 a = x[0] & b = x[1] & d = x[2]
 

 ;----------------------------------------------------------------------
 ; solve the y' equations
 ;----------------------------------------------------------------------
 bb = [y1p, y2p, y3p]

 x = lusol(AA, index, bb, /double)
 e = x[0] & f = x[1] & h = x[2]

 x1 = a*x0 + b*y0 + d
 y1 = e*x0 + f*y0 + h

end
;=============================================================================



;=============================================================================
; wcp_map_tri
;
;=============================================================================
function wcp_map_tri, cd=cd, image, p0, p1, tri, size

 ntri = n_elements(tri)/3
 new_image = dblarr(size[0], size[1])

 s = size[image]

 ;--------------------------------------------------------
 ; map triangular regions one-by-one
 ;--------------------------------------------------------
 for i=0, ntri-1 do $
  begin
   ;----------------------------------------------------
   ; get output image subscripts in triangle i
   ;----------------------------------------------------
   w = polyfillv(p0[0,tri[*,i]], p0[1,tri[*,i]], size[0], size[1])

   ;----------------------------------------------------
   ; map back to input image
   ;----------------------------------------------------
   if(w[0] NE -1) then $
    begin
     x0 = double(w mod size[0])
     y0 = double(fix(w / size[0]))

     wcp_map_tri_coords, x0, y0, p0, p1, tri[*,i], x1, y1
     x1 = x1 > 0
     x1 = x1 < s[1]-1
     y1 = y1 > 0
     y1 = y1 < s[2]-1

     new_image[w] = image_interp_cam(cd=cd, image, x1, y1, interp=interp)
    end
  end


 return, new_image
end
;=============================================================================



;=============================================================================
; warp_cp
;
;=============================================================================
function warp_cp, cd=cd, image, p0, p1, size=size, quad=quad, interp=interp

 if(NOT keyword__set(size)) then size = (size(image))[1:2]

 ;---------------------------------------------------
 ; divide into triangular regions
 ;---------------------------------------------------
 triangulate, p0[0,*], p0[1,*], tri

 ;----------------------
 ; reproject image
 ;----------------------
 if(keyword__set(quad)) then $
  begin
   quad = wcp_requadrangulate(p0, tri, qtri)
   new_image = wcp_map_quad(cd=cd, image, p0, p1, quad, tri, qtri, size, interp=interp)
  end $
 else new_image = wcp_map_tri(cd=cd, image, p0, p1, tri, size, interp=interp)



 return, new_image
end
;=============================================================================
