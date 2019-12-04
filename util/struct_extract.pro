;===========================================================================
; struct_extract
;
;===========================================================================
function struct_extract, struct, prefix, rem=rem_struct, retain=retain

 if(NOT keyword_set(struct)) then return, !null

 len = strlen(prefix)
 tags = tag_names(struct)

 w = where(strmid(tags, 0, len) EQ prefix, complement=ww)
 if(w[0] EQ -1) then return, !null

 if(keyword_set(retain)) then len = 0
 for i=0, n_elements(w)-1 do $
     new_struct = append_struct(new_struct, $
                       create_struct(strmid(tags[w[i]], len, 256), struct.(w[i])))

 if(arg_present(rem_struct)) then $
  begin
   if(ww[0] NE -1) then $
     for i=0, n_elements(ww)-1 do $
         _rem_struct = append_struct(_rem_struct, $
                            create_struct(tags[ww[i]], struct.(ww[i])))

   rem_struct = _rem_struct
  end

 return, new_struct
end
;===========================================================================
