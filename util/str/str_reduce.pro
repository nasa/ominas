;=============================================================================
; str_reduce
;
;
;=============================================================================
function str_reduce, s, cc

 ss = s
 sss = cc+cc

 done = 0
 while(NOT done) do $
  begin
   len = strlen(ss)
   ss = strep_s(ss, sss, cc)
   if(strlen(ss) EQ len) then done = 1
  end

 return, ss
end
;=============================================================================
