;====================================================================================
; get_pro_by_prefix
;
;====================================================================================
function get_pro_by_prefix, prefix, dir=dir

 if(keyword_set(dir)) then $
  begin
   ff = file_search(dir + '/*.pro')
   split_filename, ff, dir, names, ext
  end $
 else $
  begin
   help, /procedures, /functions, output=output
   names = str_nnsplit(output, ' ')
  end


 w = where(strmid(strupcase(names), 0, strlen(prefix)) EQ strupcase(prefix))


 if(w[0] EQ -1) then return, ''
 return, strlowcase(names[w])
end
;====================================================================================
