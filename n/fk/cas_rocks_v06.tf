KPL/FK
 
 
Cassini Spacecraft Frame Kernel for small satellites
===============================================================
 
   This frame kernel contains the constants defining the frames for small
   satellites (rocks) of Saturn.
 
 
Version and Date
----------------------------------------------------------
 
   The TEXT_KERNEL_ID stores version information of loaded project text
   kernels. Each entry associated with the keyword is a string that consists
   of four parts: the kernel name, version, entry date, and type. For example,
   the ISS I-kernel might have an entry as follows:
 
           TEXT_KERNEL_ID += 'IAU_ISS V0.0 29-SEPTEMBER-1999 IK'
                                  |          |         |            |
                                  |          |         |            |
              KERNEL NAME <-------+          |         |            |
                                             |         |            V
                             VERSION <-------+         |       KERNEL TYPE
                                                       |
                                                       V
                                                  ENTRY DATE
 
   Cassini Small Satellites Frame Kernel Version:
 
           \begindata
 
           TEXT_KERNEL_ID += 'ROCKS V6.0 8-APRIL-2005 FK'
 
           \begintext
 
Version 1.0 -- May 21, 2003 -- Lee Elson
 
            --   Initial Release.

Version 2.0 - November 5, 2003 - Diane Conner

            -- Included IAU approved names.

Version 3.0 - April 27, 2004 - Diane Conner
               
            -- Changed keyword "FRAME_IAU_ ERRIAPO"
                            to "FRAME_IAU_ERRIAPO"
 
Version 4.0 - November 30, 2004 - Diane Conner
               
            -- Added new body names S1_2004, S2_2004 & S5_2004.
                
Version 5.0 - December 22, 2004 - Diane Conner

            -- Corrected typos in definitions for S1, S2, & S5 2004. 

Version 6.0 - April 8, 2005 - Added names for S1, S2, & S5 2004. 
                              Also changed the mapping of ids to
                              match spk 050407AP_RE_04002_09011.
 
References
----------------------------------------------------------
 
            1.   ``Kernel Pool Required Reading''
 
            2.   ``Frames Required Reading''
 
            3.   Email from Diane Conner regarding targeting small satellites,
                 or rocks, of Saturn.

            4.  Sky & Telescope Magazine,(25th General Assembly of the
                International Astronomical Union, held from 
                July 13-26 in Sydney, Australia)
                 http://skyandtelescope.com/news/article_1012_1.asp
 

Contact Information
----------------------------------------------------------
 
   Direct questions, comments, or concerns about the contents of this kernel
   to:
 
           Lee Elson, NAIF/JPL, (818)354-4223, Lee.Elson@jpl.nasa.gov
           Diane Conner, Cassini Science Data Engineering Lead (818)354-8586,
                Diane.L.Conner@jpl.nasa.gov
 
 
Introduction
----------------------------------------------------------
 
   This file defines body fixed frames for the small satellites of Saturn.
   Body fixed frames are reference frames that do not move with respect to
   ``surface'' features of an object. Note that body fixed frames do move with
   respect to inertial frames. Information about how these frames are changing
   with respect to inertial frames is stored in the corresponding SPICE PCK
   file.
 
 
Implementation Notes
----------------------------------------------------------
 
   This file is used by the SPICE system as follows: programs that make use of
   this frame kernel must `load' the kernel, normally during program
   initialization. Loading the kernel associates data items with their names
   in a data structure called the `kernel pool'. The SPICELIB routine LDPOOL
   loads a kernel file into the pool as shown below:
 
           CALL LDPOOL ( frame_kernel_name )
 
   In order for a program or subroutine to extract data from the pool, the
   SPICELIB routines GDPOOL and GIPOOL are used. See [2] for more details.
 
   This file was created and may be updated with a text editor or word
   processor.
 
 
Assumptions
----------------------------------------------------------
 
   This file assigns frame names to the satellites that are defined by the
   corresponding PCK file. Any changes to this file must be consistent with
   the PCK file.
 
 
