FUNCTION http_get,host,path,todisk=todisk
; Gets a file(s) on the web and returns it as a string array
; path can be an array of paths (with filename at the end)
; filename in path is case sensitive
; Optionally will write it to disk
  oUrl=OBJ_NEW('IDLnetUrl')
  oUrl->SetProperty,url_scheme='http'
  oUrl->SetProperty,url_host=host
  foreach path0, path DO BEGIN
        oUrl->SetProperty,url_path=path0
        st=oUrl->Get(/String_array)               
	IF KEYWORD_SET(todisk) THEN  BEGIN
	       outfile = strsplit(path0,/extract,'/')
	       outfile = outfile[-1]
  	       result=oUrl->Get(Filename=outfile) 
	ENDIF
  	PRINT, 'file returned = ', result
  endforeach
  OBJ_DESTROY, oUrl
  RETURN,st
END
