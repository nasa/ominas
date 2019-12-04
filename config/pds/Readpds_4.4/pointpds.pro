;------------------------------------------------------------------------------
; NAME: POINTPDS
;
; PURPOSE: To process the pointer to an object in a PDS file
;
; CALLING SEQUENCE: Result = POINTPDS (label, filename, objectname)
;
; INPUTS:
;    Label: String array containing the PDS header
;    Filename: Scalar string containing the name of the PDS file to read
;    objectname: The name of the object to process pointer information for
; OUTPUTS:
;    Result: a structure containing the name of the datafile and the skip
;            offset in bytes
;
; OPTIONAL INPUT: none
;
; EXAMPLES:
;    To obtain information from TABLE.LBL on a TABLE object:
;       IDL> label = HEADPDS ("TABLE.LBL",/SILENT)
;       IDL> pointer = POINTPDS (label, "TABLE.LBL","TABLE")
;       IDL> help, /STRUCTURE, pointer
;            FLAG                      1
;            DATAFILE         "TABLE.TAB"
;            SKIP                   2056
;
; PROCEDURES USED:
;    Functions: PDSPAR, CLEAN, STR2NUM
;
; MODIFICATION HISTORY:
;    Code to look for both uppercase and lowercase
;    datafile name. Parin Choganwala, April 2008
;
;    Code to look into "label" directory for
;    formate file(.FMT). Parin Choganwala, April 2008
;
;    Written by: Puneet Khetarpal [August, 2002]
;    For a complete list of modifications, see changelog.txt file.
;    Modified: P.Choganwala 2008Apr: Enhanced the pointpds to look into 
;                                    label directory for .fmt files
;    Modified: A.Cardesin 2006Jan: Check RECORD_BYTES only if needed
;              A.Cardesin 2005May: Corrected path separator for windows
;------------------------------------------------------------------------------

function pointpds, label, fname, objname
    ; error protection:
    ;on_error, 2

    ; initialize structure:
    pointer = create_struct("flag", 1)    

;Modified A.Cardesin 2006Jan: check RECORD_BYTES only if needed (further down)
;    ; obtain record bytes keyword value:
;    record_bytes = pdspar (label, "RECORD_BYTES", COUNT=recbytescount)
;    if (recbytescount eq 0) then begin
;        print, "Error: missing required RECORD_BYTES keyword."
;        goto, endfun
;    endif

    ; obtain pointer to objname:
    param = "^" + objname
    point = PDSPAR (label, param, COUNT=pointercount)
    if (pointercount eq 0) then begin
        print, "Error: pointer to " + objname + " object missing."
        goto, endfun
    endif

    ; clean and save pointer as backup:
    point = clean(point[0], /space)
    savepoint = point

    ; remove parentheses from string:
    rightp = strpos(point, "(" )
    leftp = strpos(point, ")" )
    if (rightp gt -1 && leftp gt -1) then begin
        rightp += 1
        length = leftp - rightp
        point = strmid(point, rightp, length)
    endif

    ; check for <BYTES> flag and remove it if found:
    rightp = strpos (point, "<BYTES>")
    if (rightp gt -1) then begin
        byte_offset_flag = 1
        point = strmid(point, 0, rightp)
    endif else begin
        byte_offset_flag = 0
    endelse

    ; check for double quotes and extract:
    rightp = strpos (point, '"')
    if (rightp gt -1) then begin
        leftp = strpos (point,'"', rightp + 1)
    endif else begin
        leftp = -1
    endelse

    ; if there was a filename, save it:
    datafile = ""
    if (rightp gt -1 && leftp gt -1) then begin
        rightp += 1
        length = leftp - rightp
        datafile = strmid (point, rightp, length)

        ; remove the file name from the pointer string:
        length = strlen(point) - leftp
        point = strmid (point, leftp + 1, length)
    endif else if (rightp eq -1 xor leftp eq -1) then begin
        print, "Error: badly formatted file pointer " + savepoint
        goto, endfun
    endif
 
    ; obtain bytes_offset or skip bytes:
    rightp = strpos (point, ",")
    if (rightp gt -1) then begin
        rightp += 1
        length = strlen(point)
        point = strmid (point, rightp, length - rightp)
    endif   
    skip = (strlen(point) eq 0) ? 0 : long(str2num(point))

    ; assign the skip bytes for byte offset flag:
    if (~byte_offset_flag && skip ne 0) then begin
;Modified A.Cardesin 2006Jan: check RECORD_BYTES only if needed; ; ; ; ; ; ;
    	; obtain record bytes keyword value:                               ;
    	record_bytes = pdspar (label, "RECORD_BYTES", COUNT=recbytescount) ;
    	if (recbytescount eq 0) then begin                                 ;
           print, "Error: missing required RECORD_BYTES keyword."          ;
           goto, endfun                                                    ;
    	endif                                                              ;
        skip = (skip - 1) * record_bytes[0]
    endif else if (byte_offset_flag && skip ne 0) then begin
        skip -= 1
    endif
    
    if (strupcase(!version.os_name) EQ 'MICROSOFT WINDOWS')then begin
          sep="\\"
          lbl_dir='label\'
    endif else begin
          sep=PATH_SEP()
          lbl_dir='label'+sep
    endelse

    ; if there is a datafile, then check:
    if (strlen(datafile) gt 0) then begin
       ;Modified A.Cardesin 23 May 2005
       ;corrected for Windows, using File_Dirname       
        dir = FILE_DIRNAME(fname,/MARK_DIRECTORY)

