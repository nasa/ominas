;=============================================================================
;+
; NAME:
;	cor_match_gd
;
;
; PURPOSE:
;	Compares generic descriptors.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	status = cor_match_gd(gd1, gd2)
;
;
; ARGUMENTS:
;  INPUT: 
;	gd1, gd2:	Generic descriptors to compare, or object descriptors
;			containing generic descriptors to compare.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;	True if the generic descriptors match, false otherwise.  The
;	fields in each structure do not have to be in the same order.
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================



;=============================================================================
; cmgd_compare
;
;=============================================================================
function cmgd_compare, gd1, gd2

 if(cor_test(gd1)) then gd1 = cor_gd(gd1)
 if(cor_test(gd2)) then gd2 = cor_gd(gd2)

 tags1 = tag_names(gd1)
 tags2 = tag_names(gd2)
 ntags1 = n_elements(tags1)
 ntags2 = n_elements(tags2)

 if(ntags1 NE ntags2) then return, 0
 ntags = ntags1

 tags1 = ssort(tags1)
 tags2 = ssort(tags2)

 w = nwhere(tags1, tags2)
 if(n_elements(w) NE ntags) then return, 0
 if(w[0] EQ -1) then return, 0

 for i=0, ntags-1 do $
  begin
   w = (where(tags1[i] EQ tags2))[0]
   if(n_elements(gd1.(i)) NE n_elements(gd2.(w))) then return, 0
   if(total(gd1.(i) EQ gd2.(w)) LT n_elements(gd1.(i))) then return, 0
  end

 return, 1
end
;=============================================================================



;=============================================================================
; cor_match_gd
;
;=============================================================================
function cor_match_gd, _gd1, _gd2

 gd1 = _gd1
 gd2 = _gd2

 ndim1 = (size(_gd1))[0]
 ndim2 = (size(_gd2))[0]
 ngd1 = n_elements(gd1)
 ngd2 = n_elements(gd2)

 if(ndim1 EQ 0) then gd1 = make_array(ngd2, val=gd1)
 if(ndim2 EQ 0) then gd2 = make_array(ngd1, val=gd2)
 if((ndim1 GT 0) AND (ndim2 GT 0)) then if(ngd2 LT ngd1) then swap, gd1, gd2
 ngd = n_elements(gd1)

 result = bytarr(ngd)
 for i=0, ngd-1 do result[i] = cmgd_compare(gd1[i], gd2[i])

 return, result
end
;==================================================================================
