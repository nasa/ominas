;=============================================================================
; mosaic
;
;=============================================================================
function mosaic, maps, combine_fn=combine_fn, wt_fns=wt_fns, data=data, mosaic=mosaic, $
          weight=weight


 ;---------------------------------------------
 ; construct array containing all of the maps
 ;---------------------------------------------
 nwt = n_elements(wt_fns)

 if(keyword_set(weight)) then weight = weight / total(weight) $
 else weight = make_array(n, val=1.0)

 dim = size(maps, /dim)
 xsize = dim[0]
 ysize = dim[1]
 n = size[2]

 type = size(maps, /type)


 ;------------------------------------------------------------------------
 ; combine the maps
 ;------------------------------------------------------------------------
 for i=0, n-1 do maps[*,*,i] = maps[*,*,i] * weight[i]

 for i=0, nwt-1 do maps = maps*call_function(wt_fns[i], maps, data)
 mosaic = call_function(combine_fn, maps, data)



 return, mosaic
end
;=============================================================================



