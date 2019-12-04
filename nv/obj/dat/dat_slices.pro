;=============================================================================
;+
; NAME:
;	dat_slices
;
;
; PURPOSE:
;	Creates new data descriptors that point to subarray slices in a given
;	data descriptor.
;
;
; CATEGORY:
;	NV/OBJ/DAT
;
;
; CALLING SEQUENCE:
;	new_dd = dat_slices(dd, slice)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing N-dimensional data array.
;
;	slice:	m x n array giving coordinates of n m-dimensional arrays to 
;		select. If not given, the original data array is sliced into
;		arrays of one dimension smaller, i.e., a cube is sliced
;		into its constituent images, and an image is sliced into its
;		constituent lines etc.
;
;  OUTPUT: 
;	data:		Data array from the last data descriptor returned.  
;			This is provided as a convenience when slicing off 
;			single descriptors so that it is not necessary to 
;			call dat_data to get the array.
;
;	header:		Header array from the last data descriptor returned.  
;			This is provided as a convenience when slicing off 
;			single descriptors so that it is not necessary to call 
;			dat_header to get the array.
;
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	abscissa:	Data abscissa.
;
;
; RETURN: 
;	New data descriptors for the selected data arrays.  Dimensions are N - m.
;	Note that new data arrays are not allocated.  Instead, the returned 
;	descriptors point to the subarray within the data array of the input 
;	data descriptor.
;
;
; EXAMPLE:
;	1) Extract the ith image of a 3-dimensional data cube:
;
;		new_dd = dat_slices(dd, i)
;
;	2) Extract the ith cube of a 4-dimensional data array:
;
;		new_dd = dat_slices(dd, i)
;
;	3) Extract the ith image in the jth cube of a 4-dimensional data array:
;
;		new_dd = dat_slices(dd, [i,j])
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		6/2017
;	
;-
;=============================================================================
function dat_slices, dd0, slice, data, header, abscissa=abscissa

 dim0 = dat_dim(dd0)
 ndim0 = n_elements(dim0)
 if(NOT defined(slice)) then slice = lindgen(1,dim0[ndim0-1])

 n = 1
 dim = size(slice, /dim)
 ndim = n_elements(dim)
 if(ndim EQ 2) then n = dim[1]

 dd = objarr(n)

 for i=0, n-1 do $
  begin
   dd[i] = nv_clone(dd0, protect='DD0P')
   dat_set_slice, dd[i], dd0, slice[*,i], /new
   dat_set_max, dd[i], -1d100
   dat_set_min, dd[i], 1d100
  end

 if(arg_present(data)) then data = dat_data(dd[n-1], abscissa=abscissa)
 if(arg_present(header)) then header = dat_header(dd[n-1])

 return, dd
end
;===========================================================================



