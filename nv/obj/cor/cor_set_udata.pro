;=============================================================================
;+
; NAME:
;	cor_set_udata
;
;
; PURPOSE:
;	Stores user data in a descriptor and associates it with the 
;	specified name. If multiple descriptors, then the trailing dimension 
;	must match the number of descriptors.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	cor_set_udata, crx, name, data
;
;
; ARGUMENTS:
;  INPUT:
;	crx:	 Any subclass of CORE.  Only one descriptor may be provided.
;
;	name:	 Name to associate with the data.  If the name already exists,
;		 then the data are overwritten.  If null string given, it is
;		 assumed that a udata pointer is given in the udata argument
;		 and the current pointer is replaced. 
;
;	data:	 Data to store.  If multiple crx supplied, then the trailing 
;		 dimension must match the number of descriptors unless /all.
;
;	all:	 If set, the data array is applied to every descriptor.
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
; RETURN: NONE
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
pro cor_set_udata, crd, name, udata, all=all, noevent=noevent
@core.include

 if(NOT defined(udata)) then return

 _crd = cor_dereference(crd)

 if(NOT keyword_set(name)) then _crd.udata_tlp = udata $
 else $
  begin
   tlp = _crd.udata_tlp
   n = n_elements(_crd)

   ;-----------------------------
   ; one descriptor
   ;-----------------------------
   if(n EQ 1) then $
    begin
     tag_list_set, tlp, name, udata, index=index
     _crd.udata_tlp = tlp
    end $
   ;-------------------------------
   ; /all
   ;-------------------------------
   else if(keyword_set(all)) then for i=0, n-1 do  $
    begin
     _tlp = tlp[i]
     tag_list_set, _tlp, name, udata
     tlp[i] = _tlp
    end $
   ;-----------------------------------
   ; more than one descriptor not /all
   ;-----------------------------------
   else if(n_elements(udata) EQ n) then for i=0, n-1 do $
    begin
     _tlp = tlp[i]
     tag_list_set, _tlp, name, udata[i]
     tlp[i] = _tlp
    end $
   else $
    begin
     type = size(udata, /type)
     dim = size(udata, /dim)
     ndim = n_elements(dim) - 1
     nn = dim[ndim]
     dim = dim[0:ndim-1]

     if(nn NE n) then nv_message, 'Inconsistent array.'

     ss = replicate({x:make_array(type=type, dim=dim)}, n)
     ss.x = udata

     for i=0, n-1 do tag_list_set, tlp[i], name, ss[i].x, index=index
    end

   _crd.udata_tlp = tlp
  end


 cor_rereference, crd, _crd
 nv_notify, crd, type = 0, noevent=noevent
end
;=============================================================================
