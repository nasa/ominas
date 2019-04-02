;===============================================================================
; docformat = 'rst'
;+
;
; Input translator for SAO star catalog.
;
; Usage
; =====
; This routine is called via `dat_get_value`, which is used to read the
; translator table. In particular, the specific translator for the scene
; to be processed should contain the following line::
;
;      -   strcat_sao_input     -       /j2000    # or /b1950 if desired
; 
; For the star catalog translator system to work properly, only one type
; of catalog may be used at a time for a particular instrument.
;
;	The version of the SAO catalog which is expected by this translator is
; the 1984 binary catalog format used by NAV. The star catalog file,
; sao_idl.str, must be kept in the location of the path_sao variable,
; which uses the NV_SAO_DATA environment variable by default.
;	
; In the file, the data is grouped into 18 segments of 10 degrees each.
; Each star has a data record of 36 bytes.  RA (radians), RAMu (pm in 
; sec time/year), DEC (radians), DECMu (pm in sec arc/year), Visual 
; Magnitude, 13-byte Name and 3-byte Spectral type. The first 4 records
; of the output catalog are 18 sets of pointers to the records for the 
; start and end of each segment. The real values (RA, RAMu, DEC, DECMu 
; and Mag) are in XDR.  The pointer integers are in network byte order.
;
; The catalog uses the b1950 epoch, but all coordinates can be precessed
; to J2000 by using the /j2000 keyword.
;
; Restrictions
; ============
; Since the distance to stars are not given in the SAO catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
; :History:
;       Written by:     Vance Haemmerle,  5/1998
;
;       Modified:                         1/1999
;
;       Modified:       Tiscareno,        7/2000
;
;       Modified:       Haemmerle,       12/2000
;
;       Modified:       Spitale,          9/2001
;
;       Modified:       Haemmerle,        7/2017
;
;-
;===============================================================================

;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function sao_get_regions, parm
 return, file_test(parm.path + '/sao_idl.str') ? parm.path + '/sao_idl.str' : parm.path + '/sao.dat'	; there's only one sao "region"
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
; Ingests a set of records from the SAO star catalog and generates star
; descriptors for each star within a specified scene.
;
; :Returns:
;   array of star descriptors
;
; :Params:
;   dd : in, required, type="data descriptor"
;      data descriptor
;   filename : in, required, type=string
;      name of index file, or regions file
;
; :Keywords:
;   b1950 : in, optional, type=string
;      if set, coordinates are output wrt b1950
;   ra1 : in, required, type=double
;      lower bound in right ascension of scene
;   ra2 : in, required, type=double
;      upper bound in right ascension of scene
;   dec1 : in, required, type=double
;      lower bound in declination of scene
;   dec2 : in, required, type=double
;      upper bound in declination of scene
;   faint : in, optional, type=double
;      stars with magnitudes fainter than this will not be returned
;   bright : in, optional, type=double
;      stars with magnitudes brighter than this will not be returned
;   nbright : in, optional, type=double
;      if set, selects only the n brightest stars
;   names : in, optional, type="string array"
;      if set, will return only the stars with the expected names
;   mag : out, required, type=double
;      magnitude of returned stars
;   jtime : in, optional, type=double
;      Years since 1950 (the epoch of catalog) for precession
;      and proper motion correction. If not given, it is taken
;      from the object descriptor bod_time, which is assumed to
;      be seconds past 2000, unless keyword /b1950 is set
;-
;===============================================================================
function sao_get_stars, dd, filename, parm

 names = *parm.names_p

 ;---------------------------------------------------------
 ; check whether catalog falls within brightness limits
 ;---------------------------------------------------------
 if(finite(parm.faint)) then if(parm.faint LT -1.5) then return, ''
 if(finite(parm.bright)) then if(parm.bright GT 10) then return, ''

 ;---------------------------------------------------------
 ; convert to radians
 ;---------------------------------------------------------
 ra1 = parm.ra1 *!dpi/180
 ra2 = parm.ra2 *!dpi/180
 dec1 = parm.dec1 *!dpi/180
 dec2 = parm.dec2 *!dpi/180

 ;---------------------------------------------------------
 ; Open file
 ;---------------------------------------------------------
 ndx_f = file_search(filename)
 if(ndx_f[0] eq '') then $
  begin
   nv_message, 'File does not exist - ' + filename
   return, ''
  end

 openr, unit, filename, /get_lun
 record = assoc(unit,{sao_record})
 pointer = assoc(unit,lonarr(9))

 ;---------------------------------------------------------
 ; Get segment pointers
 ;---------------------------------------------------------
 ptr = lonarr(36)
 ptr=[pointer[0],pointer[1],pointer[2],pointer[3]]
 byteorder, ptr, /ntohl

 ;print, ptr
 ;---------------------------------------------------------
 ; Test validity of segment pointers (test if file is ok)
 ;---------------------------------------------------------
 filesize = (file_info(filename)).size
 nrecs = filesize/n_tags(record, /length)
 w = WHERE(ptr LT 0, count)
 if(count GT 0) then $
   nv_message, 'Segment pointers in file are not valid (< 0), perhaps not binary SAO catalog file:' + filename
 w = WHERE(ptr GT nrecs, count)
 if(count GT 0) then $
   nv_message, 'Segment pointers in file are not valid (>num records), perhaps not binary SAO catalog file:' + filename
 good = 1 
 for i=1, 17 DO if(ptr(2*i)-ptr(2*i-1) NE 1) then good = 0
 if(good EQ 0) then $
   nv_message, 'Segment pointers in file are not valid, perhaps not binary SAO catalog file:' + filename

