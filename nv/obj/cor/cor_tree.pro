;=============================================================================
;+
; NAME:
;	cor_tree
;
;
; PURPOSE:
;	Builds a class tree for the given descriptor.
;
;
; CATEGORY:
;	NV/SYS/COR
;
;
; CALLING SEQUENCE:
;	classes = cor_tree(od)
;
;
; ARGUMENTS:
;  INPUT:
;	od:	 Descriptor of any class.
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
; RETURN:
;	String array giving the names of all classes in od, in descending order.
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
;=============================================================================
function cor_tree, _od
@core.include

 od = _od
 class = cor_class(od)
 repeat $
  begin
   super = cor_class(od, /super)
   classes = append_array(classes, class)
   if(class EQ 'CORE') then return, classes
   od = obj_new('OMINAS_' + super[0],1)
   class = super
  endrep until(0)

end
;===========================================================================



