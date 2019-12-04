;docformat = 'rst rst'
;+
; :Author: Paulo Penteado (`http://www.ppenteado.net`)
;-
;+
; :Description:
;    Given the GeoTIFF structure from a file (see IDL's read_tiff), returns
;    a map structure setting up the same map projection, to be used with IDL's
;    map routines and procedures (see the help on IDL's map_proj_init,
;    `https://www.harrisgeospatial.com/docs/map_proj_init.html`)
;
; :Keywords:
;    file: in, optional
;      String with the name of a GeoTIFF file to be read.
;    dims: in, optional
;      An array with the dimensions of the GeoTIFF image. 
;    geo: in, optional
;      The GeoTIFF structure from the file, as returned by read_tiff().
;    mst: in, optional
;      A map structure to be used for output. If not provided, one is created
;      with the fields populated from the GeoTIFF's values. If provided, only
;      those fields are changed in the ouput structure. The main application for
;      this variable is to be able to use this function to set the values in a subset
;      of the fields of a structure that holds other data.  
;    
; :Todo: Add support for projections other than Equirectangular and Stereographic. This was made
;   to be a general routine, but I only had use for Equirectangular and Stereographic at the time. 
;   Add support for units other than degrees.
;
; :Author: Paulo Penteado (`http://www.ppenteado.net`)
;-
function pp_mstfromgeotiff,file=file,dims=dims,geo=geo,mst=mst
compile_opt idl2,logical_predicate

if n_elements(geo) eq 0 then begin
  q=query_tiff(file,geotiff=geo,info)
  dims=info.dimensions
endif

;dims=(n_elements(tiff) eq 2) ? tiff : size(tiff,/dimensions)

mst=n_elements(mst) ? mst : {map_projection:'Equirectangular',grid_units:1,$
  image_location:[-180d0,-90d0],image_dimensions:[360d0,180d0]-1d-12,$
  semimajor_axis:180d0/!dpi,semiminor_axis:180d0/!dpi,$
  limit:[-90d0,-180d0,90d0,180d0],$
  center_latitude:0d0,center_longitude:0d0,height:1d0}
  

case 1 of
  ((geo.gtmodeltypegeokey eq 2 ) && (geo.gtrastertypegeokey eq 2)) : begin
    tpt=geo.modeltiepointtag
    mps=geo.modelpixelscaletag
    
    mst.image_dimensions=(dims*[mps[0:1]])<[360d0-1d-12,180d0-1d-12]
    minlon=tpt[3]-tpt[0]*mps[0]
    maxlat=tpt[4]+tpt[1]*mps[1]
    

    maxlon=dims[0]*mps[0]+minlon
    minlat=maxlat-(dims[1]*mps[1])
    mst.map_projection='Equirectangular'
    mst.grid_units=1
    sfac=[mst.semimajor_axis,mst.semiminor_axis]*[2d0,1d0]*!dpi/[360d0,180d0]
    mst.image_location=([minlon,minlat])
    ;mst.image_dimensions=[maxlon-minlon,maxlat-minlat]<[360d0-1d-12,180d0-1d-12]
    mst.center_longitude=0d0
    mst.center_latitude=0d0
  end
  ((geo.gtmodeltypegeokey eq 1) && (geo.gtrastertypegeokey eq 1) && (geo.projcoordtransgeokey eq 17)) : begin
    tpt=geo.modeltiepointtag
    mps=geo.modelpixelscaletag

    mst.image_dimensions=(dims*[mps[0:1]])
    minlon=tpt[3]-tpt[0]*mps[0]
    maxlat=tpt[4]+tpt[1]*mps[1]


    maxlon=dims[0]*mps[0]+minlon
    minlat=maxlat-(dims[1]*mps[1])
    mst.map_projection='Equirectangular'
    mst.grid_units=1
    mst.semimajor_axis=geo.geogsemimajoraxisgeokey
    mst.semiminor_axis=geo.geogsemiminoraxisgeokey
    mst.image_location=([minlon,minlat])

    mst.center_longitude=geo.projcenterlonggeokey
    mst.center_latitude=geo.projcenterlatgeokey
    
  end
  (geo.PROJCOORDTRANSGEOKEY eq 15 ): begin ;stereographic
     tpt=geo.modeltiepointtag
     mps=geo.modelpixelscaletag
     
     mst.image_dimensions=(dims*[mps[0:1]])
     mst.image_location=[tpt[3],-tpt[4]]
     
     mst.map_projection='Stereographic'
     mst.grid_units=1
     
     mst.semimajor_axis=geo.GEOGSEMIMAJORAXISGEOKEY
     mst.semiminor_axis=geo.GEOGSEMIMINORAXISGEOKEY
     
     mst.center_longitude=(geo.PROJSTRAIGHTVERTPOLELONGGEOKEY) mod 360
     mst.center_latitude=geo.PROJNATORIGINLATGEOKEY
     
     mst.limit=mst.center_latitude gt 0 ? [0d0,-180d0,90d0,180d0] : [-90d0,-180d0,0d0,180d0]
     
   end
  else: begin
    message,'This projection type is not yet implemented'
  end
endcase


return,mst
end
