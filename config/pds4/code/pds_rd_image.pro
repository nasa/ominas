; This file contains pds_rd_chkfn, pds_rd_read_image,pds_rd_axes_trunc,
; pds_rd_image

;  Check that this name is unique with regard to other column names.
FUNCTION pds_rd_chkfn, name, namelist, index 
 COMPILE_OPT idl2, hidden
    maxlen = 127
    IF (STRLEN(name) GT maxlen) THEN name = STRMID(name, 0, maxlen) 
    w = WHERE(name eq STRMID(namelist, 0, maxlen) )
    IF (w[0] NE -1) THEN BEGIN
        ; We have found a name conflict. 
            name = 'gen$name_'+STRCOMPRESS(STRING(index+1),/remove_all) 
    ENDIF 
    RETURN, name 
END
;--------------------------------

; Read in the image information. 
PRO pds_rd_read_image, unit, meta, range, maxd, rsize, array, rows = rows,status=status
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
 COMPILE_OPT idl2, hidden
    ; 
    ; Unit          Unit to read data from. 
    ; array         Table/array to read information into. 

    error=0
    CATCH,error
    IF (error NE 0) THEN BEGIN
      CATCH,/cancel
      status=-2
      RETURN
    ENDIF

    ; If necessary skip to beginning of desired data. 

    IF (range[0] GT 0) THEN BEGIN
        mrd_skip, unit, range[0]*rsize
        cursor += range[0]*rsize
    ENDIF

    status=-2
    IF (rsize EQ 0) THEN return 

    ON_IOERROR,done
    READU, unit, array

    IF (N_ELEMENTS(rows) GT 0) THEN BEGIN
    row1 = rows - range[0]
    CASE SIZE(array,/n_dimen) OF 
    1: array = array[row1]
    2: array = array[*,row1]
    3: array = array[*,*,row1]
    4: array = array[*,*,*,row1]
    5: array = array[*,*,*,*,row1]
    6: array = array[*,*,*,*,*,row1]
    7: array = array[*,*,*,*,*,*,row1]
    8: array = array[*,*,*,*,*,*,*,row1]
    ELSE: BEGIN 
          PRINT,'pds_rd_image: Subscripted image must be between 1 and 8 dimensions'
          status = -1
          RETURN
          END
    ENDCASE
    ENDIF

    ; Fix for signed byte
    ; IDL has no signed byte datatype.  So, we change the array into
    ; an int and then subtract 256 if the high bit is on.
    data_type = meta.Element_Array.data_type._text
    IF (data_type EQ 'SignedByte') THEN BEGIN
      array = FIX(array)
      array[WHERE(array GT 128)] = array[WHERE(array GT 128)] - 256.
    ENDIF
    status=0
    done:
;-- probably an EOF 
    IF (status NE 0) THEN BEGIN 
          MESSAGE,!ERROR_STATE.MSG,/CON
          FREE_LUN,unit
    ENDIF
    RETURN
END;  end pro pds_rd_read_image

; Truncate superfluous axes.
PRO pds_rd_axes_trunc,axes, dims, silent
COMPILE_OPT idl2, hidden
    mysilent = silent
    FOR i=axes-1,1,-1 DO BEGIN 
        IF dims[i] EQ 1 THEN BEGIN
            IF ~mysilent THEN BEGIN
                PRINT, 'pds_rd_image: Truncating unused dimensions'
                mysilent = 1
            ENDIF
            dims = dims[0:i-1] 
            axes = axes - 1         
        ENDIF ELSE RETURN     
    ENDFOR 
    RETURN
END ; end pro pds_rd_axes_trunc

