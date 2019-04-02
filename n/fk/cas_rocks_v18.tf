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
 
           TEXT_KERNEL_ID += 'ROCKS V18.0 11-MAY-2009 FK'
 
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

Version 7.0 - December 13, 2005 - Adrian Tinio

            -- Added new body name DAPHNIS (S1_2005).

Version 8.0 - February 27, 2006 - Adrian Tinio
            -- Added new bodies:
                NARVI
                S07-S18 2004.

Version 9.0 - December 5, 2006 - Elmain Martinez 
            -- Added new bodies:
                S19 2004
                S01-S08_2006

Version 10.0 - April 19, 2007 - Elmain Martinez
	    -- Added new bodies:
                 Aegir
                 Bebhionn
                 Bergelmir 
                 Bestla  
                 Farbauti
                 Fenrir  
                 Fornjot
                 Hati 
                 Hyrokkin
                 Kari 
                 Loge 
                 Skoll
                 Surtur

Version 11.0 - August 16, 2007 - Elmain Martinez 
            -- Added new body:
                 K07S4

Version 12.0 - October 1, 2007 - Elmain Martinez
            -- Removed duplicate 'S' entries (official names already specified)

Version 13.0 - August 21, 2008 - Adrian Tinio
            -- Added new body:
                ANTHE

Version 14.0 - August 25, 2008 - Adrian Tinio
            -- Removed definition for body 65060
            -- Replaced by Anthe

Version 15.0 - February 02, 2009 - Adrian Tinio
            -- Redefined S06_2006 and S04_2006 with their new name
               Jarnsaxa and Greip respectively.   
            -- Added new bodies:
                  Tarqeq
                  S02_2007
                  S03_2007   

Version 16.0 - March 10, 2009 - Adrian Tinio
	    -- Fixed an error with the S03_2007 definition where
 	       OBJECT_65056_FRAME was set to 'IAU_S02_2007'.  The correct
               value should be 'IAU_S03_2007'.

Version 17.0 - March 11, 2009 - Adrian Tinio
            -- Changed the spellings of the following bodies to match that
               of the built-in body names in the N0062 version of the 
               SPICE toolkit.
		      ERRIAPO  -> ERRIAPUS
  		      SKADI    -> SKATHI
                      SUTTUNG  -> SUTTUNGR
		      THRYM    -> THRYMR

Version 18.0 - May 11, 2009 - Adrian Tinio
            -- Added new body: Aegaeon   

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
 
 
SUTTUNGR
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_SUTTUNGR      = 623
            FRAME_623_NAME         = 'IAU_SUTTUNGR'
            FRAME_623_CLASS        =  2
            FRAME_623_CLASS_ID     = 623
            FRAME_623_CENTER       = 623
            OBJECT_623_FRAME       = 'IAU_SUTTUNGR'
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
 
 
SKATHI
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_SKATHI        = 627
            FRAME_627_NAME         = 'IAU_SKATHI'
            FRAME_627_CLASS        =  2
            FRAME_627_CLASS_ID     = 627
            FRAME_627_CENTER       = 627
            OBJECT_627_FRAME       = 'IAU_SKATHI'
           \begintext
 
 
ERRIAPUS
----------------------------------------------------------
 
 
           \begindata
            FRAME_IAU_ERRIAPUS     = 628
            FRAME_628_NAME         = 'IAU_ERRIAPUS'
            FRAME_628_CLASS        =  2
            FRAME_628_CLASS_ID     = 628
            FRAME_628_CENTER       = 628
            OBJECT_628_FRAME       = 'IAU_ERRIAPUS'
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
 
 
THRYMR
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_THRYMR       = 630
      FRAME_630_NAME         = 'IAU_THRYMR'
      FRAME_630_CLASS        =  2
      FRAME_630_CLASS_ID     = 630
      FRAME_630_CENTER       = 630
      OBJECT_630_FRAME       = 'IAU_THRYMR'
     \begintext


NARVI
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_NARVI        = 631
      FRAME_631_NAME         = 'IAU_NARVI'
      FRAME_631_CLASS        =  2
      FRAME_631_CLASS_ID     = 631
      FRAME_631_CENTER       = 631
      OBJECT_631_FRAME       = 'IAU_NARVI'
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


DAPHNIS (S1_2005)
----------------------------------------------------------

 
     \begindata
      FRAME_IAU_DAPHNIS      = 635
      FRAME_635_NAME         = 'IAU_DAPHNIS'
      FRAME_635_CLASS        =  2
      FRAME_635_CLASS_ID     = 635
      FRAME_635_CENTER       = 635
      OBJECT_635_FRAME       = 'IAU_DAPHNIS'
     \begintext


AEGIR
----------------------------------------------------------


     \begindata
      FRAME_IAU_AEGIR        = 636
      FRAME_636_NAME         = 'IAU_AEGIR'
      FRAME_636_CLASS        =  2
      FRAME_636_CLASS_ID     = 636
      FRAME_636_CENTER       = 636
      OBJECT_636_FRAME       = 'IAU_AEGIR'
     \begintext


