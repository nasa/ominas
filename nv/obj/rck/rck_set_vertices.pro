;=============================================================================
;+
; NAME:
;	rck_set_vertices
;
;
; PURPOSE:
;	Replaces vertices in a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	rck_set_vertices, rkd, vertices
;
;
; ARGUMENTS:
;  INPUT:
;	rkd:		ROCK object.
;
;	vertices:	New vertices array.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
;
;	subscripts:	Array indicating which vertices to replace.  Must match
;			the vertices argument.
;
;	append:		If set, vertices are appended to the vertex list instead
;			of replacing the list.  This keyword supercedes the
;			subscripts keyword.
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
; SEE ALSO:
;	rck_vertices
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		12/2018
;	
;-
;=============================================================================
pro rck_set_vertices, rkd, vertices, subscripts=subscripts, noevent=noevent
@core.include
 _rkd = cor_dereference(rkd)

 if(keyword_set(append)) then $
                      new_vertices = append_array(*_rkd.vertices_p, vertices) $
 else if(keyword_set(subscripts)) then $
  begin
   new_vertices = *_rkd.vertices_p
   new_vertices[*,subscripts] = vertices
  end $
 else new_vertices = vertices

 *_rkd.vertices_p = new_vertices
 dim = size(vertices, /dim)
 _rkd.nv = dim[1]

 cor_rereference, rkd, _rkd
 nv_notify, rkd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
