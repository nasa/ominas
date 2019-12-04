; docformat = 'rst'
;=======================================================================
;+
; MULTI-MISSION EXAMPLE
; ---------------------
;
;  Created by Joe Spitale
;
;    This example file loads images from various missions onto planes of a 
;    GRIM window and computes the centers of all available planets for each
;    image to demonstrates OMINAS' multi-mission capabilities.  
;
;    This example file can be executed from the shell prompt in the ominas/demo
;    directory using::
;
;     ominas multimission_example.pro
;
;    or from within an OMINAS IDL session using::
;
;     @multimission_example.pro
;     
;   Load the 3 images into grim, with planet centers as overlays::
;   
;     grim, over='center', dat_read(getenv('OMINAS_DIR')+'/demo/data/'+ $
;     ['N1350122987_2.IMG','2100r.img','c3440346.gem'])
;     
;   The Jupiter observation (from Cassini, the first one displayed in grim) 
;   looks like::
;   
;   .. image:: graphics/multimiss_ex_1.png
;   
;   And the Ganymede observation (from Galileo) looks like::
;   
;   .. image:: graphics/multimiss_ex_2.png
;   
;   (that image is in the second plane in grim: use the Plane->next menu 
;    option, or click the black double right-arrow button on the left side 
;    of the top toolbar to switch planes)
;   
;   And the Saturn observation (from Voyager) looks like::
;   
;   .. image:: graphics/multimiss_ex_3.png
;   
;   (that image is in the third plane in grim: use the
;    Plane->next menu option, or click the black double right-arrow button on the left
;    side of the top toolbar to switch planes)
;-
;-------------------------------------------------------------------------
!quiet = 1
grim, over='center', dat_read(getenv('OMINAS_DIR')+'/demo/data/'+ $
                  ['N1350122987_2.IMG','2100r.img','c3440346.gem'])
                   
