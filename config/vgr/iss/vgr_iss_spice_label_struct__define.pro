;===========================================================================
; vgr_iss_spice_label_struct__define
;
;===========================================================================
pro vgr_iss_spice_label_struct__define

 struct = {vgr_iss_spice_label_struct, $
		lab02: '', $
		lab03: '', $
		lab05: '', $
		lab07: '', $
		dt: 0d, $
		time: 0d, $
		stime: '', $
		exposure: 0d, $
		size: [0,0], $
		filters: ['',''], $
		scale: [0d,0d], $
		target: '', $
		oaxis: [0d,0d] $
           }
end
;===========================================================================



