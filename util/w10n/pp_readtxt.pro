 ; docformat = 'rst'
 ;+
 ; :Author: Paulo Penteado (http://www.ppenteado.net), Feb/2014
 ;-
 


 ;+
 ; :Description:
 ;    Reads a text file into a string array. Each line of the text file becomes
 ;    one element of the string array.
 ;
 ; :Params:
 ;    file: in, required
 ;      A string with the name of the file to read.
 ;    count: out, optional
 ;      Returns the number of lines read from the file
 ;      
 ; :Returns:
 ;    A string array with the file contents, one element per line in the file.
 ;    
 ; :Examples:
 ;   Read the example file ascii.txt included with IDL::
 ;   
 ;     fp=filepath('ascii.txt',subdir=['examples','data'])
 ;     contents=pp_readtxt(fp)
 ;     help,contents
 ;     ;CONTENTS        STRING    = Array[20]
 ;     print,contents[0:3],format='(A)'
 ;     ; This file contains ASCII format weather data in a comma delimited table
 ;     ; with comments prefaced by the "%" character. The columns represent:
 ;     ; Longitude, latitude, elevation (in feet), temperature (in degrees F),
 ;     ; dew point (in degrees  F), wind speed (knots), wind direction (degrees)
 ;
 ;
 ;
 ; :Author: Paulo Penteado (http://www.ppenteado.net),
 ;-
function pp_readtxt,file,count
compile_opt idl2,logical_predicate,hidden
count=file_lines(file)
lines=strarr(count)
openr,lun,file,/get_lun
readf,lun,lines
free_lun,lun
return,lines
end
