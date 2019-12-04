; docformat = 'rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`), Dec/2016
;-
;+
; :Description:
;    A wrapper to pp_wget, to be called from the system command line. Any arguments
;    are passed on to pp_wget, except for the timestamps argument, which specifies
;    a file where the timestamps of the downloaded files are to be stored.
;    
;    See the documentation for `pp_wget__define` for its optional arguments.
;    
;    Example::
;    
;      From the command line (outside IDL), download some files non recursively
;      and save the timestamps to the file pp_wgetcl_timestamps.json::
;      
;        idl -e pp_wgetcl -args http://naif.jpl.nasa.gov/pub/naif/CASSINI/kernels/lsk/ --timestamps=pp_wgetcl_timestamps.json --clobber
;        
;      The files are downloaded to the local directory (pp_wget's default location),
;      and the timestamps look like::
;      
;        ;{
;        ;"naif0007.tls": 2451644.2442013896,
;        ;"naif0010.tls": 2455945.6274537044,
;        ;"naif0011.tls": 2457035.4201967600,
;        ;"naif0012.tls": 2457603.9250231488,
;        ;"naif0008.tls": 2453588.2689467599,
;        ;"naif0009.tls": 2454669.5206018523,
;        ;"aareadme.txt": 2452662.3099884265
;        ;}
;
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`), Dec/2016
;-
pro pp_wgetcl
compile_opt idl2,logical_predicate
a=pp_command_line_args_parse()
if a.keywords.haskey('verbose') && a.keywords['verbose'] then begin
  ;print,a.keywords.tostruct(),/impl
  print,json_serialize(a.keywords.tostruct())
  ;print,a.arguments,/impl
  print,json_serialize(a.arguments)
endif
if a.argcount lt 1 then return
if a.keycount then begin
  if a.keywords.haskey('timestamps') then begin
    tsf=a.keywords['timestamps']
    a.keywords.remove,'timestamps'
  endif
  pg=pp_wget(a.arguments[0],_extra=a.keywords.tostruct())
endif else begin
  pg=pp_wget(a.arguments[0])
endelse
if a.keywords.haskey('debug') && a.keywords['debug'] then print,'pp_wget object created'
pg.geturl
if a.keywords.haskey('debug') && a.keywords['debug'] then print,'all files retrieved'
if n_elements(tsf) then begin
  ts=pg.timestamps
  ;tsf=file_expand_path(tsf)
  if strmatch(tsf,'*/') then begin
    ld=a.keywords['localdir']
    fs=file_expand_path(ld)
    fs=strjoin(strsplit(fs,'/',/extract),'_')
    tsf=tsf+fs+'.json'
  endif
  print,'Saving timestamps to ',tsf  
  openw,lun,tsf,/get_lun
  ;printf,lun,ts,/impl
  tsout=strsplit(json_serialize(ts),',',/extract)
  tsout=n_elements(tsout) gt 1 ? [tsout[0:-2]+',',tsout[-1]] : tsout
  printf,lun,tsout
  free_lun,lun
endif
end
