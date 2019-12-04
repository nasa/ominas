PRO xmlfile_opener_event, event
; This is a utility to open a widget to select an xml file
; and to destroy itself when done.
; It is used by read_pds and passes the name of the file through fstate.
; Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
   COMMON openercom,fstate 
   WIDGET_CONTROL, event.top, GET_UVALUE=fstate, /NO_COPY
   CASE event.DONE OF
      0: BEGIN
            fstate.file = event.VALUE
            WIDGET_CONTROL, event.top, SET_UVALUE=fstate, /NO_COPY
         END
         
       1: WIDGET_CONTROL, event.top, /DESTROY         

       2:  BEGIN
             PRINT, 'No File was selected'
             WIDGET_CONTROL, event.top, /DESTROY
          END
   ENDCASE
END
 

PRO xmlfile_opener
   COMMON openercom, fstate
   base = WIDGET_BASE(TITLE ='Open XML PDS File', /COLUMN)
   filesel = CW_FILESEL(base, /IMAGE_FILTER, FILTER='.xml',/FIX_FILTER,/frame)
   file=''
   fstate = {file:file}
   WIDGET_CONTROL, base, /REALIZE
   WIDGET_CONTROL, base, SET_UVALUE=fstate, /NO_COPY
   XMANAGER, 'xmlfile_opener', base
END