Use
----------------------------------------------------------

   Several user-level SPICE routines require that the user supply the name of
   a reference frame as one of the inputs to the routine. The most important
   of these are the routines SPKEZ and SPKEZR. These routines return the state
   (position and velocity) of one object relative to another in a user
   specified reference frame. The choice of reference frame often makes a big
   difference in the usefulness of a returned state. If the state is relative
   to a suitable reference frame, computations involving that state can be
   much simpler than if the state were returned relative to some other
   reference frame.
 
   The SPICE frame subsystem allows you to easily transform states from one
   reference frame to another. Usually this can be done without needing to
   know all of the details of how the transformation is carried out. This
   allows you to concentrate on questions more closely related to the problem
   you are trying to solve instead of the details of how to get information in
   the frame of interest.
 
   NAIF requests that you update the `by line' and date if you modify this
   file.
         

YMIR
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_YMIR       = 619
            FRAME_619_NAME         = 'IAU_YMIR'
            FRAME_619_CLASS        =  2
            FRAME_619_CLASS_ID     = 619
            FRAME_619_CENTER       = 619
            OBJECT_619_FRAME       = 'IAU_YMIR'
 
           \begintext
 
 
PAALIAQ
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_PAALIAQ       = 620
            FRAME_620_NAME         = 'IAU_PAALIAQ'
            FRAME_620_CLASS        =  2
            FRAME_620_CLASS_ID     = 620
            FRAME_620_CENTER       = 620
            OBJECT_620_FRAME       = 'IAU_PAALIAQ'
           \begintext
 
 
TARVOS
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_TARVOS       = 621
            FRAME_621_NAME         = 'IAU_TARVOS'
            FRAME_621_CLASS        =  2
            FRAME_621_CLASS_ID     = 621
            FRAME_621_CENTER       = 621
            OBJECT_621_FRAME       = 'IAU_TARVOS'
           \begintext
 
 
IJIRAQ
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_IJIRAQ       = 622
            FRAME_622_NAME         = 'IAU_IJIRAQ'
            FRAME_622_CLASS        =  2
            FRAME_622_CLASS_ID     = 622
            FRAME_622_CENTER       = 622
            OBJECT_622_FRAME       = 'IAU_IJIRAQ'
           \begintext
 
 
SUTTUNG
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_SUTTUNG      = 623
            FRAME_623_NAME         = 'IAU_SUTTUNG'
            FRAME_623_CLASS        =  2
            FRAME_623_CLASS_ID     = 623
            FRAME_623_CENTER       = 623
            OBJECT_623_FRAME       = 'IAU_SUTTUNG'
           \begintext
 
 
KIVIUQ
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_KIVIUQ       = 624
            FRAME_624_NAME         = 'IAU_KIVIUQ'
            FRAME_624_CLASS        =  2
            FRAME_624_CLASS_ID     = 624
            FRAME_624_CENTER       = 624
            OBJECT_624_FRAME       = 'IAU_KIVIUQ'
           \begintext
 
 
MUNDILFARI
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_MUNDILFARI   = 625
            FRAME_625_NAME         = 'IAU_MUNDILFARI'
            FRAME_625_CLASS        =  2
            FRAME_625_CLASS_ID     = 625
            FRAME_625_CENTER       = 625
            OBJECT_625_FRAME       = 'IAU_MUNDILFARI'
           \begintext
 
 
ALBIORIX
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_ALBIORIX     = 626
            FRAME_626_NAME         = 'IAU_ALBIORIX'
            FRAME_626_CLASS        =  2
            FRAME_626_CLASS_ID     = 626
            FRAME_626_CENTER       = 626
            OBJECT_626_FRAME       = 'IAU_ALBIORIX'
           \begintext
 
 
SKADI
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_SKADI        = 627
            FRAME_627_NAME         = 'IAU_SKADI'
            FRAME_627_CLASS        =  2
            FRAME_627_CLASS_ID     = 627
            FRAME_627_CENTER       = 627
            OBJECT_627_FRAME       = 'IAU_SKADI'
           \begintext
 
 
ERRIAPO
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_ERRIAPO     = 628
            FRAME_628_NAME         = 'IAU_ERRIAPO'
            FRAME_628_CLASS        =  2
            FRAME_628_CLASS_ID     = 628
            FRAME_628_CENTER       = 628
            OBJECT_628_FRAME       = 'IAU_ERRIAPO'
           \begintext
 
 
SIARNAQ
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_SIARNAQ     = 629
            FRAME_629_NAME         = 'IAU_SIARNAQ'
            FRAME_629_CLASS        =  2
            FRAME_629_CLASS_ID     = 629
            FRAME_629_CENTER       = 629
            OBJECT_629_FRAME       = 'IAU_SIARNAQ'
           \begintext
 
 
THRYM
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_THRYM       = 630
      FRAME_630_NAME         = 'IAU_THRYM'
      FRAME_630_CLASS        =  2
      FRAME_630_CLASS_ID     = 630
      FRAME_630_CENTER       = 630
      OBJECT_630_FRAME       = 'IAU_THRYM'
     \begintext


METHONE (S1_2004)
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_METHONE       = 632
      FRAME_632_NAME          ='IAU_METHONE' 
      FRAME_632_CLASS         =  2
      FRAME_632_CLASS_ID      = 632
      FRAME_632_CENTER        = 632
      OBJECT_632_FRAME        = 'IAU_METHONE'
     \begintext


PALLENE (S2_2004)
----------------------------------------------------------

 
     \begindata
      FRAME_IAU_PALLENE   = 633
      FRAME_633_NAME      = 'IAU_PALLENE'
      FRAME_633_CLASS     =  2
      FRAME_633_CLASS_ID  = 633
      FRAME_633_CENTER    = 633
      OBJECT_633_FRAME    = 'IAU_PALLENE'
     \begintext


POLYDEUCES (S5_2004)
----------------------------------------------------------

 
     \begindata
      FRAME_IAU_POLYDEUCES   = 634
      FRAME_634_NAME         = 'IAU_POLYDEUCES'
      FRAME_634_CLASS        =  2
      FRAME_634_CLASS_ID     = 634
      FRAME_634_CENTER       = 634
      OBJECT_634_FRAME       = 'IAU_POLYDEUCES'
     \begintext

