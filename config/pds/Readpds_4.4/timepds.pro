;+
; NAME:
;	TIMEPDS
;
; PURPOSE:
;	To extract time from a PDS label or ASCII table, express it as
;	either Julian Date, decimal day of year, or decimal day from some
;	specific user-specified date.  Then to store the date in an IDL
;	variable.
;
; CALLING SEQUENCE:
;	Result = TIMEPDS(label, month, day, [/doy, /jd])
;
; INPUTS:
;       LABEL = IDL string array containing the PDS label associated with
;       the file.  First use HEADPDS.PRO to retrieve the label.
;
;       MONTH = Month from which to start counting.  If either /doy or /jd
;       are set, month should not be specified.
;
;       DAY = Day from which to start counting.  If either /doy or /jd are
;       set, day should not be specified.
;
; OUTPUTS:
;       If the PDS file is a PDS IMAGE:
;          If no optional keywords are present or if /doy is present:
;	      Result = Single precision floating point scalar
;          If /jd is present:
;             Result = Double precision floating point scalar for /jd
;       If the file is a PDS ASCII table:
;          If no optional keywords are present or if /doy is set:
;             Result = Single precision floating point array
;          If /jd is present:
;             Result = Double precision floating point array for /jd
;
; OPTIONAL INPUT KEYWORDS:
;	DOY - If present and non zero, then the output will be the decimal
;             day of year of the observation.
;
;	JD - If present and non zero, then the output will be the Julian date
;            of the observation.
;
; EXAMPLE:
;	Read a PDS label associated with an image to get the day of year of 
;       the observation:
;
;               IDL> LABEL = HEADPDS('TEST.LBL')
;		IDL> doy = TIMEPDS(LABEL, /DOY)
;
;       Obtain an array of decimal dates counting from January 22 using values
;	from a PDS ASCII index table:
;
;               IDL> LABEL = HEADPDS('INDEX.LBL')
;               IDL> cu_arr = TIMEPDS(LABEL, 1, 22)
;
; WARNINGS:
;       The default setting, with no keywords set, is to give the date(s) as
;       decimal day counting from the user-specified 'month' and 'day' values,
;       whereas if /doy is set, counting begins on 0 January.
;
;       When present and non-zero, the optional keyword /doy or /jd 
;       should take the place of the keywords, 'month' and 'day'.
;
;       TIMEPDS requires at least a date to be present in the PDS label or
;       table.  An error will occur if there is a time but no date.
;
; PROCEDURES USED:
;	Functions:  PDSPAR, TASCPDS
;
; MODIFICATION HISTORY:
;	July 27 1999, M. Barker
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;	define function that calculates julian date:
;------------------------------------------------------------------------------

function JDATE, yyyy_start, mm_start, dd_start, time

;	We subtract .5 from the julian date because we want the date at 12am
;	local time, not 12 noon.  Then we can add the decimal time, which was
;	calculated earlier.  We can assume that the date will always be in the
;	20th or 21st centuries, thus we also subtract 2400000 from the julian 
;	date.

   return, (julday(mm_start,dd_start,yyyy_start) -.5 + double(time)) - 2400000
end

;------------------------------------------------------------------------------
;	define function that determines if the year is a leap year:
;------------------------------------------------------------------------------

function LPYEAR, year

   ;	if it is a leap year, then the year is evenly divisible by 4:

   rem = year MOD 4

   ;	centurial years are not leap years except when divisible by 400:

   rem2 = year MOD 100
   rem3 = year MOD 400

   ;	return 1 if it is a leap year, otherwise return 0

   IF ( (NOT rem AND rem2) OR (NOT rem3) ) THEN return, 1 ELSE return, 0
end

;------------------------------------------------------------------------------
;	define function that calculates day of year:
;------------------------------------------------------------------------------

function DAY_OF_YEAR, yyyy_start, mm_start, dd_start, time

   CASE mm_start OF
      1: final_doy = dd_start
      2: final_doy = 31 + dd_start
      3: final_doy = 59 + dd_start
      4: final_doy = 90 + dd_start
      5: final_doy = 120 + dd_start
      6: final_doy = 151 + dd_start
      7: final_doy = 181 + dd_start
      8: final_doy = 212 + dd_start
      9: final_doy = 243 + dd_start
      10: final_doy = 273 + dd_start
      11: final_doy = 304 + dd_start
      12: final_doy = 334 + dd_start
   ELSE:  message,'ERROR - Invalid month.'
   ENDCASE

