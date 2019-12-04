;=================================================================================
; assign_colors
;
;=================================================================================
function assign_colors, base_colors, _ids, interleave=interleave, $
           ids=ids, idcolors=colors

 if(NOT keyword_set(ids)) then $
  begin
   ss = sort(_ids)
   ids = _ids[ss]
   uu = uniq(ids)
   ids = ids[uu]
  end

 n_ids = n_elements(_ids)
 nids = n_elements(ids)
 nbase = n_elements(base_colors)
 nshade = nids/float(nbase)

 if(nshade - fix(nshade) NE 0) then nshade = float(fix(nshade)+1) $
 else nshade = float(fix(nshade))

 colors = lonarr(nbase,nshade)

 for i=0, nbase-1 do $
  for j=0, nshade-1 do $
   colors[i,j] = call_function('ct'+base_colors[i], (j+1)/nshade)

 if(keyword_set(interleave)) then colors = rotate(reform(colors, nbase*nshade),2) $
 else colors = reform(transpose(rotate(colors,7)), nbase*nshade)


 col = lonarr(n_ids)
 for i=0, n_elements(ids)-1 do $
  begin 
   w = where(_ids EQ ids[i])  
   if(w[0] NE -1) then col[w] = colors[i] 
  end


 return, col
end
;=================================================================================
