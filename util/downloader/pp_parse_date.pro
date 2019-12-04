; docformat = 'rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
;+
; :Description:
;    Parses date strings into julian dates. More formats will be supported in
;    the future. Example dates in currently supported formats:
;    
;    Fri, 22 Jan 2016 18:03:25 GMT
;      
;
; :Params:
;    idstr: in, required
;    
;      String(s) with date(s) to be converted to JD. Can be scalar or array.
;      
; :Examples:
; 
;   Convert Fri, 22 Jan 2016 18:03:25 GMT::
;   
;     print,pp_parse_date('Fri, 22 Jan 2016 18:03:25 GMT')
;     ;       2457410.3
;
;
;
; :Author: Paulo Penteado (`http://www.ppenteado.net <http://www.ppenteado.net>`)
;-
function pp_parse_date,idstr
compile_opt idl2,logical_predicate

dstr=strtrim(idstr,2)
ret=(size(dstr))[0] ? replicate(0d0,n_elements(dstr)) : 0d0

wkds='(sun)|(mon)|(tue)|(wed)|(thu)|(fri)|(sat)'
mona=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
mons='('+strjoin(mona,')|(')+')'
f1s='('+wkds+'),? +([[:digit:]]{1,2}) +('+mons+') +([[:digit:]]+) +([[:digit:]]{1,2}):([[:digit:]]{1,2}):([[:digit:]]{1,2})'
f2s='('+mons+') +([[:digit:]]{1,2}) +([[:digit:]]{4})'
f3s='([[:digit:]]{1,2})-('+mons+')-([[:digit:]]{4}) ([[:digit:]]{1,2}):([[:digit:]]{1,2})'
f4s='[[:digit:]]{14}' ;FTP format

f1=stregex(dstr,f1s,/bool,/fold_case)
f2=stregex(dstr,f2s,/bool,/fold_case)
f3=stregex(dstr,f3s,/bool,/fold_case)
f4=stregex(dstr,f4s,/bool,/fold_case)

foreach ds,dstr,ids do begin
  case 1 of
    f1[ids]: begin
    dss=stregex(ds,f1s,/extract,/subexpr,/fold_case)
    yr=fix(dss[23])
    mon=(where(dss[11:22]))[0]+1
    day=fix(dss[9])
    h=fix(dss[24])
    m=fix(dss[25])
    s=fix(dss[26])
    ret[ids]=julday(mon,day,yr,h,m,s)
  end
  f2[ids]: begin
    dss=stregex(ds,f2s,/extract,/subexpr,/fold_case)
    yr=fix(dss[15])
    day=fix(dss[14])
    mon=(where(dss[2:13]))[0]+1
    h=0
    m=0
    s=0d0
    ret[ids]=julday(mon,day,yr,h,m,s)
  end
  f3[ids]: begin
    dss=stregex(ds,f3s,/extract,/subexpr,/fold_case)
    yr=fix(dss[15])
    mon=(where(dss[3:14]))[0]+1
    day=fix(dss[1])
    h=fix(dss[16])
    m=fix(dss[17])
    s=0d0
    ret[ids]=julday(mon,day,yr,h,m,s)
  end
  f4[ids]: begin
    yr=strmid(ds,0,4)
    mon=strmid(ds,4,2)
    day=strmid(ds,6,2)
    h=strmid(ds,8,2)
    m=strmid(ds,10,2)
    s=strmid(ds,12,2)
    ret[ids]=julday(mon,day,yr,h,m,s)
  end
  else:
  endcase
endforeach

return,ret
end
