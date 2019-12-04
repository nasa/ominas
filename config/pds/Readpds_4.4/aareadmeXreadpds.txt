PDS_VERESION_ID        = PDS3                                                 
RECORD_TYPE            = STREAM                                               
OBJECT                 = TEXT                                                 
  NOTE                   = "New Release of readpds"                           
  SOFTWARE_VERSION_ID    = "4.4"                                            
  PUBLICATION_DATE       = 2011-05-01                                         
END_OBJECT             = TEXT                                                 
END                                                                           
                                                                              
************************** File readpds.TXT *******************************   
                                                                              
readpds was created at the Small Bodies Node (SBN) of the Planetary Data      
System (PDS) to read PDS image and data files. For complete explanations      
regarding the use of any of these programs, check the headers of the          
program source files, which end in '.pro'.                                    
                                                                              
A complete listing of the programs follows:                                   
                                                                              
addeobj.pro       - inserts END_OBJECT keyword values in label if not present 
apply_bitmask.pro - applies bitmask on integer arrays or scalars              
arrcolpds.pro     - reads a PDS binary array or collection into IDL array or  
                    structure                                                 
arrcol_struct.pro - populates IDL structure for a given array/collection      
                    object from PDS label                                     
arr_struct.pro    - populates an IDL structure for array object to be read    
btabvect2.pro     - retrieves vectors from PDS binary tables                  
cleanarr.pro      - removes non-printable characters from string arrays       
clean.pro         - removes non-printable characters from scalar strings      
coll_struct.pro   - populates an IDL structure for collection object to be    
                    read                                                      
elem_struct.pro   - populates an IDL structure for element object to be read  
get_index.pro     - retrieves viable end_object index position in a PDS label 
headpds.pro       - retrieves the PDS label from a file                       
imagepds.pro      - retrieves image data from PDS image files                 
objpds.pro        - retrieves viable PDS objects from the labels              
pdspar.pro        - retrieves specified data from the PDS labels              
pointpds.pro      - retrieves pointer information for PDS object from label   
qubepds.pro       - retrieves qube data from PDS qube files                   
readpds.pro*      - calls other routines to obtain images, tables, arrays, etc
remove.pro        - removes specified characters from a string                
str2num.pro       - converts character string to numerical form               
tascpds.pro       - retrieves data from PDS ascii table files                 
tbinpds.pro       - retrieves data from PDS binary table files                
timepds.pro       - retrieves time from PDS labels or ASCII tables

   * Please see below for more information on this procedure.


READPDS.PRO DESCRIPTION:                                                                  
=======================                                                                   
                    
READPDS.PRO is an IDL function that reads data from a PDS image or data       
table file and stores it in an IDL structure. (It is the 'top level'          
program that all of the others in this set are written to serve.)             
                                                                              
The calling syntax of READPDS.PRO is as follows:                              
                                                                              
    result = READPDS( filename,[ /SILENT, /NOSCALE] )                         
                                                                              
where:                                                                        
        - 'result' is the data returned from the PDS image or data table      
          file being read by READPDS.                                         
                                                                              
        - 'filename' is a scalar string containing the name of the PDS        
          file to be read.                                                    
                                                                              
        - 'SILENT' is an optional argument to READPDS that will suppress      
          the default display of the size of the array or structure.          
                                                                              
        - 'NOSCALE' is an optional argument to READPDS that will suppress     
          the default application of SCALING_FACTOR and OFFSET values to      
          and PDS IMAGE or QUBE object array.                                 
                                                                              
READPDS.PRO uses all of the functions in this directory:                      
    ADDEOBJ, APPLY_BITMASK, ARRCOLPDS, ARRCOL_STRUCT, ARR_STRUCT, BTABVECT2,  
    CLEANARR, CLEAN, COLL_STRUCT, ELEM_STRUCT, GET_INDEX, HEADPDS, IMAGEPDS,  
    OBJPDS, PDSPAR, POINTPDS, QUBEPDS, READPDS, REMOVE, STR2NUM, TASCPDS,     
    TBINPDS, and TIMEPDS.                                                     
                                                                              
All of these must be present or be in the idl path for READPDS.PRO to         
function properly.                                                            
                                                                              
As of this version, it is intended to be used on MSB and LSB architectures,   
i.e.,'big-endian' and 'little-endian,' respectively.

