function pp_w10n::init,file,_ref_extra=ex
compile_opt idl2,logical_predicate
print,'pp_w10n: Reading GeoTIFF file'
tiff=read_tiff(file,geotiff=geo,orientation=ori)
case ori of
  1:dir=7
  2:dir=2
  3:dir=5
  4:dir=0
  5:dir=1
  6:dir=6
  7:dir=3
  8:dir=4
  else:dir=0
endcase
tiff=rotate(tiff,dir)
print,'pp_w10n: Building index hash'
loc=pp_locate(tiff)
inv=tiff[0]
inv[0]=-1
self.inv=ptr_new(inv)
self.locinv=ptr_new(loc[inv])
loc.remove,inv
self.loc=loc
self.tiff=ptr_new(tiff,/no_copy)
self.owd=pp_w10ndata(geo.gtcitationgeokey,_strict_extra=ex)
self.geotiff=ptr_new(geo,/no_copy)
self.cache=hash()

return,1
end

pro pp_w10n::getproperty,_ref_extra=ex,variables=variables,geotiff=geotiff,$
  indeximage=indeximage,dimensions=dimensions,owd=owd
compile_opt idl2,logical_predicate
if arg_present(variables) then begin;variables=['TSurfAir','solzen','solazi','satzen',$
  ;'satazi','rain_rate_15km','rain_rate_50km','forecast','final_cloud_ret','Time',$
 ; 'T_Tropopause','SurfClass','PSurfStd','MODIS_LST','Latitude','Longitude']
 tmp=(self.owd.getvariables())['data']
 ds=(*self.geotiff).geogcitationgeokey
 ds=strtrim(strsplit(ds,',',/extract),2)
 variables=list()
 foreach t,tmp,tk do if array_equal(t.dimn,ds) then variables.add,tk
 variables=variables.toarray()
endif
if arg_present(geotiff) then geotiff=*(self.geotiff)
if arg_present(indeximage) then indeximage=*(self.tiff)
if arg_present(dimensions) then dimensions=size(*(self.tiff),/dimensions)
if arg_present(owd) then owd=self.owd
if n_elements(ex) then self.owd.getproperty,_strict_extra=ex

end



function pp_w10n::_overloadBracketsRightSide, isRange, sub1, $
  sub2, sub3, sub4, sub5, sub6, sub7, sub8
  compile_opt idl2,logical_predicate

  if isrange[0] || ~isa(sub1,'string') || (~strlen(strtrim(sub1,2))) then message,'First dimension must be a non-empty variable name'
  sl=strlen(strtrim(sub1,2))
  var=strpos(sub1,'/',/reverse_search) eq (sl-1) ? strmid(sub1,0,sl-1) : sub1

  ret=self.getvar(var)
  return,ret

end

function pp_w10n::getvar,var
compile_opt idl2,logical_predicate

if (self.cache).haskey(var) then return,(self.cache)[var]

ret=!null
vardata=self.owd[var]
if n_elements(vardata) then begin
  print,'pp_w10n: Building data array'
  ret=make_array(size(*self.tiff,/dimensions),type=size(vardata,/type))
  ret[*]=!values.d_nan
  foreach v,self.loc,k do ret[v]=vardata[k] 
endif

(self.cache)[var]=ret

return,ret
end

pro pp_w10n::clearcache
compile_opt idl2,logical_predicate
self.cache=hash()
end

pro pp_w10n__define
compile_opt idl2,logical_predicate
!null={pp_w10n,inherits IDL_Object,owd:obj_new(),tiff:ptr_new(),geotiff:ptr_new(),$
  cache:obj_new(),loc:obj_new(),inv:ptr_new(),locinv:ptr_new()}
end
