;----------------------------------------------------------------------------------------
; NAME:
;	PDSPAR
; PURPOSE:
;	Obtain the value of a parameter in a PDS header
;
; CALLING SEQUENCE:
;	result = PDSPAR( lbl, name,[ abort, MVAL=, COUNT=, INDEX =])
; INPUTS:
;	Lbl =  PDS header array, (e.g. as returned by SXHREAD or READPDS)
;		string array, each element should have a length of 80
;		characters
;	Name = String name of the parameter to return.
;
; OPTIONAL INPUTS:
;	ABORT - string specifying that PDSPAR should do a RETALL
;		if a parameter is not found.  ABORT should contain
;		a string to be printed if the keyword parameter is not found.
;		If not supplied PDSPAR will return with a negative
;		!err if a keyword is not found.
;
; OUTPUTS:
;	result = value of parameter in header. If parameter is double
;		precision, float, long or string, the result is of that type.
;
;
; OPTIONAL OUTPUTS:
;	COUNT - Optional keyword to return a value equal to the number of
;		parameters found by PDSPAR, integer scalar
;	MVAL - 	Optional keyword to return the value of requested keyword
;		that exceeds the normal allowable string size that can be
;		printed by the PRINT function. The 'zeroth' record of MVAL-
;		MVAL(*,0) contains the number of following records that
;		contain meaningful information.
;
;	INDEX - Optional keyword to return an array of the line numbers
;		where the values being returned were found in the PDS label.
;
; SIDE EFFECTS:
;	Keyword COUNT returns the number of parameters found.
;	!err is set to -1 if parameter not found, 0 for a scalar
;	value returned.
;
;
; EXAMPLES:
;	Given a PDS header, h, return the values of the axis dimension
;	values. Then return the number of sample bits per pixel.
;
;	IDL> x_axis = pdspar( h ,' LINES')         ; Extract Xaxis value
;	IDL> y_axis = pdspar( h ,' LINE_SAMPLES')  ; Extract Yaxis value
;	IDL> bitpix = pdspar( h ,' SAMPLE_BITS')   ; Extract bits/pixel value
;
; PROCEDURE:
;	Each element of lbl is searched for a '=' and the part of each
;	that preceeds the '=' is saved in the variable 'keyword', with
;	any line that contains no '=' also saved in keyword. 'keyword'
;	is then searched for elements that exactly match Name, if none
;	are found then 'keyword' is searched for elements that contain Name.
;	If either search succeeds then the characters that follow the '='
;	in the matching lines are returned.
;
;	An error occurs if both above searches fail.
;
;	The values returned are converted to numeric value, if possible,
;	by the STR2NUM function.
;
; NOTE:
;
;	PDSPAR requires that the label being searched has records of
;	standard 80 byte length (or 81 bytes for UNIX stream files).
;
; MODIFICATION HISTORY:
;	Adapted by John D. Koch from SXPAR by DMS, July, 1994
;
;    12 May 2003, P. Khetarpal    Fixed the conversion of 10b into
;                                 string for search in lines 126 and 129.
;    13 Feb 2006  A. Cardesin     Modified to search for '=' (instead of ' = ')
;                                 (lines 106 and 133)
;    06 Aug 2008  P. Choganwala   Fixed "=" sign problem in Description field.
;    05 Jul 2008  P. Choganwala   Fixed to return multiple lines (Spanned
;                                 across more then one line) correctly in
;                                 case they are surrounded with '',{},().
;----------------------------------------------------------------------

;Added for 06 Aug 2008 Fix
function get_matching_char, ipchar
	CASE ipchar OF
	     '"': return,'"'
	     '(': return,')'
	     '{': return,'}'
	     '[': return,']'
	    ELSE: return,'"'
	ENDCASE
end

function PDSPAR, lbl, name, abort, MVAL=mvalue, COUNT=matches, INDEX = nfound

 params = N_params()
 if params LT 2 then begin
    print,'Syntax - result = pdspar(lbl,name [,abort,MVAL=,COUNT=,INDEX= ])'
    return, -1
 endif

 value = 0
 
 if params LE 2 then begin
    abort_return = 0
    abort = 'PDS Label'
 endif else begin
    abort_return = 1
 endelse
 
