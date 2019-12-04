;------------------------------------------------
;+
; NAME:
;	LABEL2HASH 
;
; PURPOSE:
;	Read in a PDS3 label into an ordered hash.
;Category:
;	Datafile Handling: XML, PDS
;
; CALLING SEQUENCE:
;	Return =  label2hash(file)
;	  Or 
;	Return = label2hash() 
;
; INPUTS:
;	file - filename of .lbl file.  If no input then a Widget opens to help select lbl file
;	
; Outputs:
;	Return is ordered hash of label keywords and values
; Keywords:
;	None
;
; Example: 
;	IDL> file = 'dbcp.lbl'
;	IDL> hh=label2hash(file) 
;	IDL> print,hh
;	PDS_VERSION_ID: PDS3
;	RECORD_TYPE: FIXED_LENGTH
;	RECORD_BYTES: 240
;	FILE_RECORDS: 2653
;	^TABLE: DBCP.TAB
;	DATA_SET_ID: EAR-C-COMPIL-5-DB-COMET-POLARIMETRY-V1.0
;	PRODUCT_NAME: DATABASE OF COMET POLARIMETRY
;	PRODUCT_ID: DBCP_TAB
;	INSTRUMENT_HOST_NAME: PUBLISHED LITERATURE
;	INSTRUMENT_NAME: COMPILATION
;	TARGET_NAME: COMET
;	TARGET_TYPE: COMET
;	START_TIME: 1940-11-26
;	STOP_TIME: 2005-07-03
;	PRODUCT_CREATION_TIME: 2006-07-05
;	TABLELIST: LIST  <ID=39901  NELEMENTS=1>
;
;
;	IDL> hh['TABLELIST',0,'COLUMNLIST',4].keys()
;[
;    "COLUMN_NUMBER",
;    "NAME",
;    "START_BYTE",
;    "BYTES",
;    "DATA_TYPE",
;    "FORMAT",
;    "DESCRIPTION",
;    "END_OBJECT"
;]
;
;          
; Procedures Used:
;	rmelement.pro, readfile.pro
;
;PACKAGE LOCATION: 
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; Modification History
;	Written by Ed Shaya / U. of Maryland [JULY 11, 2014]
;	Substantial rewrite to keep carriage returns in a long
;	multiline value.  Now, the label is converted into an IDL LIST
;	and then that list is turned into an IDL ORDEREDHASH. [5/6/2015]
;-
;--------------------------------
 
FUNCTION label2hash_proc,lbl,i
; Main function is below this one.
; This processes the list made from the label and creates
; a hash.  The word before the equalsign is the key of the hash
; For each object there is a list made (as in HEADER becomes
; HEADERLIST, TABLE becomes TABLELIST).  This is because there may
; be more than one of each OBJECT and a hash cannot repeat a key.
; Usually, you run this with the second parameter, i=0.  It is 
; needed because when the program recurses (COLUMNLIST is inside of 
; TABLELIST) it needs to know, when it returns from a recurse, where to
; continue on.

nobjecthash = HASH()
hh = ORDEREDHASH()
ncards = N_ELEMENTS(lbl)
REPEAT BEGIN
	i++
	; key will be whatever is before equal sign
	; For a label that spans several lines, need
	; to use just the first line for key
	pos = STRPOS(lbl[i],'=')
	IF (pos[0] EQ -1) THEN BEGIN
		PRINT,'label2hash: no "=" on line ',i
		STOP
	ENDIF
	IF ISA(lbl[i],/ARRAY) THEN BEGIN
	     key = STRTRIM(STRMID(lbl[i,0],0,pos[0]),2)
	     value = STRTRIM(STRMID(lbl[i,0],pos[0]+1),2)
	     value = [value,lbl[i,1:*]]
	ENDIF ELSE BEGIN
	     key = STRTRIM(STRMID(lbl[i],0,pos[0]),2)
	     value = STRTRIM(STRMID(lbl[i],pos[0]+1),2)
         ENDELSE
	; Remove quotes
	FOR j = 0,N_ELEMENTS(lbl[i])-1 DO BEGIN
	    IF (STRMID(value[j],0,1) EQ '"') THEN $
		    value[j]= STRMID(value[j],1)
	    IF (STRMID(value[j],0,1,/reverse) EQ '"') THEN $
		    value[j]= STRMID(value[j],0,STRLEN(value[j])-1)
	ENDFOR
	; Remove lines that just had a quote and are now null
	IF value[0] EQ '' THEN value = value[1:*]
	IF value[-1] EQ '' THEN value = value[0:-2]

	IF (key EQ 'OBJECT') THEN BEGIN
	   keys_n = nobjecthash.keys()
	   ; Recursive call to this function to handle label Objects
	   Result = EXECUTE(value + ' = label2hash_proc(lbl,i)')
	   ; If first of this object then set count to 1 and create
	   ; a list of this object type
	   IF (N_ELEMENTS(keys_n) EQ 0 || WHERE(keys_n EQ value) EQ -1) THEN BEGIN
	   	nobjecthash[value] = 1
		Result = EXECUTE(value+'LIST = LIST('+value+')')
	   ; If not first then add one to count and add hash to list of this object type
	   ENDIF ELSE BEGIN
	   	nobjecthash[value] = nobjecthash[value] + 1
		Result = EXECUTE(value+'LIST.Add,'+value)
	   ENDELSE
	   key = value + 'LIST'
	   Result = EXECUTE('hh["' +value+'LIST" ] = '+value+'LIST') 
	ENDIF ELSE BEGIN; OBJECT
		hh[key] = value
	ENDELSE
ENDREP UNTIL (i GE ncards-1 || key EQ 'END_OBJECT')
RETURN,hh
END

FUNCTION label2hash,lblfile
; This is the main function

IF KEYWORD_SET(lblfile) THEN $
	lbl = readfile(lblfile,filter='*.lbl') $
ELSE $
	lbl=readfile(filter='*.lbl')

; TRIM spaces off lbl
lbl = STRTRIM(lbl,2)
; Remove blank strings
lbl = lbl[WHERE(lbl NE '')]

lbl = rmelement(lbl,WHERE(lbl EQ 'END'))

; Search for second '"' sign to end label.
quotes = STRMATCH(lbl,'"')
nn = N_ELEMENTS(lbl)
lbllist = list()
FOR i = 0, nn - 1 DO BEGIN
   q1 = strpos(lbl[i],'"')
   q2 = strpos(lbl[i],'"',/reverse_search)
   ; If q1=q2, then there is only one quote on the line
   ; Look for next line with a quote
   IF (q1 NE -1 AND q1 EQ q2) THEN BEGIN
        endq = WHERE(quotes[i+1:*] eq 1)
        endq = endq[0]+1 
	tmp = ''
	lbllist.Add,lbl[i:i+endq]
	i = i + endq
   ENDIF ELSE lbllist.Add,lbl[i]
ENDFOR
hh = label2hash_proc(lbllist,0)
RETURN,hh
END
