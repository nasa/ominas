;-----------------------------------------------------------------------------
; NAME: TBINPDS   [Table BINARY PDS]
; 
; PURPOSE: To read a PDS binary table file into an IDL structure containing 
;     columns of the data table as elements.
;
; CALLING SEQUENCE: Result = TBINPDS (filename, label, objindex, [/SILENT])
; 
; INPUTS:
;     Filename: Scalar string containing the name of the PDS file to read.
;     Label: String array containing the table header information.
;     Objindex: Integer specifying the starting index of teh current table
;         object in the label array to be read.
;
; OUTPUTS:
;     Result: Table structure constructed from designated records with fields
;         for each column in the table, along with a string array field 
;         containing the name of each column.
;
; OPTIONAL INPUT:
;     SILENT: Suppresses any messages from the procedure.
;
; EXAMPLES:
;     To read an BINARY table file TABLE.LBL into a structure "table":
;         IDL> label = HEADPDS ('TABLE.LBL', /SILENT)
;         IDL> table = TBINPDS ('TABLE.LBL', label, /SILENT)
;
; PROCEDURES USED:
;     Functions: OBJPDS, GET_INDEX, CLEAN, REMOVE, STR2NUM, PDSPAR, POINTPDS
;
; MODIFICATION HISTORY:
;     Written by: John D. Koch [December 1994] (adapted from READFITS by
;                                               Wayne Landsman)
;     Re-written by: Puneet Khetarpal [19 July, 2004] 
;     
;     Modifications: Parin Choganwala [27 April, 2008]
;		     In OBTAIN_TBIN_REQ increased range of columns,rows,row_bytes
;		     data type by using ULONG and LONG64	   
;     
;     S. Martinez [2 February, 2009]. OBTAIN_TBIN_ITEMS modified, the number of
;        elements was wrong (named 'count' in the structure).
;      
;     S. Martinez [11 February, 2009]. ROW_SUFFIX/PREFIX_BYTES data type changed to 
;        unsigned long 64. Range of previous data type exceeded.
;                        
;     S. Martinez [12 January, 2010]. Endianess not correctly handled. Modified 
;        tbinpds to reverse byte order if MSB architecture and little-endian 
;        machine or LSB architecture and big-endian machine.
;
;     S. Martinez [05 July, 2010]. Updated to handle CONTAINER/BIT_COLUMN objects.
;        Functions OBTAIN_TBIN_CONTAINERS, OBTAIN_TBIN_BIT_COLUMNS,
;                  PROCESS_TBIN_BIT_COLUMNS and FORMAT_COLUMN added to this file.
;
;
;     To view a complete list of modifications made to this routine, 
;     please see changelog.txt file.
;
;  
;-----------------------------------------------------------------------------

;- level 2 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: the name variable is a viable required keyword scalar string,
;     label is a viable PDS label string array, and start and end_ind are
;     viable integers pointing at the start and end of the current table
;     object being processed.
; postcondition: extracts the "name" keyword from the label, stores it in a 
;     structure, and returns to the main block.

function OBTAIN_KEYWORD, name, label, start_ind, end_ind
   ; initialize keyword structure:
   struct = create_struct("flag",1)

   ; obtain keyword parameters:
   val = PDSPAR (label, name, COUNT=count, INDEX=index)    ; external routine

   ; if no viable params found, then issue error:
   if (!ERR EQ -1) then begin
       print, "Error: missing required " + name + " keyword(s)."
       GOTO, ENDFUN
   endif

   ; extract the indices where keyword index is between start_ind and end_ind:
   pos = where (index GT start_ind AND index LT end_ind)

   ; if none found then return flag as -1:
   if (pos[0] EQ -1) then GOTO, ENDFUN

   ; store the viable values, indices, and count for "name" keyword:
   val = val[pos]
   index = index[pos]
   count = n_elements(val)

   ; place the stored params in the structure:
   struct = create_struct(struct,"val",val,"count",count,"index",index)
   return, struct

   ENDFUN:
      struct.flag = -1
      return, struct
end

;-----------------------------------------------------------------------------
; precondition: name is a structure containing all names param for current
;     table object, label is a viable PDS label string array, and start_ind
;     and end_ind are integer pointers to start and end of current object.
; postcondition: the table name is searched through all the name values and
;     then removed from the structure, the count is decremented by one, and
;     the index value is also removed from the corresponding structure field.

function REMOVE_TBIN_NAME, name, label, start_ind, end_ind
    ; first obtain COLUMN object indices for current table object:
    column = OBJPDS(label, "COLUMN")                      ; external routine
    pos = where (column.index GT start_ind AND column.index LT end_ind)
    column.index = column.index[pos]

    ; check to see if the first name index is less than the first column
    ; index value. If found then there exists a table name, and is removed:
    if (name.index[0] LT column.index[0]) then begin
        temp = name.val[1:name.count - 1]
        name.val = ''
        name.val = temp
        
        temp = name.index[1:name.count - 1]
        name.index = ''
        name.index = temp
        
        name.count = name.count - 1
    endif

    ; clean up name array values, and removed unwanted characters:
    param = ['"', "'", "(", ")"]
    for j = 0, name.count-1 do begin
        name.val[j] = CLEAN (name.val[j])                 ; external routine
        name.val[j] = REMOVE (name.val[j], param)         ; external routine
    endfor

    return, name
end

;-----------------------------------------------------------------------------
; precondition: data_type is a structure containing the required keyword
;     params for DATA_TYPE keyword.
; postcondition: the architecture of the data file is determined.

function OBTAIN_TBIN_ARCH, data_type
    ; intitialize variables:
    arch = "MSB"

    for j = 0, data_type.count - 1 do begin
        type = data_type.val[j]
        ; check the existence of little endian data type:
        if ((strpos(type, "LSB") gt -1) || (strpos(type, "PC") gt -1) || $
            (strpos(type, "VAX") gt -1)) then begin
            arch = "LSB"
        endif
    endfor

    return, arch
end


;-----------------------------------------------------------------------------
; precondition: data_type is a structure containing the required keyword 
;     params for DATA_TYPE keyword.
; postcondition: the data type keyword values are cleaned.

function SEPARATE_TBIN_DATA_TYPE, data_type
    ; set the param variable:
    param = ['"', "'", ")", "("]

    ; start the loop to go through each data_type value array:
    for j = 0, data_type.count - 1 do begin
        ; first clean data_type:
        data_type.val[j] = CLEAN (data_type.val[j], /SPACE)  ; external routine
        data_type.val[j] = REMOVE (data_type.val[j], param)  ; external routine
    endfor

    return, data_type
