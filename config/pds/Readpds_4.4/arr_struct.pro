;-----------------------------------------------------------------------------
; NAME: ARR_STRUCT
;
; PURPOSE: To populate an IDL structure containing the ARRAY object
;     definitions; Intended to be used with ARRCOL_STRUCT.PRO 
; 
; CALLING SEQUENCE: Result = ARR_STRUCT (label, objects, count)
;
; INPUTS:
;     Label: String array containing the ARRAY object information
;     Objects: IDL structure containing the ARRAY and its subobjects
;         definitions 
;     Count: Integer tracking the number of objects being processed
; OUTPUTS:
;     Result: an IDL structure containing the ARRAY element to be read
;
; PROCEDURES USED: CLEAN, COLL_STRUCT, ELEM_STRUCT, GET_INDEX
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 23, 2005]
;
;----------------------------------------------------------------------------- 

;- level 1 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for current array object
; postcondition: the number of axes for current array object is returned 

function get_arr_axes, label, cur_ind, end_index
    ; obtain all axes values in the label:
    axes_all = pdspar(label, "AXES", COUNT=axescount,INDEX=axesindex)
    ; if no axes found in the label then issue error:
    if (axescount eq 0) then begin
        print, "Error: missing required AXES keyword in label"
        goto, endfunction
    endif else begin
        axespos = where (axesindex gt cur_ind and axesindex lt end_index)
        if (axespos[0] eq -1) then begin
            print, "Error: missing required AXES keyword in ARRAY object"
            goto, endfunction
        endif else begin
            axes = fix(clean(axes_all[axespos[0]],/space))
        endelse
    endelse

    ; check for viable axes value:
    if ((axes lt 1) or (axes gt 6)) then begin
        print, "Error: invalid AXES value specified (min: 1, max: 6): " + $
            clean(string(axes), /space)
        goto, endfunction
    endif

    return, axes
    endfunction:
        return, -1
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; cur_ind and end_index are
;     viable start and end indices for current array object; axes
;     is an integer value of the number of axes the array has
; postcondition: the array axis items value is extracted from the
;     label and returned  

function get_arr_axis_items, label, cur_ind, end_index, axes
    ; obtain all axis items values from the label:
    axis_all = pdspar (label, 'AXIS_ITEMS', COUNT=axiscount,INDEX=axisindex)
    ; if no axis items found in the label then issue error:
    if (axiscount eq 0) then begin
        print, "Error: missing required AXIS_ITEMS keyword from label"
        goto, endfunction
    endif else begin
        axis_pos = where (axisindex gt cur_ind and axisindex lt end_index)
        if (axis_pos[0] eq -1) then begin
            print, "Error: missing required AXIS_ITEMS keyword in ARRAY object"
            goto, endfunction
        endif else begin
            axis_items = axis_all[axis_pos[0]]
        endelse
    endelse

    ; if array is greater than 1-D then separate the axis items in string:
    if (axes gt 1) then begin
        axis_items = remove(axis_items, ['(',')','{','}'])
        if (!version.release gt 5.2) then begin
            temp = strsplit(axis_items, ',', /extract)
        endif else begin
            temp = str_sep (axis_items, ',') 
        endelse
        axis_items = fix(cleanarr (temp, /space), type=3)
    endif else begin
        axis_items = fix(clean (axis_items,/space), type=3)
    endelse

    ; check for viable axis item values:
    pos = where(axis_items lt 1, cnt)
    if (cnt gt 0) then begin
        print, "Error: invalid AXIS_ITEMS value specified: " + $
            clean(string(axis_items[pos[0]]), /space)
        goto, endfunction
    endif

    return, axis_items
    endfunction:
        return, -1
end

;- level 0 --------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: label is a viable PDS string array; objects contains
;     all viable subojbects of current array object; count tracks the
;     number of objects being processed
; postcondition: an IDL structure for the array object and its
;     subobjects are populated and returned

function arr_struct, label, objects, count
    ; initialize variables:
    struct = {flag: 1, name:""}
    cur_ind = objects.index[count]
    newstructflag = 1

    ; obtain object's end index:
    end_index = get_index(label, cur_ind)
    if (end_index eq -1) then goto, endfunction

    ; obtain current array object's name
    struct.name = extract_name(label, cur_ind, end_index)
    if (struct.name eq "-1") then goto, endfunction

    ; increment count:
    count = count + 1

    ; check for any sub-objects:
    subpos = where (objects.index gt cur_ind and objects.index lt end_index)
    if (subpos[0] eq -1) then begin
        print, "Error: no sub objects found for ARRAY at index " + $
            clean(string(cur_ind), /space)
        goto, endfunction
    endif
    
    ; obtain the number of axes:
    axes = get_arr_axes (label, cur_ind, end_index)
    if (axes eq -1) then goto, endfunction

    ; obtain the axis_items:
    axis_items = get_arr_axis_items (label, cur_ind, end_index, axes)
    if (axis_items[0] eq -1) then goto, endfunction

    ; obtain start byte value:
    start_byte = extract_start_byte (label, cur_ind, end_index)

    ; set the current sub objects into a temporary array:
    temp_arr = objects.array[subpos]
    temp_ind = objects.index[subpos]
    temp_cnt = n_elements(temp_arr)

    ; process the array for one subobject and multiple subobjects:
    if (temp_cnt eq 1) then begin
        ; check if there is an element object:
        if (is_element(temp_arr[0])) then begin
            temp_struct = elem_struct(label, temp_ind[0])
            count = count + 1 
        endif

        ; test valid structure:
        if (temp_struct.flag eq -1) then goto, endfunction

        ; get the data type of element:
        stat = size(temp_struct.element)

        ; make array of the axis items and dimensions:
        array = make_array(dimension=axis_items, type=stat[1], /nozero)
        struct = create_struct(struct, "element", array)
    endif else begin
        ; go through each sub object and process them as required:
        loopcnt = 0
        while (loopcnt lt temp_cnt) do begin
            temp = count
            if (is_element(temp_arr[loopcnt])) then begin
                temp_struct = elem_struct (label, temp_ind[loopcnt])
                loopcnt = loopcnt + 1
                count = count + 1
            endif else if (is_array(temp_arr[loopcnt])) then begin
                temp_struct = arr_struct (label, objects, count)
                loopcnt = loopcnt + (count - temp)
            endif else if (is_collection(temp_arr[loopcnt])) then begin
                temp_struct = coll_struct(label, objects, count)
                loopcnt = loopcnt + (count - temp)
            endif else begin
                print, "Error: invalid PDS object found in ARRAY object: " + $
                   temp_arr[loopcnt]
                goto, endfunction
            endelse

            ; test valid structure:
            if (temp_struct.flag eq -1) then goto, endfunction

            ; add temp structs into data struct:
            if (newstructflag eq 1) then begin
                data_struct = create_struct(temp_struct.name, $ 
                    temp_struct.element)
                newstructflag = -1
            endif else begin
                data_struct = create_struct(data_struct, temp_struct.name, $
                    temp_struct.element)
            endelse
        endwhile

        ; replicate data structure into axes and axis_items:
        replicatedstructure = replicate(data_struct, axis_items)
        struct = create_struct(struct, "element", replicatedstructure)
    endelse

    return, struct
    endfunction:
        struct.flag = -1
        return, struct
end
