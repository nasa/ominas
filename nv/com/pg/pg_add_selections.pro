;===========================================================================
; pg_filter_selections
;
;===========================================================================
function pg_filter_selections, select, prefix

 cor_class_info, abbrev=abbrev
 keys = tag_names(select)

 pre = strmid(keys, 0, 3)
 w = nwhere(pre+'_', abbrev+'_')		; object prefixed
 _w = complement(keys, w)			; not prefixed

 if(w[0] EQ -1) then return, select

 raw = struct_select(select, _w)
 prefixed = struct_select(select, w)

 return, append_struct(raw, struct_extract(prefixed, prefix+'_')) 
end
;===========================================================================



;===========================================================================
; pg_add_selections
;
;===========================================================================
pro pg_add_selections, trs, select, prefix

 if(NOT keyword_set(select)) then return
 select = pg_filter_selections(select, prefix)
 if(NOT keyword_set(select)) then return

 keys = tag_names(select)
 n = n_elements(keys)

 vals = strarr(n)
 
 for i=0, n-1 do $
  begin
   val = select.(i)
   if(NOT str_convertible(val)) then $
                 nv_message, 'Invalid keyword type: ' + keys[i] + '.'
   vals[i] = str_comma_list(strtrim(val,2), delim=';')
  end
 sel = str_comma_list(keys+'='+vals)

 if(NOT keyword_set(trs)) then trs = sel $
 else trs = trs + ',' + sel
end
;===========================================================================
