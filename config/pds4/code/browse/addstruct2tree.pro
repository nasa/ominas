PRO addstruct2tree,metadata,tag,fulltag,parent,metaidhash
; Add a structure (as a folder) to a widget tree
; Needs to recurse to go down the tree
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
ttag = idl_validname("t_"+tag,/convert_all)
Result = EXECUTE(ttag +" = widget_tree(parent,value='"+tag+"',uvalue='metadatatree',/folder)")
Result = Execute('t_tag  = '+ttag)
metaidhash += hash(fulltag,t_tag)

; Now get ready to recurse down this branch
result = execute('tags = tag_names('+fulltag+')')
result = execute('parentc='+ttag)
FOR i = 0, N_ELEMENTS(tags)-1 DO BEGIN
	tag = tags[i]
	fulltagc = fulltag+'.'+tag
	result = EXECUTE('type = size('+fulltagc+',/tname)')
	result = EXECUTE('dim = size('+fulltagc+',/dimension)')
	dim = dim > 1
	FOR j = 0,dim[0]-1 DO BEGIN
		tagp = tag
		IF (dim GT 1) then tagp = tag+'['+strtrim(string(j),1)+']'
		fulltagcp = fulltagc+'['+strtrim(string(j),1)+']'
		IF (type EQ 'STRUCT') THEN BEGIN  ; Branches
			addstruct2tree,metadata,tagp,fulltagcp,parentc,metaidhash
		ENDIF ELSE BEGIN
			result=EXECUTE('tagvalue = '+fulltagcp)
			addleaf2tree,metadata,tag,tagvalue,parentc
		ENDELSE
	ENDFOR
ENDFOR
return
END ; end addstruct2tree
