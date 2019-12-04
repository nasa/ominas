; docformat = 'rst'
    ;+
    ; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
    ;-
    ;+
    ; :Description:
    ; 
    ;    This class is used to provide functionality similar to the UNIX wget
    ;    or IDL's wget (introduced in IDL 8.5). The main differences relative
    ;    to IDL's wget is that timestamps of the downloaded files are set to match
    ;    the timestamps informed by the server, and the optional arguments, to control
    ;    things such as overwriting of existing files, recursivenes and regular expression
    ;    matching. 
    ;    
    ;
    ; :Params:
    ;    baseurl: in, required
    ;    The root URL to be downloaded. If this is a directory (ends with /), all
    ;    files found inside it will be downloaded. If it does not end with /, just
    ;    that one file will be downloaded.
    ;
    ; :Keywords:
    ;    clobber: in, optional, default=0
    ;      If set to 0 (default), exisiting files with the same timestamp as that
    ;      returned by the server will be skipped. If set to 1, files will be downloaded, 
    ;      even if overwriting existing local files. If set to 2, existing files will
    ;      be skipped, without checking the timestamp. Setting this argument to 1
    ;      is useful to resume an interrupted download of a directory.
    ;    pattern: in, optional
    ;      A string with a regular expression that file names in the server will be
    ;      matched to. If provided, only those files matching this expression will be
    ;      downloaded.
    ;    recursive: in, optional, default=0
    ;      If set and baseurl is a directory, all directories contained inside it
    ;      will be recursively downloaded.
    ;    localdir: in, optional, default='./'
    ;      Local directory where the downloaded files are to be stored. Defaults to the
    ;      current directory.
    ;    debug: in, optional, default=0
    ;    timestamps: in, optional
    ;      If provided, a hash (empty or not) where the timestamps of the downloaded
    ;      files will be stored. Such a hash is always created internally and can be
    ;      retrieved as a property (called timestamps). The reason to provide a hash
    ;      is to have the timestamps be appended to this hash, instead of having a new
    ;      hash created. 
    ;    bdir: in, optional
    ;      For internal use by recursive calls only.
    ;    xpattern: in, optional
    ;      A string with a regular expression that file names in the server will be
    ;      matched to. If provided, only those files NOT matching this expression will be
    ;      downloaded.
    ;    absolute_paths: in, optional, default=0
    ;      If set, the timestamps hash will contain absolute paths instead of relative paths. 
    ;
    ; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
    ;-
function pp_wget::init,baseurl,clobber=clobber,pattern=pattern,$
recursive=recursive,localdir=localdir,debug=debug,timestamps=timestamps,$
bdir=bdir,xpattern=xpattern,absolute_paths=absolute,_ref_extra=e,$
ssl_certificate_file=sslf,splitrows=splitrows,allow_slash=allow_slash,$
lm=lm,tz=tz,quiet=quiet,ftpw=ftpw,mdonly=mdonly
compile_opt idl2,logical_predicate,hidden

self.clobber=keyword_set(clobber)
self.localdir=n_elements(localdir) ? localdir : '.'
self.baseurl=baseurl
self.recursive=keyword_set(recursive)
self.timestamps=isa(timestamps,'hash') ? timestamps : hash()
ldir=file_expand_path(self.localdir)
self.debug=keyword_set(debug)
self.bdir=n_elements(bdir) ? bdir : ''
self.ldir=ldir+path_sep()
self.pattern=n_elements(pattern) ? pattern : ''
self.xpattern=n_elements(xpattern) ? xpattern : ''
self.absolute=keyword_set(absolute)
;self.sslf=n_elements(sslf) ? file_search(sslf) : (file_search(filepath('',subdir='bin')+'*/ca-bundle.crt'))[0]
if (n_elements(sslf)) && (sslf) then self.sslf=file_search(sslf) else begin
  if (!version.release ge '8.4') then self.sslf=(file_search(filepath('',subdir='bin')+'*/ca-bundle.crt'))[0] else begin
     ft=file_dirname((file_which('pp_wget__define.pro'))[0],/mark_directory)+'ca-bundle.crt'
     self.sslf=file_test(ft,/read) ? ft : (file_search(filepath('',subdir='bin')+'*/ca-bundle.crt'))[0]
   endelse
endelse
self.quiet=keyword_set(quiet)
if ~self.quiet then print,self.sslf
self.splitrows=keyword_set(splitrows)
self.allow_slash=keyword_set(allow_slash)
self.lm=keyword_set(lm)
self.tz=n_elements(tz) ? tz : 0d0
self.ftpw=n_elements(ftpw) ? ftpw :  (!version.release lt '8.4')
self.mdonly=n_elements(mdonly) ? mdonly : 0B
;if n_elements(e) then self.extra=ptr_new(e)

