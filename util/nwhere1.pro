;=============================================================================
;+
; NAME:
;       nwhere1
;
;
; PURPOSE:
;       Another attempt at nwhere.  This one should return the correct reverse
;       indices
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = nwhere(ref, list)
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
;       reverse_indices:
;		Subscripts wrt the second input array.
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
function nwhere1, ref, list, reverse_indices=reverse_indices

 for i=0l, n_elements(list)-1 do $
  begin
   ww = where(ref EQ list[i])
   if(ww[0] NE -1) then $
    begin
     w = append_array(w, ww)
     if(arg_present(reverse_indices)) then $
                   ii = append_array(ii, make_array(n_elements(ww), val=i))
    end
  end

 if(NOT defined(w)) then w = (ii = -1)

 if(defined(ii)) then reverse_indices = ii

; w = unique(w, sub=jj)
; reverse_indices = reverse_indices[jj]
 return, w

 return, decrapify(w)
end
;=============================================================================
