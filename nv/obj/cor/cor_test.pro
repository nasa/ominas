;=============================================================================
;+
; NAME:
;	cor_test
;
;
; PURPOSE:
;	Tests whether the input is an OMINAS object or object structure.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	data = cor_test(xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 Any subclass of CORE.  Only one descriptor may be provided.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	True if xd is an OMINAS object or object structure, false otherwise.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2017
;	
;-
;=============================================================================
function cor_test, xd, noevent=noevent
@core.include
 if(NOT keyword_set(xd)) then return, 0

 nv_notify, xd, type = 1, noevent=noevent
 _xd = cor_dereference(xd)

 if(size(_xd, /type) NE 8) then return, 0

 tags = strupcase(tag_names(_xd))
 w = where(tags EQ 'TASKS_P')
 if(w[0] NE -1) then return, 1

 return, 0
end
;=============================================================================
