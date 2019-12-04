;=============================================================================
;++
; NAME:
;	vgr_orient_to_cmat_iss
;
;
; PURPOSE:
;	Converts Voyager C matrix to a OMINAS camera orientation matrix.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = vgr_orient_to_cmat(cmat)
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
;	Voyager C matrix.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	vgr_cmat_to_orient
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
function vgr_orient_to_cmat_iss, orient

 s = size(orient)
 if(s[0] EQ 2) then n = 1 $
 else n = s[3]


 cmat = dblarr(3,3,n, /nozero)
 cmat[*,0,*] =  orient[0,*,*] 
 cmat[*,1,*] =  orient[2,*,*] 
 cmat[*,2,*] =  orient[1,*,*]

 return, cmat
end
;=============================================================================
