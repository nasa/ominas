FUNCTION READ_VOTABLE,filename, metadata=metadata
;+
; NAME:
;	READ_VOTABLE
;
; PURPOSE:
;	READ a VOTable.xml document into IDL (Interactive Data Language, ITT).  
;	This function reads the file and parses the XML document 
;	It outputs a structure where each tag is an array holding a column
;	(field).
;	It optionally outputs a structure with all of the metadata in the
;	VOTable (fieldname, units, description, datatype) 
;	It also optionally outputs a 2D string array holding the table values.
;	In metadata, items with text info, such as description, the text is in
;	the child element _text.
;
; CATEGORY:
;	Datafile handling; XML, Virtual Observatory
;
; CALLING SEQUENCE:
;	table_struct = READ_VOTABLE(filename,metadata=metadata)
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
;	metadata -  an IDL structure holding all of the info in the VOTable.xml 
;
;
; PROCEDURES USED:
;	READ_XML, XML2IDL, GET_TAGS
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Ed Shaya / U of Maryland [July 19, 2012]
;	Added datatypes (bit, int, boolean) and increased size for long.  Ed Shaya (Nov 8, 2013)
;	Nov 24 Fixed a bug for empty elements
;	And for these added NaNs for float and double and large negative number for int, long, long64
;	
;-
;-----------------------------------------------------------------

metadata=read_xml(filename)

settags = get_tags(metadata)
tables = gettagsbyname(metadata,'\.TABLE(__[0-9]*)?$',settags=settags)
IF (N_ELEMENTS(tables) EQ 0) THEN BEGIN
	PRINT,'read_votable: No tables found'
	PRINT,'Halting'
	STOP
ENDIF

ntables = N_ELEMENTS(tables)
executestring = ''
IF (ntables GT 1) THEN tablen = strarr(ntables)
FOR tbl = 0, ntables - 1 DO BEGIN
	; table_array comes right off all of the _text nodes.
	table_array = gettagsbyname(metadata,$
		tables[tbl]+'.data.tabledata.tr(__[0-9]*)?.td(__[0-9]*)?._text',$
		/getvalues,settags=settags)
	IF (N_ELEMENTS(table_array) EQ 0) THEN BEGIN
		PRINT,'read_votable: No table data found'
		PRINT,'Halting'
		STOP
	ENDIF

	; Gather info on the fields of the table
	fieldnames = gettagsbyname(metadata,$
		tables[tbl]+'.FIELD(__[0-9]*)?.name',/getvalues,settags=settags) 
	IF (N_ELEMENTS(fieldnames) EQ 0) THEN BEGIN
		PRINT,'read_votable: No fieldnames found'
		PRINT,'Halting'
		STOP
	ENDIF
	
	fieldnames = IDL_VALIDNAME(fieldnames , /CONVERT_ALL , /CONVERT_SPACES)

	datatypes = gettagsbyname(metadata,$
		tables[tbl]+'.FIELD(__[0-9]*)?.datatype',/getvalues,settags=settags)
	IF (N_ELEMENTS(datatypes) EQ 0) THEN BEGIN
		PRINT,'read_votable: No datatypes found'
		PRINT,'Halting'
		STOP
	ENDIF
	IF (N_ELEMENTS(table_array) EQ 0) THEN BEGIN
		PRINT,'read_votable: No tables found'
		PRINT,'Halting'
		STOP
	ENDIF

	; Create string to execute that creates table_stuct.
	fieldstring = ''
	FOR i = 0, N_ELEMENTS(fieldnames)-1 DO BEGIN
	    field = reform(table_array[i,*])
	    whnull = WHERE(field EQ '',nnull)
   		CASE datatypes[i] OF
   	    'boolean':  
   	    'bit':  
   	    'unicodeChar': 
   	    'floatComplex': field = complex(field)
        'doubleComplex': field = complex(field,/double)
	      'char': 
	 	    'short': BEGIN
	 	           field = fix(field) 
	 	           IF (nnull GT 0) THEN field[whnull]= -9999
	              END
	 	    'int': BEGIN
	 	         field = long(field)
	 	         IF (nnull GT 0) THEN field[whnull]= -99999999
	 	       END
	      'long': BEGIN
	             field = long64(field)
	             IF (nnull GT 0) THEN field[whnull]= -99999999999
	           END
	 	    'float': BEGIN
	 	             field = float(field)
	 	             IF (nnull GT 0) THEN field[whnull]= !VALUES.F_NAN
	 	             END
		    'double': BEGIN
		            field = double(field)
		            IF (nnull GT 0) THEN field[whnull]= !VALUES.D_NAN
		          END
		    'unsignedByte': field = byte(field)
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
metadata = metadata.votable
RETURN, table_struct
END