end

;-----------------------------------------------------------------------------
; precondition: keywds contains all required keyword values in a structure,
;     items contains all item keyword values, curr_ind and next_ind are 
;     integer pointers to current and next column object being processed, and
;     curpos is an integer containing the current cursor position being
;     processed in the record.
; postcondition: the routine tests whether there are any table items for
;     current column object, and if found, then populates the necessary
;     item structure for current column object and returns to main block.
;     If no table items are found, then simply extracts the number of
;     bytes for current object and returns it as a bytarr.

function PROCESS_TBIN_ITEMS, keywds, items, curpos, curr_ind, next_ind
    ; first determine whether there exist ITEMS for current COLUMN:
    if (items.flag EQ -1) then begin
        ipos = -1
    endif else begin
        ipos = where (items.items.index GT curr_ind AND items.items.index LT $
                  next_ind)
    endelse

    ; if items not present then extract the number of bytes for current object:
    if (ipos[0] EQ -1) then begin
        ; determine the index for current bytes values to be assigned:
        pos = where (keywds.bytes.index GT curr_ind AND $
                     keywds.bytes.index LT next_ind)
        element = bytarr(long(keywds.bytes.val[pos[0]]))

        ; increment the cursor position by current bytes:
        curpos = curpos + long(keywds.bytes.val[pos[0]])
    endif else begin
        ; if items are present, then create a secondary element bytarr 
        ; for each item, and start a temp cursor position for this column:
        item_bytes = long(items.bytes.val[ipos[0]])
        element = bytarr(item_bytes)
        temppos = item_bytes

        ; check for offset keyword values. if offset is 0 then simply
        ; set the item element structure to be element, else construct
        ; a bytarr for offset buffer to be read, increment temppos, and
        ; add the offset buffer to item element structure along with element:
        if (items.offset.count EQ 0) then begin
            item_offset = 0
        endif else begin
            item_offset = long(items.offset.val[ipos[0]])
        endelse
        if (item_offset EQ 0) then begin
            item_elem = create_struct("element", element)
        endif else begin
            offtemp = bytarr(item_offset)
            temppos = temppos + item_offset
            item_elem = create_struct("element", element, "offtemp", offtemp)
        endelse

        ; now replicate the item element structure number of items - 1 times.
        ; it is being replicated items - 1 times because of the offset buffer.
        ; when there is an offset, the offset bytes do not carry after the
        ; last item, so the item_elem structure constructed earlier would be
        ; incorrect:
        ;
        ; 1/13/2010 : Some datasets use ITEMS = 1. Add logical branch to
        ; handle this special case. If ITEMS = 1, we simply store item_elem
        ; to element, and avoid the creation of special temporary elements.
        num_items = long(items.items.val[ipos[0]])

        if num_items gt 1 then begin
            item_elem = replicate(item_elem, num_items - 1)

            ; multiply temppos by the number of items - 1:
            temppos = temppos * (num_items - 1)
        
            ; create a temporary structure to hold last array element, and
            ; increment temppos by item_bytes:
            temp_struct = create_struct("element", element)
            temppos = temppos + item_bytes

            ; populate the column structure to act as the element to be read:
            element = create_struct("item_elem", item_elem, "last", temp_struct)
        endif else begin
            element = create_struct("item_elem", item_elem)
        endelse
        ; finally increment main cursor position by temppos value:
        curpos = curpos + temppos
    endelse

    ; add cursor position and element into column object structure:
    object_struct = create_struct("curpos", curpos, "data", element)

    return, object_struct
end

;- level 1 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label string array, start_ind is the
;     index specifying the start of the current object, and end index its
;     end. Label must contain a valid BINARY table with INTERCHANGE format
;     keyword.
; postcondition: returns a boolean (1 or -1) depending on whether it finds
;     a BINARY interchange format keyword, or not.

function TBIN_INTERFORM, label, start_ind, end_ind
    ; obtain all INTERCHANGE_FORMAT keyword values from label:
    interform = PDSPAR (label, "INTERCHANGE_FORMAT", INDEX=int_ind)

    ; check whether there exist any interchange format keywords:
    if (!ERR EQ -1) then begin
        print, "Error: missing required INTERCHANGE_FORMAT keyword"
        return, -1
    endif else begin
        ; obtain the indices of interchange format array object, where
        ; they are between start and end index:
        interpos = where (int_ind GT start_ind AND int_ind LT end_ind)

        ; extract the interform values:
        interform = interform[interpos[0]]
        interform = interform[0]

        ; remove all white space, and remove the '"' chars if found:
        interform = CLEAN(interform,/SPACE)            ; external routine
        interform = REMOVE(interform, '"')             ; external routine

        ; if interchange format value is binary, then return -1 with error:
        if (interform EQ "ASCII") then begin
            print, "Error: This is ascii table file; try TASCPDS."
            return, -1
        endif
    endelse
    ; if all goes well, then return 1:
    return, 1
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label string array, and start_ind and
;     end_ind are valid integers specifying the start and end of the 
;     current table object as index pointers in the string array.
; postcondition: extracts required keywords for table object in the label.

