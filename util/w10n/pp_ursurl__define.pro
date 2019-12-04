;docformat = 'rst rst'
;+
;
;    Class inheriting from IDLNetURL, to handle request to a server that
;    authenticates on a URS server (`https://urs.earthdata.nasa.gov/ <https://urs.earthdata.nasa.gov/>`).
;    Main difference from IDLNetURL is the method `getr`, which wraps the standard get
;    method, to intercept the redirect to the URS server, and do the authentication,
;    
;    Authentication can be by user/password (provided as keywords, or requested
;    interactively if they are needed), or through cookies, or throgh a `.netrc`
;    hash obtained from `pp_parsenetrc`.
;    
; :Requires: mg_getpassword
;
; :Author: Paulo Penteado (`http://www.ppenteado.net`), Aug/2016
;-


function pp_ursurl_callback,statusinfo,progressinfo,callbackdata
compile_opt idl2,logical_predicate

callbackdata.getproperty,response_header=h,debug=debug
if debug gt 1 then begin
  print,'pp_ursusl_callback: statusinfo:'
  print,statusinfo
endif
if debug gt 2 then begin
  print,'pp_ursusl_callback: response_header:'
  print,h
endif

ret=1
if stregex(statusinfo+string(10B)+h,'Set-Cookie:',/fold,/bool) then begin
  tmp=stregex(statusinfo+string(10B)+h,'Set-Cookie:[[:space:]]*([^;]+)',/fold,/extract,/subexpr)
  cookie=strtrim(tmp[-1],2);strtrim((strsplit(tmp[-1],'=',/extract))[-1],2)
  tmp=strsplit(cookie,'=',/extract)
  cookie=strtrim(cookie,2)
  if strlen(cookie) && strlowcase(strtrim(tmp[-1],2)) ne 'yes' then begin
    callbackdata.getproperty,url_host=uh
    (callbackdata.cookies)[uh]=cookie
  endif
endif
if stregex(h,'Location: (https?://[[:cntrl:]]*)',/bool) then begin
  url=(stregex(h,'Location: (https?://[^[:cntrl:]]*)',/subexpr,/extract))[-1]
  oldurl=callbackdata.fullurl
  if oldurl ne url then begin
    (callbackdata.authdata)['authurl']=url
    ret=0
  endif
endif

return,ret
end

function pp_ursurl::getr,_ref_extra=ex
compile_opt idl2,logical_predicate

self.getproperty,url_host=uh
if self.cookies.haskey(uh) then begin
  self.getproperty,header=header
  header+='Cookie: '+(self.cookies)[uh]
  self.setproperty,header=header
endif
self.getproperty,fullurl=fullurl
catch,err
if err ne 0 then begin
  catch,/cancel
  if ~((self.authdata)['authurl']) then begin
    self.getproperty,response_code=response_code
    message,'Get failed ('+strtrim(response_code,2)+')'
  endif else begin
    url=(self.authdata)['authurl']
    tmp=stregex(url,'([[:alpha:]]+)://([^/]+)/([^?]+)(.+)',/subexpr,/extract)
    uscheme=tmp[1]
    uhost=tmp[2]
    upath=tmp[3]
    uquery=tmp[4]
    noauth=self.cookies.haskey(uhost) ? self.cookies[uhost] : (strmatch(uquery,'*code=*') ? '1' : '')
    if self.debug then print,'pp_ursurl: got redirected to ',uhost
    if (strlen(uquery) gt 1) then uquery=strmid(uquery,1) else uquery=''
    if noauth then begin
      if self.debug then print,'pp_ursurl: using cookie for authentication'
      inu=pp_ursurl(url_host=uhost,url_scheme=uscheme,url_path=upath,url_query=uquery,$
        debug=self.debug,cookies=self.cookies,maxrec=self.maxrec-1,netrc=self.netrc)    
    endif else begin
      if self.debug then print,'pp_ursurl: need to authenticate with user/password'
      if (~self.user) && (~self.pw) && (n_elements(self.netrc)) then begin
        print,'pp_ursurl: trying authentication with netrc credentials provided'
        if self.netrc.haskey(uhost) then begin
          self.user=((self.netrc)[uhost]).user
          self.pw=((self.netrc)[uhost]).pw
        endif else if self.netrc.haskey('default') then begin
          self.user=((self.netrc)['default']).user
          self.pw=((self.netrc)['default']).pw          
        endif
      endif else begin
        if ~self.user then begin
          user=''
          if self.widget then user=password(prompt='Enter username for '+uhost) else $
            read,prompt='Enter username for '+uhost+' ',user
          self.user=temporary(user)
        endif
        if ~self.pw then begin
          ;pw=''
          ;read,prompt='Enter password for '+uhost+' (it will show in the terminal, and possibly, in the IDL command history) ',pw
          if self.widget then pw=password(prompt='Enter password for '+uhost) else $
            pw=mg_getpassword(prompt='Enter password for '+uhost+' ')
          self.pw=temporary(pw)
        endif
      endelse
      inu=pp_ursurl(url_host=uhost,url_scheme='https',url_path=upath,url_query=uquery,$
        user=self.user,pass=self.pw,auth=3,debug=self.debug,cookies=self.cookies,maxrec=self.maxrec-1)
    endelse
    if self.user then inu.setproperty,url_username=self.user
    if self.pw then inu.setproperty,url_password=self.pw
    inu.setproperty,verbose=1
    ret=inu
  endelse
