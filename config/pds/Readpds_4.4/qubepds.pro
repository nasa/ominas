;-----------------------------------------------------------------------------
; NAME: QUBEPDS
;
; PURPOSE: To read a 3-D image QUBE object into a 3-D IDL array.
;
; CALLING SEQUENCE:
;     Result: QUBEPDS (filename, label [,/SILENT, /NOSCALE])
;
; INPUTS:
;     Filename: Scalar string containing the name of the PDS file to read
;     Label: the PDS label string array containing qube object definitions
; OUTPUTS:
;     Result: and IDL structure containing the qube array(s).
;
; OPTIONAL INPUT:
;     SILENT: suppresses any message from the procedure
;     NOSCALE: does not perform scaling and offset of values; default
;         is to scale and offset
;
; PROCEDURES USED:
;     Functions: APPLY_BITMASK, CLEAN, GET_INDEX, OBJPDS, PDSPAR,
;         POINTPDS, REMOVE
;
; MODIFICATION HISTORY:
;     Written by: Puneet Khetarpal [August, 2002]
;     
;     09 Mar 2006  A.Cardesin   Do not throw an error for Suffix_bytes NE 4 but only a warning.
;     
;     10 Feb 2007  S.Martinez   Update to read qube structure and suffix planes 
;                               depending on the storage order.
;     
;     04 Apr 2008  S.Martinez   Corrected bug. 
;                               Fuction obtain_item_idltype moved before obtain_qube_structure.
;
;
;     For a complete list of modifications, see changelog.txt file.
;
; RESTRICTIONS:
;  - Assume qubes with 3-axes among the 6 possible axes
;  - All parameters are assumed to have the same variable type 
;     inside a given suffix (the first type in the list *_SUFFIX_ITEM_TYPE)
;  - Corner regions are not used
;

;-----------------------------------------------------------------------------

;- level 3 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices; so is label;
;     param is a PDS keyword to be extracted from label; required is a
;     boolean describing whether the keyword to be extracted is
;     required for the qube object or not.
; postcondition: the keyword for current qube is extracted and returned

function extract_qube_keywords, start_ind, end_ind, label, param, required
    ; initialize variables:
    flag = 0       ; 1: found, 0: not found

    ; first extract all param keywords value in the label:
    allvalues = pdspar(label, param, count = allcount, index = allindex)
    if (allcount gt 0) then begin
        ;; extract all param value between start_ind and end_ind:
        pos = where (allindex gt start_ind and allindex lt end_ind, cnt)
        if (cnt gt 0) then begin
            value = clean(allvalues[pos[0]], /space)
            flag = 1
        endif
    endif

    ; if not found then issue error:
    if (~flag) then begin
        if (required) then begin
            print, "Error: missing required " + param + " keyword from label"
        endif
        value = "-1"
    endif

    return, value
end

;-----------------------------------------------------------------------------
; precondition: keywds contains all current qube object definitions
; postcondition: all keyword values are tested for viability

