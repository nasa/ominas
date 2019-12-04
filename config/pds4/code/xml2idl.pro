PRO XML2IDL, oNode,level=level,nodeName=nodeName,nodeValue=nodeValue,$
		struct=struct,paramArr=paramArr
;-----------------------------------------------------------------------------
;+
; NAME:
;	XML2IDL
;
; PURPOSE:
;	Translate a DOM (Document Object Model) object (read in 
;	from an XML file with read_xml.pro) into either an IDL structure
;	or a parameter array (see paramArr below) by recursion through the 
;	document tree.	For the IDL structure, XML element names become 
;	tagnames in the structure.  Elements with non-null text get  a 
;	'_text' tag.  comments are attached to parent elements with '_comment' 
;	tag.  Attributes are similarly treated with the attribute name as the 
;	tagName.  They can be distinguished from element text by the lack of 
;	a '_text' tag.
;	
;	All non-essential whitespace is removed.  IDL variable names are allowed
;	to have only the special characters '_','$', and '!', so all other 
;	special characters are converted to '_'.
;	
;	IDL does not accept repeat names as subtags but XML does allow repeats 
;	of element names of siblings. Such repeats can often be turned into 
;	arrays in IDL, but not always because IDL does not have the concept of 
;	a type with optional subcomponents. A decision is made by this program 
;	as to whether to handle a repeating element as an array
;	or to alter the element name slightly.  If its structure is of 
;	identical type as the previous element of same name, then it is 
;	appended to an array.  Otherwise, a __1, __2, etc. is added to the name.
;	In these cases, no suffix is interpreted as the __0 instance.
;	A string of elements of the same name may translate partially into
;	arrays and partially into altered names.
;	For multiple XML comments on an element, the values are appended into a 
;	string array.  They must be consecutive.
;	
;	In paramArr, an XML element that holds other elements results in a 
;	the string "OBJECT = ElementName" before all of its attributes and 
;	children and "END_OBJECT = ElementName" after.  Elements which just 
;	hold text translate to " Element = textValue ".  
;	
; CATEGORY:
;	Datafile handling; XML
;	
; CALLING SEQUENCE:
;	XML2IDL, oNode,level=level,struct=struct, [ paramArr = paramArr ]
;
; INPUTS:
;	oNode -  DOM Document object (IDLffXMLDOMDocument) or top DOM Node 
;	(IDLffXMLDOMNode) to convert to string array
;
; OUTPUTS:
;
; KEYWORDS:
;	level - starting level for indentation, usually set to 0.  As level 
;	increases during recursion the amount of indentation grows
;
;	nodeName - returns nodeName of oNode
;
;	nodeVAlue - returns nodeValue of oNode
;
;	struct - If there are children elements, this returns a structure 
;	holding information on them
;
;	paramArr - If there are children elements, this returns an array of 
;	strings of the form "Element = textValue", if it has text, and
;	"OBJECT = ELEMENT" to start an element and 
;	"END_OBJECT = ELEMENT" to close it.
;	To turn it on, set paramArr = 1 or ['1'].  To turn it off set 
;	paramArr = 0 or ['-1'].
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; PROCEDURE:
;	A number of input parameters and keywords are used internally only.  
;	They are used when the program walks through the document tree by 
;	recursively calling itself.  These are: paramArr, struct, nodeName, 
;	and nodeValue 
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [April 27, 2012]
;	Modified by Ed Shaya [May 4, 2012] - 
;       Changes all of the ANDs to && to speed it up and to fix a bug when using
;          IDL version 6 where index cannot be -1.
;-
;---------------------------------------------
 
  IF (N_PARAMS() LT 1) THEN BEGIN
	PRINT, 'usage: XML2IDL,oDoc,level=level,nodeName=nodeName,nodeValue=nodeValue,struct=struct,paramArr=paramArr'
	RETURN
  ENDIF

  ; Need to seed paramArr with a first element
  IF ~KEYWORD_SET(nodeName) THEN nodeName = ''
  IF ~KEYWORD_SET(nodeValue) THEN nodeValue = ''
  IF ~KEYWORD_SET(level) THEN level = 0
  IF ~KEYWORD_SET(paramArr) THEN paramArr = ['-1'] 
  IF (SIZE(paramArr,/type) NE 7) THEN $
  	IF (paramArr EQ 1) THEN paramArr = [''] ELSE paramArr = ['-1']

   ; "Visit" the node and get name and value 
   nodeName = oNode->GetNodeName()
   ; IDL has restrictions on characters in variable names
   nodeName = IDL_VALIDNAME(nodeName,/convert_all)
   
   
   nodeValue = oNode->GetNodeValue()
   ; Remove unprintable characters
   nodeValue = str_clean(nodeValue)
   ; Remove multiple spaces
   nodeValue = STRCOMPRESS(nodeValue)
   ; Remove spaces at beginning and end
   nodeValue = STRTRIM(nodeValue,2)

   nodeType = oNode->GetNodeType()
   ; Handle DTD nodeName which is same as root.
   IF (nodeType EQ 10) THEN BEGIN
	   nodeValue = nodeName
	   nodeName = 'DTD'
   ENDIF

   ; Get list of attribute names and values
   nAtts = 0
   oAttMap = oNode->GetAttributes()
   IF OBJ_VALID(oAttMap) THEN nAtts = oAttMap->GetLength()
   IF (nAtts GT 0) THEN BEGIN
	attNames = STRARR(nAtts)
	attValues = STRARR(nAtts)
	FOR i = 0, nAtts-1 DO BEGIN 
	   oAtt = oAttMap->Item(i)

	   attName = oAtt->GetName()
	   attNames[i] = IDL_VALIDNAME(attName,/convert_all)

	   attValue = oAtt->GetValue()
	   attValues[i] = attValue
   	ENDFOR
   ENDIF

   IF (paramArr[0] NE '-1') THEN BEGIN
	; Write to paramArr
	indent = STRING(REPLICATE(32B,(FIX(level)+1)*3))
 	oneIndent = '   '
	IF (STRPOS(nodeValue,' ') NE -1) THEN $
		nodeValue2 ='"'+nodeValue+'"'  $
	ELSE nodeValue2 = nodeValue

	;The node that holds text was written out in the visit to the parent.
        CASE nodeType OF 
	1: BEGIN ; Handle Element
		paramArr = ['',paramArr]
   	  	paramArr[0] = indent +'OBJECT = '+StrUpCase(nodeName)
      		; Attributes are nodeType 2 
      		FOR i = 0, nAtts-1 DO BEGIN
	   	   ; If there is a space in attValue, then quote it
	   	   IF (STRPOS(attValues[i],' ') NE -1) THEN $
			attValuep = '"' + attValues[i] + '"' 
		   paramArr = [oneIndent+indent+StrUpCase(attNames[i])+$
				' = ' + StrUpCase(attValuep), paramArr]
		ENDFOR
	   END
	3: BEGIN ; Handle TextNode
		IF (nodeValue2 NE '' && nodeValue2 NE ' ') THEN BEGIN
   	   	indent = STRING(REPLICATE(32B,FIX(level)*3))
		; If there is a space in nodeValue, then quote it
		keyval = parse_parameter(paramArr[0])
		paramArr[0] = indent+keyval[1]+' = ' + StrUpCase(nodeValue2)
		ENDIF
	END
	;4: CDATA TBD
	;5: Entity Reference should be dentified already
	;6: Entity should be dentified 
	7: BEGIN ; Handle processing instruction
      		paramArr = ['',paramArr]
		paramArr[0] = indent + NodeName +'= '+StrUpCase("'"+nodeValue2+"'")
	END
	8: BEGIN ; Handle comment
		paramArr = ['',paramArr]
		paramArr[0] = indent + 'COMMENT = '+StrUpCase(nodeValue2)
	END
	
	9: ; Handle DOM Document
		;Do nothing
	10: BEGIN ; DTD
		paramArr = ['',paramArr]
		paramArr[0] = indent + 'DTD = '+StrUpCase(nodeValue2)
	END
	ELSE: PRINT, 'NodeType = ',nodeType,' Not handled yet.'

	ENDCASE
   ENDIF ; paramArr
   
   ; Add quotes on values for structure.
   ; First remove double quotes if at beginning and end.
     IF (nodeValue NE '') THEN BEGIN
   IF (STRMID(nodeValue,0,1) EQ '"' && $
	   STRMID(nodeValue,0,1,/reverse_offset) EQ '"') THEN BEGIN
   	   nodeValue = STRMID(nodeValue,1)
   	    nodeValue = STRMID(nodeValue,1,/reverse_offset)
   ENDIF
 
	   ; Check for apostrope and quote
	   	quotes = STRPOS(nodeValue,'"') 
	   	squotes = STRPOS(nodeValue,"'")
	   	IF (quotes NE -1 && squotes NE -1) THEN BEGIN
	   	   nodeValue = STRJOIN(STRSPLIT(nodeValue,'"',/extract),'&quot;')
         nodeValue = '"'+nodeValue+'"'
      ENDIF ELSE BEGIN
        IF (squotes EQ -1) THEN $
           nodeValue = "'"+nodeValue+"'" $
        ELSE IF (quotes EQ -1) THEN $
		       nodeValue = '"'+nodeValue+'"'
	   ENDELSE
  ENDIF

   childElStr = ''
   ; childElStr will hold string for all tagnames and values of siblings.
   ; When all of the children's tagname:value are appended, the IDL 
   ; EXECUTE command will 'eval' it.
   ; Start with Attrbute names and values
   IF (nAtts GT 0) THEN BEGIN
	   FOR m = 0, nAtts-1 DO BEGIN
	    attV = attValues[m]
	   	IF (STRPOS(attV,"'") EQ -1) THEN BEGIN  ; No single quote
			   childElStr +=  ','+attNames[m]+" : '"+attV+"'"  
		  ENDIF ELSE BEGIN ; There is a single quote

	   		 IF (STRPOS(attV,'"') NE -1) THEN $ ; Single quota and double quote, use entity &quot;
		        attV = STRJOIN(STRSPLIT(attV,'"',/extract),'&quot;')
		    childElStr +=  ',' + attNames[m] + ' : "'+ attV +'"' 
	    ENDELSE
	   ENDFOR
  ENDIF

  
   ; The following loop does all of the walking.
   ; This digs down one level and routine calls itself to get name and value
   ; and we get here again and digs down deeper.  Repeats until cannot go
   ; further down.  Return takes us up one level and then we look for siblings
   ; there.  When no more siblings at that level, go back up one level and look
   ; for siblings
   executeStr = ''
   result = ''
   prevElName = ''
   ElName = ''
   childNames = ['']
   ElNames = ['']
   childValues = ['']

   oChild = oNode->GetFirstChild() 
   prevChildTags = ['']
   nrep = 0
   WHILE OBJ_VALID(oChild) DO BEGIN 

      XML2IDL,oChild,level=level+1,nodeName=childName,nodeValue=childValue,$
		     struct=struct,paramArr=paramArr
 ;    print,"level: ",level
 ;    print,"childName: ",childName
 ;    print,"childValue: ",childValue
  ;   help,struct
 ;    stop
	    ArrayIt = -1 ; Reset flag to create an Array for this child element
	    ; Gather info and structs of each child for the struct

	    ; Leaves: text and comments etc.   We don't cover elements with mixed content
	    ; that is childvalue and child elements.
	    IF (childValue NE '') THEN BEGIN

		    IF (childNames[0] EQ '') THEN BEGIN ; First one
      		   childNames = [childName]
		    ENDIF ELSE BEGIN 
      		   childNames = [childNames,childName]
	      ENDELSE

		    IF (childValues[0] EQ '') THEN BEGIN ; First one
      		   childValues = [childValue] 
		    ENDIF ELSE BEGIN 
      		   childValues = [childValues,childvalue] 
	      ENDELSE
            
	    ENDIF ELSE BEGIN

       ; Handle Empty Element
       ;IF (childname eq 'TD') then stop
       ;IF (childvalue EQ '' and ~ISA(struct)) THEN struct = {_text : ''}

		  ; Elements without PCDATA.  Either empty or it has child elements
		  ; and these go into elNames. 
		  IF (childName NE '_text' && childName NE '_comment') THEN BEGIN
			   elName = childName
			   IF (elNames[0] EQ '') THEN BEGIN ; First one
      		   		elNames = [elName]
			   ENDIF ELSE BEGIN 
      		   		elNames = [elNames,elName]
			   ENDELSE