;	If it is a leap year and the month is not 1 or 2, then add 1 to the
;	day of year, otherwise we do not need to account for the extra day.

   IF lpyear(yyyy_start) AND (mm_start GT 2) $
   THEN return, float(final_doy + time + 1) $
   ELSE return, float(final_doy + time)
end

;------------------------------------------------------------------------------
;	define function that calculates day from user-specified date:
;------------------------------------------------------------------------------

function CUSTOM, final_doy, yyyy_start, mm_start, dd_start, usr_month, usr_day

 IF usr_month GT mm_start OR ( (usr_month EQ mm_start) $
 AND (usr_day GT dd_start) ) $
 THEN message,'ERROR -  User-supplied date cannot be after observation date.'

;	calculate doy for user-specified date

 CASE usr_month OF
    1: usr_doy = usr_day   
    2: usr_doy = 31 + usr_day
    3: usr_doy = 59 + usr_day
    4: usr_doy = 90 + usr_day
    5: usr_doy = 120 + usr_day
    6: usr_doy = 151 + usr_day
    7: usr_doy = 181 + usr_day
    8: usr_doy = 212 + usr_day
    9: usr_doy = 243 + usr_day
    10: usr_doy = 273 + usr_day
    11: usr_doy = 304 + usr_day
    12: usr_doy = 334 + usr_day
 ELSE:  message,'ERROR -  Invalid month provided upon call to TIMEPDS'
 ENDCASE

 IF lpyear(yyyy_start) AND (usr_month GT 2) THEN usr_doy = usr_doy + 1

 return, (final_doy - usr_doy)

end

;------------------------------------------------------------------------------
;	define function that converts day of year to calendar date
;------------------------------------------------------------------------------

function CAL_DATE, yyyy_start, doy

   ;	If it is a leap year and the day of year is greater than 60, then 
   ;	subtract 1 to normalize the doy.

   IF lpyear(yyyy_start) AND (doy GE 60) THEN doy2 = doy - 1 ELSE doy2 = doy

   CASE 1 OF
      doy2 LE 31: mm_start = 1
      doy2 LE 59: mm_start = 2
      doy2 LE 90: mm_start = 3
      doy2 LE 120: mm_start = 4
      doy2 LE 151: mm_start = 5
      doy2 LE 181: mm_start = 6
      doy2 LE 212: mm_start = 7
      doy2 LE 243: mm_start = 8
      doy2 LE 273: mm_start = 9
      doy2 LE 304: mm_start = 10
      doy2 LE 334: mm_start = 11
      doy2 LE 357: mm_start = 12
      ELSE: message,'ERROR - Invalid day of year in PDS label'
   ENDCASE

   ;	Find the day of the month by calculating the difference between the 
   ;	doy and the doy of the first of each month.

   CASE mm_start OF
      1: dd_start = doy2
      2: dd_start = doy2 - 31
      3: dd_start = doy2 - 59
      4: dd_start = doy2 - 90
      5: dd_start = doy2 - 120
      6: dd_start = doy2 - 151
      7: dd_start = doy2 - 181
      8: dd_start = doy2 - 212
      9: dd_start = doy2 - 243
      10: dd_start = doy2 - 273
      11: dd_start = doy2 - 304
      12: dd_start = doy2 - 334
      ELSE: message,'ERROR - Invalid month in PDS label'
   ENDCASE

   cal_arr = fltarr(2)
   cal_arr(0) = mm_start
   cal_arr(1) = dd_start

   return, cal_arr
end

;------------------------------------------------------------------------------
;	define function that separates date into mm,dd,ccyy
;------------------------------------------------------------------------------

function DATE_SEP, date

;	First, we separate the date into its components using '-' as a
;	separator.

if (!VERSION.RELEASE GT 5.2) then begin
    date_arr = strsplit (date, '-', /EXTRACT)
endif else begin
    date_arr = str_sep(date,'-')      ; obsolete in IDL v. > 5.2
endelse

;	Declare the date array which we will be returning:

d_arr = fltarr(4)

;	Initialize the last element of the date array, day of year, to zero:

d_arr(3) = 0

;	There are three possible date formats that are supported by PDSSBN and
;	the PDSREAD set of tools:  1) CCYY-MM-DD, 2) YY-DOY, and 3) CCYY-DOY.
;	If there are 3 elements, the format is CCYY-MM-DD

