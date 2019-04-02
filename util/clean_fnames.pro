;==============================================================================
; clean_fnames
;
;==============================================================================
function clean_fnames, _fnames

 fnames = _fnames
 n = n_elements(fnames)

 sep = path_sep()
 sepsep = sep+sep

 for i=0, n-1 do $
  begin
   fname = fnames[i]

   p = strpos(fname, sepsep)
   while(p[0] NE -1) do $
    begin
     fname = strcompress(strep(fname, sep+' ', p[0]), /rem)
     p = strpos(fname, sepsep)
    end

   fnames[i] = fname
  end

 return, fnames
end
;==============================================================================
