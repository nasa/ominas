;=============================================================================
;+
; NAME:
;	pg_select_bodies
;
;
; PURPOSE:
;	Selects bodies based on given criteria.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_select_bodies(bx, keyvals, od=od)
;
;
; ARGUMENTS:
;  INPUT:
;	bx:		Array of descriptors.
;
;	keyvals:	Structure containing the seletion keywords and values.
;
;	prefix:		Optional prefix for descriptor select keywords.  If
;			given, a keyword is matched without or without the 
;			prefix (including a '_'), and the prefixed version
;			takes precedence.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	od:		Observer descriptor; some selections require a
;			CAMERA, others will work with any subclass of BODY.
;			
;	Descriptor Select Keywords
;	--------------------------
;	Descriptor select keywords are combined with OR logic.  
;
;	  fov/cov:	Select all planets that fall within this many fields of
;			view (fov) (+/- 10%) from the center of view (cov).
;			Default cov is the camera optic axis.
;
;	  pix:		Select all planets whose apparent size (in pixels) is 
;			greater than or equal to this value.
;
;	  radmax:	Select all planets whose radius is greater than or 
;			equal to this value.
;
;	  radmin:	Select all planets whose radius is less than or 
;			equal to this value.
;
;	  distmax:	Select all planets whose distance is greater than or 
;			equal to this value.
;
;	  distmin:	Select all planets whose distance is less than or 
;			equal to this value.
;
;	  *nlarge:	Select n largest planets.
;
;	  *nsmall:	Select n smallest planets.
;
;	  *nclose:	Select n closst planets.
;
;	  *nfar:	Select n farthest planets.
;
;
; RETURN:
;	Array of subscripts for the descriptors in bx corresponding to the 
;	specified criteria.  !null if no selection criteria were applied.
;
;
; SEE ALSO:
; 	pg_cull_bodies
;
;
; STATUS:
;	Starred keywords are not yet implemented.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2017
;	
;-
;=============================================================================
function pg_select_bodies, bx, od=od, prefix=prefix, _extra=keyvals

 if(NOT keyword_set(keyvals)) then return, !null

 n = n_elements(bx)
 if(cor_class(od) EQ 'CAMERA') then cd = od

 sel = !null 

 nv_message, verb=0.2, 'Selection Criteria:'
 help, keyvals, out=s &  nv_message, /anon, verb=0.2, transpose(s[1:*])

 ;------------------------------------------------------------------------ 
 ; parameters
 ;------------------------------------------------------------------------ 
 if(keyword_set(cd)) then $ 
  begin
   pos = bod_pos(bx)
   if(n GT 1) then pos = reform(transpose(pos))
   cam_pos = bod_pos(cd)##make_array(n,val=1d)
   cam_scale = min(cam_scale(cd))
   cam_size = cam_size(cd)

   cov = extra_value(keyvals, 'cov', prefix)
   if(NOT keyword_set(cov)) then cov = cam_oaxis(cd)
   cov = cov#make_array(n,val=1d)

   dist = v_mag(cam_pos-pos)
   rad = body_radius(bx)

   theta = 2d*rad/dist
   mpix = theta/cam_scale
  end

 ;----------------------------------------------------------------------------- 
 ; fov -- select all bodies that fall within this many fovs (+/- 10%)
 ;-----------------------------------------------------------------------------
 fov = extra_value(keyvals, 'fov', prefix)
 if(keyword_set(fov)) then $
  if(keyword_set(cd)) then $
   begin
    fov = double(fov[0])
    cam_fov = min(cam_scale*cam_size)
    image_pts = inertial_to_image_pos(cd, pos)

    w = where(p_mag(image_pts-cov)-mpix LE fov*cam_fov/cam_scale*1.1)
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on field of view:'
      nv_message, verb=0.2, /anon, transpose(['   ' + cor_name(bx[w])])
     end
   end

 ;---------------------------------------------------------------------------- 
 ; pix -- select all bodies whose apparent size (in pixels) is GE this value
 ;----------------------------------------------------------------------------
 pix = extra_value(keyvals, 'pix', prefix)
 if(keyword_set(pix)) then $
  if(keyword_set(cd)) then $
   begin
    pix = double(pix[0])

    w = where(mpix GE pix)
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on apparent size:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
   end

 ;------------------------------------------------------------------------ 
 ; radmax -- select all bodies whose radius is GE this value
 ;------------------------------------------------------------------------
 radmax = extra_value(keyvals, 'radmax', prefix)
 if(keyword_set(radmax)) then $
  begin
   radmax = double(radmax[0])

   w = where(rad GE radmax)
   if(w[0] NE -1) then $
    begin
     sel = append_array(sel, w)
     nv_message, verb=0.2, 'Selected based on maximim radius:'
     nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
    end
  end

 ;------------------------------------------------------------------------ 
 ; radmin -- select all bodies whose radius is LE this value
 ;------------------------------------------------------------------------
 radmin = extra_value(keyvals, 'radmin', prefix)
 if(keyword_set(radmin)) then $
  begin
   radmin = double(radmin[0])

   w = where(rad LE radmin)
   if(w[0] NE -1) then $
    begin
     sel = append_array(sel, w)
     nv_message, verb=0.2, 'Selected based on minimum radius:'
     nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
    end
  end

 ;------------------------------------------------------------------------ 
 ; distmax -- select all bodies whose distance is LE this value
 ;------------------------------------------------------------------------
 distmax = extra_value(keyvals, 'distmax', prefix)
 if(keyword_set(distmax)) then $
  if(keyword_set(cd)) then $
   begin
    distmax = double(distmax[0])

    w = where(dist LE distmax)
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on maximum distance:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
   end

 ;------------------------------------------------------------------------ 
 ; distmin -- select all bodies whose distance is GE this value
 ;------------------------------------------------------------------------
 distmin = extra_value(keyvals, 'distmin', prefix)
 if(keyword_set(distmin)) then $
  if(keyword_set(cd)) then $
   begin
    distmin = double(distmin[0])

    w = where(dist GE distmin)
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on minimum distance:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
   end

 ;------------------------------------------------------------------------ 
 ; nlarge -- select n largest bodies
 ;------------------------------------------------------------------------
 nlarge = extra_value(keyvals, 'nlarge', prefix)
 if(keyword_set(nlarge)) then $
  begin
    nlarge = long(nlarge[0])