function OBTAIN_TBIN_REQ, label, start_ind, end_ind
    ; initialize keyword structure:
    keywds = create_struct("flag",1)

    ; obtain table object definitions for current object:
    ; extract the keyword structure from subroutine, and check whether
    ; there are any params for the keyword, if not then return to main block
    ; else store the value

    ; first obtain number of COLUMNS:
    columns_num = OBTAIN_KEYWORD("COLUMNS", label, start_ind, end_ind)
    if (columns_num.flag EQ -1) then GOTO, ENDFUN
    columns = fix(columns_num.val[0])

    ;Modified by parin Apr,2008 starts
    ; obtain ROW_BYTES keyword:
    row_bytes = OBTAIN_KEYWORD("ROW_BYTES",label, start_ind, end_ind)
    if (row_bytes.flag EQ -1) then GOTO, ENDFUN
    row_bytes = ulong(row_bytes.val[0])

    ; obtain ROWS keyword:
    rows = OBTAIN_KEYWORD("ROWS", label, start_ind, end_ind)
    if (rows.flag EQ -1) then GOTO, ENDFUN
    rows = ulong(rows.val[0])

    ; check whether either columns, rows or row_bytes equal 0:
    if ((columns le 0) or (rows le 0) or (row_bytes le 0)) then begin
        row_bytes = ulong64(row_bytes)
        rows = ulong64(rows)
        if ((columns le 0) or (rows le 0) or (row_bytes le 0)) then begin
        	print, "Error: ROWS OR ROW_BYTES or COLUMNS <= 0. No data read."
        	GOTO, ENDFUN
         endif
    endif
    ;Modified by parin Apr, 2008 ends

    ; obtain information for each column object:

    ; obtain NAME keyword:
    name = OBTAIN_KEYWORD("NAME",label,start_ind,end_ind)
    if (name.flag EQ -1) then GOTO, ENDFUN
    
    ;; Modified by smartinez
    bit_column_objects = objpds(label, "BIT_COLUMN")
    if (bit_column_objects.flag ne -1) then begin
      bit_ind = 0ULL
      bit_start_ind = bit_column_objects.index[0]
      bit_end_ind = get_index(label,bit_column_objects.index[0])
    
      tmp_ind = 0L
      tmp_val = strarr(name.count)
      tmp_index = lonarr(name.count)
      for i=0,name.count-1 do begin
      
        if (name.index[i] gt bit_start_ind and name.index[i] lt bit_end_ind) then begin
          bit_ind++
          columns--
          if (bit_ind lt n_elements(bit_column_objects.index)) then begin
            bit_start_ind = bit_column_objects.index[bit_ind]
            bit_end_ind = get_index(label,bit_column_objects.index[bit_ind])
          endif
          continue
        endif

        tmp_val[tmp_ind] = name.val[i] 
        tmp_index[tmp_ind] = name.index[i] 
        tmp_ind++
      
      endfor
      tmp_name = create_struct('flag',name.flag,'count',tmp_ind,'val',tmp_val[0:tmp_ind-1],'index',tmp_index[0:tmp_ind-1])
      name = tmp_name
    endif
    ;; End of smartinez modification


    ; remove table name from name structure if present:
    name = REMOVE_TBIN_NAME(name, label, start_ind, end_ind)

    ; obtain DATA_TYPE keyword, then clean, separate, and extract it:
    data_type = OBTAIN_KEYWORD("DATA_TYPE", label, start_ind, end_ind)
    if (data_type.flag EQ -1) then GOTO, ENDFUN

    ; obtain data file architecture and separate data type:
    arch = OBTAIN_TBIN_ARCH(data_type)
    data_type = SEPARATE_TBIN_DATA_TYPE(data_type)  ; subroutine

    ; obtain BYTES keyword:
    bytes = OBTAIN_KEYWORD("BYTES",label, start_ind, end_ind)
    if (bytes.flag EQ -1) then GOTO, ENDFUN

    ; obtain START_BYTE keyword, and subtract 1 for IDL variable indexing:
    start_byte = OBTAIN_KEYWORD("START_BYTE",label, start_ind, end_ind)
    if (start_byte.flag EQ -1) then GOTO, ENDFUN
    start_byte.val = long(start_byte.val) - 1

    ; store values into the keyword structure:
    keywds = create_struct(keywds, "columns",columns,"row_bytes",row_bytes, $
                           "rows",rows,"name",name,"data_type",data_type, $
                           "bytes",bytes,"start_byte",start_byte, "arch",arch)

    return, keywds

    ENDFUN:
       keywds.flag = -1
       return, keywds
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label string array, start_ind and end_ind
;     are integer pointers to start and end of current table in label.
; postcondition: obtains the optional table keywords from the label, and 
;     returns them in a structure.

function OBTAIN_TBIN_OPT, label, start_ind, end_ind
    ; initialize structure:
    keywds = create_struct("flag", 1, "prefix", 0ULL, "suffix", 0ULL)

    ; obtain ROW_PREFIX_BYTES keyword:
    rowprefix = PDSPAR (label, "ROW_PREFIX_BYTES", COUNT=pcount, INDEX=pindex)
    if (!ERR GT -1) then begin
        pos = where (pindex GT start_ind AND pindex LT end_ind)
        if (pos[0] GT -1) then begin
            keywds.prefix = ulong64(rowprefix[pos[0]])
            if (keywds.prefix LT 0) then begin
                print, "Error: invalid ROW_PREFIX_BYTES (" + $
                       CLEAN(string(keywds.prefix), /SPACE) + ")."
                GOTO, ENDFUN
            endif
        endif
    endif

    ; obtain ROW_SUFFIX_BYTES keyword:
    rowsuffix = PDSPAR (label, "ROW_SUFFIX_BYTES", COUNT=scount, INDEX=sindex)
    if (!ERR GT -1) then begin
        pos = where (sindex GT start_ind AND sindex LT end_ind)
        if (pos[0] GT -1) then begin
            keywds.suffix = ulong64(rowsuffix[pos[0]])
            if (keywds.suffix LT 0) then begin
                print, "Error: invalid ROW_SUFFIX_BYTES (" + $
                       CLEAN(string(keywds.suffix), /SPACE) + ")."
                GOTO, ENDFUN
            endif
        endif
    endif

    return, keywds

    ENDFUN:
        keywds.flag = -1
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: label is viable PDS label string array, req_keywds is a 
;     structure containing required table object keywords, and start and 
;     end_ind are viable integer pointers to start and end of the current
;     table object.
; postcondition: Extracts table items keyword params from label and returns
;     to main block as a structure.