CHANGE LOGS:                                                                  
===========                                                                   
                                                                              
   Version    Date      Programmer     Description
    4.4    2010-08-10  B. Prager     Improved memory usage in tascpds.pro. Fixed
                                     the selection of INTERCHANGE_FORMAT for
                                     detached labels in tascpds and tbinpds,
                                     as well as record_bytes in tascpds. Fixed a
                                     bug where the .FMT files were not properly
                                     searched for in the directory tree or in
                                     LABEL subfolders.
                                     
    4.3    2011-05-03  E. Teichman   This release incorporates functions to read
                                     BIT_COLUMN, BIT_ELEMENT, and CONTAINER objects.
                                     Fixed to not trim off leading zeroes when
                                     reading keyword values. Modified to handle properly
                                     unsigned integeres in ARRAY objects. Fixed to
                                     reverse bytes if needed when reading binary tables
                                     to handle endianness. Improved pdspar to resolve
                                     pointer references. 

    4.3    2009-01-19  P. Choganwala Enchanced to look into the LABEL directory
                                     for resolving include pointers (references
                                     to structure files). Added function to read
                                     SPREADSHEET. Improved function to read QUBE
                                     objects. Resolved data type range overflow
                                     binary and ASCII tables.
                                     
                                     TABLEPDS was split again into TASCPDS and
                                     TBINPDS. Removed verification of PDS label
                                     included in 4.2 that will be incorporated as
                                     optional in next releases. Incorporated testing
                                     regression routines.
                                     
    4.2.1  2008-02-25  P. Choganwala Resolved BYTE specification problem
                                     in tascpds.pro. The program was not
                                     reading ASCII tables correctly because
                                     of BYTE specification error.The problem
                                     was solved by restucturing if-else statements
                                     in tascpds.pro.
                                                                      
    4.2.1  2007-11-20  P. Choganwala Fixed problem with "=" sign in description 
                                     field. pdspar.pro was not able to distinguish
                                     keywords correctly because it is considering
                                     "=" sign of description fields also.Logic added 
                                     in program so that it can ommit "=" sign
                                     in description and notes.
                                     
    4.2.1  2007-10-14  P. Choganwala Fixed leading zero problem in pdspar.pro
                                     This program was trimming off the leading
                                     zeros while reading keywords.The function
                                     was corrected which was removing leading zeros.
                                     
    4.2    2005-07-15  P. Khetarpal  This release is for IDL v. 6.0 and above. Combined
                                     TASCPDS and TBINPDS into TABLEPDS routine, which
                                     now handles both ascii and binary data processing.
                                     Reorganized the processing line by including
                                     verification of PDS lavel before any other action
                                     is performed. All routines were rewritten to
                                     stabilize the program.
                                     
                                     As of version 4.2 READPDS is intended to be used
                                     on MSB and LSB architectures, i.e. 'big-endian'
                                     and 'little-endian' respectively.

    4.1.1  2005-04-18  P. Khetarpal  Fixed problem with headpds changing the  
                                     name of the input file. Resolved row     
                                     suffix bytes and padding bytes conflict, 
                                     and fixed some minor errors in table     
                                     object reading.                          
                                                                              
    4.1    2004-01-28  P. Khetarpal  Resolved compatibility for both MSB and  
                                     LSB architectures of all routines.       
                                     Array and collection objects routine was 
                                     rewritten for updated standards.         
                                     Re-instated the NOSCALE keyword for      
                                     images and qubes. Included bit masking   
                                     for signed and unsigned integers.        
                                                                              
    4.0    2004-08-01  P. Khetarpal  Rewrote the major routines for reading   
                                     images, tables, and qubes by using IDL   
                                     structures to read data directly, instead
                                     of reading data element by element. Also,
                                     rewrote routines using many levels of    
                                     subroutines, and thorough error-checking.
                                     Heavy comments were added to almost all  
                                     routines. The previous releases of       
                                     version 3.3.x are compiled into one in   
                                     this release of readpds.                 
                                                                              
   3.3.x   2004-03-18  P. Khetarpal  Fixed bugs for reading array objects     
                                     included with other non-array objects for
                                     IDL. Wrote a new binary array routine to 
                                     read arrays with axes greater than 2.    
                                                                              
    3.2    2003-12-02  P. Khetarpal  Fixed bugs for reading tables with long  
                                     int number of rows or columns; fixed     
                                     item byte issue for reading tables.      
                                                                              
    3.1    2003-10-03  P. Khetarpal  Updated for standards changes; fixed     
                                     minor bugs; increased robustness of      
                                     subroutines; added a subroutine to handle
                                     cleaning of string arrays.               
                                                                              
    3.0    2003-08-05  P. Khetarpal  Updated for standards changes; added     
                                     WINDOW support; added "examples"         
                                     directory; included ARRAY and COLLECTION 
                                     object support. 

