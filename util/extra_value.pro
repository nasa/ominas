;=============================================================================
;+
; NAME:
;	extra_value
;
;
; PURPOSE:
;	Returns the value of a keyword in a _extra structure.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	value = extra_value(extra, name, prefix)
;
;
; ARGUMENTS:
;  INPUT:
;	extra:	Structure containing keywords and values, e.g. a _extra
;		structure.
;
;	name:	String giving the name of the keyword to search for.  May
;		be abbreviated according to the usual IDL keyword abbreviation
;		rules except that in the case of a conflict, perfect matches 
;		are preferred; otherwise first match is returned.  
;
;	prefix:	String giving an optional prefix to apply to the keyword
;		search.  A value is returned if either the name or prefixed
;		name are matched, with the prefixed nam taking precedence.  
;		Note that '_' is inserted between the prefix and the name.
;
;	noabbrev:
;		If set, the name input may nt be abbreviated.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================



;=============================================================================
; ev_match
;
;=============================================================================
function ev_match, extra, name, prefix

 ;--------------------------------------------------------
 ; check for match to only given number of sharacters
 ;--------------------------------------------------------
 s = name
 if(keyword_set(prefix)) then s = prefix + '_' + s
 len = strlen(s)

 tags = tag_names(extra)
 w = where(strmid(tags, 0, len) EQ strupcase(s), nw)

 ;--------------------------------------------------------
 ; multiple matches
 ;--------------------------------------------------------
 if(nw GT 1) then $
  begin
   ww = where(tags[w] EQ s)

   ;- - - - - - -  - - - - - - - - - - - - - - - - - - - - -
   ; if multiple matches, return exact match if present
   ;- - - - - - -  - - - - - - - - - - - - - - - - - - - - -
   if(ww[0] NE -1) then return, w[ww[0]]
  end

 ;--------------------------------------------------------
 ; result for one or zero matches
 ;--------------------------------------------------------
 return, w[0]
end
;=============================================================================



;=============================================================================
; extra_value
;
;=============================================================================
function extra_value, extra, name, prefix, noabbrev=noabbrev

  if(NOT keyword_set(extra)) then return, !null

 ;--------------------------------------------------------
 ; if prefixed name matches, use that
 ;--------------------------------------------------------
 if(keyword_set(prefix)) then $
  begin
   w = ev_match(extra, name, prefix)
   if(w[0] NE -1) then return, extra.(w)
  end

 ;--------------------------------------------------------
 ; otherwise check for non-prefixed name
 ;--------------------------------------------------------
 w = ev_match(extra, name)
 if(w[0] NE -1) then return, extra.(w)

 return, !null
end
;=============================================================================
