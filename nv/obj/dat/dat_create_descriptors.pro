;=============================================================================
;+
; NAME:
;	dat_create_descriptors
;
;
; PURPOSE:
;	Creates and initializes a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dd = dat_create_descriptors(n)
;
;
; ARGUMENTS:
;  INPUT: 
;	n:	 Number of descriptors to create.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	filename:	Name of data file.
;
;	dim:		Array giving the dimensions of the data array.
;
;	typecode:	Integer giving the type code of the data array.
;
;	data:		Data array.
;
;	nhist:		Number of past version of the data array to archive.
;			If not given, the environment variable NV_NHIST is
;			used.  If that is not set, then nhist defaults to 1.
;
;	header:		Header array.
;
;	filetype:	Filetype identifier string.  If not given
;			an attempt is made to detect it.
;
;	input_fn:	Name of function to read data file.
;
;	output_fn:	Name of function to write data file.
;
;	keyword_fn:	Name of function to read/write header keywords.
;
;	instrument:	Instrument string.  If not given an
;			attempt is made to detect it.
;
;	input_transforms:	String array giving the names of the
;				input transforms.
;
;	output_transforms:	String array giving the names of the
;				output transforms.
;
;	maintain:	Data maintenance mode.
;
;	compress:	Compression suffix.
;
;
;  OUTPUT: NONE
;	input_translators:	String array giving the names of the
;				input translators.
;
;	output_translators:	String array giving the names of the
;				output translators.
;
;
;
; RETURN:
;	Newly created and initialized data descriptor.
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
function dat_create_descriptors, n, crd=_crd0, dd=_dd0, $
@dat__keywords_tree.include
end_keywords
@core.include
 if(NOT keyword_set(n)) then n = 1

 dd = objarr(n)
 for i=0, n-1 do $
  begin
   if(keyword_set(_crd0)) then crd0 = _crd0[i]
   if(keyword_set(_dd0)) then dd0 = _dd0[i]

   dd[i] = ominas_data(i, crd=crd0, dd=dd0, $
@dat__keywords_tree.include
end_keywords)

  end
 
 return, dd
end
;===========================================================================



