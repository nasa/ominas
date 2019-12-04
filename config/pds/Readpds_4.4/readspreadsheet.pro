; $Id: readspreadsheet.pro,v 1.2 2007/04/27 16:31:45 santam Exp $
;
; Copyright (c) ESA/ESTEC/SCI-SB
;   Use as is
;
;+
; NAME:
;      READSPREADSHEET
;
; PURPOSE:
;      This function reads data in PDS Spreadsheet object.
;
;      This function is meant to be integrated into the READPDS package
;      from the PDS Small Bodies Node to add spreadsheet support.
;
; CATEGORY:
;      Scientific Data Extraction Routines
;
; CALLING SEQUENCE:
;      Result = READSPREADSHEET(filename, label, objindex [,SILENT] [,PRINT_TIME])
;
;      Note: this routine is intended to be called from the READPDS.PRO routine
;      (see examples below)
;
; INPUTS:
;      Filename: Scalar string containing the name of the PDS file to read.
;      Label: String array containing the spreadsheet label information.
;      Objindex: Integer specifying the starting index of the current object
;         in the label array to be read.
;
; OUTPUTS:
;      Result: Spreadsheet structure containing records for each field in the object,
;      along with a string array NAMES with the names of all the fields.
;
; OPTIONAL INPUT:
;      SILENT: Suppresses any messages from the procedure.
;      PRINT_TIME: Prints processing times for each of the Fields
;
; EXTERNAL FUNCTIONS USED:
;      SBNIDL ReadPDS Package: OBJPDS, GET_INDEX, CLEAN, REMOVE, STR2NUM, PDSPAR, POINTPDS
;
; PROCEDURE:
;      (1) Preprocess object definition parameters
;      (2) Create data structure to be read
;      (3) Read data structure from file using subroutine
;      (4) Re-organize data structures into arrays
;      (5) Return Data
;
; SIDE EFFECTS:
;      Fields with missing values (e.g. 2,1,,,4,5,,7,,,) are converted to ZERO
;      This should be corrected in a later version. Possible using NaN (!values.f_nan)
;
; TEST STATUS
;      This routine has been tested on SUN/SPARC/SOLARIS2.9 and WINDOWS XP with IDL6.1
;
; EXAMPLES:
;      This routine is intended to be called from the READPDS.PRO routine
;      To read a PDS file TEST.LBL into an IDL spreadsheet structure, spr:
;        IDL> spr = READPDS ("TEST.LBL",/SILENT)
;        IDL> help, /STRUCTURE, spr
;               OBJECTS      INT       1
;               SPREADSHEET  STRUCT    -> <Anonymous> Array[1]
;        IDL> help, /STRUCTURE, spr.(1)
;               NAMES           STRING    Array[8]
;               FIELD1           TYPE     Array[...]
;               FIELD2           TYPE     Array[...]
;                ...
;               FIELDN           TYPE     Array[...]
;
; MODIFICATION HISTORY:
;   Written by: A.Cardesin (ESA/ESTEC), 2006Feb (based on TASCPDS by P.Khetarpal)
;-

;-----------------------------------------------------------------------------
; (1.3.1) obtain keyword from spreadsheet object
;-----------------------------------------------------------------------------
; precondition: the KWname variable is a viable required keyword scalar string,
;     label is a viable PDS label string array, and start and end_ind are
;     viable integers pointing at the start and end of the current spreadsheet
;     object being processed. objname is the name of the current object
; postcondition: extracts the "KWname" keyword from the label, stores it in a
;     structure, and returns to the main block.

