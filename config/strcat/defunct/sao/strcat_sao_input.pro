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
function sao_get_regions, ra1, ra2, dec1, dec2, path_sao=path_sao
 return, file_test(path_sao + '/sao_idl.str') ? path_sao + '/sao_idl.str' : path_sao + '/sao.dat'	; there's only one sao "region"
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
function sao_get_stars, dd, filename, $
         b1950=b1950, ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
         faint=faint, bright=bright, nbright=nbright, $
         names=names, mag=mag, jtime=jtime

 ;---------------------------------------------------------
 ; check whether catalog falls within brightness limits
 ;---------------------------------------------------------
 if(keyword_set(faint)) then if(faint LT -1.5) then return, ''
 if(keyword_set(bright)) then if(bright GT 10) then return, ''

 ;---------------------------------------------------------
 ; For segment testing, need to have limits in b1950 since
 ; star positions in catalog are in b1950
 ; If /b1950 is not specified, then convert range to b1950
 ;---------------------------------------------------------
 _ra1 = ra1
 _ra2 = ra2
 _dec1 = dec1
 _dec2 = dec2
  nv_message, verb=1.0, 'ra1 = '+string(ra1)+' ra2= '+string(ra2)+' dec1= '+string(dec1)+' dec2= '+string(dec2)

 if (NOT keyword_set(b1950)) then $
   begin
     ; If ra1/ra2 is entire range then do not change
     ; declination change is not enough to update
     if (ra1 NE 0. OR ra2 NE 360.) then $
       begin
         nv_message, verb=0.9, 'Converting RA/DEC to B1950 (catalog epoch) for range testing'
         ra_to_xyz, ra1, dec1, pos1
         ra_to_xyz, ra2, dec2, pos2
         pos1_1950 = b1950_to_j2000(pos1,/reverse)
         pos2_1950 = b1950_to_j2000(pos2,/reverse)
         xyz_to_ra, pos1_1950, _ra1, _dec1
         xyz_to_ra, pos2_1950, _ra2, _dec2
         if (_ra1 LT 0) then _ra1 = _ra1 + 360d
         if (_ra2 LT 0 ) then _ra2 = _ra2 + 360d
         nv_message, verb=1.0, 'ra1 = '+string(_ra1)+' ra2= '+string(_ra2)+' dec1= '+string(_dec1)+' dec2= '+string(_dec2)
       end
   end

 _ra1 = _ra1[0] * !dpi/180d
 _ra2 = _ra2[0] * !dpi/180d
 _dec1 = _dec1[0] * !dpi/180d
 _dec2 = _dec2[0] * !dpi/180d

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
 start_segment = 17 - fix((_dec2*!RADEG+90.)/10)
 end_segment = 17 - fix((_dec1*!RADEG+90.)/10)

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
   if(end_record-start_record GT 100 AND _ra1 LE _ra2) then $
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

      index = where(ra_test LE _ra1,count)
      start_record = ra_ptr[0]
      if(count NE 0) then start_record = ra_ptr[count-1]

      end_record = ra_ptr[36]
      index = where(ra_test GE _ra2,count)
      if(count NE 0) then end_record = ra_ptr[37-count]
     end

   nv_message, verb=0.9, 'Search records from ' + string(start_record) + ' to ' + string(end_record)

   _star = replicate({sao_record},end_record-start_record+1)
   for j = start_record, end_record do _star[j-start_record] = record[j]

   nv_message, verb=0.9, '_star contains ' + string(n_elements(_star)) + ' stars'

   ;---------------------------------------------------------
   ; select within magnitude limits
   ;---------------------------------------------------------
   if(keyword__set(faint)) then $
     begin
      _Mag = _star.mag
      byteorder, _Mag, /XDRTOF
      w = where(_Mag LE faint)
      if(w[0] EQ -1) then continue
      _star = _star[w]
     end

   if(keyword__set(bright)) then $
     begin
      _Mag = _star.mag
      byteorder, _Mag, /XDRTOF
      w = where(_Mag GE bright)
      if(w[0] EQ -1) then continue 
      _star = _star[w]
     end

   ;---------------------------------------------------------
   ; Select named stars
   ;---------------------------------------------------------
   if(keyword__set(names)) then $
     begin
      w = where(names EQ STRING(_star.Name))
      if(w[0] EQ -1) then continue
      _star = _star[w]
     end

   ;---------------------------------------------------------
   ; If limits are defined, remove stars that fall outside
   ; the limits. 
   ;---------------------------------------------------------
   _RA = _star[*].RA
   byteorder, _RA, /XDRTOF
   _DEC = _star[*].DEC
   byteorder, _DEC, /XDRTOF

   w = strcat_radec_select([_ra1, _ra2], [_dec1, _dec2], _RA, _DEC)
   if(w[0] EQ -1) then continue 
   _star = _star[w]

   nv_message, verb=0.9, 'After RA/DEC test, _star contains' + string(n_elements(_star)) + ' stars'

   ;---------------------------------------------------------
   ; Unpack the _star array
   ;---------------------------------------------------------
   _RA = _star.RA
   _DEC = _star.DEC
   _DECpm = _star.DECpm
   _RApm = _star.RApm
   _Mag = _star.mag
   _Name = STRING(_star.Name)
   _Sp = STRING(_star.sp)
   byteorder, _RA, /XDRTOF
   byteorder, _DEC, /XDRTOF
   byteorder, _RApm, /XDRTOF
   byteorder, _DECpm, /XDRTOF
   byteorder, _Mag, /XDRTOF

   ;---------------------------------------------------------
   ; Apply proper motion to star (JTIME = years past 1950.0)
   ;---------------------------------------------------------
   _RA = _RA + (double(_RApm)*JTIME/240.D0)*!DTOR 
   _DEC = _DEC + (double(_DECpm)*JTIME/3600.D0)*!DTOR

   ;---------------------------------------------------------
   ; Print out data
   ;---------------------------------------------------------
   nv_message, verb=1.0, '_Name: ' + _Name
   nv_message, verb=1.0, '_RA: ' + string(_RA)
   nv_message, verb=1.0, '_DEC: ' + string(_DEC)
   nv_message, verb=1.0, '_Mag: ' +  string(_Mag)
   nv_message, verb=1.0, '_Sp: ' + _Sp

   ;---------------------------------------------------------
   ; Build arrays
   ;---------------------------------------------------------
   if(first_segment EQ 1) then $
     begin
      first_segment = 0
      RA = _RA
      DEC = _DEC
      Mag = _Mag
      Name = _Name
      Sp = _Sp
     end $
   else $
     begin
      RA = [RA,_RA]
      DEC = [DEC,_DEC]
      Mag = [Mag,_Mag]
      Name = [Name,_Name]
      Sp = [Sp,_Sp]
     end

  end ;segment end

 close, unit
 free_lun, unit

 ;---------------------------------------------------------
 ; If desired, select only nbright brightest stars
 ;---------------------------------------------------------
 if(keyword__set(nbright)) then $
  begin
   w = strcat_nbright(Mag, nbright)
   RA = RA[w]
   DEC = DEC[w]
   Mag = Mag[w]
   Name = Name[w]
   Sp = Sp[w]
  end

 ;---------------------------------------------------------
 ; Fill star descriptors
 ;---------------------------------------------------------
 n = n_elements(Name)

 print, 'Total of ',n,' stars'
 if(n EQ 0) then return, ''

 ;---------------------------------------------------------
 ; Calculate "dummy" properties
 ;---------------------------------------------------------
 orient = make_array(3,3,n)
 _orient = [ [1d,0d,0d], [0d,1d,0d], [0d,0d,1d] ]
 for j = 0 , n-1 do orient[*,*,j] = _orient
 avel = make_array(1,3,n,value=0d)
 vel = make_array(1,3,n,value=0d)
