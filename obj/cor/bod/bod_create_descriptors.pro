;=============================================================================
;+
; NAME:
;	bod_create_descriptors
;
;
; PURPOSE:
;	Init method for the BODY class.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	bd = bod_create_descriptors(n)
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
;	bd:	Body descriptor(s) to initialize, instead of creating a new one.
;
;	crd:	Core descriptor(s) to pass to cor_create_descriptors.
;
;	time:	Array (n) of times, at body position, at which each descriptor 
;		is valid.
;
;	opaque:	Array (n) of flags describing whether each body is "easily 
;		visible".  
;
;	orient:	Array (3,3,n) of orientation matrices, transforming body to 
;		inertial for each body.
;
;	avel:	Array (ndv,3,n) of angular velocity vectors for each body. 
;
;	pos:	Array (ndv,3,n) of position vectors for each body. 
;
;	vel:	Array (ndv,3,n) of velocity vectors for each body. 
;
;	libv:	Array (ndv,3,n) of libration vectors for each body. 
;
;	lib:	Array (ndv,n) of libration phases for each body. 
;
;	dlibdt:	Array (ndv,n) of libration frequencies for each body. 
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Newly created or or freshly initialized body descriptors, depending
;	on the presence of the bd keyword.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;-
;=============================================================================
function bod_create_descriptors, n, crd=_crd0, bd=_bd0, $
@bod__keywords_tree.include
end_keywords
@core.include
 if(NOT keyword_set(n)) then n = 1

 bd = objarr(n)
 for i=0, n-1 do $
  begin
   if(keyword_set(_crd0)) then crd0 = _crd0[i]
   if(keyword_set(_bd0)) then bd0 = _bd0[i]

   bd[i] = ominas_body(i, crd=crd0, bd=bd0, $
@bod__keywords_tree.include
end_keywords)

  end
 

 return, bd
end
;===========================================================================