BEBHIONN
----------------------------------------------------------


     \begindata
      FRAME_IAU_BEBHIONN     = 637
      FRAME_637_NAME         = 'IAU_BEBHIONN'
      FRAME_637_CLASS        =  2
      FRAME_637_CLASS_ID     = 637
      FRAME_637_CENTER       = 637
      OBJECT_637_FRAME       = 'IAU_BEBHIONN'
     \begintext


BERGELMIR
----------------------------------------------------------


     \begindata
      FRAME_IAU_BERGELMIR    = 638
      FRAME_638_NAME         = 'IAU_BERGELMIR'
      FRAME_638_CLASS        =  2
      FRAME_638_CLASS_ID     = 638
      FRAME_638_CENTER       = 638
      OBJECT_638_FRAME       = 'IAU_BERGELMIR'
     \begintext


BESTLA
----------------------------------------------------------


     \begindata
      FRAME_IAU_BESTLA       = 639
      FRAME_639_NAME         = 'IAU_BESTLA'
      FRAME_639_CLASS        =  2
      FRAME_639_CLASS_ID     = 639
      FRAME_639_CENTER       = 639
      OBJECT_639_FRAME       = 'IAU_BESTLA'
     \begintext


FARBAUTI
----------------------------------------------------------


     \begindata
      FRAME_IAU_FARBAUTI     = 640
      FRAME_640_NAME         = 'IAU_FARBAUTI'
      FRAME_640_CLASS        =  2
      FRAME_640_CLASS_ID     = 640
      FRAME_640_CENTER       = 640
      OBJECT_640_FRAME       = 'IAU_FARBAUTI'
     \begintext


FENRIR
----------------------------------------------------------


     \begindata
      FRAME_IAU_FENRIR       = 641
      FRAME_641_NAME         = 'IAU_FENRIR'
      FRAME_641_CLASS        =  2
      FRAME_641_CLASS_ID     = 641
      FRAME_641_CENTER       = 641
      OBJECT_641_FRAME       = 'IAU_FENRIR'
     \begintext


FORNJOT
----------------------------------------------------------


     \begindata
      FRAME_IAU_FORNJOT   = 642
      FRAME_642_NAME         = 'IAU_FORNJOT'
      FRAME_642_CLASS        =  2
      FRAME_642_CLASS_ID     = 642
      FRAME_642_CENTER       = 642
      OBJECT_642_FRAME       = 'IAU_FORNJOT'
     \begintext


HATI
----------------------------------------------------------


     \begindata
      FRAME_IAU_HATI         = 643
      FRAME_643_NAME         = 'IAU_HATI'
      FRAME_643_CLASS        =  2
      FRAME_643_CLASS_ID     = 643
      FRAME_643_CENTER       = 643
      OBJECT_643_FRAME       = 'IAU_HATI'
     \begintext


HYROKKIN
----------------------------------------------------------


     \begindata
      FRAME_IAU_HYROKKIN     = 644
      FRAME_644_NAME         = 'IAU_HYROKKIN'
      FRAME_644_CLASS        =  2
      FRAME_644_CLASS_ID     = 644
      FRAME_644_CENTER       = 644
      OBJECT_644_FRAME       = 'IAU_HYROKKIN'
     \begintext


KARI
----------------------------------------------------------


     \begindata
      FRAME_IAU_KARI         = 645
      FRAME_645_NAME         = 'IAU_KARI'
      FRAME_645_CLASS        =  2
      FRAME_645_CLASS_ID     = 645
      FRAME_645_CENTER       = 645
      OBJECT_645_FRAME       = 'IAU_KARI'
     \begintext


LOGE
----------------------------------------------------------


     \begindata
      FRAME_IAU_LOGE         = 646
      FRAME_646_NAME         = 'IAU_LOGE'
      FRAME_646_CLASS        =  2
      FRAME_646_CLASS_ID     = 646
      FRAME_646_CENTER       = 646
      OBJECT_646_FRAME       = 'IAU_LOGE'
     \begintext


SKOLL
----------------------------------------------------------


     \begindata
      FRAME_IAU_SKOLL        = 647
      FRAME_647_NAME         = 'IAU_SKOLL'
      FRAME_647_CLASS        =  2
      FRAME_647_CLASS_ID     = 647
      FRAME_647_CENTER       = 647
      OBJECT_647_FRAME       = 'IAU_SKOLL'
     \begintext


SURTUR
----------------------------------------------------------


     \begindata
      FRAME_IAU_SURTUR       = 648
      FRAME_648_NAME         = 'IAU_SURTUR'
      FRAME_648_CLASS        =  2
      FRAME_648_CLASS_ID     = 648
      FRAME_648_CENTER       = 648
      OBJECT_648_FRAME       = 'IAU_SURTUR'
     \begintext


