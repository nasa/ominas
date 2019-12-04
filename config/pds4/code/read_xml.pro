FUNCTION READ_XML,filename, toScreen=toScreen, outFile=outFile, $
	paramsOut=paramsOut,validation=validation
;+
; NAME:
;	READ_XML
;
; PURPOSE:
;	READ an XML document file into IDL (Interactive Data Language, ITT).  
;	Output is either an IDL structure, 
;	or an array of parameters (key/value pairs).
;	This function reads the file and parses the XML document into a DOM 
;	(Document Object Model) object or IDLffXMLDOMDocument.
;	It passes oDoc to XML2IDL which walks through the nodes creating the 
;	structure or paramArr.  See XML2IDL about the handling of differences 
;	between the object models, DOM vs IDL Structure.
;	
; CATEGORY:
;	Datafile handling; XML

; CALLING SEQUENCE:
;	Result = READ_XML(filename, [/toScreen,outFile=outFile,/paramsOut])
;
; INPUTS:
;	filename  - name of XML file to read (string)
;
; OUTPUTS:
;	Result - Either an IDL Structure or a parameter Array (paramArr, 
;	string array)
;	If paramsOut is not set, then it is a structure.
;	
; KEYWORDS:
;	toScreen - Write paramArr or the structure's tags to screen
;
;	outFile - If set to a filename, will save paramArr or tags to that file
;
;	paramsOut - If set to 1, Result is paramArr instead of structure.
;	
;	validation - If set to 1, schema_checking or DTD validation occurs.
;                    Schema or DTD need to be on local disk
;
; PROCEDURES USED:
;	PARSE_PARAMETER, PDSPAR, XML2IDL, GET_TAGS
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya/U. of Maryland [April 27, 2012]
;	Modified to allow for single and double quotes within a text node.Ed Shaya [May 29, 2012]
;	Removed path variable.  Now filename should contain path if needed ES [Dec 3, 2013]
;	Fixed a bug which left off an element that had tried but failed to append to 
;	array of elements of the same name. [ES/Nov 17, 2014]
;	Added  validation flag. [ES/July 8, 2015]
;-
;-----------------------------------------------------------------

  IF (N_PARAMS() LT 1) THEN BEGIN
	PRINT, 'usage: Result = READ_XML(filename, toScreen=toScreen, outFile=outFile,paramsOut=paramsOut)'
	RETURN,0
  ENDIF
 
  IF ~KEYWORD_SET(toScreen) THEN toScreen = 0
  IF ~KEYWORD_SET(outFile) THEN outFile = ''
  IF ~KEYWORD_SET(paramsOut) THEN paramsOut = 0
  IF ~KEYWORD_SET(validation) THEN validation = 0

  ; Need to seed paramArr with a first element
  IF (paramsOut EQ 0) THEN paramArr = ['-1'] ELSE paramArr = ['1']

  ; CATCH, Error_status 
 
  ;This statement begins the error handler: 
  ;   IF Error_status NE 0 THEN BEGIN 
  ;      PRINT, 'Error index: ', Error_status 
  ;      PRINT, 'Error message: ', !ERROR_STATE.MSG 
  ;      RETURN, 0
  ;   ENDIF 

  ; Parse XML file into a DOM object 
  ;PRINT, 'There may be a problem reading the dtd from us-vo.org.  Try changing to'
  ;PRINT, '<!DOCTYPE VOTABLE SYSTEM "http://cdsweb.u-strasbg.fr/xml/VOTable.dtd">'

  print,filename
  oDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=filename, schema_checking=validation,$
      /exclude_ignorable_whitespace,validation_mode=validation,/expand_entity_references)

  ; Build structure or paramArr
  XML2IDL, oDoc, struct=struct, paramArr=paramArr

  ; clean up
  OBJ_DESTROY, oDoc

  IF (paramsOut EQ 1) THEN BEGIN
	; Add version line
	paramArr = ['  PDS_VERSION_ID = PDS3',paramArr]

	; Add END statement
	paramArr = [paramArr,'   END']
  ENDIF

  ; Display on screen if /toScreen 
  IF (toScreen NE 0) THEN BEGIN
	   ; Display paramsOut
	   IF (paramsOut NE 0) THEN $
		    FOR i = 0, N_ELEMENTS(paramArr)-1 DO PRINT,paramArr[i]

	   ; Display structure tags 
	   IF (paramsOut EQ 0) THEN BEGIN
		    tags = get_tags(struct)
		    FOR i = 0, N_ELEMENTS(tags)-1 DO PRINT,tags[i]
	   ENDIF
  ENDIF

  ; Save to a file if outFile key set to filename
  IF (outFile NE '') THEN BEGIN
    OPENW, /GET_LUN, wunit, outFile

	  ; Print paramsOut
    IF (paramsOut NE 0) THEN $
      FOR i = 0, N_ELEMENTS(paramArr)-1 DO PRINTF,wunit,paramArr[i]

	  ; Print tags 
	  IF (paramsOut EQ 0) THEN BEGIN
		  tags = get_tags(struct)
      FOR i = 0, N_ELEMENTS(tags)-1 DO PRINTF,wunit,tags[i]
    ENDIF
	  FREE_LUN,wunit
  ENDIF

  IF (KEYWORD_SET(paramsOut)) THEN $
	   RETURN, paramArr $
  ELSE $
	   RETURN, struct

END ; FUNCTION READ_XML
