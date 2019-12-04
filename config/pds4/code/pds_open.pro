FUNCTION PDS_OPEN, XFILE, offset, readonly=readonly, COMPRESS=COMPRESS, $
                 SILENT = Silent, ERRMSG= ERRMSG, PIPE= pipe
;+
; NAME:
;	PDS_OPEN
;
; PURPOSE:
;	Opens and return the unit number of a file positioned at a specified 
;	offset in bytes
;
; EXPLANATION:
;	A normal file is just opened (readonly, if specified) and skips to an 
;	offset.  For a compressed file, it can determine the type of uncompression
;	and sets up a pipe to uncompress the stream.
;
; CALLING SEQUENCE:
;	unit=PDS_OPEN(FILE,OFFSET,READONLY=,COMPRESS=,PIPE=,ERRMSG= ,SILENT=)
;            
;
; INPUT PARAMETERS:
;	FILE    = file name, scalar string
;
;	OFFSET  = offset from the beginning of the file to start read or write
;
; RETURNS:
;	Unit number of file or -1 if an error is detected.
;
; OPTIONAL INPUT KEYWORD PARAMETER:
;	COMPRESS - If this keyword is set and non-zero, then treat
;	the file as compressed.  If 1 assume a gzipped file.
;	and use IDLs internal decompression facility.    For Unix 
;	compressed or bzip2 compressed files spawn off a process to 
;	decompress and use its output as the stream.  If the 
;	keyword is not 1, then use its value as a string giving the 
;	command needed for decompression.
;
;	READONLY - If this keyword is set and non-zero, then OPENR rather 
;	than OPENU will be used to open the file.    Note that
;	compressed files are always set to /READONLY
;
;	SILENT -  If set, then suppress any messages about invalid characters.
;
; OPTIONAL OUTPUT KEYWORDS:
;	ERRMSG  = If this keyword is present, then any error messages will be
;	returned to the user in this parameter rather than
;	depending on the MESSAGE routine in IDL.  If no errors are
;	encountered, then a null string is returned.
;
;	PIPE - If set to 1, then the file was opened with a pipe
;	rather than with the OPENR command.    This is only required 
;	when reading a bzip or Unix compressed file.   
;
; SIDE EFFECTS:
;	Opens and returns a file unit.
;      
; PROCEDURE:
;	Open the appropriate file, or spawn a command and intercept the output.
;	Call MRD_SKIP to get to the appropriate extension.
;      
; PROCEDURE CALLS:
;	MRD_SKIP() (from astron package)
;      
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Derived from William Thompson's FXFINDEND routine.
;	Modified by T.McGlynn, 1994 - 1999 as MXPOSIT
;	Modified by  W. Landsman 23-Apr-1997   - 2009 as MXPOSIT 
;	Rewritten by Ed Shaya for PDS data / U. of Maryland Sept-2013 for use in PDS4
;-

   COMPILE_OPT idl2  

   ; Check the number of parameters.
   IF N_PARAMS() LT 2 THEN BEGIN 
      PRINT,'SYNTAX:  UNIT = FXPOSIT(FILE, offset, /Readonly,' + $
	          'ERRMSG= , /SILENT, compress=prog )'
      RETURN,-1
   ENDIF
   PRINTERR = NOT ARG_PRESENT(ERRMSG)
   ERRMSG = ''
   PIPE = 0

   IF xfile[0] NE '' THEN $
             file = FILE_SEARCH(xfile, count=count)         

   IF count EQ 0 THEN BEGIN
   	errmsg = 'Specified File not found ' + xfile[0]
   	IF printerr THEN message,errmsg,/con 
   	RETURN, -1   ; Don't print anything out, just report an error
   ENDIF    
        
   file = file[0]
   unit = -1
   glun = 1
 
   ;  Check if this is a compressed file.
   ucmprs = ' '
   IF KEYWORD_SET(compress) THEN BEGIN
   	help,compress
   	IF strcompress(string(compress),/remo) eq '1' THEN compress = 'gunzip'
   	ucmprs = compress;
   ENDIF ELSE BEGIN        
      len = STRLEN(file)
      IF len GT 3 THEN $
         tail = STRLOWCASE(STRMID(file, len-3, 3))  $
         ELSE $
            tail = ' '
      IF STRMID(tail,1,2) EQ '.z' THEN $
         ucmprs = 'uncompress'   $
            ELSE IF (tail EQ '.gz' or tail EQ 'ftz') THEN $
              ucmprs = 'gunzip'       $
                 ELSE IF (tail EQ 'bz2') THEN $
	            ucmprs = 'bunzip2'     	    
   ENDELSE

   ; Handle compressed files which are always opened for Read only.
   IF ucmprs EQ 'gunzip' THEN BEGIN	        
       OPENR, unit, file, /compress, GET_LUN=glun, ERROR = error     
       IF error NE 0 THEN BEGIN
           IF printerr THEN  PRINT,!error_state.msg $
                  ELSE errmsg = !error_state.msg 
           RETURN,-1
       ENDIF
   ENDIF ELSE BEGIN
	   IF (ucmprs NE ' ') THEN BEGIN  ; Anything but gunzip
              SPAWN, [ucmprs,'-c',file], unit=unit, /noshell
              pipe = 1
           ENDIF ELSE BEGIN ; No compression
       	      ; Go to the start of the file.
              IF KEYWORD_SET(readonly) THEN $
                OPENR, unit, file, get_lun=glun, error = error $
                   ELSE $
                     OPENU, unit, file, get_lun=glun, error = error
              IF error NE 0 THEN BEGIN
              	IF printerr THEN  PRINT,!error_state.msg $
                  ELSE errmsg = !error_state.msg 
                RETURN,-1
              ENDIF
           ENDELSE
   ENDELSE
   IF (offset GT 0) THEN  mrd_skip, unit,offset
   RETURN, unit
END
