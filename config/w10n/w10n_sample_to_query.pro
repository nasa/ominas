;==============================================================================
; w10n_sample_to_query
;
;  Assumes samples are sorted
;
;==============================================================================
function w10n_sample_to_query, dim, w
 
 stat = grid_detect(dim, w, s0=s0, s1=s1, d=d)
return, ''

 if(NOT keyword_set(stat)) then return, w10n_query_string(s0, s1)
 return, w10n_query_string(start, stop, step)

end
;==============================================================================
