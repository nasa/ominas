;=============================================================================
; ominas_point::init
;
;=============================================================================
function ominas_point::init, _ii, crd=crd0, ptd=ptd0, $
@pnt__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(ptd0)) then struct_assign, ptd0, self
 void = self->ominas_core::init(ii, crd=crd0, $
@cor__keywords.include
end_keywords)


 ;-------------------------------------------------------------------------
 ; Handle index errors: set index to zero and try again.  This allows a 
 ; single input to be applied to multiple objects, via multiple calls to
 ; this method.  In that case, all inputs must be given as single inputs.
 ;-------------------------------------------------------------------------
 catch, error
 if(error NE 0) then $
  begin
   ii = 0
   catch, /cancel
  end

 
 ;---------------------------------------------------------------
 ; assign initial values
 ;---------------------------------------------------------------
 self.abbrev = 'PNT'
 self.tag = 'PTD'

 ;-----------------------
 ; desc
 ;-----------------------
 if(keyword_set(desc)) then pnt_set_desc, self, desc[ii]
; if(keyword_set(desc)) then self.desc = desc[ii]

 ;-----------------------
 ; points
 ;-----------------------
 if(keyword_set(points)) then $
  begin
   self.points_p = nv_ptr_new(points[*,*,ii])

   dim = size(points, /dim)
   ndim = n_elements(dim)
   nv = (nt = 1)
   if(ndim GT 1) then nv = dim[1]
   if(ndim GT 2) then nt = dim[2]
  end

 ;-----------------------
 ; vectors
 ;-----------------------
 if(keyword_set(vectors)) then $
  begin
   self.vectors_p = nv_ptr_new(vectors[*,*,ii])

   dim = size(vectors, /dim)
   ndim = n_elements(dim)
   nvv = (ntv = 1)
   nvv = dim[0]
   if(ndim GT 2) then ntv = dim[2]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvv
     nt = ntv
    end $
   else if((nvv NE nv) OR (ntv NE nt)) then $
                     nv_message, 'Incompatible vector array dimensions.'
  end

 ;-----------------------
 ; flags
 ;-----------------------
 if(NOT defined(flags)) then $
           if(keyword_set(nv)) then flags = bytarr(nv)

 if(defined(flags)) then $
  begin
   self.flags_p = nv_ptr_new(flags)

   dim = [1]
   if(n_elements(flags) GT 1) then dim = size(flags, /dim)
   ndim = n_elements(dim)
   nvf = dim[0]
   ntf = 1
   if(ndim GT 1) then ntf = dim[1]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvf
     nt = ntf
    end $
   else if((nvf NE nv) OR (ntf NE nt)) then $
                         nv_message, 'Incompatible flag array dimensions.'
  end


 ;--------------------------
 ; point-by-point data
 ;--------------------------
 if(keyword_set(data)) then $
  begin
   self.data_p = nv_ptr_new(data[*,*,ii])

   dim = size(data, /dim)
   ndim = n_elements(dim)
   nvd = (ntd = 1)
   ndat = dim[0]
   if(ndim GT 1) then nvd = dim[1]
   if(ndim GT 2) then ntd = dim[2]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvd
     nt = ntd
    end $
   else if((nvd NE nv) OR (ntd NE nt)) then $
              nv_message, 'Incompatible point-by-point data array dimensions.'
  end


 ;--------------------------
 ; point-by-point data tags
 ;--------------------------
 if(keyword_set(tags)) then $
  begin
   self.tags_p = nv_ptr_new(tags[*,ii])

   dim = size(tags, /dim)
   ndim = n_elements(dim)
   nvt = dim[0]

   if(keyword_set(ndat)) then $
       if(nvt NE ndat) then nv_message, 'Incompatible tags array dimensions.'
  end


 ;--------------------------
 ; dimensions
 ;--------------------------
 self.nv = (self.nt = 0)
 if(keyword_set(nv)) then self.nv = nv[ii]
 if(keyword_set(nt)) then self.nt = nt[ii]


 if(keyword_set(assoc_xd)) then self.__protect__assoc_xd = assoc_xd[ii]

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_point__define
;
;
; PURPOSE:
;	Structure for managing points.
;
;
; CATEGORY:
;	NV/OBJ/PNT
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	desc:		Data set description.
;
;	points_p:	Pointer to image points.
;
;	vectors_p:	Pointer to inertial vectors.
;
;	data_p:		Pointer to a point-by-point user data array.
;
;	tags_p:		Tags for point-by-point user data.
;
;	flags_p:	Pointer to point-by-point flag array.
;
;	nv:		Number of elements in the nv direction.
;
;	nt:		Number of elements in the nt direction.
;
;	assoc_xd:	Associated descriptor. 
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pg_points_struct__define
;	
;-
;=============================================================================
pro ominas_point__define

 struct={ominas_point, inherits ominas_core, $
		desc:		'', $		; data set description
		points_p:	ptr_new(), $	; image points
		vectors_p:	ptr_new(), $	; inertial vectors
		flags_p:	ptr_new(), $	; flags
		data_p:		ptr_new(), $	; point-by-point user data
		tags_p:		ptr_new(), $	; tags for p-b-p user data
		nv:		0l, $
		nt:		0l, $
		__PROTECT__assoc_xd: 	obj_new() $	; Associated descriptor
	}

end
;===========================================================================



