;=============================================================================
;+
; NAME:
;	dat_set_gd
;
;
; PURPOSE:
;	Updates a generic descriptor contained in an object.  This is a higher-
;	level interface to cor_set_gd that sorts descriptor inputs according 
;	to the data descriptors contained in their generic descriptors.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	dat_set_gd, xd, gd, <descriptor keywords>
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	Objects to modify.  The fields from any existing generic 
;		descriptors in these objects are retained in the new ones.
;		If these are data descriptors, then thesse are used for sorting
; 		any other input descriptors.
;
;	gd:	New generic descriptor.  If given, the other inputs are added 
;		to this structure and it replaces any eisting gd.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	<x>d:	Input keyword for each descriptor type.  These are sorted
;		according to associated data descriptors.
;
;
;  OUTPUT: NONE
;
;
; RETURN: NONE 
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro dat_set_gd, _xd, _gd, noevent=noevent, _extra=gdx

 xd = _xd
 if(keyword_set(_gd)) then gd = _gd

 ;---------------------------------
 ; get xd data descriptors
 ;---------------------------------
 if(cor_class(xd[0]) EQ 'DATA') then dd = xd $
 else dd = cor_gd(xd, /dd, noevent=noevent)
 if(NOT keyword_set(dd)) then return
 nxd = n_elements(xd)
 if(NOT keyword_set(gd)) then gd = bytarr(nxd)

 ;------------------------------------------------------------
 ; build gd for each xd based on its dd
 ;------------------------------------------------------------
 for i=0, n_elements(xd)-1 do $
  begin
   gdi = append_struct(gd[i], gdx)
   cor_set_gd, xd[i], append_struct(cor_gd(xd[i]), cor_associate_gd(gdi, dd[i]))
  end

end
;===========================================================================





;=============================================================================
pro ____dat_set_gd, xd, gd, noevent=noevent, _extra=gdx

 ;---------------------------
 ; get data descriptors
 ;---------------------------
 nxd = n_elements(xd)
 if(cor_class(xd[0]) EQ 'DATA') then dd = xd $
 else dd = cor_gd(xd, /dd, noevent=noevent)
 if(NOT keyword_set(dd)) then return

 ;--------------------------------------------------
 ; build an array of all xds contained in inputs
 ;--------------------------------------------------
 xds = cor_dereference_gd(gd)
 xds = append_array(xds, cor_dereference_gd(gdx))
 if(NOT keyword_set(xds)) then return

 ;--------------------------------------------------
 ; match input xds to xd generic descriptors
 ;--------------------------------------------------
;;;; field names get lost here because xds have been dereferenced.  Therefore
;;;; cds specified as ods do not get put in the gd as ods.
;;;; need to build new gdx for each dd to send to cor_set_gd as _extra arg

 for i=0, nxd-1 do $
   cor_set_gd, xd[i], xds=cor_associate_gd(xds, dd[i]), noevent=noevent





; dd_match = cor_gd(xds, /dd, /nocull, noevent=noevent)
; if(NOT keyword_set(dd_match)) then return

;stop
; for i=0, nxd-1 do $
;   begin
;    w = where(dd_match EQ dd[i])
;    if(w[0] NE -1) then cor_set_gd, xd[i], xds=xds[w], noevent=noevent
;   end









; gds = append_array(gd, gdx)
; if(NOT keyword_set(gds)) then return
; gdxs = dat_sort_gd(gds)







;if(cor_class(xd[0]) NE 'DATA') then stop
;stop
; dd_match = cor_gd(xds, /dd, noevent=noevent)
; if(NOT keyword_set(dd)) then $
;       for i=0, nxd-1 do cor_set_gd, xd[i], xds=xds, noevent=noevent $
; else for i=0, nxd-1 do $
;   begin
;    dd = cor_gd(xd[i], /dd)
;    if(keyword_set(dd)) then $
;     begin
;      w = where(dd_match EQ dd)
;      if(w[0] NE -1) then cor_set_gd, xd[i], xds=xds[w], noevent=noevent
;     end
;   end

end
;===========================================================================





;=============================================================================
pro ___dat_set_gd, xd, gd, noevent=noevent, _extra=gdx

 ;---------------------------
 ; get data descriptors
 ;---------------------------
 nxd = n_elements(xd)
 if(cor_class(xd[0]) EQ 'DATA') then dd = xd $
 else dd = cor_gd(xd, /dd, noevent=noevent)

 ;--------------------------------------------------
 ; build an array of all xds contained in inputs
 ;--------------------------------------------------
 xds = cor_dereference_gd(gd)
 xds = append_array(xds, cor_dereference_gd(gdx))
 if(NOT keyword_set(xds)) then return

 ;--------------------------------------------------
 ; match input xds to xd generic descriptors
 ;--------------------------------------------------
 _dd = cor_gd(xds, /dd, noevent=noevent)
 if(NOT keyword_set(dd)) then $
       for i=0, nxd-1 do cor_set_gd, xd[i], xds=xds, noevent=noevent $
 else for i=0, nxd-1 do $
   begin
    w = where(_dd EQ dd[i])
    if(w[0] NE -1) then cor_set_gd, xd[i], xds=xds[w], noevent=noevent
   end

end
;===========================================================================



