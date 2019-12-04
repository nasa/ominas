;-----------------------------------------------------------------------------
; NAME: IMAGEPDS
; 
; PURPOSE: To read an image array into an array variable
;
; CALLING SEQUENCE: Result = IMAGEPDS (filename, label [,/SILENT, /NOSCALE]
; 
; INPUTS:
;     Filename: Scalar string containing the name of the PDS file to read
;     Label: String array containing the image header information
; OUTPUTS:
;     Result: image array constructed from designated record
;
; OPTIONAL INPUT:
;     SILENT: suppresses any messages from the procedure
;     NOSCALE: does not perform scaling and offset of values, default
;         is to scale and offset
; 
; EXAMPLES:
;     To read an image file IMAGE.LBL into an array, img:
;        IDL> label = headpds("IMAGE.LBL", /SILENT)
;        IDL> img = imagepds("IMAGE.LBL", label,/SILENT)
;     To read an image file IMAGEWIN.LBL with a window object into img:
;        IDL> label = headpds("IMAGEWIN.LBL", /SILENT)
;        IDL> img = imagepds("IMAGEWIN.LBL",/SILENT)
;
; PROCEDURES USED:
;     Functions: APPLY_BITMASK, CLEAN, GET_INDEX, OBJPDS, PDSPAR,
;         POINTPDS, REMOVE
; 
; MODIFICATION HISTORY:
;     Adapted by John D. Koch from READFITS by Wayne Landsman,
;         December, 1994
;     
;     Re-written by: Puneet Khetarpal [January 25, 2005]
;     For a complete list of modifications, see changelog.txt file.
;
;-----------------------------------------------------------------------------

;- level 3 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices for current
;     image; so is label; param is a PDS keyword name to be extracted
;     from label; required is a boolean describing whether the keyword
;     to be extracted is required for the image object or not.
; postcondition: the keyword for current image object is extracted and returned
  
function extract_image_keywords, start_ind, end_ind, label, param, required
    ; intialize variables:
    flag = 0      ; 1: found, 0: not found
    ; determine if param value is of type string or not:
    isstring = ((param eq "SAMPLE_TYPE") || $
               (strpos(param, "DISPLAY") gt -1)) ? 1 : 0  
    ; determine if param value if of type double or not:
    isfloat = ((param eq "OFFSET") || (param eq "SCALING_FACTOR")) ? 1 : 0

    ; first extract all param keywords value in the label:
    allvalues = pdspar(label, param, count=allcount, index=allindex)
    if (allcount gt 0) then begin
        ; extract all param value between start_ind and next object or
        ; end index:
        objects = pdspar(label, "OBJECT", count=objcount, index=objindex)
        pos = where (objindex gt start_ind, cnt)
        if (cnt gt 0) then begin
            greatind = objindex[pos[0]]
            ppos = where (allindex gt start_ind and allindex lt greatind, pcnt)
        endif else begin
            ppos = where(allindex gt start_ind and allindex lt end_ind, pcnt)
        endelse

        if (pcnt gt 0) then begin
            value = clean(allvalues[ppos[0]], /space)
            flag = 1
            
            ; convert into appropriate type:
            if (isstring) then begin
                par = ['"', "'", "(", ")", ","]
                value = remove(value, par)
            endif else if (isfloat) then begin
                value = float(value)
            endif else begin
                value = long(value)
            endelse
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
; precondition: value is an idl scalar obtained from the label for
;     current image object definition
; postcondition: the value is tested for whether it is of type string
;     or not

function is_string, value
    ; get size information of value:
    flag = (size(value, /type) eq 7) ? 1 : 0
    return, flag
end

;-----------------------------------------------------------------------------
; precondition: keywds contains all current image object definitions
; postcondition: all keyword values are tested for viability

function check_image_keywords, keywds, silent
    ; check line samples:
    if (keywds.line_samples eq 0) then begin
        print, "Error: LINE_SAMPLES keyword value is 0. No data in file."
        goto, endfunction
    endif else if (keywds.line_samples lt 0) then begin
        print, "Error: Invalid LINE_SAMPLES keyword value found: " + $
            clean(string(keywds.line_samples), /space)
        goto, endfunction
    endif  

    ; check lines:
    if (keywds.lines eq 0) then begin
        print, "Error: LINES keyword value is 0. No data in file."
        goto, endfunction
    endif else if (keywds.lines lt 0) then begin
        print, "Error: Invalid LINES keyword value found: " + $
            clean(string(keywds.lines), /space)
        goto, endfunction
    endif

    ; check sample bits:
    bitsrange = [8, 16, 32, 64]
    pos = where (keywds.bits eq bitsrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid SAMPLE_BITS keyword value found: " + $
            clean(string(keywds.bits), /space) 
        goto, endfunction
    endif

    ; check sample type:
    if (strlen(keywds.sample_type) eq 0) then begin
        print, "Error: null SAMPLE_TYPE keyword value found."
        goto, endfunction
    endif

    ; check sample display direction:
    if (keywds.sdd eq "-1") then begin
        if (~silent) then begin
          print, "Note: SAMPLE_DISPLAY_DIRECTION keyword not found..."
          print, "  assuming default value of RIGHT."
        endif
        keywds.sdd = "RIGHT"
    endif
    ddrange = ["UP", "DOWN", "LEFT", "RIGHT"]
    pos = where (keywds.sdd eq ddrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid SAMPLE_DISPLAY_DIRECTION keyword: " + keywds.sdd
        print, "  assuming default value of RIGHT."
        keywds.sdd = "RIGHT"
    endif

    ; check line display direction:
    if (keywds.ldd eq "-1") then begin
        if (~silent) then begin
          print, "Note: LINE_DISPLAY_DIRECTION keyword not found..."
          print, "  assuming default value of DOWN."
        endif
        keywds.ldd = "DOWN"
    endif
    pos = where (keywds.ldd eq ddrange, cnt)
    if (cnt eq 0) then begin
        print, "Error: invalid LINE_DISPLAY_DIRECTION keyword: " + keywds.ldd
        print, "  assuming default value of DOWN."
        keywds.ldd = "DOWN"
    endif

    return, keywds

    endfunction:
        keywds.flag = 0
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices for current
;     image object, and wobjects contains all the window objects
;     in the label
; postcondition: all window subobjects for current image object are returned

function get_subwindows, start_ind, end_ind, wobjects
    ; initialize variable:
    struct = {flag: 0, count:0}
    windex = wobjects.index

    ; find whether there exist window subobjects for start index:
    pos = where (windex gt start_ind and windex lt end_ind, count)
    if (count gt 0) then begin
        struct.flag = 1
        struct.count = count
        array = wobjects.array[pos]
        index = wobjects.index[pos]
        struct = create_struct(struct, "array", array, "index", index)
    endif

    return, struct
end

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices for the current
;     subwindow object; so is label; element contains the current
;     image object array
; postcondition: the current window subobject parameters are obtained
;     from label and returned in a structure

function obtain_current_window_params, start_ind, end_ind, label, element
    ; initialize keyword structure variable:
    keywds = {flag: 1}
    
    ; get dimensions of element:
    dim = size(element, /dimensions)

    ; extract first line:
    first_line = extract_image_keywords(start_ind, end_ind, label, $
        "FIRST_LINE", 1)
    if (is_string(first_line)) then goto, endfunction

    ; check first line:
    if (first_line le 0 || first_line gt dim[1]) then begin
        print, "Error: FIRST_LINE keyword value exceeds image: " + $
            clean(string(first_line),/space)
        goto, endfunction
    endif

    ; extract first line sample:
    first_line_sample = extract_image_keywords(start_ind, end_ind, label, $
        "FIRST_LINE_SAMPLE", 1)
    if (is_string(first_line_sample)) then goto, endfunction

    ; check first line sample:
    if (first_line_sample le 0 || first_line_sample gt dim[0]) then begin
        print, "Error: FIRST_LINE_SAMPLE keyword value exceeds image: " + $
            clean(string(first_line), /space)
        goto, endfunction
    endif

    ; extract line samples:
    line_samples = extract_image_keywords(start_ind, end_ind, label, $ 
        "LINE_SAMPLES", 1)
    if (is_string(line_samples)) then goto, endfunction

    ; check line samples:
    if (line_samples eq 0) then begin
        print, "Error: LINE_SAMPLES keyword value is 0. No data in file."
        goto, endfunction
    endif else if (line_samples lt 0) then begin
        print, "Error: Invalid LINE_SAMPLES keyword value found: " + $
            clean(string(line_samples), /space)
        goto, endfunction
    endif  

    ; extract lines:
    lines = extract_image_keywords(start_ind, end_ind, label, "LINES", 1)
    if (is_string(lines)) then goto, endfunction

    ; check lines:
    if (lines eq 0) then begin
        print, "Error: LINES keyword value is 0. No data in file."
        goto, endfunction
    endif else if (lines lt 0) then begin
        print, "Error: Invalid LINES keyword value found: " + $
            clean(string(lines), /space)
        goto, endfunction
    endif

    keywds = create_struct(keywds, "first_line", first_line, $
        "first_line_sample", first_line_sample, "line_samples", line_samples, $
        "lines", lines)

    return, keywds
    endfunction:
        keywds.flag = 0
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: element is either a subwindow array or the image
;     array; keywds contains all current image object definitions.
; postcondition: the element array is rotated depending upon the
;     values of line and sample display direction keyword values
 
function process_display_direction, element, keywds
    ; local variables:
    ldd = keywds.ldd
    sdd = keywds.sdd
    saveelement = element

    ; process display direction:
    if (sdd eq "RIGHT") then begin
        element = (ldd eq "UP") ? rotate(element, 0) : $
           (ldd eq "DOWN") ? rotate(element, 7) : -1 
    endif else if (sdd eq "LEFT") then begin
        element = (ldd eq "UP") ? rotate(element, 5) : $
           (ldd eq "DOWN") ? rotate(element, 2) : -1
    endif else if (sdd eq "UP") then begin
        element = (ldd eq "LEFT") ? rotate(element, 3) : $
           (ldd eq "RIGHT") ? rotate(elment, 4): -1
    endif else if (sdd eq "DOWN") then begin
        element = (ldd eq "LEFT") ? rotate(element, 6) : $
           (ldd eq "RIGHT") ? rotate(element, 1) : -1
    endif

    stat = size(element, /dimensions)
    if (stat[0] eq 0) then begin
        print, "Error: invalid LINE_DISPLAY_DIRECTION " + ldd + $
               " and SAMPLE_DISPLAY_DIRECTION " + sdd + " combination"
        return, saveelement
    endif

    return, element
end


;- level 2 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: start and end index are viable indices; so is label
; postcondition: all current image parameters are extracted from label

function obtain_current_image_params, start_ind, end_ind, label, silent
    ; initialize keyword structure variable:
    keywds = {flag:1}

    ; required keywords:
    ; line samples:
    line_samples = extract_image_keywords(start_ind, end_ind, label, $
        "LINE_SAMPLES", 1)
    if (is_string(line_samples)) then goto, endfunction

    ; lines:
    lines = extract_image_keywords(start_ind, end_ind, label, "LINES", 1)
    if (is_string(lines)) then goto, endfunction

    ; bits:
    bits = extract_image_keywords(start_ind, end_ind, label, "SAMPLE_BITS", 1)
    if (is_string(lines)) then goto, endfunction

    ; sample type:
    sample_type = extract_image_keywords(start_ind, end_ind, label, $ 
        "SAMPLE_TYPE", 1)

    if (sample_type eq "-1") then goto, endfunction

    ; optional keywords:
    ; sample display direction:
    samp_dis_dir = extract_image_keywords(start_ind, end_ind, label, $
        "SAMPLE_DISPLAY_DIRECTION", 0)
    
    ; line display direction:
    line_dis_dir = extract_image_keywords(start_ind, end_ind, label, $
        "LINE_DISPLAY_DIRECTION", 0)

    ; offset:
    offset = extract_image_keywords(start_ind, end_ind, label, "OFFSET", 0)
    if (is_string(offset)) then offset = double(0.0)

    ; scaling factor:
    scaling_factor = extract_image_keywords(start_ind, end_ind, label, $
        "SCALING_FACTOR", 0)
    if (is_string(scaling_factor)) then scaling_factor = double(1.0)

    ; line prefix bytes:
    prefix_bytes = extract_image_keywords(start_ind, end_ind, label, $
        "LINE_PREFIX_BYTES", 0)
    if (is_string(prefix_bytes)) then prefix_bytes = long(0)

    ; line suffix bytes:
    suffix_bytes = extract_image_keywords(start_ind, end_ind, label, $
        "LINE_SUFFIX_BYTES", 0)
    if (is_string(suffix_bytes)) then suffix_bytes = long(0) 

    keywds = create_struct(keywds, "line_samples", line_samples, "lines", $
        lines, "bits", bits, "sample_type", sample_type, "sdd", samp_dis_dir, $
        "ldd", line_dis_dir, "offset", offset, "scaling_factor", $
        scaling_factor, "prefix_bytes", prefix_bytes, "suffix_bytes", $
        suffix_bytes)

    keywds = check_image_keywords(keywds,silent)

    return, keywds
    endfunction:
        keywds.flag = 0
        return, keywds
end

;-----------------------------------------------------------------------------
; precondition: sample type is a viable sample type keyword value for
;     current image object
; postcondition: the architecture for the data file is determined

function obtain_image_architecture, sample_type
    ; initialize architecture variable:
    arch = "MSB"

    ; obtain all types of keyword values from the label:
    if ((strpos(sample_type, "LSB") gt -1) || $
        (strpos(sample_type, "PC") gt -1) || $
        (strpos(sample_type, "VAX") gt -1)) then begin
        arch = "LSB"
    endif

    return, arch
end

;-----------------------------------------------------------------------------
; precondition: keywds is the idl structure definition for current
;     image object.
; postcondition: an idl structure is created to read the data from the
;     data file
 
function obtain_image_structure, keywds
    ; initialize structure:
    bits = keywds.bits   ; temporary store bits value
    type = keywds.sample_type ; temporary store sample_type value

    ; get the line sample vector for image:
    if (bits eq 8) then begin
        idl_type = 1
    endif else if (bits eq 16) then begin
        idl_type = (strpos(type, "UNSIGNED") gt -1) ? 12 : 2
    endif else if (bits eq 32) then begin
        if (strpos(type, "INTEGER") gt -1) then begin
            idl_type = (strpos(type, "UNSIGNED") gt -1) ? 13 : 3
        endif else begin
            idl_type = 4
        endelse
    endif else if (bits eq 64) then begin
        if (strpos(type, "INTEGER") gt -1) then begin
            idl_type = (strpos(type, "UNSIGNED") gt -1) ? 15 : 14
        endif else begin
            idl_type = 5
        endelse
    endif

    vector = make_array(keywds.line_samples, type = idl_type)

    ; construct the prefix byte structure:
    if (keywds.prefix_bytes gt 0) then begin
        struct = {prefix:bytarr(keywds.prefix_bytes), sample:vector}
    endif else begin
        struct = {sample:vector}
    endelse

    ; construct the suffix byte structure:
    if (keywds.suffix_bytes gt 0) then begin
        struct = create_struct(struct, "suffix", bytarr(keywds.suffix_bytes))
    endif

    ; now replicate the structure lines times:
    main = replicate(struct, keywds.lines)

    return, main
end

;-----------------------------------------------------------------------------
; precondition: pointer is an idl structure containing viable data
;     file name associated with current image object to be read, and
;     the number of bytes to skip if any; struct is the idl structure
;     to be read from the data file, and arch is the architecture of
;     the data file (LSB or MSB).
; postcondition: the data file is opened, the structure is read, and
;     returned

function read_image_data, pointer, struct, arch
    ; error protection:
    on_ioerror, signal

    ; initialize variable and declare flag:
    data_read = {flag: 1} ; 0: error, 1: no error

    ; open the file to be read and apply swap endian if needed:
    if (arch eq "MSB") then begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_little_endian
    endif else begin
        openr, unit, pointer.datafile, /get_lun, /swap_if_big_endian
    endelse

    ; set the file pointer to current object to be read:
    point_lun, unit, pointer.skip

    ; read the image object into structure:
    readu, unit, struct

    ; close the unit and free the unit:
    close, unit
    free_lun, unit
    
    data_read = create_struct(data_read, "struct", struct)

    return, data_read

    signal:
        on_ioerror, null
        print, "Error: file either corrupted or invalid parameters specified"+$
               " in label."
        data_read.flag = 0
        close, unit
        free_lun, unit
        return, data_read
end

;-----------------------------------------------------------------------------
; precondition: current contains the raw image data for current image
;     object as read from the datafile; keywds contains all current
;     image object keyword values.
; postcondition: extracts the image array from the current structure,
;     converts the array values to signed integers if necessary, and
;     performs scaling and offset if noscale keyword is not supplied.

function convert_image_data, current, label, start_ind, end_ind,keywds, noscale
    ; extract image from the read data:
    element = current[*].sample

    ; convert data elements for signed bytarr objects
    ; (IDL only supports byte values of 0-255):
    pos = strpos(keywds.sample_type, "UNSIGNED")
    if ((keywds.bits eq 8) && (pos lt 0)) then begin
        element = fix(element)
        fixitlist = where (element gt 127, count)
        if (count gt 0) then begin
            element[fixitlist] = element[fixitlist] - 256
        endif
    endif  

    ; apply bit mask if applicable:
    element = apply_bitmask(label, start_ind, end_ind, element)

    ; process scaling factor and offset:
    if (~noscale) then begin
        if (keywds.scaling_factor ne 1.0) then begin
            element *= keywds.scaling_factor
        endif
        if (keywds.offset ne 0.0) then begin
            element += keywds.offset
        endif
    endif

    return, element
end

;-----------------------------------------------------------------------------
; precondition: start_ind and end_ind are viable start and end indices
;     of current image object; element contains the image array
;     information with the converted values, and bitmask applied;
;     wobjects and label are viable, and imgkeywds is an idl structure
;     containing current image object keyword values.
; postcondition: all window subobjects for the current image object,
;     if present, are processed and returned 

function process_windows, start_ind, end_ind, element, wobjects, label, $ 
  imgkeywds, silent
    ; initialize structure:
    windows_struct = {flag: 1}

    ; check existence of window subobjects and get their positions:
    subwindows = get_subwindows(start_ind, end_ind, wobjects)
    if (~subwindows.flag) then goto, endfunction
    count = subwindows.count
    array = subwindows.array
    index = subwindows.index

    ; intialize data structure for windows objects:
    if (count gt 1) then wdata = {windows: count}

    ; process each window subobject:
    for j = 0, count - 1 do begin
        ; set current and next window object pointer:
        cur_win = index[j]
        next_win = (j lt count - 1) ? index[j + 1] : end_ind

        ; obtain required keywords for current window object:
        keywds = obtain_current_window_params(cur_win, next_win, label,element)
        if (~keywds.flag) then goto, endfunction

        ; notify to user if not silent:
        if (~silent) then begin
            xtext = clean(string(keywds.line_samples), /space)
            ytext = clean(string(keywds.lines), /space)
            print, "  Now processing " + xtext + " by " + ytext + " window"
        endif

        ; extract the window vector from element:
        x1 = keywds.first_line_sample - 1     ; x - top left corner of window
        y1 = keywds.first_line - 1            ; y - top left corner of window
        x2 = x1 + keywds.line_samples - 1     ; x - bottom right corner
        y2 = y1 + keywds.lines - 1            ; y - bottom right corner 
        win_element = element(x1:x2, y1:y2)

        ; process display directions
        win_element = process_display_direction(win_element, imgkeywds)

        ; store the window vector into windows data structure:
        if (count gt 1) then begin
            name = array[j] + clean(string(j + 1), /space)
            wdata = create_struct(wdata, name, win_element)
        endif else begin
            wdata = create_struct("window", win_element)
        endelse
    endfor

    ; add entire image to window structure:
    element = process_display_direction(element, imgkeywds)
    wdata = create_struct(wdata, "image", element)
    windows_struct = create_struct(windows_struct, "wdata", wdata)

    return, windows_struct

    endfunction:
        windows_struct.flag = 0
        return, windows_struct
end 

;- level 1 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: filename and label are viable, and objects has at
;     least one image object structure, and wobjects definition is
;     obtained.
; spotcondition: all image objects are processed as defined in objects
;     and window structure.
 
function process_all_images, filename, label, objects, wobjects, silent,noscale
    ; initialize the image structure if more than one image:
    if (objects.count gt 1) then data = {images:objects.count}

    ; start the loop:
    for i = 0, objects.count - 1 do begin
        ; get current start and end index pointer:
        start_ind = objects.index[i]
        end_ind = get_index(label, start_ind)
        if (end_ind eq -1) then return, -1

        ; obtain current image object keyword values:
        keywds = obtain_current_image_params(start_ind, end_ind, label,silent)
        if (~keywds.flag) then return, -1  

        ; obtain file data architecture:
        arch = obtain_image_architecture(keywds.sample_type)

        ; obtain image structure:
        struct = obtain_image_structure(keywds)

        ; obtain pointer info:
        pointer = pointpds(label, filename, objects.array[i])
        if (pointer.flag eq "-1") then return, -1

        ; read data:
        if (~silent) then begin
            print, "Now reading " + clean(string(keywds.line_samples),/space) $
                + " by " + clean(string(keywds.lines),/space) + " image"
        endif
        data_read = read_image_data(pointer, struct, arch)        
        if (~data_read.flag) then return, -1
        current = data_read.struct

        ; perform data conversion if needed:
        element = convert_image_data(current, label, start_ind, end_ind, $
            keywds, noscale)

        ; process window sub objects:
        windows = process_windows(start_ind, end_ind, element, wobjects, $
             label, keywds, silent)

        ; save image and windows structure if applicable:
        if (windows.flag) then begin
            data = (objects.count gt 1) ? create_struct(data, $
                objects.array[i], windows.wdata) : windows.wdata
        endif else begin
            element = process_display_direction(element, keywds)
            data = (objects.count gt 1) ? create_struct(data, $
                objects.array[i], element) : element
        endelse

    endfor

    return, data
end

;- level 0 -------------------------------------------------------------------

;-----------------------------------------------------------------------------
; precondition: filename is a viable pds label file name, and label is
;     a viable pds label.
; postcondition: all image objects defined in label are read from
;     associated data file and returned.
 
function imagepds, filename, label, SILENT = silent, NOSCALE = noscale
    ; error protection:
    ;on_error, 2
    on_ioerror, signal

    ; check for the number of parameters in function call:
    if (n_params() lt 2) then begin
        print, "Syntax Error: result = IMAGEPDS (filename, label [, /SILENT" +$
               ", /NOSCALE])"
        return, -1
    endif
    silent = keyword_set(SILENT)
    noscale = keyword_set(NOSCALE)

    ; obtain all image and window objects from label:
    objects = objpds (label, "IMAGE")
    if (objects.flag eq -1) then begin
        print, "Error: no IMAGE object found in label"
        return, -1
    endif
    wobjects = objpds(label, "WINDOW")

    ; process all image and window objects:
    data = process_all_images(filename,label,objects,wobjects,silent,noscale)

    return, data

    signal:
        on_ioerror, null
        print, "Error reading file"
        return, -1
end
