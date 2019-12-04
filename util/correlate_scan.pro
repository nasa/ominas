;==============================================================================
; correlate_scan
;
;==============================================================================
function correlate_scan, scan1, scan2, sample

 n0 = double(n_elements(scan1))
 n = n0/sample

 scan1_sample = interpol(scan1, n)
 scan2_sample = interpol(scan2, n)

 result = dblarr(n)

 for i=0, n-1 do $
   result[i] = cr_correlation(scan1_sample, scan2_sample, i)

 return, result
end
;==============================================================================
