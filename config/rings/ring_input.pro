;=============================================================================
;+
; NAME:
;	ring_input
;
;
; PURPOSE:
;	Input translator for planetary rings.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by dat_get_value):
;	result = ring_input(dd, keyword)
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
;	key1:		Planet descriptor -- required
;
;	key2:		Camera descriptor
;
;  OUTPUT:
;	status:		Zero if valid data is returned
;
;
; ENVIRONMENT VARIABLES:
;	NV_RING_DATA:	Sets the directory in which to look for data files.
;
;
;  TRANSLATOR KEYWORDS:
;	system:		Asks translator to return a single ring descriptor
;			encompassing the entire ring system.  If not specified,
;			the translator may return a more detailed set of
;			individual rings.
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
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 8/2004
;	
;-
;=============================================================================



;=============================================================================
; ri_clone
;
;=============================================================================
function ri_clone, _rd

 n = n_elements(_rd)
 rd = objarr(n)

 for i=0, n-1 do if(obj_valid(_rd[i])) then $
                           rd[i] = nv_clone(_rd[i])

 return, rd
end
;=============================================================================



;=============================================================================
; ri_build
;
;=============================================================================
function ri_build, dat, name, pd

 dkd = orb_construct_descriptor(pd, /ring, /noevolve, $
              name = strupcase(name), $
              time = dat.epoch, $ 
              sma = dat.sma, $
              ecc = dat.ecc[0] , $
              lp =  dat.lp[0] , $
              dlpdt = dat.dlpdt[0] , $
              inc =  dat.inc, $
              lan =  dat.lan, $
              dlandt = dat.dlandt)

; this doesn't look right...
; dm = size(dat.ecc, /dim)
; if(n_elements(dm) GT 1) then $
;  for k=1, dm[1]-1 do $
;      dsk_assign, dkd, /noevent, $
;	   m = dat.m[k], $
;	   em = dat.ecc[k], $
;	   lpm = dat.lp[k], $
;	   dlpmdt = dat.dlpdt[k]

 return, dkd
end
;=============================================================================



;=============================================================================
; ri_system
;
;=============================================================================
pro ri_system, dkd, inner=inner, outer=outer

 sma = (dsk_sma(dkd))[0,0,*]
 ecc = (dsk_ecc(dkd))[0,0,*]
 q = sma*(1d - ecc)
 q0 = keyword_set(inner) ? min(q) : max(q)

 w = where(q EQ q0)
 dkd = dkd[w[0]]

 sma = dsk_sma(dkd) & sma[0] = q0 & dsk_set_sma, dkd, sma
 ecc = dsk_ecc(dkd) & ecc[0] = 0 & dsk_set_ecc, dkd, ecc

 cor_set_name, dkd, 'MAIN_RING_SYSTEM'

end
;=============================================================================



;=============================================================================
; ri_merge
;
;=============================================================================
function ri_merge, dkd_inner, dkd_outer, pd, opaque

 dkd = dkd_inner
 for j=0, n_elements(dkd)-1 do $
  begin
   sma = tr( [tr((dsk_sma(dkd[j]))[*,0]), tr((dsk_sma(dkd_outer[j]))[*,0])] )
   dsk_set_sma, dkd[j], sma
   ecc = tr( [tr((dsk_ecc(dkd[j]))[*,0]), tr((dsk_ecc(dkd_outer[j]))[*,0])] )
   dsk_set_ecc, dkd[j], ecc
   bod_set_pos, dkd[j], bod_pos(pd)
   bod_set_opaque, dkd[j], opaque[j]
  end

 return, dkd
end
;=============================================================================



;=============================================================================
; ring_input
;
;=============================================================================
function ring_input, dd, keyword, prefix, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 ;--------------------------
 ; verify keyword
 ;--------------------------
 if(keyword NE 'RNG_DESCRIPTORS') then $
  begin
   status = -1
   return, 0
  end

 ;----------------------------------------------
 ; get catalog path
 ;----------------------------------------------
 catpath = getenvs('NV_RING_DATA')
 if(NOT keyword_set(catpath)) then $
   begin
    nv_message, /con, $
     'NV_RING_DATA environment variable is undefined.', $
       exp=['NV_RING_DATA specifies directories in which this translator', $
            'searches for ring catalog files.']
   status = -1
   return, 0
  end
 catpath = parse_comma_list(catpath, delim=':')

 status = 0

 deg2rad = !dpi/180d
 degday2radsec = !dpi/180d / 86400d

 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------
 system = dat_keyword_value(dd, 'system')
 select_all = dat_keyword_value(dd, 'all')
 select_fiducial = dat_keyword_value(dd, 'fiducial')
 reload = dat_keyword_value(dd, 'reload')
 sel_names = dat_keyword_value(dd, 'name')
 if(NOT keyword_set(sel_names[0])) then sel_names= '' $
 else select_all = 1


 ;-----------------------------------------------
 ; planet descriptor passed as key1
 ;-----------------------------------------------
 if(keyword_set(key1)) then pds = key1 $
