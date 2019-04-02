;=============================================================================
;+-+
; NAME:
;	read_fits
;
;
; PURPOSE:
;	Reads a FITS file into IDL data and optionally header variables.
;
;
; CATEGORY:
;	UTIL/FITS
;
;
; CALLING SEQUENCE:
;	result = read_fits(filename, [ header ])
;
;
; ARGUMENTS:
;  INPUT:
;	filename:	String containing the name of the file to be read.
;
;  OUTPUT:
;	header:		String array containing the header from the FITS file.
;
;
; KEYWORDS:
;  INPUT:
;	NOSCALE:	If present and non-zero, then the ouput data will not be
;			scaled using the optional BSCALE and BZERO keywords in
;			the FITS header.   Default is to scale.
;
;	SILENT:		Normally, READFITS will display the size the array at
;			the terminal.  The SILENT keyword will suppress this
;
;	NaNVALUE:	This scalar is only needed on Vax architectures.   It 
;			specifying the value to translate any IEEE "not a
;			number" values in the FITS data array.   It is needed
;			because the Vax does not recognize the "not a number"
;			convention.
;
;	EXTEN_NO:	Scalar integer specify the FITS extension to read.  For
;			example, specify EXTEN = 1 or /EXTEN to read the first 
;			FITS extension.    Extensions are read using recursive
;			calls to READFITS.
;
;	POINT_LUN:	Position (in bytes) in the FITS file at which to start
;			reading.   Useful if READFITS is called by another
;			procedure which needs to directly read a FITS extension.
;			Should always be a multiple of 2880.
;
;	STARTROW:	This keyword only applies when reading a FITS extension
;			It specifies the row (scalar integer) of the extension
;			table at which to begin reading. Useful when one does
;			not want to read the entire table.
;
;	NUMROW:		This keyword only applies when reading a FITS extension. 
;			If specifies the number of rows (scalar integer) of the 
;			extension table to read.   Useful when one does not want
;			to read the entire table.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	FITS data array constructed from designated record.
;
;
; RESTRICTIONS:
;     (1)	Cannot handle random group FITS
;     (2)       User's with versions of IDL before 2.2.1 should remove the
;               call to the TEMPORARY function near the end of the program
;
;
; EXAMPLE:
;	Read a FITS file TEST.FITS into an IDL image array, IM and FITS 
;       header array, H.   Do not scale the data with BSCALE and BZERO.
;
;              IDL> im = READFITS( 'TEST.FITS', h, /NOSCALE)
;
;       If the file contain a FITS extension, it could be read with
;
;              IDL> tab = READFITS( 'TEST.FITS', htab, /EXTEN )
;
;       To read only rows 100-149 of the FITS extension,
;
;              IDL> tab = READFITS( 'TEST.FITS', htab, /EXTEN, 
;                                    STARTR=100, NUMR = 50 )
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	write_fits
;
;
; MODIFICATION HISTORY:
;       MODIFIED, Wayne Landsman  October, 1991
;                Reset BSCALE and BZERO after using them
;       Added call to TEMPORARY function to speed processing     Feb-92
;       Added a check for fixed record length file  under VMS    Jun-92
;       Added STARTROW and NUMROW keywords for FITS tables       Jul-92
;	Spitale; Jan 1998 - added xdr conversions, changed name
;	                    from 'readfits' to 'read_fits'
;	
;-
;=============================================================================
function read_fits, filename, header, NOSCALE = noscale, NaNvalue = NaNvalue, $
		   SILENT = silent, EXTEN_NO = exten_no, NUMROW = numrow, $
                   POINTLUN = pointlun, STARTROW = startrow, nax=nax, type=IDL_type
  On_error,2                    ;Return to user
;
; Check for filename input
;
   if N_params() LT 1 then begin		
      print,'Syntax - im = READFITS( filename, [ h, /NOSCALE, /SILENT, '
      print,'                 NaNValue = ,EXTEN_NO =, STARTROW = , NUMROW = ] )'
      return, -1
   endif

   VAX = !VERSION.ARCH EQ "vax"
   Little_endian = (!VERSION.ARCH EQ "mipsel") or  $
                   (!VERSION.ARCH EQ '386i') or $
                   (!VERSION.ARCH EQ '386' )
   silent = keyword__set( SILENT )
   if not keyword__set( EXTEN_NO ) then exten_no = 0
;
; Open file and read header information
;
         
  	openr, unit, filename, /GET_LUN, /BLOCK
        if !VERSION.OS EQ 'vms' then begin
            file = fstat(unit)
            if file.rec_len EQ 0 then $
                 message,'WARNING - ' + strupcase(filename) + $
                  ' is not a fixed record length file',/CONT
        endif

        if keyword__set( POINTLUN) then point_lun, unit, pointlun else $
                                       pointlun = 0
;
      	hdr = bytarr( 80, 36, /NOZERO )
        if eof( unit ) then message, $
              'ERROR - EOF encountered while reading FITS header'
        readu, unit, hdr
        header = string( hdr > 32b )
        endline = where( strmid(header,0,8) EQ 'END     ', Nend )
        if Nend GT 0 then header = header( 0:endline(0) ) 
;
        while Nend EQ 0 do begin
        if eof( unit ) then message, $
              'ERROR - EOF encountered while reading FITS header'
        readu, unit, hdr
        hdr1 = string( hdr > 32b )
        endline = where( strmid(hdr1,0,8) EQ 'END     ', Nend )
        if Nend GT 0 then hdr1 = hdr1( 0:endline(0) ) 
        header = [header, hdr1 ]
        endwhile
