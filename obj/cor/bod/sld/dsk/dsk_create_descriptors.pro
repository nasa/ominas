;=============================================================================
;+
; NAME:
;	dsk_create_descriptors
;
;
; PURPOSE:
;	Init method for the DISK class.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dkd = dsk_create_descriptors(n)
;
;
; ARGUMENTS:
;  INPUT:
;	n:	Number of descriptors to create.
;
;  OUTPUT: NONE
;
;
; KEYWORDS (in addition to those accepted by all superclasses):
;  INPUT:  
;	dkd:	Disk descriptor(s) to initialize, instead of creating a new one.
;
;	sld:	Solid descriptor(s) instead of using sld_create_descriptors.
;
;	bd:	Body descriptor(s) to pass to bod_create_descriptors.
;
;	crd:	Core descriptor(s) to pass to cor_create_descriptors.
;
;	sma:	Array (ndv+1 x 2 x n) giving the semimajor axes and derivatives
;		for each edge. 
;
;	ecc:	Array (ndv+1 x 2 x n) giving the eccentricities and derivatives
;		for each edge.
;
;	radial_scale:	
;		Array (2 x n) giving radial scale coefficients.
;
;	nm:	Integer giving the number of radial harmonics in the ring
;		shape.
;
;	m:	Array (nm x 2 x n) giving the m value for each harmonic, for
;		each edge.
;
;	em:	Array (nm x 2 x n) giving the eccentricity for each harmonic, for
;		each edge.
;
;	tapm:	Array (nm x 2 x n) giving the true anomaly of periapse for each 
;		harmonic, for each edge.
;
;	dtapmdt:Array (nm x 2 x n) giving the tapm rate for each 
;		harmonic, for each edge.
;
;	libam:	Array (nm x 2 x n) giving the libration amplitude for each 
;		harmonic, for each edge.
;
;	libm:	Array (nm x 2 x n) giving the libration phase for each 
;		harmonic, for each edge.
;
;	dlibmdt:	Array (nm x 2 x n) giving the libration frequency for each 
;			harmonic, for each edge.
;
;	nl:	Integer giving the number of radial harmonics in the ring
;		shape.
;
;	_l:	Array (nl x 2 x n) giving the l value for each harmonic, for
;		each edge.  The leading underscore is needed to avoid 
;		conflict with other keywords.
;
;	il:	Array (l x 2 x n) giving the inclination for each harmonic, for
;		each edge.
;
;	taanl:	Array (nl x 2 x n) giving the true anomaly of periapse for each 
;		harmonic, for each edge.
;
;	dtaanldt:	Array (nl x 2 x n) giving the taanl rate for each 
;			harmonic, for each edge.
;
;	libal:	Array (nl x 2 x n) giving the libration amplitude for each 
;		harmonic, for each edge.
;
;	libl:	Array (nl x 2 x n) giving the libration phase for each 
;		harmonic, for each edge.
;
;	dlibldt:	Array (nl x 2 x n) giving the libration frequency for each 
;			harmonic, for each edge.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Newly created or or freshly initialized disk descriptors, depending
;	on the presence of the dkd keyword.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dsk_create_descriptors, n, crd=_crd0, bd=_bd0, sld=_sld0, dkd=_dkd0, $
@dsk__keywords_tree.include
end_keywords
@core.include
 if(NOT keyword_set(n)) then n = 1


 dkd = objarr(n)
 for i=0, n-1 do $
  begin
   if(keyword_set(_crd0)) then crd0 = _crd0[i]
   if(keyword_set(_bd0)) then bd0 = _bd0[i]
   if(keyword_set(_sld0)) then sld0 = _sld0[i]
   if(keyword_set(_dkd0)) then dkd0 = _dkd0[i]

   dkd[i] = ominas_disk(i, crd=crd0, bd=bd0, sld=sld0, dkd=dkd0, $
@dsk__keywords_tree.include
end_keywords)

  end


 return, dkd
end
;===========================================================================



