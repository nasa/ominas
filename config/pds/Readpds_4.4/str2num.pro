function STR2NUM, svalue, TYPE = type
;
; NAME:
;	STR2NUM
; PURPOSE:
;	Return the numeric value of string, if possible; other wise
;	return the input string or number.
; CALLING SEQUENCE:
;	result = STR2NUM(svalue)
; INPUT:
;	svalue = a scalar string to be converted to its numeric value or 
;		a numeric value to be converted to its 'smallest' form.
; OPTIONAL KEYWORD INPUT:
;	TYPE - Optional keyword to return the integer scalar that
;		corresponds to the IDL type of the result.
; OUTPUT:
;	Function value = numeric value of input string, or unaltered string
;		if numeric conversion is not possible.
; EXAMPLE:
;	Given a scalar string, svalue = '123', return the numeric value 
;	of svalue or svalue, itself, if numeric conversion not possible.
;	IDL> x = strnum('123')		;convert '123' to its numeric value
;
; PROCEDURE:
;	The input string, svalue, is first tested to see if it is a pds
;	time value by searching for ':' or 'T' in the string; if so it
;	is returned unchanged as a string. The string is then tested to 
;	see if it could be made numeric, by attempting to convert it to 
;	a double precision number. If that succeeds, then further tests 
;	are done to determine what type of numeric value is best used, 
;	and svalue is converted to numeric value. If it fails then svalue 
;	is returned as entered. 
;
;	If a numeric value has a ',' then it is a complex number and
;	is returned as such.
;
;	If a numeric value has a decimal point it is returned as type
;	DOUBLE or FLOAT. If it contains more than 8 numerals, it is
;	returned as type DOUBLE, other wise it is returned as type FLOAT.
;
;	If it contains no decimal point then it could be any numeric type.
;	If the string contains the character 'D', or an absolute numeric 
;	value > 2Billion then it is returned as type DOUBLE. If it contains 
;	the character 'E' it is returned as type FLOAT. If the absolute 
;	value is less than 32767 it is type FLOAT, unless it is between 
;	0 and 255, then it is type BYTE. Otherwise it is type LONG.
;
; HISTORY:
;	Written by John D. Koch, July, 1994
;
;	27 July 1999, M. Barker: fixed bug that converted a date in format of
;				 1991-05-12 to 1991, so that if a '-' is 
;				 detected and neither 'e' or 'E' are detected,
;				 the value is left as a string.
; 
; 13 Jan 2010, smartinez: fixed to return string value when leading
;                         zeros present.
;
;----------------------------------------------------------------------

 if ( N_PARAMS() NE 1)then begin
     print,'Syntax - result =str2num(svalue,[ TYPE = type])
     return, -1
 endif 

 value = 0

;
;	Check that svalue is a scalar
;
 s = size(svalue)			
 if ( s(0) NE 0 ) then message,'svalue must be a scalar '
 type = 7
;
;	trap value as a string if it is a time expression
;
 if (strpos(svalue,':')GE 0) or (strpos(svalue,'T')GE 0) then goto,THE_CASE
;
;	27 July 1999, M. Barker:
;	trap value as a string if it may be a date expression
;
 if strpos((no_white=strcompress(svalue,/remove_all)),'-') GT 1 then begin
   if strpos(no_white,'e') EQ -1 and strpos(no_white,'E') EQ -1 $
   then goto,THE_CASE
 endif
;
;	
;

 l = strlen(svalue)
 temp = svalue
 ON_IOERROR,THE_CASE		; goto case if conversion on next line fails
 temp = double(temp)
 c=strpos(svalue,',')
 if(c GT -1) and (s(1) EQ 7)then begin
   temp = complex(temp,float(strmid(svalue,c+1,l-c)))
   type=6
 endif
 atemp = abs(temp)
 if type NE 6 then if(strpos(svalue,'.') GT 0) then begin   
   type = 4   
   if(strlen(svalue) GE 8) then type = 5
 endif else begin
   if(atemp GT 32767)then type = 3  else type = 2
   if(temp GT -1) and (temp LT 256)then type = 1
   if(strpos(svalue,'E') GT 0) then type = 4
   if(atemp GT 2000000000) then type = 5 
 endelse
 if(strpos(svalue,'D') GT 0) then type = 5
 ON_IOERROR,NULL
 THE_CASE:
	CASE type OF
	    7 : value=svalue
            6 : value=temp
            5 : value=temp
       	    4 : value=float(temp)
       	    3 : value=long(temp)
            2 : value=fix(temp)
       	    1 : value=byte(temp)
	  else: message,'Flag error in STR2NUM,no corresponding type'
	ENDCASE    
	
	;; If leading zeros present, then return string
  if (type eq 3 or type eq 2 or type eq 1) then begin
    leading0 = 0
    for i=0,strlen(svalue) do if (STRMID(svalue,i,1) eq '0') then leading0++ else break
    if (leading0 gt 1) then value = svalue
  endif

 return,value
 end