function OBTAIN_TBIN_ITEMS, label, req_keywds, start_ind, end_ind
    ; initialize items keyword structure:
    keywds = create_struct("flag", 1, "flag2", 1)

    ; obtain necessary ITEM keyword values:
    ; first obtain ITEMS keyword values:
    items = PDSPAR (label, "ITEMS", COUNT=items_count, INDEX=items_index)
    if (!ERR EQ -1) then begin
        GOTO, ENDFUN
    endif

    ; extract values of items between start_ind and end_ind, and store:
    pos = where (items_index GT start_ind AND items_index LT end_ind)
    if (pos[0] EQ -1) then GOTO, ENDFUN
    items = create_struct("val",items[pos],"count",n_elements(items[pos]), $
                          "index",items_index[pos])

    ; now we know that there are columns with ITEMS keyword in current table
    ; object, so extract the other item keyword values:

    ; obtain ITEM_BYTES keyword values:
    bytes = PDSPAR (label, "ITEM_BYTES", COUNT=byte_count, INDEX=byte_index)
    if (!ERR EQ -1) then begin
        print, "Error: missing required ITEM_BYTES keyword for items column."
        keywds.flag2 = -1
        GOTO, ENDFUN
    endif
    pos = where (byte_index GT start_ind AND byte_index LT end_ind)
    if (pos[0] EQ -1) then begin
        print, "Error: missing required ITEM_BYTES keyword for current table"
        keywds.flag2 = -1
        GOTO, ENDFUN
    endif
    bytes = create_struct("val", bytes[pos], "count", n_elements(bytes[pos]), $
                          "index", byte_index[pos])

    ; initialize a temp structure to hold default values:
    temp = create_struct("val",0,"count",0,"index",0)

    ; obtain ITEM_OFFSET keyword values, if present:
    offset = PDSPAR (label, "ITEM_OFFSET", COUNT=off_count, INDEX=off_index)

    ; if there exist ITEM_OFFSET keywords, then obtain ones between
    ; start and end_ind else set it to temp structure:
    if (!ERR NE -1) then begin
        pos = where (off_index GT start_ind AND off_index LT end_ind)
        if (pos[0] EQ -1) then begin
            offset = temp
        endif else begin
            offset = create_struct("val", offset[pos], "count", $
                                   n_elements(offset[pos]),"index",off_index[pos])

            ; since the offset values in the PDS label are given as the 
            ; number of bytes from the beginning of a one item to the
            ; beginning of next, therefore, the offset that we are concerned
            ; with is the difference between the end of one item and the
            ; beginning of next:
            offset.val = long(offset.val) - long(bytes.val)
            FOR i=0,N_ELEMENTS(offset.val)-1 DO $
              if (offset.val[i] LT 0) then begin
                  print, "Error: invalid ITEM_OFFSET value, must be >=ITEM_BYTES"
                  keywds.flag2 = -1
                  GOTO, ENDFUN
              endif
        endelse
    endif else offset = temp

    ; store info into a structure:
    keywds = create_struct(keywds, "items", items, "bytes",bytes,"offset", $
                           offset)
    return, keywds 

    ENDFUN:
        keywds.flag = -1
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: label is viable PDS label string array, req_keywds is a 
;     structure containing required table object keywords, and start and 
;     end_ind are viable integer pointers to start and end of the current
;     table object.
; postcondition: Extracts table container keyword params from label and returns
;     to main block as a structure.

function OBTAIN_TBIN_CONTAINERS, label, req_keywds, start_ind, end_ind
  ; initialize items keyword structure:
  keywds = create_struct("flag", 1, "flag2",1)
  
  container = objpds(label, "CONTAINER")
  if (container.flag eq -1) then goto,endfun
  
  container_info = replicate(create_struct('name','','start_byte',0ULL,'bytes',0ULL,'repetitions',0ULL,'description','',$
                                           'start_index',0ULL,'end_index',0ULL,'columns',0ULL),n_elements(container.index))
  
  for i=0,n_elements(container.index)-1 do begin
    container_info[i].start_index = container.index[i]
    container_info[i].end_index = get_index(label,container.index[i])
    
    column = objpds(label[container_info[i].start_index:container_info[i].end_index],"COLUMN")
    container_info[i].columns = column.count
    end_header = container_info[i].start_index + column.index[0]
    
    name = obtain_keyword("NAME",label, container_info[i].start_index, end_header)    
    repetitions = obtain_keyword("REPETITIONS",label, container_info[i].start_index, end_header)
    bytes = obtain_keyword("BYTES",label, container_info[i].start_index, end_header)
    start_byte = obtain_keyword("START_BYTE",label, container_info[i].start_index, end_header)
    if (name.flag eq 0 || repetitions.flag eq 0 || bytes.flag eq 0 || start_byte.flag eq 0) then begin
      print, "Error: missing required keyword in CONTAINER object: NAME, REPETITIONS, BYTES or START_BYTE"
      keywds.flag2 = -1
      goto, endfun
    endif
    
    container_info[i].name = name.val[0]
    container_info[i].repetitions = repetitions.val[0]
    container_info[i].bytes = bytes.val[0]
    container_info[i].start_byte = start_byte.val[0]
  endfor

  ; store info into a structure:
  keywds = create_struct(keywds, "name", container_info.name, "bytes",container_info.bytes,"repetitions",container_info.repetitions,"start_byte",container_info.start_byte,$
                         "start_index",container_info.start_index,"end_index",container_info.end_index,"columns",container_info.columns,"count",n_elements(container_info.name))
  return, keywds 

  endfun:
    keywds.flag = -1
    return, keywds
end

;-----------------------------------------------------------------------------
; precondition: label is viable PDS label string array, data contains the
;     data as read not taking into account bit_column splitting, req_keywds 
;     contains all required keyword values in a structure,
;     bit_columns contains all bit_column keyword values, 
; postcondition: the routine tests whether there are any table bit_column for
;     current column object, and if found, then replaces the current column
;     for bit_column structure for current column object and returns 
;     to main block.

function PROCESS_TBIN_BIT_COLUMNS, data, label, req_keywds, bit_columns
  
  columns = bit_columns.column_index(uniq(bit_columns.column_index))
  column_index = ulonarr(n_elements(columns))
  
  for i=0,n_elements(columns)-1 do begin
    end_index = get_index(label,columns[i])
    name = req_keywds.name.val(where(req_keywds.name.index gt columns[i] and req_keywds.name.index lt end_index))
    column_index[i] = where(data.names eq name[0])   
  endfor
  
  tmp_ind = 0ULL
  names = tag_names(data)
  for i=0,n_elements(names)-1 do begin
  
    pos = where(i ne column_index,count)
    
    ;; Add columns with bit_columns
    if (count eq 0) then begin
      
      index = where(bit_columns.column_index eq columns[tmp_ind])
      for j=0,n_elements(index)-1 do begin
    
        bit_column_index = index[j]
        bit_name = "BIT_COLUMN" + CLEAN(string(j+1),/SPACE)
      
        data_type = size(data.(column_index[tmp_ind]),/TYPE)
        if (data_type eq 1) then data_size = 1 $ ;; BYTE
        else if (data_type eq 2 or data_type eq 12) then data_size = 2 $ ;; INT,UINT
        else if (data_type eq 3 or data_type eq 4 or data_type eq 13) then data_size = 4 $ ;; LONG,ULONG,FLOAT
        else if (data_type eq 5 or data_type eq 14 or data_type eq 15) then data_size = 8 ;; LONG64,ULONG64,DOUBLE
        
        bit_mask = (2B^bit_columns.bits(bit_column_index)) - 1
        bit_shift = 8B*data_size - (bit_columns.bits(bit_column_index) + bit_columns.start_bit(bit_column_index) - 1)
        bit_mask = ishft(bit_mask,bit_shift)
        
        tmp_column = byte(ishft(data.(column_index[tmp_ind]) and bit_mask,-1B*bit_shift))
        bit_column_struct = (n_elements(bit_column_struct) eq 0) ? create_struct(bit_name,tmp_column) : create_struct(bit_column_struct,bit_name,tmp_column)
      
      endfor
   
      final_data = (n_elements(final_data) eq 0) ? create_struct(names[i],bit_column_struct) : create_struct(final_data,names[i],bit_column_struct)
      tmp_ind++
      
    ;; Add columns without bit_column
    endif else final_data = (n_elements(final_data) eq 0) ? create_struct(names[i],data.(i)) : create_struct(final_data,names[i],data.(i))
  endfor

  return, final_data
