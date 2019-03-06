;=============================================================================
; dat_table_unique
;
; 
;=============================================================================
pro dat_table_unique, items, keyvals

 n = n_elements(items)
 mark = bytarr(n)

 for i=0, n-2 do $
  begin
   w = where(items[i+1:*] EQ items[i])
   if(w[0] NE -1) then mark[i] = 1
  end

 w = where(mark EQ 0)

 items = items[w]
 keyvals = keyvals[w,*]


end
;=============================================================================



