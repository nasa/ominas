;=============================================================================
;++
; NAME:
;	vgr_cmat_to_orient_iss
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
;	result = vgr_cmat_to_orient(cmat)
;
;
; ARGUMENTS:
;  INPUT:
;	cmat:	Voyager C matrix
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
;	vgr_orient_to_cmat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
function vgr_cmat_to_orient_iss, cmat

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