function obtain_Spreadsheet_keyword, KWname, label, start_ind, end_ind, objname
   ; initialize keyword structure:
   struct = create_struct("flag",1)

   ; obtain keyword parameters:
   val = pdspar (label, KWname, count=count, index=index)    ; external routine

   ; if no viable params found, then issue error:
   if (count eq 0) then begin
       print, "Error in object " + objname + $
       " : missing required " + KWname + " keyword(s) for SPREADSHEET object."
       goto, endfun
   endif

   ; extract the indices where keyword index is between start_ind and end_ind:
   pos = where (index gt start_ind and index lt end_ind, cnt)

   ; if none found then return flag as -1:
   if (cnt eq 0) then goto, endfun

   ; store the viable values, indices, and count for "name" keyword:
   val = val[pos]
   index = index[pos]
   count = n_elements(val)

   ; place the stored params in the structure:
   struct = create_struct(struct,"val",val,"count",count,"index",index)
   return, struct

   endfun:
      struct.flag = -1
      return, struct
end

;-----------------------------------------------------------------------------
; (1.3.2) remove SpreadSheet name from name structure if present
;-----------------------------------------------------------------------------
; precondition: name is a structure containing all names param for current
;     Spreadsheet object, label is a viable PDS label string array, and start_ind
;     and end_ind are integer pointers to start and end of current object.
; postcondition: the SpreadSheet name is searched through all the name values and
;     then removed from the structure, the count is decremented by one, and
;     the index value is also removed from the corresponding structure field.
;

function remove_SpreadSheet_name, name, label, start_ind, end_ind
    ; first obtain COLUMN object indices for current SpreadSheet object:
    field = objpds(label, "FIELD")                      ; external routine
    pos = where (field.index gt start_ind and field.index lt end_ind)
    field.index = field.index[pos]

    ; check to see if the first name index is less than the first field
    ; index value. If found then there exists a spreadsheet name, and is removed:
    if (name.index[0] lt field.index[0]) then begin
        name.val = name.val[1:name.count - 1]
        name.index = name.index[1:name.count - 1]
        name.count = name.count - 1
    endif

    ; clean up name array values, and removed unwanted characters:
    param = ['"', "'", "(", ")"]
    for j = 0, name.count-1 do begin
        name.val[j] = clean (name.val[j])                 ; external routine
        name.val[j] = remove (name.val[j], param)         ; external routine
    endfor

    return, name
end

;-----------------------------------------------------------------------------
; (1.3.3) obtain data architecture and clean data type
;-----------------------------------------------------------------------------
; precondition: data_type is a structure containing the required keyword
;     params for DATA_TYPE keyword.
; postcondition: the data type keyword values are cleaned, and the values after
;     the first '_' character are extracted, if present.
;

function clean_SpreadSheet_data_type, data_type
    ; set the param variable:
    param = ['"', "'", ")", "("]

    ; start the loop to go through each data_type value array:
    for j = 0, data_type.count - 1 do begin
        ; first clean data_type:
        data_type.val[j] = clean (data_type.val[j], /space)  ; external routine
        data_type.val[j] = remove (data_type.val[j], param)  ; external routine

        ; extract the second component of value if '_' present:
        temp = strsplit(data_type.val[j], '_', /extract)

        if (n_elements(temp) eq 3) then begin
            data_type.val[j] = temp[1] + '_' + temp[2]
        endif else if (n_elements(temp) gt 1) then begin
            data_type.val[j] = temp[1]
        endif
    endfor

    return, data_type
end

;-----------------------------------------------------------------------------
; (1.3) Obtain required keywords for the current object
;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label string array, and start_ind and
;     end_ind are valid integers specifying the start and end of the
;     current spreadsheet object as index pointers in the string array.
;     objname is the name of the current object
; postcondition: extracts required keywords for spreadsheet object in the label.
; procedure:
;     (1.3.1) obtain spreadsheet object definitions for current object
;     (1.3.2) remove SpreadSheet name from name structure if present
;     (1.3.3) obtain data architecture and clean data type
;     (1.3.4) return structure with the keywords and their values