; time = make_array(n,value=(bod_time(ods[0])))
 time = make_array(n,value=0d)
 radii = make_array(3,n,value=1d)
 lora = make_array(n, value=0d)

 ;---------------------------------------------------------
 ; Calculate position vector, use distance as 10 parsec 
 ; to have apparent magnitude = absolute magnitude
 ;---------------------------------------------------------
 dist = 3.085678d+17 ; 10pc in meters
 pos = make_array(3,n,value=0d)
 pos[0,*] = cos(RA)*cos(DEC)*dist
 pos[1,*] = sin(RA)*cos(DEC)*dist
 pos[2,*] = sin(DEC)*dist

 ;---------------------------------------------------------
 ; Precess B1950 to J2000 if wanted
 ;---------------------------------------------------------
 if(NOT keyword__set(b1950)) then pos = transpose(b1950_to_j2000(transpose(pos)))
 pos = reform(pos,1,3,n)

 ;---------------------------------------------------------
 ; Calculate "luminosity" from visual Magnitude
 ; Use Sun as model, though this is wrong for other stars
 ; but since we don't know A (space absorption) and may
 ; only sometimes know Spectral type... what the heck
 ; use formula Mv = 4.83 - 2.5*log(L/Lsun) and since
 ; distance is 10pc mv = Mv
 ;---------------------------------------------------------
 mag = Mag
 Lsun = const_get('Lsun')
 lum = Lsun * 10.d^( (4.83d0-double(Mag))/2.5d )

 _sd = str_create_descriptors( n, $
        gd=make_array(n, val=dd), $
        name=name, $
        orient=orient, $
        avel=avel, $
        pos=pos, $
        vel=vel, $
        time=time, $
        radii=radii, $
        lora=lora, $
        lum=lum, $
        sp=sp )

 return, _sd
end
;===============================================================================




;===============================================================================
;+
; :Private:
; :Hidden:
;-
;===============================================================================
function strcat_sao_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 return, strcat_input(dd, keyword, 'sao', n_obj=n_obj, dim=dim, values=values, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords )

end
;==========================================================================
