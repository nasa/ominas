FUNCTION GETTAGSBYNAME, struct, tagname, getvalues=getvalues, root=root, $
	settags=settags, count = count, simple = simple
;+
; NAME:
;	GetTagsByName
;
; PURPOSE:
;	Get an array of tagnames in a structure matching name expression.
;	Can use full regex in the name (See Learning About Regular Expressions in IDL Help).
;	Will return an array of the values of the variables in the structure
;	corresponding to these tagnames, if /getvalues is set.
;
; CATEGORY:
;	structure processing

; CALLING SEQUENCE:
;	Result = GETTAGSBYNAME(structure,tagname,[/getvalues, root=root, settags=settags, count=count]) 
;
; INPUTS:
;	structure - An IDL structure
;
;	tagname - expression to match with the tagname string
;             Regular Expression Examples:
;		'\.name1$' -  Search for final tag 'name1' exactly.
;		'\.name1\.[^.]+$' -  Search for only direct children of 'name1'.
;		'name1\.name2$' -  Search for tags ending in 'name1.name2'.
;		'\^.name1\.name2(__[1-9])?$' - Search for top level name1 with child 'name2' or
;			'name2__1', 'name2__2', ... 'name2__9'.
;
; OUTPUTS:
;	Returns a string array of full names for tags containing tagname in 
;	the structure.  If no matches then result[0] = '-1'
;	If getvalues is set, then result is a string array of values of 
;	those tags in the structure.  If no values return, then 
;	result[0] = '-1'.  
;
; KEYWORDS:
;	getvalues - set to 1 to get values, set to 0 to get tagnames.  Will only work
;	if value is scalar or an array, but not a list of structures.
;
;	root - Optionally can use name of structure as prefix to tagnames
;
;	settags - If you already know the tags in the structure, then you can 
;       improve efficiency.  Program will not perform another get_tags.  
;	Can also use this to restrict search to certain tags.
;
;	count - Number of matches found
;
; PROCEDURES USED:
;	GET_TAGS
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [May 8, 2012]
;
;-
;-----------------------------------------------------------------

IF ~KEYWORD_SET(getvalues) THEN getvalues = 0
IF ~KEYWORD_SET(root) THEN root = ''
IF ~KEYWORD_SET(simple) THEN simple = 0
IF ~KEYWORD_SET(settags) THEN tags = get_tags(struct,root) ELSE tags = settags

	root = strUpCase(root)
	tagname = strUpCase(tagname)
	IF (simple EQ 1) THEN BEGIN
		tagspos = WHERE(STRMATCH(tags,tagname)) 
		result = where(tagspos NE -1,count)
	ENDIF ELSE BEGIN
		tagspos = WHERE(STREGEX(tags,tagname,/boolean) , count)
	ENDELSE

	IF (count EQ 0) THEN RETURN, '-1'
	tagsbyname = tags[tagspos]
	
	str = ''
	IF (getvalues) THEN BEGIN
		FOR i = 0, count-1 DO str = str+', STRUCT'+tagsbyname[i]
		str = STRMID(str,1) 			; remove extra comma at beginning
		; Executing the list of matching tags as an array
		; results in an array of their values going into tagvalues.
		result = EXECUTE('tagvalues = ['+str+']')
		RETURN, tagvalues
	ENDIF ELSE BEGIN
		RETURN,tagsbyname
	ENDELSE
END
