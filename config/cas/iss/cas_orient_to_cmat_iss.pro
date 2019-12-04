;=============================================================================
;++
; NAME:
;	cas_orient_to_cmat_iss
;
;
; PURPOSE:
;	Converts an OMINAS camera orientation matrix to a Cassini ISS C matrix.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = cas_orient_to_cmat(cmat)
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
;	Cassini C matrix.
;
;
; PROCEDURE:
;	
;
;					    / Zcm
;					  /
;			     Ycm ------		C matrix
;					|
;			   /|\		|
;			    |		| Xcm
;			  lines
;			 ---------
;			|	  |
;	   		|	  |  samples --> 
;			|	  |
;			 ---------
;	    Z	|	 
;		|	   
;    OMINAS	|  / Y    
;		|/
;		 ------- X
;
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	cas_cmat_to_orient
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function cas_orient_to_cmat_iss, orient

 s = size(orient)
 if(s[0] EQ 2) then n = 1 $
 else n = s[3]

 cmat = dblarr(3,3,n, /nozero)

; ominas to cmat (according to Cassini NAC diagram):
 cmat[*,0,*] =  orient[0,*,*]
 cmat[*,1,*] =  orient[2,*,*] 
 cmat[*,2,*] =  orient[1,*,*]

 return, cmat
end
;=============================================================================