endif else begin
  if self.debug then print,'pp_ursurl: trying to get ',fullurl
  ret=self.idlneturl::get(_strict_extra=ex)
endelse
catch,/cancel

if isa(ret,'pp_ursurl') && (ret.maxrec ge 1) then begin
  retn=ret.getr(_strict_extra=ex)
  ret=retn
endif
return,ret

end

pro pp_ursurl::setproperty,cookies=cookies,_ref_extra=ex
compile_opt idl2,logical_predicate
  if n_elements(cookies) then self.cookies=cookies
  if n_elements(ex) then self.idlneturl::setproperty,_strict_extra=ex
end

function pp_ursurl::init,_ref_extra=ex,user=user,password=pw,debug=debug,$
  cookies=cookies,maxrec=maxrec,netrc=netrc,widget=widget
compile_opt idl2,logical_predicate
if n_elements(widget) then self.widget=widget
ret=self.idlneturl::init(_strict_extra=ex)
self.setproperty,callback_function='pp_ursurl_callback'
self.cookies=isa(cookies,'hash') ? cookies : hash()
h=hash()
h['authurl']=''
self.authdata=h
self.user=n_elements(user) ? user : ''
self.pw=n_elements(pw) ? pw : ''
self.setproperty,callback_data=self
self.getproperty,url_scheme=usch,url_host=uh,url_path=up,url_query=uq
self.url=usch+'://'+uh+'/'+up+(strlen(uq) ? '?'+uq : '')
self.debug=n_elements(debug) ? debug : 0
self.maxrec=n_elements(maxrec) ? maxrec : 5
self.netrc=isa(netrc,'hash') ? netrc : hash()
return,ret
end

pro pp_ursurl::getproperty,_ref_extra=ex,authdata=authdata,response_code=response_code,$
  fullurl=fullurl,cookies=cookies,maxrec=maxrec,debug=debug
compile_opt idl2,logical_predicate
if arg_present(authdata) then authdata=self.authdata
if arg_present(response_code) then self.idlneturl::getproperty,response_code=response_code
if arg_present(fullurl) then fullurl=self.url
if arg_present(cookies) then cookies=self.cookies
if arg_present(maxrec) then maxrec=self.maxrec
if arg_present(debug) then debug=self.debug
if n_elements(ex) then self.idlneturl::getproperty,_strict_extra=ex
end

pro pp_ursurl__define
compile_opt idl2,logical_predicate
!null={pp_ursurl,inherits IDLNetURL,authdata:obj_new(),inherits IDL_Object,$
  user:'',pw:'',url:'',cookies:obj_new(),debug:0B,maxrec:0,netrc:obj_new(),widget:0L}
end
