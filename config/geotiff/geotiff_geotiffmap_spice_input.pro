;==============================================================================
; geotiffmap_spice_maps
;
;==============================================================================
function geotiffmap_spice_maps, dd, status=status

status = 0
compile_opt idl2,logical_predicate

dh=dat_header(dd)


mst=pp_mstfromgeotiff(dims=dh.info.dimensions,geo=dh.geo)
dim=dat_dim(dd)



void={ominas_map}





loc=mst.image_location/[mst.semimajor_axis,mst.semiminor_axis]
range=mst.image_dimensions/[mst.semimajor_axis,mst.semiminor_axis]
units=[1d0,1d0]
mrange=[[loc[0],loc[0]+range[0]],[loc[1],loc[1]+range[1]]]
loc+=range/2d0
units=[1d0,1d0]
center=loc
origin=dim/2d0
  
ret=map_create_descriptors(name=dat_instrument(dd),$
    projection='RECTANGULAR',size=dim,$
    origin=origin,center=center,units=units,range=mrange,gd=dd)
    
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
;==============================================================================






;===========================================================================
; geotiff_geotiffmap_spice_input.pro
;
;
;===========================================================================
function geotiff_geotiffmap_spice_input, dd, keyword, values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords

 if(keyword EQ 'MAP_DESCRIPTORS') then return, geotiffmap_spice_maps(dd, status=status)

 return, spice_input(dd, keyword, 'geotiff', 'geotiffmap', values=values, status=status, $
@dat_trs_keywords_include.pro
@dat_trs_keywords1_include.pro
	end_keywords)

end
;===========================================================================


