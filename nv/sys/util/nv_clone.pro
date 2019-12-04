;==============================================================================
;+
; NAME:
;	nv_clone
;
;
; PURPOSE:
;       Allocates a new object as a copy of the given (existing) 
;	object.  All pointers in the new object are newly allocated.  
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	new_xd = nv_clone(xd, n)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 Object to clone.  May be any pointer or structure.
;
;	n:	 Number of clones to create.  Default is 1.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	protect:
;		String array giving the names of fields to be copied rather
;		than cloned.
;
;  OUTPUT: NONE
;
;
; RETURN: 
;       Newly created object with all fields identical to
;       the input object, and new pointers.
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
;==============================================================================



;=============================================================================
; nv_clone_match
;
;=============================================================================
function nv_clone_match, protect, tag

 if(NOT keyword_set(protect)) then return, 0
 w = where(strupcase(protect) EQ tag)
 return, w[0] NE -1
end
;==============================================================================



;=============================================================================
; nv_clone_recurse
;
;=============================================================================
pro nv_clone_recurse, xd, protect=protect

 type = size(xd, /type)
 n = n_elements(xd)

 ;----------------------------------------------
 ; pointer 
 ;----------------------------------------------
 if(type EQ 10) then $
  begin
   for i=0, n-1 do if(ptr_valid(xd[i])) then $
    begin
     xd[i] = nv_ptr_new(*xd[i]) 
     if(NOT nv_protected(*xd[i])) then nv_clone_recurse, *xd[i], protect=protect
    end
  end $
 ;----------------------------------------------
 ; structure 
 ;----------------------------------------------
 else if(type EQ 8) then $
  begin
   for i=0, n-1 do $
    begin
     ntags = n_tags(xd[i])
     tags = tag_names(xd[i])

     for j=0, ntags-1 do if(NOT nv_protected(tags[j])) then $
      if(NOT nv_clone_match(protect, tags[j])) then $
       begin
        val = xd[i].(j)
        nv_clone_recurse, val, protect=protect
        xd[i].(j) = val
       end
    end
  end $
 ;----------------------------------------------
 ; object 
 ;----------------------------------------------
 else if(type EQ 11) then $
  begin
   for i=0, n-1 do if(obj_valid(xd[i])) then $
    begin
     _xd = cor_dereference(xd[i])

     ntags = n_tags(_xd)
     tags = tag_names(_xd)

     for j=0, ntags-1 do if(NOT nv_protected(tags[j])) then $
      if(NOT nv_clone_match(protect, tags[j])) then $
       begin
        val = _xd.(j)
        nv_clone_recurse, val, protect=protect
        _xd.(j) = val
       end

     xd[i] = obj_new(obj_class(xd[i]))
     cor_rereference, xd[i], _xd
    end
  end

end
;=============================================================================



;=============================================================================
; nv_clone_single
;
;=============================================================================
function nv_clone_single, xd_0, noevent=noevent, protect=protect
@core.include
 nv_notify, xd_0, type = 1, noevent=noevent

 xd = xd_0
 nv_clone_recurse, xd, protect=protect
 return, xd
end
;=============================================================================



;=============================================================================
; nv_clone
;
;=============================================================================
function nv_clone, xd_0, n, noevent=noevent, protect=protect
@core.include
 nv_notify, xd_0, type = 1, noevent=noevent

 if(NOT keyword_set(n)) then n = 1

 xd = replicate(xd_0, n)
 for i=0, n-1 do xd[i] = nv_clone_single(xd_0, noevent=noevent, protect=protect)

 return, xd
end
;=============================================================================








;=============================================================================
; nv_clone
;
;=============================================================================
function ___nv_clone, xd_0, n, noevent=noevent, protect=protect
@core.include
 nv_notify, xd_0, type = 1, noevent=noevent

 xd = xd_0
 nv_clone_recurse, xd, protect=protect
 return, xd
end
;=============================================================================
