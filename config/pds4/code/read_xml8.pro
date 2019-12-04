FUNCTION READ_XML8,filename, outFile=outFile, validation = validation
;+
; NAME:
;	READ_XML8	
;
; PURPOSE:
;	READ an XML document file into IDL (Interactive Data Language, ITT).  
;	This function is specifically for IDL version 8 and above because
;	it uses both OrderedHashes and Lists which were introduced in version 8.
;	Output is an IDL Ordered Hash with Lists for repeating elements.
;	This function reads the file and parses the XML document into a DOM
;	(Document Object Model) object or IDLffXMLDOMDocument.
;	It passes oDoc to XML2IDL8 which walks through the nodes creating the hash.  
;
; CATEGORY:
;	Datafile handling; XML

; CALLING SEQUENCE:
;	Result = READ_XML8(filename, [ outFile=outFile, validation = validation ])
;
; INPUTS:
;	filename  - name of XML file to read (string)
;
; OUTPUTS:
;	Result is a hash of hashes or lists that represents the XML file.  
;	One can access the various nodes
;	by indexing into it, like this:           
;	IDL> print, hash[rootname,elname,childname,'_text']
;          
;	If there are siblings with the same name, then they are pulled together
;	in a list which is indexed by number:
;
;	IDL> i++
;	IDL> print, hash[rootname,repeatedname,i,childname,'_text'];	
;          
;	To see what the childnames are for element elnameN:
;	
;	IDL> print, hash[rootname,elname,...,elnameN].Keys()
;	
; KEYWORDS:
;	outFile - If set to a filename, will save pretty printout to that file
;
;	validation - Turns on validation of xml file
;			The Schema or DTD need to on local disk.
;	
; PROCEDURES USED:
;	XML2IDL8
;	
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Nov 5, 2013]
;	Removed path variable.  Now filename should contain path if needed. ES/Dec 3, 2013.
;	Switched to ordered hash so elements stay in order.  Now using
;	XML2IDL8.pro.  ES/Oct 10, 2014.
;	Removed use of prettyhash (toscreen) since IDL now does this
;	natively when you enter the hash name ES/Oct 10, 2014
;-
;-----------------------------------------------------------------

  IF (N_PARAMS() LT 1) THEN BEGIN
	   PRINT, 'usage: Result = READ_XML8(filename, [ outFile=outFile, validation = validation ])'
	   RETURN,0
  ENDIF
  IF ~KEYWORD_SET(outFile) THEN outFile = ''
  IF ~KEYWORD_SET(validation) THEN validation = 0
  
  ;CATCH, Error_status 
  ;This statement begins the error handler: 
  ;IF Error_status NE 0 THEN BEGIN 
  ;   PRINT, 'Error index: ', Error_status 
   ;  PRINT, 'Error message: ', !ERROR_STATE.MSG 
   ;  RETURN, 0
  ;ENDIF 

  ; Parse XML file into a DOM object 
  oDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=filename,$
      /exclude_ignorable_whitespace,schema_checking=validation,validation_mode=validation,/expand_entity_references)

  ; Build structure
  hash = xml2idl8(oDoc)

  ; clean up
  OBJ_DESTROY, oDoc

  ; Save to a file if outFile key set to filename
  IF (outFile NE '') THEN BEGIN     
     OPENW, /GET_LUN, wunit, outFile
        printf,wunit,/implied_print,hash
     FREE_LUN,wunit
  ENDIF

	   RETURN, hash

END ; FUNCTION READ_XML8
