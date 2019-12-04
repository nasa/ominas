;==============================================================================
; nlf_print_free_params
;
;==============================================================================
pro nlf_print_free_params, state

 print
 print, 'Fit parameter values:'
 print, '  ' + tr(state.labels) + ':	' + strtrim(state.parm, 2)

end
;==============================================================================



;==============================================================================
; nlf_print_covariance
;
;==============================================================================
pro nlf_print_covariance, state, cov, sigma=sigma, norm=norm

 ;-----------------------------------------------
 ; print covariance matrix
 ;-----------------------------------------------
 print, 'Covariance matrix:'
 format = '(' + strtrim(state.nfree,2) + 'a10)'
 print, format=format, state.labels
 format = '(' + strtrim(state.nfree,2) + 'g10.3)'
 print, format=format, cov

 ;-----------------------------------------------
 ; print correlation matrix
 ;-----------------------------------------------
 print
 print, 'Correlation matrix:'
 format = '(' + strtrim(state.nfree,2) + 'a10)'
 print, format=format, state.labels
 format = '(' + strtrim(state.nfree,2) + 'g10.3)'
 print, format=format, cov/norm

 ;-----------------------------------------------
 ; print fit parameter uncertainties
 ;-----------------------------------------------
 print
 print, 'Fit parameter 1-sigma uncertainties:'
 print, '  ' + tr(state.labels) + ':	' + strtrim(sigma, 2)

end
;==============================================================================



;==============================================================================
; nlf_print_results
;
;==============================================================================
pro nlf_print_results, state, chisq, reduced_chisq, $
                       cov=cov, norm=norm, sig=sig, res=res, $
                       rms_sig=rms_sig, rms_nat=rms_nat

 nobs = state.nobs
 nfree = state.nfree

 res = state.residuals

 print, 'Residuals (in sigma units):'
 for i=0, nobs-1 do print, i, res[i]/state.sigy[i]

 if(keyword_set(cov)) then $
  begin
   print
   nlf_print_covariance, state, cov, sig=sig, norm=norm
   nlf_print_free_params, state
  end
 print

 help, chisq, output=s & print, ';  ' + s
 help, nobs, output=s & print, ';  ' + s
 help, nfree, output=s & print, ';  ' + s
 help, reduced_chisq, output=s & print, ';  ' + s
 help, rms_sig, output=s & print, ';  ' + s
 help, rms_nat, output=s & print, ';  ' + s

end
;==============================================================================



;==============================================================================
; nlf_compute_beta
;
;==============================================================================
function nlf_compute_beta, state

 nfree = state.nfree
 if(nfree EQ 0) then return, 0
 nobs = state.nobs

 a = (state.residuals / state.sigy^2) # make_array(nfree,val=1d)
 beta = -total(a*state.df, 1)		; 15.5.6, 15.5.8

 return, beta
end
;==============================================================================



;==============================================================================
; nlf_compute_alpha
;
;==============================================================================
function nlf_compute_alpha, state

 nfree = state.nfree
 if(nfree EQ 0) then return, 0
 nobs = state.nobs

 alpha = dblarr(nfree, nfree)

 for i=0, nfree-1 do $
    for j=0, nfree-1 do alpha[i,j] = $
           total(state.df[*,i]*state.df[*,j] / state.sigy^2)    ; 15.5.11

 return, alpha
end
;==============================================================================



;==============================================================================
; nlf_covariance
;
;==============================================================================
function nlf_covariance, state, sigma=sigma, norm=norm

 alpha = nlf_compute_alpha(state)
;;maybe use something besides invert here..
 cov = invert(alpha, /double)				; Eq. 15.5.15

 diag = diaggen(state.nfree, 1)
 sigma = sqrt(cov[diag])

 norm = sigma##sigma[*]

 sigma = sigma[*]

 return, cov
end
;==============================================================================



;==============================================================================
; nlf_fit_statistics
;
;==============================================================================
function nlf_fit_statistics, state, chisq, $
                    cov=cov, norm=norm, sig=sig, rms_sig=rms_sig, rms_nat=rms_nat

 nobs = state.nobs
 nfree = state.nfree
 ndf = nobs - nfree

 ;------------------------------------------------
 ; covariance matrix and formal uncertainties
 ;------------------------------------------------
 if(nfree GT 0) then cov = nlf_covariance(state, sig=sig, norm=norm)


 ;----------------------------------
 ; rms residual in units of 1 sigma
 ;----------------------------------
 res = state.residuals
 sigy = state.sigy

 nn = n_elements(res)

 rms_sig = sqrt(total((res/sigy)^2)/nobs)


 ;----------------------------------
 ; rms residual in native units
 ;----------------------------------
 rms_nat = sqrt(total(res^2)/nobs)


 ;----------------------------------
 ; reduced chisq
 ;----------------------------------
 reduced_chisq = chisq / ndf


 return, reduced_chisq
