; docformat = 'rst'
;+
; :Private:
; :Hidden:
;-

pro open_star_file, filename, stars, gsc=gsc, gsc2=gsc2

; Opens star catalog file into a pointer array, byteswaps if necessary.
; Default format is Tycho-2, set keyword for GSC.

if keyword__set(gsc) then bytesize=16 else bytesize=24
openr, unit, filename, /get_lun
info = fstat(unit)
nstars = info.size/bytesize
if keyword__set(gsc) then stars = replicate({gsc_record},nstars) $
  else if keyword__set(gsc2) then stars = replicate({gsc2_record},nstars) $
  else stars = replicate({tycho_record},nstars)
readu, unit, stars
close, unit
free_lun, unit

for i=0,n_elements(tag_names(stars))-1 do begin
  a = stars.(i)
  if (size(a))[(size(a))[0]+1] eq 2 then byteorder, a, /NTOHS $
    else if (size(a))[(size(a))[0]+1] eq 3 then byteorder, a, /NTOHL $
    else if (size(a))[(size(a))[0]+1] eq 4 then byteorder, a, /XDRTOF $
    else nv_message, 'Unrecognized type code.'
  stars.(i) = a
endfor

end
