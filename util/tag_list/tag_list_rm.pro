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
pro tag_list_rm, tlp, name, nofree=nofree

 if(NOT ptr_valid(tlp)) then return
 if(NOT keyword_set(*tlp)) then return

 if(NOT keyword_set(name)) then $
  begin
   *tlp = {tag_list_struct}
   return
  end

 i = (where(name EQ (*tlp).name))[0]
 if(i EQ -1) then return

 nv_ptr_free, (*tlp)[i].data_p
 *tlp = rm_list_item(*tlp, i)

 if(NOT keyword_set((*tlp)[0])) then $
                    if(NOT keyword_set(nofree)) then nv_ptr_free, tlp

end
;=============================================================================
