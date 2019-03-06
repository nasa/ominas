KPL/FK

Cassini Body Vector Table Eligibility Status Frames Kernel
Cassini Instrument Type Frames Kernel
=============================================================

To understand how instrument frames map to instrument FOVs, see the fovinfo.txt
report that accompanies the latest Cassini frames kernel.

FRAME_< frame id >_BVT_FRAME
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


FRAME_< frame id >_INSTRUMENT_TYPE
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

           TEXT_KERNEL_ID += 'CASSINI_STATUS V1.0 17-DECEMBER-2004 FK'

           \begintext

   Version 1.0 -- Dec 20, 2004 -- Diane Conner

     Initial file implemented as specified[1].


         
References
----------------------------------------------------------

          1.  Cassini Engineering Change request (ECR) 103373. 


Contact Information
----------------------------------------------------------

   Direct questions, comments or concerns about the contents of this
   kernel to:

           Diane Conner, CASSINI IO/JPL, 
           (818)-354-8586
           Diane.L.Conner@jpl.nasa.gov

           Lee Elson, NAIF/JPL, 
           (818)-354-4223, 
           Lee.Elson@jpl.nasa.gov


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

FRAME_-82000_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82001_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82002_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82008_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82009_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82101_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82102_BVT_STATUS     = 'ELIGIBLE'
FRAME_-82103_BVT_STATUS     = 'ACTIVE' 
FRAME_-82104_BVT_STATUS     = 'ACTIVE'  
FRAME_-82105_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82106_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82107_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82108_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82350_BVT_STATUS     = 'ELIGIBLE'  
FRAME_-82351_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82360_BVT_STATUS     = 'ACTIVE'  
FRAME_-82361_BVT_STATUS     = 'ACTIVE' 
FRAME_-82368_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82369_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82370_BVT_STATUS     = 'ACTIVE'     
FRAME_-82371_BVT_STATUS     = 'ELIGIBLE'   
FRAME_-82372_BVT_STATUS     = 'ACTIVE'    
FRAME_-82378_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82730_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82731_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82732_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82733_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82734_BVT_STATUS     = 'ELIGIBLE'  
FRAME_-82740_BVT_STATUS     = 'ELIGIBLE'  
FRAME_-82760_BVT_STATUS     = 'ELIGIBLE'  
FRAME_-82761_BVT_STATUS     = 'ELIGIBLE'  
FRAME_-82762_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82763_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82764_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82765_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82790_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82791_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82792_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82810_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82811_BVT_STATUS     = 'ELIGIBLE'
FRAME_-82812_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82813_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82814_BVT_STATUS     = 'ELIGIBLE'
FRAME_-82820_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82821_BVT_STATUS     = 'INELIGIBLE' 
FRAME_-82822_BVT_STATUS     = 'INELIGIBLE'
FRAME_-82840_BVT_STATUS     = 'ACTIVE'    
FRAME_-82842_BVT_STATUS     = 'ACTIVE'    
FRAME_-82843_BVT_STATUS     = 'ELIGIBLE' 
FRAME_-82844_BVT_STATUS     = 'ACTIVE'  
FRAME_-82845_BVT_STATUS     = 'ELIGIBLE'
FRAME_-82890_BVT_STATUS     = 'ACTIVE' 
FRAME_-82891_BVT_STATUS     = 'ACTIVE' 
FRAME_-82892_BVT_STATUS     = 'ACTIVE' 
FRAME_-82893_BVT_STATUS     = 'ACTIVE'
FRAME_-82898_BVT_STATUS     = 'INELIGIBLE'



FRAME_-82000_INSTRUMENT_TYPE     = 'UNUSED'
FRAME_-82001_INSTRUMENT_TYPE     = 'SRU' 
FRAME_-82002_INSTRUMENT_TYPE     = 'SRU' 
FRAME_-82008_INSTRUMENT_TYPE     = 'RADIATOR' 
FRAME_-82009_INSTRUMENT_TYPE     = 'RADIATOR' 
FRAME_-82101_INSTRUMENT_TYPE     = 'UNUSED'  
FRAME_-82102_INSTRUMENT_TYPE     = 'ORS'    
FRAME_-82103_INSTRUMENT_TYPE     = 'ORS'   
FRAME_-82104_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82105_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82106_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82107_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82108_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME_-82350_INSTRUMENT_TYPE     = 'MAPS'   
FRAME_-82351_INSTRUMENT_TYPE     = 'MAPS'   
FRAME_-82360_INSTRUMENT_TYPE     = 'ORS'   
FRAME_-82361_INSTRUMENT_TYPE     = 'ORS'   
FRAME_-82368_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME_-82369_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME_-82370_INSTRUMENT_TYPE     = 'ORS'     
FRAME_-82371_INSTRUMENT_TYPE     = 'ORS'     
FRAME_-82372_INSTRUMENT_TYPE     = 'ORS'    
FRAME_-82378_INSTRUMENT_TYPE     = 'RADIATOR'
FRAME_-82730_INSTRUMENT_TYPE     = 'MAPS'    
FRAME_-82731_INSTRUMENT_TYPE     = 'UNUSED'  
FRAME_-82732_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME_-82733_INSTRUMENT_TYPE     = 'UNUSED' 
FRAME_-82734_INSTRUMENT_TYPE     = 'MAPS'  
FRAME_-82740_INSTRUMENT_TYPE     = 'MAPS' 
FRAME_-82760_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82761_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82762_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82763_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82764_INSTRUMENT_TYPE     = 'UNUSED'
FRAME_-82765_INSTRUMENT_TYPE     = 'UNUSED'
FRAME_-82790_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82791_INSTRUMENT_TYPE     = 'UNUSED'
FRAME_-82792_INSTRUMENT_TYPE     = 'UNUSED'
FRAME_-82810_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82811_INSTRUMENT_TYPE     = 'ORS'
FRAME_-82812_INSTRUMENT_TYPE     = 'ORS'
FRAME_-82813_INSTRUMENT_TYPE     = 'ORS'
FRAME_-82814_INSTRUMENT_TYPE     = 'ORS'
FRAME_-82820_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82821_INSTRUMENT_TYPE     = 'MAPS'
FRAME_-82822_INSTRUMENT_TYPE     = 'MAPS' 
FRAME_-82840_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82842_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82843_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82844_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82845_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82890_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82891_INSTRUMENT_TYPE     = 'ORS'
FRAME_-82892_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82893_INSTRUMENT_TYPE     = 'ORS' 
FRAME_-82898_INSTRUMENT_TYPE     = 'RADIATOR'

\begintext
