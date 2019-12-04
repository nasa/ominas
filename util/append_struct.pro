;=============================================================================
;+
; NAME:
;	append_struct
;
;
; PURPOSE:
;	Concatenates two structures; even if one is undefined or "unset".
;	This routine is intended to be used as a replacement for the 
;	syntax: result = create_struct(struct1, struct2), except that neither 
;	struct requires checking.
;
;
; CATEGORY:
;	UTIL
;
;
; CALLING SEQUENCE:
;	result = append_struct(struct1, struct2)
;
;
; ARGUMENTS:
;  INPUT:
;	struct1:	First structure.  If undefined, the second structure is 
;			returned.
;
;	struct2:	Second structure.  If undefined, the first structure is 
;			returned.  If duplicate fields exist, the output 
;			field will be an array of the unique elements from both
;			input structures.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	fast:		If set, no checking is performed to ensure structure
;			tags are not duplicated.
;
;	replace:	If set, duplicate fields in struct2 replace those 
;			from struct1 instead of concatenating them.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Concatentated structure.
;
;
; STATUS:
;	Complete
;
;

; MODIFICATION HISTORY:
; 	Written by:	Spitale		2/2017
;	
;-
;=============================================================================



;=============================================================================
; append_struct_cat
;
;=============================================================================
function append_struct_cat, s1, s2, fast=fast, replace=replace

 if(keyword_set(fast)) then return, create_struct(s1, s2)

 tags1 = tag_names(s1)
 tags2 = tag_names(s2)

 w = nwhere(tags1, tags2)
 if(w[0] EQ -1) then return, create_struct(s1, s2)

 all_tags = unique([tags1, tags2])
 for i=0, n_elements(all_tags)-1 do $
  begin
    w1 = (where(all_tags[i] EQ tags1))[0]
    w2 = (where(all_tags[i] EQ tags2))[0]

    field = 0
    if(NOT keyword_set(replace)) then $
     begin
      if(w1 NE -1) then field = append_array(field, s1.(w1))
      if(w2 NE -1) then field = append_array(field, s2.(w2))
     end $
    else $
     begin
      if(w1 NE -1) then field = s1.(w1)
      if(w2 NE -1) then field = s2.(w2)
     end

    result = append_struct(result, $
                  create_struct(all_tags[i], unique(field)), /fast)
  end

 return, result
end
;=============================================================================



;=============================================================================
; append_struct
;
;=============================================================================
function append_struct, struct1, struct2, fast=fast, replace=replace

 if(NOT keyword_set(struct2)) then $
  begin
   if(keyword_set(struct1)) then return, struct1
   return, 0
  end

 if(NOT keyword_set(struct1)) then return, struct2
 return, append_struct_cat(struct1, struct2, fast=fast, replace=replace)
end 
;=============================================================================
