;=============================================================================
;+
; NAME:
;	cor_query
;
;
; PURPOSE:
;	Returns fields associated with a CORE object.  This is a 
;	fast way of retrieving multiple fields in one call, and only a 
;	single event is generated.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_query, xd, <keywords>=<values>
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	CORE object.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<keywords>:	POINT object fields to retrieve.
;
;	noevent:	If set, no event is generated.
;
;  OUTPUT: NONE
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2017
;	
;-
;=============================================================================
pro cor_query, xd, noevent=noevent, $
@cor__keywords.include
end_keywords

 nv_notify, xd, type = 1, noevent=noevent
 _xd = cor_dereference(xd)


@cor_query.include

end
;===========================================================================



