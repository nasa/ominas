;=============================================================================
;+
; NAME:
;	spice_input
;
;
; PURPOSE:
;	Generic NAIF/SPICE input translator core.  This routine is not an 
;	OMINAS input translator; it is intended to be called by an input
;	translator that is taylored to a specific mission. 
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE:
;	result = spice_input(dd, keyword, prefix)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;			The following keywords are recognized:
;
;			'CAM_DESCRIPTORS': The function [prefix]_spice_cameras
;					   Is called.
;
;			'PLT_DESCRIPTORS': The function [prefix]_spice_planets
;					   Is called.
;
;			'STR_DESCRIPTORS': The function [prefix]_spice_sun
;					   Is called.  Only the sun is
;				           recognized.
;
;	prefix:		String giving a prefix to use in constructing the names
;			of the input functions:
;
;			  [prefix]_spice_cameras
;			  [prefix]_spice_planets
;			  [prefix]_spice_sun
;
;			These functions are wrappers that prepare the relevant
;			inputs for a specific mission and call either
;			spice_cameras or spice_planets to obtain the appropriate
;			descriptors.  To obtain sun data, a planet descriptor is
;			obtained from spice_planets and converted to a star
;			descriptor.  See cas_spice_input for an example of how
;			to write such functions.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Camera descriptor.
;
;	key7:		Requested object time.
;
;	key8:		Array of requested object names.  Planets are requested
;			in the order given, except that the primary target body
;			is placed at the front of the list.
;
;  OUTPUT:
;	status:		Zero if valid data is returned.
;
;
;  TRANSLATOR KEYWORDS:
;	ref:		Name of the reference frame for the output quantities.
;			Default is 'j2000'.
;
;	j2000:		/j2000 is equivalent to specifying ref=j2000.
;
;	b1950:		/b1950 is equivalent to specifying ref=b1950.
;
;	klist:		Name of a file giving a list of SPICE kernels to use.
;			If no path is included, the path is taken from the 
;			NV_SPICE_KER environment variable.  Note that this
;			keyword is effective only before any kernels have been
;			loaded or when /reload is specified.  This file 
;			contains a list of file specifications, one per line.  
;			Lines beginning with '#' are ignored.  Kernels may
;			also be selected by image time using the keywords
;			START_TIME, STOP_TIME, and DEFAULT as in the 
;			following example:
;
;
;			$NV_SPICE_SPK/010419_SE_SAT077.bsp
;			$NV_SPICE_CK/051008_051217_s15s16_port3_pa.bc
;
;			START_TIME = 2002-270T10:57:56.870
;			 $NV_SPICE_SPK/000331R_SK_LP0_V1P32.bsp
;			 $NV_SPICE_SPK/010419_SE_SAT077.bsp
;			STOP_TIME = 2002-281T20:57:56.870
;
;			START_TIME = 2002-290T20:57:56.870
;			 $NV_SPICE_SPK/000331R_SK_LP0_V1P32.bsp
;			 $NV_SPICE_SPK/010419_SE_SAT077.bsp
;			STOP_TIME = 2002-291T20:57:56.870
;
;			DEFAULT
;			 $NV_SPICE_SPK/000331R_SK_LP0_V1P32.bsp
;			 $NV_SPICE_SPK/010419_SE_SAT077.bsp-bb
;
;
;			Files appearing before the first START_TIME are always
;			loaded.  If the image time is not covered in a
;			START/STOP_TIME block, then the DEFAULT kernels are
;			loaded.  Keywords must appear at the beginning of
;			the line and DEFAULT must come last.
;
;	<type>_in:	List of input kernels of the given type; e,g, ck_in,
;			spk_in, lsk_in, etc.  List must be delineated by 
;			semimcolons with no space.  The kernel list
;			file is still used, but these kernels take
;			precedence.  Entries in this list may be file
;			specification strings.  On each call, kernels are 
;			loaded and unloaded such that the kernel pool will 
;			consist of the klist kernels and these kernels.  
;			If the value 'auto' is given, then an attempt may be 
;			made to detect the correct kernel file for the given
;			image, depending on the instrument.  Kernels specified 
;			explicitly by name here take precedence over those 
;			determined using the auto-detection.  If a path
;			is specified with 'auto', the kernels that path
;			is used to autodetection instead of the path given
;			by the relevant environment variable.
;
;	reverse:	If set, klist kernels are loaded last, causing them to
;			take precedence.
;
;	<type>_reverse:	If set, the type of kernel will be loaded before
;			the klist, demoting their precedence.
;
;	<type>_strict:	Causes /strict to be passed to the corresponding
;			kernel auto-detection routine.  The behavior 
;			depends on the routine, but typically this will
;			result in fewer kernels being loaded.  
;
;	<type>_all:	Causes /all to be passed to the corresponding
;			kernel auto-detection routine.  The behavior 
;			depends on the routine, but typically this should
;			result in all kernels of the given type being loaded.  
;
;	protect:	Semicolon-delimited list of file specifications.  All
;			kernels matched are left untouched in the kernel pool.
;			If a file specification starts with '!', then only 
;			kernels not matched will be left untouched in the
;			kernel pool.
;
;	reload:		If set, all kernels are unloaded and the current 
;			kernel pool is loaded from scratch.  The interface
;			operates very reliably, but very inefficiently using
;			this option.
;
;	constants:	If set, only kernels containing constants are loaded
;			and only those quantities are filled in.  This keyword 
;			is assumed if there no time is available.
;
;	targets:	Name of text file listing the targets to be requested
;			from the kernel pool.  If not given, the name of the
;			file is taken from the environment variable
;			[prefix]_SPICE_TARGETS.
;
;	nokernels:	If set, the kernel pool will not be modified.
;
;	name:		If given, objects names are taken from this keyword
;			rather than from key8.
;
;	obs:		Name or NAIF ID of observer.  Default is SSB.
;
;	pos:		Get only position information, not pointing.
;
;	strict_priority:If set, previously loaded kernels are uncloded and 
;			reloaded in order to preserve thei priority.  This is
;			potentially very slow.
;
;
; ENVIRONMENT VARIABLES:
;	NV_SPICE_KER:		Directory containing the kernel list file.
;
;	NV_SPICE_<type>:	Directory containing the kernel files specified
;				using <type>_in.  Multiple directories can be
;				delimited using the ':' character.
;
;	[prefix]_SPICE_TARGETS:	Name of optional targets file; see targets
;				keyword.
;
;
; RETURN:
;	Descriptors associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; FULL DESCRIPTION:
;
;  The purpose of the OMINAS SPICE interface is to allow SPICE kernels to be
;  directly read into and written from OMINAS via input and output translators. 
;  Because SPICE kernels are mission-dependent (the exact layout of the C-matrix
;  depends on the camera in question, for example), unique input and output
;  translators must be written for each mission supported.  Translators and
;  supporting routines for each mission reside in subdirectories whose names are
;  abbreviations of the mission name, for example 'cas' or 'gll'. The package
;  described here provides as much generic support for those specific transators
;  as possible.
;
;  The SPICE input translator, SPICE_INPUT, reads all of the SPICE spacecraft
;  and planetary ephemeris data and returns the appropriate descriptors.  The
;  SPICE output translator, SPICE_OUTPUT, currently recognizes only camera
;  descriptors, writing only a C-kernel containing any number of C matrices.
;
;
;  Generic Kernel Detectors
;  ------------------------
;  The fundamental problem in the NAIF/SPICE system is determining which kernels
;  are needed for a given image.  For kernels generated by NAIF, ths is relatively
;  simple, as they adhere to a strict naming convention.  However, project-
;  generated kernels (mainly CK and SPK) reside in a special level of hell where 
;  file names may have any meaning or none at all, may give the coverage dates, 
;  some kind of mission-specific version code, may be generated according to an 
;  algorithm, or may be written by a human operator who may or may not have had 
;  a good day.  Therefore, automatic construction of a kernel pool is not trivial.
;  Indeed, we are not aware that it has ever been accomplished in a generic sense.
;
;  One solution to the problem is to have a separate set of kernel detectors for
;  each mission.  For example, the CAS package has a set of detectors that can 
;  identify kernels based on known Cassini conventions.  However, coding such a 
;  system is often one of the most difficult parts of adding a SPICE translator
;  for a new mission.  Another common solution is to devote human hours to maintining lists of
;  kernels covering various times windows.  This is obviously not desirable.  
;  To address these problems, we have developed an automatic system for
;  generic kernel pool detection.  These detectors are automatically called 
;  if no specific detectors are found for a mission package.
; 
;  Coverage times are specified within the kernel or its detached label, so 
;  determining a set of kernels that covers a given observation is conceptually
;  simple.  In practice, reading the coverage times from every available kernel 
;  file and finding the relevant kernels may take minutes, so we have implemented 
;  a system that catalogs all relevant kernel information into a database that can 
;  be searched quickly (less than a second).  
;
;  Determining the latest version of a kernel is much more difficult because the 
;  SPICE system does not track version information; that information typically
;  is encoded (if at all) in the kernel file name, in a project-specific code.  
;  We attempt to solve this problem by looking at a number of indicators like
;  segment interval lengths, label time stamps, file time stamps, etc.
; 
;  At present, the system functions well, but it needs refinement to produce 
;  the most concise kernel pool.  Mission-specific detectors will always
;  produce the best possible results, but the automatic system is reliably
;  producing useful results without any knowledge of the specifics of a given 
;  mission.  We are currently using this as our default method of building
;  kernel pools.
;  
;
;
;[[needs updating...]]
;
;
;Kernel Databases
;----------------
;
;Stored in the ~/.ominas directory (.ominas directory under
;the users home directory) are two types of kernel databases.
;Camera kernels (CKs) and Spacecraft and Planetary ephemeris
;kernels (SPKs) each have databases specified by directory:
;
;spice_ck_database.<encoded path of ck directory>
;spice_spk_database.<encoded path of spk directory>
;
;The encoded path is the actual path of the kernels
;with interior "/" replaced by "_" to avoid file directory
;structure issues.  The path can include a wildcard, 
;i.e. can span several subdirectories.  In this case the 
;wildcard "*" is replaced by a "x".  When a wildcard is 
;included in a path for kernels, the database contains
;files for all applicable directories.
;
;------------------
;Example:
;
;If SPKs have the following structure...
;
;/user/kernels/cas/spk/ephem
;/user/kernels/cas/spk/tour
;
;One would specify the path as "/user/kernels/cas/spk/*"
;and the database would be
;
;spice_spk_database.user_kernels_cas_spk_x
;
;------------------
;
;The kernel database contains full-path names for all
;files in the kernel path.  It includes the range
;each file covers (ET seconds for SPK, Spacecraft clock
;ticks for CK) for valid kernel files, otherwise they
;contain the value -1.  For each file there is time
;information (if available, -1 if not) about the creation
;date of the file to use in kernel load ordering.  SPICE
;uses later loaded kernels to handle times which are
;defined in multiple kernel files.  The current
;implemetation has three times, the file system time
;returned by the operating system, the creation time
;read from a PDS label file, and a time read from the
;OMINAS installation timestamps file which attemps to
;store the time on the file from the source location.
;
;
;Kernel database creation
;------------------------
;
;The IDL methods to create them are
;
;spice_ck_build_db
;spice_spk_build_db
;
;Each has two arguments, the path of the kernels and
;an optional return of a structure of database contents.
;
;Since the range times stored in the database correspond
;to the internal times in the kernels, no leapsecond
;or sclk kernels are needed to create them.  However,
;the ICY library needs to be installed with dlm_register.
;
;
;Ordered Kernel files
;--------------------
;In order to retrieve an ordered list of kernel files
;to load for the SPICE calculations, two functions exist,
;one for each type of kernel:
;
;files = spice_ck_detect( ckpath, sc=xxx, time=xxx)
;files = spice_spk_detect( kpath, time=xxx )
;
;Both routines accept time as ET seconds as the time
;to use to deterimine kernel coverage.  This means
;that a leapseconds kernel and a sclk kernel needs
;to be loaded for the spice_ck_detect routine.  The
;CK routine also needs the NAIF spacecraft ID.  If
;no files are found an empty string is returned.
;
;Files returned are in order of creation according
;to the following.
;
;Once files are selected by applicability to the time
;input, values for the three different time systems
;are checked.  If PDS Label times exist for all files then
;the PDS Label time is used, if they don't exist for
;all the selected files then OMINAS timestamps are
;used if they exist for all selected files.  If not,
;operating system times are used.
;
;
;
;
; SEE ALSO:
;	spice_output
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================



