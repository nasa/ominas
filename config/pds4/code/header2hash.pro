FUNCTION header2hash,hdr,comments=comments,history=history,keydefs=keydefs
;
;+
; NAME:
;	HEADER2HASH
;
; PURPOSE:
;	Transform a FITS like header (string array) into two IDL ordered hashes. 
;	One hash for the values and one for the line comments or keyword definitions.
;	Also outputs separate arrays of comments and history.
;
; CATEGORY:
;	Datafile handling; FITS, PDS
;
; CALLING SEQUENCE:
;	hhash = header2hash(header[,comments=comments,history=history,keydefs=keydefs])
;
; INPUTS:
;	header - A string array representing a fits header.
;
; OUTPUTS:
;	 Returns an ordered hash with keys being the FITS keywords and values are 
;	their values. Optionally, the keydefs hash with the comments in fits cards at the end
;	of many lines (after '/') that usually give the definition of the keyword.
;
;	Optionally, a string array of all the COMMENT cards
;
;	Optionally, a string array of all of the HISTORY cards
;
; KEYWORDS:
;	keydefs - allows the keyword comments to be returned in a hash 
;	with same keywords as in the returned value hash.
;        
;	comments - String array return of the COMMENTS cards.
;
;	history - String array return of the HISTORY cards
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; IDL VERSIONS TESTED: 
;	8.3
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Oct 5, 2013]. 
;	Major rewrite ES April 27, 2015. No longer relies on sxpar and other 
;	fits routines in astron library.
;-
;-----------------------------------------------------------------

comments=['']
history=['']
keys = List()
cmmnts= List()
values= List()
T = 1
F = 0

; Last card is 'END'
endcard = WHERE(STRMID(hdr,0,4) eq 'END ') 
endcard = endcard[0]
IF (endcard EQ -1) THEN BEGIN
	PRINT, 'header2hash: No END card found'
	STOP
ENDIF
FOR i = 0, endcard DO BEGIN
	hdri = hdr[i]
	pos = STRPOS(hdri,'=')
	IF (pos EQ -1) THEN BEGIN
		; No equal sign, may be comment or history
	        pos = STRPOS(hdri,' ')
		IF (pos EQ -1 OR pos EQ 1) THEN CONTINUE
		key = STRMID(hdri,0,pos)
		IF key EQ 'COMMENT' THEN comments =  [comments,STRTRIM(STRMID(hdri,pos+1),2)]
		IF key EQ 'HISTORY' THEN history =  [history,STRTRIM(STRMID(hdri,pos+1),2)]
	ENDIF ELSE BEGIN
		keys.Add,STRTRIM(STRMID(hdri,0,pos),2)
		value = STRMID(hdri,pos[0]+1)
		posquote1 = STRPOS(value,"'")
		IF (posquote1 NE -1) THEN  BEGIN
			posquote2 = STRPOS(STRMID(value,posquote1+1),"'")
			IF  (posquote2 EQ -1) THEN BEGIN
				PRINT, 'header2hash: unmatched quote, line ',i
				STOP
			ENDIF ELSE BEGIN
				pos = STRPOS(STRMID(value,posquote1+posquote2+2),'/')
				IF (pos NE -1) THEN pos = pos+posquote1+posquote2+2
			ENDELSE
		ENDIF ELSE pos = STRPOS(value,'/')
		IF (pos NE -1) THEN BEGIN
			cmmnts.Add, STRTRIM(STRMID(value,pos+1))
		        value = STRTRIM(STRMID(value,0,pos-1),2)
		ENDIF ELSE cmmnts.Add, ''
		; This execute will allow each value to 
		; be datatyped real or integer, if it 
		; fails then it will remain string
		if value ne '' then result = EXECUTE("value = "+value)
		values.Add,value
	ENDELSE
ENDFOR
hh = orderedhash(keys,values)
keydefs = orderedhash(keys,cmmnts)
IF (n_elements(comments) GT 1) THEN comments = comments[1:*]
IF (n_elements(history) GT 1) THEN history = history[1:*]
RETURN,hh
END
