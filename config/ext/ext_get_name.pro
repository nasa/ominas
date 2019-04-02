;=============================================================================
; ext_get_name
;
;=============================================================================
function ext_get_name, filename, write=write
 split_filename, filename, dir, name, ext

 ff = 'ext_read_'
 if(keyword_set(write)) then ff = 'ext_write_'
 return, ff + strlowcase(ext)
end
;=============================================================================