; Define structure/array to hold an image. 
PRO pds_rd_image, meta, range, maxd, rsize, cursor, array, scaling_factor, value_offset, scaling, $
  status, silent=silent, lsb=lsb, rows=rows
  ; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
 COMPILE_OPT idl2, hidden
    
    ; Meta                  Structure with info on the image 
    ; Range                 Range of data to be retrieved. 
    ; Rsize                 Size of a row or group. 
    ; array                 Structure to be defined. 
    ; Status                Return status
    ; Silent=silent         Suppress info messages?
 
    array = 0
    ending = '(__[0-9]+)?'
    data_type = meta.Element_Array.data_type._text
    
  
    CASE data_type OF
    'SignedLSB2': type = -2
    'SignedLSB4': type = -3
    'SignedLSB8': type = -14
    'UnsignedLSB2': type = -12
    'UnsignedLSB4': type = -13
    'UnsignedLSB8': type = -15
    'IEEE754LSBSingle': type = -4
    'IEEE754LSBDouble': type = -5
    'ComplexLSB8': type = -6
    'ComplexLSB16': type = -7
    
    'UnsignedByte': type = 1 
    'SignedByte': type = 1    

    'SignedMSB2': type = 2
    'SignedMSB4': type = 3
    'SignedMSB8': type = 14
    'UnsignedMSB2': type = 12
    'UnsignedMSB4': type = 13
    'UnsignedMSB8': type = 15
    'IEEE754MSBSingle': type = 4
    'IEEE754MSBDouble': type = 5
    'ComplexMSB8': type = 6
    'ComplexMSB16': type = 7
    'SignedBitString':BEGIN
      PRINT, 'data_type not yet handled: ', data_type
      RETURN
      END
    'UnsignedBitString': BEGIN
      PRINT, 'data_type not yet handled: ', data_type
      RETURN
      END
    ELSE : BEGIN
	    PRINT, 'data_type not permitted in PDS: ', data_type
	    RETURN
	    END
    ENDCASE
    
    lsb = 0
    IF (type LE -1) THEN BEGIN
       lsb = 1
       type = abs(type)
    ENDIF
    ; type    0        1       2         3                5  6  7  8  9 10 11        12        13          14         15
    lens =  [ 0,       1,      2,        4,       4,       8, 0, 0, 0, 0, 0, 0,        2,        4,          8,         8] 
    typstrs=['',  'Byte','Int*2',  'Int*4','Real*4','Real*8','','','','','','', 'UInt*2', 'Uint*4',    'Int*8',   'Uint*8']
    typarr= ['','bytarr','intarr','lonarr','fltarr','dblarr','','','','','','','uintarr','ulonarr', 'lon64arr','ulon64arr'] 
    bitarr = [0,       8,      16,       32,    -32,     -64, 0, 0, 0, 0, 0, 0,       16,       32,         64,        64]
 
    status = 0 
 
 
    axes = meta.axes._text
    bitpix = bitarr[type]
    IF (axes GT 0) THEN BEGIN
         dims = LONG64(gettagsbyname(meta,'\.Axis_Array'+ending+'.elements._text',/getvalues))
         sequence_number = LONG(gettagsbyname(meta,'\.Axis_Array'+ending+'.sequence_number._text',/getvalues))
         ; In case elements are not in sequence order
         dims = dims[sequence_number-1]
         
         arange = [-1L,-1L]
	       axis_index_order = STRUPCASE(strtrim(meta.axis_index_order._text,2))
         IF (axis_index_order EQ 'LAST INDEX FASTEST') THEN $
                dims = REVERSE(dims)

	        N_axis = N_ELEMENTS(dims)
          IF (N_axis GT axes) THEN BEGIN
                   ; Check if extra axesn keywords are present (though this is not legal FITS)
                   nextra = N_axis - axes
                   dim_extra = dims[axes:N_axis-1]
                   IF (TOTAL(dim_extra) EQ nextra) THEN $
                        dims = dims[0:axes-1] ELSE $
                   MESSAGE,'ERROR - axes = ' + STRTRIM(axes,2) +  $
                          ' but axes' + STRTRIM(N_axis,2) + ' keyword present'
          ENDIF
    ENDIF ELSE dims = 0
 
    IF (axes EQ 0) THEN BEGIN	
        rsize = 0 
        array = 0
        IF ~KEYWORD_SET(silent) THEN $
            PRINT, 'pds_rd_image: Null image, axes=0'
        RETURN	    
    ENDIF 
         
    ; What to do if axes value is greater then the number of Axis_Arrays
    pds_rd_axes_trunc, axes, dims, KEYWORD_SET(silent)
                
    maxd = dims[axes-1] 
         
    IF range[0] NE -1 THEN BEGIN 
        range[0] = range[0]<(maxd-1) 
        range[1] = range[1]<(maxd-1) 
    ENDIF ELSE BEGIN 
         range[0] = 0 
         range[1] = maxd - 1 
    ENDELSE 

    Nlast = dims[axes-1]   
    dims[axes-1] = range[1]-range[0]+1
    pdims = dims
    IF N_ELEMENTS(rows) GT 0 THEN BEGIN
         IF MAX(rows) GE nlast THEN BEGIN 
            PRINT, 'pds_rd_image: Row =',rows, ' Numbers must be between 0 and ' + $
                   STRTRIM(Nlast-1,2)
            status = -1 & rsize = 0
            RETURN
         ENDIF
         pdims[axes-1] = N_ELEMENTS(rows)
    ENDIF 
 
    IF ~KEYWORD_SET(silent) THEN BEGIN
         str = '('
         FOR i=0, axes-1 DO BEGIN
             IF (i NE 0) THEN str = str + ','
             str = str + STRCOMPRESS(STRING(pdims[i]),/remo)
         ENDFOR
         str = str+')'
         PRINT, 'pds_rd_image: Image array ',str, '  Type=', typstrs[type]
    ENDIF
         
    rsize = 1
	
    IF (axes GT 1) THEN FOR i=0, axes - 2 DO rsize=rsize*dims[i] 
    rsize = rsize*lens[type] 
    ; We have size of array now, so we update cursor now even though it is before the
    ; actual move
    cursor += rsize*dims[axes-1]
    sz = LONARR(axes+3) 
    sz[0] = axes 
    sz[1:axes] = dims 

	  nele = product(dims,/integer)
         
    sz[axes+1] = type   
    sz[axes+2] = nele 
  
    array = nele GT 0 ? MAKE_ARRAY(size=sz) : 0
	
    scaling_factor = DBLARR(1)
    value_offset = DBLARR(1)
	
	  IF (scaling EQ 1) THEN BEGIN
	     scaling_factor = gettagsbyname(meta.Element_Array,'.scaling_factor._text$',/getvalues,count=nscales)
       IF (nscales EQ 0) THEN scaling_factor[0] = 1.0d0 ELSE scaling_factor = DOUBLE(scaling_factor)
       IF (scaling_factor[0] EQ 0.0D0) THEN scaling_factor[0] = 1.0d0
       value_offset = gettagsbyname(meta.Element_Array,'.value_offset._text$',/getvalues,count=noffsets)
       IF (noffsets EQ 0) THEN value_offset[0] = 0.0d0 ELSE value_offset = DOUBLE(value_offset)
       IF (nscales+noffsets GT 0) THEN scaling = 1 ELSE scaling = 0
    ENDIF
    IF (scaling EQ 1) THEN $
      IF (scaling_factor[0] EQ 1.0d0 $
      		AND value_offset[0] EQ 0.0d0) THEN scaling = 0 
    status = 0 
    RETURN 
END ; End pro PDS_RD_IMAGE
