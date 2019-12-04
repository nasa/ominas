;===============================================================================
; supmap_read
;
;===============================================================================
function supmap_read

  map_file = filepath('supmap.dat',subdir=['resource','maps'])
  openr, lun, /get, map_file, /xdr, /stream
  npts = 0l

  index = 2

  ; 	  cont us_only  both
  fbyte = [ 0, 71612L, 165096L]
  nsegs = [ 283, 325, 594 ]


  point_lun, lun, fbyte[index]

  for i=1, nsegs[index] do $
   begin
    readu, lun, npts, maxlat, minlat, maxlon, minlon
    npts = npts / 2
    xy = fltarr(2, npts)
    readu, lun, xy
;    xy = reverse(xy)
    map_pts = xy * !dpi/180d
    map_pts_p = append_array(map_pts_p, ptr_new(map_pts))
   end

 free_lun, lun

 return, map_pts_p
end
;===============================================================================



;===============================================================================
; supmap
;
;  Converts IDL outline files to OMINAS array files.  These need to be culled 
;  down to the basics, and multiple files combined into properly named array 
;  files.  That shoudl be done with another program on the output of this
;  program.  Then these outputs should be moved to a subdirectory.
;
;===============================================================================
pro supmap
 
 ;-------------------------------------------------
 ; read IDL's low-res map file
 ;-------------------------------------------------
 map_pts_p = supmap_read()


 ;-------------------------------------------------
 ; create a planet descriptor for Earth
 ;-------------------------------------------------
 pd = pg_get_planets('/constants', name='EARTH')


 ;-------------------------------------------------
 ; write array files
 ;-------------------------------------------------
 for i=0, n_elements(map_pts_p)-1 do $
  begin
   map_pts = *map_pts_p[i]
   surf_pts = map_to_surface(0, pd, map_pts)
   arr_write, 'file-' + str_pad(strtrim(i,2),4,c='0',al=1) + '.arr', surf_pts
  end


end
;===============================================================================