; find segments
 start_segment = 17 - fix((dec2*!RADEG+90.)/10)
 end_segment = 17 - fix((dec1*!RADEG+90.)/10)
; start_segment = 17 - fix((dec2+90.)/10)
; end_segment = 17 - fix((dec1+90.)/10)

 nv_message, verb=0.9, 'Search segments from ' + string(start_segment) + ' to ' + string(end_segment)

 first_segment = 1
 for i = start_segment, end_segment DO $
  begin
   nv_message, verb=0.9, 'segment is ' + string(i)
   start_record = ptr(2*i)
   end_record = ptr(2*i+1)

   nv_message, verb=0.9, 'Whole segment is ' + string(start_record) + ' to ' + string(end_record)

   ;---------------------------------------------------------
   ; Search within segment to find RA limits
   ;---------------------------------------------------------
   if(end_record-start_record GT 100 AND ra1 LE ra2) then $
     begin
      ra_ptr = ptr(2*i) + lindgen(37)*((ptr(2*i+1)-ptr(2*i))/36)
      ra_ptr[36] = ptr(2*i+1)
      ra_test = fltarr(37)
      for j = 0, 36 do $
       begin
        star = record[ra_ptr[j]]
        ra_test[j] = star.RA
       end
      byteorder, ra_test, /XDRTOF

      index = where(ra_test LE ra1,count)
      start_record = ra_ptr[0]
      if(count NE 0) then start_record = ra_ptr[count-1]

      end_record = ra_ptr[36]
      index = where(ra_test GE ra2,count)
      if(count NE 0) then end_record = ra_ptr[37-count]
     end

   nv_message, verb=0.9, 'Search records from ' + string(start_record) + ' to ' + string(end_record)

   _star = replicate({sao_record},end_record-start_record+1)
   for j = start_record, end_record do _star[j-start_record] = record[j]

   nv_message, verb=0.9, '_star contains ' + string(n_elements(_star)) + ' stars'

   ;---------------------------------------------------------
   ; Convert catalog data format to standardized format
   ;---------------------------------------------------------
   return, strcat_sao_values(_star)

  end

end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_sao_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

;;; SAO catalog is b1950, so the commented line should be correct.  However,
;;; the translator does not function with that setting.
; return, strcat_input(dd, keyword, 'sao', n_obj=n_obj, dim=dim, values=values, status=status, $
 return, strcat_input(dd, keyword, 'sao', 'b1950', n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords )

end
;==========================================================================
