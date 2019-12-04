;===========================================================================
; spice_cull
;
;===========================================================================
pro spice_cull, full=full

 kernels = spice_loaded(/verb)

 n = n_elements(kernels)
 if(n EQ 1) then return


 ss = sort(kernels)
 uu = uniq(kernels[ss])

 ii = lonarr(n)
 ii[uu] = 1
 
 w = where(ii EQ 0)
 if(w[0] EQ -1) then return

 uk = kernels[ss[w]]
 
 ss = sort(uk)
 uk = uk[ss]
 uu = uniq(uk)
 uk = uk[uu]

 spice_load, uk_in=uk
end
;===========================================================================
