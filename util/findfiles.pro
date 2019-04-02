;============================================================================
; findfiles
;
;
;============================================================================
function findfiles, filespec, compress=compress, uniq=uniq, tolerant=tolerant

 nf = n_elements(filespec)
 for i=0, nf-1 do $
  begin
   ff = findfile(filespec[i])
   if(keyword_set(tolerant)) then if(NOT keyword_set(ff)) then ff = filespec[i]
   if(keyword_set(uniq)) then ff = ff[0]
   files = append_array(files, [ff])
  end


 if(keyword_set(compress)) then $
  begin
   w = where(files NE '')
   if(w[0] EQ -1) then return, ''
   files = files[w]
  end

 return, files
end
;============================================================================
