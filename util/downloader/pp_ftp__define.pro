function pp_ftp::init,user=user,pw=pw,url=url,verbose=verbose,timeout=timeout,$
debug=debug,blocksize=blocksize,clobber=clobber,callback_data=cbd,callback_function=cbf
compile_opt idl2,logical_predicate

if ~keyword_set(url) then message,'URL not provided'

pu=parse_url(url)

self.callback_data=ptr_new(cbd)
self.callback_function=n_elements(cbf) ? cbf : ''
self.debug=n_elements(debug) ? debug : 0
self.host=pu.host
self.path=pu.path
if ~stregex(url,'((ht)|f)tps?://[^/]+:'+pu.port+'/',/bool) then pu.port=21
self.port=pu.port ? fix(pu.port) : 21
self.pu=ptr_new(pu)
self.user=n_elements(user) ? user : (pu.username ? pu.username : 'anonymous') 
self.pw=n_elements(pw) ? pw : (pu.password ? pu.password : '-wget@')
self.url=url
self.verbose=n_elements(verbose) ? verbose : 0B
self.timeout=n_elements(timeout) ? timeout : 5
self.blocksize=n_elements(blocksize) ? blocksize : 2L^20
socket,lun,self.host,self.port,/get_lun
self.lun=lun
s=self.socket_read(lines=2,bstr='^220 ',/fold_case)
self.send,'USER '+self.user
s=self.socket_read(lines=2,bstr='^331 ',/fold_case)
self.send,'PASS '+self.pw
s=self.socket_read(lines=2,bstr='^230 ',/fold_case)
self.send,'PWD'
s=self.socket_read(lines=2,bstr='^257 ',/fold_case)
self.pwd=self.getpwd()
self.clobber=n_elements(clobber) ? clobber : 0
return,1

end

pro pp_ftp::send,stri
compile_opt idl2,logical_predicate
if self.debug then print,stri
printf,self.lun,stri
end

function pp_ftp::socket_read,verb=verb,lines=lines,bstr=bstr,_ref_extra=ex
compile_opt idl2,logical_predicate


tim=self.timeout
lun=self.lun
verb=self.debug

lines=n_elements(lines) ? lines : 1
s=''
ret=list()
r=file_poll_input(lun,timeout=tim,count=c)
readf,lun,s
if keyword_set(verb) then print,s
if keyword_set(bstr) && stregex(s,bstr,/bool,_strict_extra=ex) then return,s
if lines lt 2 then return,s
r=file_poll_input(lun,timeout=tim,count=c)
ict=0
while r do begin
  readf,lun,s
  if keyword_set(verb) then print,s
  ret.add,s
  ict++
  if keyword_set(bstr) && stregex(s,bstr,/bool,_strict_extra=ex) then break
  r=file_poll_input(lun,timeout=tim,count=c)
endwhile
return,ret.toarray()
end

function pp_ftp::getftpdirlist
compile_opt idl2,logical_predicate
fd=self.path;file_dirname(self.path)
if ~(strmid(fd,0,1) eq '/') then fd='/'+fd
if self.pwd ne fd then self.cd,fd

self.send,'TYPE A'
s=self.socket_read(lines=2,bstr='^200 ',/fold_case)
self.send,'PASV'
s=self.socket_read(lines=2,bstr='^227 ',/fold_case)
ss=stregex(s,'[[:alnum:]]+ \((.+)\)',/extract,/subexpr)
sss=strsplit(ss[-1],',',/extract)
ip=strjoin(sss[0:3],'.')
port=fix(sss[4])*256+fix(sss[5])
print,'ip, port: ',ip,', ',strtrim(port,2)

socket,lun2,ip,port,/get_lun,connect_timeout=5,read_timeout=5
self.send,'LIST'
s=self.socket_read(lines=2,bstr='^150 ',/fold_case)
listing=list()
while ~eof(lun2) do begin
  readf,lun2,s
  listing.add,s
endwhile
s=self.socket_read(lines=2,bstr='^226 ',/fold_case)
free_lun,lun2
return,listing.toarray()

end

pro pp_ftp::cd,path,split=split
compile_opt idl2,logical_predicate
lun=self.lun
dirs=keyword_set(split) ? strsplit(path,'/',/extract) : [path]
foreach dir,dirs[0:-1] do begin
  self.send,'CWD '+dir
  s=self.socket_read(lines=2,bstr='^250 ',/fold_case)
endforeach
self.send,'PWD'
s=self.socket_read(lines=2,bstr='^257 ',/fold_case)
self.pwd=s[-1]
end

function pp_ftp::getpwd
self.send,'PWD'
s=self.socket_read(lines=2,bstr='^257 ',/fold_case)
dir=stregex(s[-1],'257[[:space:]]+"(.*)"[[:space:]]*[^"]*',/subexpr,/extract)
return,dir[-1]
end

pro pp_ftp::getproperty,path=path,$
  url_scheme=url_scheme,url_port=url_port,url_path=url_path,url_hostname=url_hostname,$
  url_user=url_user,url_password=url_password
