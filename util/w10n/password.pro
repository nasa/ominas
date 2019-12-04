;+
; NAME:
;       PASSWORD
;
; PURPOSE:
;
;       This is a utility to allow the user to type a password
;       in a text widget. The user sees only asterisks.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       2642 Bradbury Court
;       Fort Collins, CO 80521 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:

;       Utilities
;
; CALLING SEQUENCE:
;       password = Password(Group_Leader=widgetID)
;
; Keywords:
;       GROUP_LEADER -- This keyword should be supplied if you want
;          this pop-up dialog to be a MODAL widget. (And, believe me,
;          you do.) The only reason you wouldn't use this keyword is
;          if you are calling this program from the IDL command line.
;          Set the keyword to the identifier of a widget who will be
;          the group leader of this widget program.
;
; MODIFICATION HISTORY:
;       Written by:  David Fanning 26 July 1999.
;-

PRO Password_Event, event

; This event handler for the password widget. Asterisks are returned.

IF event.type EQ 0 THEN BEGIN
   IF event.ch EQ 10 THEN BEGIN
      Widget_Control, event.top, /Destroy
      RETURN
   ENDIF
ENDIF

   ; Deal with simple one-character insertion events.

IF event.type EQ 0 THEN BEGIN

      ; Get the current text in the widget and find its length.

   Widget_Control, event.id, Get_Value=text
   text = text[0]
   length = StrLen(text)

      ; Store the password and return asterisks.

   selection = Widget_Info(event.id, /Text_Select)

      ; Insert the character at the proper location.

   Widget_Control, event.id, /Use_Text_Select, Set_Value='*'

      ; Update the current insertion point in the text widget.

   Widget_Control, event.id, Set_Text_Select=event.offset + 1

      ; Store the password.

   Widget_Control, event.top, Get_UValue=ptr
   IF *ptr EQ "" THEN *ptr=String(event.ch) ELSE $
      *ptr = *ptr + String(event.ch)

ENDIF ; of insertion event

   ; Deal with deletion events.

IF event.type EQ 2 THEN BEGIN

      ; Get the current text password.

   Widget_Control, event.top, Get_UValue=ptr
   text = *ptr
   length = StrLen(text)

      ; Put it back with the deletion subtracted.

   *ptr = StrMid(text, 0, length-event.length)
   passwordLen = StrLen(*ptr)
   Widget_Control, event.id, Set_Value=passwordlen ? Replicate('*', passwordLen) : ''

      ; Reset the text insertion point in the text widget.

   Widget_Control, event.id, Set_Text_Select=event.offset
ENDIF

Widget_Control, event.top, Set_UValue=ptr

END ;-------------------------------------------------------------------------


Function Password, Group_Leader=group_leader,prompt=prompt

   ; Create widgets. MUST use GROUP_LEADER to create MODAL widget.

IF N_Elements(group_leader) EQ 0 THEN BEGIN
   tlb = Widget_Base(Title='Enter Password...', Row=1)
ENDIF ELSE BEGIN
   tlb = Widget_Base(Title='Enter Password...', Row=1, /Modal, Group_Leader=group_leader)
ENDELSE
prompt=n_elements(prompt) ? prompt : 'Password:'
label = Widget_Label(tlb, Value=prompt)
text = Widget_Text(tlb, Scr_XSize=150, All_Events=1, Editable=0)
cgCenterTLB, tlb
Widget_Control, tlb, /Realize
ptr = Ptr_New("")
Widget_Control, tlb, Set_UValue=ptr

   ; A blocking widget if GROUP_LEADER has not made it modal

XManager, 'password', tlb

   ; Return the password after it has been filled out.

thePassword = *ptr
Ptr_Free, ptr
RETURN, thePassword
END