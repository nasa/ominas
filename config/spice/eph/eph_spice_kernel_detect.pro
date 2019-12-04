;=============================================================================
;+
; NAME:
;       eph_spice_kernel_detect
;
;
; PURPOSE:
;       Return filenames of kernels approprate to given time, in correct order
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       files = eph_spice_kernel_detect(dd, kpath, type, sc=sc, time=time ) 
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;       kpath:         Path of the CK files
;
;	type:		Type of kernel: 'c' or 'sp'.
;
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for CK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;  OUTPUT: 
;	files:		Array of CK filenames for use with cspice_furnsh
;
;
; KEYWORDS:
;  INPUT:
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for CK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;	all:		Return all kernels (time not needed in this case)
;	
;	strict:		No function.  Included for consistent interface.
;
;  OUTPUT: NONE
;
;
; PROCEDURE:		Read kernel database
;                       Deterimine kernels that have coverage for given time (or all)
;			Determine which time base to use for ordering: file system, PDS LBL time, or OMINAS timestamp
;                       Return ordered file list
;
; RESTRICTIONS:
;			Leapseconds kernels need to be loaded, SCLK kernels
;			also need to be loaded if type=='c'.
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     V. Haemmerle,  Feb. 2017
;	Addapted by:	J.Spitale      Feb. 2017
;-
;=============================================================================
function eph_spice_kernel_detect, dd, kpath, type, $
               djd=_djd, sc=sc, time=_time, all=all, strict=strict

 if(NOT keyword_set(sc)) then nv_message, 'Spacecraft must be specified.'
 ticks = 0
 if(type EQ 'c') then ticks = 1

 if(keyword_set(_time)) then time = _time
 
 djd = 0d
 if(keyword_set(_djd)) then djd = _djd
 dsec = djd * 86400d 

 if(~keyword_set(all) && ~keyword_set(time)) then begin
    nv_message, name='eph_spice_kernel_detect', 'Must specify /all or time.'
 endif

 ;--------------------------------
 ; Get kernel database 
 ;--------------------------------
 data = eph_spice_build_db(kpath, type)

 ;------------------------
 ; Get appropriate kernels
 ;------------------------
 if(keyword_set(all)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; get all files with valid ranges
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   valid = where(data.first NE -1, count)

   nv_message, verb=0.9, 'Number of valid kernels = ' + strtrim(count,2)
  end $
 else $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; convert ET to sclk ticks
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   before_time = time-dsec
   after_time = time+dsec

   if(keyword_set(ticks)) then $
    begin
     cspice_sce2t, sc, time-dsec, before_time
     cspice_sce2t, sc, time+dsec, after_time
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; get all files with valid ranges that include input time
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   valid = where((data.first LT after_time) AND (data.last GT before_time), nvalid)

   nv_message, verb=0.9, 'Number of valid kernels including given time = ' + strtrim(nvalid,2)
 end

 if(nvalid EQ 0) then return, ''


 ;--------------------------------------------------------------
 ; select files(s)
 ;--------------------------------------------------------------
 data = data[valid] 


 ;---------------------------------------------------
 ; choose best kernel for each body 
 ;---------------------------------------------------
 all_ids = data.id
 ids = unique(all_ids)
 nids = n_elements(ids)
 for i=0, nids-1 do $
  begin
   w = where(all_ids EQ ids[i])
   dat = data[w]

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; first narrow down to shortest kernel interval
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   intervals = dat.last - dat.first
   w = where(intervals EQ min(intervals), nvalid)
   dat = dat[w]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; take the latest of the remaining kernels, based on various 
   ; time stamps:
   ;  If lbltime exists, use that
   ;  If not, try installtime
   ;  If not, use file system time
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(nvalid GT 1) then $
    begin
     times = dat.mtime 

     w = where(dat.installtime NE -1, count)
     if(count GT 0) then times[w] = dat.installtime

     w = where(dat.lbltime NE -1, count)
;;;     if(count GT 0) then times[w] = dat.lbltime
     if(count GT 0) then times[w] = dat[w].lbltime

;     w = where(times NE -1, n)
;     dat = dat[w]
;     times = times[w]

     tmax = max(times, w)
     dat = dat[w]
;print, dat.id, dat.filename
    end

   files = append_array(files, dat.filename)
  end


 return, unique(files)
end
;=============================================================================



