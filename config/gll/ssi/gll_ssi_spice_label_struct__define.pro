;===========================================================================
; gll_ssi_spice_label_struct__define
;
;===========================================================================
pro gll_ssi_spice_label_struct__define

 struct = {gll_ssi_spice_label_struct, $
		dt: 0d, $
		time: 0d, $
		stime: '', $
		exposure: 0d, $
		size: [1024,1024], $
		filters: ['',''], $
		scale: [0d,0d], $
		target: '', $
		oaxis: [0d,0d] $
           }
end
;===========================================================================



