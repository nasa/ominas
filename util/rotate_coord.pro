;==================================================================================
; rotate_coord
;
;  Performs the coordinate transformations corresponding to the idl 
;  "rotate" command.
;
;==================================================================================
function rotate_coord, p, dir, inverse=inverse, size=size

 nt = (np = 1)
 dim = size(p, /dim)
 if(n_elements(dim) GT 1) then np = dim[1]
 if(n_elements(dim) GT 2) then nt = dim[2]

 if(NOT keyword_set(size)) then size = dblarr(2,np,nt)

 
 px = p[0,*,*]
 py = p[1,*,*]
 sx = size[0,*,*]
 sy = size[1,*,*]

 w = where(dir EQ 1)
 if(w[0] NE -1) then $
  begin
   pxx = px[w]
   px[w] = sy[w] - py[w] - 1d
   py[w] = pxx
   if(keyword_set(inverse)) then $
    begin
     px = -px
     py = -py
    end
  end

 w = where(dir EQ 2)
 if(w[0] NE -1) then $
  begin
   px[w] = sx[w] - px[w] - 1d
   py[w] = sy[w] - py[w] - 1d
  end

 w = where(dir EQ 3)
 if(w[0] NE -1) then $
  begin
   pyy = py[w]
   py[w] = sx[w] - px[w] - 1d
   px[w] = pyy
   if(keyword_set(inverse)) then $
    begin
     px = sx - px - 1d
     px = sy - py - 1d
    end
  end

 w = where(dir EQ 4)
 if(w[0] NE -1) then $
  begin
   pyy = py[w]
   py[w] = px[w]
   px[w] = pyy
  end

 w = where(dir EQ 5)
 if(w[0] NE -1) then $
  begin
   px[w] = sx[w] - px[w] - 1d
  end

 w = where(dir EQ 6)
 if(w[0] NE -1) then $
  begin
   pyy = py[w]
   py[w] = sx[w] - px[w] - 1d
   px[w] = sy[w] - pyy - 1d
  end

 w = where(dir EQ 7)
 if(w[0] NE -1) then $
  begin
   py[w] = sy[w] - py[w] - 1d
  end


 pp = dblarr(2,np,nt, /nozero)
 pp[0,*,*] = px
 pp[1,*,*] = py

 return, pp
end
;==================================================================================






function _rotate_coord, p, dir, inverse=inverse, size=_size

 if(NOT keyword_set(_size)) then _size = [0d,0d]
 nt = (np = 1)
 dim = size(p, /dim)
 if(n_elements(dim) GT 1) then np = dim[1]
 if(n_elements(dim) GT 2) then nt = dim[2]

 size = (_size#make_array(np, val=1d))[linegen3z(2,np,nt)]

 for i=0, nt-1 do $
  begin
   case dir of
    0	: return, p 
    1	: begin 
	   pp = rotate(p,5) 
	   pp[0,*,i] = size[0,*,i]-pp[0,*,i] - 1d
	   if(keyword_set(inverse)) then pp = -pp
	  end
    2	: return, size-p - 1d
    3	: begin 
	   pp = rotate(p,5)
	   pp[1,*,i] = size[1,*,i]-pp[1,*,i] - 1d
	   if(keyword_set(inverse)) then pp = size-pp - 1d
	  end
    4	: pp = rotate(p,5)
    5	: begin 
	   pp = p
	   pp[0,*,i] = size[0,*,i]-pp[0,*,i] - 1d
	  end
    6	: pp = size-rotate(p,5) - 1d
    7	: begin 
	   pp = p
	   pp[1,*,i] = size[1,*,i]-pp[1,*,i] - 1d
	  end
    else: message, 'Invalid rotation.'
   endcase
  end


 return, pp
end
;==================================================================================



