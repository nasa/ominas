;------------------------------------------------------------------------------
; NAME: COLL_STRUCT
;
; PURPOSE: To populate an IDL structure for a COLLECTION object to be
;     read; Intended to be used with ARRCOLL_STRUCT.PRO
;
; CALLING SEQUENCE: Result = COLL_STRUCT (label, objects, count)
;
; INPUTS:
;     Label: String array containing the COLLECTION object information
;     Objects: IDL structure containing the COLLECTION and its
;         subobjects definitions
;     Count: Integer tracking the number of objects being processed
; OUTPUTS:
;     Result: an IDL structure containing the COLLECTION elements to
;         be read
; 
; PROCEDURES USED: ARR_STRUCT, CLEAN, ELEM_STRUCT
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 23, 2005]
;
;-----------------------------------------------------------------------------

;- level 0 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS object; objects is an idl
;     structure containing collection and its subobject definitions
;     with fields of "array", "index", and "count"; count is an
;     integer that tracks the total number of objects being processed
; postcondition: the collection object structure is populated and returned 

function coll_struct, label, objects, count
    ; initialize variables:
    struct = {flag: 1, name:""}
    cur_ind = objects.index[count]
    newstructflag = 1

    ; obtain object's end index:
    end_index = get_index(label, cur_ind)
    if (end_index eq -1) then goto, endfunction

    ; obtain current collection object's name:
    struct.name = extract_name(label, cur_ind, end_index)
    if (struct.name eq "-1") then goto, endfunction

    ; increment count:
    count = count + 1

    ; check for any sub-objects:
    subpos = where (objects.index gt cur_ind and objects.index lt end_index)
    if (subpos[0] eq -1) then begin
        print, "Error: no sub objects found for COLLECTION at index "+ $
               clean(string(cur_ind), /space)
        goto, endfunction
    endif

    ; set the current subobjects into a temporary array:
    temp_arr = objects.array[subpos]
    temp_ind = objects.index[subpos]
    temp_cnt = n_elements(subpos)

    ; go through each sub object and process them as required:
    loopcnt = 0
    while (loopcnt lt temp_cnt) do begin
        temp = count
        if (is_element(temp_arr[loopcnt])) then begin
            temp_struct = elem_struct(label, temp_ind[loopcnt])
            loopcnt = loopcnt + 1
            count = count + 1
        endif else if (is_array(temp_arr[loopcnt])) then begin
            temp_struct = arr_struct (label, objects, count)
            loopcnt = loopcnt + (count - temp)
        endif else if (is_collection(temp_arr[loopcnt])) then begin
            temp_struct = coll_struct (label, objects, count)
            loopcnt = loopcnt + (count - temp)
        endif

        ; check for error flags in structure:
        if (temp_struct.flag eq -1) then goto, endfunction

        ; add temp structs into data struct:
        if (newstructflag eq 1) then begin
            data_struct = create_struct(temp_struct.name, temp_struct.element)
            newstructflag = -1
        endif else begin
            data_struct = create_struct(data_struct, temp_struct.name, $
                                        temp_struct.element)
        endelse
    endwhile

    struct = create_struct(struct, "element", data_struct)

    return, struct
    endfunction:
        struct.flag = -1
        return, struct
end
