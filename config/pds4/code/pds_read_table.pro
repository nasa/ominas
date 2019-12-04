  FUNCTION PDS_READ_TABLE,unit,meta,cursor,Ntables,tabletype,nonans

  ; Get file offset and move file pointer
  offset = LONG(meta.offset._text)
  mrd_skip, unit,offset-cursor
  cursor = offset
  ending = '(__[0-9]+)?'
  ; Number of records
  records = LONG(meta.records._text)
   
  suffix = "_" + tabletype  
  CASE tabletype OF

    "BINARY": BEGIN
        recordMeta = meta.record_binary
        record_length = LONG(recordMeta.record_length._text)           
    END
    "CHARACTER": BEGIN
        recordMeta = meta.record_character 
        record_length = LONG(recordMeta.record_length._text)     
    END
    "DELIMITED": BEGIN      
	field_delimiter = STRLOWCASE(meta.field_delimiter._text)
        CASE field_delimiter OF
            'comma':           field_delimiter = ","
            'horizontal tab':  field_delimiter = STRING(9B)
            'semicolon':       field_delimiter = ';'
            'vertical bar':    field_delimiter = '|'
             ELSE: BEGIN
                  PRINT,'pds_read_table: field_delimiter not valid, ',meta.field_delimiter._text
                  RETURN,0
             END
        ENDCASE
            
        record_delimiter = meta.record_delimiter._text 
        recordMeta = meta.record_delimited     
    END ; delimited 
    
  ENDCASE ; tabletype
	
  ; Fields is total number of columns, but some may be arrays
  fields = LONG(recordMeta.fields._text)

  ; Presumably every field has a name, so use that to get Nfields
  names = getTagsByName(recordMeta, $
	'\.FIELD'+suffix+ending+'.NAME._TEXT',/getValues)
  Nfields = N_ELEMENTS(names)
	
  IF (tabletype NE 'DELIMITED') THEN BEGIN
     ; We can order by either field_locations or group_location at the top level
     locations = LONG64(getTagsByName(recordMeta, $
         '^\.(GROUP_)?FIELD'+suffix+ending $
         + '\.((GROUP)|(FIELD))_LOCATION._TEXT',/getValues))
     arraynum = SORT(locations) 
     names = names[arraynum]
     locations = locations[arraynum]
  ENDIF
	
  ; Gettagsbyname does not necessarily get order correct, so we will
  ; need to get names again as we go.
	
  ; Declare lengths of arrays needed
  name = STRARR(Nfields)
	;field_number = LONARR(Nfields)
	datatype = STRARR(Nfields)
	field_length = INTARR(Nfields)
	description = STRARR(Nfields)
	value_offset = DBLARR(Nfields)
	scaling_factor = DBLARR(Nfields)
	scaling = BYTARR(Nfields)
	; Repetitions holds dimensions of array for fields
	; Only permit up to 3 dimensional arrays for now
	repetitions = LONARR(Nfields,3)
	; Usually field is dimension [1,0,0] so that is default.
	repetitions[*,0] = 1
	missing = STRARR(Nfields)
  IF (tabletype EQ 'CHARACTER' OR tabletype EQ 'DELIMITER') THEN BEGIN
   field_format = STRARR(Nfields)
   field_format_fortran = STRARR(Nfields)
  ENDIF
	
  ;  Now gather info from metadata
  ; Find repetitions of fields.  If more than 1 it is an array.
  igrp0 = 0
  fnum = 0
  groupTags = getTagsByName(recordMeta, $
	 '^\.GROUP_FIELD'+suffix+ending+'$', count = Ngroups)
  FOR igrp = 0, Ngroups - 1 DO BEGIN
 	groupMetas = getTagsByName(recordMeta,'^'+groupTags[igrp]+'$',/getValues)
 	; In case group is an array in the metadata, there is another FOR loop
	FOR jgrp = 0, N_ELEMENTS(groupMetas)-1 DO BEGIN 
	  dim = 0
	  groupMeta = groupMetas[jgrp]
	  ; We look ahead within groupMeta for name and this also 
	  ; gives us arraynumber
	  grpfieldname = getTagsByName(groupMeta,"FIELD"+suffix+"\.NAME._TEXT",$
			  /getValues)
	  arraynumber = WHERE(names EQ grpfieldname[0],ngrp)
	  Nrepeats  =  LONG(groupMeta.repetitions._text)
	  repetitions[arraynumber,dim++] =  Nrepeats
	  ; If there are Group_Fields children of Group_Field then
	  ; it is multidimensional (ie dim > 1) 
	  FOR level = 1, 2 do begin
	     subgroupMeta = getTagsByName(groupMeta,'^.GROUP_FIELD'+suffix+'$',/getValues)
	     IF ISA(subgroupMeta,'STRUCT') THEN BEGIN
	       groupMeta = subgroupMeta
	       Nrepeats  =  LONG(groupMeta.repetitions._text)
	       repetitions[arraynumber,dim++] =  Nrepeats
	    ENDIF ELSE BREAK
	  ENDFOR
	ENDFOR
  ENDFOR

  ; Get tagnames of all fieldmeta, some may be in groups.
  fieldTags = getTagsByName(recordMeta,'\.FIELD'+suffix+ending+'$',count=NfieldTags)
  FOR itags = 0, NfieldTags - 1 DO BEGIN
     Result = EXECUTE('fieldMeta = recordMeta' + fieldTags[itags])
     FOR ifld = 0, N_ELEMENTS(fieldMeta) - 1 DO BEGIN
        thisname = fieldMeta[ifld].name._text
        fnum = WHERE(names EQ thisname)

	; Take care of specific commonly used IDLinvalid characters
	thisname = STRJOIN(STRSPLIT(thisname,'+',/extract,/preserve),'plus')
	thisname = STRJOIN(STRSPLIT(thisname,'-',/extract,/preserve),'minus')
	thisname = STRJOIN(STRSPLIT(thisname,'/',/extract,/preserve),'div')
	thisname = STRJOIN(STRSPLIT(thisname,'*',/extract,/preserve),'times')
	thisname = STRJOIN(STRSPLIT(thisname,'#',/extract,/preserve),'hash')
	name[fnum] = thisname
		  
	;field_number[fnum] = LONG(fieldMeta[ifld].field_number._text)
	datatype[fnum] = STRTRIM(fieldMeta[ifld].data_type._text,2)
        IF (tabletype NE 'DELIMITED') THEN $
            field_length[fnum] = FIX(fieldMeta[ifld].field_length._text)
			
	; For character data, we may have format information.
        IF (tabletype EQ 'CHARACTER') THEN $
           IF (WHERE(get_tags(fieldMeta) EQ ".FIELD_FORMAT._TEXT") NE -1) THEN $
              field_format[fnum] = fieldMeta[ifld].field_format._text $
              ELSE field_format[fnum] = ""  
   
        ; See if there are field descriptions in the metadata.
	test=gettagsbyname(fieldMeta[ifld],'\.description',count=nd)
	IF (nd gt 0) THEN $
	   description[fnum] = fieldMeta[ifld].description._text $
	   ELSE description[fnum] = ''
			
	; See if there are any special constants	
	test = getTagsByName(fieldMeta,"\.SPECIAL_CONSTANTS$",count=nspecial)
	IF (nspecial GT 0) THEN BEGIN
	  ; See if there are constants for missing data
	  test = getTagsByName(fieldMeta[ifld],$
		  "\.SPECIAL_CONSTANTS.MISSING_CONSTANT$",count=nmissing)
          IF (nmissing GT 0) THEN $
	     missing[fnum] = fieldMeta[ifld].special_constants.missing_constant._text
	  ; The only special constants handled so far are missing constants.
        ENDIF
 
        ; Get offets and factors for each field
        value_offset[fnum] = gettagsbyname(fieldMeta[ifld],'.value_offset._text$',$
		/getvalues,count=noffset)
        IF noffset EQ 0 THEN value_offset[fnum] = 0.0D
        scaling_factor[fnum] = gettagsbyname(fieldMeta[ifld],$
		'.scaling_factor._text$',/getvalues,count=nscale)
        IF nscale EQ 0 THEN scaling_factor[fnum] = 1.0D
        IF ~(scaling_factor[fnum] EQ 1.0d0 AND value_offset[fnum] EQ 0.0d0) THEN $
		scaling[fnum] = 1
     ENDFOR ; ifld
  ENDFOR ; ntag
  tags = IDL_VALIDNAME(name, /convert_all, /convert_spaces) 

  ; Make structure for missing_constants
  missingstr = ''
  FOR dd = 0, Nfields-1 DO BEGIN
     IF (missing[dd] NE '') THEN BEGIN
	CASE  datatype[dd] of 
           'ASCII_Real' :               missingstr += ','+tags[dd]+' : '+STRING(DOUBLE(missing[dd]))
           'ASCII_Integer' :            missingstr += ','+tags[dd]+' : '+missing[dd] 
           'ASCII_NonNegative_Integer': missingstr += ','+tags[dd]+' : '+missing[dd]
           ELSE :                       missingstr += ','+tags[dd]+' : " "'
        ENDCASE
     ENDIF ELSE                         missingstr += ','+tags[dd]+' : " "'
  ENDFOR
  missingstr = STRMID(missingstr,1)
  Result = EXECUTE('missing_constants = {'+missingstr+'}')  
  descriptions = CREATE_STRUCT(tags[Nfields-1],description[Nfields-1]) 
  FOR dd = Nfields-2, 0, -1 DO $
	descriptions = CREATE_STRUCT(tags[dd], description[dd],descriptions)
  recordstruc = create_tablestruc(tags,datatype,repetitions, field_length,tabletype)
  recordarr = REPLICATE(recordstruc, records)
	
  CASE tabletype OF
     "BINARY": BEGIN
	     READU, unit, recordarr, transfer_count=rows_read
	     ;PRINT,' Rows Read ', rows_read
	    ; PRINT,' Rows Expected ', records
	     cursor = cursor + records*record_length
	     ;print,cursor
	     ;point_lun,-unit,cc
	     ;print,cc
	     ; Check if this computer is little endian
	     little_endian = (BYTE(1, 0, 1))[0]
	     ; If any of the fields are the wrong endian we need to byteswap them
	     FOR i = 0, Nfields - 1 DO BEGIN
	         IF (STRPOS(datatype[i],'MSB') NE -1) THEN $   
	              recordarr.(i) = SWAP_ENDIAN(recordarr.(i),/SWAP_IF_LITTLE_ENDIAN)
                 IF (STRPOS(datatype[i],'LSB') NE -1) THEN $
                      recordarr.(i) = SWAP_ENDIAN(recordarr.(i),/SWAP_IF_BIG_ENDIAN)
             ENDFOR
	  END ;  end binary
	  
      "CHARACTER": BEGIN
	   ; Handle spaces between fields
	   spaces = INTARR(Nfields)
	   nX = STRARR(Nfields)

           ; First space is just a skip to locations.
           ; Subtract 1 because one needs no skip to location = 1.
	   spaces[0] = locations[0] - 1
	   ; Spaces are difference between next location and end of field.
	   FOR kk = 1, Nfields-1 DO $
	         spaces[kk] = locations[kk] - (locations[kk-1] + field_length[kk-1])

	   ; If there is space between fields creat a string "nX, "
	   whspace = WHERE(spaces NE 0, ncount)
	   IF (ncount NE 0) THEN $
	         nX[whspace] = STRTRIM(STRING(spaces[whspace]),1) + "X, "

	   FOR i = 0, Nfields-1 DO BEGIN
	        ; Create format string using C printf-Style Quoted String Format Codes
	        ; Convert to Fortran style (C-style just doesn't work in readf despite
	        ;   what the help pages say)
	        ; If c-format is given convert to fortran because that is what IDL uses.
	        IF (STRPOS(field_format[i],'%') NE -1) THEN BEGIN
	           field_format_fortran[i] = convert_codes(field_format[i])
	        ENDIF ELSE BEGIN
	           ; Either there is fortran format or we create it
	           ; If we create it then we use 0 precision for reals and let the
	           ; decimal place  in the data override this.
	           length = STRTRIM(STRING(ABS(field_length[i])),2)
	           ; Handle even if there is no field_format info
	           IF (field_format[i] EQ "") THEN BEGIN
	              CASE datatype[i] OF
	               'ASCII_Integer':                field_format_fortran[i]="I"+length
	               'ASCII_Real':                   field_format_fortran[i]="D"+length+".0"
	               'ASCII_Numeric_Base2':          field_format_fortran[i]="A"+length 
                       'ASCII_Numeric_Base8':          field_format_fortran[i]="O"+length
                       'ASCII_Numeric_Base16':         field_format_fortran[i]="Z"+length
	               ELSE:                           field_format_fortran[i]="A"+length
	              ENDCASE

	           ;If not C-format and not blank, format must be Fortran
	           ENDIF ELSE field_format_fortran = field_format
	        ENDELSE
	   ENDFOR
	 
	   formatString = '(' + nX[0] + field_format_fortran[0]
	   FOR i = 1, Nfields-1 DO $
	       formatString += ", " + nX[i] + field_format_fortran[i]
	   formatString += ')'
	   ; print,'FormatString: ', formatstring
	   ;  Read entire datafile in one go with a structure array
	   READF, unit, recordarr, format = formatString
	   cursor = cursor + records*record_length
	     
	   ; Replace missing constants with NANs for reals unless noNans is set
	   IF  ~KEYWORD_SET(noNANs) THEN BEGIN
               FOR ifld = 0, Nfields - 1 DO BEGIN
                  IF (missing[ifld] NE '') THEN BEGIN
                     whnull = WHERE(recordarr.(ifld) EQ missing[ifld], Nnull)
                     IF (Nnull NE 0) THEN BEGIN
                        IF (datatype[ifld] EQ 'ASCII_Real') THEN BEGIN
                          recordarr[whnull].(ifld) = !VALUES.D_NAN
                          missing_constants.(ifld) = !VALUES.D_NAN
                        ENDIF
                     ENDIF
                  ENDIF
               ENDFOR
           ENDIF
	   ; Write a binary or character version
	   ;OPENW, /get_lun, wunit, 'mydata.bin'
	   ;PRINTF, wunit, recordarr, format=formatString
	   ; WRITEU, wunit, recordarr
	   ;free_lun, wunit
	  END ; END "CHARACTER"
	 
         "DELIMITED": BEGIN
	     ; Read datafile
	     line = ''
             FOR irec = 0, records - 1 DO BEGIN
	        READF, unit, line
	        cursor += STRLEN(line)
                ; Remove double quotes on strings
                ; remove quotes at beginning
                cvars = strsplit(line,'"',count=count,/extract,/preserve_null)
                IF (count GT 1) THEN line = STRJOIN(cvars)
	   
	        ; Split line by delimiter
                vars = STRSPLIT(line,field_delimiter,/preserve_null,/extract)
                vars = STRTRIM(vars,2)
                indx2 = -1
          
                ; If missing delimiters at the end of the record, 
		; fill vars out with nulls.
                NfieldsIn = N_ELEMENTS(vars)
                ncols = TOTAL(repetitions)
                IF (NfieldsIn LT ncols) THEN $
                    FOR kk = 0, ncols - NfieldsIn -1 DO vars = [vars,''] 

                FOR ifld = 0, Nfields-1 DO BEGIN
	           indx1 = indx2 + 1
                   indx2 = indx1 + repetitions[ifld]-1
                   recordarr[irec].(ifld) =  vars[indx1:indx2]
	           ; Handle nulls in delimited data
	           ; Insert NANs for reals and doubles unless noNans is set
                   ; For numbers IDL has set these nulls to 0, but that is not
                   ; what we want typically.
                   whnull = WHERE(vars[indx1:indx2] EQ '')
                   IF (whnull[0] NE -1) THEN BEGIN
                      IF (datatype[ifld] EQ 'ASCII_Real') THEN BEGIN
                         IF  ~KEYWORD_SET(noNANs)  THEN BEGIN
                           recordarr[irec].(ifld)[whnull] = !VALUES.D_NAN
                           missing_constants.(ifld) = !VALUES.D_NAN
                         ENDIF ELSE BEGIN
                           IF (missing[ifld] NE '') THEN BEGIN
                              recordarr[irec].(ifld)[whnull] = missing[ifld]
                              missing_constants.(ifld) = missing[ifld]
                           ENDIF ELSE BEGIN
                              min1 = MIN(recordarr[irec].(ifld))
                              missing_constants.(ifld) = min1 - 1
                              recordarr[irec].(ifld)[whnull] = STRING(min1 - 1)
                           ENDELSE
                         ENDELSE                           
	              ENDIF ; ASCII_Real datatype
                      ; There is no NaN equivalent for integers so we always
                      ; fill nulls with a missing value
                      ;  Here missing value is 1 less than minimum of field
	              IF (datatype[ifld] EQ 'ASCII_Integer') THEN BEGIN
                        min1 = MIN(recordarr[irec].(ifld))
                        missing_constants.(ifld) = min1 - 1
                        recordarr[irec].(ifld)[whnull] = STRING(min1 - 1)
                      ENDIF
                   ENDIF ; null elements  
	        ENDFOR ; loop on ifld
             ENDFOR  ; loop on irec	   
      END  ; delimited case
  ENDCASE ; on tabletype

  ; Handle value_offset and value_scale
  ; With scaling we always output a double, 
  ; but that means we may need to create a new structure to change
  ; the datatype of certain fields.
  IF TOTAL(scaling NE 0) THEN BEGIN
     whscale = WHERE(scaling NE 0,Nscaling)
     restruc = 0
     ; If any fields where rescaling is made are not double, then restructure
     FOR i = 0, Nscaling-1 DO $
	IF (size(recordarr.(whscale[i]),/tname) NE 'DOUBLE') THEN restruc=1
     IF (restruc EQ 1) THEN BEGIN
       IF tabletype EQ 'BINARY' THEN datatype[whscale] = 'IEEE754MSBDouble' $
          ELSE datatype[whscale] = 'ASCII_Real'
       recordstruc = create_tablestruc(tags,datatype,repetitions, field_length,tabletype)
       r2 = REPLICATE(recordstruc, records)
       FOR ifld = 0, Nfields-1 DO r2.(ifld) = recordarr.(ifld)
       recordarr = r2 
     ENDIF
     FOR ifld = 0, Nfields-1 DO BEGIN
       ; output value = (FITS value) * BSCALE + BZERO
       IF (scaling[ifld] EQ 1) THEN BEGIN
	 recordarr.(ifld) *= scaling_factor[ifld]
         recordarr.(ifld) += value_offset[ifld]
       ENDIF
     ENDFOR
   ENDIF ; scaling 
   tablei = { descriptions : descriptions, $
	missing_constants : missing_constants, $
	recordarr : recordarr}           
    RETURN, tablei
END  ; end pds_read_table.pro