end

;-----------------------------------------------------------------------------
; precondition: label is viable PDS label string array, req_keywds is a 
;     structure containing required table object keywords, and start and 
;     end_ind are viable integer pointers to start and end of the current
;     table object.
; postcondition: Extracts table bit_column keyword params from label and returns
;     to main block as a structure.

function OBTAIN_TBIN_BIT_COLUMNS, label, req_keywds, start_ind, end_ind
  ; initialize items keyword structure:
  keywds = create_struct("flag", 1, "flag2",1)
  
  ;;
  ;; Column info
  column_objects = objpds(label, "COLUMN")
  column_start_ind = ULONG(column_objects.index)
  column_end_ind = ULONARR(n_elements(column_start_ind))
  for i=0,n_elements(column_start_ind)-1 do begin
    column_end_ind[i] = ULONG(get_index(label,column_objects.index[i]))
  endfor
  
  bit_columns = objpds(label, "BIT_COLUMN")
  if (bit_columns.flag eq -1) then goto,endfun
  
  bit_columns_info = replicate(create_struct('name','','bit_data_type','','start_bit',0B,'bits',0B,'items',0B,'item_bits',0B,$
                                           'item_offset',0B,'start_index',0ULL,'end_index',0ULL,'column_index',0UL),n_elements(bit_columns.index))
  
  for i=0,n_elements(bit_columns.index)-1 do begin
    bit_columns_info[i].start_index = bit_columns.index[i]
    bit_columns_info[i].end_index = get_index(label,bit_columns.index[i])
      
    name = obtain_keyword("NAME",label, bit_columns_info[i].start_index, bit_columns_info[i].end_index)    
    bit_data_type = obtain_keyword("BIT_DATA_TYPE",label, bit_columns_info[i].start_index, bit_columns_info[i].end_index)   
    start_bit = obtain_keyword("START_BIT",label, bit_columns_info[i].start_index, bit_columns_info[i].end_index)   
    bits = obtain_keyword("BITS",label, bit_columns_info[i].start_index, bit_columns_info[i].end_index)    
    if (name.flag eq 0 || bit_data_type.flag eq 0 || start_bit.flag eq 0 || (bits.flag eq 0) ) then begin
      print, "Error: missing required keyword in BIT_COLUMN object: NAME, BIT_DATA_TYPE, START_BIT or BITS"
      keywds.flag2 = -1
      goto, endfun
    endif
    
    bit_columns_info[i].name = name.val[0]
    bit_columns_info[i].bit_data_type = bit_data_type.val[0]
    bit_columns_info[i].start_bit = start_bit.val[0]
    bit_columns_info[i].bits = bits.val[0]
    
    pos = where(bit_columns_info[i].start_index gt column_start_ind and bit_columns_info[i].start_index lt column_end_ind)
    bit_columns_info[i].column_index = column_start_ind(pos[0])
    
  endfor

  ; store info into a structure:
  keywds = create_struct(keywds, "name", bit_columns_info.name, "bit_data_type",bit_columns_info.bit_data_type,"start_bit",bit_columns_info.start_bit,$
                                 "bits",bit_columns_info.bits,$
                                 "start_index",bit_columns_info.start_index,"end_index",bit_columns_info.end_index,'column_index',bit_columns_info.column_index,$
                                 'count',n_elements(bit_columns_info.name))
  return, keywds 

  endfun:
    keywds.flag = -1
    return, keywds
end




;-----------------------------------------------------------------------------
; precondition: keywds contains required keywords for current table object,
;     items contains items keywords for current table object, label is a 
;     viable PDS label string array, start_ind and end_ind are integer
;     pointers to start and end of current table object
; postcondition: creates a structure to be read from the data file and returns
;     it to the main block.

