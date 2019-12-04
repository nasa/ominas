PRO browse_event,ev  ; Event Handler
  ; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
  COMMON browsec2, status, data, metadata, returning, idhash, metaidhash, metavalues,ytitle
  WIDGET_CONTROL, ev.id, get_uvalue=uvalue        ; get the uvalue
  psym = 1
  csize = 1.5
  Rtype = SIZE(returning,/type)       
  IF (Rtype EQ 0) THEN RETURN
  Rdim = SIZE(returning,/n_dim)
  datatreeselect = 0
  CASE uvalue OF
      'maxcounts' : BEGIN
	  ;First check that it is a numeric 2+ dim array
          IF (Rtype LE 5) THEN BEGIN
               ; Event from Maxcounts slider
               maxcnts = ev.value
               WIDGET_CONTROL,status.sldminid,get_value=mincnts
               CASE Rdim OF
                   1: PLOT,returning,psym=psym,ytitle=ytitle,charsize=csize,$
			   symsize=1,yrange=[mincnts,maxcnts+0.05*abs(maxcnts)],ystyle=1,$
			   xtitle='Table Row'
                   2: tvit,returning,mincnts,maxcnts-mincnts
                   3: tvit,returning[*,*,0],mincnts,maxcnts-mincnts
                   4: tvit,returning[*,*,0,0],mincnts,maxcnts-mincnts
                   5: tvit,returning[*,*,0,0,0],mincnts,maxcnts-mincnts
                   ELSE: PRINT, 'browse_event: Cannot browse image of ',Rdim,' dimensional array.'
               ENDCASE
           ENDIF
      END ; end maxcounts
                  
      'mincounts' : BEGIN
          IF (Rtype LE 5) THEN BEGIN
              ; Event from Mincounts slider
              mincnts = ev.value
              WIDGET_CONTROL,status.sldmaxid,get_value=maxcnts
              CASE Rdim OF
                  1: BEGIN
			  PLOT,returning,psym=psym,ytitle=ytitle,charsize=csize,$
				  symsize=1,yrange=[mincnts,maxcnts+0.05*abs(maxcnts)],$
				  ystyle=1,xtitle='Table Row'
                      END
                  2: tvit,returning,mincnts,maxcnts-mincnts
                  3: tvit,returning[*,*,0],mincnts,maxcnts-mincnts
                  4: tvit,returning[*,*,0,0],mincnts,maxcnts-mincnts
                  5: tvit,returning[*,*,0,0,0],mincnts,maxcnts-mincnts
                  ELSE: PRINT, 'browse_event: Cannot browse image of ',Rdim,' dimensional array.'
              ENDCASE 
          ENDIF
       END ; end mincounts

      'draw': BEGIN
          IF (PTR_VALID(status.imagePTR)) THEN BEGIN
          dims = size(*status.imagePTR,/dim)
          xpix = floor(ev.X/status.zoomf)
          ypix = floor(ev.Y/status.zoomf)
             IF (xpix LT dims[0] AND ypix LT dims[1]) THEN BEGIN
                WIDGET_CONTROL, status.X, SET_VALUE='X pixel: ' + $
		     STRTRIM(STRING(xpix),2)
                WIDGET_CONTROL, status.Y, SET_VALUE='Y pixel: ' + $
		     STRTRIM(STRING(ypix),2)
                WIDGET_CONTROL, status.ImValue, SET_VALUE= 'Value : ' + $
		     STRTRIM(STRING((*status.imagePTR)[xpix,ypix]),2)
             ENDIF
          ENDIF
      END

      'datatext': BEGIN
         ;Event from Data Combobox
         value = '*'+STRTRIM(STRUPCASE(ev.str),2) + '*'
         newvalues = gettagsbyname(data,value,/simple,root='DATA')
         value = newvalues[0]
         IF idhash.Haskey(value) THEN BEGIN
            WIDGET_CONTROL,status.datatextid,set_value=newvalues
            rtn = value
            ;Expand datatree nodes that are parents of node
            pvalue = ''
            parent = rtn
            WHILE (pvalue NE parent) DO BEGIN
               pvalue = parent
               ppos = STRPOS(pvalue,'.',/reverse_search)
               IF (ppos NE -1) THEN BEGIN
                  parent = STRMID(pvalue,0,ppos)
                  WIDGET_CONTROL,idhash(parent),set_tree_expanded=1
               ENDIF
            ENDWHILE
            ;Now select the node that user entered in datatext
            WIDGET_CONTROL,idhash(rtn),set_tree_select=1
         ENDIF ELSE BEGIN
         PRINT,'browse_event: No valid tag ',ev.str
         ev.type = 1
         ENDELSE
      END

      'metadatatext': BEGIN
         ;Event from Metadata Combobox
         IF (ev.index NE -1) THEN BEGIN
            ;Event from droplist menu in combobox
            ;Use ev.index to determine which one
            value = metavalues[ev.index]
            count = 1
         ENDIF ELSE BEGIN
            ;Event from editable line in Combobox
            ;Add wildcard to BEGINning of search string
            value = '*'+STRTRIM(STRUPCASe(ev.str),2)
            ;Escape (add backslash) to  any '[' or ']' in string
            parts = STRSPLIT(value,'[',/extract,/preserve_null)
            value = STRJOIN(parts,'\[')
            parts = STRSPLIT(value,']',/extract,/preserve_null)
            value = STRJOIN(parts,'\]')
            ;Add '*' before each dot.  Matches andy sequence up to a dot
            parts = STRSPLIT(value,'.',/extract,/preserve_null)
            value = STRJOIN(parts,'*.')
            ;Add '*' at the END
            value = value + '*'
            ;BEGIN Searching all keys in metaidhash
            keys = metaidhash.Keys()
            ;Convert list to array
            keys = keys.ToArray()
            match = WHERE(STRMATCH(keys,value) EQ 1,count) 
            IF (count GT  0) THEN BEGIN
               newvalues = keys[match]
               metavalues = newvalues
               value = newvalues[0]
            ENDIF
         ENDELSE
         IF (count GT  1) THEN  BEGIN
            ;Place search results onto dropdown menu in combobox
            ;Trim '[n]' from strings
            FOR i=0,count-1 DO BEGIN
               s = STRPOS(newvalues[i],'[')
               WHILE (s NE -1) DO BEGIN
                  first = STRMID(newvalues[i],0,s)
                  e = STRPOS(newvalues[i],']')
                  IF (e LT STRLEN(newvalues[i])-1) THEN $
                    newvalues[i] = first + STRMID(newvalues[i],e+1) $
                      ELSE $
                         newvalues[i] = first
                  s = STRPOS(newvalues[i],'[')
               ENDWHILE
            ENDFOR
            WIDGET_CONTROL,status.metadatatextid,set_value=newvalues
         ENDIF
         IF (count GT  0) THEN BEGIN
            rtn = value
            ;Expand metadatatree nodes that are parents of node
            pvalue = ''
            parent = rtn
            WHILE (pvalue NE parent) DO BEGIN
               pvalue = parent
               ppos = STRPOS(pvalue,'.',/reverse_search)
               IF (ppos NE -1) THEN BEGIN
                  parent = STRMID(pvalue,0,ppos)
                  WIDGET_CONTROL,metaidhash(parent),set_tree_expanded=1
               ENDIF
            ENDWHILE
	    IF (rtn NE '') THEN BEGIN
              ; Now select the node that user entered in datatext
              WIDGET_CONTROL,metaidhash(rtn),set_tree_select=1
              rtn = rtn[0]
              Result = EXECUTE('returning = '+rtn)
              Rdim = SIZE(returning,/n_dim)
              type = SIZE(returning,/tname)
            ENDIF
         ENDIF ELSE BEGIN
            PRINT,'browse_event: No valid tag ',ev.str
         ENDELSE
      END

      'datatree': BEGIN
         ;Event from Data Tree
         IF (ev.type EQ 1) THEN uvalue = 'openfolder'
         IF (ev.type EQ 0 AND idhash.Where(ev.id) ne '') THEN BEGIN
            rtn=idhash.Where(ev.id)
            rtn=rtn[0]
            WIDGET_CONTROL,status.datatextid,set_value=rtn
         ENDIF
      END

      'metadatatree': BEGIN
         ;Event from Metadata Tree
         IF (ev.type EQ 0 and metaidhash.Where(ev.id) ne '') THEN BEGIN
            rtn = metaidhash.Where(ev.id)
            ; Just take first of matching key to id, although
            ; there should be just one, but need this anyway
            ; to convert list to string
            rtn = rtn[0]
            WIDGET_CONTROL,status.metadatatextid,set_value=rtn
            Result = EXECUTE('returning = '+rtn)
            Rdim = SIZE(returning,/n_dim)
            type = SIZE(returning,/tname)
         ENDIF
      END

      'quit' : WIDGET_CONTROL, ev.top, /destroy

      ELSE: 
  ENDCASE

  IF (uvalue EQ 'datatext' OR uvalue EQ 'datatree' )THEN BEGIN
     Result = EXECUTE('returning = '+rtn)
     Rdim = SIZE(returning,/n_dim)
     dim = SIZE(returning,/dim)
     type = SIZE(returning,/tname)
     Nreturn = N_ELEMENTS(returning)
  
     ;IF rtn is string array use xdisplayfile
     IF (type EQ 'STRING') THEN BEGIN
        ERASE  ;Erase the previous image in the draw widget
        ;Display headers in scrollable text window
        width = 80
        height = Nreturn < 40
        IF (Nreturn EQ 1) THEN width = 50 > STRLEN(STRTRIM(returning,2)) < 80
        XDISPLAYFILE,'',text=STRING(returning),title=rtn,width=width,$
        height=height
     ENDIF ELSE BEGIN
         ;Plot 1 dimensional field, must have more than one element
         ; and must not be a structure
         IF (Rdim EQ 1 and dim[0] GT  1 AND type NE 'STRUCT') THEN BEGIN
            mmincnts = MIN(returning,/nan)
            mmaxcnts = MAX(returning,/nan)
            mincnts = mmincnts
            maxcnts = mmaxcnts
	    ytitle = STRMID(rtn,5)
            PLOT,returning,psym=psym,ytitle=ytitle,charsize=csize,symsize=1,$
               yrange=[mincnts,maxcnts+0.05*abs(maxcnts)],xtitle='Table Row'
            WIDGET_CONTROL,status.sldminid,set_value=[mincnts,mmincnts,mmaxcnts]
            WIDGET_CONTROL,status.sldmaxid,set_value=[maxcnts,mmincnts,mmaxcnts]
         ENDIF ; if Rdim eq 1
         ;Produce grey scale image of 2-d (or more) arrays
         IF (Rdim GE 2 AND dim[0] GT 1 AND type NE 'STRUCT') THEN BEGIN
            CASE Rdim OF
               2: tvimg = returning
               3: tvimg = returning[*,*,0]          
               4: tvimg = returning[*,*,0,0]
               5: tvimg = returning[*,*,0,0,0]
               ELSE: PRINT, 'browse_event: Cannot browse image of ',Rdim,$
                  ' dimensional array.'
            ENDCASE
            mmincnts = MIN(tvimg,/nan)
            mincnts = mmincnts
            mmaxcnts = MAX(tvimg,/nan)
            maxcnts = mmaxcnts
            tvit,tvimg,mincnts,maxcnts-mincnts,zoomf=zoomf
            IF (SIZE(tvimg,/tname) EQ 'BYTE') THEN tvimg = FIX(tvimg)
            WIDGET_CONTROL,status.sldminid,set_value=[mincnts,mmincnts,mmaxcnts]
            WIDGET_CONTROL,status.sldmaxid,set_value=[maxcnts,mmincnts,mmaxcnts]
            status.imagePTR = PTR_NEW(tvimg, /no_copy)
            status.zoomf = zoomf

         ENDIF ; If Rdim ge 1
      ENDELSE ; If returning not a string
  ENDIF ; uvalue is datatext or datatree

  RETURN
END ; END browse_event

