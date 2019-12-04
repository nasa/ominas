;=============================================================================
;+
; NAME:
;	dsk_get_edge_elevation
;
;
; PURPOSE:
;	Computes elevations along the edge of a disk.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	z = dsk_get_edge_elevation(dkd, ta)
;
;
; ARGUMENTS:
;  INPUT:
;	dkd:	 Array (nt) of any subclass of DISK.
;
;	ta:	 Array (nta) of true anomalies at which to compute elevations.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	inner:	If set, the inner edge is used.
;
;	outer:	If set, the outer edge is used.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nt x nta) of elevations computed at each true anomaly on each 
;	disk.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dsk_get_edge_elevation, dkd, ta, inner=inner, outer=outer, $
    one_to_one=one_to_one, noevent=noevent
@core.include
 
 nv_notify, dkd, type = 1, noevent=noevent
 _dkd = cor_dereference(dkd)

 if(NOT keyword_set(inner)) then outer = 1

 if(keyword__set(inner)) then ii = 0 $
 else if(keyword__set(outer)) then ii = 1

 nta = n_elements(ta)
 nt = n_elements(_dkd)


 if(NOT keyword__set(one_to_one)) then $
  begin
   MM = make_array(nta,val=1)

   a = [reform([_dkd.sma[0,ii,*]])]#MM				; nt x nta

   nl = dsk_get_nl()
   sub = linegen3y(nt,nta,nl)

   l = (transpose(_dkd.l[*,ii,*]))[sub]			; nt x nta x nl
   il = (transpose(_dkd.il[*,ii,*]))[sub]		; nt x nta x nl
   taanl = (transpose(_dkd.taanl[*,ii,*]))[sub]		; nt x nta x nl
  end $
 else $
  begin
   a = tr(reform([_dkd.sma[0,ii,*]]))				; 1 x nta

   nl = dsk_get_nl()
   l = reform(transpose(_dkd.l[*,ii,*]), 1,nta,nl, /over)	; 1 x nta x nl
   il = reform(transpose(_dkd.il[*,ii,*]), 1,nta,nl, /over)	; 1 x nta x nl
   taanl = reform(transpose(_dkd.taanl[*,ii,*]), 1,nta,nl, /over)	; nt x nta x nl
  end


 return, dsk_shape_vertical(a, ta, l, il, taanl)
end
;===========================================================================
