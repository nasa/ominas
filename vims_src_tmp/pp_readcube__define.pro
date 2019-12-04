; docformat = 'rst'
;+
;
; :Uses: pp_getcubeheadervalue, pp_extractfields, pp_buffered_vector
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-

;+
; :Description:
;    Provided with the name of the file, initializes the object reading the cube in it. 
;
; :Params:
;    file : in, required
;      The name of the file that contains the cube.
;
; :Keywords:
;    special : in, optional, default=0
;      Determines the type of special value replacement to use:
;      
;      0 uses the default special values
;      
;      1 uses the special values found in the header
;      
;      2 disables special value replacement
;
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::init,file,special=special
compile_opt idl2,hidden

;Defaults
special=n_elements(special) eq 1 ? special : 0B
self.special=special

ret=0
if (n_elements(file) ne 1) then begin
  print,'pp_readcube: Cube name not provided'
  return,ret
endif else if (file eq '') then return,ret ;Silently get out to allow the trick in pp_cubecollection::init
header=obj_new('pp_buffered_vector')
history=obj_new('pp_buffered_vector')
error_status=0;catch,error_status
if (error_status ne 0) then begin
  catch,/cancel
  print,'pp_readcube: Cube named "',file,'" could not be read or parsed'
endif else begin
  self.file=file
;Read the header
  openr,unit,file,/get_lun
  line=''
;Test for a valid cube
  readf,unit,line
;First line must start with 'CCSD'
  if (strpos(line,'CCSD') ne 0) then print,'pp_readcube: "',file,'" does not appear to be a valid cube' else begin 
;Cube seems to be valid, so proceed reading header
    header->append,line
    repeat begin
      if (not eof(unit)) then readf,unit,line else begin
        print,'pp_readcube: "',file,'" does not appear to be a valid cube' ;Header must end before the file ends
        break
      endelse
      header->append,line
    endrep until (strtrim(line,2) eq 'END')
;Get a string array from the header object
    self.labels=ptr_new(header->getdata(/all))
    self.tlabels=ptr_new(strtrim(*self.labels,2))
;Parse the labels
    if self->parselabels() then begin
;Get the history part
      if ((self.info.filerecords-self.info.labelrecords) gt 0) then begin
        point_lun,unit,self.info.recordbytes*self.info.historystart
        repeat begin
          if (not eof(unit)) then readf,unit,line else begin
            print,'pp_readcube: "',file,'" does not appear to be a valid cube' ;Header must end before the file ends
            break
          endelse
          history->append,line
        endrep until (strtrim(line,2) eq 'END')
;Get a string array from the header object
        self.history=ptr_new(history->getdata(/all))
        self.thistory=ptr_new(strtrim(*self.history,2))
      endif            
;Get the binary part
      raw=make_array(self.info.dims,type=self.info.datatype,/nozero)
      point_lun,unit,self.info.recordbytes*self.info.binarystart
      readu,unit,raw
      self.raw=ptr_new(raw,/no_copy)
    endif else message,'"'+file+'" does not appear to have enough information in its header'
  endelse
;Process the data
  self->processdata
  ret=1
endelse
catch,/cancel
if (n_elements(unit) eq 1) then free_lun,unit
obj_destroy,header
obj_destroy,history
return,ret
end

pro pp_readcube::cleanup
compile_opt idl2,hidden
ptr_free,self.labels,self.tlabels,self.history,self.thistory,self.raw
ptr_free,self.core,self.backplanes,self.sideplanes,self.bottomplanes
ptr_free,self.wavs,self.bnames,self.snames,self.bonames
ptr_free,self.wavs,self.bunits,self.sunits,self.bounits
end

function pp_readcube::parselabels
;Gets the minimum required information from the header to be able to
;read the data in the cube.
compile_opt idl2,hidden

;Get the core and suffix dimensions
theader=*self.tlabels
count=1
self.info.coredims=long(pp_getcubeheadervalue(theader,'CORE_ITEMS',count=tmp)) & count*=tmp
self.info.suffdims=long(pp_getcubeheadervalue(theader,'SUFFIX_ITEMS',count=tmp)) & count*=tmp
self.info.dims=self.info.coredims+self.info.suffdims
;Determine the data type
self.info.bytes=fix(pp_getcubeheadervalue(theader,'CORE_ITEM_BYTES',count=tmp)) & count*=tmp
self.info.type=pp_getcubeheadervalue(theader,'CORE_ITEM_TYPE',count=tmp) & count*=tmp
if (strpos(self.info.type,'REAL') ne -1) then begin
  case self.info.bytes of
    8 : self.info.datatype=5 ;double 
    else : self.info.datatype=4 ;float
  endcase
endif else begin
  case self.info.bytes of
    1 : self.info.datatype=1 ;byte
    2 : self.info.datatype=2 ;int
    8 : self.info.datatype=14 ;long64
    else : self.info.datatype=3 ;long
  endcase
endelse
;Determine endianness
self.info.littleendian=(strpos(self.info.type,'PC') ne -1)
;Determine the length and location of the labels, history and data parts
self.info.recordbytes=long(pp_getcubeheadervalue(theader,'RECORD_BYTES',count=tmp)) & count*=tmp
self.info.historystart=long(pp_getcubeheadervalue(theader,'\^HISTORY',count=tmp))-1L & count*=tmp
self.info.binarystart=long(pp_getcubeheadervalue(theader,'\^QUBE',count=tmp))-1L & count*=tmp
self.info.filerecords=long(pp_getcubeheadervalue(theader,'FILE_RECORDS',count=tmp))-1L & count*=tmp
self.info.labelrecords=long(pp_getcubeheadervalue(theader,'LABEL_RECORDS',count=tmp))-1L & count*=tmp
self.info.historyrecords=self.info.filerecords-self.info.labelrecords
self.info.binaryrecords=self.info.filerecords-self.info.binarystart-1

