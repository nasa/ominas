;=============================================================================
; NOTE: Remove the second '+' on the following line for this file to be
;       included in the reference guide.
;++
; NAME:
;	xx
;
;
; PURPOSE:
;	xx
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = xx(xx, xx)
;	xx, xx, xx
;
;
; ARGUMENTS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; KEYWORDS:
;  INPUT:
;	xx:	xx
;
;	xx:	xx
;
;  OUTPUT:
;	xx:	xx
;
;	xx:	xx
;
;
; ENVIRONMENT VARIABLES:
;	xx:	xx
;
;	xx:	xx
;
;
; RETURN:
;	xx
;
;
; COMMON BLOCKS:
;	xx:	xx
;
;	xx:	xx
;
;
; SIDE EFFECTS:
;	xx
;
;
; RESTRICTIONS:
;	xx
;
;
; PROCEDURE:
;	xx
;
;
; EXAMPLE:
;	xx
;
;
; STATUS:
;	xx
;
;
; SEE ALSO:
;	xx, xx, xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	xx, xx/xx/xxxx
;	
;-
;=============================================================================


;=============================================================================
; tag_list_get
;
;=============================================================================
function tag_list_get, tlp, name, $
                    index=index, reference=reference, prefix=prefix

 if(NOT ptr_valid(tlp)) then return, 0
 if(NOT keyword_set(*tlp)) then return, 0
 if(NOT ptr_valid((*tlp)[0].data_p)) then return, 0
 ntlp = n_elements(*tlp)

; if((NOT keyword__set(name)) AND (n_elements(index) EQ 0)) then return, 0
 if((NOT keyword__set(name)) $ 
                     AND (n_elements(index) EQ 0)) then index = indgen(ntlp)

 if(n_elements(index) EQ 0) then $
                         index = tag_list_match(tlp, name, prefix=prefix)
 if(index[0] EQ -1) then return, 0

 if(keyword__set(reference)) then return, (*tlp)[index].data_p

 if(index[0] GE ntlp) then return, 0

 n = n_elements(index)
 if(n EQ 1) then return, *((*tlp)[index].data_p)

 result = make_array(n, val=*((*tlp)[index[0]].data_p))
 for i=0, n-1 do result[i] = *((*tlp)[index[i]].data_p)

 return, result
end
;=============================================================================