function check_qube_keywords, keywds
    ; construct new structure:
    struct = {flag: 1}
    param = ['"', "(", ")", "{", "}"]

    ; check axes:
    axes = long(clean(keywds.axes, /space))
    if (axes eq 0) then begin
        print, "Error: AXES keyword value is 0. No data in file."
        goto, endfunction
    endif else if (axes lt 1 || axes gt 6) then begin
        print, "Error: invalid AXES keyword value found: " + $
            clean(string(axes), /space)
        goto, endfunction
    endif

    ; check axis name:
    temp = remove(clean(keywds.axis_name, /space), param)
    if (!version.release gt 5.2) then begin
        axis_name = strsplit(temp, ",", /extract)
    endif else begin
        axis_name = str_sep(temp, ",")    ; obsolete in idl v. > 5.2
    endelse
    if (n_elements(axis_name) ne axes) then begin
        print, "Error: invalid number of AXIS_NAME values found: " + $
            clean(string(n_elements(axis_name)), /space) + " ne " + keywds.axes
        goto, endfunction
    endif

    ; check core items:
    temp = remove(clean(keywds.core_items, /space), param)
    if (!version.release gt 5.2) then begin
        core_items = long(strsplit(temp, ",", /extract))
    endif else begin
        core_items = long(str_sep(temp, ","))   ; obsolete in idl v. > 5.2
    endelse
    pos = where (core_items lt 1, cnt)
    if (n_elements(core_items) ne axes) then begin
        print, "Error: invalid number of CORE_ITEMS values found: " + $
            clean(string(n_elements(core_items)), /space) + " ne " +keywds.axes
        goto, endfunction
    endif
    if (cnt gt 0) then begin
        print, "Error: invalid CORE_ITEMS values found: " + $
            clean(string(core_items[pos[0]]), /space) + " (n >= 1)"
        goto, endfunction
    endif

    ; check core item bytes:
    core_item_bytes = long(clean(keywds.core_item_bytes, /space))
    bytesrange = [1, 2, 4]
    pos = where (core_item_bytes eq bytesrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid CORE_ITEM_BYTES keyword value found: " + $
            keywds.core_item_bytes
        goto, endfunction
    endif

    ; check core item type:
    core_item_type = remove(clean(keywds.core_item_type, /space), param)
    if ((strpos(core_item_type, "INTEGER") lt 0) && $
       (strpos(core_item_type, "REAL") lt 0)) then begin
        print, "Error: invalid CORE_ITEM_TYPE keyword value found: " + $
            core_item_type
        goto, endfunction
    endif

    ; check core base:
    core_base = float(clean(keywds.core_base,/space))

    ; check core mulitplier:
    core_multiplier = float(clean(keywds.core_multiplier, /space))

    ; check suffix bytes:
    suffix_bytes = long(clean(keywds.suffix_bytes, /space))
    if (suffix_bytes ne 4) then begin
;Modified A.Cardesin 2006Mar09
;Do not throw an error but only a warning and go on checking
        print, "Warning: invalid SUFFIX_BYTES keyword value found: " + $
            keywds.suffix_bytes + " (must = 4)"
;        goto, endfunction
    endif

    ; check suffix items:
    temp = remove(clean(keywds.suffix_items, /space), param)
    if (!version.release gt 5.2) then begin
        suffix_items = long(strsplit(temp, ',',/extract))
    endif else begin
        suffix_items = long(str_sep(temp, ','))
    endelse
    pos = where (suffix_items lt 0, cnt)
    if (cnt gt 0) then begin
        print, "Error: invalid SUFFIX_ITEMS keyword value found: " + $
            keywds.suffix_items + " (0 <= n)"
        goto, endfunction
    endif

    ; check sample, line, band suffix item bytes:
    bytesrange = [1, 2, 4, 8, 16]
    sample_suffix_item_bytes = long(clean(keywds.sample_suffix_item_bytes, /space))
    pos = where (sample_suffix_item_bytes eq bytesrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid SAMPLE_SUFFIX_ITEM_BYTES keyword value found: " + $
            keywds.sample_suffix_item_bytes
        goto, endfunction
    endif

    line_suffix_item_bytes = long(clean(keywds.line_suffix_item_bytes, /space))
    pos = where (line_suffix_item_bytes eq bytesrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid SAMPLE_SUFFIX_ITEM_BYTES keyword value found: " + $
            keywds.line_suffix_item_bytes
        goto, endfunction
    endif

    band_suffix_item_bytes = long(clean(keywds.band_suffix_item_bytes, /space))
    pos = where (band_suffix_item_bytes eq bytesrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid SAMPLE_SUFFIX_ITEM_BYTES keyword value found: " + $
            keywds.band_suffix_item_bytes
        goto, endfunction
    endif

    struct = create_struct(struct, "axes", axes, "axis_name", axis_name, $
        "core_items", core_items, "core_item_bytes", core_item_bytes, $
        "core_item_type", core_item_type, "core_base", core_base, $
        "core_multiplier", core_multiplier, "suffix_bytes", suffix_bytes, $
        "suffix_items", suffix_items, $
        ;Modified feb2007, smartinez
        "sample_suffix_item_bytes",sample_suffix_item_bytes, "sample_suffix_type",keywds.sample_suffix_type, $
        "line_suffix_item_bytes",line_suffix_item_bytes, "line_suffix_type",keywds.line_suffix_type, $
	"band_suffix_item_bytes",band_suffix_item_bytes, "band_suffix_type",keywds.band_suffix_type)

    return, struct
    endfunction:
        struct.flag = 0
        return, struct
end

;- level 2 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices; so is label
; postcondition: all current qube parameters are extracted from label

function obtain_current_qube_params, start_ind, end_ind, label
    ; initialize keyword structure variable:
    keywds = {flag: 1}

    ; required keywords:
    ; axes:
    axes = extract_qube_keywords(start_ind, end_ind, label, "AXES", 1)
    if (axes eq "-1") then goto, endfunction

    ; axis name:
    axis_name = extract_qube_keywords(start_ind, end_ind, label, "AXIS_NAME",1)
    if (axis_name eq "-1") then goto, endfunction

    ; core items:
    core_items = extract_qube_keywords(start_ind, end_ind, label, $
        "CORE_ITEMS", 1)
    if (core_items eq "-1") then goto, endfunction

    ; core item bytes:
    core_item_bytes = extract_qube_keywords(start_ind, end_ind, label, $
        "CORE_ITEM_BYTES", 1)
    if (core_item_bytes eq "-1") then goto, endfunction

    ; core item type:
    core_item_type = extract_qube_keywords(start_ind, end_ind, label, $
        "CORE_ITEM_TYPE", 1)
    if (core_item_type eq "-1") then goto, endfunction

    ; core base:
    core_base = extract_qube_keywords(start_ind, end_ind, label, "CORE_BASE",1)
    if (core_base eq "-1") then goto, endfunction

    ; core multiplier:
    core_multiplier = extract_qube_keywords(start_ind, end_ind, label, $
        "CORE_MULTIPLIER", 1)
    if (core_multiplier eq "-1") then goto, endfunction

    ; suffix bytes:
    suffix_bytes = extract_qube_keywords(start_ind, end_ind, label, $
        "SUFFIX_BYTES", 1)
    if (suffix_bytes eq "-1") then goto, endfunction

    ; suffix items:
    suffix_items = extract_qube_keywords(start_ind, end_ind, label, $
        "SUFFIX_ITEMS", 1)
    if (suffix_items eq "-1") then goto, endfunction

    ;Modified feb2007, smartinez
    ;Get SAMPLE, LINE, BAND suffix bytes and types if present, else suffix_bytes or "REAL"
    sample_suffix_item_bytes = extract_qube_keywords(start_ind, end_ind, label, $
  		"SAMPLE_SUFFIX_ITEM_BYTES", 0)
    if (sample_suffix_item_bytes eq "-1") then sample_suffix_item_bytes = suffix_bytes
    sample_suffix_type = extract_qube_keywords(start_ind, end_ind, label, $
  		"SAMPLE_SUFFIX_ITEM_TYPE", 0)
    if (sample_suffix_type eq "-1") then sample_suffix_type = "REAL"    

    line_suffix_item_bytes = extract_qube_keywords(start_ind, end_ind, label, $
  		"LINE_SUFFIX_ITEM_BYTES", 0)
    if (line_suffix_item_bytes eq "-1") then line_suffix_item_bytes = suffix_bytes
    line_suffix_type = extract_qube_keywords(start_ind, end_ind, label, $
  		"LINE_SUFFIX_ITEM_TYPE", 0)
    if (line_suffix_type eq "-1") then line_suffix_type = "REAL"

    band_suffix_item_bytes = extract_qube_keywords(start_ind, end_ind, label, $
  		"BAND_SUFFIX_ITEM_BYTES", 0)
    if (band_suffix_item_bytes eq "-1") then band_suffix_item_bytes = suffix_bytes
    band_suffix_type = extract_qube_keywords(start_ind, end_ind, label, $
  		"BAND_SUFFIX_ITEM_TYPE", 0)
    if (band_suffix_type eq "-1") then band_suffix_type = "REAL"
  		
    ; add keywords values to structure:
    ; Modified feb2007, smartinez. Added sample, line and band suffix keywords.
    keywds = create_struct(keywds, "axes", axes, "axis_name", axis_name, $
        "core_items", core_items, "core_item_bytes", core_item_bytes, $
        "core_item_type", core_item_type, "core_base", core_base, $
        "core_multiplier", core_multiplier, "suffix_bytes", suffix_bytes, $
        "suffix_items", suffix_items, $
        "sample_suffix_item_bytes",sample_suffix_item_bytes, "sample_suffix_type",sample_suffix_type, $
        "line_suffix_item_bytes",line_suffix_item_bytes, "line_suffix_type",line_suffix_type, $
	"band_suffix_item_bytes",band_suffix_item_bytes, "band_suffix_type",band_suffix_type)

    ; clean keywords structure and convert to appropriate type:
    keywds = check_qube_keywords (keywds)

    return, keywds

    endfunction:
        keywds.flag = 0
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: type is a viable sample type keyword value for current qube
; postcondition: the architecture of the data file is returned

function obtain_qube_architecture, type
    ; initialize variable:
    arch = "MSB"

    ; determine if arch is "LSB":
    if ((strpos(type, "LSB") gt -1) || (strpos(type, "PC") gt -1) || $
        (strpos(type, "VAX") gt -1)) then begin
        arch = "LSB"
    endif

    return, arch
end

;-----------------------------------------------------------------------------
; precondition: type is the item type; bytes is the number of bytes of the item
; postcondition: the idl data type more suitable is returned

function obtain_item_idltype, type, bytes

    case bytes of
      1:  idltype = 1
      2:  idltype = (strpos(type, "UNSIGNED") gt -1) ? 12 : 2   
      4:  if (strpos(type, "INTEGER") gt -1) then begin
    idltype = (strpos(type, "UNSIGNED") gt -1) ? 13 : 3
      endif else begin
    idltype = 4
      endelse
      8:  if (strpos(type, "INTEGER") gt -1) then begin
    idltype = (strpos(type, "UNSIGNED") gt -1) ? 15 : 14
      endif else begin
    idltype = (strpos(type, "COMPLEX") gt -1) ? 6 : 5
      endelse 
      16: idltype = (strpos(type, "REAL") gt -1) ? 0 : 9   
      else: idltype = 0
    endcase

    return, idltype
end

;-----------------------------------------------------------------------------
; precondition: keywds is the idl structure definition for current
;     qube object
; postcondition: an idl structure is created to read the data from the
;     data file

function obtain_qube_structure, keywds

;    ; initialize structure:
;    bits = keywds.core_item_bytes * 8   ; temporary store bits value
;    type = keywds.core_item_type        ; temporary store item type value
;
;    ; get the idl type of the vector to be created:
;    if (bits eq 8) then begin
;        idl_type = 1
;    endif else if (bits eq 16) then begin
;        idl_type = (strpos(type, "UNSIGNED") gt -1) ? 12 : 2
;    endif else if (bits eq 32) then begin
;        if (strpos(type, "INTEGER") gt -1) then begin
;            idl_type = (strpos(type, "UNSIGNED") gt -1) ? 13 : 3
;        endif else begin
;            idl_type = 4
;        endelse
;    endif	    

;    ; determine which element contains the SAMPLE axis:
;    pos = where (keywds.axis_name eq "SAMPLE")
;    vector = make_array(keywds.core_items[pos[0]], type = idl_type)
;
;    ; construct the structure with sample suffix bytes if any:
;    if (keywds.suffix_items[pos[0]] gt 0) then begin
;        bytes = keywds.suffix_items[pos[0]] * keywds.suffix_bytes
;        sample_struct = {sample:vector, sideplane:bytarr(bytes)}
;    endif else begin
;        sample_struct = {sample:vector}
;    endelse
;
;    ; replicate the above structure LINES items times:
;    pos = where (keywds.axis_name eq "LINE")
;    lines_struct = replicate(sample_struct, keywds.core_items[pos[0]])
;
;    ; construct the structure with line suffix bytes if any:
;    if (keywds.suffix_items[pos[0]] gt 0) then begin
;        bytes = keywds.suffix_items[pos[0]] * 4
;        band_struct = {line:lines_struct, bottomplane:bytarr(bytes)}
;    endif else begin
;        band_struct = {line:lines_struct}
;    endelse
;
;    ; replicate the above structure BAND items times:
;    pos = where (keywds.axis_name eq "BAND")
;    main = replicate(band_struct, keywds.core_items[pos[0]])
;    
;    return, main

    ;Modified feb2007, smartinez

    ;Qube core item type
    print, 'CORE Items: ',  keywds.core_item_type,keywds.core_item_bytes
    core_type = obtain_item_idltype(keywds.core_item_type,keywds.core_item_bytes)

    ;Qube storage order
    if (keywds.axis_name[0] eq 'SAMPLE' and keywds.axis_name[1] eq 'LINE' $		; BSQ - (SAMPLE,LINE,BAND)
	and keywds.axis_name[2] eq 'BAND') then begin order = 0
    endif else if (keywds.axis_name[0] eq 'SAMPLE' and keywds.axis_name[1] eq 'BAND'$	; BIL - (SAMPLE,BAND,LINE)
	and keywds.axis_name[2] eq 'LINE') then begin order = 1
    endif else if (keywds.axis_name[0] eq 'BAND' and keywds.axis_name[1] eq 'SAMPLE'$	; BIP - (BAND,SAMPLE,LINE)
	and keywds.axis_name[2] eq 'LINE') then begin order = 2
    endif 

   if array_equal(keywds.axis_name,['BAND','LINE','SAMPLE']) then order=3
   print, 'Order: ',order

    ;Qube structure

    ; X core dimension 
    X_line = Make_array(keywds.core_items[0],Type=core_type,/nozero)
    
    ; SX suffix items type
    suffix_item_type = (order ge 2) ? keywds.band_suffix_type : keywds.sample_suffix_type
    suffix_item_bytes = (order ge 2) ? keywds.band_suffix_item_bytes : keywds.sample_suffix_item_bytes
    suffix_type = obtain_item_idltype(suffix_item_type,suffix_item_bytes)

    ; SX suffix plane
    if (keywds.suffix_items[0] gt 0) then begin
	SX_line = Make_array(keywds.suffix_items[0],Type=suffix_type,/nozero)
        XSX_line = {X:X_line, SX:SX_line} 
    endif else XSX_line = {X:X_line}
    SX_line = 0B    

    ; Y core dimension, SY suffix plane
    ; SY suffix items type
    if (order eq 0) then begin
	suffix_item_type = keywds.line_suffix_type
	suffix_item_bytes = keywds.line_suffix_item_bytes
    endif else if (order eq 1) then begin
	suffix_item_type = keywds.band_suffix_type
	suffix_item_bytes = keywds.band_suffix_item_bytes
    endif else if (order eq 2) then begin
	suffix_item_type = keywds.sample_suffix_type
	suffix_item_bytes = keywds.sample_suffix_item_bytes
    endif else begin
      suffix_item_type = keywds.line_suffix_type
      suffix_item_bytes = keywds.line_suffix_item_bytes      
    endelse
    suffix_type = obtain_item_idltype(suffix_item_type,suffix_item_bytes)

    ; Replicate (X+SX, Y times)
    ; Add SY suffix plane with dimension (X,SY)
    if (keywds.suffix_items[1] gt 0) then begin
	SY_line = reform(Make_array(keywds.core_items[0], keywds.suffix_items[1], Type=suffix_type,/nozero), $
		keywds.core_items[0], keywds.suffix_items[1])
        XY_frame = {Y:replicate(XSX_line,keywds.core_items[1]), SY:SY_line} 
    endif else  XY_frame = {Y:replicate(XSX_line,keywds.core_items[1])}
    SY_line = 0B    
    XSX_line = 0B

    ;Z core dimension, SZ suffix plane
   
    ; SZ suffix items type
    suffix_item_type = (order eq 0) ? keywds.band_suffix_type : keywds.line_suffix_type
    suffix_item_bytes = (order eq 0) ? keywds.band_suffix_item_bytes : keywds.line_suffix_item_bytes
    if order eq 3 then begin
      suffix_item_type=keywds.sample_suffix_type
      suffix_item_item_bytes=keywds.sample_suffix_item_bytes
    endif
    suffix_type = obtain_item_idltype(suffix_item_type,suffix_item_bytes)

    if (keywds.suffix_items[2] gt 0) then begin
	SZ_line = reform(Make_array(keywds.core_items[0], keywds.core_items[1], keywds.suffix_items[2], Type=suffix_type,/nozero), $
		keywds.core_items[0], keywds.core_items[1], keywds.suffix_items[2])
        qube = {Z:replicate(XY_frame,keywds.core_items[2]), SZ:SZ_line} 
    endif else  qube = {Z:replicate(XY_frame,keywds.core_items[2])} 
    XY_frame = 0B
    SZ_line = 0B
    
    return, qube

end

;-----------------------------------------------------------------------------
; precondition: pointer is an idl structure containing viable data
;     file name associated with current qube object to be read, and
;     the number of bytes to skip if any; struct is the idl structure
;     to be read from the data file, and arch is the architecture of
;     the data file (LSB or MSB).
; postcondition: the data file is opened, the structure is read, and returned

function read_qube_data, pointer, struct, arch
    ; error protection:
    on_ioerror, signal

    ; initialize variable and declare flag:
    data_read = {flag: 1} ; 0: error, 1: no error

    ; open the file to read and apply swap endian if needed:
    if (arch eq "MSB") then begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_little_endian
    endif else begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_big_endian
    endelse

    ; set the file pointer to current object to be read:
    point_lun, unit, pointer.skip    

    ; read the qube object into structure:
    readu, unit, struct

    ; close the unit and free the unit:
    close, unit
    free_lun, unit

    data_read = create_struct(data_read, "struct", struct)

    return, data_read

    signal:
       on_ioerror, null
       print, "Error: file either corrupted or invalid parameters specified" +$
           " in label."
       data_read.flag = 0
       return, data_read
end

;-----------------------------------------------------------------------------
; precondition: current contains the raw qube data structure for
;     current qube as read from the datafile; keywds containsn all
;     current qube object keyword values.
; postcondition: extracts the qube array from the current structure,
;     converts the array values to signed integers if necessary, and
;     performs scaling and offset if noscale keyword is not supplied.

function convert_qube_data, current, label, start_ind, end_ind, keywds, noscale
    
    ; extract qube from the read data:
    ;Modified smartinez, feb2007   
    ;element = current[*].dimension1[*].dimension0
    element_core = current.Z.Y.X

    ;Modified by P.Choganwala starts
    if ((keywds.suffix_items[0] eq 0) and       $
        (keywds.suffix_items[1] eq 0) and       $
	(keywds.suffix_items[2] eq 0)) then begin
        element_suffix = 0
    endif
    if (keywds.suffix_items[2] gt 0) then begin
        element_suffix = current.SZ
    endif
    if (keywds.suffix_items[1] gt 0) then begin
        element_suffix = current.Z.SY
    endif
    if (keywds.suffix_items[0] gt 0) then begin
        element_suffix = current.Z.Y.SX
    endif
    ;Modified by P.Choganwala ends
    
    ; convert data elements for signed bytarr objects
    ; (IDL only supports byt values of 0-255):
    pos = strpos(keywds.core_item_type, "UNSIGNED")
    if ((keywds.core_item_bytes eq 1) && (pos lt 0)) then begin
        element_core = fix(element_core)
        fixitlist = where (element_core gt 127, count)
        if (count gt 0) then begin
            element_core[fixitlist] -= 256
        endif
    endif

    ; apply bit mask if applicable:
    element_core = apply_bitmask(label, start_ind, end_ind, element_core)
    element_suffix = apply_bitmask(label, start_ind, end_ind, element_suffix)

    ; process scaling factor and offset:
    if (~noscale) then begin
        if (keywds.core_multiplier ne 1.0) then begin
            element_core *= keywds.core_multiplier
        endif
        if (keywds.core_base ne 0.0) then begin
            element_core += keywds.core_base
        endif
    endif

    element = {core:element_core, sideplane:element_suffix}
    return, element
end

;- level 1 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: filename and label are viable, and objects has at
;     least one qube object structure.
; postcondition: all qube objects are processed as defined in objects struct

function process_all_qubes, filename, label, objects, silent, noscale
    ; initialize the qube structure if more than one qube:
    if (objects.count gt 1) then data = {qubes:objects.count}

    ; start the loop:
    for i = 0, objects.count - 1 do  begin
        ;; get current start and end index pointer:
        start_ind = objects.index[i]
        end_ind = get_index(label, start_ind)
        if (end_ind eq -1) then return, -1

        ; obtain current qube object keyword values:
        keywds = obtain_current_qube_params (start_ind, end_ind, label)
        if (~keywds.flag) then return, -1

        ; obtain file data architecture:
        arch = obtain_qube_architecture(keywds.core_item_type)

        ; obtain qube structure:

        struct = obtain_qube_structure(keywds)

        ; obtain pointer information:
        pointer = pointpds(label, filename, objects.array[i])
        if (pointer.flag eq "-1") then return, -1

        ; inform user of current status:
        if (~silent) then begin
            text = "Now reading "
            for j = 0, keywds.axes - 2 do begin
                text += clean(string(keywds.core_items[j]),/space) + " by "
            endfor
            text += clean(string(keywds.core_items[keywds.axes - 1]),/space)+$
                " qube array"
            
            ;Modified feb2007, smartinez. Added suffix dimension.
	    ;print, text
            text += ", "
            for j = 0, keywds.axes - 2 do begin
                text += clean(string(keywds.suffix_items[j]),/space) + " by "
            endfor
            text += clean(string(keywds.suffix_items[keywds.axes - 1]),/space)+ $
		" suffix items."
            print, text 
        endif

        ; read data:
        data_read = read_qube_data(pointer, struct, arch)
        if (~data_read.flag) then return, -1
        current = data_read.struct

        ; perform data conversion if needed:
        element = convert_qube_data(current, label, start_ind, end_ind, $
            keywds, noscale)

	; add qube to structure:
        data = (objects.count gt 1) ? create_struct(data, objects.array[i], $
            element) : element
    endfor

    return, data
end

;- level 0 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: filename is a viable pds label file name, and label is
;     a viable pds label.
; postcondition: all qube objects defined in label are read from
;     associated data file and returned.

function qubepds, filename, label, SILENT = silent, NOSCALE = noscale
    ; error protection:
    ;on_error, 2

    ; check for number of parameters in function call:
    if (n_params() lt 2) then begin
        print, "Syntax Error: result = qubepds(filename, label [, /SILENT," + $
               " /NOSCALE] )"
        return, -1
    endif
    silent = keyword_set(SILENT)
    noscale = keyword_set(NOSCALE)

    ; obtain all qube objects from label:
    objects = objpds (label, "QUBE")
    if (objects.flag eq -1) then begin
        print, "Error: no QUBE object found in label"
        return, -1
    endif

    ; process all qube objects:
    data = process_all_qubes(filename, label, objects, silent, noscale)

    return, data
end
