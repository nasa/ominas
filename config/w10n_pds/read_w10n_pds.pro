;=============================================================================
;+
; NAME:
;       read_w10n_pds
;
;
; PURPOSE:
;       Reads a w10n file from the PDS website
;
;
; CATEGORY:
;       config/w10n_pds 
;
;
; CALLING SEQUENCE:
;       data = read_w10n_pds(url, label)
;
;
; ARGUMENTS:
;  INPUT:
;         url:          String giving the URL of the file to be read.
;
;  OUTPUT:
;       label:          Named variable in which the metadata (JSON format or PDS) label will be
;                       returned.
;
; KEYWORDS:
;  INPUT:
;         pds:          Return label as PDS label
;
;      nodata:          Do not return data
;
;      silent:          Do not print messages
;
;         gif:          Write a local gif file of the data
;
;         dim:          Returned dimension of array
;
;        type:          Returned datatype of array 
;
;      sample:          Requested samples by index
;
; returned_samples:     Returned samples by index (subframe containing sample indexes)
;
; RETURN:
;       The data array read from the web site.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle, 2/2018
;       Modified by:    Haemmerle, 3/2018
;                       Added type, sample, returned_samples
;
;-----------------------------------------------------------------
FUNCTION Url_Callback, status, progress, data

   ; print the info msgs from the url object
   PRINT, status

   ; return 1 to continue, return 0 to cancel
   RETURN, 1
END

