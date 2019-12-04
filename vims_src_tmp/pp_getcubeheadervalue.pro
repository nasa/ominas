; docformat = 'rst'
;+
; :Description:
;   Retrieves the value of the given key from the given header in ISIS cube format.
;
; :Returns:
;   A string scalar or vector (depending on the value being scalar or not) with
;   the value of the given key from the header. If not found, returns 0. If the
;   value is a quoted string, the quotes are not removed. 
;
; :Params:
;    header : in, required
;      A string array where each element is one line of an ISIS cube.
;    key : in, required
;      A string scalar with the key to be retrieved. Regular expression metacharacters must be escaped.
;
; :Keywords:
;    not_trimmed : in, optional, default=0
;      This routine needs that each line of the header is trimmed from
;      whitespaces on both sides. If the provided header is not trimmed, set
;      this keyword so that it will be trimmed before processing (the input
;      variable is unchanged). This option exists to save repeated trimming on
;      multiple queries of the same header, in which case it should be trimmed
;      before the multiple calls of this routine, for better efficiency.
;    count : out, optional
;      The number of occurences of the key found in the header. If more than 1
;      is found, the last occurence is used by default. Check this value to determine if
;      the key was not found (count will be 0 in that case).
;    fold_case : in, optional
;      Passed to stregex when searching for the key. If set, capitalization of
;      the key is ignored.
;    lines : out, optional
;      The line index (starting at zero) of the line in the header that provided
;      the retrieved value. If valued spanned more than one line, this is a vector
;      with the indexes of all such lines. If key not found, -1 is returned.
;    unquote : in, optional
;      If set, enclosing quotes are removed from the return values
;    sel : in, optional
;      In case more than one ocurrence of a keyword is found, sel gives the
;      index of the ocurrence to use (starts at 0). If not set, the last ocurrence
;      is the one used.
;
; :Examples:
;    Make a simple example header::
;    
;      head=strarr(3)      
;      head[0]='BAND_SUFFIX_NAME = (LATITUDE,LONGITUDE,SAMPLE_RESOLUTION,LINE_RESOLUTION,'
;      head[1]='PHASE_ANGLE,INCIDENCE_ANGLE,EMISSION_ANGLE,NORTH_AZIMUTH)'
;      head[2]='START_TIME = "2007-084T10:00:57.286Z"'
;      
;    Get its values::
;    
;      print,pp_getcubeheadervalue(head,'BAND_SUFFIX_NAME')
;      ;LATITUDE LONGITUDE SAMPLE_RESOLUTION LINE_RESOLUTION PHASE_ANGLE INCIDENCE_ANGLE EMISSION_ANGLE NORTH_AZIMUTH
;      print,pp_getcubeheadervalue(head,'START_TIME')
;      ;"2007-084T10:00:57.286Z"
;
; :Uses: pp_extractfields
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_getcubeheadervalue,header,key,not_trimmed=not_trimmed,count=count,$
 fold_case=fold_case,lines=lines,unquote=unquote,sel=sel,continueblank=cont
compile_opt idl2

;Defaults
not_trimmed=n_elements(not_trimmed) eq 1 ? not_trimmed : 0
unquote=n_elements(unquote) eq 1 ? unquote : 0
cont=keyword_set(cont)

if (not_trimmed) then begin
;If it was not previously trimmed (done this way to avoid copying when already trimmed)
  oldheader=header
  header=strtrim(header,2)
end
nh=n_elements(header)
;Find the line with the key
regex='^'+key+' *=' ;Regular expression to find the proper key
w=where(stregex(header,regex,/boolean,fold_case=fold_case),count)
lines=-1
if (count eq 0) then ret=0 else begin ;Get out if key not found
  w=w[(n_elements(sel) eq 1 ? 0>sel<(count-1) : count-1)] ;By default, last occurence is used if multiple found
  lines=w
  tmp=strtrim(strmid(header[w],strpos(header[w],'=')+1),2) ;Get rid of the key part
;Determine if value is scalar
  np1=strpos(tmp,'(')
  if (np1 ne 0) then begin
    ret=tmp
    ;If value is empty, continue reading from next line if cont is set
   if cont && strtrim(ret,2) eq '' then ret=strtrim(header[w+1],2)
  endif else begin
;Parse a vector
    np2=strpos(tmp,')')
;Determine if it ends on this same line
    if (np2 ne strlen(tmp)-1) then begin
;Continue getting the rest if the vector spans multiple lines
      repeat begin
        w++
        if (w eq nh) then begin
          print,'pp_getcubeheadervalue: Warning: value seems to be a truncated vector'
          break
        endif
        neq=strpos(header[w],'=')
        nq=strpos(header[w],'"')
        if (neq ge 0) && (nq ge 0) && (nq lt neq) then begin
          print,'pp_getcubeheadervalue: Warning: value seems to be a truncated vector'
          break
        endif
        tmp+=header[w]
        lines=[lines,w] 
      endrep until (strpos(header[w],')') eq (strlen(header[w])-1))
    endif
;Separate the fields in tmp to a string array (cannot use strsplit because ',' may be part of a quoted string)
    ret=pp_extractfields(strmid(tmp,1,strlen(tmp)-2))
  endelse
endelse
if (unquote) then begin ;Remove quotes
  q=["'",'"']
  l=strlen(ret)
  for j=0,n_elements(ret)-1 do begin
    for i=0,1 do begin
      nq1=strpos(ret[j],q[i])
      nq2=strpos(ret[j],q[i],/reverse_search)
      if ((nq1 eq 0) && (nq2 eq l[j]-1)) then begin
        ret[j]=strmid(ret[j],1,l[j]-2)
        break
      endif
    endfor
  endfor
endif
if (not_trimmed) then header=oldheader
return,ret
end
