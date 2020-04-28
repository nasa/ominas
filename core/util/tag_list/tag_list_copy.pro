;===========================================================================
; tag_list_copy
;
;  NOTE both tag lists are assumed to contain the same number of elements 
;  with the same field names.
;
;
;===========================================================================
pro tag_list_copy, tlp_dst, tlp_src

 if(NOT keyword_set(tlp_src)) then return

 list_src = *tlp_src
 list_dst = *tlp_dst
 list_new = *tlp_dst

 n = n_elements(list_new)
 for i=0, n-1 do *list_new[i].data_p = *list_src[i].data_p


 *tlp_dst = list_new
end
;===========================================================================
