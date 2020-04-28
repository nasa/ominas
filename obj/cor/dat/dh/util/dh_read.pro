;=============================================================================
;+-+
; NAME:
;	dh_read
;
;
; PURPOSE:
;	Reads a detached header file.
;
;
; CATEGORY:
;	UTIL/DH
;
;
; CALLING SEQUENCE:
;	result = dh_read(filename)
;
;
; ARGUMENTS:
;  INPUT:
;	filename:	Name of file to be read.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	buflen:		Number of lines to allocate at a time.  Default is 1000.
;			The routine is faster with larger values of buflen, but
;			less memory efficient.
;
;  OUTPUT: 
;	status:		0 if file found, -1 if not.
;
;
; RETURN:
;	String array in which each line is a line of the detached header.
;	a blank detached header is created and returned if the file is 
;	not found.  In that case, status is set to -1.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	dh_write
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/1998
;	
;-
;=============================================================================
function dh_read, filename, buflen=buflen, status=status

 status = -1

 ;----------------------------
 ; open file
 ;----------------------------
 openr, unit, filename, /get_lun, error=error
 if(error NE 0) then $
  begin
   nv_message, verb=0.2, 'Blank detached header created.', /continue
   return, dh_create()
  end

 status = 0
 nv_message, verb=0.1, 'Reading ' + filename + '.', /continue


 ;----------------------------
 ; read file
 ;----------------------------
 if(NOT keyword_set(buflen)) then buflen=1000
 line=''
 dh=strarr(buflen)
 i=0

 while(NOT eof(unit)) do $
  begin
   readf, unit, line
   dh[i]=line
   i=i+1

   if(i mod buflen EQ 0) then $
    begin
     dh = [dh,strarr(buflen)]
    end
  end

 if(i GT 2) then dh=dh[0:i]


 ;----------------------------
 ; clean up
 ;----------------------------
 close, unit
 free_lun, unit



 return, dh
end
;=============================================================================