;-----------------------------------------------------------------
FUNCTION read_w10n_pds, url, label, dim=dim, type=type, nodata=_nodata, silent=silent, $
                        sample=sample, returned_samples=returned_samples, $
                        pds=pds, gif=gif

   nodata = keyword_set(_nodata)
   status = 0

   ; If the url object throws an error it will be caught here
   CATCH, errorStatus 
   IF (errorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL

      ; Display the error msg 
      if (NOT keyword_set(silent)) then message, /info, !ERROR_STATE.msg

      ; Get the properties that will tell us more about the error.
      oUrl->GetProperty, RESPONSE_CODE=rspCode, $
         RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
      if (NOT keyword_set(silent)) then PRINT, 'rspCode = ', rspCode
      if (NOT keyword_set(silent)) then PRINT, 'rspHdr= ', rspHdr
      if (NOT keyword_set(silent)) then PRINT, 'rspFn= ', rspFn

      ; Destroy the url object
      OBJ_DESTROY, oUrl
      RETURN, 0
   ENDIF

   ; Parse URL
   prot_pos = strpos(url, '://')
   if (prot_pos EQ -1) then begin
      if (NOT keyword_set(silent)) then message, /info, 'URL does not have a protocol'
      return, 0
   endif
   IMAGE_PROTOCOL = strmid(url, 0, prot_pos)
   host_pos = strpos(url, '/', prot_pos+3)
   if (host_pos EQ -1) then begin
      if (NOT keyword_set(silent)) then message, /info, 'URL does not have a path'
      return, 0
   endif
   IMAGE_HOST = strmid(url, prot_pos+3, host_pos-prot_pos-3)
   path_pos = strpos(url, '/', /reverse_search)
   if (path_pos-host_pos EQ 0) then begin
      if (NOT keyword_set(silent)) then message, /info, 'URL does not have a path'
      return, 0
   endif
   IMAGE_PATH = strmid(url, host_pos+1, path_pos-host_pos)
   if (strlen(url) EQ path_pos+1) then begin
      if (NOT keyword_set(silent)) then message, /info, 'URL does not have an image name' 
      return, 0
   endif
   IMAGE_NAME = strmid(url, path_pos+1)

   nv_message, verb=0.5, 'image_protocol = ' + image_protocol
   nv_message, verb=0.5, 'image_host = ' + image_host
   nv_message, verb=0.5, 'image_path = ' + image_path
   nv_message, verb=0.5, 'image_name = ' + image_name

   ; Validate URL
   if ((strcmp(IMAGE_PROTOCOL, 'http', /fold_case) NE 1) AND (strcmp(IMAGE_PROTOCOL, 'https', /fold_case) NE 1)) then begin
      if (NOT keyword_set(silent)) then message, /info, 'Only supports http or https protocol'
      return, 0
   endif
   if (strcmp(IMAGE_HOST, 'pds-imaging.jpl.nasa.gov', /fold_case) NE 1) then begin
      if (NOT keyword_set(silent)) then message, /info, 'Only supports PDS site'
      return, 0
   endif

   ; create a new IDLnetURL object 
   if (!version.release ge '8.4') then oUrl = OBJ_NEW('IDLnetUrl') else $
     oUrl = OBJ_NEW('IDLnetUrl',ssl_certificate_file=getenv('OMINAS_DIR')+path_sep()+'util'+path_sep()+'downloader'+path_sep()+'ca-bundle.crt')

    nv_message, verb=0.5, test_verbose=verbose

  ; Specify the callback function
   if (verbose) then oUrl->SetProperty, CALLBACK_FUNCTION ='Url_Callback'

   ; Set verbose to 1 to see more info on the transacton
   if(verbose) then oUrl->SetProperty, VERBOSE = 1

   ; Set the transfer protocol as http or https
   oUrl->SetProperty, url_scheme = IMAGE_PROTOCOL

   ; The PDS server
   oUrl->SetProperty, URL_HOST = IMAGE_HOST

   ; The top metadata server path of the file to download
   oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/'

   ; Make a request to the PDS image server.
   ; Retrieve general metadata, list of images
   top_metadata_json = oUrl->Get( /STRING_ARRAY )

   ; Print the returned array of strings
   nv_message, verb=0.5, 'TOP_METADATA array of strings returned:'
   for i=0, n_elements(top_metadata_json)-1 do $
      nv_message, verb=0.5, /anonymous, '  ' + top_metadata_json[i]

   top_metadata = json_parse(top_metadata_json)
   nv_message, verb=0.5, 'TOP_METADATA:'
   nv_message, verb=0.5, /anonymous, top_metadata

   nodes = top_metadata['nodes']
   if (n_elements(nodes) NE 1) then begin
      if (NOT keyword_set(silent)) then message, 'Node contains more than one image'
      return, 0
   endif
   nodes = nodes[0]
   node_name = nodes['name']
   if (NOT keyword_set(silent)) then print, 'IMAGE node found, named "' + node_name + '"'

   ; The top metadata server path of image id from node_name
   oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/' + node_name + '/'

   ; Retrieve image metadata, list of images
   image_metadata_json = oUrl->Get( /STRING_ARRAY )

   ; Print the returned array of strings
   nv_message, verb=0.5, 'IMAGE_METADATA array of strings returned:'
   for i=0, n_elements(image_metadata_json)-1 do $
      nv_message, verb=0.5, /anonymous, '  ' + image_metadata_json[i]

   if (n_elements(image_metadata_json) EQ 0) then message, 'No image label found'
   image_metadata = json_parse(image_metadata_json)
   nv_message, verb=0.5, 'IMAGE_METADATA:'
   nv_message, verb=0.5, /anonymous, image_metadata

   ; Get image size
   attributes = image_metadata['attributes']
   image_size = (attributes[0])['value']
   isize = image_size.ToArray(type=3)
   nv_message, verb=0.5, 'Image size = ' + strtrim(isize,2)
   metadata = (attributes[1])['value']
   label = json_serialize(metadata)
   if (isize[2] EQ 1) then dim = isize[0:1] $
   else dim = isize

   ; Get data type (if available using VICAR system label item FORMAT)
   ;dh_w10n_pds_par, label, 'FORMAT', get=image_type
   ;nv_message, verb=0.5, 'FORMAT = ' + image_type
   ;if (image_type EQ 'BYTE') then type = 1
   ;if (image_type EQ 'HALF') then type = 2
   ;if (image_type EQ 'WORD') then type = 2
   ;if (image_type EQ 'FULL') then type = 3
   ;if (image_type EQ 'REAL') then type = 4
   ;if (image_type EQ 'DOUB') then type = 5

   ; Use pixel data request in JSON to get data type
   oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/'+node_name+'/raster/data[0:1,0:1,0:1]?output=json
   data_json = oUrl->Get( /STRING_ARRAY )
   jlab = json_parse(data_json)
   image_type = jlab['type']
   nv_message, verb=0.5, 'type = ' + image_type
   if (image_type EQ 'uint8') then type = 1
   if (image_type EQ 'int16') then type = 2
   if (image_type EQ 'int32') then type = 3
   if (image_type EQ 'float32') then type = 4
   if (image_type EQ 'float64') then type = 5

   if (keyword_set(gif)) then begin

      ; Make a request to the PDS image server.
      ; Retrieve a binary gif image file and write it 
      ; to the local disk's IDL main directory.
      oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/'+node_name+'/image[]?output=gif'

      fn = oUrl->Get(FILENAME = IMAGE_NAME + '.gif')  

      ; Print the path to the file retrieved from the remote server
      if (NOT keyword_set(silent)) then print, 'gif filename written = ', fn

   endif

   ; Make a request for binary data
   if (NOT keyword_set(nodata)) then begin

      big_endian = 1b - (byte(1,0,1))[0]
      data_range = ''
      rsize = isize[0]*isize[1]*isize[2]

      if (keyword_set(sample)) then begin
         ; Check sample
         if(min(sample) LT 0 ) then message, 'Input sample index cannot be negative'
         if(max(sample) GE rsize) then message, 'Input sample index cannot be outside array'
         ; Find range of samples
         fsize = isize[0]*isize[1]
         max_index_x = -1
         min_index_x = isize[0]
         max_index_y = -1
         min_index_y = isize[1] 
         max_index_z = -1
         min_index_z = isize[2] 
         for i = 0, n_elements(sample)-1 do begin
            z = sample[i]/fsize
            y = (sample[i]-z*fsize)/isize[1]
            x = sample[i]-z*fsize-y*isize[0]
            ;print, 'x, y, z = ', x, y, z
            if (z GT max_index_z) then max_index_z = z
            if (z LT min_index_z) then min_index_z = z
            if (y GT max_index_y) then max_index_y = y
            if (y LT min_index_y) then min_index_y = y 
            if (x GT max_index_x) then max_index_x = x
            if (x LT min_index_x) then min_index_x = x
            ;print, 'min/max x = ', min_index_x, max_index_x, '  min/max y = ', min_index_y, max_index_y, $
            ;     '  min/max z = ', min_index_z, max_index_z
         endfor
         x_range = max_index_x - min_index_x + 1
         y_range = max_index_y - min_index_y + 1
         z_range = max_index_z - min_index_z + 1
         data_range = strtrim(string(min_index_x),2) + ':' + strtrim(string(max_index_x+1),2) + ',' + $ 
                      strtrim(string(min_index_y),2) + ':' + strtrim(string(max_index_y+1),2) + ',' + $
                      strtrim(string(min_index_z),2) + ':' + strtrim(string(max_index_z+1),2)
         nv_message, verb=0.5, 'data_range = "' + data_range + '"'

         ; calculate returned samples
         rsize = x_range*y_range*z_range
         i = 0
         returned_samples = make_array(rsize, /long)
         for z=min_index_z, max_index_z do begin
            for y=min_index_y, max_index_y do begin
               for x=min_index_x, max_index_x do begin
                  returned_samples[i] = z*fsize + y*isize[0] + x
                  i = i + 1
               endfor
            endfor
         endfor
      endif

      if (big_endian EQ 1) then $
         oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/'+node_name+'/raster/data['+data_range+']?output=big-endian' $
      else oUrl->SetProperty, URL_PATH = IMAGE_PATH + IMAGE_NAME + '/'+node_name+'/raster/data['+data_range+']?output=little-endian'

      data = oURL->Get( /BUFFER )

      ; Reformat data
      pixels = n_elements(data)
      ; If Byte data
      if (pixels EQ rsize) then begin
         if (NOT keyword_set(sample)) then begin
            if (isize[2] EQ 1) then data = reform(data, isize[0], isize[1], /overwrite) $
            else data = reform(data, isize[0], isize[1], isize[2], /overwrite)
         endif
      endif $
      ; If Half (short) data
      else if (pixels EQ 2*rsize) then begin
         data = reform(data, 2, rsize, /overwrite)
         short_data = fix(data, 0, rsize)
         if (NOT keyword_set(sample)) then begin
            if (isize[2] EQ 1) then data = reform(short_data, isize[0], isize[1], /overwrite) $
            else data = reform(short_data, isize[0], isize[1], isize[2], /overwrite)
         endif
      endif $
      ; If Long data
      else if ((pixels EQ 4*rsize) && (type NE !NULL) && (type EQ 3)) then begin
         data = reform(data, 4, rsize, /overwrite)
         long_data = long(data, 0, rsize)
         if (NOT keyword_set(sample)) then begin
            if (isize[2] EQ 1) then data = reform(long_data, isize[0], isize[1], /overwrite) $
            else data = reform(long_data, isize[0], isize[1], isize[2], /overwrite)
         endif
      endif $
      ; If Real data
      else if ((pixels EQ 4*rsize) && (type NE !NULL) && (type EQ 4)) then begin
         data = reform(data, 4, rsize, /overwrite)
         float_data = float(data, 0, rsize)
         if (NOT keyword_set(sample)) then begin
            if (isize[2] EQ 1) then data = reform(float_data, isize[0], isize[1], /overwrite) $
            else data = reform(float_data, isize[0], isize[1], isize[2], /overwrite)
         endif
      endif $
      ; If double data
      else if ((pixels EQ 8*rsize) && (type NE !NULL) && (type EQ 5)) then begin
         data = reform(data, 8, rsize, /overwrite)
         double_data = double(data, 0, rsize)
         if (NOT keyword_set(sample)) then begin
            if (isize[2] EQ 1) then data = reform(double_data, isize[0], isize[1], /overwrite) $
            else data = reform(double_data, isize[0], isize[1], isize[2], /overwrite)
         endif 
      endif else begin
         ; 4 or 8 byte not supported if type doesn't exist
         n_pix = pixels/isize[0]/isize[1]/isize[2]
         message, 'Type for pixel size of ' + strtrim(string(n_pix),2) + ' is not known, cannot convert'
      endelse

   endif else begin
     data = 0
     if(NOT keyword_set(silent)) then print, '/nodata specified, Not reading image data.'
   endelse

   if (keyword_set(pds)) then begin
 
      ; Read the PDS label (if exists)
      label = ''
      ext_pos = strpos(IMAGE_NAME, '.', /reverse_search)
      extension = strmid(IMAGE_NAME, ext_pos+1)
      pds_ext = ''
      if (strcmp(extension, 'IMG') EQ 1) then pds_ext = 'LBL'
      if (strcmp(extension, 'img') EQ 1) then pds_ext = 'lbl'
      if (strcmp(extension, 'qub') EQ 1) then pds_ext = 'lbl'
      if (strcmp(extension, 'DAT') EQ 1) then pds_ext = 'LBL'

      if (strlen(pds_ext) NE 0) then begin
         LBL_NAME = strmid(IMAGE_NAME, 0, ext_pos+1) + pds_ext

         ; PDS label URL
         oUrl->SetProperty, URL_PATH = IMAGE_PATH + LBL_NAME

         ; Retrieve label file
         label = oUrl->Get( /STRING_ARRAY )

      endif else print, 'PDS label not found'
   endif

   ; Destroy the url object
   OBJ_DESTROY, oUrl

   return, data

END
