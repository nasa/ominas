FUNCTION readfile,file,filter=filter
;+
; NAME
;	READFILE
;
; PURPOSE
;	Read a text file into a string array
;
; CALLING SEQUENCE:
;	return = readfile([file,filter=filter])
;               
; INPUTS
;	file - name of file to read
;
;	filter - string to be used to filter files when using pickfile widget to select file.
;
; PACKAGE LOCATION
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY
;	Written by Ed Shaya (UMd) [May 3, 2012]
;-
;--------------
ON_ERROR,1

IF ~KEYWORD_SET(file) THEN $
	file = DIALOG_PICKFILE(filter=filter)

IF (file eq '') THEN BEGIN
	MESSAGE,'readfile: No file selected'
ENDIF

OPENR, lun, file, /GET_LUN
; Read one line at a time, saving the result into array
array = ''
line = ''

WHILE NOT EOF(lun) DO BEGIN 
  READF, lun, line 
  array = [array, line]
ENDWHILE

; Close the file and free the file unit
FREE_LUN, lun
RETURN, array
END
