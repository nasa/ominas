;------------------------------------------------------------------------------
; NAME: HEADPDS
;
; PURPOSE: To read a PDS label into an array variable
;
; CALLING SEQUENCE: Result = HEADPDS (filename [,/SILENT,/FILE,/FORMAT])
;
; INPUTS:
;    Filename: Scalar string containing the name of the PDS file to read
; OUTPUTS:
;    Result: PDS label array constructed from designated record
;
; OPTIONAL INPUT:
;    SILENT: suppresses any messages from the procedure
;    FILE: to be indicated if the file does not contain the label
;          [for purposes other than reading a label]
;    FORMAT: to be indicated if the file is ^STRUCTURE file
;
; EXAMPLES:
;    To read a PDS file TEST.PDS into a PDS header array, lbl:
;       IDL> lbl = HEADPDS("TEST.PDS",/SILENT)
;    To read a PDS file that may not contain a header:
;       IDL> lbl = HEADPDS("TEST2.TXT",/FILE)
;    To read a PDS format file FORMAT.FMT from the ^STRUCTURE:
;       IDL> fmt = HEADPDS("FORMAT.FMT", /FORMAT)
;
; PROCEDURES USED:
;    Functions: POINTPDS, PDSPAR, CLEAN, ADDEOBJ
;
; MODIFICATION HISTORY:
;    Written by: Puneet Khetarpal [January 24, 2003]
;
;    29 Jan 2009, S. Martinez: Add [CR,LF] instead of [LF,CR].
;    01 Feb 2009, S. Martinez: Corrected to do not crash when file does not exist.
;    
;    For detailed log of modifications to this routine, please see the
;    changelog.txt file.
;------------------------------------------------------------------------------

function get_struct_name, label, objindex
    ; initialize variables:
    objectname = "-1"

    ; obtain the line of objindex and split into two using '=':
    line = label[objindex]
    segs = strsplit(line, '=', /extract)

    ; clean the second element of separated line
    objectname = clean(segs[0],/space)

    return, strmid(objectname,1)
end

function headpds, input_filename, SILENT = silent, FILE = file, FORMAT = format
; Modified: A.Cardesin 19 May 2005
; input_filename was changed during procedure 
    filename=input_filename

    ; error protection:
    ;on_error, 2
    on_ioerror, signal

    ; check for number of parameters in function call, must be >= 1:
    if (n_params() lt 1) then begin
        print, "Error: Syntax - result = HEADPDS ( filename " + $
               "[,/SILENT,/FILE,/FORMAT] )"
        return, "-1"
    endif

    ; check for input of optional keywords:
    silent = keyword_set(silent)
    file = keyword_set(file)
    format = keyword_set(format)

    ; check whether the file exists and can be opened:
    openr, unit, filename, error = err, /get_lun
    if (err lt 0) then begin
        print, "Error: file " + filename + " could not be opened - "
        print, "  File either corrupted or invalid file name."
        ;;A.Cardesin Modified 8 Jun 2005
        ;;close and free logical unit before return
        CATCH,error_status
        IF (error_status NE 0) THEN BEGIN
          CATCH,/CANCEL
          return,"-1"
        ENDIF
        
        close,unit & free_lun, unit
        return, "-1"
    endif

    ; check for correct PDS label file:
    if (~file && ~format) then begin
        temp = bytarr(160)
        readu, unit, temp
        if ((strpos(string(temp), "PDS_VERSION_ID") lt 0) && $
            (strpos(string(temp), "SFDU_LABEL") lt 0) && $
            (strpos(string(temp), "XV_COMPATIBILITY") lt 0)) then begin
            print, "Error: label must contain viable PDS_VERSION_ID keyword"
            ;;A.Cardesin Modified 8 Jun 2005
            ;;close and free logical unit before return
            close,unit & free_lun, unit
            return, "-1"
        endif
    endif
   
    ; initialize label variables:
    lbl = ""                ; holds the label string array
    flag = 0                ; set to -1 when END keyword is encountered
    objarr = "-1"           ; holds the name of the OBJECTs in stack
    objcount = 0            ; the number of objects to be processed
    linecountflag = 0       ; the current number of lines, acts as a flag
                            ;    for storing values into lbl variable

    ; inform user of status:
    if (~silent) then begin
        print, "Now reading header: ", filename
    endif

    ; set up file unit pointer:
    point_lun, unit, 0

    ; start reading the file and read until one had reached the "END"
    ; keyword in the file and until it is not the end of the file:
    while (~flag && ~(eof(unit))) do begin
        ; read one line from file:
        ; Note- readf removes all \r\n characters from end of ln during read:
        ln = ""
        readf, unit, ln

        ; if not reading a "FILE" type then look for OBJECT and END_OBJECT
        ; keywords and set values appropriately, also pad the lines to 80 
        ; bytes:
        if (~file) then begin
            struct = addeobj(ln, objarr, objcount)   ; external routine
            if (struct.flag eq -1) then begin
                ;;A.Cardesin Modified 8 Jun 2005
                ;;close and free logical unit before return
                close,unit & free_lun, unit
               return, "-1"
            endif
            ln = struct.ln
            objarr = struct.array
            objcount = struct.count
        endif else begin
            ln += string([13B, 10B])
        endelse

        ; if lbl array has not been constructed, then assign lbl to ln
        ; else concatenate ln to lbl array and increment linecount:
        if (~linecountflag) then begin
            lbl = ln
            linecountflag += 1
        endif else begin
            lbl = [lbl, ln]
        endelse

        ; now check for "END" keyword in ln:
        ln2 = ln
        ln2 = clean(ln2, /space)                      ; external routine
        if (ln2 eq "END") then flag = 1
    endwhile

    ; close the file unit and free the unit number:
    close, unit
    free_lun, unit

