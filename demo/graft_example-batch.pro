; docformat = 'rst'
;==============================================================================
;+
;                            GRAFT EXAMPLE
;
;  Created by Joe Spitale
;
;  This example file demonstrates the use the GRIM interface programs
;  GRIFT and GRAFT.  While GRIFT cheats GRIM out of its object references, 
;  GRAFT corruptly inserts (or grafts) data arrays into a GRIM instance.  
;
;  The usage demonstrated here is a bit contrived, as one could accomplish
;  a better result by specifying the desired overlays in the call to GRIM,
;  as in grim_example, but let's live a little.
;
;  This example file can be executed from the shell prompt in the ominas/demo
;  directory using::
;
;  	ominas graft_example-batch
;
;  or from within IDL using::
;
;  	@graft_example-batch
;
;  You can also just paste line-by-line if you want to inspect the variables
;  at each step.
;
;  After the example stops, later code samples in this file may be executed by
;  pasting them onto the IDL command line.
;-
;==============================================================================
!quiet = 1								; shush!

;------------------------------------------------------------------------------
;+
; READ AND DISPLAY IMAGE
;
;  Use GRIM to open and display an image::
;
;    grim, './data/n1350122987.2', zoom=0.75, /order
;-
;------------------------------------------------------------------------------
grim, './data/n1350122987.2', zoom=0.75, /order


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;+
; GRIFT
;
;  First, GRIFT the data descriptor out of poor old GRIM.  Note that the 
;  returned object is a reference to the same object as GRIM is using::
;
;    grift, dd=dd				
;
;  Be warned that GRIM jealously watches over its objects and updates whenever 
;  it detects any changes, so you can simultaneously operate on objects from 
;  within GRIM and from the command line.  For example, try::
;
;	dat_set_data, dd, rotate(dat_data(dd),7)
;
;  GRIM resigns itself to having its data descriptor tampered with and
;  updates the display accordingly.  Run the same command again if you
;  want flip the image back.
;-
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
grift, dd=dd				


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;+
; OBTAIN GEOMETRY
;
;  Now compute geometry for this dd.  This is the same business you have
;  seen in all of the other demos, cd, pd, etc.  Of course, you could have 
;  just had GRIM do this::
;
;    cd = pg_get_cameras(dd, 'ck_in=auto')
;    pd = pg_get_planets(dd, od=cd, $
;           name=['JUPITER', 'IO', 'EUROPA', 'GANYMEDE', 'CALLISTO'])
;    rd = pg_get_rings(dd, pd=pd, od=cd)
;    ltd = pg_get_stars(dd, od=cd, name='SUN')
;- 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd = pg_get_cameras(dd, 'ck_in=auto')
pd = pg_get_planets(dd, od=cd, $
       name=['JUPITER', 'IO', 'EUROPA', 'GANYMEDE', 'CALLISTO'])
rd = pg_get_rings(dd, pd=pd, od=cd)
ltd = pg_get_stars(dd, od=cd, name='SUN')


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;+
; MAKE A GENERIC DESCRIPTOR
;
;  And of course we shove everything into a generic descriptor because it
;  makes everything so much easier::
;
;    gd = {cd:cd, gbx:pd, dkx:rd, ltd:ltd}
;-
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gd = {cd:cd, gbx:pd, dkx:rd, ltd:ltd}


;-------------------------------------------------------------------------
;+
; COMPUTE OVERLAY ARRAYS
;
;  Same old story;  PG_LIMB, PG_DISK, PG_HIDE, etc.  GRIM would have been 
;  happy to do this for you::
;
;    limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
;              pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=ltd
;    ring_ptd = pg_disk(gd=gd) & pg_hide, ring_ptd, gd=gd, bx=pd
;    term_ptd = pg_limb(gd=gd, od=gd.ltd) & pg_hide, term_ptd, gd=gd, bx=pd, /assoc
;    center_ptd = pg_center(gd=gd, bx=pd)

;-
;-------------------------------------------------------------------------
limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=ltd
ring_ptd = pg_disk(gd=gd) & pg_hide, ring_ptd, gd=gd, bx=pd
term_ptd = pg_limb(gd=gd, od=gd.ltd) & pg_hide, term_ptd, gd=gd, bx=pd, /assoc
center_ptd = pg_center(gd=gd, bx=pd)


;-------------------------------------------------------------------------
;+
; DISPLAY OVERLAYS
;
;  Ok, now let's draw those overlays, just like in the PG example.  This
;  is going to be great::
;
;    pg_draw, center_ptd, col=ctwhite(), psym=1, plabel=cor_name(pd)
;    pg_draw, limb_ptd, col=ctyellow()
;    pg_draw, term_ptd, col=ctred()
;    pg_draw, ring_ptd, col=ctorange()
;
;  Now let's zoom in and take a look at things.  You can use the mouse wheel 
;  with Ctrl depressed, or you can use one of the Zoom cursor modes, or you
;  can use the View->Zoom menu, or the associated keyboard shortcuts if 
;  have your Xdefaults-grim installed; basically just throw a flip-flop at 
;  your computer and you should be able to make this happen. 
;
;  But wait, where did my overlays go?  Did they ever even exist?  If you  
;  are older than two years of age and have mastered object permanence, 
;  then you probably have this one figured out.  We need a way to draw
;  these things permanently; some way of GRAFTing them into GRIM...
;-
;-------------------------------------------------------------------------
pg_draw, center_ptd, col=ctwhite(), psym=1, plabel=cor_name(pd)
pg_draw, limb_ptd, col=ctyellow()
pg_draw, term_ptd, col=ctred()
pg_draw, ring_ptd, col=ctorange()


;-------------------------------------------------------------------------
;+
; GRAFT
;
;  GRAFT "grafts" the POINT objects into GRIM.  Note that these are entered
;  as user arrays in GRIM, so they're pretty much second class as far as
;  GRIM is concerned.  This would have been way better if you had just 
;  specified these as overlays in your call to GRIM.  Now you have wasted 
;  your time and GRIM's.
;
;    graft, center_ptd, col=ctwhite(), psym=1;, plabel=cor_name(pd)
;    graft, limb_ptd, col=ctyellow()
;    graft, term_ptd, col=ctred()
;    graft, ring_ptd, col=ctorange()
;    
;  .. image:: graphics/graft_example_01.png
;
;-
;-------------------------------------------------------------------------
graft, center_ptd, col=ctwhite(), psym=1;, plabel=cor_name(pd)
graft, limb_ptd, col=ctyellow()
graft, term_ptd, col=ctred()
graft, ring_ptd, col=ctorange()
stop, '=== Auto-example complete.  Use cut & paste to continue.'



