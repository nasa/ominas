;==============================================================================
; ccpsf_filename_vicar
;
;==============================================================================
function ccpsf_filename_vicar, dir, inst, filters, size=size, default=default

 default = 0

 if(n_elements(filters) GE 2) then $
  begin
   filespec = dir + 'xpsf_' + $
     strmid(inst, 8,2) + 'c_' + strlowcase(filters[0]) + '_' + strlowcase(filters[1]) + '.img'
   ff = file_search(filespec)
  end
 if(NOT keyword_set(ff)) then $
  begin
   default = 1
   ff = file_search(dir + 'xpsf_default_generic.img')
  end
stop

 if(NOT keyword_set(ff)) then return, ''


; size = [[1024]]

 return, ff
end
;==============================================================================



;==============================================================================
; ccpsf_read_vicar
;
;==============================================================================
function ccpsf_read_vicar, fname, size



 return, psf
end
;==============================================================================



;==============================================================================
; ccpsf_filename_dat
;
;==============================================================================
function ccpsf_filename_dat, dir, inst, filters, size=size, default=default

 default = 0

 if(n_elements(filters) GE 2) then $
  begin
   filespec = dir + $
     strmid(inst, 8,2) + 'C_' + filters[0] + '_' + filters[1] + '_PSF_reb_*.dat'
   ff = file_search(filespec)
  end
 if(NOT keyword_set(ff)) then $
  begin
   default = 1
   ff = file_search(dir + 'default_psf_generic_00200.dat')
  end

 if(NOT keyword_set(ff)) then return, ''


 split_filename, ff, dir, name, ext
 size = fix(strmid(name, 20, 5))

 return, ff
end
;==============================================================================



;==============================================================================
; ccpsf_read_dat
;
;==============================================================================
function ccpsf_read_dat, fname, size

 openr, unit, fname, /get_lun
 psf = fltarr(size, size)
 readu, unit, psf

 close, unit
 free_lun, unit

 if(test_endian()) then psf = swap_endian(psf)
 return, psf
end
;==============================================================================



;==============================================================================
; cas_iss_psf
;
;  Uses old .dat files
;
;==============================================================================
function cas_iss_psf, cd, x, y, format=format

 if(NOT keyword_set(format)) then format = 'dat'
 format = strlowcase(format)
;format='vicar'

 if((NOT keyword_set(x)) AND (NOT keyword_set(y))) then full = 1 $
 else if(NOT keyword_set(y)) then y = dblarr(n_elements(x))


 ;--------------------------------------------
 ; determine data filename
 ;--------------------------------------------
 sep = path_sep()

 inst = cor_name(cd)
 filters = cam_filters(cd)

 if(NOT keyword_set(filters)) then $
  begin
   nv_message, verb=0.1, 'No filters file for ' + cor_name(cd) + '.'
   return, 0
  end

 dir = getenv('CAS_FILTERS')
 if(NOT keyword_set(dir)) then dir = getenv('OMINAS_CAS') + '/iss/psfs/' + format
 dir = dir + sep

 ff = call_function('ccpsf_filename_' + format, dir, inst, filters, size=size, default=default)
 if(NOT keyword_set(ff)) then $
  begin
   nv_message, /con, $
      'PSF file not found for ' + cor_name(cd) + ': ' + $
             filters[0] + sep + filters[1] + '.', exp=' in ' + filespec
   return, 0
  end

 if(default) then $
   nv_message, verb=0.1, $
      'No PSF file for ' + cor_name(cd) + ': ' + $
             filters[0] + sep + filters[1] + '.  Using ' + ff + '.'


 ;--------------------------------------------
 ; read data file
 ;--------------------------------------------
 dat = call_function('ccpsf_read_' + format, ff[0], size[0])
 if(keyword_set(full)) then return, dat

 cx = size/2 & cy = size/2
 return, image_interp_poly(dat, x+cx, y+cy)
end
;==============================================================================



