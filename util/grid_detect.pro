;==============================================================================
; grid_detect
;
;  Assumes samples w are sorted
;
;==============================================================================
function grid_detect, dim, w, s0=s0, s1=s1, d=d

 n = n_elements(w)
 ndim = n_elements(dim)


 ;--------------------------------------------------------------------
 ; convert 1-D samples to appropriate dimensionality
 ;--------------------------------------------------------------------
 p = w_to_nd(dim, w)

 ;------------------------------------------------------------
 ; create uniform grid to test
 ;------------------------------------------------------------
 d = lonarr(ndim)
 s0 = lonarr(ndim)
 s1 = lonarr(ndim)

 ;------------------------------------------------------------
 ; determine grid parameters
 ;------------------------------------------------------------
 for i=0, ndim-1 do $
  begin
   s0[i] = p[i,0]			; min coordinate in this dimension
   s1[i] = p[i,n-1]			; max coordinate in this dimension

   ww = min(where(p[i,*] NE p[i,0]))	; look for increment in this dimension
   d[i] = p[i,ww[0]] - p[i,0]		; compute step in this dimension
  end
stop

 grid_dim = (s1-s0)/d - 1
;;lindgen(grid_dim[i])*d[i] + s0[i]
;; this doesn't work in general because an input grid resulting from the 
;; conversion of a device-coord grid to a data-coord grid will be aliased
;; unless there is an ineger zoom factor: ther will be a jump in the grid step
;; every time the rounding switches from down to up.
;; --> some programs, like BRIM should be made to use integer zooms


 ;------------------------------------------------------------
 ; create test grid
 ;------------------------------------------------------------
 grid = gridgen(grid_dim, p0=p[*,0], /rec)	; won't work

 ;------------------------------------------------------------
 ; if samples match the test grid, return the grid parameters
 ;------------------------------------------------------------
 ww = where(grid NE p)
 if(ww[0] EQ -1) then return, 1
 return, 0
end
;==============================================================================
