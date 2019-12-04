;=============================================================================
;+
; NAME:
;	pnt_nt
;
;
; PURPOSE:
;	Returns the nt dimension of a POINT object.
;
;
; CATEGORY:
;	nt/SYS/PS
;
;
; CALLING SEQUENCE:
;	nt = pnt_nt(ptd)
;
;
; ARGUMENTS:
;  INPUT:
;	ptd:	POINT object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	The nt dimensions of the POINT object.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2015
;	
;-
;=============================================================================
function pnt_nt, ptd, condition=condition, noevent=noevent, $
@pnt_condition_keywords.include
end_keywords

 condition = pnt_condition(condition=condition, $
@pnt_condition_keywords.include 
end_keywords)

 nv_notify, ptd, type = 1, noevent=noevent
 _ptd = cor_dereference(ptd)

 if(NOT keyword_set(condition)) then return, _ptd.nt
 if(NOT ptr_valid(_ptd.flags_p)) then return, _ptd.nt

 n_ptd = n_elements(_ptd)
 nt = lonarr(n_ptd)

 for i=0, n_ptd-1 do $
  begin
   ii = pnt_apply_condition(_ptd[i], condition)
   if(ii[0] NE -1) then nt[i] = (size(ii, /dim))[0]
  end

 if(n_ptd EQ 1) then nt = nt[0]
 return, nt
end
;===========================================================================