function CREATE_TBIN_STRUCT, keywds, opt, items, containers, label, start_ind, end_ind
    ; initialize variables:
    curpos = 0            ; cursor position
    complete_set = create_struct("flag", 1)      ; structure to be returned
    data_set = 0          ; data structure set

    ; create structure for row prefix bytes if any:
    if (opt.prefix GT 0) then begin
        data_set = create_struct("prefix", bytarr(opt.prefix))
    endif


    ;; No CONTAINER objects in label
    if (containers.flag eq -1) then begin

    ; start the loop:
    for j = 0, keywds.columns - 1 do begin
        ; set current and next COLUMN object index pointers:
        curr_ind = keywds.name.index[j]
        if (j EQ keywds.columns - 1) then begin
            next_ind = end_ind
        endif else begin
            next_ind = keywds.name.index[j+1]
        endelse

        ; name of current column:
        name = "COLUMN" + CLEAN(string(j+1),/SPACE)     ; external routine
        ; extract start byte value for current column:
        start_byte = long(keywds.start_byte.val[j])

        ; the temp buffer to be read is: difference between start_byte of
        ; current column and last curpos:
        buffer_length = start_byte - curpos
        if (buffer_length LT 0) then begin
            print, "Error: inconsistent START_BYTE and BYTES specification" + $
                   " in COLUMNS " + CLEAN(string(j),/SPACE) + " and " + $
                   CLEAN(string(j+1), /SPACE) + "."
            GOTO, ENDFUN
        endif else if (buffer_length EQ 0) then begin
            temp = -1            
        endif else begin
            temp = bytarr (buffer_length)
            curpos = start_byte
        endelse

        ; process item objects for current COLUMN object:
        element = PROCESS_TBIN_ITEMS(keywds, items, curpos,curr_ind,next_ind)

        ; create column structure:
        if (temp[0] EQ -1) then begin
            col_struct = create_struct ("element", element.data)
        endif else begin
            col_struct = create_struct ("temp", temp, "element", element.data)
        endelse

        ; construct structure to be read:
        if (size(data_set, /TYPE) NE 8) then begin
            data_set = create_struct(name, col_struct)
        endif else begin
            data_set = create_struct(data_set, name, col_struct)
        endelse
    endfor

    ; set additional buffer array at end of record:
    ; if cursor position < rb then take the difference between 78 and curpos
    ; and create a temporary buffer to be read at the end of each record.
    ; if cursor position > rb then issue error, and exit routine:
    if (keywds.row_bytes GT curpos) then begin
        diff = keywds.row_bytes - curpos
        data_set = create_struct(data_set, "temp", bytarr(diff))
    endif else if (keywds.row_bytes LT curpos) then begin
        print, "Error: Invalid START_BYTE or BYTES specification in label."
        GOTO, ENDFUN
    endif


    ;; CONTAINER objects in label
    endif else begin 
    
      container_index = 0
      
      columns = objpds(label, "COLUMN")
      pos = where(columns.index gt start_ind and columns.index lt end_ind)
      columns.count = n_elements(pos)
      columns.array[0:columns.count-1] = columns.array(pos)
      columns.index[0:columns.count-1] = columns.index(pos)
      columns_end_index = uintarr(columns.count)   
      for i=0,columns.count-1 do columns_end_index[i] = get_index(label,columns.index[i])
      
      ;; start the loop for columns
      for j = 0, columns.count - 1 do begin
      
        ; set current and next COLUMN object index pointers:
        curr_ind = columns.index[j]
        next_ind = columns_end_index[j]
        
        ;; Check if column belongs to container object
        container_flag = 0
        if (container_index lt containers.count) then begin
          if (curr_ind gt containers.start_index[container_index] and next_ind lt containers.end_index[container_index]) then container_flag = 1 $
          else container_flag = 0
        endif
        
        if (container_flag eq 0) then begin
        
          ; name of current column:
          name = "COLUMN" + CLEAN(string(j+1),/SPACE)     ; external routine
        
          ; extract start byte value for current column:
          ; determine the index for current start_byte values to be assigned:
          pos = where (long(keywds.start_byte.index) GT curr_ind AND long(keywds.start_byte.index) LT next_ind)
          start_byte = long(keywds.start_byte.val[pos(0)])
        
          ; the temp buffer to be read is: difference between start_byte of
          ; current column and last curpos:
          buffer_length = start_byte - curpos
          if (buffer_length LT 0) then begin
              print, "Error: inconsistent START_BYTE and BYTES specification" + $
                   " in COLUMNS " + CLEAN(string(j),/SPACE) + " and " + $
                   CLEAN(string(j+1), /SPACE) + "."
              GOTO, ENDFUN
          endif else if (buffer_length EQ 0) then begin
            temp = -1            
          endif else begin
            temp = bytarr (buffer_length)
            curpos = start_byte
          endelse

          ; process item objects for current COLUMN object:
          element = PROCESS_TBIN_ITEMS(keywds, items, curpos,curr_ind,next_ind)

          ; create column structure:
          if (temp[0] EQ -1) then begin
            col_struct = create_struct ("element", element.data)
          endif else begin
            col_struct = create_struct ("temp", temp, "element", element.data)
          endelse

          ; construct structure to be read:
          if (size(data_set, /TYPE) NE 8) then begin
            data_set = create_struct(name, col_struct)
          endif else begin
            data_set = create_struct(data_set, name, col_struct)
          endelse
          
        endif else begin
        
          ; name of current column:
          container_name = "CONTAINER" + CLEAN(string(container_index+1),/SPACE)     ; external routine
          container_struct = 0
          container_curpos = 0
        
          for k=0,containers.columns[container_index]-1 do begin
        
            ; set current and next COLUMN object index pointers:
            curr_ind = columns.index[j]
            next_ind = columns_end_index[j]
        
          ; name of current column:
          name = "COLUMN" + CLEAN(string(j+1),/SPACE)     ; external routine
        
          ; extract start byte value for current column:
          ; determine the index for current start_byte values to be assigned:
          pos = where (long(keywds.start_byte.index) GT curr_ind AND long(keywds.start_byte.index) LT next_ind)
          start_byte = long(keywds.start_byte.val[pos(0)])
        
          ; the temp buffer to be read is: difference between start_byte of
          ; current column and last curpos:
          buffer_length = start_byte - container_curpos
          if (buffer_length LT 0) then begin
              print, "Error: inconsistent START_BYTE and BYTES specification" + $
                   " in COLUMNS " + CLEAN(string(j),/SPACE) + " and " + $
                   CLEAN(string(j+1), /SPACE) + "."
              GOTO, ENDFUN
          endif else if (buffer_length EQ 0) then begin
            temp = -1            
          endif else begin
            temp = bytarr (buffer_length)
            curpos = start_byte
          endelse

          ;process item objects for current COLUMN object:
          element = PROCESS_TBIN_ITEMS(keywds, items, container_curpos,curr_ind,next_ind)

          ; create column structure:
          if (temp[0] EQ -1) then begin
            col_struct = create_struct ("element", element.data)
          endif else begin
            col_struct = create_struct ("temp", temp, "element", element.data)
          endelse

          ; construct structure to be read:
          if (size(container_struct, /TYPE) NE 8) then container_struct = create_struct(name, col_struct) $
          else container_struct = create_struct(container_struct, name, col_struct)
        
          if (k ne containers.columns[container_index]-1) then j++
        endfor
       
        container_struct_aux = replicate(container_struct,containers.repetitions[container_index])        
        curpos = container_curpos*containers.repetitions[container_index] + curpos
        container_index++
        
        ; construct structure to be read:
        if (size(data_set, /TYPE) NE 8) then begin
          data_set = create_struct(container_name, container_struct_aux)
        endif else begin
          data_set = create_struct(data_set, container_name, container_struct_aux)
        endelse
       
       endelse   
          
    endfor

    ; set additional buffer array at end of record:
    ; if cursor position < rb then take the difference between 78 and curpos
    ; and create a temporary buffer to be read at the end of each record.
    ; if cursor position > rb then issue error, and exit routine:
    if (keywds.row_bytes GT curpos) then begin
        diff = keywds.row_bytes - curpos
        data_set = create_struct(data_set, "temp", bytarr(diff))
    endif else if (keywds.row_bytes LT curpos) then begin
        print, "Error: Invalid START_BYTE or BYTES specification in label."
        GOTO, ENDFUN
    endif      
    
    endelse
    

    if (opt.suffix GT 0) then begin
        data_set = create_struct(data_set, "suffix", bytarr(opt.suffix))
    endif

    ; replicate data structure ROWS times:
    data_set = replicate (data_set, keywds.rows)

    ; construct the complete data structure:
    complete_set = create_struct (complete_set, "data_set", data_set)

    return, complete_set

    ENDFUN:
        complete_set.flag = -1
        return, complete_set
