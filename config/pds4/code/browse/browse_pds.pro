;+
; NAME:
;       BROWSE_PDS
;
; PURPOSE:
;	Browse PDS4 data using a widget to display both metadata and data 
;	and output all the data or some
;	subset of it.  One can view images in an attached IDL window.
;
; CATEGORY:
;       Datafile handling; PDS
;
; CALLING SEQUENCE:
;       data_struct = BROWSE_PDS([filename])
;
; INPUTS:
; filename - Name of PDS XML document that describes the data and datafiles.  
;            It is optional; if one uses no input parameters, then a file 
;            selection window appears to allow convenient selection of the 
;            PDS XML file.
;
; OUTPUTS:
; data_struct - Any subset of the data or metadata
;
; KEYWORDS:
;       NO_REORIENT - Do not use display_direction directives to reorient the
;				image.
;        
; PROCEDURES USED:
;        READ_PDS, TV1
;
; PACKAGE LOCATION:
;         http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
;
; IDL VERSIONS TESTED: 8.2
;
; MODIFICATION HISTORY:
; Written by Ed Shaya / U. of Maryland[Sept. 25, 2012]. 
;-
;-----------------------------------------------------------------
FUNCTION browse_pds, pdsfile, no_reorient=no_reorient

COMMON browsec2, status, data, metadata, returning, idhash, metaidhash, metavalues,ytitle
COMMON openercom, fstate
status = {win_id: 0L, sldminid: 0L, sldmaxid: 0L, datatextid: 0L, metadatatextid: 0L,$
       	X: 0L, Y: 0L, ImValue: 0L, imagePtr: ptr_new(), zoomf: 0D}
returning = 0
xtree=300
ytitle=''
xgraph=512
xsize=xtree+xgraph
ysize=512+40
if ~KEYWORD_SET(no_reorient) THEN no_reorient = 0
data = read_pds(pdsfile,metadata=metadata,no_reorient=no_reorient)
IF (SIZE(data,/tname) NE 'STRUCT') THEN BEGIN
   IF (data[0] EQ -1) THEN BEGIN
	PRINT,'Browse_pds: Unable to parse file ',pdsfile
	PRINT, 'Returning.'
	RETURN,-1
   ENDIF
   IF (data[0] EQ -2) THEN BEGIN
	PRINT,'Browse_pds: No data files found '
	PRINT, 'Browse Metadata only!'
	havedata = 0
   ENDIF
ENDIF ELSE havedata = 1

; Top Level base divided into left side and right side
top = WIDGET_BASE(title='BROWSE_PDS: '+pdsfile,/column)
if havedata eq 0 then xsize = xsize - xgraph
main = WIDGET_BASE(top,title='BROWSE_PDS: '+pdsfile,/row,xsize=xsize,ysize=ysize)

; Left side base is a column
leftside = WIDGET_BASE(main,/column,xsize=xtree)
; Right side base is a column 
IF havedata then rightside = WIDGET_BASE(main,/column,xsize=xgraph)
; Quit button on left side, last element in either tree is returned to user
qbtn = WIDGET_BUTTON(leftside,uvalue='quit', value='Quit')
; A tree widget for the data 
if havedata then datatree = WIDGET_TREE(leftside,value='Data Tree',/frame,ysize=ysize/2.)
; A combobox (text entry and droplist) search for data elements
status.datatextid = WIDGET_COMBOBOX(leftside, /editable,xsize=25,/flat,$
	UNAME ='datatext', UVALUE='datatext', VALUE=' ')
; A tree to display the metatdata
metatree = WIDGET_TREE(leftside,value='Metadata Tree',/frame)
; A combobox to search for rtn element from metadata
status.metadatatextid = WIDGET_COMBOBOX(top, /editable,$
	UNAME ='metadatatext', UVALUE='metadatatext', VALUE=' ')

; Add a graphics window on rightside
if havedata then begin
;	SET_PLOT,'X'
	!P.MULTI = 0
	!P.COLOR = !D.N_COLORS-1
	!P.BACKGROUND = 0
	!X.MARGIN = [10,6]
	!Y.MARGIN = [4,2]
	draw = WIDGET_DRAW(rightside, uvalue='draw', /button, xsize=xgraph,retain=2,ysize=ysize-100,/motion_events)
