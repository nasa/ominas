FUNCTION CONVERT_CODES,codein
;-----------------------------------------------------------------
;+
; NAME:  
;	CONVERT_CODES
;
; PURPOSE: 
;	Convert C-printf-Style format code to Fortran format code
;
; CATEGORY: 
;	PDS processing
;
; CALLING SEQUENCE:
;	result = convert_codes(codein)
;
; INPUTS:
;	codein -  a string or string array of C-style format codes.
;
; OUTPUTS:
;	Returns a string or string array of Fortran style format codes 
;	(for use in IDL readf and printf statements).
;
; PROCEDURES USED: 
;	Built-in, only.
;
; PACKAGE LOCATION: 
; 	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Nov. 7, 2013]
;
;-
;-----------------------------------------------------------------

   ; If first character is %-sign, remove it
   ncodes = N_ELEMENTS(codein) 
   result = STRARR(ncodes)
   FOR i = 0, ncodes-1 DO BEGIN
	leftJustify = ''
	plusPrefix = ''
	code = codein[i]
	; Remove '%' as first character
	IF (STRPOS(code,'%') EQ 0) THEN code = STRMID(code,1)
	; Last character determines datatype
	datatype = STRMID(code,0,/reverse_offset)
	; Remove last character from code
	code = STRMID(code,0,strlen(code)-1)
	; Check first two characters for "+-" flags
	; Keep track of them, but remove from code
	FOR J = 0, 1 DO BEGIN
		IF (STRPOS(code,'-') EQ 0) THEN BEGIN
			leftJustify = '-'
			code = STRMID(code,1)
		ENDIF
		IF (STRPOS(code,'+') EQ 0) THEN BEGIN
			plusPrefix = '+'
			code = STRMID(code,1)
		ENDIF
	ENDFOR
	CASE STRLOWCASE(datatype) OF
	     'f': datatype = 'F'
	     's': datatype = 'A'
	     'd': datatype = 'I'
	     'e': datatype = 'E'
	     'i': datatype = 'I'
	     'g': datatype = 'G'
	     'b': datatype = 'B'
	     'o': datatype = 'O'
	     'x': datatype = 'Z'
	     'z': datatype = 'Z'
	     ELSE: print, 'convert_codes: datatype not yet handled ', datatype
	ENDCASE
	; For character type (A), take numbers after the decimal place
	IF (DATATYPE EQ 'A') THEN code = STRMID(code,STRPOS(code,'.')+1)
	result[i] = datatype + plusPrefix + leftJustify + code
   ENDFOR

   RETURN, result
END