ANTHE
----------------------------------------------------------


     \begindata
      FRAME_IAU_ANTHE        = 649
      FRAME_649_NAME         = 'IAU_ANTHE'
      FRAME_649_CLASS        =  2
      FRAME_649_CLASS_ID     = 649
      FRAME_649_CENTER       = 649
      OBJECT_649_FRAME       = 'IAU_ANTHE'
     \begintext


JARNSAXA
----------------------------------------------------------


     \begindata
      FRAME_IAU_JARNSAXA     = 650
      FRAME_650_NAME         = 'IAU_JARNSAXA'
      FRAME_650_CLASS        =  2
      FRAME_650_CLASS_ID     = 650
      FRAME_650_CENTER       = 650
      OBJECT_650_FRAME       = 'IAU_JARNSAXA'
     \begintext


GREIP
----------------------------------------------------------


     \begindata
      FRAME_IAU_GREIP        = 651
      FRAME_651_NAME         = 'IAU_GREIP'
      FRAME_651_CLASS        =  2
      FRAME_651_CLASS_ID     = 651
      FRAME_651_CENTER       = 651
      OBJECT_651_FRAME       = 'IAU_GREIP'
     \begintext


TARQEQ
----------------------------------------------------------


     \begindata
      FRAME_IAU_TARQEQ       = 652
      FRAME_652_NAME         = 'IAU_TARQEQ'
      FRAME_652_CLASS        =  2
      FRAME_652_CLASS_ID     = 652
      FRAME_652_CENTER       = 652
      OBJECT_652_FRAME       = 'IAU_TARQEQ'
     \begintext


AEGAEON
----------------------------------------------------------


     \begindata
      FRAME_IAU_AEGAEON      = 653 
      FRAME_653_NAME         = 'IAU_AEGAEON'
      FRAME_653_CLASS        =  2
      FRAME_653_CLASS_ID     = 653
      FRAME_653_CENTER       = 653
      OBJECT_653_FRAME       = 'IAU_AEGAEON'
     \begintext


S7_2004
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_S7_2004        = 65035
      FRAME_65035_NAME         = 'IAU_S7_2004'
      FRAME_65035_CLASS        =  2
      FRAME_65035_CLASS_ID     = 65035
      FRAME_65035_CENTER       = 65035
      OBJECT_65035_FRAME       = 'IAU_S7_2004'
     \begintext


S12_2004
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_S12_2004       = 65040
      FRAME_65040_NAME         = 'IAU_S12_2004'
      FRAME_65040_CLASS        =  2
      FRAME_65040_CLASS_ID     = 65040
      FRAME_65040_CENTER       = 65040
      OBJECT_65040_FRAME       = 'IAU_S12_2004'
     \begintext


S13_2004
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_S13_2004        = 65041
      FRAME_65041_NAME         = 'IAU_S13_2004'
      FRAME_65041_CLASS        =  2
      FRAME_65041_CLASS_ID     = 65041
      FRAME_65041_CENTER       = 65041
      OBJECT_65041_FRAME       = 'IAU_S13_2004'
     \begintext


S17_2004
----------------------------------------------------------
 
 
     \begindata
      FRAME_IAU_S17_2004       = 65045
      FRAME_65045_NAME         = 'IAU_S17_2004'
      FRAME_65045_CLASS        =  2
      FRAME_65045_CLASS_ID     = 65045
      FRAME_65045_CENTER       = 65045
      OBJECT_65045_FRAME       = 'IAU_S17_2004'
     \begintext


S01_2006
----------------------------------------------------------


     \begindata
      FRAME_IAU_S01_2006       = 65048
      FRAME_65048_NAME         = 'IAU_S01_2006'
      FRAME_65048_CLASS        =  2
      FRAME_65048_CLASS_ID     = 65048
      FRAME_65048_CENTER       = 65048
      OBJECT_65048_FRAME       = 'IAU_S01_2006'
     \begintext


S03_2006
----------------------------------------------------------


     \begindata
      FRAME_IAU_S03_2006       = 65050
      FRAME_65050_NAME         = 'IAU_S03_2006'
      FRAME_65050_CLASS        =  2
      FRAME_65050_CLASS_ID     = 65050
      FRAME_65050_CENTER       = 65050
      OBJECT_65050_FRAME       = 'IAU_S03_2006'
     \begintext


S02_2007
----------------------------------------------------------


     \begindata
      FRAME_IAU_S02_2007       = 65055
      FRAME_65055_NAME         = 'IAU_S02_2007'
      FRAME_65055_CLASS        =  2
      FRAME_65055_CLASS_ID     = 65055
      FRAME_65055_CENTER       = 65055
      OBJECT_65055_FRAME       = 'IAU_S02_2007'
     \begintext


S03_2007
----------------------------------------------------------


     \begindata
      FRAME_IAU_S03_2007       = 65056
      FRAME_65056_NAME         = 'IAU_S03_2007'
      FRAME_65056_CLASS        =  2
      FRAME_65056_CLASS_ID     = 65056
      FRAME_65056_CENTER       = 65056
      OBJECT_65056_FRAME       = 'IAU_S03_2007'
     \begintext

