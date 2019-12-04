FUNCTION CREATE_TABLESTRUC, tags, datatype, repetitions, field_length, tabletype
;-----------------------------------------------------------------
;+
; NAME: 
;	CREATE_TABLESTRUC
;
; PURPOSE:
;	Creates a structure to hold a table.
;
; CATEGORY:  
;	PDS Processing
;
; CALLING SEQUENCE:
;	Result =  CREATE_TABLESTRUC(tags, datatype, repetitions, field_length, tabletype)
;
; INPUTS:
;	tags - Names of the fields of the table. Expects all tags are IDL valid variable 
;	names and are unique.
;	datatype - PDS standard names for field datatypes.
;	repetitions - (Nfields,3) dimensioned integer array.  For each field,there is an 
;             (N,M,L) to provide the dimension of array.  If field is just an 
;             array then it will be (N,0,0). (N,M,0) for 2-d array. (N,M,L) for 3-d array
;	field_length - Length of each cell in the field.
;	tabletype -  This just needs to be set to "BINARY", if table is binary type
;
; OUTPUTS:
;	Result -  An IDL Structure to hold a table.
;
; KEYWORDS: 
;	None.
;
; PACKAGE LOCATION:  
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Nov. 7, 2013]
;	Added ASCII_DATE DOY, YMD, and UTC types (March 26, 2015, EJS).
;	Change ASCII_Numeric_Base2 to be read into strings and ASCII_Numeric_Base8 
;	  and _Base16 to be read into Longs.  (March 28, 2015, EJS).
; 	Fixed bug in reading ASCII array within a Binary Table (ES/July 9, 2015)
;
;-
;-----------------------------------------------------------------
values = ""
Nfields = N_ELEMENTS(tags)
IF (tabletype NE 'BINARY') THEN BEGIN ; For ASCII tables
  FOR i = 0, Nfields -1 DO BEGIN
    repet = repetitions[i,*]
    IF (TOTAL(repet[0:2] EQ [1,0,0]) EQ 3) THEN BEGIN
      CASE datatype[i] OF
         'ASCII_Boolean':                   values += ', 0B '
         'ASCII_Integer':                   values += ', 0L '
         'ASCII_NonNegative_Integer':       values += ', 0L '
         'ASCII_Numeric_Base2':             values += ', "A" '
         'ASCII_Numeric_Base8':             values += ", 0L "
         'ASCII_Numeric_Base16':            values += ", 0L "
         'ASCII_Real':                      values += ', 0.0D '
	 'ASCII_Date_DOY':                  values += ', "1999-365" '
	 'ASCII_Date_YMD':                  values += ', "1999-12-31" '
	 'ASCII_Date_Time_DOY':             values += ', "1999-365:23:59:59.999" '
	 'ASCII_Date_Time_YMD':             values += ', "1999-12-31:23:59:59.999" '
	 'ASCII_Date_Time_DOY_UTC':         values += ', "1999-365:23:59:59.999Z" '
	 'ASCII_Date_Time_YMD_UTC':         values += ', "1999-12-31:23:59:59.999Z" '
         ELSE:                              values += ', "A" '
      
      ENDCASE

    ENDIF ELSE BEGIN
      indx = [0,1,2]
      IF repet[1] EQ 0 AND repet[2] EQ 0 THEN indx = 0       ; Dim is 1  
      IF repet[2] EQ 0 AND repet[1] NE 0 THEN indx = [0,1]   ; Dim is 2 
      reps = '('+STRJOIN(STRTRIM(STRING(repet[indx]),1),",",/single)+') ' 

      CASE datatype[i] OF
      'ASCII_Boolean':                   values += ', 0B '
      'ASCII_Integer':                   values += ', LONARR'+reps
      'ASCII_NonNegative_Integer':       values += ', LONARR'+reps
      'ASCII_Real':                      values += ', DBLARR'+reps
      'ASCII_Numeric_Base2':             values += ', STRARR'+reps
      'ASCII_Numeric_Base8':             values += ', LONARR'+reps
      'ASCII_Numeric_Base16':            values += ', LONARR'+reps
      ELSE:                              values += ', STRARR'+reps
       
      ENDCASE
    ENDELSE ; end array or scalar ascii input
  ENDFOR ; end loop over fields

