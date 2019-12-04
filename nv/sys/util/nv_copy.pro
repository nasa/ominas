;==============================================================================
;+
; NAME:
;	nv_copy
;
;
; PURPOSE:
;	Copies all fields from one descriptor to another.  New pointers
;	are allocated only when the destination field is null.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_copy, dst_xd, src_xd
;
;
; ARGUMENTS:
;  INPUT:
;	dst_xd:	 Object to copy to.
;
;	src_xd:	 Object to copy from.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:  NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		3/2016
;	
;-
;==============================================================================



;=============================================================================
; nv_copy_is_scalar
;
;=============================================================================
function nv_copy_is_scalar, x
 type = size(x, /type)
 if(type EQ 8) then return, 0
 if(type EQ 10) then return, 0
 return, 1
end
;=============================================================================



;=============================================================================
; nv_copy_recurse
;
;=============================================================================
pro nv_copy_recurse, dst_xd, src_xd, alloc=alloc

 type = size(src_xd, /type)
 n = n_elements(dst_xd)

 ;----------------------------------------------
 ; pointer 
 ;----------------------------------------------
 if(type EQ 10) then $
  begin
   for i=0, n-1 do $
    begin
     if(ptr_valid(src_xd[i])) then $
      begin
       if(NOT ptr_valid(dst_xd[i])) then alloc = 1
       if(alloc) then dst_xd[i] = nv_ptr_new(*src_xd[i])

       if(nv_copy_is_scalar(*src_xd[i])) then *dst_xd[i] = *src_xd[i] $
       else nv_copy_recurse, *dst_xd[i], *src_xd[i], alloc=alloc
      end $
     else nv_free, dst_xd[i] 
    end
  end $
 ;----------------------------------------------
 ; structure 
 ;----------------------------------------------
 else if(type EQ 8) then $
  begin
   for i=0, n-1 do $
    begin
;;     if(nv_get_directive(xd[i]) EQ 'NV_STOP') then return

     for j=0, n_tags(src_xd[i])-1 do $
      begin
       if(nv_copy_is_scalar(src_xd[i].(j))) then dst_xd[i].(j) = src_xd[i].(j) $
       else nv_copy_recurse, dst_xd[i].(j), src_xd[i].(j), alloc=alloc
      end
    end
  end $
 ;----------------------------------------------
 ; structure 
 ;----------------------------------------------
 else if(type EQ 11) then $
  begin
   for i=0, n-1 do if(obj_valid(src_xd[i])) then $
    begin
     _src_xd = cor_dereference(src_xd[i])
     _dst_xd = cor_dereference(dst_xd[i])

;;     if(nv_get_directive(_xd) EQ 'NV_STOP') then return

     for j=0, n_tags(_src_xd)-1 do $
      begin
       if(nv_copy_is_scalar(_src_xd.(j))) then _dst_xd.(j) = _src_xd.(j) $
       else nv_copy_recurse, _dst_xd.(j), _src_xd.(j), alloc=alloc
      end

     cor_rereference, dst_xd[i], _dst_xd
    end
  end

end
;=============================================================================



;=============================================================================
; nv_copy
;
;=============================================================================
pro nv_copy, dst_xd, src_xd, noevent=noevent

 w = where(cor_class(dst_xd) NE cor_class(src_xd))
 if(w[0] NE -1) then nv_message, 'Source and destination must have the same class'

; if(cor_class(dst_xd) NE cor_class(src_xd)) then $
;    nv_message, 'Source and destination must have the same class'

 nv_notify, src_xd, type=1, noevent=noevent

 nv_copy_recurse, dst_xd, src_xd, alloc=0

 nv_notify, dst_xd, type=0, desc='ALL', noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;=============================================================================
