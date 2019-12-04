FUNCTION READ_FITSWHOLE,datafile,compress=compress,nonumbers=nonumbers,nextensions=nextensions
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
; Oct 5, 2017 Added nextensions to read in only N extensions if don't want all or if you don't want an error of reading past EOF

IF ~KEYWORD_SET(nonumbers) then nonumbers = 0

execString = ''
OPENR, lunit, datafile, /get_lun, error = error,/swap_if_little,compress=compress

; Read primary header/data
primary = mrdfits(lunit,0,hdr_0,/dscale,status=status,silent=2)
IF (N_ELEMENTS(primary EQ 1)) THEN $
	execString +=  ', header : hdr_0 ' $
ELSE $
	execString +=  ', header : hdr_0, data : primary '

; The header will either give number of extensions or it will just set extend=1
; If it only has extend=1, then we read in a maximum of 100 extensions here.
nextend = fxpar(hdr_0,'NEXTEND',count=matches)
if keyword_set(nextensions) then nextend = nextensions
IF (nextend EQ 0) THEN BEGIN
	extend = fxpar(hdr_0,'EXTEND')
	IF (extend EQ 1) THEN nextend = 100
ENDIF
IF (nextend NE 0) THEN BEGIN
  FOR j = 1, nextend DO BEGIN
  	data = mrdfits(lunit,0,hdr,/dscale,status=status,/silent)
	IF (status EQ -2) THEN BREAK
        ; Create a structure for extensions using extname
	extname = fxpar(hdr,'EXTNAME',count=matches)
	IF (matches EQ 0) THEN BEGIN 
	        extname =  '_' + STRTRIM(STRING(j),2)
	ENDIF ELSE BEGIN
		extname = IDL_VALIDNAME(STRTRIM(extname,2), /convert_all) 
		IF ~nonumbers THEN $
		    extname +=  '_' + STRTRIM(STRING(j),2)
	ENDELSE
	Result = EXECUTE(extname+' = {header : hdr, data : data}')
	; Prepare string for creating data_struct
	execString +=  ',' + extname + ' : ' + extname
  ENDFOR
ENDIF
FREE_LUN, lunit
execString = STRMID(execstring,1)
Result = Execute('data_struc = { ' + execString + '}')
RETURN, data_struc
END ; FUNCTION READ_FITSWHOLE
