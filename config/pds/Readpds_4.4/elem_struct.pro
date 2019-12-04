;-----------------------------------------------------------------------------
; NAME: ELEM_STRUCT
;
; PURPOSE: To populate an IDL structure containing the type of element
;     object; intended to be used with ARRCOL_STRUCT.PRO
;
; CALLING SEQUENCE: Result = ELEM_STRUCT (label, index)
;
; INPUTS:
;     Label: String array containing the element object information
;     Index: The start index associated with label array for element object
; OUTPUTS:
;     Result: an IDL structure containing the type of element object
;         to be read
; 
; PROCEDURES USED: CLEAN, GET_INDEX, PDSPAR, REMOVE 
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 23, 2005]
;     
;     2010-01-12, smartinez: UNSIGNED integer format not correctly handled.        
;                            Function determine_element_type modified.
;
;-----------------------------------------------------------------------------

;--level 1--------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for current element object
; postcondition: the data type value for current element object is returned



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


function extract_data_type, label, cur_ind, end_index
    ; initialize variables:
    data_type = "-1"
    param = ['"',"'", ',' ,'(',')']

    ; obtain all data_type keyword values from the label:
    data_all = pdspar(label, "DATA_TYPE", count=datacount, index=dataindex)
    if (datacount gt 0) then begin
        datapos = where (dataindex gt cur_ind and dataindex lt end_index, cnt)
        if (cnt gt 0) then begin
            data_type = remove(clean(data_all[datapos[0]],/space),param)
        endif
    endif

    ; check if data_type has been assigned a value:
    if (data_type eq "-1") then begin
        print, "Error: missing required DATA_TYPE keyword from label"
    endif
    
    return, data_type
end

;-----------------------------------------------------------------------------
; precondition: data_type is a viable data type for current element
;     object, and bytes is a viable bytes value for current element
; postcondition: the element type of the current object is determined
;     and a vector variable initialized to 0 of that type is returned

function determine_element_type, data_type, bytes
    ; initialize variables:
    vector = 0
    type = ""

    ; separate data type:
    if (!version.release gt 5.2) then begin
        temp = strsplit(data_type, '_', /extract)
    endif else begin
        temp = str_sep(data_type, '_')    ; obsolete in IDL v. > 5.2
    endelse

    ; extract the element type:
    if (n_elements(temp) eq 3) then begin
        type = temp[1] + '_' + temp[2]
    endif else if (n_elements(temp) gt 1) then begin
        type = temp[1]
    endif else begin
        type = temp[0]
    endelse

    ; declare element array types:
    if ((type eq "INTEGER") or (type eq "UNSIGNED_INTEGER")) then begin
    
      case bytes of
        8: vector = (type eq "UNSIGNED_INTEGER") ? ulong64(0) : long64(0)
        4: vector = (type eq "UNSIGNED_INTEGER") ? ulong(0) : long(0) 
        2: vector = (type eq "UNSIGNED_INTEGER") ? uint(0) : fix(0)
      else: vector = byte(0)
      endcase
      
      if ((bytes ne 4) and (bytes ne 2) and (bytes ne 1)) then $
        print, "Warning: incorrect number of bytes for integer representation."
      
    endif else if ((type eq "REAL") or (type eq "FLOAT")) then begin
        if (bytes lt 8) then begin
            vector = float(0)
        endif else begin
            vector = double(0)
        endelse 
    endif else if ((type eq "BYTE") or (type eq "BOOLEAN")) then begin
        vector = byte(0)
    endif else if (type eq "DOUBLE") then begin
        vector = double(0)
    endif else begin
        vector = byte(0)
    endelse     

    return, vector
end

;-- level 0--------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: label is a viable PDS label; index is the start index
;     for current element object to be read
; postcondition: the element object is processed and the idl structure
;     is constructed for the element object and returned  

function elem_struct, label, index
    ; initialize variables:
    struct = {flag: 1, name:""}
    cur_ind = index

    ; obtain object's end index:
    end_index = get_index(label, cur_ind)
    if (end_index eq -1) then goto, endfunction

    ; obtain current element object's name:
    struct.name = extract_name(label, cur_ind, end_index)
    if (struct.name eq "-1") then goto, endfunction

    ; obtain bytes for current element object:
    bytes = extract_bytes(label, cur_ind, end_index)
    if (bytes eq -1) then goto, endfunction

    ; obtain start byte for current element object if any:
    start_byte = extract_start_byte (label, cur_ind, end_index)

    ; obtain data type for the current element object:
    data_type = extract_data_type (label, cur_ind, end_index)
    if (data_type eq "-1") then goto, endfunction

    ; determine and connstruct the data_type element vector:
    element = determine_element_type(data_type, bytes)

    struct = create_struct(struct, "element", element)

    return, struct
    endfunction:
        struct.flag = -1
        return, struct
end
