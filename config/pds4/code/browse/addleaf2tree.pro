PRO addleaf2tree,metadata,tag,tagvalue,parent
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
	IF (tag NE '_TEXT') THEN $
		tagvalue = tag+" = "+tagvalue
	  ttag = IDL_VALIDNAME("t_"+tag,/convert_all)
	   IF (STRPOS(tagvalue,"'") EQ -1) THEN $
	         Result = EXECUTE(ttag +" = widget_tree(parent,value='"+tagvalue+"')") $
	   ELSE $
	         Result = EXECUTE(ttag +' = widget_tree(parent,value="'+tagvalue+'")')
	return
END ; end addleaf2tree
