;==============================================================================
; strsub_case
;
;  Matches any substring in 'match'.
;
;==============================================================================
function strsub_case, match, rules

 cases = transpose(rules[0,*])
 results = rules[1:*,*]

 n = n_elements(cases)
 for i=0, n-1 do $
   if(strpos(match, cases[i]) NE -1) then return, results[*,i]

 return, ''
end
;==============================================================================