end
;==============================================================================



;==============================================================================
; nlf_show
;
;==============================================================================
pro nlf_show, state, chisq
 print, format='($, "			")' & help, chisq
end
;==============================================================================



;==============================================================================
; nint_newtfn
;
;==============================================================================
function nint_newtfn, x0
common nint_newtfn_block, n, a, c, xi, dchisqdx, diag

 cxi_x0 = c * ((xi-x0) ## make_array(n, val=1d))
 cxi_x0[diag] = 0

 return, dchisqdx - 2d*a*(xi-x0) - total(cxi_x0, 2)
end
;==============================================================================



;==============================================================================
; nlf_interp
;
;  Here we compute the location in parameter space of the chisq minimum,
;  assuming that we're sufficiently close that the chisq function may 
;  be treated as a paraboloid.  The shape is given by the chisq 2nd 
;  deriviatives contained in alpha and the absolute location in the
;  parameter space is determined by the chisq gradient at the current
;  location.
;
;==============================================================================
function nlf_interp, state, alpha, beta
common nint_newtfn_block, n, a, c, xi, dchisqdx, diag

 ;----------------------------------
 ; paraboloid coefficients
 ;----------------------------------
 diag = diaggen(state.nfree, 1)
 a = (alpha[diag])[*]
 c = 2d*alpha
 c[diag] = 0

 ;-------------------------------------
 ; use known gradient to find minimum
 ;-------------------------------------
 xi = state.parm
 dchisqdx = -2d*beta
 n = state.nfree

 x0 = newton(xi, 'nint_newtfn', /double)

 delta = x0 - xi 

 return, delta
end
;==============================================================================



;==============================================================================
; nlf_step
;
;==============================================================================
pro nlf_step, state, delta
 state.parm = state.parm + delta
end
;==============================================================================



;==============================================================================
; nlf_test_abort
;
;==============================================================================
function nlf_test_abort, state

 if(state.nokb) then return, 0

 c = strupcase(get_kbrd(0))
 if(c NE 'X') then return, 0

 print, 'abort detected'
 return, 1
end
;==============================================================================



;==============================================================================
; nlf_compute_chisq
;
;==============================================================================
function nlf_compute_chisq, state
 return, total(state.residuals^2/state.sigy^2)
end
;==============================================================================



;==============================================================================
; nlf_compute_state
;
;==============================================================================
pro nlf_compute_state, state, status=status

status = 0
 ;-------------------------------------
 ; compute function and derivatives
 ;-------------------------------------
 call_procedure, state.fn, state.x, state.parm, f, df
 state.f = f
 state.df = df

 ;-------------------------------------
 ; compute residuals
 ;-------------------------------------
 state.residuals = f - state.y

end
;==============================================================================



;==============================================================================
; nlf_minimize
;
;  Based on the algorithm described in NRC sec.15.5.
;
;==============================================================================
function nlf_minimize, state, epsilon=epsilon, ntries=ntries, silent=silent

 old_state = 0

 nlf_compute_state, state, status=status		; compute state
 chisq = nlf_compute_chisq(state)			; initial chisq
 if(NOT keyword_set(silent)) then nlf_show, state, chisq

 nfree = state.nfree
 if(state.nfree EQ 0) then return, chisq

 lambda = 0.001
 almost_done = (done = (abort = 0))


 ;------------------------------------------------------
 ; iterate toward minimum chisq
 ;------------------------------------------------------
 ntried = 0
 while(NOT done) do $
  begin
   ;--------------------------------
   ; compute chisq derivatives
   ;--------------------------------
   beta = nlf_compute_beta(state)			; chisq derivatives

   ;--------------------------------
   ; compute curvature matrix
   ;--------------------------------
   alpha = nlf_compute_alpha(state)			; curvature 
							;  (chisq 2nd derivs)
   ;----------------------------------
   ; compute scaled curvature matrix
   ;----------------------------------
   alpha_ = alpha	
   diag = diaggen(nfree, 1)
   alpha_[diag] = alpha[diag] * (1d + lambda)
   alpha_ = reform(alpha_, nfree, nfree, /over)		; Scaled curvature

   ;----------------------------------
   ; solve for the increments
   ;----------------------------------
   delta = make_array(nfree, val=0d)
   if(state.nfree GT 1) then $
    begin
     catch, err

     if(NOT keyword_set(err)) then $
      begin
       choldc, alpha_, p, /double
       delta = cholsol(alpha_, p, beta, /double)
      end $
     else $
      begin
       if(NOT keyword_set(silent)) then print, format='($, "o")'
       ntried = ntried + 1
      end

     catch, /cancel
    end $
   else delta = beta/alpha_

   ;------------------------------------
   ; take a step and compute new chisq
   ;------------------------------------
   old_state = state					; save current state
   nlf_step, state, delta				; update elements
   nlf_compute_state, state, status=status		; compute new state
   if(status NE 0) then abort = 1
   trial_chisq = nlf_compute_chisq(state)


   ;--------------------------------------------------------------------
   ; if chisq decreased, then accept this new state, otherwise, revert
   ; and decrease step size.
   ;--------------------------------------------------------------------
   if(trial_chisq GE chisq) then $
    begin
     if(NOT keyword_set(silent)) then print, format='($, ".")'
     lambda = lambda * 100d
     state = old_state
     ntried = ntried + 1
    end $
   else $
    begin
     if(abs(chisq - trial_chisq) LE epsilon) then almost_done = 1
     lambda = lambda / 10d
     chisq = trial_chisq
     if(NOT keyword_set(silent)) then nlf_show, state, chisq
     ntried = 0
    end
   if(ntried GE ntries) then almost_done = 1

   if(nlf_test_abort(state)) then abort = 1
   if(abort) then $
    begin
     abort = 0
     if(NOT almost_done) then almost_done = 1 $
     else done = 1
    end

   ;-----------------------------------------------------------------
   ; covariance matrix sometimes yields bad sigmas so here we allow
   ; the iteration to continue after reaching the solution until a
   ; valid matrix is obtained.
   ;-----------------------------------------------------------------
   if(almost_done) then $
    begin
     cov = nlf_covariance(state, sigma=sigma)
     w = where(finite(sigma))
     if(w[0] NE -1) then if(n_elements(w) EQ n_elements(sigma)) then done = 1 $
     else if(NOT keyword_set(silent)) then print, format='($, "*")'
    end
  end


 ;---------------------------------------------------------------------------
 ; interpolate using gradient beta and curvature matrix alpha 
 ;  This interplation is not very effective in practice, presumably because
 ;  the numerical derivatives near the solution are not very accurate.
 ;---------------------------------------------------------------------------
 if(NOT abort) then $
  begin
   old_state = state					; save current  state
   delta = nlf_interp(state, alpha, beta)
   nlf_step, state, delta				; update elements 
   nlf_compute_state, state, status=status		; compute new state
   trial_chisq = nlf_compute_chisq(state)
   if(trial_chisq GE chisq) then $
    begin
     state = old_state
    end $
   else $
    begin
     chisq = trial_chisq
     if(NOT keyword_set(silent)) then nlf_show, state, chisq
   end 
  end

 if(abort) then state = old_state


 return, chisq
end
;==============================================================================




;==============================================================================
; nlfit
;
;  Based on the algorithm described in NRC sec.15.5.
;
;==============================================================================
function nlfit, x, y, sigy, parm, sigparm, silent=silent, nokb=nokb, $
          chisq=chisq, rms=rms, epsilon=epsilon, ntries=ntries, fn=fn, labels=labels

 if(NOT keyword_set(epsilon)) then epsilon = 0.01
 if(NOT keyword_set(ntries)) then ntries = 20

 nfree = 0
 if(defined(parm)) then nfree = n_elements(parm)
 nobs = n_elements(x)


 df = 0
 if(nfree GT 0) then df = dblarr(nobs,nfree)

 ;----------------------------------------------
 ; build state structure
 ;----------------------------------------------
 state = { $
	 nokb:			keyword_set(nokb), $
	 labels:		labels, $
	 nfree:			nfree, $
	 nobs:			nobs, $
	 fn:			fn, $
	 x:			x, $
	 y:			y, $
	 sigy:			sigy, $
	 parm:			parm, $
	 residuals:		dblarr(nobs), $
	 f:			dblarr(nobs), $
	 df:			df }



 ;-----------------------------------------------------------------
 ; iterate toward minimum chisq
 ;-----------------------------------------------------------------
 chisq = nlf_minimize(state, epsilon=epsilon, ntries=ntries, silent=silent)
 if(NOT keyword_set(chisq)) then return, 0


 ;-----------------------------------------------------------------
 ; compute fit statistics
 ;-----------------------------------------------------------------
 reduced_chisq = nlf_fit_statistics(state, chisq, $
             cov=cov, norm=norm, sig=sig, rms_sig=rms_sig, rms_nat=rms_nat)


 ;-----------------------------------------------------------------
 ; print results
 ;-----------------------------------------------------------------
 if(NOT keyword_set(silent)) then $
           nlf_print_results, state, chisq, reduced_chisq, $
                                cov=cov, norm=norm, sig=sig, $
                                  rms_sig=rms_sig, rms_nat=rms_nat, res=res


 parm = state.parm
 if(nfree GT 0) then sigparm = sig

 chisq = reduced_chisq
 rms = rms_nat
 return, state.f
end
;==============================================================================
