;==============================================================================
; w10n_query_string
;
;==============================================================================
function w10n_query_string, s0, s1, step

 ndim = n_elements(s0)

 s = strarr(ndim)
 for i=0, ndim-1 do $
  begin
   s[i] = strtrim(s0[i],2) + ':' + strtrim(s1[i],2)
   if(keyword_set(step)) then $
     if(step[i] GT 1) then s[i] = s[i] + ':' + strtrim(step[i],2)
  end

 return, '[' + str_comma_list(s) + ']'
end
;==============================================================================
