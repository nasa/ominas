FUNCTION XML2IDL8,oNode,nodeName=nodeName,nodeValue=nodeValue

;-----------------------------------------------------------------------------
;+
; NAME:
;	XML2IDL8
;
; PURPOSE:
;	Translate a DOM (Document Object Model) object (read in
;	from an XML file with read_xml.pro) into either an IDL hash
;	by recursion through the document tree.	The '8' in the name
;	indicates this version is for IDL version 8.3 and above
;	as it uses ordered hashes and lists which were introduced to IDL in
;	version 8.3.  For the IDL hash, XML element names become
;	key names in the hash.  Elements with non-null text get a
;	'_text' key.  Comments are attached to parent elements with
;	'_comment' key.  Attributes are similarly treated with the
;	attribute name as the key.  They can be distinguished from
;	element text by the lack of a '_text' key.
;	
;	All non-essential whitespace is removed.  IDL variable names are allowed
;	to have only the special characters '_','$', and '!', so all other
;	special characters are converted to '_'.
;	
; CATEGORY:
;	Datafile handling; XML
;
; CALLING SEQUENCE:
;	myhash = XML2IDL8(oChild,nodeName=childName,nodeValue=childValue) 
;       
; INPUTS:
;	oNode -  DOM Document object (IDLffXMLDOMDocument) or top DOM Node 
;		(IDLffXMLDOMNode) to convert to string array
;
; OUTPUTS:
;	Returns a hash of hashes or lists that represents the XML file.  One can access the various nodes
;	by indexing into it, like this:
;          
;	IDL> print, hash[rootname,elName,childname,'_text']
;          
;	If there are siblings with the same name, then they are pulled together in a list which
;	is indexed by number:
;          
;	IDL> i++
;	IDL> print, hash[rootname,repeatedname,i,childname,'_text']
; 
; KEYWORDS:
;	nodeName - returns nodeName of oNode
;
;	nodeVAlue - returns nodeValue of oNode
;	hash - If there are children elements, this returns a hash 
;	holding information on them
;
; PROCEDURE:
;	A number of input parameters and keywords are used internally only.  
;	They are used when the program walks through the document tree by 
;	recursively calling itself.  These are: paramArr, nodeName, 
;	and nodeValue 
;	
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [Nov 5, 2013]
;	Removed empty _text except for true empty elements ES [Dec 2013]
;-
;---------------------------------------------

  myhash = ORDEREDHASH()
  IF (N_PARAMS() LT 1) THEN BEGIN
	    PRINT, 'usage: myhash = XML2IDL(oDoc,nodeName=nodeName,nodeValue=nodeValue)'
	    RETURN,-1
  ENDIF

  ; Need to seed paramArr with a first element
  IF ~KEYWORD_SET(nodeName) THEN nodeName = ''
  IF ~KEYWORD_SET(nodeValue) THEN nodeValue = ''

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

   ; childHash will hold string for all tagnames and values of siblings.
   ; Start with Attribute names and values
   IF (SIZE(childHash,/type) EQ 0) THEN childHash = ORDEREDHASH()
   IF (nAtts GT 0) THEN $
	   FOR m = 0, nAtts-1 DO childHash[attNames[m]] = attValues[m]

   ; The following loop does all of the walking.
   ; This digs down one level and routine calls itself to get name and value
   ; and we get here again and digs down deeper.  Repeats until cannot go
   ; further down.  Return takes us up one level and then we look for siblings
   ; there.  When no more siblings at that level, go back up one level and look
   ; for siblings



   ; Go down one level
   oChild = oNode->GetFirstChild() 
   elNames = ['']
    
   ; Loop over siblings    
   WHILE OBJ_VALID(oChild) DO BEGIN 

      myhash = XML2IDL8(oChild,nodeName=childName,nodeValue=childValue)
		     
	    ; Gather info and hashs of each child for myhash 
	    
	    ; First deal with true EMPTY nodes (no attributes or text), 
	    ; these are coming back as
	    ; null strings on the childValue and an empty myhash, 
	    ; not as null _text nodes, so we put them into text nodes
	    ; Now they look like myhash got a return and can be handled
	    ; like other elements.
	    IF (n_elements(myhash) eq 0 and childValue EQ '' and childname NE '_text') THEN BEGIN
	      myhash['_text'] = ''
	    ENDIF
	    
	    ; Non empty _text and _comments
	    IF (childValue NE '' && (childName EQ '_text' || childname EQ '_comment')) THEN BEGIN
	        ; Concatenate these strings with a single space if multiple
	        multiple = 0
	        IF (N_ELEMENTS(childHash) NE 0) THEN $
	                   multiple = STREGEX((childHash.Keys()).ToArray(),childName,/boolean)
	        IF (total(multiple)) THEN $           
	            childHash[childName] = childHash[childName] + ' ' + childValue $
	        ELSE $
	             childHash[childName] = childValue
	             
	    ; Elements will have a non null myhash         
	    ENDIF ELSE BEGIN
	       IF (N_ELEMENTS(myhash) NE 0) THEN BEGIN
			      elName = childName
			      IF (elNames[0] EQ '') THEN BEGIN ; First one
      		   		elNames = [elName]
			      ENDIF ELSE BEGIN 
      		   		elNames = [elNames,elName]
			      ENDELSE

            ; Check for Repeat of elName.
            ; If so, then create a list or add to list
            whsame = where(elNames EQ elName,nsame)
            ; Second time a nodename is used create a list
            ; extract value from first hash and add new hash value
            IF (nsame EQ 2) THEN $ ; one previous element with this name
               childHash[elName] = LIST(childHash[elName],myhash)
            IF (nsame GT 2) THEN  BEGIN ; this element already a list by now
                      elList = childHash[elName]
                      elList.Add,myhash
                      childHash[elName] = elList
            ENDIF       
            IF (nsame LT 2) THEN $ ; no previous element with this name
			        childHash[elName] = myhash 
;            print,": ",
;            print,"childName: ",childName
;            print,"childValue: ",childValue
;            print,'childHash.keys: ',childHash.keys(),'childHash.values: ',childHash.values()
;            print,'myhash.keys ',myhash.keys()
			   ENDIF
      ENDELSE
	 
        oChild = oChild->GetNextSibling() 
  ENDWHILE ; end loop to get all children 
  
  RETURN, childHash
END ; PRO XML2IDL8
