;===============================================================================
; docformat = 'rst'
;+
; Input translator for GSC star catalog.
;
; Returns
; =======
;   Star descriptor containing all the stars found.  The Sp part of
;   the star descriptor does not contain the Spectral type since this
;   is not available.  Instead it contains the GSC class of the object::
;    0 - star
;    1 - galaxy
;    2 - blend or member of incorrectly resolved blend.
;    3 - non-star
;    5 - potential artifact
;
;   (Note that code 1 is used only for a few  hand-entered errata;
;   galaxies successfully processed by the software have a 
;   classification of 3 [non-stellar].  Also code 4 is never used.)  
;
; Restrictions
; ============
;
; Since the distance to stars are not given in the GSC catalog, the
; position vector magnitude is set as 10 parsec and the luminosity
; is calculated from the visual magnitude and the 10 parsec distance.
;
;	This translator does not correct for proper motion.
;
;
; Procedure
; =========
;
; Stars are found in a square area in RA and DEC around a given
; or calculated center.  The star descriptor is filled with stars
; that fit in this area.  If B1950 is selected, input ods orient 
; matrix is assumed to be B1950 also, if not, input is assumed to be
; J2000, like the catalog.  
;
; :Private:
;
; :Categories:
;   nv, config
;
; :History:
;    Written by:     Vance Haemmerle, 3/2000 (pg_get_stars_gsc.pro)
;
;    Modified:       Spitale 9/2001 - changed to strcat_gsc_input.pro
;
;    Modified:       Vance Haemmerle, 9/2017 - changed to compressed GSC format
;
;-
;===============================================================================


;===============================================================================
;+
; :Private:
; :Hidden:
;
; gsc_fzone:  Determine the Declination zone of a GSC region
;-
;===============================================================================
function gsc_fzone, declow, dechi

  dec = (declow + dechi) / 2.0
  zone = fix (dec / (90./12.)) + 1
  if (dec lt 0) then begin
    zone = (12 + 2) - zone
  endif

  return, zone
end
;===============================================================================




