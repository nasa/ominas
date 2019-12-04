;===========================================================================
; cas_iss_spice_label_struct__define
;
;===========================================================================
pro cas_iss_spice_label_struct__define

 struct = {cas_iss_spice_label_struct, $
		dt: 0d, $
		time: 0d, $
		stime: '', $
		exposure: 0d, $
		size: [0,0], $
		filters: ['',''], $
		target: '', $
		oaxis: [0d,0d] $
           }
end
;===========================================================================



