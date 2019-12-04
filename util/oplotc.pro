;==================================================================================
; oplotc
;
;==================================================================================
pro oplotc, x, y, colors=_colors, polar=polar, psyms=psyms, $
               solid=solid, symsize=symsize, thick=thick, pixmap=pixmap

 if(NOT keyword_set(symsize)) then symsize = 1 
 if(NOT keyword_set(thick)) then thick = 1 

 if(NOT keyword_set(_colors)) then _colors = !p.color

 colors = _colors
 if(n_elements(colors) EQ 1) then colors = make_array(n_elements(x), val=colors[0])

 ss = sort(colors)
 col = colors[ss]
 uu = uniq(col)
 col = col[uu]

 nk = 1
 if(keyword_set(solid)) then nk = 5

 wnum = !d.window

 for i=0, n_elements(col)-1 do $
  begin
   if(defined(pixmap)) then wset, pixmap $
   else if(arg_present(pixmap)) then $
    begin
     window, /pixmap, xsize=!d.x_size, ysize=!d.y_size
     pixmap = !d.window
    end

   w = where(colors EQ col[i])

   sym = psyms[w]
   ss = sort(sym)
   sym = sym[ss]
   uu = uniq(sym)
   sym = sym[uu]

   for j=0, n_elements(sym)-1 do $
    begin
     ww = where(psyms[w] EQ sym[j])
     for k=0, nk-1 do $
      oplot, x[w[ww]], y[w[ww]], psym=sym[j], col=col[i], polar=polar, $
            symsize=float((nk-k))/nk * symsize, thick=thick
    end

   if(defined(pixmap)) then $
     begin
      wset, wnum
      device, copy=[0,0, !d.x_size,!d.y_size, 0,0, pixmap]
     end

  end


end
;==================================================================================