; else nv_message, 'Planet descriptor required.'
 else $
  begin
   status = -1
   return, 0
  end

 ;-----------------------------------------------
 ; object names passed as key8
 ;-----------------------------------------------
 if(keyword_set(key8) AND (NOT keyword_set(sel_names))) then sel_names = key8


 ;-----------------------------------------------
 ; set up ring descriptors
 ;-----------------------------------------------
 npds = n_elements(pds)
 for i=0, npds-1 do $
  begin
   planet = cor_name(pds[i])

   dkd_inner = (dkd_outer = '')

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; read relevant ring catalog
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   catfile = 'ringcat_' + strlowcase(planet) + '.txt'
   dat = file_manage('ringcat_read', catpath, catfile, reload=reload)

   if(keyword_set(dat)) then $
    begin
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; select desired rings by classification
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     if(NOT keyword_set(select_all)) then $
      begin
       if(keyword_set(select_fiducial)) then w = where(dat.fiducial EQ 'yes') $
       else w = where(dat.default EQ 'yes')
       dat = dat[w]
      end


     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; if any requested names, select only those
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     continue = 1
     if(keyword_set(sel_names)) then $
      begin
       ww = -1
       for j=0, n_elements(sel_names)-1 do $
               ww = append_array(ww, where(strupcase(dat.ring) EQ strupcase(sel_names[j])), /pos)
       if(ww[0] EQ -1) then dat = 0 $
       else dat = dat[ww]
      end

    if(keyword_set(dat)) then $
      begin
       ;- - - - - - - - - - - - - - - - - -
       ; build descriptors
       ;- - - - - - - - - - - - - - - - - -

       ;.............................................
       ; get unique ring names + all unnamed rings
       ;.............................................
       ss = sort(dat.name)
       uu = uniq(dat[ss].name)
       dat = dat[ss[uu]]

       ;...........................................................
       ; create descriptors
       ;  rings with no name are created using their feature name
       ;  with inner and outer edges identical
       ;...........................................................
       n_rings = n_elements(dat)

       opaque = strupcase(dat.opaque) EQ 'YES'

       dkd_inner = objarr(n_rings)
       dkd_outer = objarr(n_rings)
       dkd_peak = objarr(n_rings)
       dkd_trough = objarr(n_rings)
       kk = 0
       for j=0, n_rings-1 do $
        begin
         ring = dat[j].ring
         w = where(dat.ring EQ ring)
         name = ring

         nw = n_elements(w)
         if(nw GT 2) then nv_message, $
                    'Too many features with ring name ' + dat[j].ring + '.'
         w0 = where(dat[w].type EQ 'INNER') 
         w1 = where(dat[w].type EQ 'OUTER') 
         w2 = where(dat[w].type EQ 'PEAK') 
         w3 = where(dat[w].type EQ 'TROUGH') 

         dkd_inner[j] = (dkd_outer[j] = (dkd_peak[j] = (dkd_trough[j] = obj_new())))

         ;................................ 
         ; inner edge
         ;................................ 
         if(w0[0] NE -1) then $
          begin
           dkd_inner[j] = ri_build(dat[w[w0]], name, pds[i])
           dkdx = append_array(dkdx, dkd_inner[j])	; save to free later
          end

         ;................................ 
         ; outer edge
         ;................................ 
         if(w1[0] NE -1) then $
          begin
           dkd_outer[j] = ri_build(dat[w[w1]], name, pds[i])
           dkdx = append_array(dkdx, dkd_outer[j])	; save to free later
          end

         ;................................ 
         ; peak
         ;................................ 
         if(w2[0] NE -1) then $
          begin
           dkd_peak[j] = ri_build(dat[w[w2]], name, pds[i])
           dsk_widen, dkd_peak[j], 0d

           dkds = append_array(dkds, dkd_peak[j])
           primaries = append_array(primaries, pds[i])
           gd = append_array(gd, cor_create_gd(cor_gd(pds[i]), bx0=pds[i], dd=dd))
           ppds = append_array(ppds, pds[i])
          end

         ;................................ 
         ; trough
         ;................................ 
         if(w3[0] NE -1) then $
          begin
           dkd_trough[j] = ri_build(dat[w[w3]], name, pds[i])
           dsk_widen, dkd_trough[j], 0d

           dkds = append_array(dkds, dkd_trough[j])
           primaries = append_array(primaries, pds[i])
           gd = append_array(gd, cor_create_gd(cor_gd(pds[i]), bx0=pds[i], dd=dd))
           ppds = append_array(ppds, pds[i])
          end
        end

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; record which rings had only one edge, and fix them up so
       ; that the following calculations are valid
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       xx_inner = where(obj_valid(dkd_inner) EQ 0)
       xx_outer = where(obj_valid(dkd_outer) EQ 0)
       xx_peak = where(obj_valid(dkd_peak) EQ 0)
       xx_trough = where(obj_valid(dkd_trough) EQ 0)

       if(xx_inner[0] NE -1) then dkd_inner[xx_inner] = dkd_outer[xx_inner]
       if(xx_outer[0] NE -1) then dkd_outer[xx_outer] = dkd_inner[xx_outer]
       if(xx_peak[0] NE -1) then dkd_peak[xx_peak] = dkd_peak[xx_peak]
       if(xx_trough[0] NE -1) then dkd_trough[xx_trough] = dkd_trough[xx_trough]

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; if /system, we want one descriptor encompassing entire ring system
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(keyword_set(system)) then $
        begin
         ri_system, dkd_inner, /inner
         ri_system, dkd_outer, /outer
        end

       ;- - - - - - - - - - - - - - - - - - - - -
       ; merge inner/outer descriptors
       ;- - - - - - - - - - - - - - - - - - - - -
       if(keyword__set(dkd_inner)) then $
        begin
         dkd = ri_merge(dkd_inner, dkd_outer, pds[i], opaque)
         ndkd = n_elements(dkd)
         dkds = append_array(dkds, dkd)
         primaries = append_array(primaries, make_array(n_elements(dkd), val=pds[i]))
         gd = append_array(gd, make_array(ndkd, val=cor_create_gd(cor_gd(pds[i]), bx0=pds[i], dd=dd)))
         ppds = append_array(ppds, make_array(n_elements(dkd), val=pds[i]))
        end
      end

    end
  end


 if(NOT keyword_set(dkds)) then $
  begin
   status = -1
   return, 0
  end


 ;------------------------------------------------------------------
 ; handle rings with only one edge
 ;------------------------------------------------------------------
 if(xx_inner[0] NE -1) then $
  begin
   sma = dsk_sma(dkds[xx_inner])
   sma[0,0,*] = -1
   dsk_set_sma, dkds[xx_inner], sma
  end

 if(xx_outer[0] NE -1) then $
  begin
   sma = dsk_sma(dkds[xx_outer])
   sma[0,1,*] = -1
   dsk_set_sma, dkds[xx_outer], sma
  end


 ;----------------------------------------------
 ; evolve rings to primary epochs
 ;----------------------------------------------
 n_obj = n_elements(dkds)

 dkdts = objarr(n_obj)
 for i=0, n_obj-1 do $
  dkdts[i] = rng_evolve(dkds[i], bod_time(ppds[i]) - bod_time(dkds[i]))
 nv_free, dkdx
;stop
; apply to other edge types, other translators

 ;------------------------------------------------------------------
 ; make ring descriptors
 ;------------------------------------------------------------------
 rds = rng_create_descriptors(n_obj, $
		gd=gd, $
		name=cor_name(dkdts), $
		opaque=bod_opaque(dkdts), $
		orient=bod_orient(dkdts), $
		avel=bod_avel(dkdts), $
		pos=bod_pos(dkdts), $
		vel=bod_vel(dkdts), $
		time=bod_time(dkdts), $
		sma=dsk_sma(dkdts), $
		ecc=dsk_ecc(dkdts))

 return, rds
end
;===========================================================================



