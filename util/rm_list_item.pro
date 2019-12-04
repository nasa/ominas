;=============================================================================
;+
; NAME:
;	rm_list_item
;
;
; PURPOSE:
;	Removes the items with indices i from the given list and returns the
;	new list.  If an index is not in the list, then it is ignored.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	newlist = rm_list_item(list, i)
;
;
; ARGUMENTS:
;  INPUT:
;	list:	The list from which to remove item with index i.
;
;	i:	Index of items in list to be removed.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	only:	If set, then return is [only] if removing the only element of
;		the list. Otherwise return [0] on this condition.
;
;	scalar:	If set, the output will be a scalar if there is only one
;		element.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	New list with item i removed.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/1994
;	
;-
;=============================================================================
function rm_list_item, list, i, only=only, scalar=scalar

 n = n_elements(list)
 bl = bytarr(n)
 bl[i] = 1
 sub = where(bl EQ 0)
 result = list[sub]

 if(sub[0] EQ -1) then $
  begin
   if(n_elements(only) NE 0) then result = [only] $
   else result = [0]
  end

 if(keyword_set(scalar)) then if(n_elements(result) EQ 1) then result = result[0]

 return, result
end
;=================================================================