;==============================================================================
;+
; :Private:
; :Hidden:
;
; gsc_initzd: Initialize GSC directory names
;-
;==============================================================================
pro gsc_initzd, zdir

  zdir(0)  = 'N0000'
  zdir(1)  = 'N0730'
  zdir(2)  = 'N1500'
  zdir(3)  = 'N2230'
  zdir(4)  = 'N3000'
  zdir(5)  = 'N3730'
  zdir(6)  = 'N4500'
  zdir(7)  = 'N5230'
  zdir(8)  = 'N6000'
  zdir(9)  = 'N6730'
  zdir(10) = 'N7500'
  zdir(11) = 'N8230'

  zdir(12) = 'S0000'
  zdir(13) = 'S0730'
  zdir(14) = 'S1500'
  zdir(15) = 'S2230'
  zdir(16) = 'S3000'
  zdir(17) = 'S3730'
  zdir(18) = 'S4500'
  zdir(19) = 'S5230'
  zdir(20) = 'S6000'
  zdir(21) = 'S6730'
  zdir(22) = 'S7500'
  zdir(23) = 'S8230'
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;
; Read GSC regions.dat database (collection of file headers)
; gsc_unit an IDL file unit number
;-
;===============================================================================
function gsc_read_regions, gsc_unit

 temp = make_array(80,value=32b)
 stemp = string(temp)
 int_val = 0
 dbl_val = double(0)
 region = {gsc_region}

 while ~EOF(gsc_unit) do begin
   readf, gsc_unit, stemp
   values = STRSPLIT(stemp, /EXTRACT)
   reads, values(2), int_val
   region.REG_NO = int_val
   reads, values(4), dbl_val
   region.RA_LOW = dbl_val
   reads, values(5), dbl_val
   region.RA_HI = dbl_val
   reads, values(6), dbl_val
   region.DEC_LO = dbl_val
   reads, values(7), dbl_val
   region.DEC_HI = dbl_val
   if (gsc_region_table EQ !NULL) then gsc_region_table = region $
   else gsc_region_table = [gsc_region_table, region]
 endwhile

 return, gsc_region_table
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;
; Given a GSC region filename, read the header
; gsc_unit is IDL file unit number
;-
;===============================================================================
function gsc_read_header, gsc_unit

 point_lun, gsc_unit, 0
 header = {gsc_header}

 temp = make_array(256,value=32b)
 stemp = string(temp)
 readf, gsc_unit, stemp
 point_lun, gsc_unit, 0

 int_val = 0
 dbl_val = double(0)

 values = STRSPLIT(stemp, /EXTRACT)
 reads, values(0), int_val
 header.LEN = int_val
 reads, values(1), int_val
 header.VERS = int_val
 reads, values(2), int_val
 header.REGION = int_val
 reads, values(3), int_val
 header.NOBJ = int_val
 reads, values(4), dbl_val
 header.AMIN = dbl_val
 reads, values(5), dbl_val
 header.AMAX = dbl_val
 reads, values(6), dbl_val
 header.DMIN = dbl_val
 reads, values(7), dbl_val
 header.DMAX = dbl_val
 reads, values(8), dbl_val
 header.MAGOFF = dbl_val
 reads, values(9), dbl_val
 header.SCALE_RA = dbl_val
 reads, values(10), dbl_val
 header.SCALE_DEC = dbl_val
 reads, values(11), dbl_val
 header.SCALE_POS = dbl_val
 reads, values(12), dbl_val
 header.SCALE_MAG = dbl_val
 reads, values(13), int_val
 header.NPL = int_val
 header.LIST = values(14)
 for i = 15, n_elements(values)-1 DO header.LIST = header.LIST + ' ' + values(i) 

 return, header
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;
; Given a GSC region filename, read the stars
; gsc_unit is IDL file unit number
;-
;===============================================================================
function gsc_read_stars, gsc_unit

 header = gsc_read_header(gsc_unit)
 nstars = header.nobj
 stars = replicate({gsc_record},nstars)

 point_lun, gsc_unit, header.len
 data = bytarr(12)

 FOR i = 0, nstars-1 DO BEGIN
   readu, gsc_unit, data
   ; Decode GSC_ID, 15 bits (documentation says 14), data 0, 1
   part1 = data(0) MOD 127
   stars(i).GSC_ID = part1*2^7 + data(1)/2

   ; Decode RA, 22 bits, data 1, 2, 3, 4
   part1 = data(1) AND 1
   RA = LONG(part1)*(LONG(2)^21) + LONG(data(2))*(LONG(2)^13) + LONG(data(3))*2^5 + LONG(data(4))/2^3
   stars(i).RA_DEG = RA/header.SCALE_RA + header.AMIN
   if (stars(i).RA_DEG LT 0.) then stars(i).RA_DEG = stars(i).RA_DEG + 360.
   if (stars(i).RA_DEG GE 360.) then stars(i).RA_DEG = stars(i).RA_DEG - 360.

   ; Decode DEC, 19 bits, data, 4, 5, 6
   part1 = data(4) AND 7
   DEC = LONG(part1)*(LONG(2)^16) + LONG(data(5))*2^8 + LONG(data(6))
   stars(i).DEC_DEG = DEC/header.SCALE_DEC + header.DMIN

   ; Pos-error 9 bits, data 7, 8
   ; mag-error 7 bits, data 8
   ; Decode magnitude, data 9, 10
   MAG = data(9)*2^3 + data(10)/2^5
   stars(i).MAG = MAG/header.SCALE_MAG + header.MAGOFF

   ; mag-band 4 bits, data 10
   ; multiple 1 bit, data 10
   stars(i).MULTIPLE = data(10) AND 1
   ; Decode class 3 bits, data 11
   part1 = data(11)/2^4
   stars(i).CLASS = part1 MOD 7

   ; plate-id 4 bits, data 11

 ENDFOR

 return, stars
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;
; Given a GSC region star records, average the duplicates 
; records is an array of GSC star records, MULTIPLE indicates muliples 
;-
;===============================================================================
function gsc_remove_dups, records

 ; Find unique IDs
 w = WHERE(records.MULTIPLE EQ 0, count)
 if(count NE 0) then stars = records[w]

 ; Find duplicates
 w = WHERE(records.MULTIPLE EQ 1, count)
 if(count EQ 0) then return, stars
 dups = records[w]

 ; Find unique IDs
 w = uniq(dups.GSC_ID, sort(dups.GSC_ID))
 ids = dups[w].GSC_ID

 FOR i = 0, n_elements(ids)-1 DO BEGIN
   new_record = {gsc_record}
   entry = WHERE(dups.GSC_ID EQ ids[i], count)
   new_record.GSC_ID = ids[i]
   new_record.CLASS = dups(entry(0)).CLASS
   new_record.RA_DEG = total(dups(entry).RA_DEG)/n_elements(entry)
   new_record.DEC_DEG = total(dups(entry).DEC_DEG)/n_elements(entry)
   new_record.MAG = total(dups(entry).MAG)/n_elements(entry) 
   new_record.MULTIPLE = 1
   if(stars EQ !NULL) then stars = new_record $
   else stars = [stars, new_record]
 ENDFOR

 return, stars
end
;===============================================================================




