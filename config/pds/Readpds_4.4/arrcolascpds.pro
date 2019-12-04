forward_function create_array, create_collection

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

function sort_objects, object1, object2
    ; initialize variables:
    array = [object1.array, object2.array]
    index = [object1.index, object2.index]
    count = object1.count + object2.count

    ; go through the indicies and perform sequential sort:
    for i = 0, count - 1 do begin
        min = i
        for j = i + 1, count - 1 do begin
            if (index[j] lt index[min]) then begin
                min = j
            endif
        endfor
        temp1 = index[i]
        temp2 = array[i]
        index[i] = index[min]
        array[i] = array[min]
        index[min] = temp1
        array[min] = temp2
    endfor

    ; create structure:
    objects = create_struct("array", array, "index", index, "count", count)

    return, objects
end

function is_object,objectname,object
  result = strtrim(strmid(objectname,strpos(objectname,object)),2) eq object
  return, result
end

function create_element,label,objects,soindex,eoindex

  start_byte = pdspar(label[soindex:eoindex], 'START_BYTE')
  bytes = pdspar(label[soindex:eoindex], 'BYTES')
  data_type = pdspar(label[soindex:eoindex], 'DATA_TYPE')
  format = pdspar(label[soindex:eoindex], 'FORMAT')
  name = strupcase(strtrim(pdspar(label[soindex:eoindex], 'NAME')))
  name = strmid(name,1,strlen(name)-2)
  result = create_struct(name,bytarr(bytes),'delimiter',0B)
  
  return, result
end

function create_collection,label,objects,soindex,eoindex

  pos = where(objects.index gt soindex and objects.index lt eoindex, cnt)
  
  for i=0,cnt-1 do begin
    index = pos[i]
    if (is_object(objects.array[index],'ELEMENT')) then begin
      end_objindex = get_index(label, objects.index[index])
      temp = create_element(label, objects, objects.index[index], end_objindex)
    endif else if (is_object(objects.array[index],'ARRAY')) then begin
      end_objindex = get_index(label, objects.index[index])
      temp = create_array(label, objects, objects.index[index], end_objindex)
      i = i+1
    endif else if (is_object(objects.array[index],'COLLECTION')) then begin
      end_objindex = get_index(label, objects.index[index])
      temp = create_collection(label, objects,objects.index[index], end_objindex)
    endif
  
    result = (n_elements(result) eq 0) ? create_struct('element'+strtrim(string(i),2),temp) : create_struct(result,'element'+strtrim(string(i),2),temp)
  endfor
  
  return, result
end


function create_array,label,objects,soindex,eoindex
  
  pos = where(objects.index gt soindex and objects.index lt eoindex, cnt)
  subobject_index = objects.index(pos[0])
  subobject_eindex = get_index(label, subobject_index)
  
  if (is_object(objects.array(pos[0]),'ELEMENT')) then begin
    end_objindex = get_index(label, objects.index(pos[0]))
    temp = create_element(label, objects, objects.index(pos[0]), end_objindex)
    
  endif else if (is_object(objects.array(pos[0]),'ARRAY')) then begin
    end_objindex = get_index(label, objects.index(pos[0]))
    temp = create_array(label, objects, objects.index(pos[0]), end_objindex)
    
  endif else if (is_object(objects.array(pos[0]),'COLLECTION')) then begin
    end_objindex = get_index(label, objects.index(pos[0]))
    temp = create_collection(label, objects,objects.index(pos[0]), end_objindex)
  endif
  
  axes = pdspar(label[soindex:eoindex], 'AXES')
  axes = uint(axes[0])
  axis_items = strtrim(pdspar(label[soindex:eoindex], 'AXIS_ITEMS'),2)
  if (axes gt 1) then begin
    axis_items = strmid(axis_items,strpos(axis_items,'(')+1,strlen(axis_items)-2)
    axis_items = uint(strsplit(axis_items,',',/EXTRACT))
  endif else axis_items = uint(axis_items[0])
  
  case axes of
    1: result = replicate(temp,axis_items[0])
    2: result = replicate(temp,axis_items[0],axis_items[1])
    3: result = replicate(temp,axis_items[0],axis_items[1],axis_items[2])
    4: result = replicate(temp,axis_items[0],axis_items[1],axis_items[2],axis_items[3])
  endcase
  return, result
end

function get_subobjects_arrcol, label, start_index, end_index

  objects = objpds(label, "ALL")
  elementobjects = objpds(label, "ELEMENT")
  objects = sort_objects(objects, elementobjects)
  
  return,objects
end

function organize_struct, structure, name
  
  names = tag_names(structure)
  for i=0,n_tags(structure)-1 do begin
    if (names(i) eq 'DELIMITER') then continue
    if (size(structure.(i),/type) eq 8) then temp = organize_struct(structure.(i),names(i)) $
    else begin
      temp = create_struct(names(i),STRING(structure.(i)))
    endelse
    result = (n_elements(result) gt 0) ? create_struct(result,temp) : create_struct(temp)
  endfor
 
  return,result
end

function organize_data, read_struct
  
  if (size(read_struct,/type) eq 8) then begin
    result = organize_struct(read_struct)
  endif 
 
  return, result
end

function arrcolascpds, filename, label, objindex, SILENT=silent
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

    ;; Create structure to read data in
    objects = get_subobjects_arrcol(label, objindex, end_objindex)
   
    if (is_object(objects.array[0],'ARRAY')) then begin
      end_objindex = get_index(label, objects.index[0])
      read_struct = create_array(label, objects, objects.index[0], end_objindex)
    endif else if (is_object(objects.array[0],'COLLECTION')) then begin
      end_objindex = get_index(label, objects.index[0])
      read_struct = create_collection(label, objects,objects.index[0], end_objindex)
    endif
    
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
    
    if (n_elements(read_struct) gt 1) then $
    for i=0ULL,n_elements(read_struct)-2 do begin
      first = (n_elements(first) eq 0) ? [read_struct(i)] : [first,read_struct(i)]
    endfor
    last = read_struct(n_elements(read_struct)-1)
   
    if ((n_elements(first) ne 0)) then readu,unit,first
    
    ;; Remove last delimiter from last structure element before reading from file
    data_length = n_tags(last,/data_length)
    last_data = bytarr(data_length-1) ;; last delimiter does not exist in file
    readu,unit,last_data
    last_data = [last_data,44B]
    reads,last_data,last
    result = ((n_elements(first) eq 0)) ? [last] : [first,last]
    
    close, unit
    free_lun, unit
    
    data = organize_data(result)
    
    return, data
    
    endfunction:
       return, -1    
end
