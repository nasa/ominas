FUNCTION READ_VOTABLE8,filename, metadata=metadata
;+
; NAME:
;	READ_VOTABLE8
;
; PURPOSE:
;	READ a VOTable.xml document into IDL (Interactive Data Language, ITT).
;	It uses IDL Version 8 and above routines for reading the XML.  
;	This function reads the file and parses the XML document 
;	It outputs a structure where each tag is an array holding a column (field).
;	It optionally outputs a structure with all of the metadata in the
;	VOTable (fieldname, units, description, datatype).  This will be a hash. 
;	It also optionally outputs a 2D string array holding the table values.
;	In metadata, items with text info, such as description, the text is in
;	the child element _text.
;	Missing floats and doubles use IDL NaN !Values and integers get -9999...
;
; CATEGORY:
;	Datafile handling; XML, Virtual Observatory
;
; CALLING SEQUENCE:
;	table_struct = READ_VOTABLE8(filename,metadata=metadata)
;
; INPUTS:
;	filename  - Name of VOTable.xml file to read (string)
;
; OUTPUTS:
;	table_struct - A structure where each tag is an array holding a column from the table.
;	If there is more than one table in the VOTable, then they are all there
;	and tagged TABLE1, TABLE2, etc.
;
; KEYWORDS:
;	metadata -  an IDL hash holding all of the info in the VOTable.xml 
;
;
; PROCEDURES USED:
;	READ_XML8
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Ed Shaya / U of Maryland [November 24, 2013]
;
;-
;-----------------------------------------------------------------

metadata=read_xml8(filename)

tables = metadata['VOTABLE','RESOURCE','TABLE']
IF (N_ELEMENTS(tables) EQ 0) THEN BEGIN
	PRINT,'read_votable8: No tables found'
	PRINT,'Halting'
	STOP
ENDIF

IF ISA(tables,'LIST') THEN ntables = N_ELEMENTS(tables) ELSE ntables = 1
executestring = ''
IF (ntables GT 1) THEN tablen = strarr(ntables)
FOR tbl = 0, ntables - 1 DO BEGIN
	; table_array comes right off all of the _text nodes.
	;table_array = gettagsbyname(metadata,$
	  IF (ntables GT 1) THEN table = tables[tbl] ELSE table = tables
		tabledata = table['DATA','TABLEDATA']
		tr = tabledata['TR']
		nrows = N_ELEMENTS(tr)
		fields = table['FIELD']
		nfields = N_ELEMENTS(fields)
		td0 = tr[0,'TD']
		IF (nfields NE N_ELEMENTS(td0)) THEN $
		  PRINT, 'read_votable8: Warning: Number of fields is not equal to number of TD elements'
		 table_array = strarr(nfields,nrows)
		 for i = 0, nfields - 1 do for j=0,nrows-1 do table_array[i,j]=tr[j,'TD',i,'_text']
	IF (N_ELEMENTS(tabledata) EQ 0) THEN BEGIN
		PRINT,'read_votable: No table data found'
		PRINT,'Halting'
		STOP
	ENDIF

	; Gather info on the fields of the table
	fieldnames = STRARR(nfields)
	FOR i=0,nfields-1 do fieldnames[i] = fields[i,'name']
	
	fieldnames = IDL_VALIDNAME(fieldnames , /CONVERT_ALL , /CONVERT_SPACES)

  datatypes = STRARR(nfields)
  FOR i=0,nfields-1 do datatypes[i] = fields[i,'datatype']

	IF (N_ELEMENTS(table_array) EQ 0) THEN BEGIN
		PRINT,'read_votable: No tables found'
		PRINT,'Halting'
		STOP
	ENDIF

	; Create string to execute that creates table_stuct.
	fieldstring = ''
	FOR i = 0, N_ELEMENTS(fieldnames)-1 DO BEGIN
	  field = REFORM(table_array[i,*])
	  whnull = WHERE(field EQ '',nnull)
	  CASE datatypes[i] OF
	    'boolean':
	    'bit':
	    'unicodeChar':
	    'floatComplex': field = COMPLEX(field)
	    'doubleComplex': field = COMPLEX(field,/double)
	    'char':
	    'short': BEGIN
	      field = FIX(field)
	      IF (nnull GT 0) THEN field[whnull]= -9999
	    END
	    'int': BEGIN
	      field = LONG(field)
	      IF (nnull GT 0) THEN field[whnull]= -99999999
	    END
	    'long': BEGIN
	      field = LONG64(field)
	      IF (nnull GT 0) THEN field[whnull]= -99999999999
	    END
	    'float': BEGIN
	      field = FLOAT(field)
	      IF (nnull GT 0) THEN field[whnull]= !VALUES.F_NAN
	    END
	    'double': BEGIN
	      field = DOUBLE(field)
	      IF (nnull GT 0) THEN field[whnull]= !VALUES.D_NAN
	    END
	    'unsignedByte': field = BYTE(field)
	    ELSE: BEGIN
	      PRINT,'read_votable: This datatype not handled ',datatypes[i]
	      PRINT,'Halting'
	      STOP
	    END
	  ENDCASE
    result = EXECUTE(fieldnames[i]+' = field')
    fieldstring = fieldstring + ','+fieldnames[i]+':'+fieldnames[i]
	ENDFOR
	fieldstring = STRMID(fieldstring,1)

	Result =  EXECUTE('table_struct  = {'+fieldstring+'}')
	IF (ntables GT 1) THEN BEGIN
		tablen[tbl] = 'TABLE'+STRTRIM(STRING(tbl+1),2)
		;Create individual structures for each table: 
		;eg TABLE2_struct = {TABLE2:table_struct}
		Result = EXECUTE(tablen[tbl] + '_struct = table_struct')
		executestring = executestring+','+tablen[tbl]+' : '+tablen[tbl]+'_struct' 
	ENDIF
ENDFOR

;  If multiple tables, create structure  holding all of the tables
IF (ntables GT 1) THEN BEGIN
		get_date,date
		Result = EXECUTE('table_struct = {Created: date'+executestring+'}')
ENDIF
metadata = metadata['VOTABLE']
RETURN, table_struct
END
