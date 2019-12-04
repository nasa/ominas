; docformat = 'rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`),
;-

;+
; :Description:
;    Simple function to retrieve a URL as a string array, similar to
;    IDLNetURL::get(). The purpose of this function is simply to avoid the segfault
;    that IDLNetURL::getftpdirlist() throws on some very specific URLs before
;    IDL 8.4.
;
; :Params:
;    url: in, required, type=string
;      URL to download.
;
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`),
;-
function pp_jget,url,verbose=verbose
compile_opt idl2,logical_predicate
if keyword_set(verbose) then print,'Using Java get (pp_jget) for ',url
jbridge=obj_new('IDLjavaObject$JAVA_NET_URL','java.net.URL',url)
c=jbridge.openConnection()
i=c.getInputStream()
jin=obj_new('IDLjavaObject$JAVA_IO_INPUTSTREAMREADER','java.io.InputStreamReader',i)
bjin=obj_new('IDLjavaObject$JAVA_IO_BUFFEREDREADER','java.io.BufferedReader',jin)
ret=list()
repeat begin
  l=bjin.readLine()
  ret.add,l
endrep until l eq ''
return,n_elements(ret) gt 1 ? (ret[0:-2]).toarray() : ret.toarray()
end
