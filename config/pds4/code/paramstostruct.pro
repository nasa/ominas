FUNCTION PARAMSTOSTRUCT, paramarray, commentChar=commentChar

;+
; NAME:
;	paramsToStruct
;
; PURPOSE:
;	Converts a parameter string array (eg, header for FITS files) into
;	an IDL Structure where each keyword is a tag of a structure and
;	each of these structures contain a value and a comment. The values
;	should by datatyped (float, int, string, etc) correctly.  
;	Logical T is transformed to 1byte and F to 0byte.
;	Does not work on PDS labels because it requires unique keynames 
;	and OBJECT and END_OBJECT can be repeated.
;
; CATEGORY:
;	Datafile handling; PDS; FITS
;
; CALLING SEQUENCE:
;	struct = paramsToStruct(paramArray,commentChar=commentChar)
;
; INPUTS:
;	paramArr - A string consisting of 'key = value'.  Value can have 
;	spaces. Comments (which describe the keyvalue) are on the same line and 
;	after the value and start with the commentChar character.
;	(eg, '   keyword = 17.3   / A keyword with floating point value')
;
; OUTPUTS:
;	struct - A structure in which each keyword is a tag holding a structure.
;	Each of these structure hold a value and a comment.
;
; KEYWORDS:
;	commentChar - Character that begins the comment on each line.  Default is '/'.
;
; PROCEDURES USED:
;	PARSE_PARAMETER
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [June 27, 2012] ;
;-
;-----------------------------------------------------------------


IF ~KEYWORD_SET(commentChar) THEN commentChar = '/'
nparams = N_ELEMENTS(paramarray)
executestring = ''
FOR i = 0, nparams-1 DO BEGIN
	; This function should provide 3-element array [keyword,value,comment]
        ; Remove Carriage return at the end of value
	par = paramarray[i]
	pos = STREGEX(par,string(10b)+'$') 
        IF  (pos NE -1) THEN  par = strmid(par,0,pos)
	pos = STREGEX(par,string(13b)+'$') 
        IF  (pos NE -1) THEN  par = strmid(par,0,pos)
        ; Remove blanks
        par = strtrim(par,2) 
	; If it is now an empty string go to next line
	if (par eq '') then continue

	keyval = parse_parameter(par,commentChar=commentChar)

	; Reached the END?
	IF (keyval[0] EQ 'END') THEN BREAK

	; Replace invalid IDL characters with underscore
	keyval[0] = IDL_VALIDNAME(keyval[0],/convert_all)

	; Here we use IDL's on-the-fly datatyping to handle the datatype
	IF (size(keyval,/dimension) GE 2) THEN BEGIN
		IF (keyval[1] EQ 'T') THEN keyval[1] = '1B'
		IF (keyval[1] EQ 'F') THEN keyval[1] = '0B'
		IF (keyval[1] EQ '') THEN keyval[1] = "''"
;		Result = EXECUTE('keyval1 = '+keyval[1])
	;	if (Result eq 0) then print,' Problem with keyword ',keyval[0]
	ENDIF

	; Create structures for each keyword with value and comment if there.
	CASE size(keyval,/dimension)  OF
	   3: Result = EXECUTE(keyval[0]+'_valstruct = {value : keyval[1], comment : keyval[2]}')
	   2: Result = EXECUTE(keyval[0]+'_valstruct = {value : keyval[1]}')
	   1: Result = EXECUTE(keyval[0]+'_valstruct = {value : ''}')
	ENDCASE

	executestring = executestring+','+keyval[0]+' : '+keyval[0]+'_valstruct'
ENDFOR
; Remove extra comma at the beginning
executestring = STRMID(executestring,1)

; Finally create the header structure
Result = EXECUTE('struct = {'+executestring+'}')

RETURN, struct
END