;=============================================================================
; si_get_kernels
;
;=============================================================================
function si_get_kernels, dd, time, exclusive=exclusive, $
      klist, desc, prefix, inst, name, ext, all, strict, exp=exp, $
      optional=optional

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; first, look for kernel files in the klist
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 kl_in = spice_read_klist(dd, klist, prefix=prefix, inst=inst, /notime, ext=ext)
 if(keyword_set(exclusive)) then if(keyword_set(kl_in)) then return, kl_in

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; otherwise, check for keywords
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 kw_in = spice_kernel_parse(dd, prefix, inst, name, ext=ext, $
                               exp=exp, strict=strict, all=all, time=time)
 if(keyword_set(exclusive)) then if(keyword_set(kw_in)) then return, kw_in

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; concatenate results
 ;  Keyword kernels appear after kernel list kernels, so they take 
 ;  precedence
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 k_in = append_array(kl_in, kw_in)

 if(NOT keyword_set(optional)) then $
   if(NOT keyword_set(k_in)) then nv_message, 'No ' + desc + ' kernels.'

 return, k_in
end
;=============================================================================



;=============================================================================
; si_manage_kernels
;
;=============================================================================
pro si_manage_kernels, dd, prefix=prefix, inst=inst, pos=pos, reload=reload, $
                             constants=constants, time=time, status=status
 status = 0

 inst_prefix = prefix
 if(keyword_set(inst)) then inst_prefix = inst_prefix + '_' + inst

 ;-----------------------------------------------------------------
 ; if data descriptor already has kernel list, load that pool
 ;-----------------------------------------------------------------
 kernel_pool = cor_udata(dd, 'SPICE_KERNEL_POOL')
 if(keyword_set(kernel_pool)) then $
  begin
   spice_load, kernel_pool, /pool
   return
  end

 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------

 ;- - - - - - - - - - - - - - - - - - -
 ; /strict keywords
 ;- - - - - - - - - - - - - - - - - - -
 ck_strict = fix(dat_keyword_value(dd, 'ck_strict'))
 spk_strict = fix(dat_keyword_value(dd, 'spk_strict'))
 pck_strict = fix(dat_keyword_value(dd, 'pck_strict'))
 fk_strict = fix(dat_keyword_value(dd, 'fk_strict'))
 ik_strict = fix(dat_keyword_value(dd, 'ik_strict'))
 sck_strict = fix(dat_keyword_value(dd, 'sck_strict'))
 lsk_strict = fix(dat_keyword_value(dd, 'lsk_strict'))
 xk_strict = fix(dat_keyword_value(dd, 'xk_strict'))

 ;- - - - - - - - - - - - - - - - - - -
 ; /all keywords
 ;- - - - - - - - - - - - - - - - - - -
 ck_all = fix(dat_keyword_value(dd, 'ck_all'))
 spk_all = fix(dat_keyword_value(dd, 'spk_all'))
 pck_all = fix(dat_keyword_value(dd, 'pck_all'))
 fk_all = fix(dat_keyword_value(dd, 'fk_all'))
 ik_all = fix(dat_keyword_value(dd, 'ik_all'))
 sck_all = fix(dat_keyword_value(dd, 'sck_all'))
 lsk_all = fix(dat_keyword_value(dd, 'lsk_all'))
 xk_all = fix(dat_keyword_value(dd, 'xk_all'))

 ;- - - - - - - - - - - - - - - - - - -
 ; reverse keywords
 ;- - - - - - - - - - - - - - - - - - -
 reverse = fix(dat_keyword_value(dd, 'reverse'))

 ck_reverse = fix(dat_keyword_value(dd, 'ck_reverse'))
 spk_reverse = fix(dat_keyword_value(dd, 'spk_reverse'))
 pck_reverse = fix(dat_keyword_value(dd, 'pck_reverse'))
 fk_reverse = fix(dat_keyword_value(dd, 'fk_reverse'))
 ik_reverse = fix(dat_keyword_value(dd, 'ik_reverse'))
 sck_reverse = fix(dat_keyword_value(dd, 'sck_reverse'))
 lsk_reverse = fix(dat_keyword_value(dd, 'lsk_reverse'))
 xk_reverse = fix(dat_keyword_value(dd, 'xk_reverse'))

 ;- - - - - - - - - - - - - - - - - - -
 ; strict_priority
 ;- - - - - - - - - - - - - - - - - - -
 strict_priority = fix(dat_keyword_value(dd, 'strict_priority'))

 ;- - - - - - - - - - - - - - - - - - -
 ; protect keyword
 ;- - - - - - - - - - - - - - - - - - -
 protect = dat_keyword_value(dd, 'protect')


 ;+++++++++++++++++++++++++++++++++++
 ; manage kernel pool
 ;+++++++++++++++++++++++++++++++++++

 ;---------------------------------------------------------------------------
 ; Check for time in dd if not already given.  /string is used to prevent 
 ; lsks from being used since those aren't loaded yet.
 ; If still no time, then assume /constants.
 ;---------------------------------------------------------------------------
 if(NOT defined(time)) then $
  begin
   test = spice_time(dd, prefix=prefix, inst=inst, /string, stat=stat)  
   if(stat NE 0) then constants = 1
  end

 ;---------------------------------------------------------------------------
 ; get the kernel list file
 ;---------------------------------------------------------------------------
 sep = path_sep()

 klist = dat_keyword_value(dd, 'klist')
 if(keyword_set(klist)) then $
  if(strpos(klist, sep) EQ -1) then $
   begin
    kpath = spice_get_kpath('NV_SPICE_KER', klist)
    klist = kpath + sep + klist
   end

 ;---------------------------------------------------------------------------
 ; time-dependent kernels
 ;---------------------------------------------------------------------------
 if(NOT keyword_set(constants)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Handle time (LS and SC) kernels first.
   ;  LS kernels are needed so that times can be compared in the kernel 
   ;   list file.
   ;  SC kernels are needed for the ck and spk auto detect functions
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   lsk_in = si_get_kernels(dd, time, klist, /exclusive, $
     'leap-second', prefix, inst, 'lsk', 'tls', lsk_all, lsk_strict, exp=lsk_exp)

   if(keyword_set(inst)) then $
     sck_in = si_get_kernels(dd, time, klist, /exclusive, $
     'spacecraft clock', prefix, inst, 'sck', 'tsc', sck_all, sck_strict, exp=sck_exp)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; load time kernels if found
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   k_in = lsk_in
   if(keyword_set(sck_in)) then k_in = [k_in, sck_in]

   spice_sort_kernels, k_in, $
     reload=reload, reverse=reverse, protect=protect, $
     lsk_in=lsk_in, lsk_exp=lsk_exp, $
     sck_in=sck_in, sck_exp=sck_exp, $
     kernels_to_load=k_to_load, kernels_to_unload=k_to_unload, $
     lsk_reverse=lsk_reverse, sck_reverse=sck_reverse
   spice_load, k_to_load

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; now that lsks are loaded, we can try to get an ephemeris time
   ; from the data descriptor
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(NOT defined(time)) then time = spice_time(dd, prefix=prefix, inst=inst)
   if(size(time, /type) EQ 7) then time = spice_str2et(time) 

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; other time-dependent kernels
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   fk_in = si_get_kernels(dd, time, klist, /optional, $
       'frame', prefix, inst, 'fk', 'tf', fk_all, fk_strict, exp=fk_exp)

   if(NOT keyword_set(pos) AND (NOT keyword_set(od))) then $
     ck_in = si_get_kernels(dd, time, klist, /optional, $
       'C', prefix, inst, 'ck', 'bc', ck_all, ck_strict, exp=ck_exp)

   spk_in = si_get_kernels(dd, time, klist, $
       'SP', prefix, inst, 'spk', 'bsp', spk_all, spk_strict, exp=spk_exp)
  end

 ;---------------------------------------------------------------------------
 ; time-independent kernels
 ;---------------------------------------------------------------------------
 pck_in = si_get_kernels(dd, time, klist, $
       'PC', prefix, inst, 'pck', 'tpc', pck_all, pck_strict, exp=pck_exp)

 if(keyword_set(inst)) then $
    ik_in = si_get_kernels(dd, time, klist, /optional, $
       'instrument', prefix, inst, 'ik', 'ti', ik_all, ik_strict, exp=ik_exp)

 ;---------------------------------------------------------------------------
 ; extra kernels; keyword-only
 ;---------------------------------------------------------------------------
 xk_in = spice_kernel_parse(dd, prefix, inst, 'xk', $
		  exp=xk_exp, strict=xk_strict, all=xk_all, time=time)


 ;-----------------------------------------------------------------
 ; Determine kernels to load / unload.  If no kernels specified, 
 ; the pool is left untouched.
 ;-----------------------------------------------------------------
 spice_sort_kernels, $
   reload=reload, reverse=reverse, protect=protect, $
   ck_in=ck_in, spk_in=spk_in, pck_in=pck_in, $
   fk_in=fk_in, ik_in=ik_in, sck_in=sck_in, lsk_in=lsk_in, xk_in=xk_in, $
   ck_exp=ck_exp, spk_exp=spk_exp, pck_exp=pck_exp, $
   fk_exp=fk_exp, ik_exp=ik_exp, sck_exp=sck_exp, lsk_exp=lsk_exp, xk_exp=xk_exp, $
   kernels_to_load=kernels_to_load, kernels_to_unload=kernels_to_unload, $
   ck_reverse=ck_reverse, spk_reverse=spk_reverse, pck_reverse=pck_reverse, $
   fk_reverse=fk_reverse, ik_reverse=ik_reverse, sck_reverse=sck_reverse, $
   lsk_reverse=lsk_reverse, xk_reverse=xk_reverse, strict_priority=strict_priority

 ;+++++++++++++++++++++++++++++++
 ; load/unload kernels
 ;+++++++++++++++++++++++++++++++
 spice_load, kernels_to_load, uk_in=kernels_to_unload
; spice_cull


 ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ; Save kernel pool for this data descriptor
 ;  This is commented out because it leads to huge kernel pools for 
 ;  unknown reasons.  If it wrked, it would proabably save some time.
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; kernel_pool = cor_udata(dd, 'SPICE_KERNEL_POOL')
; if(NOT keyword_set(kernel_pool)) then $
;  begin
;   loaded_kernels = spice_loaded(/full)
;   if(keyword_set(loaded_kernels)) then $
;             cor_set_udata, dd, 'SPICE_KERNEL_POOL', loaded_kernels
;  end


end
;=============================================================================



;=============================================================================
; si_get
;
;=============================================================================
function si_get, dd, keyword, prefix, inst, od=od, time=__time, names=names, status=status

 if(keyword_set(__time)) then time = __time

 inst_prefix = prefix
 if(keyword_set(inst)) then inst_prefix = inst_prefix + '_' + inst

 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------

 ;- - - - - - - - - - - - - - - - - - -
 ; obs
 ;- - - - - - - - - - - - - - - - - - -
 obs = dat_keyword_value(dd, 'obs')
 if(str_isnum(obs) EQ 0) then obs = long(obs)

 ;- - - - - - - - - - - - - - - - - - -
 ; pos
 ;- - - - - - - - - - - - - - - - - - -
 pos = dat_keyword_value(dd, 'pos')

 ;- - - - - - - - - - - - - - - - - - -
 ; ref
 ;- - - - - - - - - - - - - - - - - - -
 ref = dat_keyword_value(dd, 'ref')
 if(NOT keyword_set(ref)) then ref = 'j2000'

 ;- - - - - - - - - - - - - - - - - - -
 ; j2000
 ;- - - - - - - - - - - - - - - - - - -
 j2000 = fix(dat_keyword_value(dd, 'j2000'))
 if(keyword_set(j2000)) then ref = 'j2000'

 ;- - - - - - - - - - - - - - - - - - -
 ; b1950
 ;- - - - - - - - - - - - - - - - - - -
 b1950 = fix(dat_keyword_value(dd, 'b1950'))
 if(keyword_set(b1950)) then ref = 'b1950'

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; reload
 ;  Force /reload if this call has a different prefix than the last one.
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 reload = fix(dat_keyword_value(dd, 'reload'))
 if(keyword_set(last_prefix)) then if(prefix NE last_prefix) then reload = 1
 last_prefix = prefix

 ;- - - - - - - - - - - - - - - - - - -
 ; constants
 ;- - - - - - - - - - - - - - - - - - -
 constants = fix(dat_keyword_value(dd, 'constants'))
 if(keyword_set(constants)) then time = -1		; this doesn't seem right

 ;- - - - - - - - - - - - - - - - - - -
 ; name
 ;- - - - - - - - - - - - - - - - - - -
 name = dat_keyword_value(dd, 'name')
 if(keyword_set(name)) then names = name

 ;- - - - - - - - - - - - - - - - - - -
 ; time
 ;- - - - - - - - - - - - - - - - - - -
 _time = dat_keyword_value(dd, 'time')
 if(defined(_time)) then $
  begin
   if(keyword_set(_time)) then time = _time $
   else if((size(_time, /type) NE 7)) then time = _time
  end

 ;- - - - - - - - - - - - - - - - - - -
 ; nokernels
 ;- - - - - - - - - - - - - - - - - - -
 nokernels = fix(dat_keyword_value(dd, 'nokernels'))

 ;- - - - - - - - - - - - - - - - - - -
 ; targets
 ;- - - - - - - - - - - - - - - - - - -
 targ_list = dat_keyword_value(dd, 'targets')
 if(NOT keyword_set(targ_list)) then $
  begin
   var = strupcase(prefix) + '_SPICE_TARGETS'
   targ_list = getenv(var)
  end 


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; get time if needed
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 if((NOT keyword_set(time)) AND keyword_set(od)) then $
  begin
   if(NOT cor_isa(od, 'BODY')) then $
    begin
     status = -1
     return, 0
    end
   time = bod_time(od)
  end


 ;---------------------------------------------------------------
 ; manage kernels unless /nokernels
 ;---------------------------------------------------------------
 if(NOT keyword_set(nokernels)) then $
     si_manage_kernels, dd, prefix=prefix, inst=inst, pos=pos, reload=reload, $
                                 constants=constants, time=time, status=status
 if(status NE 0) then return, !null


 if(defined(time)) then $
         if(size(time, /type) EQ 7) then time = spice_str2et(time)


 ;--------------------------
 ; match keyword
 ;--------------------------
 case keyword of
  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; CAM_DESCRIPTORS
  ;  Construct a descriptor for the relevant camera.
  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  'CAM_DESCRIPTORS': $
	result = call_function(inst_prefix + '_spice_cameras', time=time, pos=pos, $
                      constants=constants, dd, ref, n_obj=n_obj, dim=dim, $
                      status=status, orient=orient, obs=obs)

  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; PLT_DESCRIPTORS
  ;  Construct descriptors for all planets, or for those requested.  
  ;  Although the SUN is returned by NAIFLIB, it is not returned
  ;  here unless specifically requested.
  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  'PLT_DESCRIPTORS': $
	begin
         names0 = ''
         if(keyword_set(names)) then names0 = names
	 result = call_function(inst_prefix + '_spice_planets', dd, ref, $
                     time=time, targ_list=targ_list, constants=constants, $
	             n_obj=n_obj, dim=dim, status=status, planets=names, obs=obs)
	 if(NOT keyword_set(result)) then status = -1 $
	 else if((where(names0 EQ 'SUN'))[0] EQ -1) then $
	  begin
	   names = cor_name(result)
  	   w = where(strupcase(names) EQ 'SUN')
	   if(w[0] NE -1) then $
            begin
             result = rm_list_item(result, w[0], only=nv_ptr_new())
             n_obj = n_obj - 1
            end
	  end
	end

  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; STR_DESCRIPTORS
  ;  Construct descriptors for all stars.  The only star that would be 
  ;  returned by NAIFLIB is the sun.
  ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  'STR_DESCRIPTORS': $
	begin
         if(keyword_set(key8)) then $
          begin
           w = where(strpos(strupcase(key8), 'SUN') NE -1)
           if(w[0] EQ -1) then $
            begin
	     status = -1
	     result = 0
            end
          end 

	 if(status NE -1) then $
                result = call_function(inst_prefix + '_spice_sun', dd, ref, $
	                       time=time, constants=constants, $
	                       n_obj=n_obj, dim=dim, status=status, obs=obs)
	end

  else: $
	begin
	 status = -1
	 result = 0
	end
 endcase

 if(NOT keyword_set(result)) then status = -1
	

 return, result
end
;=============================================================================



;=============================================================================
; spice_input
;
;=============================================================================
function spice_input, dd, keyword, prefix, inst, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords
common spice_input_block, last_prefix

 status = 0
 n_obj = 0
 dim = [1]

 ndd = n_elements(dd)

 if((keyword NE ('CAM_DESCRIPTORS')) AND $
    (keyword NE ('PLT_DESCRIPTORS')) AND $
    (keyword NE ('STR_DESCRIPTORS'))) then $
  begin
   status = -1
   return, 0
  end

 if(NOT spice_test()) then $
  begin
   nv_message, /con, $
     'Aborting because the NAIF/SPICE interface is not installed.'
   status = -1
   return, 0
  end


 ;------------------------------------------------------------
 ; primary planet descriptors (key4) must not be present
 ;------------------------------------------------------------
 if(keyword_set(key4)) then $
  begin
   status = -1
   return, 0
  end

 ;-----------------------------------------------
 ; observer descriptor passed as key1
 ;-----------------------------------------------
 if(keyword_set(key1)) then od = key1
 if(keyword_set(od) AND (keyword EQ 'CAM_DESCRIPTORS')) then $
  begin
   status = -1
   return, 0
  end
 if(NOT keyword_set(od)) then od = bytarr(ndd)

 ;-----------------------------------------------
 ; default orientation passed as key3
 ;-----------------------------------------------
 if(keyword_set(key3)) then orient = key3
 
 ;-----------------------------------------------
 ; object times passed as key7
 ;-----------------------------------------------
 if(defined(key7)) then $
  begin
   if(size(key7, /type) NE 7) then time = key7 $
   else if(keyword_set(key7)) then time = key7
  end
 if(n_elements(time) EQ 1) then time = make_array(ndd, val=time[0])

 ;-----------------------------------------------
 ; object names passed as key8
 ;-----------------------------------------------
 if(keyword_set(key8)) then names = key8


 ;-----------------------------------------------
 ; get descriptors for each dd
 ;-----------------------------------------------
 for i=0, ndd-1 do $
  begin
   if(defined(time)) then _time = time[i]

   result = append_array(result, si_get(dd[i], $
                      keyword, prefix, inst, od=od[i], $
                        time=_time, names=names, status=status))
  end

 return, result
end
;===========================================================================
