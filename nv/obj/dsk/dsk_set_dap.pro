;=============================================================================
;+
; NAME:
;	dsk_set_dap
;
;
; PURPOSE:
;	Replaces the apsidal shift in each given disk descriptor.  Half of the
;	shift is applied to each edge, so as to not affect the mean periapse
;	direction.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dsk_set_dap, bx, dap
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	 Array (nt) of any subclass of DISK.
;
;	dap:	 New dap value.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2016
;	
;-
;=============================================================================
pro dsk_set_dap, dkd, dap, noevent=noevent
@core.include
 
 _dkd = cor_dereference(dkd)

 _dkd.dap[*,0,*] = 0.5*dap
 _dkd.dap[*,1,*] = -0.5*dap

 cor_rereference, dkd, _dkd
 nv_notify, dkd, type = 0, noevent=noevent
end
;===========================================================================