function obtain_SpreadSheet_req, label, start_ind, end_ind, objname
    ; initialize keyword structure:
    keywds = create_struct("flag",1)

    ; (1.3.1) obtain spreadsheet object definitions for current object:
    ; extract the keyword structure from subroutine, and check whether
    ; there are any params for the keyword, if not then return to main block
    ; else store the value

    ; first obtain number of FIELDS:
    fields_num = obtain_spreadsheet_keyword("FIELDS", label, start_ind, end_ind, objname)
    if (fields_num.flag eq -1) then goto, endfun
    fields = fix(fields_num.val[0])

    ; obtain ROW_BYTES keyword:
    row_bytes = obtain_spreadsheet_keyword("ROW_BYTES",label, start_ind, end_ind, objname)
    if (row_bytes.flag eq -1) then goto, endfun
    row_bytes = long(row_bytes.val[0])

    ; obtain ROWS keyword:
    rows = obtain_spreadsheet_keyword("ROWS", label, start_ind, end_ind, objname)
    if (rows.flag eq -1) then goto, endfun
    rows = long(rows.val[0])

    ; obtain FIELD_DELIMITER keyword:
    field_delimiter = obtain_spreadsheet_keyword("FIELD_DELIMITER", label, start_ind, $
                                                                    end_ind, objname)
    if (field_delimiter.flag eq -1) then goto, endfun
    if n_elements(field_delimiter.val) EQ 1 then $
     field_delimiter = strtrim(field_delimiter.val[0],2) $
    else begin
     print, "Error in object "+ objname +": FIELD_DELIMITER is not well defined."
     goto, endfun
    endelse

    ; check whether either fields, rows or row_bytes equal 0:
    if (fields * rows * row_bytes le 0) then begin
        print, "Error in object "+ objname +": ROWS or ROW_BYTES or FIELDS <= 0."
        goto, endfun
    endif

    ; obtain information for each FIELD object:

    ; obtain NAME keyword:
    name = obtain_spreadsheet_keyword("NAME", label, start_ind, end_ind, objname)
    if (name.flag eq -1) then goto, endfun

    ; obtain DATA_TYPE keyword, then clean, separate, and extract it:
    data_type = obtain_spreadsheet_keyword("DATA_TYPE", label, start_ind, end_ind, objname)
    if (data_type.flag eq -1) then goto, endfun

    ; obtain BYTES keyword:
    bytes = obtain_spreadsheet_keyword ("BYTES", label, start_ind, end_ind, objname)
    if (bytes.flag eq -1) then goto, endfun
    ;check that bytes is positive
    void = where (bytes.val le 0, count)
    if (count gt 0) then begin
        print, "Error in object "+ objname +": BYTES <= 0."
        goto, endfun
    endif

    ;
    ; (1.3.2) remove SpreadSheet name from name structure if present:
    ;
    name = remove_SpreadSheet_name(name, label, start_ind, end_ind)

    ;
    ; (1.3.3) obtain data architecture and clean data type:
    ;
    data_type = clean_SpreadSheet_data_type(data_type)

    ;
    ; (1.3.4) return structure with the keywords and their values
    ;
    keywds = create_struct(keywds, "fields",fields,"row_bytes",row_bytes, $
                           "rows",rows,"field_delimiter",field_delimiter, $
                           "name",name,"data_type",data_type,"bytes",bytes)
    return, keywds

    endfun:
       keywds.flag = -1
       return, keywds
end


;-----------------------------------------------------------------------------
; (1.4) Obtain items keywords for the field objects using subroutine
;-----------------------------------------------------------------------------
; precondition: label is viable PDS label string array, req_keywds is a
;     structure containing required spread object keywords, and start and
;     end_ind are viable integer pointers to start and end of the current
;     spreadsheet object. objname is the name of the current object read
; postcondition: Extracts spreadsheet items keyword params from label and returns
;     to main block as a structure.
;     flag=-1: no items found   flag2=-1: items found, ITEM_BYTES missing or erroneous
; procedure:
;     (1.4.1) obtain necessary ITEM keyword values
;     (1.4.2) extract values of items between start_ind and end_ind, and store
;     (1.4.3) obtain ITEM_BYTES keyword values
;     (1.4.4) Return structure with the keywords

