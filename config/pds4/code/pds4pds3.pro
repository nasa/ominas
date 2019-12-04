FUNCTION PDS4PDS3,paramArr, toScreen=toScreen, outFile=outFile

;
; NAME:
;	PDS4PDS3
;
; PURPOSE:
;	The read_xml procedure will read PDS4 xml documents and output PDS3 
;	type labels.  This routine just completes the translation to PDS3.
;	It translate PDS4 terms into PDS3 terms using PDS_TRANSLATE, and then
;	makes a few more structural changes to get to PDS3 compliance.
;	ParamArr can be created with READ_XML.pro
;
; CATEGORY:
;	Datafile handling; PDS
;
; CALLING SEQUENCE:
;	out = read_xml(filename,paramsout=paramArr)
;
;	Result = PDS4PDS3(paramArr [,/toScreen,outFile=outFile] )
;
; INPUTS:
;	paramArr -  Label for starting PDS version, stringarr
;
; OUTPUTS:
;	paramArr - Label for ending PDS version, stringarr
;
; KEYWORDS:
;	toScreen - write paramArr to screen
;	outFile - if set to a filename, will save to that file
;
; PROCEDURES USED:
;	Uses PDS_TRANSLATE to do global substitutions, then makes specific structural changes
;	for going to PDS3.  This is an intermediate 
;	PDS_TRANSLATE, PARSE_PARAMETER, PDSPAR
;
; External Functions or Procedures
;	PDSPAR
;
; PACKAGE LOCATION:
;	       http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya [April 27, 2012].  Not yet complete.
;
;-
;-----------------------------------------------------------------

  ; Now translate all terms to PDS3
  paramArr = pds_translate(paramArr)

  ; pointpds.pro requires datafile has quotes (against convention)
  datafile = pdspar(paramArr,'^SPREADSHEET',index=index)
  paramArr[index] = '       ^SPREADSHEET = "'+datafile+'"'

  ; Display on screen if /toScreen
  IF KEYWORD_SET(toScreen) THEN $
	FOR i = 0, N_ELEMENTS(paramArr)-1 DO PRINT,paramArr[i]

  ; Save to a file if outFile keyword set to filename
  IF (KEYWORD_SET(outFile) EQ 1) THEN BEGIN
	OPENW, /GET_LUN, wunit, outFile
	FOR i = 0, N_ELEMENTS(paramArr)-1 DO PRINTF,wunit,paramArr[i]
	FREE_LUN,wunit
  ENDIF
  RETURN, paramArr
END ; FUNCTION PDS4PDS3
