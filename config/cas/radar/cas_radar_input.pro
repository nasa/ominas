
function cas_radar_planets,dd
compile_opt idl2,logical_predicate

  dat_header_value,dd,'TARGET_NAME',get=target
  dat_header_value,dd,'START_TIME',get=startt
  dat_header_value,dd,'END_TIME',get=endt
  target=strtrim(target[0],2)
  startt=strtrim(startt[0],2)
  endt=strtrim(endt[0],2)
  
  
  
  ret=eph_spice_planets(dd, ref, time=plt_time, planets=planets, $
    n_obj=n_obj, dim=dim, status=status, $
    targ_list=targ_list, $
    target=target, constants=constants, obs=obs)

  return,ret

end

function cas_radar_lonlattolinesample,lon,lat,line_offset=line_off,sample_offset=sample_off,$
  mapres=mapres
compile_opt idl2,logical_predicate
line=line_off+lon*mapres+1
sample=sample_off+lat*mapres+1
return,transpose([[line],[sample]])
end

function cas_radar_linesampletolonlat,line,sample,line_offset=line_off,sample_offset=sample_off,$
  mapres=mapres
compile_opt idl2,logical_predicate
lon=(line-1-line_off)/(mapres*1d0)
lat=(sample-1-sample_off)/(mapres*1d0)
return,transpose([[lon],[lat]])
end

function cas_radar_maps,dd
compile_opt idl2,logical_predicate

dat_header_value,dd,'LINES',get=lines
dat_header_value,dd,'SAMPLES',get=samples
dat_header_value,dd,'LINE_PROJECTION_OFFSET',get=line_proj_off
dat_header_value,dd,'SAMPLE_PROJECTION_OFFSET',get=sample_proj_off
dat_header_value,dd,'MAP_RESOLUTION',get=map_res
dat_header_value,dd,'OBLIQUE_PROJ_POLE_LATITUDE',get=pole_lat
dat_header_value,dd,'OBLIQUE_PROJ_POLE_LONGITUDE',get=pole_lon
dat_header_value,dd,'OBLIQUE_PROJ_POLE_ROTATION',get=pole_rot



lines=long(lines[0])
samples=long(samples[0])
line_proj_off=double(line_proj_off[0])
sample_proj_off=double(sample_proj_off[0])
map_res=double(map_res[0])
void={ominas_map}
pole={ominas_map_pole}

pole.lat=double(pole_lat[0])*!dpi/180d0
pole.lon=double(pole_lon[0])*!dpi/180d0
pole.rot=double(pole_rot[0])*!dpi/180d0



center=cas_radar_linesampletolonlat(lines/2d0,samples/2d0,line_off=line_proj_off,$
  sample_off=sample_proj_off,mapres=map_res)
lonlat0=cas_radar_linesampletolonlat(0d0,0d0,line_off=line_proj_off,$
    sample_off=sample_proj_off,mapres=map_res)
lonlat1=cas_radar_linesampletolonlat(lines,samples,line_off=line_proj_off,$
    sample_off=sample_proj_off,mapres=map_res)
range=[lines/map_res,samples/map_res]*!dpi/180d0
units=[360d0,180d0]/([lines,samples]/map_res)
origin=[lines,samples]/2d0
center=reverse(center)
units=reverse(units)
  
ret=map_create_descriptors(name='CAS_RADAR',$
    type='RECTANGULAR', $
    size=[lines,samples], $
    origin=origin, $
    pole=pole,$
    center=center*!dpi/180d0,$
    units=units,$
    gd=dd)
    
 ;ddd=dat_data(dd)
 ;dddr=congrid(ddd,lines/10,samples/10)
 ;szd=size(dddr,/dim)
 ;mps=map_res/10
 ;lonlat=cas_radar_linesampletolonlat(0,0,line_off=line_proj_off,sample_off=sample_proj_off,mapres=map_res)
 ;im=image(0>dddr<2.8,grid_units=2,map_projection='orthographic',image_dimensions=szd/mps,image_location=lonlat,limit=[-90d0,-180d0,90d0,180d0],margin=0.2)
 ;im=image(0>dddr<2.8,grid_units=2,map_projection='equirectangular',image_dimensions=szd/mps,image_location=lonlat,limit=[-90d0,-180d0,90d0,180d0],margin=0.2)
 ;mg=mapgrid(grid_lon=15,grid_lat=15)   
status=0
  
return,ret
  
end


function cas_radar_input, dd, keyword, n_obj=n_obj, dim=dim, values=values, $
status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

  funs=hash()
  funs['PLT_DESCRIPTORS']='cas_radar_planets'
  funs['MAP_DESCRIPTORS']='cas_radar_maps'
 

  ret=call_function(funs[keyword],dd);,n_obj=n_obj, dim=dim, values=values, status=status, $
	  ;@nv_trs_keywords_include.pro
	;@nv_trs_keywords1_include.pro
	;end_keywords)


 status=0
 n_obj=n_elements(dd)
 dim=[n_obj]
 values=0
 return, ret

end
;===========================================================================


