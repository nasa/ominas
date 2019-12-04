;==================================================================================
; binogram
;
;  This is like a histogram, except that every occurrence counts once.  In other
;  words, we are binning each given coordinate combination, rather than a value
;  given at that location in phase space.
;
; coor has dimensions npoints x ndimensions
;
;==================================================================================
function binogram, coords, bin=bin, reverse_indices=reverse_indices

 dim = size(coords, /dim)
 n = dim[0]
 ncoord = dim[1]

 mins = transpose(nmin(coords, 0))
 maxs = transpose(nmax(coords, 0))

 nbins = fix((maxs-mins)/bin) + 1

 binogram = lonarr(nbins)
 reverse_indices = lonarr(n)

 for i=0, n-1 do $
  begin
   coord = coords[i,*] - mins
   ii = long(coord[0]/bin[0])
   for j=1, ncoord-1 do ii = ii + long(coord[j]/bin[j])*prod(nbins[0:j-1])
   binogram[ii] = binogram[ii] + 1
   reverse_indices[i] = ii
  end

 return, binogram
end
;==================================================================================
