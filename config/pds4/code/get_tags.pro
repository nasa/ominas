FUNCTION TAG_PTRS, structure, rootname

; This function recursively searches through
; a structure, finds ALL of the structure's tag names.
; It returns a pointer to an array of pointers, each pointing
; to the names of structure fields.
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 

IF N_ELEMENTS(rootname) EQ 0 THEN rootname = '.' ELSE $
   rootname = STRUPCASE(rootname) + '.'
tags = TAG_NAMES(structure)
result = PTR_NEW(rootname + tags)

   ; If any of the fields are structures, recurse back into this function 

FOR j=0,N_ELEMENTS(tags)-1 DO BEGIN
   out = EXECUTE('type = Size(structure.' + tags[j] + ',/TNAME)')
   IF type EQ 'STRUCT' THEN BEGIN
      newrootname = rootname + tags[j]
      theseTags = CALL_FUNCTION('tag_ptrs',structure.(j),newrootname)
      result = [[result],[theseTags]]
   ENDIF
ENDFOR

RETURN, result
END
;-------------------------------------------------------------------

FUNCTION GET_TAGS, structure, rootname
;-----------------------------------------------------------------
;+
; NAME: 
;	GET_TAGS
;
; PURPOSE:
;	This function returns the names of all tags in the structure as a string 
;	array. The names are given from the root structure name,
;	which can be passed in along with the structure itself.
;
; CATEGORY:
;	structure processing
;
; CALLING SEQUENCE:
;	Result =  GET_TAGS(structure [, rootname])
;
; INPUTS:
;	structure - Name of structure that will be searched for tagnames
;
; OUTPUTS:
;	result - Names of all tags in the structure.  IDL procedure tag_name only provides
;	top level structure tag names
;
; Optional Input:
;	rootname - The name of the structure, provides the rootname if you want the 
;	result names to start with it.
;
; PROCEDURES USED:
;	TAG_PTRS
;
; PACKAGE LOCATION:  
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Nov. 9, 2013]
;-
;-----------------------------------------------------------------

ON_ERROR, 1

   ; Check parameters.

CASE N_PARAMS() OF

   0: BEGIN
      MESSAGE, 'Structure argument is required.'
      ENDCASE
      
   1: BEGIN
      rootname = ''
      type = SIZE(structure,/tname)
      IF type NE 'STRUCT' THEN $
         MESSAGE, 'Structure argument is required.'
      ENDCASE
      
   2: BEGIN
      type = SIZE(structure,/tname)
      IF type NE 'STRUCT' THEN $
         MESSAGE, 'Structure argument is required.'
      type = SIZE(rootname,/tname)
      IF type NE 'STRING' THEN $
         MESSAGE, 'RootName parameter must be a STRING'
      ENDCASE
      
ENDCASE

tags = tag_ptrs(structure, rootname)

; Extract and free the first pointer.

retval = [*tags[0,0]]
PTR_FREE, tags[0,0]

; Extract and free the the rest of the pointers.
   
s = SIZE(tags)
FOR j=1,s[2]-1 DO BEGIN
   retval = [retval, *tags[0,j]]
   PTR_FREE, tags[0,j]
ENDFOR
PTR_FREE, tags

; Return structure names.
   
RETURN, retval
END
