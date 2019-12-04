;------------------------------------------------------------------------------
; NAME: ADDEOBJ
; 
; PURPOSE: To insert END_OBJECT keyword values if not present, and pad the
;          lines to 80 bytes
;
; CALLING SEQUENCE: Result = ADDEOBJ (ln, objarr, objcount)
; 
; INPUTS:
;    Ln: Scalar string containing a line from label for PDS file.
;    Objarr: String array containing the values of OBJECT keyword in label.
;    Objcount: The total count of objects in the objarr to be processed.
;
; OUTPUTS:
;    Result: Updated PDS label string with END_OBJECT keyword value
;
; OPTIONAL INPUT: none.
;
; MODIFICATION HISTORY:
;    Written by: Puneet Khetarpal [June 28, 2004]
;
;    29 Jan 2009, S. Martinez: Add [CR,LF] instead of [LF,CR].
; 
;------------------------------------------------------------------------------

;-- level 1 -------------------------------------------------------------------

;------------------------------------------------------------------------------
; precondition: the ln variable must be of type string
; postcondition: the ln variable is searched for comments. If present, they
;     are removed from the string, and then the line is formatted to 80
;     bytes if not formatted.

function cleanline, ln
    ; first check for comments and remove them if present:
    poslc = strpos(ln, '/*')
    posrc = strpos(ln, '*/')
    if ((poslc[0] gt -1) && (posrc[0] gt -1)) then begin
        if (poslc[0] lt posrc[0]) then begin
            str1 = strmid(ln, 0, poslc[0] - 1)
            str2 = strmid(ln, posrc[0] + 2)
            ln = str1 + str2
        endif else begin
            print, "Error: Comments in label out of order."
            return, "-1"
        endelse
    endif

    ; now format line to 80 bytes if not formatted:
    length = strlen(ln)
    if (length lt 78) then begin
        pad = make_array(78 - length, /byte, value = 32B)
        ln += string(pad) + string([13B, 10B]) ;; [CR,LF]
    endif else begin
        ln += string([13B, 10B]) ;; [CR,LF]
    endelse

    return, ln
end

;-- level 0 ------------------------------------------------------------------

function addeobj, ln, objarr, objcount
    ; error protection:
    ;on_error, 2

    ; initialize structure to be returned:
    struct = create_struct("flag", 1)

    ; check for number of arguments in function call, must equal 3:
    if (n_params() lt 3) then begin
        print, "Error: Syntax - result = addeobj (ln, objarr, objcount)"
        goto, endfun
    endif

    ; clean the line:
    ln = cleanline(ln)                        ; subroutine
    if (ln eq "-1") then goto, endfun 

    ; determine the position of OBJECT or END_OBJECT keyword in ln string:
    tempstr = ln
    tempstr = clean(tempstr, /space)          ; external routine
    objpos = strpos(tempstr, "OBJECT=")
    end_objpos = strpos(tempstr, "END_OBJECT")

    ; check for OBJECT keyword:
    if ((objpos gt -1) && (end_objpos eq -1)) then begin
        ; if present then extract OBJECT value by separating the string
        ; into two via the "=" separator (str_sep routine obsolete > 5.2):
        arr = (!version.release gt 5.2) ? strsplit(ln, "=", /extract) : $
                                          str_sep(ln, "=")
        name = clean(arr[1], /space)          ; external routine

        ; if there are currently no objects in the objarr, then assign 
        ; objarr to the extracted name of the OBJECT, else concatenate
        ; the value to objarr, and increment objcount by 1:
        objarr = (objcount eq 0) ? name : [objarr, name]
        objcount += 1
    endif else if (end_objpos gt -1) then begin
        ; if END_OBJECT keyword found in the string, then first check
        ; whether there are any viable objarr elements left to be processed
        ; for the found END_OBJECT keyword:
        if (objcount eq 0) then begin
            print, "Error: Inconsistent number of OBJECT and END_OBJECT " + $
                   "keywords found."
            goto, endfun
        endif

        ; determine whether the string already has an "=" character:
        pos = strpos(ln, "=")
        if (pos eq -1) then begin
            ; if not, then position to write onto string is right after
            ; the word "END_OBJECT":
            pos = strpos(ln, "END_OBJECT")
            pos += strlen("END_OBJECT") + 1
            src = "= " + objarr[objcount - 1]
        endif else begin
            ; first check to ensure that the END_OBJECT param matches
            ; OBJECT param, obtain object parameter, and end object param:
            src = objarr[objcount - 1]
            eobjparam = clean(strmid(ln, pos + 1), /space)

            ; if object param not equals end object param, then error:
            if (eobjparam ne src) then begin
                print, "Error: OBJECT (" + src + ") and END_OBJECT (" + $
                       eobjparam + ") value mismatch."
                goto, endfun
            endif

            ; else extract string upto the already included "=" sign:
            pos += 2
            ln = strmid (ln, 0, pos - 1)

            ; clean line:
            ln = cleanline(ln)
            if (ln eq "-1") then goto, endfun
        endelse

        ; insert the OBJECT value into END_OBJECT value keyword, and
        ; decrement objcount, and reconstruct objarr:
        strput, ln, src, pos
        objcount = objcount - 1
        if (objcount eq 0) then begin
            objarr = "-1"
        endif else begin
            temp = objarr[0:objcount-1]
            objarr = temp
        endelse
    endif

    ; add to the struct the ln, objarr, and objcount vars:
    struct = create_struct(struct, "ln", ln, "array", objarr, "count",objcount)
    return, struct

    endfun:
        ; if error, then set struct.flag to -1 and return struct:
        struct.flag = -1
        return, struct
end
