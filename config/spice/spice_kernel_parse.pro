;=============================================================================
; skp_simple
;
;=============================================================================
function skp_simple, dd, path, ext=ext0

ext0='bc'
 sep = path_sep()

 split_filename, cor_name(dd), dir, name, ext
 if(NOT keyword_set(name)) then return, ''

 ff = file_search(path + sep + name + '.' + ext0)
 if(keyword_set(ff)) then return, ff

 return, file_search(path + sep + name + '.' + ext + '.' + ext0)
end
;=============================================================================



;=============================================================================
; spice_kernel_parse
;
;=============================================================================
function spice_kernel_parse, dd, prefix, inst, type, ext=ext, time=_time, $
                       explicit=explicit, strict=strict, all=all

 if(keyword_set(_time)) then time = _time[0]
 sep = path_sep()

 ;-------------------------------------------------------------------
 ; Construct kernel input keyword and name of auto-detect function
 ; if specific auto-detect function does not exist, use the default 
 ; eph detector
 ;-------------------------------------------------------------------
 kw = strlowcase(type) + '_in'
 env = strupcase(prefix) + '_SPICE_' + strupcase(type)
 def = 'spice_' + strlowcase(type) + '_detect'

 fn = prefix + '_' + def
 if(NOT routine_exists(fn)) then fn = 'gen_' + def
 
 scfn = prefix + '_spice_sc'
 sc = 0
 if(routine_exists(scfn)) then sc = call_function(scfn, dd)

 ;---------------------------------------
 ; Get raw kernel keyword value
 ;---------------------------------------
 _k_in = dat_keyword_value(dd, kw)
 if(NOT keyword_set(_k_in)) then return, ''

 ;---------------------------------------
 ; Get default kernel path(s)
 ;---------------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; get path specific to this translator
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
; kpath = subdirs(getenv(env)) + sep
 kpath = getenv(env)
 w = where(kpath NE '')
 if(w[0] EQ -1) then $
  begin
   nv_message, verb=0.5, $
     env + ' environment variable is undefined.', /con, $
       exp=[env + ' specifies the directory in which the NAIF/SPICE translator', $
            'searches for ' + strupcase(type) + ' kernel files.']
   return, ''
  end

 nkpath = n_elements(kpath)

 ;---------------------------------------
 ; parse value list
 ;---------------------------------------
 _k_in = strtrim(str_nsplit(_k_in, ';'), 2)
 k_in = ''

 for i=0, n_elements(_k_in)-1 do $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; AUTO -- try to automatically detect the correct kernel in one
   ;         of the kernel directories, or the given path.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   split_filename, _k_in[i], dir, name
   if(strupcase(name) EQ 'AUTO') then $
    begin
     for j=0, nkpath-1 do $
      begin
       ;- - - - - - - - - - - - -
       ; get path
       ;- - - - - - - - - - - - -
       path = kpath[j]
       if(keyword_set(dir)) then path = dir 

       ;- - - - - - - - - - - - - - - - -
       ; try filename-based kernel names
       ;- - - - - - - - - - - - - - - - -
       _ff = skp_simple(dd, path, ext=ext)

       ;- - - - - - - - - - - - - - - - -
       ; use auto-detect function
       ;- - - - - - - - - - - - - - - - -
       if(NOT keyword_set(_ff)) then $
        begin
         nv_message, verb=0.9, 'Calling kernel auto-detect ' + fn
         _ff = call_function(fn, dd, kpath, sc=sc, all=all, strict=strict, time=time)
        end

      if(keyword_set(_ff)) then ff = _ff $
      else nv_message, verb=0.9, 'No kernels found.'
      end
    end $
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Otherwise, try to find the named kernel in one of the kernel
   ; directories.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else $
    begin
     for j=0, nkpath-1 do $
      begin
       if(strpos(_k_in[i], sep) EQ -1) then _k_in[i] = kpath[j] + _k_in[i]
       ff = file_search(_k_in[i])
       if(keyword_set(ff)) then explicit = append_array(explicit, ff) $
       else $
        nv_message, 'Not found: ' + _k_in[i], $
         exp = ['This kernel was explicitly requested, but it cannot be found in the', $
                'directory.']             
      end
    end

   if(keyword_set(ff)) then  k_in = append_array(k_in, ff)
  end


 return, k_in
end
;=============================================================================