;			   IF (childname eq 'Internal_Reference') then stop
         Nels = N_ELEMENTS(elNames)
			   IF (Nels GE 2 && elName EQ elNames[Nels-2]) THEN BEGIN  
			  	  ; Handle repeat of child element
			      ; Check if struct and previous struct are 
			      ; compatible to be put into an array.  	
			      childTags = get_tags(struct)
			      arrayIt = ARRAY_EQUAL(childTags,prevChildTags)			      
			      nrep += 1
			      ; whether or not we array it, we will need a unique name for this structure
	;		      childName = elName+'__'+STRTRIM(STRING(nrep),1)
	;		      IF (childname eq 'Internal_Reference') then stop
			   ENDIF ELSE BEGIN
				    nrep = 0
			   ENDELSE

			   ; Now handle repeat childNames
			   ; We suffix it with '__N' where N is the occurrence number of childName
			   ; We do not try to put them into an array unless they are adjacent
				 IF (Nels GE 2) THEN BEGIN
				    whrep = WHERE(elName EQ elNames, nthis)
            IF (nthis GT 1) THEN $
				   		 childName = elName+'__'+STRTRIM(STRING(nthis-1),1)
         ENDIF
			   
			   ; If not going to array it, then add to ElStr
			   IF (arrayIt NE 1) THEN $
			     childElStr += ','+childName+' : '+childName
			   ; Keep track of all the tags to compare with next element  
		     IF (SIZE(struct,/type) NE 0) THEN $
		                  prevChildTags = get_tags(struct)
		   ENDIF ; if no _text or _comment
	   ENDELSE ; if childvalue eq ''

	   IF (KEYWORD_SET(struct) and childname NE '_text') THEN BEGIN ; If a struct returned from child
		   ; Use childName for name of oChild's returned structure.
		   result2 = 0
		   IF (arrayIt EQ 1) THEN BEGIN

			   result2 = EXECUTE(prevElName+'= ['+prevElName+', struct]',0,1 )

			   ; But, if execution fails, it is probably because one
			   ; cannot form an array of these structures, so just
			   ; create another node with underscores.
			 ENDIF 
			 IF (result2 NE 1) THEN BEGIN
				   result3 = EXECUTE(childName+' = struct') 
				   IF (arrayIt EQ 1) THEN childElStr += ','+childName+' : '+childName
			 ENDIF ELSE BEGIN
				   childname = prevElName
			 ENDELSE 
		   IF (result3 NE 1) THEN BEGIN 
			   PRINT, 'xml2idl: Problem renaming struct to '+childname
			   STOP
		   ENDIF
		   struct = {_text : ''}
		   IF (childName NE '_text' && childName NE '_comment') THEN $
		         prevElName =  childName  
		   
	   ENDIF ; if struct
	   
	; Get all of the other siblings 
        oChild = oChild->GetNextSibling() 

  ENDWHILE ; loop to get all children 

  ; Create new structure

   ; This next big block is just for handling multiple comments in an element
   ; IDL does not permit multiple variables with the same name on a structure 
   ; node.
   IF (childNames[0] NE '') THEN BEGIN

      nc = N_ELEMENTS(childNames)
      IF (nc EQ 2) THEN BEGIN
	      IF (childNames[0] EQ childNames[1]) THEN BEGIN
		      childValues[0] = ' ['+childValues[0]+','+childValues[1]+']'
		      nc =1
	      ENDIF
      ENDIF
      
      IF (nc gt 2) THEN BEGIN
   	     unique = UNIQ(childNames) 
         nc2 = N_ELEMENTS(unique)
	       unique2 = [-1,unique]  ; this helps handle the first element
         FOR k = 1, nc2 DO BEGIN
	           k1 = unique2[k-1]+1
	          k2 = unique2[k]
	          IF ((k2 - k1) NE 0) THEN BEGIN 
		           childValues[k2] = ','+childVAlues[k2] +']'
		           IF ((k2-k1) GT 1) THEN $
		             FOR kk = k1+1, k2-1 DO $
		       	        childValues[k2] = ','+childValues[kk] + childValues[k2]
		             childValues[k2] = '['+childVAlues[k1] + childValues[k2]
	          ENDIF
         ENDFOR
	       childValues = childValues[unique]
	       nc = nc2
      ENDIF
      
      IF (nc GT 0) THEN $
	      FOR k = 0, nc-1 DO $
	      	childElStr += ','+childNames[k] + ' : '+childValues[k]
   ENDIF ; end adding leaves to string to execute

   childElStr = STRMID(childElStr,1) ; remove comma as first character
   IF (childElStr NE '') THEN ExecuteStr = 'struct ='+'{'+childElStr+'}'
   IF (executeStr NE '') THEN result = Execute(ExecuteStr)
   IF (executeStr NE '') THEN IF (result eq 0) then STOP

   IF (paramArr[0] NE '-1') THEN BEGIN ; Close OBJECT in paramArr or 
	   				; finish up paramArr
   	IF (nodeName NE '_text' && childNames[0] NE '_text' && $
	    nodeName NE '_comment' && nodeType NE 7 && $
	    nodeType NE 10 && level NE '0') THEN $
	   paramArr = [indent+'END_OBJECT = '+StrUpCase(nodeName), paramArr]

   	IF (level EQ 0) THEN BEGIN
   		paramArr = REVERSE(paramArr)
   		paramArr = paramArr[1:*]
   	ENDIF
   ENDIF ; Close OBJECT paramArr
   RETURN
END ; PRO XML2IDL
