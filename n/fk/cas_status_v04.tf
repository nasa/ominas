KPL/FK

Cassini Body Vector Table Eligibility Status Frames Kernel
Cassini Instrument Type Frames Kernel
=============================================================

To understand how instrument frames map to instrument FOVs, see the fovinfo.txt
report that accompanies the latest Cassini frames kernel.

FRAME-< frame id >_BVT_FRAME
--------------------------

   This keyword specifies which CASSINI frames can be used for targeting
   using the Spacecraft Pointing Design Tool (PDT) software due to their
   availability in the Body Vector Table (BVT) on the spacecraft.  The
   value of the keyword will be changed by Cassini Sequence Change 
   Request (SCR).
  
   < frame id > is the identifier of the frame (that can be mapped to one or 
                more instruments)

   Description of keyword values:

     INELIGIBLE identifies that the body vector will never be made ACTIVE; i.e., the 
                body vector cannot be used for targeting using the PDT tool.

     ELIGIBLE   identifies that the body vector can be made ACTIVE; however the 
                BVT on the spacecraft does not currently contain that vector.  An 
                SCR is required to change the BVT and keyword value to ACTIVE.

     ACTIVE     identifies that the body vector is currently available in the 
                spacecraft BVT and can be used for targeting using PDT.


FRAME-< frame id >_INSTRUMENT_TYPE
----------------------------------


   This keyword specifies a frame as type ORS (Optical Remote Sensing), 
   MAPS (Magnetospheres and Plasma Physics), SRU (Stellar Reference Unit), 
   RADIATOR or UNUSED.

   < frame id > is the identifier of the frame (that can be mapped to one or 
                more instruments)

   ORS identifies an observation remote science frame. 
   MAPS identifies a magnetosphere, atmosphere, plasma sciences instrument.
   SRU identifies a stellar reference unit.
   RADIATOR identifies a radiator or cooler of an instrument.
   UNUSED means that the entry is not read by PDT.


Version and Date
----------------------------------------------------------

   The TEXT_KERNEL_ID stores version information of loaded project text
   kernels. Each entry associated with the keyword is a string that
   consists of four parts: the kernel name, version, entry date, and
   type. For example, the ISS I-kernel might have an entry as follows:

           TEXT_KERNEL_ID += 'CASSINI_ISS V0.0 29-SEPTEMBER-1999 IK'
                                  |          |         |            |
                                  |          |         |            |
              KERNEL NAME <-------+          |         |            |
                                             |         |            V
                             VERSION <-------+         |       KERNEL TYPE
                                                       |
                                                       V
                                                  ENTRY DATE

   Cassini Frame Kernel Version:

           \begindata

           TEXT_KERNEL_ID += 'CASSINI_STATUS V4.0 06-NOV-2008 FK'

           \begintext

Version 4.0 -- Nov  06, 2008 -- Adrian Tinio

     Added defintions for UVIS_SOL_OFF[3].

           FRAME-82849_BVT_STATUS      = 'ACTIVE' 
           FRAME-82849_INSTRUMENT_TYPE = 'ORS'
     
     Updates based on V40 of the Cassini Frames Kernel and V06 of the Cassini
     Instruments Kernel.       
 
Version 3.0 -- June 27, 2005 -- Diane Conner

     Correction to original file[2].  FRAME-82370_BVT_STATUS='ELIGIBLE' (VIMS_V)
                                      FRAME-82371_BVT_STATUS='ACTIVE' (VIMS_IR) 
 
Version 2.0 -- June 20, 2005 -- Diane Conner

     Initial file implemented as specified[1].


         
References
----------------------------------------------------------

          1.  Cassini Engineering Change request (ECR) 103373.
          2.  Email from Jeff Boyer, "PDT 11 Warning Message", 6/27/05
          3.  Cassini Engineering Change request (ECR) 108546.

Contact Information
----------------------------------------------------------

   Direct questions, comments or concerns about the contents of this
   kernel to:

           Diane Conner, CASSINI IO/JPL, 
           (818)-354-8586
           Diane.L.Conner@jpl.nasa.gov

           Adrian Tinio, CASSINI IO/JPL, 
           (818)-393-5995 
           Adrian.Tinio@jpl.nasa.gov


Implementation Notes
----------------------------------------------------------

   This file is used by the SPICE system as follows: programs that make
   use of this instrument kernel must ``load'' the kernel, normally
   during program initialization. Loading the kernel associates data
   items with their names in a data structure called the ``kernel
   pool''. The SPICELIB routine FURNSH and CSPICE routine furnsh_c load
   SPICE kernels as shown below:

   FORTRAN (SPICELIB)

           CALL FURNSH ( 'kernel_name' )

   C (CSPICE)

           furnsh_c ( "kernel_name" )

   In order for a program or subroutine to extract data from the pool,
   the SPICELIB routines GDPOOL and GIPOOL are used. 
 
   This file was created and may be updated with a text editor or word
   processor.


\begindata