function obtain_spreadsheet_items, label, req_keywds, start_ind, end_ind, objname
    ; initialize items keyword structure:
    keywds = create_struct("flag", 1, "flag2", 1)

    ;
    ; (1.4.1) obtain necessary ITEM keyword values:
    ;
    items = pdspar (label, "ITEMS", count=items_count, index=items_index)
    if (items_count eq 0) then begin
        goto, endfun
    endif

    ;
    ; (1.4.2) extract values of items between start_ind and end_ind, and store:
    ;
    pos = where (items_index gt start_ind and items_index lt end_ind, cnt)
    if (cnt eq 0) then goto, endfun
    if (items[pos] le 0) then begin
        print, "Error in object "+ objname +": ITEMS cannot be <= 0."
        keywds.flag2 = -1
        goto, endfun
    endif

    items = create_struct("val",items[pos],"count",n_elements(items), $
                          "index",items_index[pos])

    ; now we know that there are fields with ITEMS keyword in current
    ; spreadsheet object, so extract the other item keyword values:

    ;
    ; (1.4.3) obtain ITEM_BYTES keyword values:
    ;
    bytes = pdspar (label, "ITEM_BYTES", count=byte_count, index=byte_index)
    if (byte_count eq 0) then begin
        print, "Error in object "+ objname +": missing required ITEM_BYTES keyword."
        keywds.flag2 = -1
        goto, endfun
    endif
    pos = where (byte_index gt start_ind and byte_index lt end_ind, cnt)
    if (cnt eq 0) then begin
        print, "Error in object "+ objname +": missing required ITEM_BYTES keyword."
        keywds.flag2 = -1
        goto, endfun
    endif
    if (bytes[pos] le 0) then begin
        print, "Error in object "+ objname +": ITEM_BYTES cannot be <= 0."
        keywds.flag2 = -1
        goto, endfun
    endif

    bytes = create_struct("val", bytes[pos], "count", n_elements(bytes), $
                          "index", byte_index[pos])

    ;
    ; (1.4.4) Return structure with the keywords
    ;

    ; store info into a structure:
    keywds = create_struct(keywds, "items",items, "bytes",bytes)
    return, keywds

    endfun:
        keywds.flag = -1
        return, keywds
end

;-----------------------------------------------------------------------------
; (2.1.2) process item objects for current FIELD object
;-----------------------------------------------------------------------------
; precondition: keywds contains all required keyword values in a structure,
;     items contains all item keyword values, curr_ind and next_ind are
;     integer pointers to current and next field object being processed, and
; postcondition: the routine tests whether there are any items defined for
;     current field object, and if found, then populates the necessary
;     item structure for current field object and returns to main block.
;     If no items are found, returns a single element null string''.
; procedure:
;   (2.1.2.1) determine whether there exist ITEMS for current FIELD:
;   (2.1.2.2) if items not present then create a one-element field (null string)
;   (2.1.2.3) if items are present, check keywords and create a field with n elements
;   (2.1.2.4) return data into field object structure
;

function process_field_items, keywds, items, curr_ind, next_ind, objname

    object_struct = create_struct("flag", 1)      ; structure to be returned

    ;
    ; (2.1.2.1) determine whether there exist ITEMS for current FIELD:
	;
    if (items.flag eq -1) then begin
        ipos = -1
    endif else begin
        ipos = where (items.items.index gt curr_ind and items.items.index lt $
                  next_ind)
    endelse

    ;
    ; (2.1.2.2) if items not present then create a one-element field (null string)
    ;
    if (ipos[0] eq -1) then begin

        field = ''

    endif else begin
    ;
    ; (2.1.2.3) if items are present, check keywords and create a field with num_items elements
    ;
    num_items  = long(items.items.val[ipos[0]])
    if num_items lt 1 then begin
        print, "Error in object "+objname+": keyword ITEMS must be greater that 0"
        goto, endfun
    endif

    item_bytes = long(items.bytes.val[ipos[0]])
    if item_bytes lt 1 then begin
        print, "Error in object "+objname+": keyword ITEM_BYTES must be greater that 0"
        goto, endfun
    endif

    ; Create a field with num_items elements
    field = strarr(num_items)

    endelse

    ;
    ; (2.1.2.4) return data into field object structure:
    ;
    object_struct = create_struct(object_struct, "data",field)
    return, object_struct

    endfun:
        object_struct.flag = -1
        return, object_struct
