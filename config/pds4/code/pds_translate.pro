FUNCTION PDS_TRANSLATE,paramArr
;=================================
;+
; NAME:
;       PDS_TRANSLATE
;
; PURPOSE:
;       Translate paramArr (label) by making substitutions for either keywords or values
;        across the entire array
;
; CATEGORY:
;       Datafile handling; PDS
;
; CALLING SEQUENCE:
;       paramArr3 = PDS_TRANSLATE(paramArr)
;
; INPUTS:
;       paramArr - A PDS like label (basically keyword = value) , string array
;
; OUTPUTS:
;       paramArr3 - PDS label after translating terms, (string array)
;
; KEYWORDS:
;       NONE 
;
; PROCEDURES USED:
;        PARSE_PARAMETER
;
; RESTRICTIONS:
;	Requires two files holding translation word pairs.  One for keyword to substitute the 
;	other for value terms to subsitute.  Format is "oldword = newword"
;
;	Example, 
;	pds4keysto3.txt has pairs of keywords (pds4 = pds3), and the file
;	pds4valsto3.txt has pairs of values.
;
; PACKAGE LOCATION:
;        http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya [April 27, 2012]
;
;-
;-----------------------------------------------------------------

  ; Exchange PDS4 keywords and values for PDS3 type 

  IF (N_PARAMS() Lt 1) THEN BEGIN
	PRINT, 'usage: PDS_TRANLATE,paramArr'
	RETURN, 0
  ENDIF
  ; We will return a copy of lable.
  paramArrpds = paramArr

  ; A long blank string is used for indentation
  blank = string(' ',format='(a80)')

  ; Open file with keyword equivalents
  OPENR,/get_lun,rdunit,'pds4keysto3.txt'
  param = ''
  REPEAT BEGIN
	READF,rdunit,param
	key = parse_parameter(param)
	; Have both keywords, now search and replace in certain paramArr lines
	FOR i = 0, N_ELEMENTS(paramArr)-1 DO BEGIN
		keyval = parse_parameter(paramArr[i], pos=pos)
		IF (keyval[0] EQ key[0]) THEN $
			paramArrpds[i] = STRMID(blank,0,pos)+key[1]+' = '+keyval[1]
	ENDFOR
  ENDREP UNTIL EOF(rdunit)
  FREE_LUN,rdunit

  ; Now repeat procedure for values that need to be exchanged
  OPENR,/get_lun,rdunit,'pds4valsto3.txt'
  REPEAT BEGIN
	READF,rdunit,param
	; Get pair of words to exchange
	vals = parse_parameter(param)
	; Now search and replace in certain paramArr lines
	FOR i = 0, N_ELEMENTS(paramArr)-1 DO BEGIN
		keyval = parse_parameter(paramArrpds[i], pos=pos)
		IF (keyval[1] EQ vals[0]) THEN $
			paramArrpds[i] = STRMID(blank,0,pos)+keyval[0]+' = '+vals[1]
	ENDFOR
  ENDREP UNTIL EOF(rdunit)

  FREE_LUN,rdunit
  RETURN,paramArrpds
END ; FUNCTION PDS_TRANSLATE
