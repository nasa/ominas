;===========================================================================
; struct_get
;
;===========================================================================
function struct_get, struct, tag, prefix=preifx

 tags = tag_names(struct)

 w = where(tags EQ strupcase(tag))
 if(w[0] EQ -1) then return, !null
 return, struct.(w)
end
;===========================================================================