;    ; process ^STRUCTURE object in label if any:
;    struct = pdspar(lbl, "^STRUCTURE", COUNT=strcount, INDEX=strindex)
;    if (strcount ne 0) then begin
;        endobj = pdspar(lbl, "END_OBJECT", COUNT=eobjcount, INDEX=eobjindex)
;      
;        ; obtain the position where the contents of STRUCTURE file are
;        ; to go in the lbl array, viz., before the last END_OBJECT keyword:
;        structpos = where (eobjindex gt strindex[0])
;        lblpos = eobjindex[structpos[0]]
;        lastelem = n_elements(lbl) - 1
;
;        ; obtain the pointer attributes for STRUCTURE, and read the file:
;        pointer = pointpds (lbl, filename, "STRUCTURE")   ; external routine
;        if (pointer.flag eq -1) then begin
;            print, "Error: structure pointer file missing"
;            return, "-1"
;        endif
;
;        datafile = pointer.datafile
;        fmtlabel = headpds (datafile, /format)
;
;        ; insert fmtlabel into lbl array:
;        lbl = [lbl[0:lblpos - 1], fmtlabel, lbl[lblpos:lastelem]]
;    endif

     ; process ^STRUCTURE object in label if any:
     struct = pdspar(lbl, "^STRUCTURE", COUNT=strcount, INDEX=strindex)  ;; ^STRUCTURE
     for i=0,strcount-1 do begin ;;santa
        endobj = pdspar(lbl, "END_OBJECT", COUNT=eobjcount, INDEX=eobjindex)
      
        ; obtain the position where the contents of STRUCTURE file are
        ; to go in the lbl array, viz., before the last END_OBJECT keyword:
        structpos = where (eobjindex gt strindex[i]) 
        lblpos = eobjindex[structpos[0]]
        lastelem = n_elements(lbl) - 1

        ; obtain the pointer attributes for STRUCTURE, and read the file:
        objname = get_struct_name(lbl, strindex[i])

        pointer = pointpds(lbl[strindex[i]-1:lastelem], filename, objname)   ; external routine
        if (pointer.flag eq -1) then begin
            print, "Error: structure pointer file missing"
            return, "-1"
        endif

        datafile = pointer.datafile
        fmtlabel = headpds (datafile, /format)

        ; insert fmtlabel into lbl array:
        
        lblpos = strindex[i] + 1
        lbl = [lbl[0:lblpos - 1], fmtlabel, lbl[lblpos:lastelem]]
        ;strcount--  ;; 2008 May 20, smartinez: removed
        struct = pdspar(lbl, "STRUCTURE", COUNT=strcount, INDEX=strindex)
    endfor

    return, lbl

    ; error processing:
    signal: 
        on_ioerror, null
        print, 'Error: unable to read file ' + filename
        ;;A.Cardesin Modified 8 Jun 2005
        ;;close and free logical unit before return
        close,unit & free_lun, unit
        return, -1
end