return,1
end

;+
; :Description:
;    Internal function, inteded to be used by pp_wget::geturl.
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
function pp_wget_callback,StatusInfo,ProgressInfo,CallbackData
compile_opt idl2,logical_predicate
if callbackdata.debug then print,statusinfo
w=where(stregex(statusinfo,'Verbose:[[:blank:]]+Header In:[[:blank:]]+Content-Length:',/bool),count)
if count then begin
  tmp=stregex(statusinfo[w[0]],'Content-Length:[[:blank:]]*([[:digit:]]+)',/subexpr,/extract)
  callbackdata.content_length=long64(tmp[1])
  if ~callbackdata.quiet then print,'Content Length: ',pp_readablesize(tmp[1],/string)
  if callbackdata.mdonly eq 1 then begin
    print,'Skipping download'
    callbackdata.mdata={size:long64(tmp[1])}
    return,0
  endif
endif
w=where(stregex(statusinfo,'Verbose:[[:blank:]]+Header In:[[:blank:]]+Last-Modified:',/bool),count)
if count then begin
  olm=callbackdata.last_modified
  sinfom=stregex(statusinfo[w[0]],'Last-Modified:[[:blank:]]+(.*)',/subexpr,/extract)
  callbackdata.last_modified=sinfom[1]
  if (~callbackdata.clobber) && callbackdata.local_file_exists then begin
    tml=callbackdata.local_file_tm
    tmr=sinfom[1]
    tmrj=pp_parse_date(tmr)
    tmlj=julday(1,1,1970)-0.5d0+tml/86400d0
    if olm then begin ;if server provided a timestamp with directory listing
      tdiff=pp_parse_date(olm)-tmrj
      if (tdiff le 1d0) then begin
        tz=round(tdiff*1440d0) ;offset as integer minutes
        tz=15*round(tz/15) ;offset in precision of 1/4h (the smallest time zone difference)
        callbackdata.tz=tz/1440d0
        callbackdata.hlm=olm
      endif
    endif
    ;if (abs(tmrj-tmlj) lt 1d0/86400d0) then begin
    if (abs(tmrj-tmlj) lt 1d0/1440d0) then begin
      print,'This file is already present locally with same timestamp. Skipping'
      return,0
    endif else print,'dif: ',tmrj-tmlj
  endif
endif
return,1
end

pro pp_wget::setproperty,last_modified=last_modified,content_length=content_length,$
  tz=tz,hlm=hlm,quiet=quiet,mdata=mdata
compile_opt idl2,logical_predicate
if n_elements(last_modified) then self.last_modified=last_modified
if n_elements(content_length) then self.content_length=content_length
if n_elements(tz) then self.tz=tz
if n_elements(hlm) then self.hlm=hlm
if n_elements(mdata) then self.mdata=ptr_new(mdata)
;if n_elements(ex) then self.idlneturl::setproperty,_strict_extra=ex
end

pro pp_wget::getproperty,local_file_tm=local_file_tm,clobber=clobber,$
  debug=debug,content_length=content_length,local_file_exists=local_file_exists,$
  timestamps=timestamps,last_modified=last_modified,tz=tz,hlm=hlm,quiet=quiet,$
  mdonly=mdonly,mdata=mdata
compile_opt idl2,logical_predicate
if arg_present(local_file_tm) then local_file_tm=self.local_file_tm
if arg_present(clobber) then clobber=self.clobber
if arg_present(debug) then debug=self.debug
if arg_present(local_file_exists) then local_file_exists=self.local_file_exists
if arg_present(timestamps) then timestamps=self.timestamps
if arg_present(last_modified) then last_modified=self.last_modified
if arg_present(tz) then tz=self.tz
if arg_present(hlm) then hlm=self.hlm
;if n_elements(ex) then self.idlneturl::setproperty,_strict_extra=ex
if arg_present(quiet) then quiet=self.quiet
if arg_present(mdonly) then mdonly=self.mdonly
if arg_present(mdata) then mdata=*self.mdata
end

;+
; :Description:
;    Starts the download of the URL set when the object was instantiated.
;    
; :Examples:
; 
;    Download all files at ,skipping exisiting files, recursively::
;    
;      
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
pro pp_wget::geturl,listonly=listonly
compile_opt idl2,logical_predicate