EXAMPLES:                                                                     
========                                                                      
                                                                              
LABEL:                                                                        
-----                                                                         
- to obtain a PDS label information as a string array variable, type          
                                                                              
   > label = HEADPDS('pdsfile.lbl')                                           
                                                                              
which will return a string array of the entire pdsfile.lbl and put it into    
the variable label.                                                           
                                                                              
- to obtain a PDS ASCII file that may not contain a header, type              
                                                                              
   > label = HEADPDS('asciifile.txt', /FILE)                                  
                                                                              
which will return the entire text file and store it into variable label.      
                                                                              
- to obtain only the associated ^STRUCTURE file FORMAT.FMT from a label, type 
                                                                              
   > fmt = HEADPDS('format.fmt', /FORMAT)                                     
                                                                              
which will return the entire format.fmt contents and store it into            
the variable fmt.                                                             
                                                                              
* Note: headpds will extract the ^STRUCTURE files by default from a label     
if the keyword is present.                                                    
                                                                              
IMAGE:                                                                        
-----                                                                         
- to read a PDS image file for viewing, type                                  
                                                                              
   > img = READPDS('image.lbl')                                               
                                                                              
which will read data from the file and put it into the variable, 'img'.       
If there are any OFFSET or SCALING_FACTOR keywords present in the IMAGE       
object, then it will apply them to the image array by default. If you would   
like to obtain the image without the OFFSET or SCALING_FACTOR values          
applied, then type                                                            
                                                                              
   > img = READPDS('image.lbl', /NOSCALE)                                     
                                                                              
The following message will be displayed:                                      
                                                                              
   Now reading header: image.lbl                                              
   Now reading 128 by 128 array                                               
   ** Structure <cbde0>, 2 tags, length=32770, data length=32770, refs=1:     
      OBJECTS         INT              1                                      
      IMAGE           INT       Array[128, 128]                               
                                                                              
- to view, type                                                               
                                                                              
   > tvscl, img.image                                                         
                                                                              
which should bring up an idl window with an image of the data from            
'image.lbl' in it. (Multiple images would be returned as an IDL structure     
with the first element named 'images' being the number of images contained    
and the other elements being the images in order found.)                      
                                                                              
Note: img is no longer an image array, but a structure.                       
                                                                              
                                                                              
TABLES:                                                                       
------                                                                        
- to read a PDS ascii table to read or extract information from later, type   
                                                                              
   > data = READPDS('ascii.lbl')                                              
                                                                              
- to read a PDS binary table to read or extract information from later, type  
                                                                              
   > data = READPDS('binary.lbl')                                             
                                                                              
in either case, READPDS will return the data as an IDL structure:             
                                                                              
   Now reading header: ascii.lbl                                              
   Now reading table with 2 Columns and 20 Rows                               
   ** Structure <d5820>, 2 tags, length=368, data length=358, refs=1:         
      OBJECTS         INT              1                                      
      TABLE           STRUCT    -> <Anonymous> Array[1]                       
                                                                              
To access the table, type:                                                    
                                                                              
   > help, /STRUCTURE, data.table                                             
   ** Structure <c8918>, 3 tags, length=360, data length=356, refs=2:         
      COLUMN_NAMES    STRING    Array[3]                                      
      COLUMN1         DOUBLE    Array[20]                                     
      COLUMN2         DOUBLE    Array[20]                                     
                                                                              
Here's how to access columns:                                                 
                                                                              
To access                                                                     
   entire table:  print, result.table                                         
   column names:  print, result.table.column_names                            
   first column:  print, result.table.column1                                 
   second column: print, result.table.column2                                 
                                                                              
which should cause the contents to print to the screen.                       
                                                                              
** Note: For PDS tables, the IDL routines access the "structure" file         
(.fmt) automatically as long as the "structure" file is in the same           
directory.                                                                    
                                                                              
                                                                              
QUBE:                                                                         
----                                                                          
- to read a PDS cube to read or extract information from later, type          
                                                                              
   > cube = READPDS ('qube.lbl')                                              
                                                                              
which should return a three dimensional array.                                
                                                                              
   Now reading header: qube.lbl                                               
   Now reading 256 by 98 by 432 qube array                                    
   ** Structure <ce9b0>, 2 tags, length=21676034, data length=21676034, refs=1
      OBJECTS         INT              1                                      
      QUBE            INT       Array[256, 98, 432]                           
                                                                              
- to view the data from any of the frames, type                               
                                                                              
   > frame = cube[*,*,0]                                                      
   > tvscl, frame                                                             
                                                                              
