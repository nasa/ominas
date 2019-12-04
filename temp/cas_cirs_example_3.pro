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


;-------------------------------------------------------------------------
;+
; Read CIRS files
; ---------------
;
;-
;-------------------------------------------------------------------------
;

dd=dat_read('ISPM10021300.LBL')
ddn=cirs_separate_spectra(dd,/byreq,keys=keys)
wk=where(stregex(keys,'.*_.*_126MI_FP.*DAYMAP001_PRIME',/boolean))
foreach wwk,wk,iwk do print,wwk,dat_dim(ddn[wwk]),keys[wwk]

bytimes=hash()
foreach wwk,wk,iwk do begin

  ddnu=ddn[wwk]
  ns=(dat_dim(ddnu))[0]
  pd=objarr(ns)
  cd=pg_get_cameras(ddnu,/tr_nosort)
  for i=0,ns-1 do begin & print,i & pd[i]=pg_get_planets(ddnu,od=cd[i],name='MIMAS') & endfor
  
  map_xsize = 400
  map_ysize = 200
  md = pg_get_maps(/over, gbx = pd1, name='MIMAS',projection='RECTANGULAR',$
    fn_data=ptr_new(),size=[map_xsize,map_ysize],origin=[map_xsize,map_ysize]/2)
  
  sd=pg_get_stars(ddnu,od=cd,name='SUN')
  gd={cd:cd,gbx:pd,dkx:obj_new(),ltd:sd}
  
  
  
  
  sub=1
  fov=cirs_fov('fp3',sub=sub,nbx=1,nby=1)
  g=list()
  lons=list()
  lats=list()
  flux=list()
  da=dat_data(ddnu)
  da=median(da,dim=2)
  if sub then begin
    nfovs=size(fov,/dimensions)
    fov=reform(fov,2,nfovs[1]*nfovs[2])
  endif
  for i=ns-1,0,-1 do begin
    ll=(180d0/!dpi)*globe_to_map(md,pd[i],image_to_globe(cd[i],pd[i],fov,body_pts=bp))
    if sub && (n_elements(ll) gt 1) then ll=reform(ll,2,nfovs[1],nfovs[2])
    if n_elements(ll) gt 1 then g.add,ll
    if sub then begin
      w=where(finite(total(total(ll,1),2)),c)
      if (n_elements(ll) gt 1) && c then begin
        foreach ww,w,iw do begin
          lons.add,reform(ll[1,ww,*])
          lats.add,reform(ll[0,ww,*])
          flux.add,da[i]
        endforeach
      endif
    endif else begin
      w=where(finite(total(ll,1)),c)
      if (n_elements(ll) gt 1) && c then begin
        lons.add,reform(ll[1,w])
        lats.add,reform(ll[0,w])
        flux.add,da[i]
      endif
    endelse
  
  endfor
  
  if n_elements(flux) then begin
  fl=flux.toarray()
   m=image(grid_units=2,map_projection='equirectangular',dist(360,180),image_location=[-180,-90],center_lon=180,$
    title=keys[wwk]+' '+strtrim(wwk,2)+' /'+strtrim(iwk,2))
   www=where(fl lt 1d-8)
   pp_drawsphericalpoly,lons[www],lats[www],fl[www],rgb_table=13,linestyle='none'
   m.save,'cirs_example_test4_'+string(iwk,format='(I03)')+'.png',res=100
   m.close
   scet=(dat_header(ddnu)).table[0].scet
   if ~bytimes.haskey(scet) then begin
     bytimes[scet]={lons:list(),lats:list(),fl:list()}
   endif
   (bytimes[scet].lons).add,lons[www],/extract
   (bytimes[scet].lats).add,lats[www],/extract
   (bytimes[scet].fl).add,fl[www],/extract
   
   endif
endforeach
for i=0,n_elements(g)-1 do iplot,reform(g[i,0,*]),reform(g[i,1,*]),over=(i ne 0)

dat_set_data,ddnu,total(da,1)



;dd_map=pg_map(ddnu, md=md, gd=gd, aux=['EMM'],pc_xsize=map_xsize,pc_ysize=map_ysize) 


end
