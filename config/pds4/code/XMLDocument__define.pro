FUNCTION XMLDocument::SetElement,name,parent,atts=atts,attvals=attvals,text=text,before=before
;------------------------------------------------
;+
; NAME:
;	XMLDocument__define 
;
; PURPOSE:
;	We subclass IDLffDOMDocument to add a convenient SetElement method.  It
;	allows one to create a new element with multiple attributes and a text
;	node plus place in it the Document tree by naming its parent
;	and optionally naming the next sibling.
;
;Category:
;	Datafile Handling: XML
;
; CALLING SEQUENCE:
;	oXML = OBJ_NEW('XMLDocument')
;	Return = oXML->SetElement(name,parent,atts=atts,attvals=atvals,$
;	             text=text, before=before)
;
; Required INPUTS:
;	name - Tag name of the element being created.
;
;	parent - object that holds parent of element
;	If parent is the XMLDocument then it is the root node.
;
; Optional INPUT KEYWORDS:
;	atts - string or stringarr of attribute names for element.
;
;	attvals - string or stingarr of values for attributes
;
;	text - string for textnode of element
;
;	before - next sibling.  If not specified, Element is placed as
;	last sibling (appended instead of inserted before).
;
; Outputs:
;	Return - Object reference to the element created
;
; Example: 
;	IDL> hh=orderedhash('E1','Text for E1','E2','Text for E2','E3','Text for E3') 
;	IDL> atts = ['att1','att2']
;	IDL> attvals =['att1 value','att2 value']
;	IDL> oXML = OBJ_NEW('XMLDocument')
;	IDL> oroot = oXML->SetElement('RootElement',oXML,atts='xmlns',$
;	IDL> attvals='somenamespace')
;	IDL> keys = hh.keys()
;	IDL> ochild1 = oXML->SetElement(keys[0],oroot,$
;	IDL>	atts='att1',attvals='att1 value',text=hh[keys[0]]) 
;	IDL> ochild2 = oXML->SetElement(keys[1],oroot,$
;	IDL>    atts=atts,attvals=attvals,text=hh[keys[1]])
;	IDL> ochild3 = oXML->SetElement(keys[2],oroot,text=hh[keys[2]])
;	IDL> oXML.save,string=outstring,/pretty_print
;	IDL> OBJ_DESTROY, oXML
;	IDL> print,outstring
;	&lt;?xml version="1.0" encoding="UTF-8" standalone="no" ?>
;	&lt;RootElement xmlns="somenamespace">
;
;	&lt;E1 att1="att1 value">Text for E1&lt;/E1>
;
;	&lt;E2 att1="att1 value" att2="att2 value">Text for E2&lt;/E2>
;
;	&lt;E3>Text for E3&lt;/E3>
;
;	&lt;/RootElement>
;	(Note: lessthan sign was encoded so that it appears correctly on the web)
;          
; Procedures Used:
;	Just built-in procedures
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; Modification History
;	Written by Ed Shaya / U. of Maryland [JULY 11, 2014].
;	Changed parent from a keyword to a required parameter ES [5/7/15].
;-
;--------------------------------


IF (N_PARAMS() EQ 0) THEN BEGIN
	print,'setElement:  Both a name string and parent object reference are required'
	return,-1
ENDIF

IF (~KEYWORD_SET(parent)) THEN BEGIN
	print, 'setElement: Parent must be set'
	return,-1
ENDIF

oElement = self->CreateElement(name) 

IF KEYWORD_SET(atts) THEN $
	FOR i = 0, N_ELEMENTS(atts)-1 DO $
		oElement->SetAttribute,atts[i],attvals[i]

IF KEYWORD_SET(text) THEN BEGIN
	oText = self->CreateTextNode(text) 
	oVoid = oELement->AppendChild(oText)
ENDIF

; Place Element into document as parent or before
IF KEYWORD_SET(before) THEN $
	oRef = parent->InsertBefore(oElement,before)  $
ELSE $
	oRef = parent->AppendChild(oElement) 

RETURN,oRef
END

PRO XMLDocument__define
	COMPILE_OPT IDL2
	void = {XMLDocument, inherits IDLffXMLDOMDocument}
END
