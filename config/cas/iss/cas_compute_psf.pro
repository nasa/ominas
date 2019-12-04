;==============================================================================
; cas_compute_psf
;
;
;==============================================================================
function cas_compute_psf, cd, x, y, default=default, onedim=onedim

 if(keyword_set(default)) then $
  begin
   dxy = 4
   nn = 2*dxy + 1
   x = lindgen(nn) - dxy 
   if(NOT keyword_set(onedim)) then $
    begin
     x = x # make_array(nn, val=1d)
     y = tr(x)
    end
  end

 inst = cor_name(cd)
 case inst of 
  'CAS_ISSNA' : $
	begin
	 ; from SSR paper...
;	 sig_a = 1.3d / 2.354
;	 sig_b = sig_a
;	 theta = 0

;	 ; from 5/2005 fit...
;	 sig_a = 0.7615
;	 sig_b = 0.6799
;	 theta = -1.66 * !dpi/180d

	 ; from emma, 7/15/05
	 sig_a = 0.685960
	 sig_b = 0.662233
	 theta = 0.00432408
	end
  'CAS_ISSWA' :  $
	begin
;	 ; from SSR paper...
;	 sig_a = 1.8d / 2.354
;	 sig_b = sig_a
;	 theta = 0

	 ; from emma, 7/15/05
	 sig_a = 0.898618
	 sig_b = 1.00861
	 theta = 0.106206
	end
 endcase

 if(keyword_set(onedim)) then return, gauss1d(x, 0.5*(sig_a + sig_b))
 return, gauss2d(x, y, sig_a, sig_b, theta, /norm)
end
;==============================================================================
