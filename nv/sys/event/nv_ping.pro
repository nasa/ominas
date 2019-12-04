;=============================================================================
;+
; NAME:
;	nv_ping
;
;
; PURPOSE:
;	Generates a write event on a set of descriptors.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_ping, xd
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	Array of descriptors.
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
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2014
;	
;-
;=============================================================================
pro nv_ping, xdp, noevent=noevent
@core.include

 for i=0, n_elements(xdp)-1 do nv_notify, xdp[i], type=0, desc='PING', noevent=noevent
 nv_notify, /flush

 
end
;===========================================================================



