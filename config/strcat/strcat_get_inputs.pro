; docformat = 'rst'
;+
; Obtains scene data to be used by star catalog translator.
; 
; Notes
; =====
;	Assumes star positions are wrt SSB, not sun
;	
;	Assumes camera coordinate system is Earth equatorial
;	
;	:Private:
;-

;+
; :Hidden:
;-
pro strcat_get_inputs, dd, env, key, $
	b1950=b1950, j2000=j2000, time=time, jtime=jtime, $
	path=path, names=names, $
	ra1=ra1, ra2=ra2, dec1=dec1, dec2=dec2, $
	faint=faint, bright=bright, nbright=nbright, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 status = -1

 ;---------------------------------------------------------
 ; Translator keywords
 ;---------------------------------------------------------
 b1950 = tr_keyword_value(dd, 'b1950')

 jtime = double(tr_keyword_value(dd, 'jtime'))

 j2000 = tr_keyword_value(dd, 'j2000')

 _faint = tr_keyword_value(dd, 'faint')
 if(_faint NE '') then faint = double(_faint)

 _bright = tr_keyword_value(dd, 'bright')
 if(_bright NE '') then bright = double(_bright)

 nbright = long(tr_keyword_value(dd, 'nbright'))

 ;---------------------------------------------------------
 ; Star catalog path
 ;---------------------------------------------------------
 path = tr_keyword_value(dd, key)
 if(NOT keyword_set(path)) then path = getenv(env);
 if(NOT keyword_set(path)) then $
  begin
   nv_message, /cont, 'Warning: ' + env + ' not defined.  No star catalog.'
   return
  end
   
 ;---------------------------------------------------------
 ; Observer descriptor passed as key1
 ;---------------------------------------------------------
 if(keyword_set(key1)) then ods = key1 
 if(NOT cor_isa(ods[0], 'BODY')) then ods = 0
 if(NOT keyword_set(ods)) then return

 ;---------------------------------------------------------
 ; fov and cov 
 ;---------------------------------------------------------
 fov = double(tr_keyword_value(dd, 'fov'))
 if(NOT keyword_set(fov)) then fov = 1

 cov = double(parse_comma_list(tr_keyword_value(dd, 'cov'), delim=';'))
 if(keyword_set(cov)) then cov = transpose(cov) $
 else if(NOT keyword_set(cov)) then cov = cam_oaxis(ods[0])

 ;---------------------------------------------------------
 ; Names passed as key8
 ;---------------------------------------------------------
 if(keyword_set(key8)) then $
  begin
   names = key8
   if(n_elements(names) EQ 1) then $
        if(strupcase(names[0]) EQ 'SUN') then return
  end

 ;---------------------------------------------------------
 ; Get jtime 
 ;---------------------------------------------------------
 time = bod_time(ods[0])
 if(NOT keyword_set(jtime)) then $
  begin
   jtime = time/(365.25d*86400d)      ; assuming camtime is secs past 2000
   if(keyword__set(b1950)) then jtime = jtime + 50.
  end

 ;---------------------------------------------------------
 ; Get ra/dec limits 
 ;---------------------------------------------------------
 ra1 = 0d & ra2 = 2d*!dpi * 0.999
 dec1 = -!dpi/2d * 0.999 & dec2 = -dec1 * 0.999

 if(keyword_set(fov)) then $
  begin
   cam_scale = min(cam_scale(ods[0]))
   cam_size = cam_size(ods[0])

   radec0 = image_to_radec(ods[0], cov)
   cam_fov = min(cam_scale*cam_size)
   field = fov*cam_fov

   ra1 = reduce_angle(radec0[0] + field)
   ra2 = reduce_angle(radec0[0] - field)

   dec1 = radec0[1] + field
   dec2 = radec0[1] - field
  end $
 else nv_message, /con, $
      'WARNING: No FOV limits set for star catalog search.', $
       exp=['Without FOV limits, stars will be returned for the entire sky.', $
            'This may cause the software to run very slowly.']


 status = 0

end
;=============================================================================
