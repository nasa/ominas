; docformat = 'rst'
;+
; Used to create the GSC2 records for use by `strcat_gsc2_input`.
;
; Purpose
; =======
;
; The full catalog file for GSC 2.2 is not available for download by 
; researchers, but the data is accessible through a WWW query engine at
; http://www-gsss.stsci.edu/support/data_access.htm .  I was able to 
; determine the sections of the sky that were needed for the sat search
; project (see /raid/matt/pointing.sav and /raid/matt/pointing.pro), and
; created 40 data files by cut-and-paste from the WWW query engine.  This
; routine compiles those data files into a single structure that can be
; accessed by OMINAS.
;
; :Private:
;-

;+
; :Hidden:
;-
pro make_star_files_gsc2, indir=indir, catfile=catfile, outdir=outdir, $
	outfile=outfile, ns=ns

 ;------------------------------------
 ; File management stuff
 ;------------------------------------
 sep = path_sep()
 if not keyword__set(indir) then indir = '/catalog/gsc2.2/data/'
 if rstrpos(indir,sep) ne strlen(indir)-1 then indir = indir + sep
 if not keyword__set(catfile) then catfile = findfile( indir + 'gsc*dat' )
 if not keyword__set(outdir) then outdir = '/catalog/gsc2.2/'
 if rstrpos(outdir,sep) ne strlen(outdir)-1 then outdir = outdir + sep

 ;------------------------------------
 ; Initialize variables
 ;------------------------------------
 ns = 0l
 free_lun, 1
 free_lun, 2

 if not keyword__set(outfile) then outfile = outdir + 'gsc2.str'

 outrec = {gsc2_record}
 out = {gsc2_record}

 ;--------------------------------------------
 ; read the files and build a list of records
 ;--------------------------------------------
 for i=0, n_elements(catfile)-1 do $
  begin
   data = read_txt_table(catfile)
   n = (size(data))[1]
   data = data[2:n-2,*]

   nstars = (size(data))[1]
   _outrec = replicate({gsc2_record}, nstars)

   gsc2_id = strarr(nstars)
   tmp = data[*,0]
   for j=0, nstars-1 do gsc2_id[j] = strmid(tmp[j],4,strlen(tmp[j])-4)

   w = where(gsc2_id NE outrec.gsc2_id)
   if(w[0] NE -1) then $
    begin
     data = data[w,*]

     ra = float(data[*,1])
     dec = float(data[*,2])
     rapm = float(data[*,6])
     decpm = float(data[*,7])
     mag = float(data[*,14])

     _outrec.gsc2_id = gsc2_id
     _outrec.ra_deg = ra
     _outrec.dec_deg = dec
     _outrec.rapm = rapm
     _outrec.decpm = decpm
     _outrec.mag = mag


     if(i EQ 0) then outrec = _outrec $
     else outrec = [outrec, _outrec]


     k = n_elements(_outrec)
     print, 'Finished reading '+catfile[i]
     print, strtrim(j,2)+' stars found, '+strtrim(k,2)+' unique stars added.'
     print, 'RA Range:  '+strtrim(min(_outrec.ra_deg),2)+' to '+$
	                strtrim(max(_outrec.ra_deg),2)
     print, 'Dec Range:  '+strtrim(min(_outrec.dec_deg),2)+' to '+$
                    	strtrim(max(_outrec.dec_deg),2)

     ns = [ ns, ns[n_elements(ns)-1] + n_elements(_outrec) ]
    end
  end


 ;------------------
 ; Convert to XDR
 ;------------------
 gsc2_id = outrec.gsc2_id
 ra = outrec.ra_deg
 dec = outrec.dec_deg
 rapm = outrec.rapm
 decpm = outrec.decpm
 mag = outrec.mag
 byteorder, gsc2_id, /htonl
 byteorder, ra, /ftoxdr
 byteorder, dec, /ftoxdr
 byteorder, rapm, /ftoxdr
 byteorder, decpm, /ftoxdr
 byteorder, mag, /ftoxdr 
 outrec.gsc2_id = gsc2_id
 outrec.ra_deg = ra
 outrec.dec_deg = dec
 outrec.rapm = rapm
 outrec.decpm = decpm
 outrec.mag = mag

 openw, 2, outfile
 writeu, 2, outrec
 close, 2
 free_lun, 2

 free_lun, 1

; save, ns, filename='ns.sav'

end
