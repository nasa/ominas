 
CASSINI FK files
===========================================================================
 
     This ``aareadme.txt'' file describes contents of the kernels/fk
     directory of the CASSINI SPICE data server. It was last modified on
     January 22, 2003. Contact Chuck Acton (818-354-3869,
     Chuck.Acton@jpl.nasa.gov), Lee Elson (818-354-4223,
     Lee.Elson@jpl.nasa.gov), or Boris Semenov (818-354-8136,
     Boris.Semenov@jpl.nasa.gov) if you have any questions regarding the
     data files provided in this directory.
 
 
Brief summary
--------------------------------------------------------
 
     This directory contains the SPICE frame kernel files for the CASSINI
     spacecraft and its science instruments. All files are text files
     following the UNIX end-of-line convention (lines terminated by <LF>
     only.) Most of the files in this directory have been automatically
     copied from the CASSINI Project Database (DOM.) The following files
     are present in this directory:
 
           cas_v##       Cassini Frames kernel file containing definitions
                         for the Cassini spacecraft, its science
                         instruments, and antennae.
 
           fovinfo       The FOV info report. Lists instrument boresights
                         in the spacecraft frame and FOV angular sizes.
 
           release       Text file documenting release notes; see the
                         Release Notes section below for details.
 
 
FK File Naming Scheme
--------------------------------------------------------
 
     This section describes the CASSINI FK file naming convention.
 
     The FK files produced by the CASSINI IO team are named as follows:
 
        [cas]_v[VV].[Ext]
 
     where:
 
           [cas]     Constant prefix indicating CASSINI FK file;
 
           [VV]      File Version;
 
           [Ext]     Standard SPICE extension for FK files: ``tf'' text
                     frame kernels.
 
 
Release Notes and History
--------------------------------------------------------
 
     A release history containing previous frame kernels and their FOV info
     reports as well as documentation describing updates driving the
     release.
 
 
release.txt
 
     This text file contains a release history, documenting major changes,
     for each frame kernel release. The contents of the file are structured
     as follows:
 
        current:
 
           Date: February 20, 2002
           Notes:
            -- Updated the frame definition for
               CASSINI_VIMS_RAD.
 
        release.06:
 
           Date: January 28, 2002
           Notes:
            -- Updated frame definitions for
               CASSINI_KABAND and CASSINI_XBAND.
 
     The label ``current:'' indicates the release notes for the frame
     kernel currently in kernels/fk. The label ``release.##:'' indicates
     the release notes for the frame kernel and FOV info report stored in
     the directory kernels/fk/release.##.
 
 
release.##
 
     This directory contains the frame kernel and FOV info report from a
     particular (##) release, as documented in kernels/fk/release.txt.
 
