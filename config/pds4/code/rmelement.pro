FUNCTION rmelement,array,indx
;-----------------------------------------------------------------
;+
; NAME:
;	RMELEMENT       
;
; PURPOSE:
;	Remove an element or several elements from an array by their index number
;
; CATEGORY:
;	Array Processing
;
; CALLING SEQUENCE:
;	Result =  rmelement(array,indx)
;
; INPUTS:
;	array - 1 d array which will have some element(s) removed.
;
;	indx - an integer scalar or array with index values of elements to be removed.
;
; OUTPUTS:
;       Returns an array that has fewer elements than the input array.
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya a long long time ago. / U. of Maryland
;
;	Modified to return an empty array when needed.
;	Modified to handle zero length index and indx outside array size. 
;	And added a sort to the uniq function to ensure uniqueness really happens. [5/7/15]
;
;-
;-----------------------------------------------------------------

; Remove elements given by indx from array.
sz = N_ELEMENTS(indx)
IF (sz EQ 0) THEN BEGIN
	PRINT,'rmelement: indx has zero length, returning original array.'
	RETURN,array
ENDIF

szarr = N_ELEMENTS(array)
empty = []
outside = WHERE((indx LT 0) OR (indx GE szarr),nout)
IF (nout GT 0) THEN BEGIN
	PRINT, ' RMELEMENT: Attempting to remove elements outside array size'
	PRINT, ' array has length ', szarr
	PRINT, ' outside indx to remove is/are ', indx[outside]
	RETURN,array
	ENDIF
; If removing an array of element	
IF (sz GT 1) THEN BEGIN
	indx = indx[UNIQ(indx,SORT(indx))]
	; Create an array of indices to include
	; At first they are all included, because indgen is all positive
	include = INDGEN(szarr)
	; Set the one to be removed to -1
	include[indx] = -1
	; Include only indices that are still positive
	include = include[WHERE(include GE 0)]
	IF include[0] NE -1 THEN array1 = array[include] ELSE array1 = []
	RETURN,array1
	ENDIF
; If removing a single element
IF (sz EQ 1) THEN BEGIN
	; If the single element is the first one 
	IF (indx[0] EQ 0) THEN $
	     IF (szarr GT 1) THEN RETURN,array[1:*] ELSE RETURN,empty
	; If the single element is the last one 
	IF (indx[0] EQ (szarr-1)) THEN RETURN, array[0:szarr-2]

	RETURN, [array[0:indx[0]-1],array[indx[0]+1:*]]
	ENDIF
END
