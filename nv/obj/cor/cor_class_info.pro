;=============================================================================
;+
; NAME:
;	cor_class_info
;
;
; PURPOSE:
;	Returns information about OMINAS object classes.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	cor_class_info, class=class, abbrev=abbrev, tag=tag
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	class:		String array giving the names of all OMINAS classes. 
;
;	abbrev:		String array giving the abbreviations of OMINAS classes. 
;
;	tag:		String array giving the tag names of OMINAS classes. 
;
;
;
; RETURN: NONE
;
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================
pro cor_class_info, class=class, abbrev=abbrev, tag=tag
common cor_class_info_block, _class, _abbrev, _tag

  
 ;------------------------------------------------
 ; return prior results if available
 ;------------------------------------------------
 if(keyword_set(_class)) then $
  begin
   class = _class
   abbrev = _abbrev
   tag = _tag
   return
  end

 ;------------------------------------------------
 ; get classes from directory structure
 ;------------------------------------------------
 alldirs = file_search(getenv('OMINAS_DIR') + '/nv/obj/*', /test_dir, /mark_dir)
 defs = file_search(alldirs+'ominas_*__define.pro')
 dirs = file_dirname(defs)
 defs = file_basename(defs)
 class = strupcase(str_nnsplit(strmid(defs, 7, 128), '__'))
 nclass = n_elements(class)

 ;------------------------------------------------
 ; create prototype objects and get abbrev an tag
 ;------------------------------------------------
 xd = objarr(nclass)
 for i=0, nclass-1 do xd[i] = obj_new('ominas_'+class[i])

 abbrev = cor_abbrev(xd)
 tag = cor_tag(xd)




end
;===========================================================================