;Modification - JAN 2011 - BPrager
	; Changed this section to consolidate all the small fixes into one logical segment of code.
   ; Now the script will check a camel case path (i.e. The path entered by the user explicitely)
   ; and then check for the file in six different ways. Either the file is uppercase or lowercase
   ; and exists in the current folder, is uppercase or lowercase and in a folder 'LABEL/', or in a
   ; folder 'label/'. The script will go back along the path entered by the user to search for the
   ; file.
   err      = -1                             ; Error flag for trying to open a given file
   flag     = 0                              ; Flag to determine if the code should keep looking for the file
   idflag   = 0                              ; Flag to determine if the file was found or not
   CAMpath  = dir                            ; A duplicate of the original path that will be edited as we look through the path
   dirlist  = strsplit(dir,'/',/extract)     ; An array with folder names in path

   if strmid(dir,0,1) EQ '/' then begin
      lead = '/'
   endif else begin
      lead = ''
   endelse 

   while flag eq 0 do begin
      CAM_lc      = CAMpath + strlowcase(datafile)                ; Path for lowercase version of file in current folder
      CAM_uc      = CAMpath + strupcase(datafile)                 ; Path for uppercase version of file in current folder
      CAM_lc_labu = CAMpath + 'LABEL/' + strlowcase(datafile)     ; Path for lowercase version of file in current folder + 'LABEL/'
      CAM_uc_labu = CAMpath + 'LABEL/' + strupcase(datafile)      ; Path for uppercase version of file in current folder + 'LABEL/'
      CAM_lc_labl = CAMpath + 'label/' + strlowcase(datafile)     ; Path for lowercase version of file in current folder + 'label/'
      CAM_uc_labl = CAMpath + 'label/' + strupcase(datafile)      ; Path for uppercase version of file in current folder + 'label/'

      CAMchk_lc      = FILE_TEST(CAM_lc)
      CAMchk_uc      = FILE_TEST(CAM_uc)
      CAMchk_lc_labu = FILE_TEST(CAM_lc_labu)
      CAMchk_uc_labu = FILE_TEST(CAM_uc_labu)
      CAMchk_lc_labl = FILE_TEST(CAM_lc_labl)
      CAMchk_uc_labl = FILE_TEST(CAM_uc_labl)

      if (CAMchk_lc EQ 1) then begin
		   openr,unit, CAM_lc, error = err, /get_lun
		   fname = CAM_lc
         flag = 1
	   endif
      if (CAMchk_uc EQ 1) then begin
		   openr,unit, CAM_uc, error = err, /get_lun
		   fname = CAM_uc
         flag = 1
	   endif
      if (CAMchk_lc_labu EQ 1) then begin
		   openr,unit, CAM_lc_labu, error = err, /get_lun
		   fname = CAM_lc_labu
         flag = 1
	   endif
      if (CAMchk_uc_labu EQ 1) then begin
		   openr,unit, CAM_uc_labu, error = err, /get_lun
		   fname = CAM_uc_labu
         flag = 1
	   endif
      if (CAMchk_lc_labl EQ 1) then begin
		   openr,unit, CAM_lc_labl, error = err, /get_lun
		   fname = CAM_lc_labl
         flag = 1
	   endif
      if (CAMchk_uc_labl EQ 1) then begin
		   openr,unit, CAM_uc_labl, error = err, /get_lun
		   fname = CAM_uc_labl
         flag = 1
	   endif

      if flag eq 0 then begin
         CAMpath = lead

         if n_elements(dirlist) eq 1 then begin
            flag     = 1
            idflag   = 1
         endif else begin
            dirlist = dirlist[0:n_elements(dirlist)-2]            ; Pop off final element from the array for next iteration

            for path_idx=0,n_elements(dirlist)-1,1 do begin
               CAMpath = CAMpath + dirlist[path_idx] + '/'        ; Re-write CAMpath as if the path were promoted by one folder
            endfor
         endelse
      endif
   endwhile


	if (idflag eq 1 and err NE 0) then begin
		message, "Error: Could Not open data file. If possible, move this file to your local directory and try again. It is located under the label directory in the parent data file. The data file that could not be opened:" +dir+datafile
		pointer.flag=-1
		return, pointer
	endif 


    endif else begin
        openr, unit, fname, error = err, /get_lun
        if (err ne 0) then begin
            print, "Error: could not re-open " + fname
            goto, endfun
        endif
    endelse

    close, unit
    free_lun, unit

    ; store pointer information in a structure:
    pointer = create_struct (pointer, "datafile", fname, "skip", skip)      

    return, pointer

    endfun:
        pointer.flag = -1
        return, pointer
end
