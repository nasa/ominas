;=======================================================================================
; spice_load
;
;=======================================================================================
pro spice_load, k_in, uk_in=uk_in, pool=pool

 ;----------------------------------------------------------
 ; if /pool, set the kernel pool to this list
 ;----------------------------------------------------------
 if(keyword_set(pool)) then $
  begin
   loaded_kernels = spice_loaded()
  
   _w = nwhere(k_in, loaded_kernels, rev=_ii)
   w = complement(k_in, _w)
   ii = complement(loaded_kernels, _ii)

   if(w[0] EQ -1) then k_in = !null $
   else k_in = k_in[w]

   if(ii[0] NE -1) then uk_in = loaded_kernels[ii]
  end

 if(keyword_set(k_in)) then k_in = file_search(k_in)

 n_k_in = 0l
 if(NOT keyword_set(k_in)) then k_in = '' $
 else n_k_in = n_elements(k_in)

 n_uk_in = 0l
 if(NOT keyword_set(uk_in)) then uk_in = '' $
 else n_uk_in = n_elements(uk_in)


 ;-------------------
 ; unload kernels
 ;-------------------
 if(keyword_set(uk_in)) then $
       nv_message, verb=0.9, 'Unloading the following kernels:', exp=transpose([uk_in])
 if(keyword_set(uk_in)) then for i=0, n_uk_in-1 do cspice_unload, uk_in[i]


 ;-------------------
 ; load kernels
 ;-------------------
 if(keyword_set(k_in)) then $
       nv_message, verb=0.9, 'Loading the following kernels:', exp=transpose([k_in])
 if(keyword_set(k_in)) then for i=0, n_k_in-1 do cspice_furnsh, k_in[i]


end
;=======================================================================================
