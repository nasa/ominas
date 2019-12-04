;=============================================================================
;++
; NAME:
;	gll_orient_to_cmat_ssi
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
;	result = gll_orient_to_cmat(cmat)
;
;
; ARGUMENTS:
;  INPUT:
;	orient:		OMINAS camera orientation matrix.
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
;	Galileo C matrix.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	gll_cmat_to_orient
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function gll_orient_to_cmat_ssi, orient

 s = size(orient)
 if(s[0] EQ 2) then n = 1 $
 else n = s[3]


 cmat = dblarr(3,3,n, /nozero)
 cmat[*,0,*] = -orient[1,*,*] 
 cmat[*,1,*] = -orient[0,*,*] 
 cmat[*,2,*] =  orient[2,*,*]


 return, cmat
end
;=============================================================================
