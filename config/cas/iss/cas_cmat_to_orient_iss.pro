;=============================================================================
;++
; NAME:
;	cas_cmat_to_orient_iss
;
;
; PURPOSE:
;	Converts a Cassini ISS C matrix to an OMINAS camera orientation matrix.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = cas_cmat_to_orient(cmat)
;
;
; ARGUMENTS:
;  INPUT:
;	cmat:	Cassini C matrix
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
;	cas_orient_to_cmat
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function cas_cmat_to_orient_iss, cmat

 s = size(cmat)
 if(s[0] EQ 2) then n = 1 $
 else n = s[3]

 orient = dblarr(3,3,n, /nozero)

; cmat to ominas (according to Cassini NAC diagram):
 orient[0,*,*] =  cmat[*,0,*]
 orient[1,*,*] =  cmat[*,2,*]
 orient[2,*,*] =  cmat[*,1,*]




 return, orient
end
;=============================================================================
