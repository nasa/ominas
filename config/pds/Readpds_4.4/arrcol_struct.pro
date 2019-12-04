;------------------------------------------------------------------------------
; NAME: ARRCOL_STRUCT
;
; PURPOSE: To construct and IDL structure for a given ARRAY/COLLECTION
;     object; intended for use with ARRCOLPDS.PRO
; 
; CALLING SEQUENCE: Result = ARRCOL_STRUCT(label, objindex)
;
; INPUTS:
;     Label: String array containing ARRAY/COLLECTION header definitions
;     Objindex: Integer specifying the index in the label where the 
;         ARRAY/COLLECTION object starts
; OUTPUTS:
;     Result: ARRAY/COLLECTION idl structure constructed from
;         designated record
; 
; EXAMPLE:
;     To construct and IDL structure for VEGA1 PUMA data:
;     IDL> label = headpds('mod0bin0.lbl')
;     IDL> result = arrcol_struct(label, 20)
;
;     IDL> help, /st, result
;   ** Structure <820a61c>, 3 tags, length=637248, data length=635454, refs=1:
;   FLAG            INT              1
;   RECORD_ARRAY    STRUCT    -> <Anonymous> Array[895]
;   COUNT           INT             23
;
; PROCEDURES USED: ARRAY_STRUCT, COLL_STRUCT, ELEM_STRUCT, GET_INDEX, OBJPDS,
;     PDSPAR, REMOVE
; 
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 23, 2005]
;
;------------------------------------------------------------------------------

;-- level 3 -------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for the current object being processed
; postcondition: the name value is extracted from the label for the
;     current object and returned.

function extract_name, label, objindex, end_index
    ; initialize variable:
    flag = 0  ; name keyword found flag (0: not found, 1: found)

    ; obtain all names keyword values from label:
    names = pdspar (label, "NAME", count=name_count, index=name_index)
    if (name_count gt 0) then begin
        ; obtain index of object just below objindex object:
        objects = pdspar(label, "OBJECT", count=objcnt, index=objindices)
        objpos = where(objindices gt objindex, cnt)
        ; get names within the current object and next object indices:
        if (cnt gt 0) then begin
            greatindex = objindices[objpos[0]]
            pos = where (name_index gt objindex and name_index lt $
                      greatindex, ncnt)
        endif else begin
            pos = where (name_index gt objindex and name_index lt $
                      end_index, ncnt)
        endelse
        ; check if there was a name keyword found:
        if (ncnt gt 0) then begin
            name = names[pos[0]]
            flag = 1
        endif 
    endif 

    if (~flag) then begin
        print, "Error: missing required NAME keyword from ARRAY/COLLECTION"
        return, "-1"
    endif
  
    ; convert name to a valid idl name:
    pattern = ['"', '(', ')', ',', '.', "'"]
    name = remove(name, pattern)    
    name = idl_validname(name, /convert_all)

    return, name
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for the current object being processed
; postcondition: the bytes value is extracted from the label for the
;     current object and returned

function extract_bytes, label, cur_ind, end_index
    ; extract all bytes keyword values from the label:
    bytes_all = pdspar (label, "BYTES", count=byte_count, index=byte_index)
    if (byte_count eq 0) then begin
        print, "Error: missing required BYTES keyword from label"
        return, -1
    endif else begin
        ; obtain index of object just below objindex object:
        objects = pdspar(label, "OBJECT", count=objcnt, index=objindices)
        objpos = where (objindices gt cur_ind, cnt)
        ; get bytes within the current object and next object indices:
        if (cnt gt 0) then begin
            greatindex = objindices[objpos[0]]
            pos = where (byte_index gt cur_ind and byte_index lt $
                      greatindex, bcnt)
        endif else begin
            pos = where (byte_index gt cur_ind and byte_index lt $
                      end_index, bcnt)
        endelse

        ; check if there was a byte keyword found:
        if (bcnt eq 0) then begin
            print, "Error: missing required BYTES keyword in ELEMENT/" + $
                   "COLLECTION object"
            return, -1
        endif else begin
            bytes = fix(clean(bytes_all[pos[0]],/space),type=3)
        endelse
    endelse

    ; check validity of bytes value:
    if (bytes le 0) then begin
        print, "Error: invalid BYTES keyword value specified: " + $
               clean(string(bytes), /space)
        return, -1
    endif

    return, bytes
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for the current object being
;     processed
; postcondition: the start_byte value is extracted from the label for
;     the current object and returned 

function extract_start_byte, label, cur_ind, end_index
    ; initialize variable:
    start_byte = -1

    ; obtain all start_byte keyword values from the label:
    start_all = pdspar(label, "START_BYTE", count=startcount, index=startindex)
    if (startcount gt 0) then begin
        ; obtain index of object just below current object:
        objects = pdspar(label, "OBJECT", count=objcnt, index=objindices)
        objpos = where(objindices gt cur_ind, cnt)
        if (cnt gt 0) then begin
            greatindex = objindices[objpos[0]]
            startpos = where (startindex gt cur_ind and startindex lt $
                           greatindex)
        endif else begin
            startpos = where(startindex gt cur_ind and startindex lt end_index)
        endelse

        ; check if there was a start byte keyword found:
        if (startpos[0] gt 0) then begin
            start_byte = fix(clean(start_all[startpos[0]],/space),type=3)
        endif
    endif

    return, start_byte
end

;-- level 2 -------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: object1 and object2 are idl structures containing
;     fields of "array", "index", and "count", where the latter former two
;     are string and long arrays, respectively.
; postcondition: the object arrays and indices are sorted using
;     sequential sort, and returned as a signle idl structure with the
;     same fields.

