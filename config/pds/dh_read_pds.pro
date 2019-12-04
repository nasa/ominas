;=============================================================================
; dh_read_pds.pro
;
;=============================================================================
function dh_read_pds, dd, label, dim, type, min, max, abscissa=abscissa, $
                          nodata=nodata, gff=gff, $
                          sample=sample, returned_samples=returned_samples

 if(keyword_set(sample)) then return, 0
 filename = dat_filename(dd)

 ;--------------------------------------------------------
 ; read label
 ;--------------------------------------------------------
 label = headpds(filename, /silent)

 ;- - - - - - - - - - - - - - - - - - - - -
 ; get rid of CR/LFs included by headpds
 ;- - - - - - - - - - - - - - - - - - - - -
 label = strtrim(str_nnsplit(label, string(13b)), 2)

 ;- - - - - - - - - - - - - - - - - - - - -
 ; determine image dimensions
 ;- - - - - - - - - - - - - - - - - - - - -
 names = pdspar(label, 'OBJECT')


 wi=where(strmatch(names,'*IMAGE',/fold_case),/null)
 wq=where(strmatch(names,'*QUBE',/fold_case),/null)
 wt=where(strmatch(names,'*TABLE',/fold_case),/null)
 
 dat=!null
 case 1 of
  n_elements(wi) gt 0 : begin
    
   w=wi[0]
   s = pdspar(label, 'LINE_SAMPLES')
   xsize = long(s[w])

   s = pdspar(label, 'LINES')
   ysize = long(s[w])

   dim = [xsize, ysize]
  end
  n_elements(wq) gt 0 : begin

     s=strsplit(pdspar(label,'CORE_ITEMS'),'() ,',/extract)
;     xsize=long(s[2])
;     ysize=long(s[1])
;     dim = [xsize, ysize]
     zsize=long(s[2])
     xsize=long(s[0])
     ysize=long(s[1])
     dim = [xsize, ysize, zsize]
  end
  n_elements(wt) gt 0: begin
     dat = readpds(filename, /silent)
     dim=[n_elements(dat.table.column1)]
  end 
 endcase

;;; type = pdspar(label, 'SAMPLE_TYPE')
;;; need to convert this to IDL type code
;;; see imagepds.pro
min=0
max=0

 if(keyword_set(nodata)) then return, 0


 ;--------------------------------------------------------
 ; read image
 ;--------------------------------------------------------
 if n_elements(dat) eq 0 then dat = readpds(filename, /silent)

 wi=where(strmatch(tag_names(dat),'*IMAGE',/fold_case),/null)
 wq=where(strmatch(tag_names(dat),'*QUBE',/fold_case),/null)
 wt=where(strmatch(tag_names(dat),'*TABLE',/fold_case),/null)
 case 1 of
  n_elements(wi) gt 0 : image=dat.(wi[0])
  n_elements(wq) gt 0 : image=fix(dat_keyword_value(dd,'struct')) ? dat.(wq[0]) : (dat.(wq[0])).core 
  n_elements(wt) gt 0 : begin
    image={}
    foreach name,dat.(wt[0]).names,iname do image=create_struct(image,name,(dat.(wt[0]).(iname+1))[0])
    image=replicate(image,n_elements(dat.(wt[0]).column1))
    foreach name,dat.(wt[0]).names,iname do image.(iname)=dat.(wt[0]).(iname+1)
  end
 endcase
 type = size(image, /type)
 if(type EQ 8) && (n_elements(wi) gt 0) then image = image.image
 type = size(image, /type)

 return, image














 dat = readpds(filename, label, /silent, dim=dim, nodata=nodata)
 n = dat.objects


 if(n EQ 1) then $
  begin
   return, dat.image
  end

stop

 data = ptrarr(n)
 dim_p = ptrarr(n)

 for i=0, n-1 do $
  begin
;   data[i] = nv_ptr_new(...)
;   dim_p[i] = nv_ptr_new(...)
  end

 return, data
end
;=============================================================================