;==============================================================================
;+
; :Private:
; :Hidden:
;
; Search the index table to find the region identifiers whose coordinate
; limits overlap the specified field. Save list of paths to gsc files for
; these regions.
;-
;==============================================================================
function gsc_get_regions, parm

  ; Initialize the directory name for each zone
  zdir = strarr(24)
  gsc_initzd, zdir
  rows = 9537
  num_regions = 0

  if(NOT keyword__set(parm.path)) then parm.path = getenv('NV_GSC_DATA')
  region_file = parm.path + "/" + "regions.dat"
  if(!VERSION.OS eq 'vms') then $
   begin
    len = strlen(parm.path)
    lastchar = strmid(parm.path,len-1,1)
    if(lastchar eq ']' or lastchar eq ':') then $
      region_file = parm.path + "regions.index"
    if(lastchar eq '.') then region_file = $
     strmid(parm.path,0,len-1) + "]" + "regions.dat"
   end

  get_lun, lun
  openr, lun, region_file
  gsc_region_table = gsc_read_regions(lun)

  region_list = ''
  for row = 0, rows-1 do begin
    ; For each row in the gsc_region_table
    region_table = gsc_region_table[row]

    ; Declination range of the GS region
    ; Note:  southern dechi and declow are reversed
    dechi = region_table.DEC_HI

    if (dechi gt 0 and dechi lt parm.dec1) then begin
      goto,next
    endif else if (dechi lt 0 and dechi gt parm.dec2) then begin
      goto,next
    endif

    ; Limit of GS region closer to equator
    declow = region_table.DEC_LO

    if (declow gt 0) then begin
      ; North
      if (declow gt parm.dec2) then goto,next
    endif else if (declow lt 0) then  begin
      ; South
      if (declow le parm.dec1) then goto, next
    endif else begin
      ; Lower limit of GS region ON equator
      if (dechi gt 0) then begin
        ; North
        if (dechi lt parm.dec1 or declow gt parm.dec2) then goto, next
      endif else if (dechi < 0) then begin
        ; South
        if (dechi gt parm.dec2 or declow lt parm.dec1) then goto, next
      endif
    endelse

    ; Right ascension range of the GS region
    if (parm.ra1 lt parm.ra2) then begin
      ; 0 R.A. not in region

      ralow = region_table.RA_LOW
      if (ralow gt parm.ra2) then goto, next

      rahi = region_table.RA_HI
      if (ralow gt rahi) then rahi = rahi + 360.0
      if (rahi lt parm.ra1) then goto, next

    endif else begin

      ; 0 R.A. in region
      ralow = region_table.RA_LOW
      rahi = region_table.RA_HI

      if (ralow gt rahi) then rahi = rahi + 360.0
      if (ralow gt parm.ra2 and rahi lt parm.ra1) then goto, next

    endelse

    ; Region number
    regnum = region_table.REG_NO

    ; Zone number => directory name
    zone = gsc_fzone (declow, dechi)

    ; Build the file name
    root = string(format='(i4.4,".GSC")',regnum)

    path = string(format='(a,"/",a,"/")',parm.path,zdir(zone-1))
    if(!VERSION.OS eq 'vms') then $
     begin
      len = strlen(parm.path)
      lastchar = strmid(parm.path,len-1,1)
      if(lastchar eq ']') then path = $
       strmid(parm.path,0,len-1) + "." + zdir(zone-1) + "]"
      if(lastchar eq ':') then path = $
       parm.path + "[" + zdir(zone-1) + "]"
      if(lastchar eq '.') then path = $
       parm.path + zdir(zone-1) + "]"
     end

    if(num_regions eq 0) then region_list = path+root $
    else region_list = [region_list, path+root]
    num_regions = num_regions + 1

next: a = 1
  endfor

 close, lun
 free_lun, lun
 return, region_list
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;
; Given a GSC region filename, load the stars that fit within
; region (ra1 - ra2) and (dec1 - dec2) into a star descriptor.
;-
;===============================================================================
function gsc_get_stars, dd, filename, parm
       
 names = *parm.names_p

 f = findfile(filename)
 if(f[0] eq '') then $
  begin
   print, 'gsc_get_stars: File does not exist - ',filename
   return, ''
  end

 ;----------------------------------------------
 ; Open file, expected name ends with "nnnn.GSC"
 ; where nnnn is the gsc region
 ;----------------------------------------------
 start = strpos(filename,'.GSC') - 4
 gsc_region = strmid(filename,start,4)
 openr, gsc_unit, filename, /get_lun
 records = gsc_read_stars(gsc_unit)
 close, gsc_unit
 free_lun, gsc_unit
 stars = gsc_remove_dups(records)
 nstars = n_elements(stars)


 ;---------------------------------------------------------
 ; Convert catalog data format to standardized format
 ;---------------------------------------------------------
 return, strcat_gsc_values(stars)
end
;=============================================================================



;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_gsc_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords


 return, strcat_input(dd, keyword, 'gsc', n_obj=n_obj, dim=dim, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords )

end
;=============================================================================



