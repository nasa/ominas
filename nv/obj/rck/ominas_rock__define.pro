;=============================================================================
; ominas_rock::init
;
;=============================================================================
function ominas_rock::init, _ii, crd=crd0, bd=bd0, sld=sld0, rkd=rkd0, $
@rck__keywords_tree.include
end_keywords
@core.include
 
 if(keyword_set(_ii)) then ii = _ii
 if(NOT keyword_set(ii)) then ii = 0 


 ;---------------------------------------------------------------
 ; set up parent class
 ;---------------------------------------------------------------
 if(keyword_set(rkd0)) then struct_assign, rkd0, self
 void = self->ominas_solid::init(ii, crd=crd0, bd=bd0, sld=sld0, $
@sld__keywords_tree.include
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
 self.abbrev = 'RCK'
 self.tag = 'RKD'
 self.vertices_p = nv_ptr_new(0)
 self.faces_p = nv_ptr_new(0)
 self.nv = 0
 self.nf = 0

 ;-----------------------
 ; vertices
 ;-----------------------
 if(keyword_set(vertices)) then $
  begin
   *self.vertices_p = vertices[*,*,ii]
   dim = size(vertices, /dim)
   self.nv = dim[1]
  end


 ;-----------------------
 ; faces
 ;-----------------------
 if(keyword_set(faces)) then $
  begin
  *elf.faces_p = faces[*,*,ii]
   dim = size(faces, /dim)
   self.nf = dim[1]
  end


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_rock__define
;
;
; PURPOSE:
;	Class structure for the ROCK class.
;
;
; CATEGORY:
;	NV/LIB/ROCK
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	vertices_p:	Pointer to array of body-frame vertex points.
;
;	faces_p:	Pointer to array (3,nfaces) of vertex indices defining 
;			each face.
;
;	nv:		Number of vertices.
;
;	nt:		Number of faces.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2018
;	
;-
;=============================================================================
pro ominas_rock__define

 struct = $
    { ominas_rock, inherits ominas_solid, $
	vertices_p:	ptr_new(), $		; Body-frame vertex coordinates
	faces_p:	ptr_new(), $		; Vertex indices defining each face
	nv:		0l, $
	nf:		0l $
    }

end
;===========================================================================
