;=============================================================================
;++
; NAME:
;	gll_cmat_to_orient_ssi
;
;
; PURPOSE:
;	Converts Galileo C matrix to a OMINAS camera orientation matrix.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = gll_cmat_to_orient(cmat)
;
;
; ARGUMENTS:
;  INPUT:
;	cmat:	Galileo C matrix
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	NONE
;
;  OUTPUT:
;	NONE
;
;
; RETURN:
;	OMINAS camera orientation matrix.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	gll_orient_to_cmat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function gll_cmat_to_orient_ssi, cmat

 s = size(cmat)
 if(s[0] EQ 2) then n = 1 $
 else n = s[3]


 orient = dblarr(3,3,n, /nozero)
 orient[0,*,*] =  cmat[*,0,*]
 orient[1,*,*] =  cmat[*,2,*]
 orient[2,*,*] =  cmat[*,1,*]


 return, orient
end
;=============================================================================
