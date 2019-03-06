;=============================================================================
;+
; NAME:
;	sxpar
;
;
; PURPOSE:
;	Obtains the value of a parameter in a FITS header.
;
;
; CATEGORY:
;	UTIL/FITS
;
;
; CALLING SEQUENCE:
;	result = sxpar(hdr, name [, abort])
;
;
; ARGUMENTS:
;  INPUT:
;	hdr:	FITS header array, (e.g. as returned by SXOPEN or READFITS)  
;		string array, each element should have a length of 80
;		characters.
;
;	name:	String name of the parameter to return.   If Name is of 
;		the form 'keyword*' then an array is returned containing 
;		values of keywordN where N is an integer.  The value
;		of keywordN will be placed in RESULT(N-1).  The data type 
;		of RESULT will be the type of the first valid match of keywordN 
;		found.
;
;	abort:	String specifying that SXPAR should do a RETALL
;		if a parameter is not found.  ABORT should contain
;		a string to be printed if the keyword parameter is not found.
;		If not supplied SXPAR will return with a negative
;		!err if a keyword is not found.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT:
;	count:	Returns a value equal to the number of parameters found by sxpar.
;
;
; RETURN:
;	Value of parameter in header.  If parameter is double precision,
;	floating, long or string, the result is of that type.  Apostrophes are
;	stripped from strings.  If the parameter is logical, 1 is returned for T,
;	and 0 is returned for F.  If Name was of form 'keyword*' then a vector of
;	values are returned.
;
;
; COMMON BLOCKS:
;	xx:	xx
;
;	xx:	xx
;
;
; SIDE EFFECTS:
;       Keyword COUNT returns the number of parameters found.
;	!err is set to -1 if parameter not found, 0 for a scalar
;	value returned.  If a vector is returned it is set to the
;	number of keyword matches found.
;
;       If a keyword occurs more than once in a header, a warning is given,
;       and the first occurence is used.
;
;
; RESTRICTIONS:
;	xx
;
;
; PROCEDURE:
;	The first 8 chacters of each element of Hdr are searched for a 
;       match to Name.  The value from the last 20 characters is returned.  
;       An error occurs if there is no parameter with the given name.
;       
;       If a numeric value has no decimal point it is returned as type
;       LONG.   If it contains more than 8 numerals, or contains the 
;       character 'D', then it is returned as type DOUBLE.  Otherwise
;       it is returned as type FLOAT
;
;
; EXAMPLE:
;        Given a FITS header, h, return the values of all the NAXISi values
;        into a vector.    Then place the history records into a string vector.
;
;         IDL> naxisi = sxpar( h ,'NAXIS*')         ; Extract NAXISi value
;         IDL> history = sxpar( h, 'HISTORY' )      ; Extract HISTORY records
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	sxaddpar, sxdelpar
;
;
; MODIFICATION HISTORY:
;	DMS, May, 1983, Written.
;   D. Lindler Jan 90 added ABORT input parameter
;   J. Isensee Jul,90 added COUNT keyword
;   W. Thompson, Feb. 1992, added support for FITS complex values.
;   W. Thompson, May 1992, corrected problem with HISTORY/COMMENT/blank
;			   keywords, and complex value error correction.
;	
;-
;=============================================================================
function SXPAR, hdr, name, abort, COUNT=matches   
 if N_params() LT 2 then begin
     print,'Syntax -     result =  sxpar( hdr, name, [abort, COUNT = ])
     return, -1
 endif 

 VALUE = 0
 if N_params() LE 2 then begin
      abort_return = 0
      abort = 'FITS Header'
 end else abort_return = 1
 if abort_return then On_error,1 else On_error,2

;       Check for valid header

  s = size(hdr)		;Check header for proper attributes.
  if ( s(0) NE 1 ) or ( s(2) NE 7 ) then $
	   message,'FITS Header (first parameter) must be a string array'

  nam = strtrim( strupcase(name) )	;Copy name, make upper case     

; Determine if name is of form 'keyword*'

   if strpos( nam, '*' ) EQ strlen( nam ) - 1 then begin    
	    nam = strmid( nam, 0, strlen( nam ) - 1)  
	    vector = 1	   		;Flag for vector output  
	    name_length = strlen(nam)  	;Length of name 
	    num_length = 8 - name_length 	;Max length of number portion  
	    if num_length LE 0 then  $ 
		  message, 'Keyword length must be 8 characters or less'
    endif else begin  
	 	while strlen(nam) LT 8 do nam = nam + ' ' ;Make 8 chars long
		vector = 0      
    endelse
