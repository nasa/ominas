;-----------------------------------------------------------------------------
; NAME: APPLY_BITMASK
;
; PURPOSE: To apply bitmask on a SIGNED or UNSIGNED INTEGER array or
;     scalar as defined in the associated PDS label
;
; CALLING SEQUENCE: Result = APPLY_BITMASK (label, start_ind, end_ind, element)
;
; INPUTS:
;     Label: String array containing the current element object definitions
;     Start_ind: integer indicating the start of the element object in
;         label array
;     End_ind: integer indicating the end of the element object in the
;         label array
;     Element: the signed/unsigned integer array/scalar to apply the bitmask
; OUTPUTS:
;     Result: the signed/unsigned integer array/scalar after the
;         bitmask is applied (if any)
;
; PROCEDURES USED: CLEAN, PDSPAR
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 25, 2005]
;     Modified by A.Cardesin 28Feb2006: check if NULL or N/A
;
;-----------------------------------------------------------------------------

;- level 1 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: line is a scalar string containing the bitmask keywor
;     and its value as extracted from the PDS label; idl_type is the idl
;     type code for the element to be bitmasked
; postcondition: the bitmask value is extracted and converted into
;     appropriate type for the element and returned

function extract_bitmask, line, idl_type
    ; initialize variable:
    bitmask = 0

    ; extract the value from the line:
    if (!version.release gt 5.2) then begin
        temp = strsplit(line, "#", /extract)
    endif else begin
        temp = str_sep(line, "#")    ; obsolete in idl v. > 5.2
    endelse
    value = byte(clean(temp[1], /space)) - 48 ; convert to integer 0 or 1
    reversed = reverse(value)

    ; determine the added value of the bit elements in decimal:
    for i = 0, n_elements(reversed) - 1 do begin
        bitmask += reversed[i] * 2^i
    endfor

    ; convert bitmask to appropriate type:
    bitmask = fix(bitmask, type = idl_type)

    return, bitmask
end

;- level 0 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label; start_ind and end_ind are
;     viable start and end indices for the current element object;
;     element is an unsigned or signed integer array or scalar
; postcondition: the bitmask for the current element object is
;     extracted from the label and the bitmask is applied to the element
;     and returned.

function apply_bitmask, label, start_ind, end_ind, element
    ; initialize variables:
    newvalue = element

    ; check whether element is integer:
    typerange = [1, 2, 3, 4, 12, 13, 14, 15]
    stat = size(element, /type)
    pos = where (stat eq typerange, cnt)
    if (cnt eq 0) then return, newvalue

    ; extract all bitmask keywords from the label:
    allbitmask = pdspar(label, "BIT_MASK", count=allcount, index=allindex)
    allsamplebm = pdspar(label, "SAMPLE_BIT_MASK", count=cnt2, index=ind2)
    allbitmask = [allbitmask, allsamplebm]
    allcount += cnt2
    allindex = [allindex, ind2]

    ;; check if there are any bit mask values within start and end index:
    if (allcount gt 0) then begin
        pos = where (allindex gt start_ind and allindex lt end_ind, cnt)

;Modified A.Cardesin 28Feb2006
;Check if the value is N/A or NULL
    null= STRPOS(label[allindex[pos[0]]],'NULL') GE 0
    napp= STRPOS(label[allindex[pos[0]]],'N/A') GE 0

        if (cnt gt 0)&&(~null)&&(~napp) then begin
            bitmask = extract_bitmask(label[allindex[pos[0]]], stat)

            ; determine where element is negative:
            negpos = where (element lt 0, negcnt)

            ; apply bitmask:
            newvalue = abs(element) and bitmask

            ; apply negative where element was negative if any:
            if (negcnt gt 0) then begin
                newvalue[pos] *= -1
            endif
        endif
    endif

    return, newvalue
end