which should display the first frame on the screen.                           
                                                                              
6D ARRAY:                                                                     
--------                                                                      
- to read a PDS 6D image array with 1 ELEMENT sub-object and the last         
  axis is set to NAXIS6 = 1, type                                             
                                                                              
   array = READPDS ('array.lbl')                                              
                                                                              
which should return a five dimensional array of data.  Since NAXIS6 = 1,      
IDL ignores this axis (for example, a 128 x 128 x 1 image cube is             
equivalent to a 128 x 128 image).                                             
                                                                              
   Now reading header: array.lbl                                              
   Now constructing ARRAY/COLLECTION structure to be read                     
   Now reading ARRAY/COLLECTION object                                        
   ** Structure <a20e8>, 2 tags, length=262148, refs=1:                       
      OBJECTS         INT              1                                      
      ARRAY           LONG      Array[128, 128, 2, 1, 2]                      
                                                                              
- the above description is from an example KECK data file in FITS format.     
  The FITS file contains 2 stacked sets (chop-nod sets), each containing      
  2, two-dimensional images. The PDS label was written as an array object     
  to be read and then displayed as an image.                                  
                                                                              
- to view the first image, type:                                              
                                                                              
  > tvscl, result.array[*,*,0,0,0,0]                                          
                                                                              
or                                                                            
                                                                              
  > tvscl, result.array[*,*,0,0,0]                                            
                                                                              
which should display the first frame on the screen.                           
                                                                              

NOTE: Additional programs not written at SBN are required to properly         
access binary table data. They are 'conv_vax_unix.pro' and                    
'ieee_to_host.pro', and may be found in NASA/Goddard's IDL Astronomy Users    
Library (anonymous ftp at idlastro.gsfc.nasa.gov /pub/astron.tar.Z or WWW     
URL listed below)                                                             
                                                                              
COMPATIBILITY WARNINGS: These programs have only been tested on IDL           
version 5.3, 6.0, and 7.0.6 for SunOS 8.0 and Centos 5, they may not work as well on other         
systems/versions.                                                             
                                                                              
PDS attached, detached and combined-detached labels as well as include pointers
to structure files (FMT) are supported by these programs.

As of version 4.3, READPDS looks in LABEL subdirectory for files referenced by
include pointers that are not included directly at the location of the PDS file
(both upper and lower case). See Rules for Resolving Pointers in the PDS
Standards document for reference.

PDS objects supported by these programs:

Major Objects
- ARRAY
- CONTAINER
- ELEMENT
- IMAGE
- TABLE
- INDEX_TABLE
- GAZETTEER_TABLE
- PALETTE
- SPECTRAL_QUBE
- QUBE
- SERIES
- SPECTRUM
- SPREADSHEET
- Sub-objects
- BIT_COLUMN
- BIT_ELEMENT
- COLLECTION
- COLUMN
- WINDOW
- ELEMENT

PDS objects not supported by these programs:
- CATALOG
- HISTOGRAM
- HISTORY
- IMAGE_MAP_PROJECTION
- SPICE_KERNEL

PDS objects not needed by these programs:
- DATA_PRODUCT
- DATA_SUPPLIER
- DIRECTORY
- DOCUMENT
- FILE
- HEADER
- VOLUME

See Appendix A in the PDS Standards document for reference of approved PDS data
object definitions.                                                         
                                                                              
==============================================================================
For instructions on using these routines, please see aareadme.txt file.       
==============================================================================
                                                                              
FITS: I/O software in the comercial language IDL is available from the IDL    
Astronomy Library (Landsman 1995), which is accessible from the WWW site      
http://idlastro.gsfc.nasa.gov/homepage.html                                   
                                                                              
Landsman, W.B. 1995, "The IDL Astronomy User's Library" in "Astronomical      
Data Analysis Software and Systems IV", ed. R. Shaw, H.E. Payne, J.J.E.       
Hayes, ASP Conference Series 77, p. 437                                       
                                                                              
A listing of some particularly useful 'idlastro' procedures follow:           
headfits.pro    - retrieves the FITS header from a file                       
readfits.pro    - reads a FITS file, returns data                             
sxaddpar.pro    - add or modify a parameter in a FITS array                   
sxpar.pro       - retrieves specified data from FITS headers                  
wherenan.pro    - finds the position of the IEEE NaN special values           
                                                                              
LICENSING INFORMATION:                                                        
IDL is the property of Research Systems, Inc., Copyright 1989-2010            
All rights reserved. Unauthorized reproduction prohibited.                    
The University of Maryland is licensed to use IDL.
