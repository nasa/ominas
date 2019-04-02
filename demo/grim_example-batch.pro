; docformat = 'rst'
;===============================================================================
;+
;                            GRIM EXAMPLE
;
;  Created by Joe Spitale
;
;  This example script demonstrates various basic ways to run GRIM, the
;  graphical interface to OMINAS.  GRIM is kind of like a fancier TVIM,
;  where you can do all the standard stuff like zooming, panning, and 
;  all manner of other acts that TVIM would never consent to.  You could 
;  just use it exactly like TVIM, using PG_DRAW/PLOTS to draw overlays, 
;  etc., but then none of your overlays would be permanent.  GRIM 
;  maintains arrays internally, so they hang around as you zoom and pan 
;  all over the place.  GRIM also maintains object descriptors and monitors 
;  them very closely; you can barely sneeze around a descriptor without 
;  GRIM refreshing itself several times.  See GRIM.PRO for information
;  on usage, or just play around with it.
;
;  This example file can be executed from the shell prompt in the ominas/demo
;  directory using::
;
;  	ominas grim_example-batch
;
;  or from within IDL using::
;
;  	@grim_example-batch
;-
;==============================================================================
!quiet = 1
file = 'data/n1350122987.2'
defsysv, '!grimrc',  ''				; disable grim resource file


;------------------------------------------------------------------------------
;+
; EXAMPLE 1: 
;
;  Read a data descriptor and give it to GRIM.  Also specify some overlays::
;
;    dd = dat_read(file)
;    grim, dd, zoom=0.75, /order, $
;                  overlay=['center', 'limb', 'terminator', 'ring']
;                  
;  .. image:: graphics/grim_example_01.png
;
;-
;------------------------------------------------------------------------------
dd = dat_read(file)
grim, dd, zoom=0.75, /order, $
                  overlay=['center', 'limb', 'terminator', 'ring']


;------------------------------------------------------------------------------
;+
; EXAMPLE 2: 
;
;  Example 1 was kind of dumb, because you could have just done this.  Note
;  the /new.  Without it, GRIM will try to update the existing instance. 
;  If you zoom out, you may notice many objects far from the field of view::
;
;    grim, /new, file, zoom=0.75, /order, $
;                overlay=['center', 'limb', 'terminator', 'ring']
;                
;  .. image:: graphics/grim_example_02.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, file, zoom=0.75, /order, $
                overlay=['center', 'limb', 'terminator', 'ring']


;------------------------------------------------------------------------------
;+
; EXAMPLE 3: 
;
;  Try specifying some explicit planet names.  This will likely be faster
;  because the above examples may have returned many more planets, depending
;  on your translator setup::
;
;    grim, /new, file, zoom=0.75, /order, $
;        overlay=['center:JUPITER,IO,EUROPA,GANYMEDE,CALLISTO', $
;                                                'limb', 'terminator', 'ring']
;                                                
;  .. image:: graphics/grim_example_03.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, file, zoom=0.75, /order, $
    overlay=['center:JUPITER,IO,EUROPA,GANYMEDE,CALLISTO', $
                                              'limb', 'terminator', 'ring']


;------------------------------------------------------------------------------
;+
; EXAMPLE 4: 
;
;  Let's get rid of the explicit planet names and just select them based
;  on geometric criteria.  FOV=-1 selects overlays within 1 field of view
;  of the viewport::  
;
;    grim, /new, file, zoom=0.75, /order, $
;        overlay=['center', 'limb', 'terminator', 'ring'], fov=-1
;        
;  .. image:: graphics/grim_example_04.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, file, zoom=0.75, /order, $
    overlay=['center', 'limb', 'terminator', 'ring'], fov=-1


;------------------------------------------------------------------------------
;+
; EXAMPLE 5: 
;
;  Same as above, except FOV=-1 selects overlays within 1 field of view
;  of the *image*::
;
;    grim, /new, file, zoom=0.75, /order, $
;        overlay=['center', 'limb', 'terminator', 'ring'], fov=1
;        
;  .. image:: graphics/grim_example_05.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, file, zoom=0.75, /order, $
    overlay=['center', 'limb', 'terminator', 'ring'], fov=1



stop, '=== Auto-example complete.  Use cut & paste to continue.'






;------------------------------------------------------------------------------
;+
;  You have too many GRIM windows open.  Let's take care of that::
;
;   grim, /exit, grn=lindgen(100)
;-
;------------------------------------------------------------------------------
grim, /exit, grn=lindgen(100)		; I'm assuming you haven't opened more
					; than 100 GRIMs here.  I've never tried
					; that, but it's probably not a good
					; idea.



;------------------------------------------------------------------------------
;+
;  Speaking of way too many GRIMs, let's just open a bunch of images in
;  *one* GRIM.  Each image is opened in a separate plane.  You can change 
;  planes using the left/right arrows in the top left corner.  If you have
;  Xdefaults-grim set up, you can use the left/right arrow keys::
;
;    grim, /new, './data/n*.2', /order, overlay='center'
;    
;  .. image:: graphics/grim_example_06.png
;  
;  .. image:: graphics/grim_example_07.png
;  
;  .. image:: graphics/grim_example_08.png
;  
;  .. image:: graphics/grim_example_09.png
;  
;  .. image:: graphics/grim_example_10.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, './data/n*.2', /order, overlay='center'



;------------------------------------------------------------------------------
;+ 
;  Did you know GRIM also handles plots?  Well it does!
;  ::
;
;    grim, /new, './data/GamAra037_2_bin50_031108.vic'
;    
;  .. image:: graphics/grim_example_11.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, './data/GamAra037_2_bin50_031108.vic', xsize=1200, ysize=300



;------------------------------------------------------------------------------
;+
; 
;  And cubes!  Here's an rgb image cube with some overlays::
;
;    grim, /new, './data/' + ['N1460072434_1.IMG', $
;                             'N1460072401_1.IMG', $
;                             'N1460072467_1.IMG'], $
;          ext='.cal', visibility=1, channel=[1b,2b,4b], $
;          over=['center', $
;                'limb:SATURN', $
;                'terminator:SATURN', $
;                'planet_grid:SATURN', $
;                'ring'], /global_scaling
;                
;  .. image:: graphics/grim_example_12.png
;-
;------------------------------------------------------------------------------
grim, /new, './data/' + ['N1460072434_1.IMG', $
                         'N1460072401_1.IMG', $
                         'N1460072467_1.IMG'], $
      ext='.cal', visibility=1, channel=[1b,2b,4b], $
      over=['center', $
           'limb:SATURN', $
           'terminator:SATURN', $
           'planet_grid:SATURN', $
           'ring']


;------------------------------------------------------------------------------
;+
; 
;  Here's a spectral cube::
;
;    grim, /new, './data/CM_1503358311_1_ir_eg.cub'
;    
;  .. image:: graphics/grim_example_13.png
;  
;-
;------------------------------------------------------------------------------
grim, /new, './data/CM_1503358311_1_ir_eg.cub'



