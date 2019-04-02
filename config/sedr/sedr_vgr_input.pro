;=============================================================================
;+
; NAME:
;	sedr_vgr_input
;
;
; PURPOSE:
;	Input translator for Voyager images using SEDR database.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = sedr_vgr_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor.
;
;  OUTPUT:
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	j2000:		If set, returned quantites are rotated to j2000
;			reference frame.  Otherwise, results are b1950.
;
;	sedr_source:	String giving the name of the SEDR update source to use.
;			Default is 'SEDR'.
;
;
;  ENVIRONMENT VARIABLES:
;	NV_SEDR_DATA:	Directory containing the SEDR data files.  The 
;			variable should contain a trailing slash.
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; FULL DESCRIPTION:
;
;  The SEDR software is a collection of IDL functions and procedures that
;  allow the software to retrieve Voyager ephemeris data into NV camera,
;  planet and ring descriptors as well as an nv translator to do this when
;  there is no detached header for an image.
;
;
;  DATA
;  ====
;  The SEDR data are in several files and are expected to be in a directory
;  pointed to by the NV_SEDR_DATA environment variable:
;
;      'planet'.sdr2_idl             SEDR2 file
;      'planet'.sdr2_idx             SEDR2 index of sctime
;      'planet'.sdru_idl             SEDRUPD file
;      'planet'.sdru_idx             SEDRUPD index of sctime
;      bodyconst.dat_idl             Body Constants file
;      bodyconst.dat_idx             Body Constants index of Target ID
;
;  where 'planet' is one of jupiter, saturn, uranus or neptune, sctime is
;  the Voyager FDS multiplied by 100, Target ID is the Voyager ID for a
;  body (which is 10*Sat_number + Planet_number).  The *.sdr2_idl files
;  contain records of a structure described by the file SEDR2__DEFINE.PRO,
;  the *.sdru_idl records are described by the file SEDRUPD__DEFINE.PRO and
;  the bodyconst.dat_idl file records are described in BCONS__DEFINE.PRO.
;  The data is in J2000 coordinates, the angles are in degrees (lora is
;  degrees west longitude) and the dimensions are in km.  Each Voyager image
;  has a SEDR2 record which contains predict pointing information.  Some
;  images have updated information.  This is contained in the SEDRUPD records.
;  This will contain new elements to replace those in the SEDR2 record.
;  The source (JPL VICAR program which updated the info) is also listed in
;  the SEDRUPD record as one of 'DAVI', 'NAV ', 'FARE', 'NAV2', 'NEAR', 'AMOS'.
;  There can be more than one update for an image.  The ME-matrix of the
;  SEDRUPD record is already assumed to be one-way Light-travel time corrected
;  while the original SEDR2 value is not.
;
;
;  Create
;  ======
;  In the create subdirectory are procedures and a log file used to create
;  the SEDR data files from the original VMS indexed file counterparts.  To
;  be as simple as possible, the structures in the new files are identical
;  to the original VMS ones execpt in the fact that floats are in XDR format
;  and integers are in Network byte order (big-endian).  This is so that the
;  data files can be platform independent.  The routines sedr_unpack_sedr2, 
;  sedr_unpack_sedrupd and sedr_unpack_bcons are used to convert this format
;  to the host platform integer and floating format.  The files were then
;  ftp'ed in binary format to other platforms.
;
;
;  Usage
;  =====
;  The following procedures and functions are likely to be used by users:
;
;  Procedure                     Purpose
;
;   sedr_list		List sources for a given sctime
;   sedr_read		Read a SEDR2+(SEDRUPD) record into a SEDR2 structure
;   vicar_vgrkey		Returns Voyager keywords from VICAR header
;
;   sedr_vgr_input	Voyager translator returns predict SEDR at B1950
;
;  More information about these routines are in doc_sedr.txt.
;
;
;  The following procedures and functions are likely to be used by programmers:
;
;  Procedure                     Purpose
;
;   bcons__define		Defines Body Constant structure
;   sedr2__define		Defines SEDR structure
;   sedrupd__define		Defines SEDR update structure
;
;   sedr_get_bcons		Reads a BCONS record from a file
;   sedr_get_sedr2		Reads a SEDR2 record from a SDR2 file
;   sedr_get_sedrupd		Reads a SEDRUPD record from a SDRU file
;
;   sedr_unpack_bcons		Unpacks a BCONS record
;   sedr_unpack_sedr2		Unpacks a SEDR2 record
;   sedr_unpack_sedrupd		Unpacks a SEDRUPD record
;
;   sedr_buildcm			Builds C-matrix or ME-matrix from euler angles
;   sedr_time			Converts SEDR time to secs past 1950
;   sedr_to_nv			Converts SEDR C-matrix to NV cam_orient format
;
;   sedr_vgr_cameras		Generates NV camera keywords from SEDR
;   sedr_vgr_planets		Generates NV planet keywords from SEDR
;   sedr_vgr_rings		Generates NV ring keywords from SEDR
;
; MODIFICATION HISTORY:
; 	Written by:	VRH
;	
;-
;=============================================================================
function sedr_vgr_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 common sedr_block, sedr, bconst
 status=0
 n_obj=0


 ;-----------------------------------------------
 ; translator keywords
 ;-----------------------------------------------
 j2000 = dat_keyword_value(dd, 'j2000')
 source = dat_keyword_value(dd, 'sedr_source')


 ;-----------------------------
 ; Check existance of SEDR data
 ;-----------------------------
 sedr_data = getenv('NV_SEDR_DATA')
 if(sedr_data EQ '') then $
    begin
     status = -1
     return, ''
    end


 ;---------------------------------
 ; get sctime and planet and source
 ;---------------------------------
 sctime = long(vicar_vgrkey(dat_header(dd),'SCTIME'))
 planet = vicar_vgrkey(dat_header(dd),'PLANET')
 if(keyword__set(source)) then _source=source $
 else _source = 'SEDR'

 ;---------------------------------------
 ; If needed, get SEDR and Body Constants
 ;---------------------------------------
 sedr = sedr_read(sctime, planet=planet, source=_source)
 _size = size(sedr)
 if(_size[2] NE 8) then $
  begin
   nv_message, 'No SEDR/SEDRUPD match', /con
   status = -1
   return, 0
  end

 print, format='(A,I7,A,A4,A,I3,A,I4)','Read SEDR ',sctime, '   source: ', $
          _source, '    Update: ', sedr.update_day,'/',sedr.update_year
 target_id = sedr.target
 bconst = sedr_get_bcons(target_id)
 _size = size(bconst)
 if(_size[2] NE 8) then $
  begin
   nv_message, 'No Body Constant data for Target', /con
   status = -1
   return, 0
  end


 ;--------------------------
 ; match keyword
 ;--------------------------

 ;-------------------camera keywords--------------------
 if(keyword EQ 'CAM_DESCRIPTORS') then $
   begin

    ;-----------------------------------------
    ; Test if image is Object space ("geomed")
    ;-----------------------------------------
    geom = 0
    if(strpos(dat_header(dd),'GEOM') NE -1) then geom = 1
    if(strpos(dat_header(dd),'FARENC') NE -1) then geom = 1
    if(strpos(dat_header(dd),'*** OBJECT SPACE') NE -1) then geom = 1
    s = size(dat_data(dd))
    ; If size = 1000x1000 assume it's geomed
    if(s[1] EQ 1000 AND s[2] EQ 1000) then geom = 1

    return, sedr_vgr_cameras(dd, sedr, geom, j2000=j2000, $
                            n_obj=n_obj, dim=dim, status=status)
   end

 ;-------------------planet keywords--------------------
 if(keyword EQ 'PLT_DESCRIPTORS') then $
   begin
    planet_pds = sedr_vgr_planets(planet, sedr, j2000=j2000, $
                                        n_obj=n_planets, dim=dim, status=status)

    target_pds = sedr_vgr_targets(sedr, bconst, j2000=j2000, $
                                        n_obj=n_targets, dim=dim, status=status)

    n_obj = n_planets + n_targets 
    return, [target_pds, planet_pds]
   end


 ;-------------------sun keywords--------------------
 if(keyword EQ 'STR_DESCRIPTORS') then $
   begin

    return, sedr_vgr_sun(sedr, bconst, j2000=j2000, $
                                        n_obj=n_obj, dim=dim, status=status)
   end


 status=-1
end
;===========================================================================
