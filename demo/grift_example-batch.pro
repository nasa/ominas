; docformat = 'rst'
;===============================================================================
;+
;                            GRIFT EXAMPLE
;
;  Created by Joe Spitale
;
;  This example script demonstrates the usage of the GRIM interface program
;  GRIFT.  GRIFT swindles GRIM into giving up references to its descriptor set
;  so they can be used against it by some foreign agent.  
;
;  This example file can be executed from the shell prompt in the ominas/demo
;  directory using::
;
;  	ominas grift_example-batch
;
;  or from within IDL using::
;
;  	@grift_example-batch
;-
;==============================================================================
!quiet = 1

;-------------------------------------------------------------------------
;+
; OPEN IMAGE IN GRIM
;
;  This is basically it.  GRIM opens the specified image or images, and
;  computes whatever overlays you specify.  NHIST specifies the number
;  how far back the data descriptor history should go for the purpose
;  of undoing.  So now you're finished.  Have fun!
;  ::
;     grim, '~/casIss/1350/N1350122987_2.IMG', $
;                over=['center','limb','terminator','ring'], nhist=5
;                
;  .. image:: graphics/grift_example_01.png
;
;-
;-------------------------------------------------------------------------
grim, './data/N1350122987_2.IMG', $
;                  light=['SUN', 'JUPITER'], $
                  over=['center','limb','terminator','ring'], nhist=5


stop, '=== Auto-example complete.  Use cut & paste to continue.'



;-------------------------------------------------------------------------
;+
; RE-POINT FROM COMMAND LINE
;
;  Actually there is one more thing just for kicks.  GRIM could do this
;  from the menu, but you can also do it from the command line.  Just
;  GRIFT the descriptors out of GRIM, scan for edges and do a farfit.
;  GRIM sees the update to the camera descriptor and takes the liberty of 
;  recomputing everything that depends on that descriptor.  Neato!
;  ::
;    grift, cd=cd, dd=dd, limb_ptd=limb_ptd
;
;    edge_ptd = pg_edges(dd, edge=10, np=4000)
;    pg_draw, edge_ptd
;
;    dxy = pg_farfit(dd, edge_ptd, limb_ptd[0])
;    pg_repoint, dxy, cd=cd
;    
;  .. image:: graphics/grift_example_02.png
;-
;-------------------------------------------------------------------------
grift, cd=cd, dd=dd, limb_ptd=limb_ptd

edge_ptd = pg_edges(dd, edge=10, np=4000)
pg_draw, edge_ptd

dxy = pg_farfit(dd, edge_ptd, limb_ptd[0])
pg_repoint, dxy, cd=cd