; if abort_return then On_error,1 else On_error,2

;Check for valid header

 s = size(lbl)		;Check header for proper attributes.
 if (s[0] NE 1) or (s[2] NE 7) then begin
    message,abort+' (first parameter) must be a string array'
 endif

;Copy name, make upper case  ;line100

 nam = strtrim(strupcase(name),2)

;Loop on lines of the header

;Modified A.Cardesin 2006Feb13: changed ' = ' into '='
 
 key_end = strpos(lbl,'=')			;find '=' in all lines of lbl
 r = size(key_end)
 stopper = r[r[r[0]-1]]
 keyword = strarr(stopper)
 for j = 0,stopper-1 do begin
     if key_end[j] LT 0 then keyword[j] = '*' $
     else keyword[j]=strtrim(strmid(lbl[j],0,key_end[j]),2)
 endfor

;Added for 05 Jul 2008 Fix
 nfound = where(keyword EQ "DESCRIPTION", matches)
 srch = '"'
 if matches GT 0 then begin
  for j = 0, matches - 1 do begin
    res1 = STRPOS(lbl[nfound[j]],srch)
    res2 = STRPOS(lbl[nfound[j]],srch,res1+1)
    if (res2 EQ -1) then begin
       start=nfound[j]+1
       while (STRPOS(lbl[start],srch) EQ -1) do begin
            keyword[start] = '*'
            start += 1
       endwhile
       keyword[start] = '*'
    endif
  endfor
 endif

 nfound = where(keyword EQ nam, matches) ; index where the keyword matches nam
 
 if matches EQ 0 then begin
    nfound = where(strpos(keyword,nam) GT -1,matches)
 endif

; Process string parameter and use STR2NUM to obtain numeric value

 if matches GT 0 then begin
    line = lbl[nfound]
    nfd = size(nfound)
    quitter = nfd[nfd[nfd[0]-1]]
    svalue = strarr(quitter)
    mvalue = strarr(quitter,100)
    value = svalue
    i = 0
    while i LT quitter do begin
          n = nfound[i]
          knd = key_end[n]
          retrn = strpos(line[i],string(10b))
          if retrn EQ -1 then retrn = 80

;Modified A.Cardesin 2006Feb13: knd+1 (for '=') instead of knd+2 (for ' = ')

          svalue[i] = strtrim(strmid(line[i],knd+1,retrn-knd-2),2)
          spot = strpos(svalue[i],string(10b))
          if spot GT 0 then svalue[i]=strtrim(strmid(svalue[i],0,spot-1),2)
      
          check = stregex(svalue[i],'["([{]')

          if check GT -1 then begin

	     char_start = stregex(svalue[i],'["([{]',/extract)
	     char_end = get_matching_char(char_start)

             k = n
      	     c=strpos(svalue[i],char_end,check+1)
             if c GT -1  then value[i]=strtrim(svalue[i],2) else begin
	        for a = 0, key_end[n]+1 do value[i]=value[i]+' '
	        value[i] = value[i] + svalue[i]
	     endelse
	     m = 0
	     m2 = 0
             while c LT 0 do begin
                   k = k+1
	           m = m+1
	           m2=fix(m/24)
                   if m2 EQ 0 then value[i]=value[i] + ' ' + strtrim(lbl[k],2) $
 	           else if m2 GT 0 then mvalue[i,m2]=mvalue[i,m2]+' '+strtrim(lbl[k],2) $
	           else print,'Illegal value of variable m2 ='+m2
	           c = strpos(lbl[k],char_end)
;	           if (c GT -1) then if(keyword[k+1] EQ '*') then c = -1
             endwhile
             mvalue[i,0]=fix(m2[0])

          endif else begin
	     value[i]=str2num(strtrim(svalue[i],2))
          endelse
	i = i + 1
    endwhile
    
 endif  else begin
   if abort_return then message,'Keyword '+nam+' not found in '+abort ;150
   !ERR = -1
 endelse

;	To print value and mvalue after running pdspar use:
;           print,value(*)
;           for d = 1,mvalue(*,0) do print,mvalue(*,d)
;	where '*' is any number valid for value(*)
 
 return,value

end