if ~file_test(self.ldir,/directory) then begin
  if file_test(self.ldir,/regular) then begin
    if ~self.quiet then print,'directory ',self.ldir,' exists as a file. Deleting the file to replace it with directory'
    file_delete,self.ldir,/verbose
  endif
  print,'Creating directory ',self.ldir
  file_mkdir,self.ldir
endif


pu=parse_url(self.baseurl)
if (strlowcase(pu.scheme) eq 'ftp') && (self.ftpw) then begin
 self.iu=pp_ftp(url=self.baseurl,verbose=~self.quiet,debug=self.debug,callback_data=self,$
 callback_function='pp_wget_callback')
endif else begin
 if ptr_valid(self.extra) then begin
  self.iu=idlneturl(url_host=pu.host,url_scheme=pu.scheme,url_port=pu.port,url_path=pu.path,$
    url_query=pu.query,/verbose,callback_function='pp_wget_callback',callback_data=self,$
    ftp_connection_mode=0,_strict_extra=*self.extra,ssl_certificate_file=self.sslf)
 endif else begin
  self.iu=idlneturl(url_host=pu.host,url_scheme=pu.scheme,url_port=pu.port,url_path=pu.path,$
    url_query=pu.query,/verbose,callback_function='pp_wget_callback',callback_data=self,$
    ftp_connection_mode=0,ssl_certificate_file=self.sslf)    
 endelse
endelse

if strmatch(self.baseurl,'*/') then begin ;if url is a directory
  if strlowcase(pu.scheme) eq 'ftp' then begin
    ;ind=!version.release gt '8.3' ? self.iu.getftpdirlist() : pp_jget(self.baseurl)
    ind=self.iu.getftpdirlist()
    inds=(strsplit(ind,/extract)).toarray()
    links=inds[*,-1]
    lm=inds[*,-4]+' '+inds[*,-3]+' '+inds[*,-2]
    if arg_present(listonly) then begin
      listonly=links
      return
    endif
    foreach link,links,il do begin
      self.retrieve,link,lm=lm[il],/skip_missing
    endforeach
  endif else begin
    ind=self.iu.get(/string_array)
    if self.splitrows then begin
      indtmp=strsplit(ind,'</tr>',/extract,/regex,count=count)
      foreach c,count,ic do if (c gt 0) then indtmp[ic]+='</tr>'
      indtmp=indtmp.toarray(dim=1)
      ind=indtmp
    endif
    indj=strjoin(ind,' ')
    tmp=strtrim(((stregex(indj,'<title>(.+)</title>',/extract,/subexpr))[1]),2)
    if stregex(tmp,'^index of ',/fold_case,/bool) then begin
      ;w=where(stregex(ind,'<a[[:blank:]]+href[[:blank:]]*="[^"]+"[^>]*>',/bool))
      w=where(stregex(ind,'<a[^>]*[[:blank:]]+href[[:blank:]]*="[^"]+"[^>]*>',/bool))
      indl=ind[w];lines with links
      ;links=reform((stregex(indl,'<a[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>',/extract,/subexpr))[1,*])
;      links=(stregex(indl,'<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>',/extract,/subexpr))
      ;links=(stregex(indl,'<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>.*<td[^>]*>[[:blank:]]*([[:alnum:] :-]{10,17})[[:blank:]]*</td>',/extract,/subexpr))     re1='<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>.*<td[^>]*>[[:blank:]]*([[:alnum:] :-]{10,17})[[:blank:]]*</td>'
      re1='<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>.*<td[^>]*>[[:blank:]]*([[:alnum:] :-]{10,17})[[:blank:]]*</td>'
      links=stregex(indl,re1,/boolean)
      if total(links,/integer) eq 0 then begin
        re2='<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>.*<td[^>]*>[[:blank:]]*([[:alnum:] :-]{10,19})[[:blank:]]*</td>'
        links=stregex(indl,re2,/extract,/subexpr)
        lms=reform(links[2,*])
        links=reform(links[1,*])
      endif else begin
        links=stregex(indl,re1,/extract,/subexpr)
        lms=reform(links[2,*])
        links=reform(links[1,*])
      endelse
      if total(strlen(strtrim(lms,2)),/integer) eq 0 then begin
        links=(stregex(indl,'\[(DIR)?[[:blank:]]*\][[:blank:]]*<a[^>]*[[:blank:]]+href[[:blank:]]*="([^"]+)"[^>]*>([^<]*)</a>(<td[^>]*>)?[[:blank:]]*([[:alnum:] :-]{10,17})[[:blank:]]*(</td>)?',/extract,/subexpr))
        lms=reform(links[5,*])
        w=where(strtrim(links[1,*],2) eq 'DIR',wc)
        if wc then begin
          ww=where(~strmatch(links[3,*],'*/'),wwc)
        endif else wwc=0
        links=reform(links[3,*])
        if wwc then links[w[ww]]+='/'
      endif
      wla=where(stregex(links,'^(\/|\?)',/bool),/null,count,complement=wlac)
      if ~self.allow_slash then begin
        links=links[wlac]
        lms=lms[wlac]
      endif else begin
        w=wla
        if count then begin
          ;links[w]=strmid(links[w],1)
          lw=stregex(links[w],'^/'+pu.path+'(.*)',/extract,/subexpr)
          links[w]=lw[1,*]
          ;print,count
        endif
        wf=where(strlen(strtrim(links,2)),/null)
        links=links[wf]
        lms=lms[wf]
      endelse
      if arg_present(listonly) then begin
        listonly=links
        return
      endif
      foreach link,links,il do begin
        if self.lm then self.retrieve,link,/skip_missing,lm=lms[il] $
          else self.retrieve,link,/skip_missing
      endforeach
    endif
  endelse