IF n_elements(date_arr) EQ 3 THEN BEGIN
   year = float(date_arr(0))
   month = float(date_arr(1))
   day = float(date_arr(2))
ENDIF ELSE BEGIN

   ;	if there are 2 elements, the format is YY-DOY or CCYY-DOY

   IF n_elements(date_arr) EQ 2 THEN BEGIN

      ;	determine if format is either YY-DOY or CCYY-DOY

      IF strlen(date_arr(0)) EQ 4 THEN year = float(date_arr(0)) $
      ELSE year = 1900 + float(date_arr(0))  ;01,02,...?

      ;		day of year

      d_arr(3) = float(date_arr(1))

      ;		call cal_date function to calculate month and day of month

      cal_arr = cal_date(year, d_arr(3))
      month = cal_arr(0)
      day = cal_arr(1)

   ENDIF ELSE BEGIN
      message,'ERROR - Invalid date format in PDS label'

   ENDELSE
ENDELSE

d_arr(0) = year
d_arr(1) = month
d_arr(2) = day

return, d_arr

end

;------------------------------------------------------------------------------
;	define function that calculates decimal time of day
;------------------------------------------------------------------------------

function TIME_SEP, tm

;	Separate the time into its components using ':' as a separator

if (!VERSION.RELEASE GT 5.2) then begin
    time_arr = strsplit(tm, ':', /EXTRACT)
endif else begin
    time_arr = str_sep(tm,':')    ; obsolete in IDL v. > 5.2
endelse

;	We know that at least the hour and mins will be provided.

hour = double(time_arr(0))
min = double(time_arr(1))

;	Initialize seconds to zero.

sec = 0

;	test to see if seconds are provided and if 'Z' is present

IF n_elements(time_arr) EQ 3 THEN BEGIN
   z = strpos(time_arr(2), 'Z')
   IF z NE -1 THEN BEGIN
      sec = strmid(time_arr(2), 0, z)
      sec = double(sec)
   ENDIF ELSE sec = double(time_arr(2))
ENDIF

;	Return time as a decimal fraction of day

return, float( (hour + min/60 + sec/3600)/24 )
end

;------------------------------------------------------------------------------
;	define parent function, TIMEPDS:
;------------------------------------------------------------------------------

function TIMEPDS, label, usr_month, usr_day, DOY = doy, JD = jd

;ON_ERROR, 1

IF n_params() NE 1 AND n_params() NE 3 THEN BEGIN
 print, 'Syntax: result = TIMEPDS(label, month, day, [/DOY, /JD])'
 print, 'Note: If an optional keyword is present and nonzero, it should'
 print, 'take the place of month and day.'
 return, -1
ENDIF

;	Read object to determine type of data in file

object = pdspar(label,'OBJECT')

IF !ERR EQ -1 THEN message, 'ERROR - '+label+' missing required OBJECT keyword'

;	a value may not be provided, so initialize it to zero

time = 0
month = 0
day = 0
year = 0