end

;-----------------------------------------------------------------------------
; precondition: pointer is a structure containing viable pointer information
;     for current table object, data_struct contains the data structure to
;     be read from file, keywds contains all the required keyword info, and 
;     silent is set to either 0 or 1 depending on the function specification.
; postcondition: this subroutine reads the data from the pointer datafile
;     and returns the data structure.
;

function READ_TBIN_DATA, pointer, data_struct, keywds, silent
    ; error protection:
    on_ioerror, SIGNAL

    ; construct data_set structure:
    data_set = create_struct("flag", 1)

    ; first inform user of status:
    if (silent EQ 0) then begin
        text = CLEAN(string(keywds.columns), /SPACE) + " Columns and " + $
               CLEAN(string(keywds.rows), /SPACE) + " Rows" ; external routine
        print, "Now reading table with " + text
    endif

    ; open the file:
    if (keywds.arch eq "MSB") then begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_little_endian
    endif else begin 
        openr, unit, pointer.datafile, /get_lun, /swap_if_big_endian
    endelse

    ; now read data after setting the file pointer to skip:
    point_lun, unit, pointer.skip
    readu, unit, data_struct
    close, unit
    free_lun, unit
    data_set = create_struct(data_set, "data", data_struct)

    return, data_set

    SIGNAL:
        on_ioerror, NULL
        print, "Error: File either corrupted or bad PDS label."
        data_set.flag = -1
        close, unit
        free_lun,unit
        return, data_set
end


function FORMAT_COLUMN, element, keywds, items, repetitions, rows, type, index1, index2

  stat = size(element, /TYPE)
  
  ; check to see if current column is a structure:
  if (stat EQ 8) then begin
    ; determine item bytes for current column:
    if (index1 EQ keywds.columns - 1) then begin
      bytes = items.bytes.val[items.bytes.count - 1]
      items_count = items.items.val[items.bytes.count - 1]
    endif else begin
      pos = where (items.bytes.index GT keywds.bytes.index[index1])
      bytes = items.bytes.val[pos[0]]
      items_count = items.items.val[pos[0]]
    endelse

    ; perform conversion of the element into arrays using routine:
    stat = size(element.item_elem.element)
    
    if (repetitions eq 0) then begin
      if (items_count eq 2) then begin
        combo = bytarr(stat[1], 2, stat[2])
        combo[*, 0, *] = element.item_elem.element
        combo[*, 1, *] = element.last.element
        temp = BTABVECT2(combo, type, rows, bytes)
      endif else begin
        
        if float(strtrim(items_count,1)) ne 1 then begin
            combo = bytarr(stat[1], stat[2] + 1, stat[3])
            combo[*, 0:stat[2] - 1, *] = element.item_elem.element
            combo[*, stat[2], *] = element.last.element
        endif else begin
            combo = bytarr(stat[1], stat[2], stat[3])
            combo = element.item_elem.element
        endelse
        temp = BTABVECT2(combo, type, rows, bytes)
      endelse

    endif else begin
      combo = bytarr(repetitions, stat[2] + 1, stat[3], stat[4])
      combo[*,0:stat[2]-1,*,*] = element.item_elem.element
      combo[*,stat[2],*,*] = element.last.element
      
      temp = BTABVECT2(combo, type, rows, bytes, repetitions)
    endelse
  endif else begin
    bytes = keywds.bytes.val[index2]
    temp = (repetitions eq 0) ? BTABVECT2(element, type, rows, bytes) : BTABVECT2(element, type, rows, bytes, repetitions)  ; external routine
  endelse

  return, temp
end


;-----------------------------------------------------------------------------
; precondition: keywds contains the required keyword params, data contains
;     the data as read from the file in a structure format.
; poscondition: the data structure is parsed and all the column data is 
;     extracted, organized into arrays, and returned as a structure.
function ORGANIZE_TBIN_DATA, keywds, items, data
    ; initialize data structures:
    data_set = create_struct("flag", 1)
    name_val = keywds.name.val[0:keywds.name.count-1]
    data_struct = create_struct("names", name_val)
    rows = keywds.rows

    ;; Check if container object
    names = tag_names(data)
    pos = where(strmid(names,0,9) eq "CONTAINER",count)
    if (count eq 0) then begin

    ; go through each column and convert data structure into array:
    for i = 0, keywds.columns - 1 do begin
        ; get the column title and data type:
        title = "column" + CLEAN(i + 1,/SPACE)
        type = keywds.data_type.val[i]

        ; obtain the ith tag's element and store it as temp element, and 
        ; determine the type of object element is, i.e., a structure, array:
        if (size(data.(0), /TYPE) NE 8) then element = data.(i+1).element $
        else element = data.(i).element
        stat = size(element, /TYPE)

        temp = FORMAT_COLUMN(element, keywds, items, 0, rows, type, i, i)
            
        ; if conversion not successful then return to main block with flag:
        if (temp.flag EQ -1) then begin
            GOTO, ENDFUN 
        endif

        ; add to data structure:
        data_struct = create_struct(data_struct, title, temp.vector)
    endfor
    
    endif else begin
    
      column_ind = 0ULL
      total_ind = 0ULL
      
      ; go through each column and convert data structure into array:
      for i = 0, n_elements(names)-1 do begin
      
        if (strmid(names[i],0,9) eq "CONTAINER") then begin
          container_content = tag_names(data.(i))
          stat = size(data.(i))
          repetitions = stat[1] ;; repetitions
          total_ind++
          
          container_struct = 0
          for j=0,n_elements(container_content)-1 do begin
          
            title = "column" + CLEAN(column_ind + 1,/SPACE)
            type = keywds.data_type.val[column_ind]
            element = data.(i).(j).element
          
            temp = FORMAT_COLUMN(element, keywds, items, repetitions, rows, type, i, total_ind)
            if (temp.flag EQ -1) then goto, endfun ; if conversion not successful then return to main block with flag
            
            ; add to data structure:
            container_struct =  (size(container_struct, /TYPE) NE 8) ? create_struct(title, temp.vector) : create_struct(container_struct, title, temp.vector)
          
            column_ind++
            total_ind++
          
          endfor
        
          data_struct = create_struct(data_struct,names[i],container_struct)
        
        endif else begin  
          
          title = "column" + CLEAN(column_ind + 1,/SPACE)
          type = keywds.data_type.val[column_ind]
          
          ; obtain the ith tag's element and store it as temp element, and 
          ; determine the type of object element is, i.e., a structure, array:
          if (size(data.(0), /TYPE) NE 8) then element = data.(i+1).element else element = data.(i).element
          
          temp = FORMAT_COLUMN(element, keywds, items, 0, rows, type, i, total_ind)
          if (temp.flag EQ -1) then goto, endfun ; if conversion not successful then return to main block with flag

          ; add to data structure:
          data_struct = create_struct(data_struct, title, temp.vector)
          
          column_ind++
          total_ind++
        endelse
    
      endfor
    
    endelse

    data_set = create_struct(data_set, "data", data_struct)
    return, data_set

    ENDFUN:
       data_set.flag = -1
       return, data_set
