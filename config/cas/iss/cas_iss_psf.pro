;==============================================================================
; ccpsf_read
;
;==============================================================================
function ccpsf_read, fname, size

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
;
;==============================================================================
function cas_iss_psf, cd, x, y

 if((NOT keyword_set(x)) AND (NOT keyword_set(y))) then default = 1 $
 else if(NOT keyword_set(y)) then y = dblarr(n_elements(x))


 ;--------------------------------------------
 ; determine data filename
 ;--------------------------------------------
 sep = path_sep()

 inst = cor_name(cd)
 filters = cam_filters(cd)

 dir = getenv('CAS_FILTERS')
 if(NOT keyword_set(dir)) then dir = getenv('OMINAS_CAS') + '/iss/psfs'
 dir = dir + sep

 filespec = dir + 'default_psf_generic_00200.dat'
 if(n_elements(filters) GE 2) then filespec = dir + $
     strmid(inst, 8,2) + 'C_' + filters[0] + '_' + filters[1] + '_PSF_reb_*.dat'
 ff = findfile(filespec)

 if(NOT keyword_set(ff)) then $
  begin
   nv_message, /con, $
      'PSF file not found for ' + cor_name(cd) + ': ' + $
             filters[0] + sep + filters[1] + '.', exp=' in ' + filespec
   return, 0
  end

 split_filename, ff, dir, name, ext
 size = fix(strmid(name, 20, 5))


 ;--------------------------------------------
 ; read data file
 ;--------------------------------------------
 dat = ccpsf_read(ff[0], size[0])
 if(keyword_set(default)) then return, dat

 cx = size/2 & cy = size/2
 return, image_interp_poly(dat, x+cx, y+cy)
end
;==============================================================================



