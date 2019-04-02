;=============================================================================
; dh_w10n_pds_par.pro
;
;=============================================================================
pro dh_w10n_pds_par, label, keyword, get=get, set=set

 if (size(label,/type) NE 7) then begin
   nv_message, verb=0.5, 'No label'
   return
 endif
 jlab = json_parse(label)

 ; Find where keyword is
 ; Find top level keys
 top_keys = jlab.keys()
 n_keys = n_elements(top_keys)

 for i = 0, n_keys-1 do begin
    n_segments = n_elements(jlab[top_keys[i]])
    for j = 0, n_segments-1 do begin
       if (jlab[top_keys[i], j].hasKey(keyword)) then begin
          n_list = n_elements(jlab[top_keys[i], j, keyword])
          nv_message, verb=0.5, $
                "Found " + keyword + " in ['" + top_keys[i] + "', " + $
                    strtrim(i,2) + '] with ' + strtrim(n_list,2) + ' elements'
          if (n_list EQ 1) then begin
             if (arg_present(get)) then get = jlab[top_keys[i], j, keyword] $
             else begin
                jlab[top_keys[i], j, keyword] = strtrim(string(set),2)
                label = json_serialize(jlab)
             endelse
          endif else begin
             if (arg_present(get)) then begin
                get = strarr(n_list)
                for k = 0, n_list-1 do get[k] = jlab[top_keys[i], j, keyword, k]
             endif else begin
                if(n_elements(set) NE n_list) then message, 'Set variable dimension mismatch'
                for k = 0, n_list-1 do jlab[top_keys[i], j, keyword, k] = strtrim(string(set[k]),2)
                label = json_serialize(jlab)
             endelse
          endelse
       endif
    endfor
 endfor


end
;=============================================================================
