FUNCTION str_clean, text, SPACE = space
;+
; NAME: 
;	STR_CLEAN
;     
; PURPOSE: 
;	To remove all unprintable characters from the given string
; 
; CALLING SEQUENCE: 
;	Result = STR_CLEAN (text, [/SPACE])
; 
; INPUTS:
;	Text: Scalar string of characters to be cleaned
;
; OUTPUTS:
;	Result: Scalar string of characters removed of all unprintable characters
;
; OPTIONAL INPUTS:
;	SPACE: removes all unprintable characters including all space chars.
;
; EXAMPLE:
;	To remove all unprintable chars except space
;	IDL> word = STR_CLEAN ('the [tab]file is [lf][cr]')
;	IDL> print, word
;	the file is
;
;	To remove all unprintable chars including space
;	IDL> word = STR_CLEAN ('the [tab]file is [lf][cr]',/SPACE)
;	IDL> print, word
;	thefileis
;
; PACKAGE LOCATION:
;	http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
; MODIFICATION HISTORY:
;	Written by Puneet Khetarpal, January 15, 2003
;
;------------------------------------------------------------------------------


    ; error protection:
    on_error, 2

    ; check for SPACE keyword specification:
    space = keyword_set(space)

    ; process the text only if string is not NULL:
    status = size(text, /type)
    if (status ne 7) then text = string(text)
    if (strlen(text) ne 0) then begin
        btext = byte(text)

        ; find the wanted chars ommitting or including the space char:
        pos = (space) ? where (btext gt 32B and btext lt 127B) : $
                        where (btext ge 32B and btext lt 127B)

        ; assign processed value of text:
        text = (pos[0] ne -1) ? string(btext[pos]) : ""
    endif
    return, text   
end
