;=============================================================================
;+
; NAME:
;       nnwhere
;
;
; PURPOSE:
;       Finds subscripts where an element in the first array matches
;       elements in the second input array.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = nnwhere(ref, list)
;
;
; ARGUMENTS:
;  INPUT:
;        ref:  Reference array
;
;       list:  Comparison array.
;
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;       NONE
;
;
; RETURN:
;       An array of subscripts in list that match something in ref.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function nnwhere, ref, list

 n = n_elements(list)

 i=0l
 while(i LT n) do $
  begin
   w = append_array(w, where(ref EQ list[i]))
   i = i + 1
  end

 ww = where(w NE -1)

 if(ww[0] EQ -1) then return, -1
 return, w[ww]

end
;===========================================================================
