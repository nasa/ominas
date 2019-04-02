; docformat = 'rst'
;=======================================================================
;+
; CIRS EXAMPLE
; ------------
;
;   This script demonstrates reading Cassini CIRS cubes and combining them with
;   Cassini ISS images, using observations of Mimas.
;
;   The data files are provided in the `demo/data directory`.
;
;   Setup: The instrument detectors, translators and transforms must contain the
;   CIRS and ISS definitions, as is included in `demo/data/instrument_detectors.tab`,
;   `demo/data/translators.tab`, and `demo/data/transforms.tab`.
;
;   This example requires SPICE/Icy to have been setup. It can be run by doing::
;
;     .run cas_cirs_example
;
;   from within an OMINAS IDL session.
;
;-
;=======================================================================



compile_opt idl2,logical_predicate



dd=dat_read(getenv('OMINAS_DIR')+'/demo/data/126MI_FP3DAYMAP001_CI004_601_F3_039E.LBL')
header=dat_header(dd)
items=pdspar(header,'CORE_ITEMS')
items=fix(strsplit(items,'(,)',/extract))
names=pdspar(header,'AXIS_NAME')
names=strupcase(strtrim(strsplit(names,'(,) ',/extract),2))
wl=where(names eq 'LINE')
ws=where(names eq 'SAMPLE')
wb=where(names eq 'BAND')
lines=items[wl]
samples=items[ws]
bands=items[wb]
origin=[lines,samples]/2d0


fsc=double(pdspar(header,'CSS:FIRST_SAMPLE_CENTER')); = 225
flc=double(pdspar(header,'CSS:FIRST_LINE_CENTER')); = 17
lsc=double(pdspar(header,'CSS:LAST_SAMPLE_CENTER')); = 117
llc=double(pdspar(header,'CSS:LAST_LINE_CENTER')); = -75

center=[mean([flc,llc]),mean([fsc,lsc])]
units=[180d0,360d0]/[-(flc-llc),-(fsc-lsc)]

mdr=map_create_descriptors(name='CAS_CIRS',$
  projection='RECTANGULAR', $
  size=[lines,samples], $
  origin=origin, $
  ;pole=pole,$
  center=center*!dpi/180d0,$
  units=units,$
  gd=dd)
  
  dat_set_data,dd[0],total((dat_data(dd[0])).core,3)

  map_xsize = 1000
  map_ysize = 1000

  mdp= pg_get_maps(/over,  $
    name='MIMAS',$
    projection='ORTHOGRAPHIC', $
    size=[map_xsize,map_ysize], $
    origin=[map_xsize,map_ysize]/2, $
    center=[0d0,0.8d0*!dpi])

  dd_map=pg_map(dd,md=mdp,cd=mdr,pc_xsize=500,pc_ysize=500)

end
