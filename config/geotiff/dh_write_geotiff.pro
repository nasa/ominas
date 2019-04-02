;=============================================================================
; dh_write_geotiff.pro
;
;=============================================================================
function dh_write_geotiff, dd, filename, data, header, abscissa=abscissa, nodata=nodata

 if(keyword_set(nodata)) then return, -1

 if(NOT keyword_set(filename)) then filename = dat_filename(dd)
 if(NOT keyword_set(label)) then label = dat_header(dd)
 if(NOT keyword_set(data)) then data = dat_data(dd, abscissa=_abscissa)
 if(NOT keyword_set(abscissa)) then abscissa = _abscissa

 dt=dat_typecode(dd)
 md=cor_udata(dd,'md')
 if size(md, /type) ne 11 then md=!null else md=md[0]
 
 case 1 of
   dat_instrument(dd) eq 'GEOTIFF_MAP': begin
     name=label.planet
     geo=label.geo
   end
   isa(md,'ominas_map'): begin
     name=cor_name(md)
     tpt=dblarr(6)
     ps=dblarr(2)
     case map_projection(md) of
       'RECTANGULAR': begin
         tpt[0:1]=map_origin(md)
         tpt[3:4]=map_center(md)
         dims=dat_dim(dd)
         dr=map_image_to_map(md,[[0d0,0d0],[dims]])
         ps[1]=((dr[0,1]-dr[0,0])*180d0/!dpi)/dims[1]
         ps[0]=((dr[1,1]-dr[1,0])*180d0/!dpi)/dims[0]
         geo={$
           GTMODELTYPEGEOKEY:2,$ ;1 Projection Coordinate System, 2 Geographic latitude-longitude System, 36767 User-defined
           GTRASTERTYPEGEOKEY:1,$ ;RasterPixelIsArea  = 1, RasterPixelIsPoint = 2
           GEOGANGULARUNITSGEOKEY:9102 ,$ ;Angular_Degree =  9102
           PROJLINEARUNITSGEOKEY: 9001,$ ;Linear_Meter = 9001
           PCSCITATIONGEOKEY:'Made with OMINAS (https://github.com/nasa/ominas',$
           MODELTIEPOINTTAG:tpt[0:5],$
           MODELPIXELSCALETAG:[ps[0],ps[1],0d0]}
       end
       else: begin
        ;To be implemented
       end
     endcase
   end
   else: begin
     name=cor_name(dd)
     geo=!null
   end
 endcase
 
 write_tiff,filename,reverse(data,2),geotiff=geo,compression=2,document_name=name,$
  description='Created by OMINAS (https://github.com/nasa/ominas)',$
  complex=(dt eq 6),dcomplex=(dt eq 9),double=(dt eq 5),l64=((dt eq 14)||(dt eq 15)),$
  long=((dt eq 3)||(dt eq 13)),short=((dt eq 2)||(dt eq 12)),float=(dt eq 4),$
  signed=((dt eq 2)||(dt eq 3)||(dt eq 14)),orientation=1

 return, 0
end
;=============================================================================