FOR i = 0, (n_elements(object) - 1) DO BEGIN

   ;	test to see if filename is an image

   IF (object(i) EQ 'IMAGE') THEN BEGIN

      ;	Now we look for 'TIME' and 'DATE' keywords and if neither are provided,
      ;	an error occurs.  The following 'TIME' keywords are supported:
      ;	START_TIME, OBSERVATION_TIME, UT_TIME, SPACECRAFT_START_TIME.  The 
      ; following 'DATE' keywords are supported:  OBSERVATION_DATE, UT_DATE.

      time_flag = 1
      date_flag = 1

      start_tm = pdspar(label, 'START_TIME')
      IF !ERR EQ -1 THEN start_tm = pdspar(label, 'OBSERVATION_TIME')
      IF !ERR EQ -1 THEN start_tm = pdspar(label, 'UT_TIME')
      IF !ERR EQ -1 THEN start_tm = pdspar(label, 'SPACECRAFT_START_TIME')
      IF !ERR EQ -1 THEN time_flag = 0

      start_dt = pdspar(label, 'OBSERVATION_DATE')
      IF !ERR EQ -1 THEN start_dt = pdspar(label, 'UT_DATE')
      IF !ERR EQ -1 THEN date_flag = 0

      IF (NOT time_flag AND NOT date_flag) THEN $
         message, 'ERROR - '+label+' missing a time and date keyword'

      ;	There are a number of possible combinations of time and/or date
      ;	keywords that appear in a PDS label.  First, any keyword containing
      ;	the substring, 'TIME', will have a time and maybe a date, as well, but
      ;	it cannot have only a date.  Similarly, any keyword containing the
      ;	substring, 'DATE', will have a date and maybe a time, but it
      ;	cannot have only a time.
      ;
      ;	First, we check for a 'TIME' keyword:

      IF time_flag THEN BEGIN

         ;	There are two possibilities for the format of this value:
         ;	1) time or 2) dateTtime.  We will attempt to separate the
         ;	value using 'T' as a separator.  If the resulting array has 2
         ;	elements, we know the format is of 2) from above, but if it
         ;	has just 1 element, the format is of 1).

         if (!VERSION.RELEASE GT 5.2) then begin
             sep_arr = strsplit(start_tm(0), 'T', /EXTRACT)
         endif else begin
             sep_arr = str_sep(start_tm(0),'T')   ; obsolete in IDL v. > 5.2
         endelse
         IF n_elements(sep_arr) EQ 2 THEN BEGIN

            ;	PDS standards dictate that the time is after the date.  Call 
            ;	the function, time_sep, to calculate the decimal time and 
            ;	date_sep to calculate the day.

            time = time_sep(sep_arr(1))
            d_arr = date_sep(sep_arr(0))
            year = d_arr(0)
            month = d_arr(1)
            day = d_arr(2)
            doy3 = d_arr(3)

         ENDIF ELSE BEGIN
            time = time_sep(sep_arr(0))

            ;	There must be a date provided in the PDS label for timepds to
            ;	work.

            IF (NOT date_flag) $
            THEN message,'ERROR - '+label+' missing required date'
         ENDELSE
      ENDIF

      ;	Check for the date keyword:

      IF date_flag THEN BEGIN
         if (!VERSION.RELEASE GT 5.2) then begin
             sep_arr = strsplit(start_dt(0), 'T', /EXTRACT)
         endif else begin
             sep_arr = str_sep(start_dt(0),'T')    ; obsolete in IDL v. > 5.2
         endelse

         ;	The date is the first element no matter what...

         d_arr = date_sep(sep_arr(0))
         year = d_arr(0)
         month = d_arr(1)
         day = d_arr(2)
         doy3 = d_arr(3)

         ;	Check to see if the time is also provided:

         IF n_elements(sep_arr) EQ 2 THEN time = time_sep(sep_arr(1))
      ENDIF

      IF keyword_set(jd) THEN BEGIN
         juldate = jdate(year, month, day, time)
         print, 'Julian Date:  2400000 +', juldate
         return, juldate
      ENDIF ELSE BEGIN

         ;	We test to see if doy was provided, otherwise we must
         ;	calculate it.

         IF doy3 THEN final_doy = doy3 + time $
         ELSE final_doy = day_of_year(year, month, day, time)
         IF keyword_set(doy) THEN return, final_doy $
         ELSE return, custom(final_doy, year, month, day, usr_month, usr_day)
      ENDELSE

   ENDIF ELSE BEGIN

      ;	Test to see if the object is a table:

      IF (object(i) EQ 'TABLE') OR (object(i) EQ 'INDEX_TABLE') THEN BEGIN

         inform=pdspar(label,'INTERCHANGE_FORMAT')
         IF !ERR EQ -1 $
         THEN message,'ERROR - '+label+' missing required INTERCHANGE_FORMAT keyword'
         IF inform(0) EQ 'BINARY' $
         THEN message, 'ERROR - PDS table must be an ASCII table file.'

         ;	We must get the file pointer "^TABLE = " or "^INDEX_TABLE = "

         pointer = pdspar(label,'TABLE')
         IF !ERR EQ -1 THEN filename = pdspar(label, 'INDEX_TABLE')
         IF !ERR EQ -1 $
         THEN message, 'ERROR - No pointers to table data found in ' + label

         ;	Find positions of double quotes surrounding filename:

         leftpos = strpos(pointer(0),'"')
         IF leftpos EQ -1 $
         THEN message, 'ERROR - No filename found in pointer to image data'

         rightpos = strpos(pointer(0),'"',leftpos + 1)

         ;	Extract filename from inside double quotes:

         filename = strmid(pointer(0), leftpos + 1, rightpos - leftpos - 1)

         ;	Remove leading and trailing blanks:

         filename = strtrim(filename, 2)

         ;	Read the table and label:

;;A.Cardesin 13-04-2005
;;Modified: function name corrected'tascpds_test'-->'tascpds'
         data = tascpds(filename, label, /SILENT)

         n_columns = pdspar(label, 'COLUMNS')
         IF !ERR EQ -1 $
         THEN message, 'ERROR - '+label+' missing required COLUMNS keyword' $
         ELSE n_columns = fix(n_columns(0))

         ;	We initialize these indexes to -1 because later we will test
         ;	to see which ones are provided:

         time_col = -1
         date_col = -1
         doy3 = 0

         FOR i = 0, n_columns DO BEGIN

            ;	In the structure returned by tascpds, search the column_names
            ;	element for the keywords and assign the appropriate element of
            ;	the structure to an array.  

            col_name = data.column_names(i)

            CASE 1 OF
               col_name EQ 'START_TIME' OR col_name EQ 'OBSERVATION_TIME' OR $
               col_name EQ 'UT_TIME' OR col_name EQ 'SPACECRAFT_START_TIME': $
               BEGIN
                  time_col = i
                  times_arr = data.(i)
                  dummy_arr = times_arr
               END
               col_name EQ 'OBSERVATION_DATE' OR col_name EQ 'UT_DATE': BEGIN
                  date_col = i
                  dates_arr = data.(i)
                  dummy_arr = dates_arr
               END
               ELSE: 
            ENDCASE

         ENDFOR

         IF (time_col EQ -1) AND (date_col EQ -1) $
         THEN message, 'ERROR - Invalid or no time keyword in PDS label'

         ;	We use the dummy_arr to declare the final arrays:

         n_el = n_elements(dummy_arr)

         jd_arr = dblarr(n_el)
         doy_arr = fltarr(n_el)
         cu_arr = fltarr(n_el)

         ;	Now, we will go through the date and/or time array(s) one
         ;	element at a time and perform the necessary calculations.

         FOR k = 0, n_el - 1 DO BEGIN

            ;	IF there is a 'time' and a separate 'date' keyword:

            IF (time_col NE -1) AND (date_col NE -1) THEN BEGIN
               d_arr = date_sep(dates_arr(k))
               year = d_arr(0)
               month = d_arr(1)
               day = d_arr(2)
               doy3 = d_arr(3)
               time = time_sep(times_arr(k))

            ENDIF ELSE BEGIN

               ;	if there is just a 'TIME' keyword, it must contain
               ;	both a date and time in the format, dateTtime.

               IF (time_col NE -1) AND (date_col EQ -1) THEN BEGIN
                  if (!VERSION.RELEASE GT 5.2) then begin
                      sep_arr = strsplit(times_arr(k), 'T', /EXTRACT)
                  endif else begin
                     sep_arr = str_sep(times_arr(k),'T') ; obsolete in IDL> 5.2
                  endelse
                  d_arr = date_sep(sep_arr(0))
                  year = d_arr(0)
                  month = d_arr(1)
                  day = d_arr(2)
                  doy3 = d_arr(3)
                  time = time_sep(sep_arr(1))
               ENDIF

               ; if there is just a 'DATE' keyword, it must contain
               ; at least a date and maybe a time in the format, dateTtime.

               IF (time_col EQ -1) AND (date_col NE -1) THEN BEGIN
                  if (!VERSION.RELEASE GT 5.2) then begin
                      sep_arr = strsplit(dates_arr(k), 'T', /EXTRACT)
                  endif else begin
                      sep_arr = str_sep(dates_arr(k),'T') ; obsolete in IDL>5.2
                  endelse
                  d_arr = date_sep(sep_arr(0))
                  year = d_arr(0)
                  month = d_arr(1)
                  day = d_arr(2)
                  doy3 = d_arr(3)
                  IF n_elements(sep_arr) EQ 2 THEN time = time_sep(sep_arr(1))
               ENDIF

            ENDELSE

            IF keyword_set(jd) $
            THEN jd_arr(k) = jdate(year, month, day, time) $
            ELSE BEGIN

               IF doy3 THEN doy_arr(k) = doy3 + time $
               ELSE doy_arr(k) = day_of_year(year, month, day, time)

               IF not keyword_set(doy) $
               THEN cu_arr(k)=custom(doy_arr(k),year, $
                                     month,day,usr_month,usr_day)

            ENDELSE

         ENDFOR

         IF keyword_set(jd) THEN return, jd_arr
         IF keyword_set(doy) THEN return, doy_arr
         return, cu_arr

      ENDIF
   ENDELSE

ENDFOR

message, 'Could not determine type of data in PDS file'

end