compile_opt idl2,logical_predicate
if arg_present(path) then path=self.path
if arg_present(url_scheme) then url_scheme=(*self.pu).scheme
if arg_present(url_path) then url_path=(*self.pu).path
if arg_present(url_port) then url_port=(*self.pu).port
if arg_present(url_hostname) then url_hostname=(*self.pu).hostname
if arg_present(url_password) then url_password=(*self.pu).password
if arg_present(url_username) then url_username=(*self.pu).username
end

pro pp_ftp::setproperty,url_port=po,url_path=pa
compile_opt idl2,logical_predicate

if n_elements(po) then self.port=po
if n_elements(pa) then self.path=pa

end

function pp_ftp::get,buffer=buffer,filename=fileout,ltime=ltime,$
  string=string
compile_opt idl2,logical_predicate

ltime=n_elements(ltime) ? ltime : ''
clober=n_elements(clonner) ? clobber : 0

fd=file_dirname(self.path)
if ~(strmid(fd,0,1) eq '/') then fd='/'+fd
if self.pwd ne fd then self.cd,fd

;dirs=strsplit(self.path,'/',/extract,cdirs)
;if cdirs gt 1 then self.cd,strjoin(dirs[0:-2],'/')
;f=dirs[-1]
f=file_basename(self.path)
if keyword_set(string) then buffer=1
if (~keyword_set(fileout)) && (~keyword_set(buffer)) then fileout=f

self.send,'TYPE I'
s=self.socket_read(lines=2,bstr='^200 ',/fold_case)
self.send,'SIZE '+f
s=self.socket_read(lines=2,bstr='^213 ',/fold_case)
ss=strsplit(s,/extract)
fs=long64(ss[1])

self.send,'MDTM '+f
s=self.socket_read(lines=2,bstr='^213 ',/fold_case)
mdtm=(stregex(s,'213[[:space:]]([[:digit:]]{14})',/extract,/subexpr))[-1]

self.send,'PASV'
s=self.socket_read(lines=2,bstr='^227 ',/fold_case)
ss=stregex(s,'[[:alnum:]]+ \((.+)\)',/extract,/subexpr)
sss=strsplit(ss[-1],',',/extract)
ip=strjoin(sss[0:3],'.')
port=fix(sss[4])*256+fix(sss[5])
if self.verbose then print,'ip, port: ',ip,', ',strtrim(port,2)

socket,lun2,ip,port,/get_lun,connect_timeout=5,read_timeout=5
self.send,'RETR '+f
s=self.socket_read(lines=2,bstr='^150 ',/fold_case)

verbstr=['pp_ftp']
verbstr=[verbstr,'Verbose: Header In: Content-Length: '+strtrim(fs,2)]
verbstr=[verbstr,'Verbose: Header In: Last-Modified: '+mdtm]

ret=keyword_set(buffer) ? (keyword_set(string) ? '' : !null) : ''

if self.callback_function then r=call_function(self.callback_function,verbstr,[1LL,long64(fs),0LL,0LL,0LL],*self.callback_data)
if self.callback_function && (r eq 0) then return,ret

if keyword_set(fileout) then begin
  if self.verbose then print,'saving ',self.path,' to ',fileout
  openw,luno,fileout,/get_lun
endif

if self.verbose then print,'Downloading ',pp_readablesize(fs,/string)
if keyword_set(buffer) then begin
  b=bytarr(fs)
  readu,lun2,b
  writeu,luno,b
endif else begin
  if self.verbose then print,'Downloading in blocks of ',pp_readablesize(self.blocksize,/string)
  b=bytarr(self.blocksize)
  for i=0,floor(fs/self.blocksize)-1 do begin
    readu,lun2,b
    writeu,luno,b
  endfor
  lo=fs mod self.blocksize
  if lo then begin
    b=bytarr(lo)
    readu,lun2,b
    writeu,luno,b
  endif
endelse
s=self.socket_read(lines=2,bstr='^226 ',/fold_case)
free_lun,lun2

if keyword_set(buffer) then ret=temporary(b) else ret=file_expand_path(fileout)
if keyword_set(string) then ret=string(temporary(b))
if keyword_set(fileout) then begin
  free_lun,luno
  ;tmstr=string(yr,mon,day,h,m,s,format='(I04,I02,I02,I02,I02,".",I02)')
  tmstr=strmid(mdtm,0,12)+'.'+strmid(mdtm,12,2)
  spawn, 'test "$?BASH_VERSION" = "0" || eval '+"'"+'setenv() { export "$1=$2"; }'+"'"+'; setenv TZ UTC; touch -t "'+tmstr+'" '+fileout
endif

return,ret

end

pro pp_ftp::cleanup
compile_opt idl2,logical_predicate
free_lun,self.lun
end

pro pp_ftp__define
compile_opt idl2,logical_predicate

!null={pp_ftp,inherits IDL_Object,host:'',port:0,path:'',user:'',pw:'',url:'',$
  lun:0,timeout:0,verbose:0B,pwd:'',debug:0B,blocksize:0ULL,clobber:0B,$
  callback_data:ptr_new(),callback_function:'',pu:ptr_new()}

end