;
; Loop on lines of the header 
;
 keyword = strmid( hdr, 0, 8)
 histnam = (nam eq 'HISTORY ') or (nam eq 'COMMENT ') or (nam eq '        ') 
 if vector then begin
           nfound = where(strpos(keyword,nam) GE 0, matches)
	   if ( matches GT 0 ) then begin
                   numst= strmid(hdr(nfound), name_length, num_length)
                   number = intarr(matches)-1
                   for i = 0, matches-1 do $
	            if strnumber( numst(i), num) then number(i) = num
                   igood = where(number GE 0, matches)
                   if matches GT 0 then begin
                        nfound = nfound(igood) & number = number(igood)
                   endif
           endif

 endif else begin

       nfound = where(keyword EQ nam, matches)
       if not histnam then if matches GT 1 then message,$
         'WARNING- Keyword '+NAM +'located more than once in '+abort,/inform
 endelse   

; Process string parameter 

 if matches GT 0 then begin
  line = hdr(nfound)
  svalue = strtrim( strmid(line,9,70),2)
  if histnam then $
	value = strtrim(strmid(line,8,71),2) else for i = 0,matches-1 do begin
      if ( strmid(svalue(i),0,1) EQ "'" ) then begin   ;Is it a string?
	          test = strmid( svalue(i),1,strlen( svalue(i) )-1)
		  next_char = 0
		  value = '' 
          NEXT_APOST:
		  endap = strpos(test, "'", next_char)      ;Ending apostrophe  
	     	  if endap LT 0 then $ 
			    MESSAGE,'Value of '+name+' invalid in '+abort
	  	  value = value + strmid( test, next_char, endap-next_char )  
;
;  Test to see if the next character is also an apostrophe.  If so, then the
;  string isn't completed yet.  Apostrophes in the text string are signalled as
;  two apostrophes in a row.
;
          	 if strmid( test, endap+1, 1) EQ "'" then begin    
	     	    value = value + "'"
	      	    next_char = endap+2         
		    goto, NEXT_APOST
          	 endif      
;
; Process non-string value  
;
          endif else begin
	       value = strtrim( strmid(line(i), 10, 20), 2)   ;Extract value    
	       if ( value EQ 'T' ) then value = 1 else $
	       if ( value EQ 'F' ) then value = 0 else begin
;
;  Test to see if a complex number.  It's not a complex number of columns 31-50
;  are blank, or if a slash character occurs in columns 11-50.  Otherwise, try
;  to interpret columns 31-50 as a number.
;
	    	value2 = strtrim( strmid(line(i),30,20), 2) ;Imaginary part
                if value2 EQ '' then goto, NOT_COMPLEX
		if strpos( strmid( line(i),10,40), path_sep()) GE 0 then $  ; Spitale
                       goto,NOT_COMPLEX
		On_ioerror, NOT_COMPLEX
	   	value2 = float(value2)
		value = complex(value,value2)
		goto, GOT_VALUE
;
;  Not a complex number.  Decide if it is a floating point, double precision,
;  or integer number.
;
NOT_COMPLEX:
		On_ioerror, GOT_VALUE
		  if strpos(value,'.') GE 0 then begin      
		      if ( strpos(value,'D') GT 0 ) or $
			 ( strlen(value) GE 8 ) then value = double(value) $
						else value = float(value)
		       END ELSE value = long(value)
;
GOT_VALUE:
		On_IOerror, NULL
		endelse
	     endelse; if c eq apost
;
;  Add to vector if required
;
	 if vector then begin
               maxnum = max(number)
	       if ( i EQ 0 ) then begin
                     sz_value = size(value)
                     result = make_array( maxnum, type=sz_value(1), /NOZERO)
	       endif 
               result( number(i)-1 ) =  value
	  endif
  endfor

  if vector then begin
         !ERR = matches     
         return, result
  endif else !ERR = 0

endif  else  begin    
     if abort_return then message,'Keyword '+nam+' not found in '+abort
     !ERR = -1
endelse     

return, value       

END                 
