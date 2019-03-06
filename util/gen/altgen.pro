;=============================================================================
;+
; NAME:
;	altgen
;
;
; PURPOSE:
;	Constructs 1d subscripts of alternating elements of an nxn array.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = altgen(n)
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
;	Array of subscripts.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		6/2018
;	
;-
;=============================================================================
function altgen, n

 nn = n*n

 sub = 2*lindgen((nn+1)/2)
 if(n mod 2 EQ 0) then $
  begin
   row = sub/n
   ii = where(row mod 2 EQ 1)
   sub[ii] = sub[ii] + 1
  end

 return, sub
end
;===========================================================================
