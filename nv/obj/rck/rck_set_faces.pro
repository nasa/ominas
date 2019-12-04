;=============================================================================
;+
; NAME:
;	rck_set_faces
;
;
; PURPOSE:
;	Replaces faces in a ROCK object.
;
;
; CATEGORY:
;	NV/OBJ/RCK
;
;
; CALLING SEQUENCE:
;	rck_set_faces, rkd, faces
;
;
; ARGUMENTS:
;  INPUT:
;	rkd:		ROCK object.
;
;	faces:		New faces array.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	noevent:	If set, no event is generated.
;
;	subscripts:	Array indicating which faces to replace.  Must match
;			the faces argument.
;
;	append:		If set, faces are appended to the face list instead
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
;	rck_faces
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale		12/2018
;	
;-
;=============================================================================
pro rck_set_faces, rkd, faces, subscripts=subscripts, noevent=noevent
@core.include
 _rkd = cor_dereference(rkd)

 if(keyword_set(append)) then $
                      new_faces = append_array(*_rkd.faces_p, faces) $
 else if(keyword_set(subscripts)) then $
  begin
   new_faces = *_rkd.faces_p
   new_faces[*,subscripts] = faces
  end $
 else new_faces = faces

 *_rkd.faces_p = new_faces
 dim = size(faces, /dim)
 _rkd.nf = dim[1]

 cor_rereference, rkd, _rkd
 nv_notify, rkd, type = 0, noevent=noevent
 nv_notify, /flush, noevent=noevent
end
;===========================================================================