end

;-----------------------------------------------------------------------------
; (2.1.3) Create field structure with the correct data type
;-----------------------------------------------------------------------------
; precondition: element is a n dimensional string array
; postcondition: element is converted into an n dimensional array of type
;     "type", and returned to main block.
;

function convert_spreadsheet_element, element, type
    ; error protection:
    on_ioerror, error_case

    ; depending on the case of the type assign each element to its own
    ; element conversion type:
    data = create_struct("flag",1)
    stat = size(element)

    case type of
               "CHARACTER": break ; it is already a string
                    "TIME": break ; it is already a string
                    "DATE": break ; it is already a string
                    "REAL": element = double(element)
                 "INTEGER": element = long(element)
        "UNSIGNED_INTEGER": element = long(element)
                   "FLOAT": element = float(element)
                  "DOUBLE": element = double(element)
                    "BYTE": element = byte(long(element))
                 "BOOLEAN": element = long(element)
                     "N/A": ; no conversion performed, spare column
                      else: begin
                                print, "Error: " + type + $
                                       " is not a recognized data type!"
                                data.flag = -1
                                return, data
                            end
    endcase

    data = create_struct(data, "element",element)
    return, data

    error_case:
        on_ioerror, null
        print, "WARNING: bad DATA_TYPE definition. Data will be treated as string"
        data = create_struct(data, "element", element)
        return, data
end

;-----------------------------------------------------------------------------
; (2) Create data structure to be read:
;-----------------------------------------------------------------------------
; precondition: keywds contains required keywords for current spreadsheet object,
;     label is a viable PDS label string array, start_ind and end_ind are integer
;     pointers to start and end of current spreadsheet object, objname is the name
;     of the current object
; postcondition: creates a structure to be read from the data file and returns
;     to the main block.
; procedure:
;   (2.1) LOOP: for each FIELD object
;    (2.1.1) Set current and next FIELD object index pointers
;    (2.1.2) process item objects for current FIELD object
;    (2.1.3) Create field structure with the correct data type
;    (2.1.4) Add to current row structure
;   (2.2) Return the complete data structure, replicating row_struct ROWS times
;

function create_spreadsheet_struct, keywds, items, label, start_ind, end_ind, objname
    ; initialize variables:
    complete_set = create_struct("flag", 1)      ; structure to be returned
    row_struct = 0          ; structure of a row of data

    ;
    ; (2.1) LOOP: for each FIELD object
    ;
    for j = 0, keywds.fields - 1 do begin

        ;
        ; (2.1.1) Set current and next FIELD object index pointers:
        ;
        curr_ind = keywds.name.index[j]
        if (j eq keywds.fields - 1) then begin
            next_ind = end_ind
        endif else begin
            next_ind = keywds.name.index[j+1]
        endelse

        ; name of current field: FIELDi
        name = "FIELD" + clean(string(j+1),/space)     ; external routine

    	;
        ; (2.1.2) process items for current FIELD object:
        ;
        element = process_field_items (keywds, items, curr_ind,next_ind,objname)
        if element.flag eq -1 then goto, endfun

        ;
        ; (2.1.3) Create field structure with the correct data type
        ;

        ;type of current field
        type = keywds.data_type.val[j]

        ;convert current field to the specified type
        temp_field = convert_spreadsheet_element(element.data, type)  ; subroutine
        ; if conversion not successful then return to main block with flag:
        if (temp_field.flag eq -1) then begin
           print, "Error converting data in field ", strtrim(j+1,2)
           goto, endfun
        endif

	; create field structure
        field_struct = create_struct ("element", temp_field.element)

        ;
        ; (2.1.4) Add to current row structure
        ;
        if (size(row_struct,/TNAME) eq 'STRUCT') then begin
            row_struct = create_struct(row_struct, name, field_struct)
        endif else begin
            row_struct = create_struct(name, field_struct)
        endelse
    endfor

    ;
    ; (2.2) Return the complete data structure, replicating row_struct ROWS times
    ;
    complete_set = create_struct (complete_set, "data_set", replicate (row_struct, keywds.rows))

    return, complete_set

    endfun:
        complete_set.flag = -1
        return, complete_set