FRAME-82000_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82001_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82002_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82008_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82009_BVT_STATUS     = 'INELIGIBLE'
FRAME-82101_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82102_BVT_STATUS     = 'ELIGIBLE'
FRAME-82103_BVT_STATUS     = 'ACTIVE' 
FRAME-82104_BVT_STATUS     = 'ACTIVE'  
FRAME-82105_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82106_BVT_STATUS     = 'INELIGIBLE'
FRAME-82107_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82108_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82350_BVT_STATUS     = 'ELIGIBLE'  
FRAME-82351_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82360_BVT_STATUS     = 'ACTIVE'  
FRAME-82361_BVT_STATUS     = 'ACTIVE' 
FRAME-82368_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82369_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82370_BVT_STATUS     = 'ELIGIBLE'     
FRAME-82371_BVT_STATUS     = 'ACTIVE'   
FRAME-82372_BVT_STATUS     = 'ACTIVE'    
FRAME-82378_BVT_STATUS     = 'INELIGIBLE'
FRAME-82730_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82731_BVT_STATUS     = 'INELIGIBLE'
FRAME-82732_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82733_BVT_STATUS     = 'INELIGIBLE'
FRAME-82734_BVT_STATUS     = 'ELIGIBLE'  
FRAME-82740_BVT_STATUS     = 'ELIGIBLE'  
FRAME-82760_BVT_STATUS     = 'ELIGIBLE'  
FRAME-82761_BVT_STATUS     = 'ELIGIBLE'  
FRAME-82762_BVT_STATUS     = 'INELIGIBLE'
FRAME-82763_BVT_STATUS     = 'INELIGIBLE'
FRAME-82764_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82765_BVT_STATUS     = 'INELIGIBLE'
FRAME-82790_BVT_STATUS     = 'INELIGIBLE'
FRAME-82791_BVT_STATUS     = 'INELIGIBLE'
FRAME-82792_BVT_STATUS     = 'INELIGIBLE'
FRAME-82810_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82811_BVT_STATUS     = 'ELIGIBLE'
FRAME-82812_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82813_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82814_BVT_STATUS     = 'ELIGIBLE'
FRAME-82820_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82821_BVT_STATUS     = 'INELIGIBLE' 
FRAME-82822_BVT_STATUS     = 'INELIGIBLE'
FRAME-82840_BVT_STATUS     = 'ACTIVE'    
FRAME-82842_BVT_STATUS     = 'ACTIVE'    
FRAME-82843_BVT_STATUS     = 'ELIGIBLE' 
FRAME-82844_BVT_STATUS     = 'ACTIVE'  
FRAME-82845_BVT_STATUS     = 'ELIGIBLE'
FRAME-82849_BVT_STATUS     = 'ACTIVE'
FRAME-82890_BVT_STATUS     = 'ACTIVE' 
FRAME-82891_BVT_STATUS     = 'ACTIVE' 
FRAME-82892_BVT_STATUS     = 'ACTIVE' 
FRAME-82893_BVT_STATUS     = 'ACTIVE'
FRAME-82898_BVT_STATUS     = 'INELIGIBLE'



FRAME-82000_INSTRUMENT_TYPE     = 'UNUSED'
FRAME-82001_INSTRUMENT_TYPE     = 'SRU' 
FRAME-82002_INSTRUMENT_TYPE     = 'SRU' 
FRAME-82008_INSTRUMENT_TYPE     = 'RADIATOR' 
FRAME-82009_INSTRUMENT_TYPE     = 'RADIATOR' 
FRAME-82101_INSTRUMENT_TYPE     = 'UNUSED'  
FRAME-82102_INSTRUMENT_TYPE     = 'ORS'    
FRAME-82103_INSTRUMENT_TYPE     = 'ORS'   
FRAME-82104_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82105_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82106_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82107_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82108_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME-82350_INSTRUMENT_TYPE     = 'MAPS'   
FRAME-82351_INSTRUMENT_TYPE     = 'MAPS'   
FRAME-82360_INSTRUMENT_TYPE     = 'ORS'   
FRAME-82361_INSTRUMENT_TYPE     = 'ORS'   
FRAME-82368_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME-82369_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME-82370_INSTRUMENT_TYPE     = 'ORS'     
FRAME-82371_INSTRUMENT_TYPE     = 'ORS'     
FRAME-82372_INSTRUMENT_TYPE     = 'ORS'    
FRAME-82378_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME-82730_INSTRUMENT_TYPE     = 'MAPS'    
FRAME-82731_INSTRUMENT_TYPE     = 'UNUSED'  
FRAME-82732_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME-82733_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME-82734_INSTRUMENT_TYPE     = 'MAPS'  
FRAME-82740_INSTRUMENT_TYPE     = 'MAPS' 
FRAME-82760_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82761_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82762_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82763_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82764_INSTRUMENT_TYPE     = 'UNUSED'
FRAME-82765_INSTRUMENT_TYPE     = 'UNUSED'
FRAME-82790_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82791_INSTRUMENT_TYPE     = 'UNUSED'
FRAME-82792_INSTRUMENT_TYPE     = 'UNUSED'
FRAME-82810_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82811_INSTRUMENT_TYPE     = 'ORS'
FRAME-82812_INSTRUMENT_TYPE     = 'ORS'
FRAME-82813_INSTRUMENT_TYPE     = 'ORS'
FRAME-82814_INSTRUMENT_TYPE     = 'ORS'
FRAME-82820_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82821_INSTRUMENT_TYPE     = 'MAPS'
FRAME-82822_INSTRUMENT_TYPE     = 'MAPS' 
FRAME-82840_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82842_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82843_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82844_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82845_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82849_INSTRUMENT_TYPE     = 'ORS'
FRAME-82890_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82891_INSTRUMENT_TYPE     = 'ORS'
FRAME-82892_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82893_INSTRUMENT_TYPE     = 'ORS' 
FRAME-82898_INSTRUMENT_TYPE     = 'RADIATOR'

\begintext
