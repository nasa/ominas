;=============================================================================
; strep_ss
;
;  Replaces every occurrence of string _s in string s with string ss.
;
;  Same as strep_s, except ss has multiple elements, like s
;
;=============================================================================
function strep_ss, s, _s, ss

 ns = n_elements(s)
 sss = s
 lss = strlen(ss)
 l_s = strlen(_s)

 i = 0l
 while(i LT ns) do $
  begin
   p = -1
   pp = strlen(s[i])
   repeat $
    begin
     pp = strpos(strmid(s[i], 0, pp), _s, /reverse_search)
     p = append_array(p, pp, /def)
    endrep until(pp[0] EQ -1)

   w = where(p NE -1)
   if(w[0] NE -1) then $
    begin
     p = p[w]
     p = p[sort(p)]
     np = n_elements(p)
     sss[i] = strmid(s[i], 0, p[0])
;     for j=0, np-1 do sss[i] = sss[i] + ss[i] + strmid(s[i], p[j]+lss[i]-1, lss[i])
;     for j=0, np-1 do sss[i] = sss[i] + ss[i] + strmid(s[i], p[j]+lss[i], lss[i])

     for j=0, np-2 do sss[i] = sss[i] + ss[i] + $
                             strmid(s[i], p[j]+l_s, p[j+1]-p[j]-lss[i]-1)
;     sss[i] = sss[i] + ss[i] + strmid(s[i], p[np-1]+l_s, strlen(s[i])-p[np-1]-lss[i]+1)
     sss[i] = sss[i] + ss[i] + strmid(s[i], p[np-1]+l_s, strlen(s[i]))
    end
   i = i + 1
  end

 return, sss
end
;=============================================================================