end

;-----------------------------------------------------------------------------
; (3) Read spreadsheet data structure from file
;-----------------------------------------------------------------------------
; precondition: pointer is a structure containing viable pointer information
;     for current spreadsheet object, data_struct contains the data structure to
;     be read from file, keywds contains all the required keyword info, and
;     silent is set to either 0 or 1 depending on the function specification.
; postcondition: this subroutine reads the data from the pointer datafile
;     and returns the data structure.
; procedure:
;   (3.1) construct data_set structure
;   (3.2) open file and read data after setting the file pointer to skip
;   (3.3) Find field separator (as defined in the keyword FIELD_DELIMITER)
;   (3.4) LOOP: read each line, separate fields and put them into the structure
;   (3.5) Close and return structure

function read_spreadsheet_data, pointer, data_struct, keywds, silent
    ; error protection:
    on_ioerror, signal

    ;
    ; (3.1) construct data_set structure:
    ;
    data_set = create_struct("flag", 1)

    ; first inform user of status:
    if (silent eq 0) then begin
        text = clean(string(keywds.fields), /space) + " Fields and " + $
               clean(string(keywds.rows), /space) + " Rows" ; external routine
        print, "Now reading Spreadsheet with " + text
    endif

    ;
    ; (3.2) open file and read data after setting the file pointer to skip:
    ;
    openr, unit, pointer.datafile, /get_lun
    point_lun, unit, pointer.skip

    ;
    ; (3.3) Find field separator (as defined in the keyword FIELD_DELIMITER)
    ;
    case strjoin(strsplit(keywds.field_delimiter,'"',/EXTRACT)) of

       "COMMA"       : separator = ','
       "SEMICOLON"   : separator = ';'
       "VERTICAL_BAR": separator = '|'
       "TAB"         : separator = string(BYTE(9)) ;TAB character (ascii 9)
       else: begin
               print, "Error in spreadsheet object definition: " + $
                      "Field separator: " + keywds.field_delimiter + " is not valid."
               goto, signal
               end
    endcase


    ;
    ; (3.4) LOOP: read each line, separate fields and put them into the structure
    ;

    textline = ''

    ; Instead of reading the whole structure at once,
    ; I will read line by line and fill the structure myself
    for i=0L,long(keywds.rows)-1 do begin

        readf, unit, textline

        ; separate fields
        asciifields = strsplit(textline, separator, /EXTRACT, $
                              COUNT=count, /PRESERVE_NULL )

        ; I treat missing values as ZERO.
        ; This should be corrected in the future to use NaN
        indx = where(asciifields EQ '', count)
        if count gt 0 then $
            asciifields[indx] = '0'

        ; read each line into the data_struct
        ; I use tempstruct as I cannot index a structure while reading
        tempstruct = data_struct[i]
        reads, asciifields, tempstruct
        data_struct[i] = tempstruct

    endfor   ; ENDLOOP

    ;
    ; (3.5) Close and return structure
    ;
    close, unit
    free_lun, unit
    data_set = create_struct(data_set, "data", data_struct)

    return, data_set

    signal:
        on_ioerror, null
        print, "Error: Bad Fields/Items Definition or bad data. Cannot read."
        data_set.flag = -1
        return, data_set
end


