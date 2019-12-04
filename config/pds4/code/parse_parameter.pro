FUNCTION PARSE_PARAMETER, line, pos=pos, commentChar=commentChar

;+
; NAME:
;       PARSE_PARAMETER
;
; PURPOSE:
;	Given a string from a parameter/header ('key = value'), returns key and 
;	value of a parameter as two element array by basically splitting on an 
;	equal sign. If commentChar is set to the delimiter for start of a 
;	comment, then it returns a 3 element array [key, value, comment].
;	Keyword "pos" returns position of beginning of key.
;	If there is no equal sign, then it returns [strtrim(line,2),''] and 
;	pos = -1.
;
; CATEGORY:
;	Datafile handling; PDS
;
; CALLING SEQUENCE: 
;	keyval = PARSE_PARAMETER(line, pos=pos, commentChar=commentChar)
;
; INPUTS:
;	line - A string consisting of 'key = value'.  Value can have spaces.
;
; OUTPUTS:
;	keyval -  2 element array with [key,value] as strings or 3 element 
;
;	array, if commentChar keyword is set, with [key,value,comment]
;
; KEYWORDS:
;	pos - position of first character of key in paramArr 
;
;	commentChar - character that begins a comment or description
;
; PROCEDURES USED:
;	IDL built-in procedures
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [April 27, 2012]
;
;-
;-----------------------------------------------------------------


  IF (N_PARAMS() Lt 1) THEN BEGIN
	PRINT, 'usage: keyval = PARSE_PARAMETER(line, pos=pos)'
	RETURN, 0
  ENDIF

  ; Split on equal sign
  keyval = STRSPLIT(line,'=',/extract,count=count,/preserve_null)

  IF (count EQ 1) THEN BEGIN
	keyval = [STRTRIM(line,2),'']
	pos = -1
  ENDIF ELSE BEGIN
	;  Fix if there equal signs in the comments section
        IF (count GT 2) THEN keyval = [keyval[0],STRJOIN(keyval[1:*],'=')]
	; Split on commentChar if it was set.
	; keyval becomes 3 elements long.
  	IF (KEYWORD_SET(commentChar)) THEN BEGIN
	  valcomment = STRSPLIT(keyval[1],commentChar,/extract,/preserve_null,count=count)
	  IF (count GT 1) THEN $
	  	keyval = [keyval[0],valcomment[0],valcomment[1]]
	ENDIF
	; Trim off spaces
	keyval = STRTRIM(keyval,2)
	; Locate start of key, if pos is set.
        IF (ARG_PRESENT(POS)) THEN pos = STRPOS(line,keyval[0])
  ENDELSE
  RETURN, keyval
END ; FUNCTION PARSE_PARAMETER
