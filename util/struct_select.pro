;===========================================================================
; struct_select
;
;===========================================================================
function struct_select, struct, w, rm=rm

 if(NOT keyword_set(struct)) then return, !null
 if(w[0] EQ -1) then return, !null

 tags = tag_names(struct)
 if(keyword_set(rm)) then w = complement(tags, w)

 for i=0, n_elements(w)-1 do $
                 new_struct = append_struct(new_struct, $
                                  create_struct(tags[w[i]], struct.(w[i])))

 return, new_struct
end
;===========================================================================
