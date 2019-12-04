;------------------------------------------------------------------------------
; NAME: REMOVE
;
; PURPOSE: To remove all characters from the given string as specified by
;          the parameter array
;
; CALLING SEQUENCE: Result = REMOVE (text, param)
;
; INPUTS:
;    Text: String of characters to be cleaned
;    Param: A string array of characters to be removed from text
; OUTPUTS:
;    Result: String characters removed of all unwanted characters
;
; OPTIONAL INPUTS: none
;
; EXAMPLE:
;    To remove all unwanted characters as defined by param:
;       IDL> param = ['"',',',')','(']
;       IDL> result = REMOVE ("this, here (contained)",param)
;       IDL> print, result
;            this here contained
;
; PROCEDURES USED: none
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal, January 15, 2003
;     For a complete list of modifications, see changelog.txt file.
;
;------------------------------------------------------------------------------

function REMOVE, text, param
    ; initialize variables:
    length = strlen(text)

    if (length NE 0) then begin
        ; initialize variables:
        btext = byte(text)
        bparam = byte(param)
        clength = n_elements(bparam)-1

        ; process string and remove unwanted chars:
        for c = 0, clength do begin
            pos = where (btext NE bparam[c])
            if (pos[0] NE -1) then begin
                btext = btext[pos]
            endif else begin
                btext = 0B
            endelse
        endfor

        text = string(btext)
    endif
    return, text
end