;    w = ...
;    if(w[0] NE -1) then $
;     begin
;      sel = append_array(sel, w)
;      nv_message, verb=0.2, 'Selected based on N largest:'
;      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
;     end
  end

 ;------------------------------------------------------------------------ 
 ; nsmall -- select n smallest bodies
 ;------------------------------------------------------------------------
 nsmall = extra_value(keyvals, 'nsmall', prefix)
 if(keyword_set(nsmall)) then $
  begin
    nsmall = long(nsmall[0])

;    w = ...
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on N smallest:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
  end

 ;------------------------------------------------------------------------ 
 ; nclose -- select n closest bodies
 ;------------------------------------------------------------------------
 nclose = extra_value(keyvals, 'nclose', prefix)
 if(keyword_set(nclose)) then $
  if(keyword_set(cd)) then $
   begin
    nclose = long(nclose[0])

;     w = ...
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on N closest:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
   end

 ;------------------------------------------------------------------------ 
 ; nfar -- select n farthest bodies
 ;------------------------------------------------------------------------
 nfar = extra_value(keyvals, 'nfar', prefix)
 if(keyword_set(nfar)) then $
  if(keyword_set(cd)) then $
   begin
    nfar = long(nfar[0])
;     w = ...
    if(w[0] NE -1) then $
     begin
      sel = append_array(sel, w)
      nv_message, verb=0.2, 'Selected based on N farthest:'
      nv_message, verb=0.2, /anon, transpose('   ' + cor_name(bx[w]))
     end
   end


 return, sel
end
;===========================================================================
