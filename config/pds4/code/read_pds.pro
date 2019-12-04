FUNCTION READ_PDS,file,datastatus=datastatus,metadata=metadata, $
          noNANs=noNANs,version=version,dscale=dscale,no_reorient=no_reorient
;+
; NAME:
;	READ_PDS
;
; PURPOSE:
;	This reads metadata from PDS version 4 XML documents, using READ_XML, and
;	then reads the data in the datafile into an IDL structure.
;
; CATEGORY:
;	Datafile handling; PDS
;
; CALLING SEQUENCE:
;	data_struct = READ_PDS([file, datastatus=datastatus, metadata=metadata, 
;                                     dscale=dscale, version=version])
;
; INPUTS:
;	file - Name and path, if not current directory, of PDS XML document that
;	describes the data and datafiles.
;	However, if there is no file parameter, then a file selection 
;	window pops up to allow convenient selection of the PDS XML file.
;
; OUTPUTS:
;	data_struct - The data.  If the data is held in a FITS data file the output
;	is a structure holding pairs of headers and images/data. 
;	It also handles fixed format tables (TABLE_CHARACTER) by returning
;	a structure that is an array of structures.  
;	Each row (record) in the table is an element of the array with tagnames
;	given by the names given in the metadata.
;
;
; KEYWORDS:
;	datastatus - Relays error flags from the routines that read the data.
;
;	metadata - All of the metadata in the PDS XML documents.
;	
;	noNANs - Set this on if NANs are not wanted in real and double fields.
;
;	version - Prints out version of the code and continues.
;
;	dscale - Ensures scaling (scale_factor and value_offset) is done in double precision.
;
;	no_reorient - Set this flag on to prevent images from being reoriented 
;	according to sample_ and line_display_direction, so that they 
;	are displayed properly with the TV command.  Default reorients.
; 
; PROCEDURES USED:
;	READ_XML, XML2IDL, getTagsByName, PDS_READ_TABLE, PDS_OPEN, PDS_RD_IMAGE, PDS_RD_READ_IMAGE
;        
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; IDL VERSIONS TESTED: 
;	8.2
;
; MODIFICATION HISTORY:
;	Written by Ed Shaya / U. of Maryland [July 19, 2012].  Not yet complete.
;	Add Delimited Tables [Aug 20, 2012].
;	Add BINARY Tables [May 29, 2013].
;	Substantial rewrite to ensure info from XML is used
;	rather than headers.  Ed Shaya / U. of Maryland Oct. 22, 2013
;	Removed path keyword.  Now filename should contain path if needed Feb 4, 2014.
;	Sep 6, 2014 - Allow for groups inside of groups to form 2 or 3 dimensional arrays.  ES
;	Sep 6, 2014 - Reworked PDS datatype to IDL datatype table. ES
;	Sep 9, 2014 - Added scaling for fields in tables. ES
;	Sep 10, 2014 - Use local_identifier as structure tag names. ES
;	Nov 24, 2014 - Make table_name idl_valid when needed. ES
;	Nov 24, 2014 - Fixed a bug that prevented simple arrays in table fields.
;	Nov 24, 2014 - Fix for case where headers have no local identifiers
;  
;-
;-----------------------------------------------------------------	
  COMPILE_OPT idl2    

  COMMON openercom, fstate

  ;Begin the error handler:
  error_status = 0
  CATCH, Error_status
  IF Error_status NE 0 THEN BEGIN
    PRINT, 'Error index: ', Error_status 
    PRINT, 'Error message: ', !ERROR_STATE.MSG 
    CATCH, /CANCEL
    RETURN, Error_status 
  ENDIF 
  
  ending = '(__[0-9]+)?'
  ;   Display version
  IF KEYWORD_SET(version) THEN $
        PRINT,'read_pds: Beta Version, Oct 16, 2013'
  IF ~KEYWORD_SET(noNaNs) THEN noNaNs = 0
  IF ~KEYWORD_SET(file) THEN  BEGIN
	   xmlfile_opener
	   file=fstate.file
	   IF (file EQ '') THEN BEGIN
		   PRINT, 'read_pds: Blank file name'
		   PRINT, 'read_pds: Returning'
		   RETURN, -1
	   ENDIF
  ENDIF
  IF KEYWORD_SET(version) THEN RETURN, 0
  IF KEYWORD_SET(help) THEN BEGIN
           PRINT, 'read_pds: Usage'
           PRINT, '   data = read_pds(XMLfile, datastatus=datastatus, metadata=metadata
           PRINT, '                      noNANs=noNANs, version=version)
           RETURN, -1
  ENDIF
  filetest = file_search(file)
  IF (filetest EQ '') THEN BEGIN
     PRINT, 'read_pds: Cannot find xml file ', file 
     PRINT, 'read_pds: Returning'
     RETURN, -1
  ENDIF
  filename = FILE_BASENAME(file)
  path = FILE_DIRNAME(file)
  
  IF ~KEYWORD_SET(no_reorient) THEN no_reorient = 0

  result = -1
  idlVersion = FLOAT(!version.release)
  ; Read XML metadata file into structure named metadata
  metadata = read_xml(file)
  ; Get File_Area of metadata
  filearea = getTagsByName(metadata,'FILE_AREA_OBSERVATIONAL$',/getvalues,count=count)
  IF (count EQ 0) THEN BEGIN
    PRINT,'read_pds: No element FILE_AREA_OBSERVATIONAL.  Returning -2
    RETURN, -2
  ENDIF
  ; Get title text to use as name of output
  Identification_Area = getTagsByName(metadata,'Identification_Area$',/getvalues)
  title = Identification_Area.title._text
  execString = ''
  NHeaders = 0
  NTables = 0
  NImages = 0
  ; Top level elements in filearea is the datasets (header, images, tables, etc)
  dataset = getTagsByName(filearea,'^\.[^.]+$',count=nchild)  
  ; Remove '.' at beginning of each string
  dataset = STRMID(dataset,1)
        	
  FOR dd = 0, nchild-1 DO BEGIN
	dataseti =  dataset[dd]
	meta0 = filearea.(dd)
	; meta may be an array if there are two very similar datasets in a row
	FOR nmeta = 0, N_ELEMENTS(meta0) - 1 DO BEGIN
		meta = meta0[nmeta]
		; Split on '_' etc
		dataset_split = STRSPLIT(dataseti,'_',/extract)
		
		CASE dataset_split[0] OF

		  'FILE':  BEGIN 
		     ; datafile name
		     datafile = meta.file_name._text
		     creation_datetime = getTagsByName(meta,'^.creation_date_time._text',/getvalues)
		     IF (creation_datetime[0] EQ '-1') THEN $
			     creation_datetime = 'Unknown'
		     compress = ''
		     suffix = STRMID(datafile,STRPOS(datafile,'.',/reverse_search)+1)
                     IF (suffix EQ 'gz') THEN compress = 'gunzip'
                     IF (suffix eq 'z' or suffix eq 'Z') THEN $
			     compress = 'uncompress'
                     IF (suffix EQ 'bz2') THEN compress = 'bunzip2'
                     fullDatafile = path+'/'+datafile[0]
                     PRINT, 'read_pds: Data file is ', fullDatafile
                     ; open datafile 
		     filetest = file_search(fulldatafile)
		     IF (filetest EQ '') THEN BEGIN
			    PRINT, 'read_pds: Cannot find datafile ',fulldatafile 
			    PRINT, 'read_pds: Returning -2'
			    RETURN, -2
		     ENDIF
                     unit = pds_open(fulldatafile, 0, compress=compress, $
	             	/readonly, errmsg= errmsg)
	             cursor = 0L

                     ; openr,/get_lun,unit,fulldatafile
                  END

		  'HEADER': BEGIN 
         parsing_standard_id = meta.parsing_standard_id._text
         IF (STRMATCH(parsing_standard_id[0], 'FITS*')) $
            THEN dataIsFits = 1 ELSE dataIsFits = 0
	 offset = LONG64(meta.offset._text)
         offset_unit = getTagsByName(meta,'^.offset.unit',/getvalues)
         IF (offset_unit[0] NE "byte" AND offset_unit[0] NE "-1") THEN BEGIN
             PRINT, 'pds_rd: offset unit should be "byte", but it is "'+offset_unit+'" in the .xml file.'
             RETURN, 0
         ENDIF    
         ;point_lun,-unit,cc
         ;print,' point_lun before skip ',cc, cursor
         mrd_skip, unit, offset-cursor
         cursor = offset
         name = getTagsByName(meta,'^\.local_identifier._text',/getvalues)
         name = name[0]
         IF (name EQ '-1') THEN name = 'Unknown'
         name = IDL_VALIDNAME(name,/convert_all)
         ; description of header
         description = getTagsByName(meta,'^\.description._text',/getvalues)
         description = description[0]
         IF (description EQ '-1') THEN description = 'Unknown'  
         REPEAT BEGIN
            quote = STRPOS(description,'"')
            IF quote NE -1 THEN STRPUT,description,"'",quote
         ENDREP UNTIL (quote EQ -1)
              
         object_length = LONG64(getTagsByName(meta,'^\.object_length._text',/getvalues))
         object_length = object_length[0]
         IF (object_length EQ -1L) THEN BEGIN
             PRINT, 'read_pds: No length provided for header.  There may be padding left at the end of the header.'
             object_length = LONG64(filearead.(dd+1).offset._text) - cursor
         ENDIF ELSE BEGIN
	     hdr = ["NAME = Unknown","COMMENT = Unable to read header"]