; Binary
ENDIF ELSE BEGIN ; Now handle binary table input
   FOR i = 0, Nfields -1 DO BEGIN
    repet = repetitions[i,*]
    IF (TOTAL(repet[0:2] EQ [1,0,0]) EQ 3) THEN BEGIN   ; SCALARS
    CASE datatype[i] OF
      'SignedByte':         values += ', 0B '
      'SignedMSB2':         values += ', 0S '
      'SignedMSB4':         values += ', 0L '
      'SignedMSB8':         values += ', 0LL '
      'UnsignedByte':       values += ', 0B '
      'UnsignedMSB2':       values += ', 0U '
      'UnsignedMSB4':       values += ', 0L '
      'UnsignedMSB8':       values += ', 0ULL '
      'SignedLSB2':         values += ', 0S '
      'SignedLSB4':         values += ', 0L '
      'SignedLSB8':         values += ', 0LL '
      'UnsignedLSB2':       values += ', 0U '
      'UnsignedLSB4':       values += ', 0L '
      'UnsignedLSB8':       values += ', 0ULL '
      'IEEE754MSBSingle':   values += ', 0.0 '
      'IEEE754MSBDouble':   values += ', 0.0D0 '
      'ComplexMSB8':        values += ', COMPLEX(1.0, 0.0) ' 
      'ComplexMSB16':       values += ', DCOMPLEX(1.0D0, 0.0D0) '
      'IEEE754LSBDouble':   values += ', 0.0D0 '
      'IEEE754LSBSingle':   values += ', 0.0 '

      ELSE :  BEGIN
        values += ', "' + STRJOIN(REPLICATE("a",field_length[i])) + '" '
        
        END
    ENDCASE   
    ENDIF ELSE BEGIN ; Now handle arrays
      IF repet[2] EQ 0 THEN repet = repet[0:1]   ; Array is less than 3 dim
      IF repet[1] NE 0 THEN $             ; Get string (N,M,L) or (N,M) or (N)
        reps = '('+ STRJOIN(STRTRIM(STRING(repet[*]),1),",",/single)+') ' $
      ELSE $
        reps = '('+ STRTRIM(STRING(repet[0]),1)+') '



      CASE datatype[i] OF

	'ASCII_String':			values += ', ASCIIARR_'
	'ASCII_Date_DOY':		values += ', ASCIIARR_'
	'ASCII_Date_YMD':		values += ', ASCIIARR_'
	'ASCII_Date_Time_DOY':		values += ', ASCIIARR_'
	'ASCII_Date_Time_YMD':		values += ', ASCIIARR_'
	'ASCII_Date_Time_DOY_UTC':	values += ', ASCIIARR_'
	'ASCII_Date_Time_YMD_UTC':	values += ', ASCIIARR_'

      'SignedByte':       values += ', BYTARR'+reps
      'SignedMSB2':       values += ', INTARR'+reps
      'SignedMSB4':       values += ', LONARR'+reps
      'SignedMSB8':       values += ', LON64ARR'+reps
      'UnsignedByte':     values += ', BYTARR'+reps
      'UnsignedMSB2':     values += ', UINTARR'+reps
      'UnsignedMSB4':     values += ', ULONARR'+reps
      'UnsignedMSB8':     values += ', ULON64ARR'+reps
      'IEEE754MSBSingle': values += ', FLTARR'+reps
      'IEEE754MSBDouble': values += ', DBLARR'+reps
      'ComplexMSB8':      values += ', COMPLEXARR'+reps
      'ComplexMSB16':     values += ', DCOMPLEXARR'+reps
      
      'SignedLSB2':       values += ', INTARR'+reps
      'SignedLSB4':       values += ', LONARR'+reps
      'SignedLSB8':       values += ', LON64ARR'+reps
      'UnsignedLSB2':     values += ', UINTARR'+reps
      'UnsignedLSB4':     values += ', ULONARR'+reps
      'UnsignedLSB8':     values += ', ULON64ARR'+reps
      'IEEE754LSBSingle': values += ', FLTARR'+reps
      'IEEE754LSBDouble': values += ', DBLARR'+reps
      'ComplexLSB8':      values += ', COMPLEXARR'+reps
      'ComplexLSB16':     values += ', DCOMPLEXARR'+reps
       ELSE: BEGIN
        PRINT, 'create_tablestruc: datatype not yet handled: ', datatype[i]
        STOP
       END
      ENDCASE

      ; For ASCII need to form array with correct length strings
      IF STRMID(datatype[i],0,5) EQ 'ASCII' THEN BEGIN
	        ; This makes a string of length = field_length
        	asciiv = STRJOIN(REPLICATE("a",field_length[i])) 
		si = strtrim(string(i),2)
		; This does a = STRARR(N,M)
		result = EXECUTE('asciiarr_' + si + ' = STRARR'+reps)
		; This does a[*] = asciiv
		result = EXECUTE('asciiarr_' + si +'[*] = asciiv')
		; Add _N to make values unique.
		values += si+' '
	ENDIF

      ENDELSE ; end array or scalar binary field
  ENDFOR ; end loop over fields 
ENDELSE ; end binary or not
values0 = values   
; Remove excess comma at the beginning of values string
values = STRMID(values, 1)
result = EXECUTE("recordstruc = CREATE_STRUCT(tags, "+ values + ")")
IF (result NE 1) THEN BEGIN
	PRINT,'create_tablestruc: Error creating structure for table '
	PRINT,"recordstruc = CREATE_STRUCT(tags, "+ values + ")"
        STOP
ENDIF
RETURN,recordstruc
END
