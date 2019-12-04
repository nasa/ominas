;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
;
; NAME:
;    REMOVE_TAGS
;       
; PURPOSE:
;    remove the specified tags from input structure
;
; CALLING SEQUENCE:
;    remove_tags, oldstruct, tagnames, newstruct
;
; INPUTS: 
;    oldstruct: the original structure
;    tagnames: the names of tags to be removed (can be an array)
;
; OPTIONAL INPUTS:
;    NONE.
;
; KEYWORD PARAMETERS:
;    NONE.
;       
; OUTPUTS: 
;    newstruct: the new structure without tags.
;
; OPTIONAL OUTPUTS:
;    NONE
;
; CALLED ROUTINES:
;    
; 
; PROCEDURE: 
;    
;	
;
; REVISION HISTORY:
;    ????? Judith Racusin
;    25-OCT-2000 Modified to handle arbitrary tag types. Also error 
;          handling. Erin Scott Sheldon
;       
;                                      
;-                                       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRO remove_tags, struct, tagnames, newstruct

  IF n_params() EQ 0 THEN BEGIN 
      print,'Syntax - remove_tags, oldstruct, tagnames, newstruct'
      print
      print,'Use doc_library,"remove_tags"  for more help.'  
      return
  END

  ;; Figure out which tags get removed

  tags=get_tags(struct)
  n=n_elements(tags)
  tagnames=strupcase(tagnames)
  nt=n_elements(tagnames)
  IF nt EQ 1 THEN BEGIN
      t=where(tags NE tagnames[0],nw) 
      IF nw EQ n THEN BEGIN
          print,'-----------------------------------------------------'
          message,'Tag did not match, structure unchanged',/inf
          print,'-----------------------------------------------------'
          newstruct = struct
          return
      ENDIF 
  ENDIF ELSE BEGIN 
      match,tags,tagnames,m
      IF m[0] EQ -1 THEN BEGIN
          print,'-------------------------------------------------'
          message,'No tags matched, structure unchanged',/inf
          print,'-------------------------------------------------'
          newstruct=struct
          return
      ENDIF 
      nm=n_elements(m)
      IF nm EQ n THEN BEGIN 
          print,'-------------------------------------------------------------'
          message,'This would remove all tags! structure unchanged',/inf
          print,'-------------------------------------------------------------'
          newstruct=struct
          return
      ENDIF 
      t=lindgen(n)
      remove, m, t
  ENDELSE 
      
  ;; create new structure
  tags=tags[t]
  n=n_elements(tags)

  newstruct=create_struct(tags[0],struct[0].(t[0]))
  
  FOR i=1L, n-1 DO newstruct = create_struct(temporary(newstruct), $
                                             tags[i], struct[0].(t[i]) )

  newstruct=replicate( temporary(newstruct), n_elements(struct) )
  struct_assign,struct,newstruct

  return
END