function sort_objects, object1, object2
    ; initialize variables:
    array = [object1.array, object2.array]
    index = [object1.index, object2.index]
    count = object1.count + object2.count

    ; go through the indicies and perform sequential sort:
    for i = 0, count - 1 do begin
        min = i
        for j = i + 1, count - 1 do begin
            if (index[j] lt index[min]) then begin
                min = j
            endif
        endfor
        temp1 = index[i]
        temp2 = array[i]
        index[i] = index[min]
        array[i] = array[min]
        index[min] = temp1
        array[min] = temp2
    endfor

    ; create structure:
    objects = create_struct("array", array, "index", index, "count", count)

    return, objects
end

;-----------------------------------------------------------------------------
; precondition: objectname is a scalar string
; postcondition: the objectname is tested for being an element or not,
;     return 1 if it is, 0 otherwise.

function is_element, objectname
    ; find whether the object is an ELEMENT
    flag = 0
   ;; A. Cardesin, 2005-03-29; 
   ;; check wether the string "ELEMENT" is at the end of the objectname.
    pos = strpos(objectname, "ELEMENT")
    length = strlen(objectname)
    if (pos NE -1)&&(pos EQ length-7) then flag = 1
    
    return, flag
end

;-----------------------------------------------------------------------------
; precondition: objectname is a scalar string
; postcondition: the objectname is tested for being an array or not,
;     return 1 if it is, 0 otherwise.

function is_array, objectname
    ; find whether the object is an ARRAY
    flag = 0
   ;; A. Cardesin, 2005-03-29; correction for MEX/SPICAM/UV channel
   ;; check wether the string "ARRAY" is at the end of the objectname.
    pos = strpos(objectname, "ARRAY")
    length = strlen(objectname)
    if (pos NE -1)&&(pos EQ length-5) then flag = 1

    return, flag
end

;-----------------------------------------------------------------------------
; precondition: objectname is a scalar string
; postcondition: the objectname is tested for being a collection or
;     not, return 1 if it is, 0 otherwise. 

function is_collection, objectname
    ; find whether the object is a collection
    flag = 0
   ;; A. Cardesin, 2005-03-29;
   ;; check wether the string "COLLECTION" is at the end of the objectname.
    pos = strpos(objectname, "COLLECTION")
    length = strlen(objectname)
    if (pos NE -1)&&(pos EQ length-10) then flag = 1

    return, flag
end

;-- level 1 -------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: label is a viable PDS label; objindex is a viable
;     start index for current array/collection object
; postcondition: all subobjects associated with the current object are
;     extracted, sorted by index order, and returned as a structure 

function get_subobjects, label, objindex
    ; initialize variables:
    objstruct = {flag: 1}

    ; obtain the end object index for the current objindex:
    eobjindex = get_index(label, objindex)
    if (eobjindex eq -1) then goto, endfunction
    
    ; obtain all objects and element objects from label and combine them:
    objects = objpds(label, "ALL")
    if (objects.flag eq -1) then goto, endfunction
    elementobjects = objpds(label, "ELEMENT")
    if (elementobjects.flag eq -1) then begin
        print, "Error: no sub-objects found for current ARRAY or COLLECTION"
        goto, endfunction
    endif
    objects = sort_objects(objects, elementobjects)

    ; extract all objects from the label between objindex and eobjindex:
    pos = where(objects.index ge objindex and objects.index lt eobjindex, cnt)
    if (cnt eq 0) then begin
        print, "Error: no sub-objects found for current ARRAY or COLLECTION"
        goto, endfunction
    endif else begin
        objstruct = create_struct(objstruct, "array", objects.array[pos], $
            "index", objects.index[pos], "count", n_elements(pos))
    endelse

    return, objstruct

    endfunction:
        objstruct.flag = -1
        return, objstruct
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; objects contains all
;     viable objects/subobjects of current array/collection object to be
;     read
; postcondition: all the objects and subobjects are processed
;     recursively and the structures are populated and returned

function process_structs, label, objects
    ; initialize variables:
    struct = {flag: 1}
    count = 0            ; counter for object index
    flag = 1             ; flag to determine whether all objects have been
                         ; compiled into the structure

    ; go through each sub object and compile the object structure:
    while (flag) do begin
        if (is_element(objects.array[count])) then begin
            temp_struct = elem_struct(label,objects.index[count])
            count = count + 1
        endif else if (is_collection(objects.array[count])) then begin
            temp_struct = coll_struct (label,objects, count)
        endif else if (is_array(objects.array[count])) then begin
            temp_struct = arr_struct (label,objects, count)
        endif else begin
            print, "Error: invalid PDS object found in label for processing."
            goto, endfunction
        endelse

        ; check for structure flag:
        if (temp_struct.flag eq -1) then goto, endfunction

        struct = create_struct(struct, temp_struct.name, temp_struct.element)
        if (count eq objects.count) then begin
            flag = 0
        endif

    endwhile

    struct = create_struct(struct, "count", count)

    return, struct

    endfunction:
       struct.flag = -1
       return, struct
end

;-- level 0 -------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: label is a viable PDS label, and objindex is a viable
;     start index of the current array/collection object
; postcondition: the idl structure to be read from the label is
;     constructed and returned 

function arrcol_struct, label, objindex
    ; error protection:
    ;on_error, 1

    ; check for the number of arguments:
    if (n_params() lt 2) then begin
        print, "Syntax: structure = arrcol_struct(label, objindex)"
        return, -1
    endif

    ; get sub objects for the current objindex:
    objects = get_subobjects (label, objindex)
    if (objects.flag eq -1) then return, objects

    ; compile object structure:
    struct = process_structs (label, objects)    

    return, struct
end