end

;- level 0 -------------------------------------------------------------------

function TBINPDS, fname, label, objindex, SILENT=silent
    ; error protection:
    ;ON_ERROR, 2

    ; check for number of parameters in function call:
    if (n_params() LT 3) then begin
        print, "Syntax: Result = TBINPDS (filename,label,objindex[,/SILENT])"
        return, -1
    endif

    ; check for silent keyword:
    silent = keyword_set(SILENT)

    ; obtain viable objects for label:
    objects = OBJPDS(label, "ALL")                         ; external routine
    if (objects.flag EQ -1) then begin
        print, "Error: No viable TABLE objects found in label."
        return, -1
    endif

    ; match the indices of all viable objects against objindex:
    objpos = where (objindex EQ objects.index)

    ; if a match is found, then store the name of that object, else 
    ; indicate the specification of invalid objindex:
    if (objpos[0] NE -1) then begin
        objects.array = objects.array[objpos[0]]
        objectname = objects.array[0]
    endif else begin
        print, "Error: Invalid objindex specified."
        return, -1
    endelse

    ; set start and end object pointers for current table object:
    start_ind = objindex
    end_ind = GET_INDEX(label, start_ind)                  ; external routine
    if (end_ind EQ -1) then begin
        return, -1
    endif

    ; check for valid interchange format using subroutine:
    if (TBIN_INTERFORM(label, start_ind, end_ind) EQ -1) then begin
        return, -1
    endif

    ; obtain required keywords for the current object:
    req_keywds = OBTAIN_TBIN_REQ(label, start_ind, end_ind)   ; subroutine
    if (req_keywds.flag EQ -1) then begin
        return, -1
    endif

    ; obtain optional keywords for current object:
    opt_keywds = OBTAIN_TBIN_OPT(label, start_ind, end_ind)    ; subroutine
    if (opt_keywds.flag EQ -1) then begin
        return, -1
    endif

    ; obtain items keywords for the column objects using subroutine:
    items = OBTAIN_TBIN_ITEMS(label, req_keywds, start_ind, end_ind)
    if (items.flag2 EQ -1) then begin
        return, -1
    endif

    ; obtain CONTAINER objects for the column objects using subroutine:
    containers = OBTAIN_TBIN_CONTAINERS(label, req_keywds, start_ind, end_ind)
    if (containers.flag2 EQ -1) then begin
        return, -1
    endif
   
   ; obtain BIT_COLUMN objects for the column objects using subroutine:
    bit_columns = OBTAIN_TBIN_BIT_COLUMNS(label, req_keywds, start_ind, end_ind)
    if (bit_columns.flag2 EQ -1) then begin
        return, -1
    endif
   
    ; check consistency of COLUMN objects and COLUMNS keyword
    ; note: only when no CONTAINER/BIT_COLUMN objects are present, and no ITEM keywords used
    ;       because it is not clear how to count the number of columns in those cases
    if (containers.flag EQ -1 and bit_columns.flag EQ -1 and items.flag EQ -1) then begin
      column_objects = objpds(label, "COLUMN")
      pos = where(column_objects.index gt start_ind and column_objects.index lt end_ind,count)
      if (count ne req_keywds.columns) then $
        print,'Warning: COLUMNS keyword value not consistent with number of COLUMN objects.'
    endif
   
    ; obtain pointer information for table object:
    pointer = POINTPDS (label, fname, objectname)          ; external routine
    if (pointer.flag EQ -1) then begin
        return, -1
    endif        

    ; create data structure to be read:
    complete_set = CREATE_TBIN_STRUCT(req_keywds, opt_keywds, items, containers, label, $
                                       start_ind, end_ind)    ; subroutine
    if (complete_set.flag EQ -1) then begin
        return, -1
    endif else begin
        data_struct = complete_set.data_set
    endelse
    
    ; read data structure from file using subroutine:
    data_set = READ_TBIN_DATA(pointer, data_struct, req_keywds, silent)
    if (data_set.flag EQ -1) then begin
        return, -1
    endif

    data = data_set.data
    
    ; separate data into columns and convert into appropriate type:
    data_set = ORGANIZE_TBIN_DATA(req_keywds, items, data) ; subroutine
    if (data_set.flag EQ 1) then begin
        data = data_set.data
    endif else begin
        return, -1
    endelse

    ;; Reverse byte order if:
    ;;   - MSB architecture and little-endian machine
    ;;   - LSB architecture and big-endian machine
    if (req_keywds.arch eq "MSB") then data = swap_endian(data,/swap_if_little_endian) $
    else data = swap_endian(data,/swap_if_big_endian)
    
    ;;
    ;; Process BIT_COLUMN objects if present and add to current structure
    if (bit_columns.flag EQ -1) then return, data 
    data = PROCESS_TBIN_BIT_COLUMNS(data, label, req_keywds, bit_columns)
    
    return, data
end