loadct,0
; Control for graphics window
control = WIDGET_BASE(rightside,row=1,ysize=50)
control2 = WIDGET_BASE(rightside,row=1,ysize=50)
; Create slider for min/max value of image
sldmin = CW_FSLIDER(control,/drag,title='Min Counts',min=0.,max=256.,value=0.,uval='mincounts',xsize=230,/edit)
status.sldminid = sldmin
sldmax = CW_FSLIDER(control,/drag,title='Max Counts',min=0.,max=256.,value=256., uval='maxcounts', xsize=230,/edit)
status.sldmaxid = sldmax
; Create label widgets to hold the cursor position and Hexadecimal
; value of the pixel under the cursor.
  status.X = WIDGET_label(control2, XSIZE=130, VALUE='X position:', frame=2)
  status.Y = WIDGET_label(control2, XSIZE=130, VALUE='Y position:', frame=2)
  status.ImValue = WIDGET_label(control2, XSIZE=130, VALUE='Value:', frame=2)
endif

; Add root for Metadata Tree
root = WIDGET_TREE(metatree,value='METADATA',uvalue='metadatatree',/folder,/expanded)
metaidhash = HASH('METADATA',root)
tags = tag_names(metadata)

; Add each metadata tag to the tree
FOR i = 0, N_ELEMENTS(tags)-1 DO BEGIN
        ;elements = STRSPLIT(tags[i],'.',/extract,count=count)
	tag = tags[i]
	fulltag = 'METADATA'+'.'+tag
	result = EXECUTE('type = size('+fulltag+',/tname)')
	result = EXECUTE('dim = size('+fulltag+',/dimension)')
	parent=root
	dim = dim > 1
	FOR j = 0,dim[0]-1 DO BEGIN
		IF (dim[0] GT 1) THEN tag = tag+'['+STRTRIM(STRING(j),1)+']'
		fulltag = 'METADATA'+'.'+tag
		IF (type EQ 'STRUCT') THEN BEGIN  ; Branches
			addstruct2tree,metadata,tag,fulltag,parent,metaidhash
		ENDIF ELSE BEGIN	; Leaves	 
			addleaf2tree,metadata,tag,fulltag,parent
		ENDELSE
	ENDFOR
ENDFOR

; Add root for Data Tree
IF havedata THEN BEGIN
   root = WIDGET_TREE(datatree,value='DATA',uvalue='datatree',/folder,/expanded)
   idhash = HASH('DATA',root)
   tags = get_tags(data,'data')

   FOR i = 0, N_ELEMENTS(tags)-1 DO BEGIN
        elements = STRSPLIT(tags[i],'.',/extract,count=count)
	tagname = elements[-1]
	parent = 't_'+elements[-2]
	tag = IDL_VALIDNAME(tagname,/convert_all)
	IF (count EQ 2) THEN parent='root'
	result = EXECUTE('type = size('+tags[i]+',/tname)')
	Result = EXECUTE("t_"+tag +" = WIDGET_TREE("+parent+$
		",value='"+tagname+"',/folder,uvalue='datatree')")
	Result = EXECUTE('t_tag = t_'+tag)
	idhash += HASH(tags[i],t_tag)
	IF (type NE 'STRUCT') THEN BEGIN  ; Leaves
	;	result=EXECUTE('tagvalue = '+tags[i])
	;	tagvalue = STRING(tagvalue[0])
	;	Result = EXECUTE("t_value = WIDGET_TREE(t_"+tag+$
	;		",value='"+tagvalue+"',uvalue=tags[i])")
	ENDIF
   ENDFOR
ENDIF

WIDGET_CONTROL, top, /realize              ; create the widgets
IF havedata THEN BEGIN 
	WIDGET_CONTROL, draw, get_value=win_id      ;get the graphic window id
ENDIF
XMANAGER, 'browse', top, no_block=0      ; wait for events
RETURN, returning
END ; end browse_pds
