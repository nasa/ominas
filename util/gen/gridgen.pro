;=============================================================================
;+
; NAME:
;	gridgen
;
;
; PURPOSE:
;	Constructs a grid of subscripts.
;
;
; CATEGORY:
;	UTIL/GEN
;
;
; CALLING SEQUENCE:
;	sub = gridgen(dim)
;
;
; ARGUMENTS:
;  INPUT:
;	dim:	 Dimensions of output grid.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	rectangular: If set, the output array has dimensions (ndim,dim[0],dim[1],...)
;	             instead of (ndim,dim[0]*dim[1]*...).  In this case,
;	             sub[i, x_0,x_1,x_2,x3,...] = x_i.
;
;	p0:          Array (ndim) giving the starting point for the grid.  
; 	             Default is [0,0,..].
;
;	center:	     If given, p0 is taken to be the center of the grid instead.
;	             of the corner.
;
;	double:      If set, output is double instead of long.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (ndim, dim[0]*dim[1]*...) of subscripts, or (ndim,dim[0],dim[1],...) 
;	if /rectangular.
;
;
; EXAMPLE:
;	gridgen([3], /rec) returns an array (1,3) with elements:
;
;			0 1 2    
;
;
;	gridgen([3,4], /rec) returns an array (2,3,4) with elements:
;
;			0 1 2       
;			0 1 2    
;			0 1 2    
;			0 1 2    
;
;			0 0 0   
;			1 1 1   
;			2 2 2   
;			3 3 3   
;
;
;	gridgen([3,4,2], /rec) returns an array (3,3,4,2) with elements:
;
;			0 1 2   0 1 2    
;			0 1 2   0 1 2 
;			0 1 2   0 1 2 
;			0 1 2   0 1 2 
;
;			0 0 0   0 0 0
;			1 1 1   1 1 1
;			2 2 2   2 2 2
;			3 3 3   3 3 3
;
;			0 0 0   1 1 1
;			0 0 0   1 1 1
;			0 0 0   1 1 1
;			0 0 0   1 1 1
;
;
; KNOWN BUGS:
;	In some circumstances gridgen will return duplicate subscripts.
;	This happens when the grid spans zero and the grid locations are not
;	not integers.  In that case, converting to integer type could cause 
;	neighboring elements to both round to zero, or to round to either side, 
;	omitting zero entirely.
;
;
; STATUS:
;	Some bugs.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 	7/2015
;	
;-
;=============================================================================
function gridgen, dim, $
            rectangular=rectangular, p0=p0, center=center, double=double

 dim = long(dim)
 ndim = n_elements(dim)

 if(NOT keyword_set(p0)) then p0 = dblarr(dim) 
 if(n_elements(p0) EQ 1) then return, [0]
 n = long(product(dim))


 grid = dblarr([ndim,n])
 for i=0, ndim-1 do grid[i,*] = p0[i] + $
         transpose(dindgen(shift(dim,-i)) mod dim[i], shift(lindgen(ndim),i))


 if(keyword_set(center)) then $ 
            for i=0, ndim-1 do grid[i,*] = grid[i,*] - dim[i]/2 + 0.5
 if(keyword_set(rectangular)) then grid = reform(grid, [ndim,dim], /over)
 if(NOT keyword_set(double)) then grid = round(grid)
; if(NOT keyword_set(double)) then grid = fix(grid)

 return, grid
end
;==================================================================================