;
; Get parameter values

Naxis = sxpar( header,'NAXIS' )

bitpix = sxpar( header,'BITPIX')
if !ERR EQ -1 then message, $
    'ERROR - FITS header missing required BITPIX keyword'

 case BITPIX of 
	   8:	IDL_type = 1          ; Byte
	  16:	IDL_type = 2          ; Integer*2
	  32:	IDL_type = 3          ; Integer*4
	 -32:   IDL_type = 4          ; Real*4
         -64:   IDL_type = 5          ; Real*8
        else:   message,'ERROR - Illegal value of BITPIX (= ' +  $
                               strtrim(bitpix,2) + ') in FITS header'
  endcase     

; Check for dummy extension header

if Naxis GT 0 then begin 
      Nax = sxpar( header,'NAXIS*' )	  ;Read NAXES
      nbytes = nax(0) * abs( BITPIX ) / 8
      if naxis GT 1 then for i = 2, naxis do nbytes = nbytes*nax(i-1)

endif else nbytes = 0

        if pointlun EQ 0 then begin 
          extend = sxpar( header, 'EXTEND') 
   	  if !ERR EQ -1 then extend = 0
          if not ( SILENT) then begin
          if (exten_no EQ 0) then message, $
               'File may contain FITS extensions',/INF  $
          else if not EXTEND  then message, $
               'ERROR - EXTEND keyword not found in primary header',/CON
          endif
        endif

    if keyword__set( EXTEN_NO ) then  begin
           nrec = nbytes / 2880
           if nbytes GT nrec*2880L then nrec = fix( nrec + 1) else $
                  nrec = fix( nrec)
           point_lun, -unit, pointlun          ;Current position
           pointlun = pointlun + nrec*2880l     ;Next FITS extension
           free_lun, unit
;           im = READFITS( filename, header, POINTLUN = pointlun, $  ; JNS 6/98
           im = READ_FITS( filename, header, POINTLUN = pointlun, $  ; JNS 6/98
                   NUMROW = numrow, EXTEN = exten_no - 1, STARTROW = startrow)
           return, im
        endif                  

if nbytes EQ 0 then if not SILENT then $
 	message,"FITS header has NAXIS or NAXISi = 0,  no data array read'

; Check for FITS extensions, GROUPS
;
 groups = sxpar( header,' GROUPS' ) 
 if groups then MESSAGE,'WARNING - FITS file contains random GROUPS', /CON

; If an extension, did user specify row to start reading, or number of rows
; to read?

   if not keyword__set(STARTROW) then startrow = 0
   if not keyword__set(NUMROW) then $
         if naxis GE 2 then numrow = nax(1) else numrow = 0
   if (pointlun GT 0) and ((startrow NE 0) or (numrow NE 0)) then begin
        nax(1) = nax(1) - startrow    
        nax(1) = nax(1) < numrow
        sxaddpar,header,'NAXIS2',nax(1)
        point_lun, -unit, pointlun          ;Current position
        pointlun = pointlun + startrow*nax(0)      ;Next FITS extension
        point_lun,unit,pointlun
    endif

  if not (SILENT) then begin   ;Print size of array being read
         if pointlun GT 0 then begin
                   xtension = sxpar( header, 'XTENSION' )
                   if !ERR GE 0 then message, $ 
                      'Reading FITS extension of type ' + xtension, /INF else $
                   message,'ERROR - Header missing XTENSION keyword',/CON
         endif
         snax = strtrim(NAX,2)
         st = snax(0)
         if Naxis GT 1 then for I=1,NAXIS-1 do st = st + ' by '+SNAX(I) $
                            else st = st + ' element'
         message,'Now reading ' + st + ' array',/INFORM    
   endif
;
; Read Data
;
	DATA = make_array( DIM = nax, TYPE = IDL_type, /NOZERO)
	readu, unit, data
	free_lun, unit
        
   if keyword__set( NaNvalue) then NaNpts = whereNaN( data, Count)
   if VAX or Little_endian then ieee_to_host, data
   if keyword__set( NaNvalue) then if Count GT 0 then $
                  data( NaNpts) = NaNvalue
;
; Scale data unless it is an extension, or /NOSCALE is set
;
   if not keyword__set( NOSCALE ) and (PointLun EQ 0 ) then begin

          bscale = float( sxpar( header, 'BSCALE' ))

; Use "TEMPORARY" function to speed processing.  

	  if !ERR NE -1  then $ 
	       if ( Bscale NE 1. ) then begin
                   data = temporary(data) * Bscale 
                   sxaddpar, header, 'BSCALE', 1.
   	       endif

         bzero = float( sxpar ( header, 'BZERO' ) )
	 if !ERR NE -1  then $
	       if (Bzero NE 0) then begin
                     data = temporary( data ) + Bzero
                     sxaddpar, header, 'BZERO', 0.
	       endif
	   endif

	;--------------------------------------
	; xdr conversion - JNS; 1/1998
	;--------------------------------------
	  case bitpix of 
	 	  8:	
	 	  16:	byteorder, data, /ntohs
	 	  32:	byteorder, data, /ntohl
	 	 -32:   byteorder, data, /xdrtof
	         -64:   byteorder, data, /xdrtod
	   endcase     


; Return array
;

	return, data    
end 