;	     CASE parsing_standard_id of
;	        '7-Bit ASCII Text': BEGIN
;	           bytehdr = BYTEARR(object_length)
;	           READU,unit,bytehdr
;	           hdr = STRSPLIT(STRING(bytehdr),STRING(13b))
;  	     END
;			               
;	    'CDF 3.4 ISTP/IACG':
;	        'FITS 3.0':  mrd_hread, unit, hdr, status, errmsg=errmsg,/silent
;	        'ISIS2':
;  	        'ISIS3':
;	        'PDS DSV 1':
;	        'PDS ODL 2':
;	        'PDS3':
;	        'Pre-PDS3':

;	      'UTF-8 Text':  BEGIN
;                  bytehdr = BYTEARR(object_length)
;                  READU,unit,bytehdr
;                  hdr = STRSPLIT(STRING(bytehdr),STRING(13b))
;               END
;                   
;  	      'VICAR1':
;  	      'VICAR2':
;        ELSE: BEGIN
;        print, 'read_pds: parsing_standard_id of header,',$
;                parsing_standard_id,' is unknown'
;        print, 'Returning'
;        return,-1
;      END
;   ENDCASE
             IF (parsing_standard_id EQ 'FITS 3.0') THEN BEGIN
                bytehdr = BYTARR(object_length)
                ; point_lun,-unit,cc
                ;print,' cursor before readu',cc
                READU,unit,bytehdr
                ; point_lun,-unit,cc
                ;  print,' cursor after readu',cc
                cursor += object_length
                ; print,' cursor set to', cursor
                hdr = STRING(REFORM(bytehdr,80,object_length/80))
                lastcard = WHERE(STRMID(hdr,0,3) EQ 'END',count)
                IF (count NE 0) THEN hdr = hdr[0:lastcard[0]-1] $
                     ELSE $
                        PRINT,'read_pds: Warning: No END statement in FITS header'
                ;IF (STRMID(hdr[N_ELEMENTS(hdr)-1],0,2) EQ 'END') THEN $
	        ;hdr = hdr[0:N_ELEMENTS(hdr)-2] $
                ;ELSE $
                ;PRINT,'read_pds: Warning: No END statement in FITS header'
             ENDIF ELSE BEGIN
                  bytehdr = BYTARR(object_length)
                  READU,unit,bytehdr
                  cursor += object_length
                  hdr = STRSPLIT(STRING(bytehdr),STRING(13b))
             ENDELSE
	     ; IF (idlVersion ge 8.0) THEN $
	     ; hdr_0 = headertohash(hdr,comments=comments_0) 

             NHeaders++  ; increment image number and create a structure for array
             headern = 'header' + STRTRIM(STRING(NHeaders),1)
             IF (name EQ 'Unknown') THEN name = headern
             Result = EXECUTE(name + $
		 " = {name : name, description: description[0], header : hdr}")
             ; Prepare string for creating output structure
             execString += ', '+ name + ' : ' +  name
	 ENDELSE ; if object_length NE -1

		  END ; 'HEADER'

		  'ARRAY': BEGIN  
	 array_name = getTagsByName(meta,'^.local_identifier._text',/getvalues)
	 array_name = array_name[0]
	 IF (array_name EQ "-1") THEN array_name = 'Unknown'  
	 array_name = IDL_VALIDNAME(array_name,/convert_all)		     
	 offset = LONG64(meta.offset._text)
         offset_unit = getTagsByName(meta,'^.offset.unit',/getvalues)
         IF (offset_unit NE "byte" AND offset_unit NE "-1") THEN BEGIN
           PRINT, 'pds_rd: offset unit should be "byte", but it is "'+offset_unit+'" in the .xml file.'
             RETURN, 0
         ENDIF
         
         ; Bring file cursor up to offset
         IF (offset-cursor GT 0) THEN  BEGIN
            ;point_lun,-unit,cc
            ;print,' Before skip to Bring file cursor up ',cc
            mrd_skip, unit,offset - cursor
            ;point_lun,-unit,cc
            ;print,' Before skip to Bring file cursor up ',cc,' should be ', offset
            cursor = offset
         ENDIF    
         
         IF EOF(unit) THEN BEGIN
            MESSAGE,'ERROR - PAST EOF',/CON
            IF inputUnit EQ 0 THEN FREE_LUN,unit 
            status = -2
            RETURN, 0
         ENDIF
         
	 axis_index_order = STRUPCASE(STRTRIM(meta.axis_index_order._text,2))
	 special_tags = $
		getTagsByName(meta,'^\.Special_Constants.*_text',count=nspecials)
	 IF (nspecials GT 0) THEN BEGIN
	      tagvString = ""
	      FOR kk = 0, nspecials-1 DO BEGIN
	          Result = Execute("value = meta" + special_tags[kk]) 
	          tag = STRMID(special_tags[kk],19)
	          tag = STRMID(tag,0,STRLEN(tag)-6)
	          tagvString = tagvString + "," + tag + " : " + value 
	      ENDFOR   
   
	      Result = EXECUTE("special_constants =  {" + STRMID(tagvString,1) + "}")
	      specials = ' special_constants : special_constants, '
	 ENDIF ELSE specials = ''
			   
	 ; Units for array in Element_Array
	 units = getTagsByName(meta,'^\.Element_Array.unit._text',/getvalues)
	 IF (units[0] EQ '-1') THEN units[0] = 'Unknown'

	 ; Info on each axis in Axis_Array
	 axis_name = getTagsByName(meta,'^\.Axis_Array'+ending+'.axis_name._text',/getvalues,count=nnames)
	 sequence_number = getTagsByName(meta,'^\.Axis_Array'+ending+'.sequence_number._text',/getvalues,count=nnumber)
	 axis_units = getTagsByName(meta,'^\.Axis_Array'+ending+'.axis_units._text',/getvalues,count=nunits)    
	 sequence_number = FIX(sequence_number)
         ; In case elements are not in sequence order
         indx = sequence_number - 1
         axis_name = axis_name[indx]
         axis_units = axis_units[indx]

         
         FOR kk = 0, N_ELEMENTS(axis_units)-1 DO $
              IF (axis_units[kk] EQ '-1') THEN axis_units[kk] = 'Unknown'
         IF (axis_index_order EQ 'LAST INDEX FASTEST') THEN $
              axis_name = REVERSE(axis_name)
         description = getTagsByName(meta,'.description._text$',/getvalues)
         
	 IF (description EQ '-1') THEN description = 'Unknown' ELSE description = description[0]
         REPEAT BEGIN
             quotes = STRPOS(description,'"')
             IF quotes NE -1 THEN STRPUT,description,"'",quotes
         ENDREP UNTIL quotes EQ -1
	 display_info = getTagsByName(meta,'^\.Display_2D_Image$',/getvalues,count=ndisplay)
	 IF (ndisplay GT 0) THEN BEGIN
	      line_display_direction = STRUPCASE(display_info.line_display_direction._text)
	      sample_display_direction = STRUPCASE(display_info.sample_display_direction._text)
	 ENDIF ELSE BEGIN
	     ; Use default values
	     line_display_direction = 'DOWN'
             sample_display_direction = 'RIGHT'
	 ENDELSE

	 scaling = 1		   
	 type = 0
	 silent = 0
	 arange = [-1,-1]
	 pds_rd_image, meta, arange, maxd, rsize, cursor, array0, scaling_factor,$
		value_offset, scaling, status, silent=silent, lsb=lsb
         IF status GE 0 AND rsize GT 0 THEN $
                pds_rd_read_image, unit, meta, arange, maxd, rsize, array0,$
                      status=status

         ; Re-orient image, unless no_reorient is  set 
         IF (no_reorient EQ 0 AND nnumber GT 1) THEN BEGIN
            PRINT,'read_pds: Re-orienting the image'
            IF (line_display_direction EQ 'UP' OR $
		  line_display_direction EQ 'DOWN') THEN BEGIN
                  ; IN IDL TV command rows go up the screen
                  IF (line_display_direction EQ 'DOWN') THEN $
			    array0 = REVERSE(array0,2)
	          ; Sample direction must be left or right.
                  IF (sample_display_direction EQ 'LEFT') THEN BEGIN
                     array0 = REVERSE(array0,1)
                  ENDIF ELSE BEGIN
                     IF (sample_display_direction NE 'RIGHT') THEN BEGIN
                        PRINT,'read_pds: Incompatible display_directions'
                        STOP
                     ENDIF
                  ENDELSE
            ENDIF; END UP or DOWN

            IF (line_display_direction EQ 'LEFT' OR $
		line_display_direction EQ 'RIGHT') THEN BEGIN
                  ; Transpose the first 2 dimensions
                  dims = INDGEN(SIZE(array0,/n_dimension))
	          dims[0:1] = [1,0]
                  ; Now sample is line and line is sample
                  array0 = TRANSPOSE(array0, dims)
                  IF (line_display_direction EQ 'LEFT') THEN $
                     array0 = REVERSE(array0,1)
	          ; Sample direction must be up or down.
                  IF (sample_display_direction EQ 'DOWN')  THEN BEGIN
                      array0 = REVERSE(array0,2)
                  ENDIF ELSE BEGIN
                      IF (sample_display_direction NE 'UP') THEN BEGIN
                        PRINT,'read_pds: Incompatible display_directions'
                        STOP
                      ENDIF
                  ENDELSE
	    ENDIF; end left or right
         ENDIF ; end no_reorient

         ; Swap endianess of array if needed             
         IF (LSB EQ 1) THEN $
                SWAP_ENDIAN_INPLACE, array0, /SWAP_IF_BIG_ENDIAN $
         ELSE $
                SWAP_ENDIAN_INPLACE, array0, /SWAP_IF_LITTLE_ENDIAN
                
         ; Scale the data if needed       
         IF (scaling eq 1) THEN BEGIN
            IF KEYWORD_SET(dscale) THEN $
                array0 = TEMPORARY(array0)*scaling_factor[0]+value_offset[0] $
            ELSE $
                array0 = TEMPORARY(array0)*FLOAT(scaling_factor[0]) + FLOAT(value_offset[0]) 
         ENDIF
         NImages++  ; incriment the image number and create a structure for array
         imagen = 'Array' + STRTRIM(STRING(NImages),1)
         IF (array_name EQ 'Unknown') THEN array_name = imagen
         Result = EXECUTE(array_name + " = { array_type : dataseti, " + $
                 "description: description[0], units : units[0], " + $
                 "axis_names : axis_name, axis_units : axis_units, " + $
                 "line_display_direction : line_display_direction, " + $
                 "sample_display_direction : sample_display_direction, " + $
                 specials + $
                 "array : array0}")
         ; Prepare string for creating output structure
         execString += ', '+ array_name + ' : ' + array_name
		  END ; 'ARRAY_2D_IMAGE'

	
		  'TABLE': BEGIN    
	 tabletype = dataset_split[1]
	 Ntables++
	 tablen = 'table' + STRTRIM(STRING(Ntables),1)

	 ; If there is a local_identifier use that for tablename.
	 table_name = getTagsByName(meta,'^.local_identifier._text', /getvalues)
	 IF (table_name[0] EQ "-1") THEN $  
	 table_name = getTagsByName(meta,'^.name._text', /getvalues)
	 ; Use name if no local_identifier and Make name idl valid, if needed.
	 IF (table_name[0] EQ "-1") THEN table_name = tablen ELSE $
	    table_name = IDL_VALIDNAME(table_name[0],/convert_all,/convert_spaces) 

	 table = pds_read_table(unit,meta,cursor,Ntables,tabletype,nonans)
	 Result = EXECUTE(table_name + " = table")
	 execString += ', '+ table_name + ' : ' + table_name
		  END ; 'TABLE'

	          ; Ignore comments at this level
	          'COMMENT': 
	    
		  ELSE: BEGIN
		      PRINT,' This format is unknown ', dataseti
		      Stop
		   ; Bundle
		   ; Bundle_Member_Entry
		   ; Encoded_Image
		   ; Header_Encoded
		   ; Stream_Text
		   
		   
		  END
	  ENDCASE
	
    ENDFOR; end loop on nmeta
  ENDFOR ; end loop on dataset[dd]
  FREE_LUN, unit
  ; Now make data_struct with all substructures

  Result = EXECUTE('data_struct = { title : title, date : systime(), creation : creation_datetime[0], data_file : datafile' + execString + '}')
  
  RETURN, data_struct

END ; FUNCTION READ_PDS
