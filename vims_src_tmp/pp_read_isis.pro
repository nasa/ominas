;=============================================================================
; pp_read_isis.pro
;
;=============================================================================
function pp_read_isis, filename, label, udata, dim, type, _min, _max,$
                          silent=silent, sample=sample, nodata=nodata, gff=gff,$
                          abscissa=abscissa,returned_samples=returned_samples
 ;tag_list_set, udata, 'DETACHED_HEADER', $
 ;              dh_read(dh_fname(filename), silent=silent)

 ;data = read_vicar(filename, label, silent=silent, nodata=nodata, $
 ;                                    get_nl=nl, get_ns=ns, get_nb=nb, type=type)
 cube=pp_readcube(filename)
 data=keyword_set(nodata) ? 0 : cube.core
 label=strjoin(cube.label,string(10B))+string(10B)+strjoin(cube.history,string(10B))
 ns=cube.samples
 nl=cube.lines
 nb=cube.bands
 type=size(cube.core,/type)
 dim = degen_array([ns, nl, nb])
 _min=min(data,max=_max)

 return, data
end
;=============================================================================
