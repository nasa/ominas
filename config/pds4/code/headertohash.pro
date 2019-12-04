;+
; NAME:
;       HEADERTOHASH
;
; PURPOSE:
;      Transform a FITS like header (string array) into two IDL hashes.  One hash for the values and one for the comments.
;
; CATEGORY:
;       Datafile handling; FITS, PDS
;
; CALLING SEQUENCE:
;       hhash = headertohash(header,comments=comments
;
; INPUTS:
; header - A string array holding the information from a fits header (or something resembling it)
;
; OUTPUTS:
;      A hash with keys being the parameter keywords and values are fits values
;
; KEYWORDS:
;        comments - allows the comments to be returned in a hash as well with keys being the parameter keywords.
;        
; PROCEDURES USED:
;        NONE
;
; PACKAGE LOCATION:
;        http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; IDL VERSIONS TESTED: 8.2
;
; MODIFICATION HISTORY:
; Written by Ed Shaya / U. of Maryland [Oct 5, 2013]. 
;-
;-----------------------------------------------------------------
FUNCTION headertohash,hdr,comments=comments
; Create a hash from a FITS header
j=-1
k=-1
keys = STRMID(hdr,0,8)

keys = STRTRIM(keys,2)
keys=keys[where(keys ne '')]
hh = HASH(keys[0],fxpar(hdr,keys[0],comment=cmmnts))
comments = HASH(keys[0],cmmnts)
whcomments = WHERE(keys EQ 'COMMENT',ncomments)
whhist = WHERE(keys EQ 'HISTORY',nhistory)
IF (ncomments GT 0) THEN commentarr = fxpar(hdr,'COMMENT',comment=cmmnts)
IF (nhistory GT 0) THEN historyarr = fxpar(hdr,'HISTORY',comment=cmmnts)
FOR i = 0, N_ELEMENTS(keys)-1 DO BEGIN
  IF (keys[i] EQ 'COMMENT' OR keys[i] EQ 'HISTORY') THEN CONTINUE
	par= fxpar(hdr,keys[i],comment=cmmnts)
	hh = hh + HASH(keys[i],par)
  comments = comments + HASH(keys[i],STRTRIM(cmmnts))
ENDFOR
IF (ncomments GT 0) THEN hh = hh +HASH('COMMENT',commentarr)
IF (nhistory GT 0) THEN  hh = hh +HASH('HISTORY',historyarr)
RETURN,hh
END


