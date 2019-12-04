;-----------------------------------------------------------------------------
; NAME: GET_INDEX
;
; PURPOSE: To obtain the END_OBJECT index position for a specified PDS object
;          in a PDS label.
;
; CALLING SEQUENCE: Result = GET_INDEX (label, start index)
;
; INPUTS:
;    label: String array containing the object information according to
;           PDS standards. The label must meet all PDS standards.
;    start index: Integer specifying the index of the OBJECT for which
;                 the END_OBJECT index is desired. Start index must be
;                 a valid object index in the label string array.
;
; OUTPUTS:
;    Result: A scalar integer specifying the END_OBJECT index in the label
;            string array for which the start index was specified.
;
; OPTIONAL INPUT: none
;
; EXAMPLES:
;    To obtain the index of the table array starting at label index 7:
;    IDL> label = HEADPDS ("TABLE.LBL", /SILENT)
;    IDL> index = GET_INDEX (label, 7)
;    IDL> help, index
;    INDEX          LONG      =           60
;
; PROCEDURES USED:
;    CLEAN, OBJPDS, PDSPAR
;
; MODIFICATION HISTORY:
;    Written by: Puneet Khetarpal [February 24, 2004]
;    For a complete list of modifications, see changelog.txt file.
;
;-----------------------------------------------------------------------------

;-- level 0 ------------------------------------------------------------------

function get_index, label, startindex
    ; error protection:
    ;on_error, 2
   
    ; check number of arguments:
    if (n_params() lt 2) then begin
        print, "Syntax: result = get_index (label, startindex)"
        return, -1
    endif

    ; check for a valid starting index position:
    position = strpos(label[startindex], "OBJECT")
    position2 = strpos(label[startindex], "END_OBJECT")
    if ((position[0] eq -1) || (position2[0] gt 0)) then begin
        print, "Error: Invalid start index position specified."
        return, -1
    endif

    ; get all object and end_object keywords from label and make struct:
    objects = pdspar(label, "OBJECT", count=objcount, index=objindex)
    end_objects = pdspar(label, "END_OBJECT", count=eobjcount, index=eobjindex)
    ; sort objects index and end_objects index into one array:
    indices = [objindex, eobjindex]
    indices = indices[sort(indices)]

    ; go through the indices and obtain the appropriate end index value:
    count = 0
    flag = 1
    objarr = ""
    objind = -1
    objcount = 0
    end_index = -1

    while ((count lt n_elements(indices)) && flag) do begin
        objpos = where (indices[count] eq objindex)
        eobjpos = where (indices[count] eq eobjindex)

        if ((objpos[0] gt -1) && (eobjpos[0] eq -1)) then begin
            ; if the current index belongs to an OBJECT:
            if (objcount eq 0) then begin
                objarr = objects[objpos[0]]
                objind = objindex[objpos[0]]
            endif else begin
                objarr = [objarr, objects[objpos[0]]]
                objind = [objind, objindex[objpos[0]]]
            endelse
            objcount += 1
        endif else if ((objpos[0] eq -1) && (eobjpos[0] gt -1)) then begin
            ; if the current index belongs to an END_OBJECT:
            if (objcount eq 0) then begin
                print, "Error: Inconsistent number of OBJECT and END_OBJECT "+$
                       "keywords found."
                return, -1
            endif
            
            ; check if the current end_object value matches the last object
            ; value:
            if (end_objects[eobjpos[0]] ne objarr[objcount - 1]) then begin
                print, "Error: OBJECT (" + objarr[objcount - 1] + ") and " + $
                   "END_OBJECT (" + end_objects[eobjpos[0]] + ") value " + $
                   "mismatch."
                return, -1
            endif

            ; else check whether the index value of the object is the start
            ; index we were looking for:
            if (objind[objcount - 1] eq startindex) then begin
                end_index = indices[count]
                flag = 0
            endif else begin
                objcount -= 1
                if (objcount eq 0) then begin
                    objarr = ""
                    objind = -1
                endif else begin
                    objarr = objarr[0:objcount - 1]
                    objind = objind[0:objcount - 1]
                endelse
            endelse
        endif

        ; increment loop count:
        count += 1
    endwhile

    if (end_index eq -1) then begin
        print, "Error: no END_OBJECT keyword found for OBJECT at index "+$
               clean(string(startindex),/space)
    endif

    return, end_index
end