;-----------------------------------------------------------------------------
; (4) Re-organize data structures into arrays
;-----------------------------------------------------------------------------
; precondition: keywds contains the required keyword params, data contains
;     the data as read from the file in a structure format, print_time is a flag
; poscondition: the data structure is parsed and all the field data is
;     extracted, organized into arrays, and returned as a structure.
;     If print_time is active the time consumed in each loop is printed
; procedure:
;   (4.1) initialize data structures: flag, names and rows
;   (4.2) LOOP: go through each field and re-organise data structures into arrays
;   (4.3) Create structure and return

function organize_spreadsheet_data, keywds, data, print_time

    ; Init time to print if PRINT_TIME mode is active
    startTime = systime(1)

    ;
    ; (4.1) initialize data structures: flag, names and rows
    ;
    data_set = create_struct("flag", 1)
    name_val = keywds.name.val[0:keywds.name.count-1]
    data_struct = create_struct("names", name_val)
    rows = keywds.rows

    ;
    ; (4.2) LOOP: go through each field and re-organise data structures into arrays:
    ;
    for i = 0, keywds.fields - 1 do begin

        ; set the field title
        title = "field" + clean(i + 1,/space)

	; check if a field has items or not
        if (size(data.(0), /tname) eq 'STRUCT') then begin
            data_struct = create_struct(data_struct, title, data.(i).element)
        endif else begin
            data_struct = create_struct(data_struct, title, data.(i+1).element)
        endelse

  	; print time if PRINT_TIME mode is active
    	if PRINT_TIME then begin
            iTime=sysTime(1)
            print, "Field ", strtrim(string(i+1),2),$
                   " converted in ", iTime - startTime," seconds."
            startTime = iTime
            empty
        endif

    endfor     ; ENDLOOP

    ;
    ; (4.3) Create structure and return
    ;
    data_set = create_struct(data_set, "data", data_struct)

    return, data_set

    endfun:
       data_set.flag = -1
       return, data_set
end


;==========================================================================
; MAIN FUNCTION
;==========================================================================
;(1) Preprocess object definition parameters
;   (1.1) obtain viable objects for label
;   (1.2) Set start/end indices for all viable objects
;   (1.3) Obtain required keywords for the current object
;     (1.3.1) obtain spreadsheet object definitions for current object
;     (1.3.2) remove SpreadSheet name from name structure if present
;     (1.3.3) obtain data architecture and clean data type
;     (1.3.4) return structure with the keywords and their values
;   (1.4) Obtain items keywords for the field objects using subroutine
;     (1.4.1) obtain necessary ITEM keyword values
;     (1.4.2) extract values of items between start_ind and end_ind, and store
;     (1.4.3) obtain ITEM_BYTES keyword values
;     (1.4.4) Return structure with the keywords
;   (1.5) Obtain pointer information for spreadsheet object
;
;(2) Create data structure to be read
;   (2.1) LOOP: for each FIELD object
;     (2.1.1) Set current and next FIELD object index pointers
;     (2.1.2) process item objects for current FIELD object
;       (2.1.2.1) determine whether there exist ITEMS for current FIELD:
;       (2.1.2.2) if items not present then create a one-element field (null string)
;       (2.1.2.3) if items are present, check keywords and create a field with n elements
;       (2.1.2.4) return data into field object structure
;    (2.1.3) construct structure to be read
;   (2.2) replicate data structure ROWS times
;   (2.3) construct the complete data structure
;
;(3) Read data structure from file using subroutine
;   (3.1) construct data_set structure
;   (3.2) open file and read data after setting the file pointer to skip
;   (3.3) Find field separator (as defined in the keyword FIELD_DELIMITER)
;   (3.4) LOOP: read each line, separate fields and put them into the structure
;   (3.5) Close and return structure
;
;(4) Re-organize data structures into arrays
;   (4.1) initialize data structures: flag, names and rows
;   (4.2) LOOP: go through each field and re-organise data structures into arrays
;   (4.3) Create structure and return
;
;(5) Return Data

