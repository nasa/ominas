; docformat = 'rst rst'
;+
;
; Class to provide access to w10n data. Can handle authentication
; through a URS server (`https://urs.earthdata.nasa.gov/ <https://urs.earthdata.nasa.gov/>`).
; 
; :Examples:
; 
;   Retrieve the variable TSurfAir from a AIRS granule. The EOSDIS server
;   requires URS authentication::
;   
;     f=pp_w10ndata('http://airsl2.gesdisc.eosdis.nasa.gov/pomegranate/Aqua_AIRS_Level2/AIRS2SUP.006/2002/244/AIRS.2002.09.01.001.L2.RetSup_IR.v6.0.7.0.G13207161125.hdf',/urs)
;     ts=f['TSurfAir']
;     ;Enter username for urs.earthdata.nasa.gov 
;     ;Enter password for urs.earthdata.nasa.gov (it will show in the terminal, and possibly, in the IDL command history) 
;     help,ts
;     ;TS              FLOAT     = Array[30, 45]
;   
;   Now that login was performed, the cookies from the URS server can be saved
;   for future use, without neeed to provide username and password again. Here
;   we will use the default cookie file location (~/.pp_w10ndatarc), but it can
;   be provided with the `cookiefile` keyword.
;   
;     f.savecookies
;     f2=pp_w10ndata('http://airsl2.gesdisc.eosdis.nasa.gov/pomegranate/Aqua_AIRS_Level2/AIRS2SUP.006/2002/244/AIRS.2002.09.01.001.L2.RetSup_IR.v6.0.7.0.G13207161125.hdf',/urs,/cookiefile)
;     ts=f2['TSurfAir']
;     help,ts
;     ;TS              FLOAT     = Array[30, 45]
;     
;   Thus authentication is only needed once, to create the cookies file.
;   There are two alternatives to typing the username/password interactively:
;   1) Provide them as keywords, and
;   2) Provide them in a `.netrc file <https://www.gnu.org/software/inetutils/manual/html_node/The-_002enetrc-file.html>`. 
;   It is the same file that can be used by
;   `wget <https://www.gnu.org/software/wget/>`. In this example, we will use the
;   default .netrc file location (~/.netrc), but an alternate location can
;   be provided with the `netrc` keyword::
;   
;     f3=pp_w10ndata('http://airsl2.gesdisc.eosdis.nasa.gov/pomegranate/Aqua_AIRS_Level2/AIRS2SUP.006/2002/244/AIRS.2002.09.01.001.L2.RetSup_IR.v6.0.7.0.G13207161125.hdf',/urs,/netrc)
;     ts=f3['TSurfAir']
;     ;pp_ursurl: trying authentication with netrc credentials provided
;     help,ts
;     ;TS              FLOAT     = Array[30, 45]
;   
;   Note that the host on the .netrc must be the one that does the authentication,
;   which is the URS server, `urs.earthdata.nasa.gov`, not the one that servers
;   the data. See `https://wiki.earthdata.nasa.gov/display/HDD/Wget+with+URS+Authentication <https://wiki.earthdata.nasa.gov/display/HDD/Wget+with+URS+Authentication>' 
;   for more information on URS authentication. 
;     
; 
; :Requires: IDL 8.2, `pp_ursurl__define`, `pp_readtxt`, `pp_parsenetrc`, $
; mg_getpassword, password, `pp_label2hash`
; 
; :Todo: Caching, retrieving only selected indices, parsing file metadata
; to provide a variable tree.
;
; :Author: Paulo Penteado (http://www.ppenteado.net), Aug/2016
;-


function pp_w10ndata::init,url,$
  cookiefile=cookiefile,netrcfile=netrcfile,$
  urs=urs,_ref_extra=ex,$
  debug=debug
compile_opt idl2,logical_predicate

if n_elements(cookiefile)&&cookiefile then self.readcookies,cookiefile else self.cookies=hash()
if n_elements(netrcfile)&&netrcfile then self.readnetrc,netrcfile else self.netrc=hash()


tmp=stregex(url,'([[:alpha:]]+)://([^/]+)/(.+)',/subexpr,/extract)

uscheme=tmp[1]
uhost=tmp[2]
upath=tmp[3]
self.uhost=uhost
self.upath=upath+'/'
self.baseurl=uhost+'/'+upath

self.inet=keyword_set(urs) ? pp_ursurl(url_hostname=uhost,url_path=self.upath,$
  url_scheme=uscheme,_strict_extra=ex,debug=debug,cookies=self.cookies,netrc=self.netrc) : idlneturl(url_hostname=uhost,url_path=self.upath,$
    url_scheme=uscheme,_strict_extra=ex)

self.cache=hash()

;Constants
self.endian=(swap_endian(1L,/swap_if_big) eq 1L) ? 'le' : 'be'

self.typedict=hash()
self.typedict['float32']=!values.f_nan
self.typedict['float64']=!values.d_nan
self.typedict['int8']=0B
self.typedict['uint8']=0B
self.typedict['int16']=0S
self.typedict['int32']=0L
self.typedict['int64']=0LL
self.typedict['uint16']=0US
self.typedict['uint32']=0UL
self.typedict['uint64']=0ULL



return,obj_valid(self.inet)

end



function pp_w10ndata::_overloadBracketsRightSide, isRange, sub1, $
   sub2, sub3, sub4, sub5, sub6, sub7, sub8
compile_opt idl2,logical_predicate

if isrange[0] || ~isa(sub1,'string') then message,'First dimension must be a non-empty variable name'
sl=strlen(strtrim(sub1,2))
var=strpos(sub1,'/',/reverse_search) eq (sl-1) ? strmid(sub1,0,sl-1) : sub1

ret=self.getvar(var)
return,ret

end

function pp_w10ndata::getvar,var
compile_opt idl2,logical_predicate

if (self.cache).haskey(var) then return,(self.cache)[var]

ret=!null
;Get the metadata
self.inet.setproperty,url_path=self.upath+var+'/'
self.inet.setproperty,url_query='output=json'
if (~isa(self.inet,'pp_ursurl')) && self.cookies.haskey(self.uhost) then self.inet.setproperty,header='Cookie: '+self.cookie[self.uhost]
meta=self.inet.getr(/string)
meta=json_parse(meta)
if (var eq '') then return,meta
type=strlowcase(meta['type'])
type=size(self.typedict[type],/type)
attr=meta['attributes']
foreach a,attr do begin
  if strmatch(strtrim(a['name'],2),'_FillValue') then begin
    fill=a['value']
  endif
endforeach

;Get the data
self.inet.setproperty,url_path=self.upath+var+'[]'
self.inet.setproperty,url_query='output='+self.endian
;if self.cookie then self.inet.setproperty,header='Cookie: '+self.cookie

ret=self.inet.getr(/buffer)
dims=reverse((meta["shape"]).toarray())
ret=fix(ret,0,dims,type=type)
if n_elements(fill) then begin
  w=where(ret eq fill,count)
  if count then ret[w]=!values.d_nan
endif
(self.cache)[var]=ret

return,ret
end

function pp_w10ndata::getvariables
compile_opt idl2,logical_predicate
if obj_valid(self.variables) then return,(self.variables)[*]
meta=self.getvar('')
attrs=hash()
foreach a,meta['attributes'] do begin
  if strmatch(a['name'],'StructMetadata*') then attrs[a['name']]=a['value']
endforeach
k=(attrs.keys()).toarray()
sa=k[sort(k)]
label=''
foreach s,sa do label+=attrs[s]
lbl=strsplit(label,string(10B),/extract)
lbl=strtrim(lbl,2)
lbl=lbl[where(strlen(lbl),/null,count)]
if ~count then return,!null
w=where(strmatch(lbl,'END'),count)
if count && w[0] gt 0 then lbl=lbl[0:w[0]-1] else return,!null
l=list(lbl,/extract)
resolve_routine,'pp_label2hash',/is_function
h=pp_label2hash_proc(l,0)
hd=(h.keys()).filter(lambda(x:strmatch(x,'Dimension_*')))
dims=!version.release ge '8.3' ? orderedhash() : hash()
foreach hdd,hd do begin
  tmp=h[hdd,0]
  dims[tmp['DimensionName']]=long(tmp['Size'])
endforeach
hd=(h.keys()).filter(lambda(x:strmatch(x,'GeoField_*')))
geolocs=!version.release ge '8.3' ? orderedhash() : hash()
foreach hdd,hd do begin
  tmp=h[hdd,0]
  name=tmp['GeoFieldName']
  diml=tmp['DimList']
  diml=strtrim(diml,2)
  diml=strmid(diml,1,strlen(diml)-2)
  diml=strsplit(diml,',',/extract)
  diml=stregex(diml,'"?([^"]+)+"?',/extract,/subexpr)
  diml=reform(strtrim(diml[1,*],2))
  dim=lonarr(n_elements(diml))
  foreach d,diml,id do dim[id]=dims[d]
  geolocs[name]={dimn:diml,type:tmp['DataType'],dims:dim}
endforeach
hd=(h.keys()).filter(lambda(x:strmatch(x,'DataField_*')))
dataf=!version.release ge '8.3' ? orderedhash() : hash()
foreach hdd,hd do begin
  tmp=h[hdd,0]
  name=tmp['DataFieldName']
  diml=tmp['DimList']
  diml=strtrim(diml,2)
  diml=strmid(diml,1,strlen(diml)-2)
  diml=strsplit(diml,',',/extract)
  diml=stregex(diml,'"?([^"]+)+"?',/extract,/subexpr)
  diml=reform(strtrim(diml[1,*],2))
  dim=lonarr(n_elements(diml))
  foreach d,diml,id do dim[id]=dims[d]
  dataf[name]={dimn:diml,type:tmp['DataType'],dims:dim}
endforeach
ret=!version.release ge '8.3' ? orderedhash() : hash()
ret['dims']=dims
ret['geo']=geolocs
ret['data']=dataf
self.variables=ret
return,ret
end


pro pp_w10ndata::getproperty,_ref_extra=ex,cookies=cookies
compile_opt idl2,logical_predicate
if arg_present(cookies) then cookies=self.cookies
if n_elements(ex) then self.inet.getproperty,_strict_extra=ex
end

pro pp_w10ndata::clearcache
compile_opt idl2,logical_predicate
self.cache=hash()
end

pro pp_w10ndata::savecookies,file
compile_opt idl2,logical_predicate
;Default file location
file=n_elements(file) ? file : '~'+path_sep()+'.pp_w10ndatarc'
openw,lun,file,/get_lun
printf,lun,json_serialize(self.cookies)
free_lun,lun
end

pro pp_w10ndata::readcookies,file
compile_opt idl2,logical_predicate
;Default file location
file=n_elements(file) ? file : '~'+path_sep()+'.pp_w10ndatarc'
if ~(isa(file,/string) && file) then file='~'+path_sep()+'.pp_w10ndatarc'
self.cookies=file_test(file,/read) ? json_parse(pp_readtxt(file)) : hash()
end

pro pp_w10ndata::readnetrc,file
compile_opt idl2,logical_predicate
;Default file location
file=n_elements(file) ? file : '~'+path_sep()+'.netrc'
if ~(isa(file,/string) && file) then file='~'+path_sep()+'.netrc'
n=pp_parsenetrc(file)
self.netrc=n
end


pro pp_w10ndata__define
compile_opt idl2,logical_predicate
!null={pp_w10ndata, inherits IDL_Object,baseurl:'',cookies:obj_new(),$
  inet:obj_new(),endian:'',upath:'',uhost:'',typedict:obj_new(),netrc:obj_new(),$
  cache:obj_new(),widget:0L,variables:obj_new()}

end
