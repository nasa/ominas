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
pro tag_list_set, tlp, name, data, index=index, new=new

 if(NOT ptr_valid(tlp)) then tlp = nv_ptr_new({tag_list_struct})
 if(NOT keyword_set(*tlp)) then *tlp = {tag_list_struct}

 if(n_elements(index) EQ 0) then index = (where(name EQ (*tlp).name))[0]
 new = 0

 if(index EQ -1) then $
  begin
   new = 1
   if(keyword__set((*tlp)[0].name)) then *tlp = [*tlp, {tag_list_struct}]
   index = n_elements(*tlp)-1
  end

 if(NOT ptr_valid((*tlp)[index].data_p)) then (*tlp)[index].data_p = nv_ptr_new(0)
 *((*tlp)[index].data_p) = data
 (*tlp)[index].name = name

end
;=============================================================================
