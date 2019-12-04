;================================================================================
; root_interp
; 
;
;================================================================================
function root_interp, arg1, arg2

 if(keyword_set(arg2)) then $
  begin
   x = arg1
   y = arg2
  end $
 else $
  begin
   y = arg1
   x = dindgen(n_elements(arg1))
  end

 w = where(y*shift(y,-1) LT 0)
 ww = where(w EQ n_elements(x)-1)
 if(ww[0] NE -1) then w = rm_list_item(w, ww, only=-1)
 if(w[0] NE -1) then $
  begin
   n = n_elements(w)
   w = [transpose(w), transpose(w+1)]

   x0 = dblarr(n)
   for i=0, n-1 do $
    begin
     ww = where(x[w[*,i]] EQ max(x[w[*,i]]))
     xmax = x[w[ww,i]] & ymax = y[w[ww,i]]
     xmin = x[w[1-ww,i]] & ymin = y[w[1-ww,i]]
     x0[i] = xmin + (xmax-xmin) * abs(ymin/(ymax-ymin))
    end
  end

 w = where(y EQ 0)
 if(w[0] NE -1) then x0 = append_array(x0, x[w])

 if(NOT keyword_set(x0)) then return, [-1l]

 x0 = x0[sort(x0)]

 w = where(x0 EQ 0)
 if(w[0] NE -1) then x0 = rm_list_item(x0, w, only=-1)
 w = where(x0 EQ n_elements(x)-1)
 if(w[0] NE -1) then x0 = rm_list_item(x0, w, only=-1)

 return, x0
end
;================================================================================
