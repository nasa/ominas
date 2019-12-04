;=============================================================================
; pic_test
;
;=============================================================================
function pic_test, pp, p
 
 n = n_elements(p)/2

 M = make_array(n,val=1d)

 ;------------------------------------------------
 ; vectors relative to central vertex
 ;------------------------------------------------
 pp0 = pp[*,1]#M
 u1 = pp[*,0]#M - pp0
 u2 = pp[*,2]#M - pp0
 u = p - pp0

 ;------------------------------------------------
 ; angles about central vertex
 ;------------------------------------------------
 theta1 = p_angle(u, u1)
 theta2 = p_angle(u, u2)
 theta12 = p_angle(u1, u2)
;stop
;erase
;plots, pp0, psym=4, col=ctyellow(), symsize=2
;plots, pp[*,0], psym=4, col=ctyellow(), symsize=2
;plots, pp[*,2], psym=4, col=ctyellow(), symsize=2
;plots, p, psym=4, col=ctgreen()

 ;------------------------------------------------------------------
 ; return subscripts of points p that lie outside this "cone"
 ;------------------------------------------------------------------
 return, where((theta1 GT theta12) OR (theta2 GT theta12))
end
;=============================================================================



;=============================================================================
; p_interior_convex
;
;  Determines whether points lie within a set of verticies.
;
;=============================================================================
function p_interior_convex, p_vert, p

;if(counter() EQ 0) then plot, /nodata, [0], $
;       xrange=[min(p[0,*]), max(p[0,*])], yrange=[min(p[1,*]), max(p[1,*])]
;;       xrange=[-1,1]*0.1, yrange=[-1,1]*0.1
;plots, p, psym=3
;plots, p_vert, psym=4, col=ctred(), symsize=0.1


 nv = n_elements(p_vert)/2
 n = n_elements(p)/2

 ;------------------------------------------------------------------
 ; test the "cone" formed by each set of three vertices
 ;------------------------------------------------------------------
 p0 = p
 w = lindgen(n)
 for i=0, nv-1 do $
  begin
   a = i-1 & b = i & c = i+1
   if(a LT 0) then a = nv-1
   if(c GE nv) then c = 0
   pp = transpose([transpose(p_vert[*,a]), $
                   transpose(p_vert[*,b]), $
                   transpose(p_vert[*,c])])

   ww = pic_test(pp, p)
   if(ww[0] NE -1) then w = rm_list_item(w, ww, only=-1)

   if(w[0] EQ -1) then break
   p = p0[*,w]
  end

 return, w
end
;=============================================================================
