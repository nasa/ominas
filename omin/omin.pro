;=============================================================================
;+-+
; NAME:
;	OMIN --  OMINAS Installer
;
;
; PURPOSE:
;	Graphical installer for OMINAS.
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	omin
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	NONE
;
;
;
; STATUS:
;	Incomplete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2017
;	
;-
;=============================================================================



;=============================================================================
; omin_event
;
;=============================================================================
pro omin_event, event

 ;-----------------------------------------------
 ; get form base and data
 ;-----------------------------------------------
 base = event.top
 widget_control, base, get_uvalue=data

 ;-----------------------------------------------
 ; get form value structure
 ;-----------------------------------------------
 widget_control, event.id, get_value=value


 ;-----------------------------------------------
 ; switch on item tag
 ;-----------------------------------------------
 if(size(value, /type) EQ 7) then $
  case strupcase(value) of
   ;---------------------------------------------------------
   ; 'Exit' button: Destroy the form
   ;---------------------------------------------------------
   'EXIT' : widget_control, base, /destroy

   ;---------------------------------------------------------
   ; 'Reset' button: Reset configuration
   ;---------------------------------------------------------
   'RESET' : omin_reset, data

   else: 
  endcase


end
;=============================================================================



;=============================================================================
; omin
;
;=============================================================================
pro omin



 ;----------------------------------
 ; widgets
 ;----------------------------------
 base = widget_base(title='OMIN -- OMINAS Installer', /tlb_size_events, /column)

 fixed_base = widget_base(base, /column)
 scroll_base = widget_base(base, /scroll, /column)

 button_base = widget_base(base, /row)
 exit_button = widget_button(button_base, value='Exit')
 reset_button = widget_button(button_base, value='Reset')


 ;----------------------------------
 ; packages
 ;----------------------------------
 


 widget_control, /realize, base
 xmanager, 'omin', base

end
;=============================================================================
