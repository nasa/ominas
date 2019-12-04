;==============================================================================
; tvxmap
;
;==============================================================================
pro tvxmap, _xmap, _ptd, color=color, fn=fn, data=data, max=max, min=min, $
            radius=radius, weight=weight, bin=bin, offset=offset

 ptd = nv_clone(_ptd)
 if(keyword_set(offset)) then pnt_offset, ptd, offset*bin

 xmap = _xmap

 dim = size(xmap, /dim)
 nx = dim[0]
 ny = dim[1]

 np = n_elements(ptd)


 for i=0, np-1 do $
  begin
   p = pnt_points(/cat, /vis, ptd[i])
   if(keyword_set(p)) then $
    begin
     if(keyword_set(fn)) then shade = call_function(fn, ptd[i], data)
     shade = xshade(p, shade, map=xmap, color=color, radius=radius, weight=weight, /getmap)
    end
  end


 xmap = bytscl(xmap, max=max)

device, set_graphics=7
 if(keyword_set(bin)) then xmap = rebin(xmap, nx/bin, ny/bin, 3)
 for j=1, 3 do tvim, offset=offset, /no_scale, xmap[*,*,j-1], channel=j
device, set_graphics=3

 nv_free, ptd
end
;==============================================================================




