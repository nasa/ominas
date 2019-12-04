;-----------------------------------------------------------------------------
; NAME: ARRCOLPDS
;
; PURPOSE: To read an ARRAY or COLLECTION object into an idl structure
; 
; CALLING SEQUENCE: Result = ARRCOLPDS (filename, label [,/SILENT])
; 
; INPUTS:
;     Filename: Scalar string containing the name of the PDS file to read
;     Label: String array containing the ARRAY/COLLECTION header definition
; OUTPUTS:
;     Result: idl structure constructed from designated record
; 
; OPTIONAL INPUTS:
;     SILENT: suppresses any messages from the procedure
;
; EXAMPLES:
;     To read a Keck 6D fits file with a PDS label file. The array
;     object in the label starts at index 53:
;     IDL> label = headpds('focus0037.lbl')
;     IDL> result = arrcolpds('focus0037.lbl', label, 53)
;
;     The output is:
;     IDL> help, result
;        RESULT          LONG      Array[128, 128, 2, 1, 2]
;
; PROCEDURES USED:
;     Functions: ARRCOL_STRUCT, CLEAN, GET_INDEX, PDSPAR, POINTPDS 
;
; MODIFICATION HISTORY:
;     Written by Puneet Khetarpal [January 23, 2005]
;
;-----------------------------------------------------------------------------

;-- level 1 ------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: label is a viable pds label, and objindex is a viable
;     starting index for the current array/collection object;
;     label@objindex contains the current object's name
; postcondition: the name of the object is extracted from the label

function extract_object_name, label, objindex
    ; initialize variables:
    objectname = "-1"

    ; obtain the line of objindex and split into two using '=':
    line = label[objindex]
    if (!version.release gt 5.2) then begin
        segs = strsplit(line, '=', /extract)
    endif else begin
        segs = str_sep(line, '=')    ; obsolete in IDL v. > 5.2
    endelse

    ; clean the second element of separated line
    objectname = clean(segs[1],/space)

    return, objectname
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label, and objindex and
;     end_objindex are viable indices for current pds object
; postcondition: the interchange format of the current object is
;     determined; if is binary, then returns 1, else returns 0

function is_binary, label, objindex, end_objindex
    ; intialize variable:
    flag = 0
    keyword = ""
    aflag = 0

    ; first obtain all interchange format keywords from the label:
    interformat_all = pdspar(label, "INTERCHANGE_FORMAT", count=intcount, $
                             index=intindex)

    ; check for the presence of interchange format keyword:
    if (intcount gt 0) then begin
        ; extract all the keywords for the specified objindex:
        pos = where (intindex gt objindex and intindex lt end_objindex, srcnt)
        ; check for the presence of keyword within the current object block:
        if (srcnt gt 0) then begin
            ; store the value of keyword and check for binary or ascii:
            keyword = interformat_all[pos[0]]
            if (strpos(keyword, "BINARY") ne -1) then begin
                flag = 1
            endif else begin
                print, "Error: this is an ASCII PDS file, currently not " + $
                       "supported by PDSRead."
                aflag = 1
            endelse
        endif
    endif 

    ; if no interchange format keyword found at all the issue error:
    if ((flag eq 0) and (aflag eq 0)) then begin 
        print, "Error: missing required INTERCHANGE_FORMAT keyword in label"
    endif

    return, flag
end

;-----------------------------------------------------------------------------
; precondition: label is a viable PDS label, and objindex and
;     end_objindex are viable start and end indices for current pds
;     object
; postcondition: the architecture of the current data file is obtained 

function obtain_arrcol_architecture, label, objindex, end_objindex
    ; initialize architecture:
    arch = "MSB"

    ; obtain the first data type object for an ELEMENT subobject:
    data_all = pdspar(label, "DATA_TYPE", count=data_count, index=data_index)
    pos = where(data_index gt objindex and data_index lt end_objindex, cnt)
    data_type = data_all[pos[0]]

    if ((strpos(data_type, "LSB") gt -1) || (strpos(data_type,"PC") gt -1) || $
        (strpos(data_type, "VAX") gt -1)) then begin
        arch = "LSB"
    endif

    return, arch
end

;-- level 0 ------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: filename and label are viable file and label, objindex
;     is a viable starting index for an ARRAY or COLLECTION PDS
;     object.
; postcondition: processes the current array or collection object
;     specified by objindex from the associated data file and returns. 

function arrcolpds, filename, label, objindex, SILENT=silent
    ; error protection:
    ;on_error, 1

    ; check for the number of arguments:
    if (n_params() lt 3) then begin
        print, "Syntax: result = arrcolpds(file, label, objectindex, /SILENT)"
        goto, endfunction
    endif
    st = keyword_set(SILENT)

    ; obtain end object index:
    end_objindex = get_index(label, objindex)
    if (end_objindex eq -1) then begin
        goto, endfunction
    endif

    ; obtain object name at objindex:
    objname = extract_object_name(label, objindex)

    ; obtain the interchange format for the current object
    if (is_binary(label, objindex, end_objindex)) then begin
        interchangeformat = "BINARY"
    endif else begin
        goto, endfunction
    endelse

    ; obtain the structure to be read from the data file:
    if (~st) then begin
        print, "Now constructing ARRAY/COLLECTION structure to be read"
    endif
    struct = arrcol_struct(label, objindex)
    if (struct.flag eq -1) then begin
        goto, endfunction
    endif else begin
        ; set the actual structure to be read to a separate variable
        read_struct = struct.(1)
    endelse    

    ; obtain object pointer:
    pointer = pointpds(label, filename, objname)
    if (pointer.flag eq -1) then goto, endfunction

    ; obtain array / collection data architecture:
    arch = obtain_arrcol_architecture(label, objindex, end_objindex)

    ; read the structure off the file:
    if (~st) then begin
        print, "Now reading ARRAY/COLLECTION object"
    endif
    if (arch eq "MSB") then begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_little_endian
    endif else begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_big_endian
    endelse
    point_lun, unit, pointer.skip
    readu, unit, read_struct
    close, unit
    free_lun, unit
    
    return, read_struct
    endfunction:
       return, -1    
end