;Get the core wavelengths
wavs=double(pp_getcubeheadervalue(theader,'BAND_BIN_CENTER',count=tmp))
wavs=tmp gt 0 ? wavs : replicate('UNKNOWN',self.info.coredims[2])
self.wavs=ptr_new(wavs,/no_copy)
;Get the core units
units=pp_getcubeheadervalue(theader,'BAND_BIN_UNIT',count=tmp)
self.units=tmp gt 0 ? units : ''
;Get the backplane names
if (self.info.suffdims[2] gt 0) then begin
  bnames=pp_getcubeheadervalue(theader,'BAND_SUFFIX_NAME',count=tmp)
  bnames=tmp gt 0 ? bnames : 'UNKNOWN_'+strtrim(sindgen(self.info.suffdims[2]),2)
  self.bnames=ptr_new(bnames,/no_copy)
;Get the backplane unit names
  bunits=pp_getcubeheadervalue(theader,'BAND_SUFFIX_UNIT',count=tmp)
  bunits=tmp gt 0 ? bunits : replicate('UNKNOWN',self.info.suffdims[2])
  self.bunits=ptr_new(bunits,/no_copy)
endif
;Get the sideplane names
if (self.info.suffdims[0] gt 0) then begin
  snames=pp_getcubeheadervalue(theader,'SAMPLE_SUFFIX_NAME',count=tmp)
  snames=tmp gt 0 ? snames : 'UNKNOWN_'+strtrim(sindgen(self.info.suffdims[0]),2)
  self.snames=ptr_new(snames,/no_copy)
;Get the sideplane unit names
  sunits=pp_getcubeheadervalue(theader,'SAMPLE_SUFFIX_UNIT',count=tmp)
  sunits=tmp gt 0 ? sunits : replicate('UNKNOWN',self.info.suffdims[0])
  self.sunits=ptr_new(sunits,/no_copy)
endif
;Get the bottomplane names
if (self.info.suffdims[1] gt 0) then begin
  bonames=pp_getcubeheadervalue(theader,'LINE_SUFFIX_NAME',count=tmp)
  bonames=tmp gt 0 ? bonames : 'UNKNOWN_'+strtrim(sindgen(self.info.suffdims[1]),2)
  self.bonames=ptr_new(bonames,/no_copy)
;Get the bottomplane unit names
  bounits=pp_getcubeheadervalue(theader,'LINE_SUFFIX_UNIT',count=tmp)
  bounits=tmp gt 0 ? bounits : replicate('UNKNOWN',self.info.suffdims[1])
  self.bounits=ptr_new(bounits,/no_copy)
endif

return,(count ne 0) ;A return value of 0 indicates failure to read all the required information
end

pro pp_readcube::processdata
;Extracts the core and suffix parts of the raw data, swaps bytes if necessary,
;and does special value replacement if selected.
compile_opt idl2,hidden

cdims=self.info.coredims
sdims=self.info.suffdims

;Get the core
core=(*self.raw)[0:cdims[0]-1,0:cdims[1]-1,0:cdims[2]-1]
;Get the suffix
back=(sdims[2] gt 0) ;Are there backplanes?
side=(sdims[0] gt 0) ;Are there sideplanes?
bottom=(sdims[1] gt 0) ;Are there bottomplanes?
if back then backplanes=(*self.raw)[0:cdims[0]-1,0:cdims[1]-1,cdims[2]:cdims[2]+sdims[2]-1]
if side then sideplanes=(*self.raw)[cdims[0]:cdims[0]+sdims[0]-1,0:cdims[1]-1,0:cdims[2]-1]
if bottom then bottomplanes=(*self.raw)[0:cdims[0]-1,cdims[1]:cdims[1]+sdims[1]-1,0:cdims[2]-1]

;Swap byte order if necessary
l_e=self.info.littleendian
b_e=~l_e
byteorder,core,swap_if_big_endian=l_e,swap_if_little_endian=b_e
if back then byteorder,backplanes,swap_if_big_endian=l_e,swap_if_little_endian=b_e
if side then byteorder,sideplanes,swap_if_big_endian=l_e,swap_if_little_endian=b_e
if bottom then byteorder,bottomplanes,swap_if_big_endian=l_e,swap_if_little_endian=b_e

;Replace special values, if requested
if (self.special eq 0) || (self.special eq 1) then begin
  special=self->getspecialvalues()
  core=pp_readcube_specialreplace(core,special)
  if back then backplanes=pp_readcube_specialreplace(backplanes,special)
  if side then sideplanes=pp_readcube_specialreplace(sideplanes,special)
  if bottom then bottomplanes=pp_readcube_specialreplace(bottomplanes,special)
endif

;Store the processed data
self.core=ptr_new(core,/no_copy)
if back then self.backplanes=ptr_new(backplanes,/no_copy)
if side then self.sideplanes=ptr_new(sideplanes,/no_copy)
if bottom then self.bottomplanes=ptr_new(bottomplanes,/no_copy)

end

;+
; :Description:
;    Provides a structure with the special values to use in this cube,
;    determined by the special replacement mode selected when the object
;    was created (see documentation of the init method).
;
; :Returns:
;    A structure where each field is one of the six special values:
;    VALID_MIN,NULL,LOW_REPR_SAT,LOW_INSTR_SAT,HIGH_INSTR_SAT,HIGH_REPR_SAT
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getspecialvalues,default=default
compile_opt idl2

default=n_elements(default) eq 1 ? default : 0

