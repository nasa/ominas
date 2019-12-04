;==============================================================================
; spice_time
;
;
;==============================================================================
function spice_time, dd, prefix=prefix, inst=inst, string=string, status=status

 inst_prefix = prefix
 if(keyword_set(inst)) then inst_prefix = inst_prefix + '_' + inst

 ndd = n_elements(dd)

 fn_spice_time = inst_prefix + '_spice_time'

 for i=0, ndd-1 do $
    time = append_array(time, $
         call_function(fn_spice_time, dd[i], string=string, status=status))

 return, time
end
;=============================================================================