endif else begin
  ;link=file_basename(pu.path)
  ;self.iu.setproperty,url_path=(stregex(pu.path,'(.*)'+link+'$',/extract,/subexpr))[1]
  self.retrieve,''
endelse

end

;+
; :Description:
;    Internal function, inteded to be used by pp_wget::geturl.
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
pro pp_wget::retrieve,link,lm=lm,skip_missing=skip_missing
compile_opt idl2,logical_predicate,hidden
self.hlm=''
if ~strmatch(link,'*/') then begin ;if entry is not a directory
  self.iu.getproperty,url_scheme=us,url_port=po,url_path=up
  pu=parse_url(self.baseurl)
  if (us eq 'https') && ~(stregex(self.baseurl,'https://[^/]+:[[:digit:]]+',/bool)) then po='443'
  ;if (pu.scheme eq 'https') && ~(stregex(self.baseurl,'https://[^/]+:[[:digit:]]+',/bool)) then pu.port='443'
  ;self.iu.setproperty,url_path=up+link,url_port=po
  self.iu.setproperty,url_path=pu.path+link,url_port=po
  if self.pattern && ~stregex(link,self.pattern,/bool) then begin
    if ~self.quiet then print,'skipping '+link+' because it does not match the specified pattern: '+self.pattern
    return
  endif
  if self.xpattern && stregex(link,self.xpattern,/bool) then begin
    if ~self.quiet then print,'skipping '+link+' because it matches the specified xpattern: '+self.xpattern
    return
  endif
  ds=((self.bdir ? (self.bdir+'/') : '')+link)
  if ~ds then ds=self.baseurl
  print,'downloading '+ds
  self.last_modified=n_elements(lm) ? lm : ''
  self.hlm=self.last_modified
  self.content_length=0LL
  fi=file_info(self.ldir+link)
  if (fi.exists && self.clobber eq 2) then begin
    print,'skipping '+link+' because it already exists.'
    return
  endif
  if ~self.clobber then begin
    if fi.exists then begin
      self.local_file_exists=1
      self.local_file_tm=fi.mtime
    endif else begin
      self.local_file_exists=0
      self.local_file_tm=0
    endelse
  endif
  setts=1
  
    catch,err
    if err then begin
      catch,/cancel
      if (err ne -1005) && (err ne -1006) && (~strmatch(!error_state.msg,'*Cancel request detected*',/fold_case)) then begin
        if keyword_set(skip_missing) && (strmatch(!error_state.msg,'*Failed to open file*',/fold_case) || (err eq -1052)) then begin
          return
        endif
        print,'error downloading file ',link,': ',err,' ',!error_state.msg
        return
      endif else setts=0
    endif else begin
      ng=0B
      if self.last_modified then begin
        if (~self.clobber) && self.local_file_exists then begin
          tml=self.local_file_tm
          tmrj=pp_parse_date(self.last_modified)
          if (self.last_modified eq self.hlm) then tmrj-=self.tz
          tmlj=julday(1,1,1970)-0.5d0+tml/86400d0
          ;if (abs(tmrj-tmlj) lt 1d0/86400d0) then begin
          ;if (abs(tmrj-tmlj) lt 1d0/1440d0) then begin
          ;for test from server directory listing, test must be more lax, as servers may not inform time zone, so their time might shift by 1h during the year
          if (abs(tmrj-tmlj) le 1d0/24d0+1d0/1440d0) then begin
            if ~self.quiet then print,'This file is already present locally with same timestamp. Skipping.'
            setts=0B
            ng=1B
          endif ;else print,'diff: ',tmrj-tmlj
        endif
      endif
      if ~ng then begin
        fn=link ? link : file_basename(pu.path)
        self.hlm=self.last_modified
        g=self.iu.get(filename=self.ldir+fn)
        nlm=self.last_modified
      endif
    endelse
  
  ;Set the timestamp
  if self.last_modified then begin
    if n_elements(lm) then tm=self.last_modified else begin
      tm=stregex(self.last_modified,'Last-Modified:[[:blank:]]+(.*)',/subexpr,/extract)
      tm=tm[1]
    endelse
    if tm then begin
      tmrj=pp_parse_date(tm)
      if (self.last_modified eq self.hlm) then tmrj-=self.tz
      if setts then begin
        if ~strmatch(!version.os_family,'*win*',/fold) then begin ;linux-like systems
          caldat,tmrj,mon,day,yr,h,m,s
          tmstr=string(yr,mon,day,h,m,s,format='(I04,I02,I02,I02,I02,".",I02)')
          smon=(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'])[mon-1]
          tmstr=string(day,smon,yr,h,m,s,format='(I02," ",A3," ",I04," ",I02,":",I02,":",I02," GMT")')
          ;print, 'touch -d "'+tmstr+'" '+self.ldir+link
          ;spawn,'touch -d "'+tmstr+'" '+self.ldir+link
          tmstr=string(yr,mon,day,h,m,s,format='(I04,I02,I02,I02,I02,".",I02)')
          ;print, 'TZ=UTC touch -t "'+tmstr+'" '+self.ldir+link
          spawn, 'test "$?BASH_VERSION" = "0" || eval '+"'"+'setenv() { export "$1=$2"; }'+"'"+'; setenv TZ UTC; touch -t "'+tmstr+'" '+self.ldir+link
        endif else begin ;Windows systems
          spawn,'powershell -WindowStyle Hidden "$(Get-Item '+self.ldir+link+').lastwritetime=$(Get-Date '+"'"+tm+"'"+')"',/noshell
        endelse
      endif
      tsf=self.absolute ? file_expand_path(self.ldir+link) : self.bdir+link
      (self.timestamps)[tsf]=tmrj
    endif
  endif
endif else begin
  if self.recursive then begin ; if entry is a directory
    if self.pattern && ~stregex(link,self.pattern,/bool) then begin
      if ~self.quiet then print,'skipping '+link+' because it does not match the specified pattern: '+self.pattern
      return
    endif
    if self.xpattern && stregex(link,self.xpattern,/bool) then begin
      if ~self.quiet then print,'skipping '+link+' because it matches the specified xpattern: '+self.xpattern
      return
    endif
    if ~self.quiet then print,'Entering directory ',link
    iw=pp_wget(self.baseurl+'/'+link,$
      timestamps=self.timestamps,clobber=self.clobber,pattern=self.pattern,$
      recursive=self.recursive,localdir=self.localdir+path_sep()+link+path_sep(),$
      bdir=self.bdir ? self.bdir+'/'+link : link,xpattern=self.xpattern,absolute=self.absolute,$
      ssl_certificate_file=self.sslf,splitrows=self.splitrows,allow_slash=self.allow_slash,$
      lm=self.lm,quiet=self.quiet,ftpw=self.ftpw,mdonly=self.mdonly)
    iw.geturl
    if ~self.quiet then print,'Done with directory ',link
  endif else if ~self.quiet then print,'Recursive mode not set, skipping directory ',link
endelse
end

;+
; :Description:
;    Type definition for pp_wget. See the documentation on `pp_wget::init`.
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
pro pp_wget__define
compile_opt idl2,logical_predicate
!null={pp_wget, inherits idl_object, clobber:0,recursive:0,$
  ldir:'',pattern:'',localdir:'',last_modified:'',local_file_exists:0,local_file_tm:0LL,$
  baseurl:'',iu:obj_new(),timestamps:obj_new(),debug:0,content_length:0LL,bdir:'',$
  xpattern:'',absolute:0,extra:ptr_new(),sslf:'',splitrows:0B,allow_slash:0B,lm:0B,$
  tz:0d0,hlm:'',quiet:0B,ftpw:0B,mdonly:0B,mdata:ptr_new()}
end
