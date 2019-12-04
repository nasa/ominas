;=============================================================================
;+
; NAME:
;	idgen
;
;
; PURPOSE:
;	Constructs an n x n identity matrix.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	id = idgen(n)
;
;
; ARGUMENTS:
;  INPUT:
;	n:	 Degree of matrix, i.e., number of rows / columns.
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
;	Array (n x n) with all diagonal elements set to 1.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function idgen, n

 id = dblarr(n,n)
 id[diaggen(n,1)] = 1

 return, id
end
;==================================================================================