;Constants
;Default special values (from ISIS' SpecialPixel.h)
;8-byte:
special_8={VALID_MIN:'FEFFFFFFFFFFFFA'xull,$
 NULL:'FFEFFFFFFFFFFFFB'xull,$
 LOW_REPR_SAT:'FFEFFFFFFFFFFFFC'xull,$
 LOW_INSTR_SAT:'FFEFFFFFFFFFFFFD'xull,$
 HIGH_INSTR_SAT:'FFEFFFFFFFFFFFFE'xull,$
 HIGH_REPR_SAT:'FFEFFFFFFFFFFFFF'xull}
;4-byte:
special_4={VALID_MIN:'FF7FFFFA'xul,$
 NULL:'FF7FFFFB'xul,$
 LOW_REPR_SAT:'FF7FFFFC'xul,$
 LOW_INSTR_SAT:'FF7FFFFD'xul,$
 HIGH_INSTR_SAT:'FF7FFFFE'xul,$
 HIGH_REPR_SAT:'FF7FFFFF'xul}
;2-byte:
special_2={VALID_MIN:-32752S,$
 NULL:fix(-32768),$
 LOW_REPR_SAT:-32767S,$
 LOW_INSTR_SAT:-32766S,$
 HIGH_INSTR_SAT:-32765S,$
 HIGH_REPR_SAT:-32764S,$
 VALID_MAX:32767S}
;1-byte:
special_1={VALID_MIN:1B,$
 NULL:0B,$
 LOW_REPR_SAT:0B,$
 LOW_INSTR_SAT:0B,$
 HIGH_INSTR_SAT:255B,$
 HIGH_REPR_SAT:255B,$
 VALID_MAX:254B}

sel=default ? 0 : self.special
switch sel of
 1 : begin ;Get the set of special values from the header
   theader=*self.theader
   count=1
   vmin=pp_getcubeheadervalue(theader,'CORE_VALID_MINIMUM',count=tmp) & count*=tmp
   null=pp_getcubeheadervalue(theader,'CORE_NULL',count=tmp) & count*=tmp
   lrs=pp_getcubeheadervalue(theader,'CORE_LOW_REPR_SATURATION',count=tmp) & count*=tmp
   lis=pp_getcubeheadervalue(theader,'CORE_LOW_INSTR_SATURATION',count=tmp) & count*=tmp
   hrs=pp_getcubeheadervalue(theader,'CORE_HIGH_REPR_SATURATION',count=tmp) & count*=tmp
   his=pp_getcubeheadervalue(theader,'CORE_HIGH_INSTR_SATURATION',count=tmp) & count*=tmp
   if (count ne 0) then begin
     if (self.info.bytes ge 4) then begin ;Special values that are written in hex
       tmp=self.info.bytes eq 8 ? 0ULL : 0UL
       reads,vmin,ltmp,format='(3X,Z,1X)' & vmin=ltmp
       reads,null,ltmp,format='(3X,Z,1X)' & null=ltmp
       reads,lrs,ltmp,format='(3X,Z,1X)' & lrs=ltmp
       reads,lis,ltmp,format='(3X,Z,1X)' & lis=ltmp
       reads,hrs,ltmp,format='(3X,Z,1X)' & hrs=ltmp
       reads,his,ltmp,format='(3X,Z,1X)' & his=ltmp
     endif
     case self.info.bytes of ;Select the proper processing of the values
      1 : special={VALID_MIN:byte(vmin),NULL:byte(null),LOW_REPR_SAT:byte(lrs),$
           LOW_INSTR_SAT:byte(lis),HIGH_INSTR_SAT:byte(his),HIGH_REPR_SAT:byte(hrs)}
      2 : special={VALID_MIN:fix(vmin),NULL:fix(null),LOW_REPR_SAT:fix(lrs),$
           LOW_INSTR_SAT:fix(lis),HIGH_INSTR_SAT:fix(his),HIGH_REPR_SAT:fix(hrs)}
      8 : special={VALID_MIN:vmin,NULL:null,LOW_REPR_SAT:lrs,$
           LOW_INSTR_SAT:lis,HIGH_INSTR_SAT:his,HIGH_REPR_SAT:hrs}
      else : special={VALID_MIN:vmin,NULL:null,LOW_REPR_SAT:lrs,$
              LOW_INSTR_SAT:lis,HIGH_INSTR_SAT:his,HIGH_REPR_SAT:hrs}
     endcase
     break
;If header does not provide enough information, fall through to defaults
   endif else print,'pp_readcube: Warning: Cube header does not have all special values, using default values'
 end
 else : begin
   case self.info.bytes of ;Select the proper default set of special values
    1 : special=special_1
    2 : special=special_2
    8 : special=special_8
    else : special=special_4
   endcase
   self.special=0
 end
endswitch
return,special
end

function pp_readcube_specialreplace,data,special
;Given a structure special containing the special values (as returned by pp_readcube::getspecial),
;replaces the occurrences of special values in the array data by NaN (real types),
;or special.null (integer types). 
compile_opt idl2,hidden
datatype=size(data,/type)
  case datatype of ;Reals are treated differently from integers
   4 : begin ;Floats
     rep=!values.f_nan
     w=where(data lt float(special.valid_min,0),count)
     if (count gt 0) then data[w]=rep
     sel=(data eq float(special.null,0))
     sel=sel or (data eq float(special.low_repr_sat,0))
     sel=sel or (data eq float(special.low_instr_sat,0))
     sel=sel or (data eq float(special.high_instr_sat,0))
     sel=sel or (data eq float(special.high_repr_sat,0))
     w=where(sel,count)
     if (count gt 0) then data[w]=rep
   end
   5 : begin ;Doubles
     rep=!values.d_nan
     w=where(data lt double(special.valid_min,0),count)
     if (count gt 0) then data[w]=rep
     sel=(data eq double(special.null,0))
     sel=sel or (data eq double(special.low_repr_sat,0))
     sel=sel or (data eq double(special.low_instr_sat,0))
     sel=sel or (data eq double(special.high_instr_sat,0))
     sel=sel or (data eq double(special.high_repr_sat,0))
     w=where(sel,count)
     if (count gt 0) then data[w]=rep
   end
   else : begin ;Integers
     rep=special.null
     w=where(data lt special.valid_min,count)
     if (count gt 0) then data[w]=rep
     sel=(data eq special.null)
     sel=sel or (data eq special.low_repr_sat)
     sel=sel or (data eq special.low_instr_sat)
     sel=sel or (data eq special.high_instr_sat)
     sel=sel or (data eq special.high_repr_sat)
     w=where(sel,count)
     if (count gt 0) then data[w]=rep     
   end
  endcase
return,data
end

function pp_readcube::getexerpt
compile_opt idl2,logical_predicate
nx=self.info.coredims[0]
nz=self.info.coredims[1]
npixels=nx*nz
ret=replicate({x:0,z:0,lats:dblarr(4)+!values.d_nan,lons:dblarr(4)+!values.d_nan,lat:!values.d_nan,$
  lon:!values.d_nan,emissions:dblarr(4)+!values.d_nan,phases:dblarr(4)+!values.d_nan,incidences:$
  dblarr(4)+!values.d_nan,az_difs:dblarr(4)+!values.d_nan,emission:!values.d_nan,phase:!values.d_nan,$
  incidence:!values.d_nan,az_dif:!values.d_nan},npixels)
lats=reform(self.getsuffixbyname('LAT_'+strtrim(indgen(5),2)),npixels,5)
lons=reform(self.getsuffixbyname('LON_'+strtrim(indgen(5),2)),npixels,5)
emissions=reform(self.getsuffixbyname('EMISSION_'+strtrim(indgen(5),2)),npixels,5)
phases=reform(self.getsuffixbyname('PHASE_'+strtrim(indgen(5),2)),npixels,5)
incidences=reform(self.getsuffixbyname('INCIDENCE_'+strtrim(indgen(5),2)),npixels,5)
az_difs=reform(self.getsuffixbyname('AZ_DIF_'+strtrim(indgen(5),2)),npixels,5)
x=(indgen(nx)+1)#replicate(1,nz)
z=replicate(1,nx)#(indgen(nz)+1)
x=reform(x,npixels)
z=reform(z,npixels)
ret.x=x & ret.z=z
ret.lat=lats[*,0]
ret.lon=lons[*,0]
ret.incidence=incidences[*,0]
ret.phase=phases[*,0]
ret.emission=emissions[*,0]
ret.az_dif=az_difs[*,0]
ret.lats=transpose(lats[*,1:4])
ret.lons=transpose(lons[*,1:4])
ret.incidences=transpose(incidences[*,1:4])
ret.phases=transpose(phases[*,1:4])
ret.emissions=transpose(emissions[*,1:4])
ret.az_difs=transpose(az_difs[*,1:4])
return,ret
end

;+
; :Description:
;    Retrieves parts of the data contained in the object. If keyword all is given,
;    returns all the properties as fields of a structure.
;
; :Returns:
;    See keyword descriptions.
;
; :Keywords:
;    all : out, optional
;      A structure containing every property as a field with the same name as the corresponding keyword.
;    file : out, optional
;      File from which the cube was read.
;    special : out, optional
;      The special value replacement mode used when the data was processed: 0 for default special values,
;      1 for special values given in the header, 2 for no special value replacement.
;    labels : out, optional
;      String array with one element for each line of the label part of the cube header.
;    history : out, optional
;      String array with one element for each line of the history part of the cube header. 
;    core : out, optional
;      3D array with the core data values.
;    backplanes : out, optional
;      3D array with the backplane values, if there are blackplanes, a null pointer otherwise.
;    sideplanes : out, optional
;      3D array with the sideplane values, if there are sideplanes, a null pointer otherwise.
;    bottomplanes : out, optional
;      3D array with the bottomplane values, if there are bottomplanes, a null pointer otherwise.
;    info : out, optional
;      A structure with the cube parameters that were used to read it.
;    lines : out, optional
;      The number of lines in the core.
;    bands : out, optional
;      The number of bands in the core.
;    samples : out, optional
;      The number of samples in the core.
;    nback : out, optional
;      The number of backplanes in the suffix.
;    nside : out, optional
;      The number of sideplanes in the suffix.
;    nbottom : out, optional
;      The number of bottomplanes in the suffix.
;    rawdata : out, optional
;      The unprocessed binary part of the cube.
;    wavelengths : out, optional
;      A string array with the wavelength of each core band ('UNKNOWN's if not found).
;    backnames : out, optional
;      A string array with the name of each backplane ('UNKNOWN_'+sindgen(nback) if not found).
;    sidenames : out, optional
;      A string array with the name of each sideplane ('UNKNOWN_'+sindgen(nside) if not found).
;    bottomnames : out, optional
;      A string array with the name of each bottomplane ('UNKNOWN_'+sindgen(nbottom) if not found).
;    units : out, optional
;      A string with the wavelength unit of the core bands ('UNKNOWN' if not found).
;    backunits : out, optional
;      A string array with the name of each backplane's unit ('UNKNOWN's if not found).
;    sideunits : out, optional
;      A string array with the name of each sideplane's unit ('UNKNOWN's if not found).
;    bottomunits : out, optional
;      A string array with the name of each bottomplane's unit ('UNKNOWN's if not found).
;    struct_backplanes : out, optional
;      2D array of structures, each with one field for each backplane, if there are blackplanes, a null pointer otherwise.
;
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
pro pp_readcube::getproperty,all=all,file=file,special=special,labels=labels,history=history,$
 core=core,backplanes=backplanes,sideplanes=sideplanes,bottomplanes=bottomplanes,$
 info=info,lines=lines,bands=bands,samples=samples,nback=nback,nside=nside,nbottom=nbottom,$
 rawdata=raw,wavelengths=wavs,backnames=bnames,sidenames=snames,bottomnames=bonames,$
 units=wunits,backunits=bunits,sideunits=sunits,bottomunits=bounits,struct_backplanes=struct_backplanes,$
 npixels=npixels,lats=lats,lons=lons
compile_opt idl2

all=arg_present(all)
if (all || arg_present(file)) then file=self.file
if (all || arg_present(special)) then special=self.special
if (all || arg_present(labels)) then labels=*self.labels
if (all || arg_present(history)) then history=*self.history
if (all || arg_present(core)) then core=*self.core
if (all || arg_present(backplanes)) then backplanes=ptr_valid(self.backplanes) ? *self.backplanes : self.backplanes
if (all || arg_present(sideplanes)) then sideplanes=ptr_valid(self.sideplanes) ? *self.sideplanes : self.sideplanes
if (all || arg_present(bottomplanes)) then bottomplanes=ptr_valid(self.bottomplanes) ? *self.bottomplanes : self.bottomplanes
if (all || arg_present(info)) then info=self.info
if (all || arg_present(lines)) then lines=self.info.coredims[1]
if (all || arg_present(samples)) then samples=self.info.coredims[0]
if (all || arg_present(npixels)) then npixels=self.info.coredims[0]*self.info.coredims[1]
if (all || arg_present(bands)) then bands=self.info.coredims[2]
if (all || arg_present(nback)) then nback=self.info.suffdims[2]
if (all || arg_present(nside)) then nside=self.info.suffdims[0]
if (all || arg_present(nbottom)) then nbottom=self.info.suffdims[1]
if (all || arg_present(raw)) then raw=*self.raw
if (all || arg_present(wavs)) then wavs=*self.wavs
if (all || arg_present(bnames)) then bnames=ptr_valid(self.bnames) ? *self.bnames : self.bnames
if (all || arg_present(snames)) then snames=ptr_valid(self.snames) ? *self.snames : self.snames
if (all || arg_present(bonames)) then bonames=ptr_valid(self.bonames) ? *self.bonames : self.bonames
if (all || arg_present(wunits)) then wunits=self.units
if (all || arg_present(bunits)) then bunits=ptr_valid(self.bunits) ? *self.bunits : self.bunits
if (all || arg_present(sunits)) then sunits=ptr_valid(self.sunits) ? *self.sunits : self.sunits
if (all || arg_present(bounits)) then bounits=ptr_valid(self.bounits) ? self.bounits : self.bounits
if (all || arg_present(struct_backplanes)) then begin
  if (ptr_valid(self.bnames)) then begin
  nt=n_elements(*self.bnames)
  tmp=create_struct((*self.bnames)[0],0d0)
  for i=1,nt-1 do tmp=create_struct(tmp,(*self.bnames)[i],0d0)
  struct_backplanes=replicate(tmp,self.info.coredims[0],self.info.coredims[1],self.info.suffdims[2])
  for i=0,nt-1 do struct_backplanes[*,*].(i)=(*self.backplanes)[*,*,i]
  endif else struct_backplanes=ptr_new()
endif

if arg_present(lats) then begin
  lats=self[['lat_1','lat_2','lat_3','lat_4']]
  self.getproperty,npixels=np
  lats=reform(lats,np,4)
  lats=transpose(lats)
endif

if arg_present(lons) then begin
  lons=self[['lon_1','lon_2','lon_3','lon_4']]
  self.getproperty,npixels=np
  lons=reform(lons,np,4)
  lons=transpose(lons)
endif

if all then all={file:file,special:special,labels:labels,history:history,core:core,$
   backplanes:backplanes,sideplanes:sideplanes,bottomplanes:bottomplanes,$
   info:info,lines:lines,samples:samples,bands:bands,$
   nback:nback,nside:nside,nbottom:nbottom,$
   raw:raw,wavelengths:wavs,backnames:bnames,sidenames:snames,bottomnames:bonames,$
   units:wunits,backunits:bunits,sideunits:sunits,bottomunits:bounits,struct_backplanes:struct_backplanes}
   
end

;+
; :Description:
;    Simple function wrapper for the routine method getproperty. Has the same keywords,
;    and retrieves the same values, but with function semantics instead of routine. Only
;    one keyword should be set, and the corresponding value is the function's return value.
;
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getproperty,all=all,file=file,special=special,labels=labels,history=history,$
 core=core,backplanes=backplanes,sideplanes=sideplanes,bottomplanes=bottomplanes,$
 info=info,lines=lines,bands=bands,samples=samples,nback=nback,nside=nside,nbottom=nbottom,$
 rawdata=raw,wavelengths=wavs,backnames=bnames,sidenames=snames,bottomnames=bonames,$
 units=wunits,backunits=bunits,sideunits=sunits,bottomunits=bounits
compile_opt idl2
if keyword_set(all) then self->getproperty,all=ret
if keyword_set(file) then self->getproperty,file=ret
if keyword_set(special) then self->getproperty,special=ret
if keyword_set(labels) then self->getproperty,labels=ret
if keyword_set(history) then self->getproperty,history=ret
if keyword_set(core) then self->getproperty,core=ret
if keyword_set(backplanes) then self->getproperty,backplanes=ret
if keyword_set(sideplanes) then self->getproperty,sideplanes=ret
if keyword_set(bottomplanes) then self->getproperty,bottomplanes=ret
if keyword_set(info) then self->getproperty,info=ret
if keyword_set(lines) then self->getproperty,lines=ret
if keyword_set(bands) then self->getproperty,bands=ret
if keyword_set(samples) then self->getproperty,samples=ret
if keyword_set(nback) then self->getproperty,nback=ret
if keyword_set(nside) then self->getproperty,nside=ret
if keyword_set(nbottom) then self->getproperty,nbottom=ret
if keyword_set(raw) then self->getproperty,rawdata=ret
if keyword_set(wavs) then self->getproperty,wavelengths=ret
if keyword_set(bnames) then self->getproperty,backnames=ret
if keyword_set(snames) then self->getproperty,sidenames=ret
if keyword_set(bonames) then self->getproperty,bottomnames=ret
if keyword_set(wunits) then self->getproperty,units=ret
if keyword_set(bunits) then self->getproperty,backunits=ret
if keyword_set(sunits) then self->getproperty,sideunits=ret
if keyword_set(bounits) then self->getproperty,bottomunits=ret
if keyword_set(all) then self->getproperty,all=ret
return,ret
end

;+
; :Description:
;    Retrieves suffix planes by their names. If all suffix planes, or their names,
;    are to be retrieved, the getproperty method should be used instead. By default,
;    backplanes are retrieved, but sideplanes and bottomplanes can be returned if the
;    corresponding keyword is set.
;
; :Returns:
;    A 2D array (if only one plane is requested) or 3D array (if several planes) with
;    the names suffix planes. If one plane is not found, the corresponding array plane contains
;    either NaN (for real types) or special.null (for integer types). 
;
; :Params:
;    names : in, required
;      A scalar or string array with the name(s) of the suffix plane(s) to retrieve.
;      If more than one plane is returned, their order (in the 3rd dimension of the
;      returned array) is the same as the order of the names in this array.
;
; :Keywords:
;    found : out, optional
;      An integer array with the same number of elements as names, with the number
;      of suffix planes that match each given name. If more than one suffix plane has
;      the selected name, the first one is the one returned (though proper cubes should
;      not have multiple planes with the same name).
;    index : out, optional
;      An integer array with the same number of elements as names, with the index of the returned
;      suffix planes that matched each given name. If more than one suffix plane has
;      the selected name, the first one is the one returned (though proper cubes should
;      not have multiple planes with the same name). When that plane was not found, the corresponding
;      index will be -1.
;    case_sensitive : in, optional, default=0
;      If set, name matches are case-sensitive (though proper cubes should not have planes
;      the same name in different capitalizations). 
;    side : in, optional, default=0
;      By default, the search for the planes is done among the cube's backplanes. If this keyword is
;      set, sideplanes are used instead.
;    bottom : in, optional, default=0
;      By default, the search for the planes is done among the cube's backplanes. If this keyword is
;      set, bottomplanes are used instead.
;    back : in, optional, default=1
;      If set, the search for the planes is done among the cube's backplanes (default).
;       
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getsuffixbyname,names,found=found,case_sensitive=cases,side=side,bottom=bottom,back=back,index=index
compile_opt idl2

;Defaults
cases=n_elements(cases) eq 1 ? cases : 0
back=n_elements(back) eq 1 ? back : 1
side=n_elements(side) eq 1 ? side : 0
bottom=n_elements(bottom) eq 1 ? bottom : 0

;Initialize the return arrays
nnames=n_elements(names)
if (nnames eq 0) then message,'Names for the suffix planes were not provided'
type=back ? 2 : (side ? 0 : (bottom ? 1 : 2))
case type of
  2 : ret=make_array(type=self.info.datatype,[self.info.coredims[[0,1]],nnames],/nozero)
  0 : ret=make_array(type=self.info.datatype,[self.info.coredims[[1,2]],nnames],/nozero)
  1 : ret=make_array(type=self.info.datatype,[self.info.coredims[[0,2]],nnames],/nozero)
endcase
special=self->getspecialvalues()
ret[*]=self.info.datatype eq 4 ? !values.f_nan : (self.info.datatype eq 5 ? !values.d_nan : special.null)
found=intarr(nnames)
index=intarr(nnames)
;Retrieve the names and values of the proper suffix
sufnames=type eq 2 ? self.bnames : (type eq 0 ? self.snames : self.bonames)
sufvals=type eq 2 ? self.backplanes : (type eq 0 ? self.sideplanes : self.bottomplanes)
if ptr_valid(sufnames) then begin
  csufnames=cases ? *sufnames : strupcase(*sufnames)
  cnames=cases ? names : strupcase(names)
  for i=0,nnames-1 do begin
    if (cnames[i]  eq 'X') or (cnames[i]  eq 'Z') then begin
      if (cnames[i]  eq 'X') then tmp=indgen(self.info.coredims[[0,1]]) mod self.info.coredims[0] 
      if (cnames[i]  eq 'Z') then tmp=reverse(floor(indgen(self.info.coredims[[0,1]]) / self.info.coredims[0]),2)
      ret[0,0,i]=tmp+1
    endif else begin
      w=where((strpos(csufnames,cnames[i]) ne -1),nw)
      found[i]=nw
      index[i]=w[0]
      if (nw gt 0) then ret[0,0,i]=(*sufvals)[*,*,w[0]]
    endelse 
  endfor
endif
return,ret
end

;+
; :Description:
;    Retrieves one or more core bands from their wavelengths. The returned bands
;    are those with wavelength nearest to the ones provided, so they need not
;    match exactly.
;
; :Returns:
;    If only one wavelength is provided, returns a 2D array with that band.
;    If more than one wavelength is provided, the result is a 3D array, with the
;    3rd dimension being the bands.
;
; :Params:
;    wavs : in, required
;      A scalar or array with the value(s) of the wavelength(s) to search for. 
;
; :Keywords:
;    index : out, optional
;      Returns the index of the band that matched each provided wavelength.
;       
;    wavelengths : out, optional
;      Returns the wavelength of the band that matched each provided wavelength. 
;
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getbandbywavelength,wavs,index=inds,wavelengths=sdwavs
compile_opt idl2

nwavs=n_elements(wavs)
if (nwavs eq 0) then message,'Wavelengths were not provided'
;Make the double array for the wavelengths
catch,error_status
if (error_status ne 0) then begin
  catch,/cancel
  message,'Cube does not contain valid wavelengths'
endif else dwavs=double(*self.wavs)
ndwavs=n_elements(dwavs)
tmp0=rebin(reform(wavs,1,nwavs),ndwavs,nwavs)
tmp1=rebin(dwavs,ndwavs,nwavs)
void=min(tmp0-tmp1,inds,/abs,dim=1,/nan)
inds=reform((array_indices(tmp0,inds))[0,*])
ret=(*self.core)[*,*,inds]
sdwavs=dwavs[inds]
return,ret
end

;+
; :Description:
;    Retrieves one or more core bands from their indexes.
;
; :Returns:
;    If only one index is provided, returns a 2D array with that band.
;    If more than one index is provided, the result is a 3D array, with the
;    3rd dimension being the bands.
;
; :Params:
;    index : in, required
;      A scalar or array with the value(s) of the index(es) to search for. 
;
; :Keywords:
;       
;    wavelengths : out, optional
;      Returns the wavelength of the band that matched each provided index. 
;
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getbandbyindex,index,wavelengths=sdwavs
compile_opt idl2

ninds=n_elements(index)
if (ninds eq 0) then message,'Indexes were not provided'
;Make the double array for the wavelengths
catch,error_status
if (error_status ne 0) then begin
  catch,/cancel
  message,'Cube does not contain given band'
endif else dwavs=double(*self.wavs)
ret=(*self.core)[*,*,index]
sdwavs=dwavs[index]
return,ret
end

;+
; :Description:
;    Retrieves values contained in the label or history part of the cube header.
;    Just a wrapper for pp_getcubeheadervalue. See its documentation for details.
;    
; :Params:
;    key : in
;      Key name to be retrieved.
;
; :Keywords:
;    history : in, optional, default=0
;      If set, reading is done on the history part of the header, instead of the label part.
;    count : out, optional
;      Passed to pp_getcubeheadervalue.
;      The number of occurences of the key found in the header. If more than 1
;      is found, the last occurence is used. Check this value to determine if
;      the key was not found (count will be 0 in that case).
;    fold_case : in, optional
;      Passed to pp_getcubeheadervalue.
;      Passed to stregex when searching for the key. If set, capitalization of
;      the key is ignored.
;    lines : out, optional
;      Passed to pp_getcubeheadervalue.
;      The line index (starting at zero) of the line in the header that provided
;      the retrieved value. If valued spanned more than one line, this is a vector
;      with the indexes of all such lines. If key not found, -1 is returned.
;    unquote : in, optional
;      Passed to pp_getcubeheadervalue.
;      If set, enclosing quotes are removed from the return values
;    sel : in, optional
;      Passed to pp_getcubeheadervalue.
;      In case more than one ocurrence of a keyword is found, sel gives the
;      index of the ocurrence to use (starts at 0). If not set, the last ocurrence
;      is the one used.

;
; :Examples:
;    See the examples on pp_readcube__define and pp_getcubeheadervalue.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
function pp_readcube::getfromheader,key,history=hist,$
 count=count,fold_case=fold_case,lines=lines,unquote=unquote,sel=sel,cont=cont
compile_opt idl2

;Defaults
hist=n_elements(hist) eq 1 ? hist : 0
tmp=hist ? *self.thistory : *self.tlabels
ret=pp_getcubeheadervalue(tmp,key,count=count,fold_case=fold_case,lines=lines,unquote=unquote,sel=sel,cont=cont)
return,ret
end

;+
; :Description:
;    Simple overloading to retrieve core bands, backplanes, or wavelenghts from the cube.
;    
;    Only 1D is processed. If more than 1D is specified, !null is returned.
;
; :Returns:
; 
;    The returned value depends on the type of the index provided:
;
;    If the index is an integer type (including a range), a 2D or 3D array is returned,
;    with the corresponding core band(s).
;    
;    If the index is of string type, then a 2D or 3D array with the corresponsing
;    backplane(s) is returned.
;    
;    If the index is of type double, a 2D or 3D array is returned with the core bands
;    that have wavelength(s) closest to the wavelength(s) given by the subscript.
;    
;    If the index is of type float, a 1D array is returned with the core wavelengths
;    that are nearest to the correspoinding given wavelength(s).
;    
; :Examples:
;    See the example on pp_readcube__define.
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Feb/2011
;-
function pp_readcube::_overloadBracketsRightSide, isRange, sub1, $
   sub2, sub3, sub4, sub5, sub6, sub7, sub8
compile_opt idl2,logical_predicate

if (n_elements(isrange) ne 1) then return,!null
if (isrange[0]) then begin
  core=self.getproperty(/core)
  ret=core[*,*,sub1[0]:sub1[1]:sub1[2]]
  return,ret
endif
case 1 of
  isa(sub1,'string') : ret=self.getsuffixbyname(sub1)
  isa(sub1,'double') : ret=self.getbandbywavelength(sub1)
  isa(sub1,'float') : !null=self.getbandbywavelength(sub1,wavelengths=ret)
  isa(sub1,'int') || isa(sub1,'uint') || isa(sub1,'long') || isa(sub1,'ulong') || $
   isa(sub1,'long64') || isa(sub1,'ulong64') : ret=self.getbandbyindex(sub1)  
  else: ret=!null
endcase
return,ret
end

;+
; 
; :Description:
;    Object to read an ISIS cube.
;    
;    Initialization parses the cube into the object, other methods retrieve parts of it.
;    
;    Assumes that all suffix items are the same data type as core items.
;    
;    Assumes that cube has 3 axes in BSQ order.
;    
;    Assumes constant length records.
;    
;    The only methods intended to be public are getproperty,getspecialvalues, getfromheader,
;    getsuffixbyname, and getbandbywavelength.
;    
; :Examples:
;    
;    To read the cube CM_1553510065_1_ir.cub::
; 
;      a=obj_new('pp_readcube','CM_1553510065_1_ir.cub')
;    
;    To get the core and its wavelengths::
;    
;      a->getproperty,core=core,wavelengths=wavs
;      print,min(wavs,max=mw),mw
;      ;0.88421000       5.1225000
;      
;    To get the backplanes and their names::
;    
;      a->getproperty,backplanes=back,backnames=bnames
;      print,bnames
;      ;LATITUDE LONGITUDE SAMPLE_RESOLUTION LINE_RESOLUTION PHASE_ANGLE INCIDENCE_ANGLE EMISSION_ANGLE NORTH_AZIMUTH
;      
;    To get the file name::
;    
;      print,a->getproperty(/file)
;      ;CM_1553510065_1_ir.cub
;      
;    To get all the properties at once::
;    
;     a->getproperty,all=a_all
;     ;** Structure PP_READCUBE_ALL, 24 tags, length=98912, data length=98895:
;     ;   FILE            STRING    'CM_1553510065_1_ir.cub'
;     ;   SPECIAL         BYTE         0
;     ;   LABELS          STRING    Array[268]
;     ;   HISTORY         STRING    Array[479]
;     ;   CORE            FLOAT     Array[1, 40, 256]
;     ;   BACKPLANES      FLOAT     Array[1, 40, 8]
;     ;   SIDEPLANES      POINTER   <NullPointer>
;     ;   BOTTOMPLANES    POINTER   <NullPointer>
;     ;   INFO            STRUCT    -> PP_READCUBE_INFO Array[1]
;     ;   LINES           LONG                40
;     ;   SAMPLES         LONG                 1
;     ;   BANDS           LONG               256
;     ;   NBACK           LONG                 8
;     ;   NSIDE           LONG                 0
;     ;   NBOTTOM         LONG                 0
;     ;   RAW             FLOAT     Array[1, 40, 264]
;     ;   WAVELENGTHS     DOUBLE    Array[256]
;     ;   BACKNAMES       STRING    Array[8]
;     ;   SIDENAMES       POINTER   <NullPointer>
;     ;   BOTTOMNAMES     POINTER   <NullPointer>
;     ;   UNITS           STRING    'MICROMETER'
;     ;   BACKUNITS       STRING    Array[8]
;     ;   SIDEUNITS       POINTER   <NullPointer>
;     ;   BOTTOMUNITS     POINTER   <NullPointer>
;     
;    To get the latitudes::
;    
;      lats=a->getsuffixbyname('LATITUDE')
;      
;    Or, equivalenty::
;    
;      lats=a['LATITUDE']
;      
;    To get the band with wavelength nearest to 2.1 (in the units used in the cube)::
;    
;      selband=a->getbandbywavelength(2.1,wavelengths=selwavs)      
;      print,selwavs
;      ;2.1003400
;      
;    Or, equivalently::
;    
;      selband=a[2.1d0]
;      selwavs=a[2.1]
;      print,selwavs
;      ;2.1003400
;      
;    To get the start time of the cube::
;    
;      print,a->getfromheader('START_TIME')
;      ;"2007-084T10:00:57.286Z"
;
;    Destroy the object when done with it::
;    
;      obj_destroy,a
;    
; :Uses: pp_getcubeheadervalue, pp_extractfields
;
; :Author: Paulo Penteado (pp.penteado@gmail.com), Oct/2009
;-
pro pp_readcube__define
compile_opt idl2
void={pp_readcube,$
 file:'',$ ;file name
 special:0B,$ ;Type of special value replacement: 0 for default values, 1 for header values, 2 for no replacement
 labels:ptr_new(),tlabels:ptr_new(),$ ;label part of the header and its trimmed version (string arrays)
 history:ptr_new(),thistory:ptr_new(),$ ;history part of the header and its trimmed version (string arrays)
 raw:ptr_new(),$ ;raw data (array of whatever type used) part
 info:{pp_readcube_info,datatype:0,littleendian:1B,$ ;type code and endianness of the data (assumed same in core and suffix)
 recordbytes:0L,filerecords:0L,labelrecords:0L,historyrecords:0L,binaryrecords:0L,$ ;record length (bytes) and number of records
 historystart:0L,binarystart:0L,$ ;record where the history and binary parts begin 
 bytes:0B,type:'',$ ;number of bytes per element, and ISIS type identifier
 dims:lonarr(3),coredims:lonarr(3),suffdims:lonarr(3)},$ ;dimensions of entire cube, and of core and suffix parts  
 core:ptr_new(),backplanes:ptr_new(),sideplanes:ptr_new(),bottomplanes:ptr_new(),$ ;sections of data part
 wavs:ptr_new(),units:'UNKNOWN',$ ;wavelength and units of each core band
 bnames:ptr_new(),snames:ptr_new(),bonames:ptr_new(),$ ;name of each backplane, sideplane and bottomplane
 bunits:ptr_new(),sunits:ptr_new(),bounits:ptr_new(),$ ;units of each backplane, sideplane and bottomplane
 dwavs:ptr_new(),idwavs:ptr_new(),$ ;wavelengths as doubles and their sort indexes
 inherits IDL_Object}
return
end