FUNCTION READSPREADSHEET, filename, label, objindex, SILENT=silent, PRINT_TIME=print_time

    ; check for keywords
    silent     = keyword_set(SILENT)
    print_time = keyword_set(PRINT_TIME)

    ; Init Time to print process timing in PRINT_TIME mode
    initTime=systime(1)

    ; error protection:
    ;on_error, 2

    ; check for number of parameters in function call:
    if (n_params() lt 3) then begin
        print, "Syntax: result = readspreadsheet (filename,label,objindex[,/SILENT])"
        return, -1
    endif

;;
;; (1) Preprocess object definition parameters
;;
    ;
    ; (1.1) obtain viable objects for label:
    ;
    objects = objpds(label, "ALL")                         ; external routine
    if (objects.flag eq -1) then begin
        print, "Error: No viable SPREADSHEET objects found in label."
        return, -1
    endif

    ;
    ; (1.2) Set start/end indices for all viable objects
    ;

    ; match the indices of all viable objects against objindex:
    objpos = where (objindex eq objects.index)

    ; if a match is found, then store the name of that object, else
    ; indicate the specification of invalid objindex:
    if (objpos[0] ne -1) then begin
        objects.array = objects.array[objpos[0]]
        objectname = objects.array[0]
    endif else begin
        print, "Error: Invalid objindex specified: " + $
             clean(string(objects.index[objpos[0]]), /space)
        return, -1
    endelse

    ; set start and end object pointers for current spreadsheet object:
    start_ind = objindex
    end_ind = get_index(label, start_ind)                  ; external routine
    if (end_ind eq -1) then return, -1

    ;
    ; (1.3) Obtain required keywords for the current object:
    ;
    req_keywds = obtain_spreadsheet_req(label, start_ind, end_ind, objectname) ; subroutine
    if (req_keywds.flag eq -1) then return, -1

    ;
    ; (1.4) Obtain items keywords for the field objects using subroutine:
    ;
    items = obtain_spreadsheet_items(label, req_keywds, $      ; subroutine
    				     start_ind, end_ind, objectname)
    if (items.flag2 eq -1) then return, -1

    ;
    ; (1.5) Obtain pointer information for spreadsheet object:
    ;
    pointer = pointpds (label, filename, objectname)          ; external routine
    if (pointer.flag EQ -1) then return, -1

;;
;; (2) Create data structure to be read:
;;
    complete_set = create_spreadsheet_struct (req_keywds, items, $ ; subroutine
                                        label, start_ind, end_ind, objectname)
    if (complete_set.flag eq -1) then begin
        return, -1
    endif else begin
        data_struct = complete_set.data_set
    endelse

    ; print time if PRINT_TIME mode is active
    IF PRINT_TIME THEN BEGIN
    	preprocessTime=systime(1)
	print, "Preprocessing time :", preprocessTime-initTime, " seconds"
	empty
    ENDIF

;;
;; (3) Read data structure from file using subroutine:
;;
    data_set = read_spreadsheet_data (pointer, data_struct, req_keywds, silent)
    if (data_set.flag eq -1) then return, -1

    data = data_set.data

    ; print time if PRINT_TIME mode is active
    IF PRINT_TIME THEN BEGIN
	readTime=systime(1)
	print, "Reading time :", readTime-preprocessTime, " seconds"
	print, "Spreadsheet has been read."
	print, "Re-organising data structure..."
    ENDIF

;;
;; (4) Re-organize data inside the structure
;;
    data_set = organize_spreadsheet_data (req_keywds, data, print_time)          ; subroutine
    if (data_set.flag eq 1) then begin
        data = data_set.data
    endif else begin
        return, -1
    endelse

    ; print time if PRINT_TIME mode is active
    IF PRINT_TIME THEN BEGIN
	convertTime=systime(1)
	print, "Re-organization time :", convertTime-readTime, " seconds"
	print, "Total time :", convertTime-initTime, " seconds"
    ENDIF

;;
;; (5) Return Data
;;
    return, data
END
