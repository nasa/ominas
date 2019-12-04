pro delete_ominas_files,dir,conf=conf
compile_opt idl2,logical_predicate
if ~n_elements(conf) then conf=0
if (~n_elements(dir)) || (~strlen(strtrim(dir,2))) then begin
  print,'delete_ominas_files: No directory specified'
  return
endif
;print,'This will delete all files downloaded by the OMINAS installer at ',dir
if (conf lt 1) then begin 
  print,'Would you like to delete all the files at '+dir+' (y/n)[n]? '
  ans=''
  read,ans
endif else begin
  ans='y'
  print,'This will delete all files downloaded by the OMINAS installer at ',dir
endelse
if strlowcase(ans) ne 'y' then return
ps=path_sep()
;odir=(file_search(dir)).replace(ps,'_')
odir=(file_search(dir))
odir=strjoin(strsplit(odir,ps,/extract),'_')
odir=strjoin(strsplit(odir,'_',/extract),'_')
ts=file_search(['~'+ps+'.ominas'+ps+'timestamps'+ps+odir+'.json',$
'~'+ps+'.ominas'+ps+'timestamps'+ps+odir+'_*.json'],count=count)
if ~count then begin
  print,'delete_ominas_files: No timestamps files found for specified directory ('+dir+')'
  return
endif
;r=[]
;foreach tts,ts do r=[r,read_json(tts)]
r=hash()
foreach tts,ts do r+=json_parse(tts)

if conf lt 3 then begin
  print,'This will now delete the files'
  ;print,r.filename
  print,r.keys()
endif else print,'Auto skip selected, no deletion will be done'
if (conf lt 2) then begin
  print,'Are you sure you want to delete the above files (y/n)[n]?'
  read,ans
endif else ans=conf eq 2 ? 'y' : 'n'
if strlowcase(ans) ne 'y' then return
;file_delete,r.filename,/allow_nonexistent,/verbose
file_delete,(r.keys()).toarray(),/allow_nonexistent,/verbose
end
