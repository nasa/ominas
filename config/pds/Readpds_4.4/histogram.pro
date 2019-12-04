; Notes: 1d & 2d mix for contour plots
; Let user decide contour levels

;------------------------------------------------------------------------------
;- Normal Functions -----------------------------------------------------------
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Removes a tag from a structure                      ;;;
;;; Pre-Condition : Must enter a valid structure and tag name           ;;;
;;; Post-Condition: Returns the structure without the supplied tag name ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function rm_tag, input, badtag
   all_tags = get_tags(input)                                     ; Get all the tags for the input structure
   top_tags = strarr(n_elements(all_tags))                        ; Findthe parent tag name (since all_tags may return badtag.XXX)

   for z=0,n_elements(all_tags)-1,1 do begin
      spltarr = strsplit(all_tags[z],'.',/extract)
      top_tags[z] = spltarr[0]
   endfor

   bad      = [strupcase(badtag),"."+strupcase(badtag)]           ; Store the possible bad tag structures

   tmpstr   = input                                               ; Create a temporary copy of the structure
   goodind  = where(top_tags NE bad[0] AND all_tags NE bad[1])    ; Find where the GOOD tags are
   newtags  = all_tags[goodind]                                   ; Save a list of all the good tags

   exstr = "output = create_struct("
   for a=0,n_elements(newtags)-1,1 do begin
      exstr = exstr + '"'+strmid(newtags[a],1)+'",tmpstr'+newtags[a]+','
   endfor
   exstr = strmid(exstr,0,strlen(exstr)-1)+")"

print,exstr

   void = EXECUTE(exstr)
   return,output
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Creates a 2D Array containing input to CONTOUR               ;;;
;;; Pre-Condition : A cache variable that contains the substructure "indices"    ;;;
;;;                 "indices" is a 2xN array with the (X,Y) coordinates of every ;;;
;;;                 selected item in the table. Used for testing if current tab  ;;;
;;;                 has selected values. This is a bit of a hold over from a     ;;;
;;;                 previous version.                                            ;;;
;;; Post-Condition: Returns a 2D Array with table values to go into CONTOUR.     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function makecon, cache, itr,shiftx,shifty
   indtab = "IND"+strtrim(string(itr),1)
   stat   = tag_exist(cache.indices,indtab)           ; Return Boolean value on whether cache.indices exists

   IF stat EQ 1 THEN BEGIN
      WIDGET_CONTROL, cache.tablelist[itr], GET_VALUE=value, /USE_TABLE_SELECT   ; Get table value for current coordinate
      
      indarr = WIDGET_INFO(cache.tablelist[itr], /TABLE_SELECT)

      xmin   = min(indarr[0,*])
      ymin   = min(indarr[1,*])
      xdim   = max(indarr[0,*])-min(indarr[0,*])+1    ; Find the X-Dimensions of contour array by taking span of selected indices
      ydim   = max(indarr[1,*])-min(indarr[1,*])+1    ; Find the Y-Dimensions of contour array by taking range of selected indices
      
      xdim   = xdim + shiftx
      ydim   = ydim + shifty

      output = fltarr(xdim,ydim)

      cache.conoff[*,itr] = [xmin,ymin]

      for a=0L,n_elements(indarr[0,*])-1,1 do begin
         ix = indarr[0,a] - xmin                      ; Shift the x index to fit within range of new table
         iy = indarr[1,a] - ymin                      ; Shift the y index to fit within range of new table

         output[ix+shiftx,iy+shifty] = value[a]
      endfor

      return,output
   ENDIF ELSE BEGIN
      return,-1
   ENDELSE
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Creates string array of axis values to display              ;;;
;;; Pre-Condition : Requires the cache variable. The user must submit a valid   ;;;
;;;                 binsize, and there must be a selection made in the table.   ;;;
;;; Post-Condition: Returns either a 1D String Array with Axis values if the    ;;;
;;;                 user has opted for a Histogram, or a 2D string array if the ;;;
;;;                 user opted for a contour plot.                              ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function xvals, cache
   IF cache.disptype EQ "histogram" THEN BEGIN                    ; If cache.disptype is set to histogram, create 1D string array of x values
      FOR i=0,n_elements(cache.tablelist)-1,1 DO BEGIN            ; Loop over all tables
         tabs   = get_tags(cache.indices)                         ; Store tabs with selected values
         tabitr = intarr(n_elements(tabs))                        ; Integer array that will store which tabs are in use so we only access corresponding tables
   
         for a=0,n_elements(tabs)-1,1 do begin
            tabitr[a] = int(strmid(tabs[a],4))                    ; Strip the number from a tab name to populate tabitr
         endfor
   
         goodtabs = where(i EQ tabitr)                            ; Test to see if the current table is in use

         IF goodtabs[0] NE -1 THEN BEGIN
            WIDGET_CONTROL, cache.tablelist[i], GET_VALUE=value, /USE_TABLE_SELECT   ; Get the currently selected table values and store to 'value'
         
            IF i EQ int(tabitr[0]) THEN BEGIN                  ; Need to initialize minm and maxm
               minm = min(value)
               maxm = max(value)
            ENDIF ELSE BEGIN
               IF min(value) LT minm THEN minm = min(value)    ; If the current value is less than the original minm, save it
               IF max(value) GT maxm THEN maxm = max(value)    ; If the current value is greater than the original maxm, save it
            ENDELSE
         ENDIF
      ENDFOR

      WIDGET_CONTROL, cache.binsize, GET_VALUE=bin             ; Get the current number of bins the user wants

      dx   = float(bin[0])
      nbin = int(((maxm-minm)/dx)+1)
      nbin = nbin[0]
      xvector = (nbin LT 5) ? strarr(5) : strarr(nbin)

     
      for i=0L,nbin-1,1 do begin
         xvector[i] = strtrim(string(minm+i*dx),1)
      endfor
   
      if nbin LT 5 then begin
         dbin = 5-nbin
         for a=0,dbin-1,1 do begin
            xvector[n_elements(xvector)-1-a] = ' '
         endfor
      endif

      return, xvector
   ENDIF ELSE BEGIN                                         ; If cache.disptype is not 'histogram' then it must be 'distribution'
      tags = get_tags(cache.indices)                        ; Store all tag names currently in cache.indices
      for k=0,n_elements(tags)-1,1 do begin
         exstr = 'tempind = cache.indices'+tags[k]
         void  = EXECUTE(exstr)                             ; Save the current tag in cache.indices to tempind
            
         IF k EQ 0 THEN indarr = tempind                    ; Initialize indarr from tempind
         IF k NE 0 THEN indarr = [[indarr],[tempind]]       ; Concatenate indarr with tempind
      endfor
      
      xvector = strarr(2,6)
      
      minx = min(indarr[0,*])
      maxx = max(indarr[0,*])
      miny = min(indarr[1,*])
      maxy = max(indarr[1,*])
      
      dx = (maxx-minx)/5.
      dy = (maxy-miny)/5.
      
      for a=0,5,1 do begin
         xvector[0,a] = strtrim(string(minx+a*dx),1)
         xvector[1,a] = strtrim(string(miny+a*dy),1)
      endfor
      return,xvector
   ENDELSE
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Finds the dimensions of an input array of up to two dimensions ;;;
;;; Pre-Condition : An array.                                                      ;;;
;;; Post-Condition: Returns a structure with the X-dimensions and Y-dimensions.    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function dimensions,iTable
   sz = size(iTable,/DIMENSIONS)
   sx = sz[0]
   sy = (n_elements(sz) EQ 1) ? 0 : sz[1]
   return,{sx:sx,sy:sy}
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Produces the vector containing the histogram output      ;;;
;;; Pre-Condition : Requires the cache variable to be passed as an argument. ;;;
;;; Post-Condition: Returns a vector with histogram values.                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function makehist, cache, itr
   WIDGET_CONTROL, cache.binsize, GET_VALUE=bin

   tabs   = get_tags(cache.indices)
   tabitr = intarr(n_elements(tabs))
   
   for a=0,n_elements(tabs)-1,1 do begin
      tabitr[a] = float(strmid(tabs[a],4))
   endfor
   
   goodtabs = where(itr EQ tabitr)

   IF goodtabs[0] NE -1 THEN BEGIN
      WIDGET_CONTROL, cache.tablelist[itr], GET_VALUE=value, /USE_TABLE_SELECT
   ENDIF ELSE BEGIN
      return,-1
   ENDELSE

   value = DOUBLE(value)

   if cache.histmins[0] EQ -999 then begin
      cache.histmins = [min(value)]
   endif else begin
      tmp   = [cache.histmins,min(value)]
      cache = rm_tag(cache,"histmins")
      cache = create_struct(cache,histmins,tmp)
   endelse

   return,histogram(value,BINSIZE=bin)
end


;- Environment Functions -----------------------------------------------------

function helpinfo, ev
   IF !VERSION.OS EQ 'linux' THEN spawn,'nice +19 nedit histreadme.txt'
   IF !VERSION.OS EQ 'MacOS' THEN spawn,'textedit histreadme.txt'
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Changes the display type variable in the cache.          ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager ;;;
;;; Post-Condition: Returns a modified cache structure by means of ev.TOP    ;;;
;;; NOTE          : Logically identical to disptype_hist, but is a seperate  ;;;
;;;                 function due to simplicity of widget use. UVALUE could   ;;;
;;;                 potentially allow for a merger of these two functions.   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function disptype_dist, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache
   
   cache.disptype = "distribution"

   WIDGET_CONTROL, ev.TOP, SET_UVALUE=cache
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Changes the display type variable in the cache.          ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager ;;;
;;; Post-Condition: Returns a modified cache structure by means of ev.TOP    ;;;
;;; NOTE          : Logically identical to disptype_hist, but is a seperate  ;;;
;;;                 function due to simplicity of widget use. UVALUE could   ;;;
;;;                 potentially allow for a merger of these two functions.   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function disptype_hist, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache

   cache.disptype = "histogram"

   WIDGET_CONTROL, ev.TOP, SET_UVALUE=cache
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Actually selects the table values passed by the users      ;;;
;;;                 clicks or manual selection. A user MUST call this function ;;;
;;;                 if they wish to create/change their values.                ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager   ;;;
;;; Post-Condition: Returns a modified cache structure by means of ev.TOP. It  ;;;
;;;                 also highlights the current selection in the table. This   ;;;
;;;                 is important, as other functions grab highlighted portions ;;;
;;;                 directly.                                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function highlight, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache                          ; Read in the cache
   WIDGET_CONTROL, cache.coord1, GET_VALUE=coord1                    ; Read in the (x0,y0) coordinates
   WIDGET_CONTROL, cache.coord2, GET_VALUE=coord2                    ; Read in the (x1,y1) coordinates

   itab = WIDGET_INFO(cache.Tab,/TAB_CURRENT)                        ; Determine the current tab
   
   WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=iTable

   IF coord1 EQ "(x0,y0): " AND coord2 EQ "(x1,y1): " THEN BEGIN     ; If the user chose to select from the table, save the selections
      ind = WIDGET_INFO(cache.tablelist[itab], /TABLE_SELECT)
   ENDIF ELSE IF coord1 NE "(x0,y0): " AND coord2 NE "(x1,y1): " THEN BEGIN
      ;;; Find the x0 and y0 coordinates
      cstr = strmid(coord1,10)
      carr = strsplit(cstr,',',/extract)
      yarr = strsplit(carr[1],')',/extract)
      x0   = int(carr[0])
      y0   = int(yarr[0])

      ;;; Find the x1 and y1 coordinates
      cstr = strmid(coord2,10)
      carr = strsplit(cstr,',',/extract)
      yarr = strsplit(carr[1],')',/extract)
      x1   = int(carr[0])
      y1   = int(yarr[0])

      xp   = [x0,x1]
      yp   = [y0,y1]
      ymin = min(yp,minind)
      ymax = max(yp,maxind)
      xmin = xp[minind]
      xmax = xp[maxind]
   
      dx   = (abs(x1-x0) GT 0) ? abs(x1-x0) : 1                      ; Find the x dimension of selection. If 1D vector, force to 1.
      dy   = (abs(y1-y0) GT 0) ? abs(y1-y0) : 1                      ; Find the y dimension of selection. If 1D vector, force to 1.
            
      slope = float((ymax-ymin))/float((xmax-xmin))
      
      if abs(slope) GE 1 then begin
         slope = (slope LT 0) ? ceil(slope) : floor(slope)
         dy    = abs(slope)*dx
         ind   = intarr(2,dy)

         for j=0,dy-1,1 do ind[1,j] = ymin+j

         pos = 0
         for k=0,dx-1,1 do begin
            for l=0,abs(slope)-1,1 do begin
               ind[0,pos] = (slope GT 0) ? xmin+k:xmin-k
               pos=pos+1
            endfor
         endfor
      endif else begin
         slope = (slope LT 0) ? ceil(1/slope) : floor(1/slope)
         dx    = abs(slope)*dy
         ind   = intarr(2,dx)
         
         if slope GT 0 then begin
            for j=0,dx-1,1 do ind[0,j] = xmin+j
         endif else begin
            for j=0,dx-1,1 do ind[0,j] = xmin-j
         endelse
         
         pos = 0
         for k=0,dy-1,1 do begin
            for l=0,abs(slope)-1,1 do begin
               ind[1,pos] = ymin+k
               pos = pos +1
            endfor
         endfor
      endelse
   ENDIF ELSE BEGIN
      return,-1
   ENDELSE


   ;;; Remove infs and NaNs from the selection. If they are all
   ;;; Infs or NaNs, then select nothing.
   if ind[0] NE -1 then begin
      WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=vals,USE_TABLE_SELECT=ind

      infs = where(finite(vals) EQ 1)
      if infs[0] EQ -1 then return,-1
   
      indtmp = intarr(2,n_elements(infs))

      for idx=0L,n_elements(infs)-1,1 do begin
         indtmp[*,idx] = ind[*,infs[idx]]
      endfor
      
      ind = indtmp
   endif

   tabstr = 'ind'+strtrim(string(itab),1)                            ; "ind"+ the current tab number is so we can have a tag name that we can break up for info later
   stat   = tag_exist(cache,"indices")                               ; Determine whether the indices structure has been made or not
   
   IF stat EQ 0 THEN BEGIN
      IF ind[0] NE -1 THEN BEGIN                                     ; If indices does not exist, but we have new data to enter, then insert indices and the ind#
         tempind = create_struct(tabstr,ind)
         cache   = create_struct(cache,"indices",tempind)
      ENDIF
   ENDIF ELSE BEGIN                                                  ; Logic for situations where indices already exists
      all_tags = get_tags(cache.indices)
      stat_sub = tag_exist(cache.indices,tabstr)

      IF ind[0] NE -1 THEN BEGIN
         IF stat_sub EQ 0 THEN BEGIN                                 ; If our current tab has not been added to cache.indices, add it
            cachetmp = create_struct(cache.indices,tabstr,ind)       ; Create a temp structure with the old cache.indices concatenated with the new ind#
            cache    = rm_tag(cache,"indices")                       ; Remove cache.indices
            cache    = create_struct(cache,"indices",cachetmp)       ; Recreate cache.indices with the temp structure (to avoid IDL errors of directly over-writing)
         ENDIF
         IF stat_sub EQ 1 THEN BEGIN                                 ; If our current tab has been added to cache.indices, modify it
            IF n_elements(all_tags) GT 1 THEN BEGIN
               cachetmp      = rm_tag(cache.indices,tabstr)
               cache         = rm_tag(cache,"indices")
               cache         = create_struct(cache,"indices",create_struct(cachetmp,tabstr,ind))
            ENDIF ELSE BEGIN
               cachetmp = create_struct(tabstr,ind)
               cache    = rm_tag(cache,"indices")
               cache    = create_struct(cache,"indices",cachetmp)
            ENDELSE
         ENDIF
      ENDIF
      
      IF ind[0] EQ -1 && stat_sub EQ 1 THEN BEGIN                    ; If our current tab exists, but nothing is selected, remove that tag
         IF n_elements(all_tags) EQ 1 THEN BEGIN                     ; If our current tab exists and the only one, remove cache.indices
            cache = rm_tag(cache,"indices")
         ENDIF ELSE BEGIN
            cachetmp = rm_tag(cache.indices,tabstr)
            cache    = rm_tag(cache,"indices")
            cache    = create_struct(cache,"indices",cachetmp)
         ENDELSE
      ENDIF
   ENDELSE

   WIDGET_CONTROL, ev.TOP, SET_UVALUE=cache                          ; Save the new cache to ev.TOP 
   WIDGET_CONTROL, cache.tablelist[itab], SET_TABLE_SELECT=ind       ; Set the selection in the table
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Display TVSCL of current table data                      ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager ;;;
;;; Post-Condition: Returns a new copy of cache via ev.TOP                   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function tvscl, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache

   itab = WIDGET_INFO(cache.Tab,/TAB_CURRENT)                  ; Store the current tab number

   WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=value      ; Grab all values from the table
   
   cache.plottype = 1                                          ; Set the display type to 1 so zoom knows what it is handling

   WSET, cache.preview                                         ; Set the display destination to the draw widget
   DEVICE, DECOMPOSED=1
   TVSCL, congrid(value,300,300)                               ; Display the table data fitted to be 300x300 pixels
   DEVICE, DECOMPOSED=0
   
   WIDGET_CONTROL, ev.TOP, SET_UVALUE=cache                    ; Store the new cache to ev.TOP
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Plots the histogram or contour plots to the main draw widget. ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager      ;;;
;;; Post-Condition: Returns a new copy of cache via ev.TOP                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function plothist, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache
   WIDGET_CONTROL, cache.binsize, GET_VALUE=binval
   
   flag = 0                                                             ; flag lets the code know if this is the first result actually plotted or not
   stat = tag_exist(cache,"indices")                                    ; Boolean test whether indices already exists or not.

   indcnt = (stat EQ 1) ? n_elements(get_tags(cache.indices)):0         ; Find number of tabs with selections, allows us to vary color of plots  
   cache.plottype = 2                                                   ; Set plottype to 2, which lets the code know we are NOT using TVSCL
   WSET,cache.preview                                                   ; Set the display window to the main draw widget

   IF cache.disptype EQ "histogram" AND stat EQ 1 THEN BEGIN            ; If there is some selection active, and we're plotting histograms, begin
      FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN                  ; Loop over all possible tables
         output = makehist(cache,j)                                     ; Save the output from makehist to plot to screen
  
         IF output[0] EQ -1 THEN continue                               ; makehist will return -1 if the current iteration of tables has no selection

         xval   = xvals(cache)                                          ; Get the axis labels and store to string array
     
         IF flag EQ 0 THEN BEGIN
            IF n_elements(xval) GT 8 THEN BEGIN                         ; If xvals is more than 8 indicies, reduce it to 8 to avoid clutter
               dx  = int((n_elements(xval)-1)/8.)
               tmp = [xval[0]]
               for a=1,7,1 do tmp = [tmp,xval[0+a*dx]]
               xval = tmp
            ENDIF

            numtick = n_elements(xval)-1
            plot,output,psym=10,xtickname=xval,xticks=numtick
            flag = 1
         ENDIF ELSE BEGIN
            oplot,output,psym=10,color=(j*250/indcnt)
         ENDELSE
      ENDFOR
   ENDIF
   IF cache.disptype EQ "distribution" AND stat EQ 1 THEN BEGIN               ; If there is some selection active, and we're plotting contours, begin
      FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN                        ; Loop over all possible tables
         output = makecon(cache,j,0,0)                                        ; Save the output from makecon to plot to screen

         IF output[0] EQ -1 THEN cache.conoff[*,j] = [-1,-1]
      ENDFOR

      FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN
         IF cache.conoff[0,j] NE -1 && cache.conoff[1,j] NE -1 THEN BEGIN
            output = makecon(cache,j,0,0)
            sz     = size(output)                                              ; If output is 1D, then we just plot it, if 2D, then we use contour

            if sz[0] EQ 1 then begin
               IF flag EQ 0 THEN BEGIN
                  plot,output,XTITLE='Column'
                  flag = 1
               ENDIF ELSE BEGIN
                  oplot,output,color=(j*250/indcnt)
               ENDELSE
            endif else begin
               xval   = xvals(cache)

               difx   = cache.conoff[0,j] - max([min(cache.conoff[0,*]),0])
               dify   = cache.conoff[1,j] - max([min(cache.conoff[1,*]),0])

               output=makecon(cache,j,difx,dify)


               IF flag EQ 0 THEN BEGIN
                  contour,output,xtickname=xval[0,*],ytickname=xval[1,*],XTITLE='Column',YTITLE='Row',NLEVELS=5
                  flag = 1
               ENDIF ELSE BEGIN
                  contour,output,color=(j*250/indcnt),/OVERPLOT,NLEVELS=5
               ENDELSE
            endelse
         ENDIF
      ENDFOR
   ENDIF

   X = [-2,0,2]
   y = [0,0,0]
   usersym,x,y
   
   legname = strarr(indcnt)
   legsym  = intarr(indcnt)+8
   col     = intarr(indcnt)
   indname = get_tags(cache.indices)
   
   for a=0,indcnt-1,1 do begin
      numstr     = strmid(indname[a],4)
      legname[a] = 'Tab '+numstr
      col[a]     = (a*250/indcnt)
   endfor
   
   col[0]=250
   
   IF cache.plottype NE 1 THEN BEGIN
      legend,legname,psym=legsym,colors=col
   ENDIF

   IF cache.disptype EQ "histogram" AND cache.plottype NE 1 THEN BEGIN
      INFOSTR = "Minimum is: "+strtrim(string(min(cache.histmins)),2)
      xyouts,75,60,INFOSTR,/DEVICE
            
      INFOSTR = "Binsize is: "+strtrim(string(cache.binsize[0]),2)
      xyouts,75,50,INFOSTR,/DEVICE
      
      cache.histmins = [float(-999)]
   ENDIF

   WIDGET_CONTROL, ev.TOP, SET_UVALUE=cache
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Takes the user selected tag from a PDS structure, and       ;;;
;;;                 the current table values with the newly selected data.      ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager    ;;;
;;; Post-Condition: Returns a new copy of cache via ev.TOP and replaces content ;;;
;;;                 of the main widgets table.                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function newform, ev
   if ev.CLICKS EQ 2 then begin                                                     ; We only want to replace values on a double click
      WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache                                      ; Get the current cache from ev.TOP
      
      for i=0,n_elements(cache.leafid)-1,1 do begin                                 ; Loop over all leaves
         flag = WIDGET_INFO(cache.leafid[i], /TREE_SELECT)                          ; Return boolean if the current leaf in the tree is selected or not
         if flag EQ 1 then iLeaf = i                                                ; Save the current indice for later referencing
      endfor

      itab = WIDGET_INFO(cache.Tab,/TAB_CURRENT)

      WIDGET_CONTROL, cache.leafid[iLeaf], GET_UVALUE=iObj                          ; Get the User Value for selected leaf (The substructure path of given PDS structure)
      WIDGET_CONTROL, cache.tablelist[itab], GET_UVALUE=pdsf, GET_VALUE=iTable      ; Get the User Value for selected leaf (The PDS structure passed by readpds)
      
      exstr = 'newtable = pdsf'+iObj
      void  = EXECUTE(exstr)                                                        ; Store the array from PDS structure to newtable so we can display it

      szstr = dimensions(iTable)                                                    ; Get the current table dimensions
      sx    = szstr.sx
      sy    = szstr.sy
      
      szstr = dimensions(newtable)                                                  ; Get the new table dimensions
      newsx = szstr.sx
      newsy = szstr.sy
            
      dx = (newsx-sx)                                                               ; Find x size difference of old and new
      dy = (newsy-sy)                                                               ; Find y size difference of old and new

      if (dx GT 0) then begin
         WIDGET_CONTROL, cache.tablelist[itab], INSERT_COLUMNS=dx                   ; If the new table is wider, insert columns so we can display everything
      endif
      if (dy GT 0) then begin
         WIDGET_CONTROL, cache.tablelist[itab], INSERT_ROWS=dy                      ; If the new table is taller, insert columns so we can display everything
      endif
      
      WIDGET_CONTROL, cache.tablelist[itab], SET_VALUE=[newtable]                   ; Replace old table with new table
   endif
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Saves the current selection from all active tabs.        ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager ;;;
;;; Post-Condition: Saves a file to current folder called 'histogram.save'   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function save, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache                                               ; Grab the cache
   
   flag = 0                                                                               ; Flag to differentiate initialization from concatenation
   stat = tag_exist(cache,"indices")                                                      ; Check to see if any selections have been made

   FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN
      tabstr  = 'ind'+strtrim(string(j),1)                                                ; Form substring needed to get info from cache.indices for current tab
      
      if stat EQ 1 then begin                                                             ; If there is a selection on this tab, proceed
         substat = tag_exist(cache.indices,tabstr)
         
         if substat EQ 1 then begin
            exstr = 'tmp = cache.indices.ind'+strtrim(string(j),1)                        ; Save the indices from that tab to the variable tmp
            void  = EXECUTE(exstr)
            
            WIDGET_CONTROL, cache.tablelist[j],SET_TABLE_SELECT=tmp                       ; Use those indices to highlight correct values in that tab
            WIDGET_CONTROL, cache.tablelist[j],GET_VALUE=vals,/USE_TABLE_SELECT           ; Grab the highlighted values
            
            if flag EQ 0 then begin
               output = create_struct("tab"+strtrim(string(j),1),vals)                    ; Initialize a structure to store final results
               flag   = 1                                                                 ; trip the flag
            endif else begin
               output = create_struct(output,"tab"+strtrim(string(j),1),vals)             ; Concatenate new values into the structure
            endelse
         endif
      endif
   endfor
   save,output,FILENAME='histogram.save'                                                  ; Save our structure as histogram.save
end         
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Exits the current session.                               ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager ;;;
;;; Post-Condition: None.                                                    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function exit, ev
   WIDGET_CONTROL, ev.TOP, /DESTROY
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Event function for the zoomed window. Allows the user to    ;;;
;;;                 either close the window with a left double-click, or to     ;;;
;;;                 choose new selection points with single right-click.        ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager    ;;;
;;; Post-Condition: If new points are selected, it will replace the coordinates ;;;
;;;                 in the main widget.                                         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro zoomed_event, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache                                               ; Grab the cache

   if ev.CLICKS EQ 2 THEN BEGIN                                                           ; If the user double clicks, close the zoomed window
      WIDGET_CONTROL, ev.TOP, /DESTROY
   endif
   
   IF ev.CLICKS EQ 1 AND ev.PRESS EQ 4 AND cache.plottype EQ 1 then begin                 ; On single right click, store user defined coordinate for draw selection
      WIDGET_CONTROL, cache.coord1, GET_VALUE=coord1 
      WIDGET_CONTROL, cache.coord2, GET_VALUE=coord2
      WIDGET_CONTROL, cache.zoom, GET_VALUE=zoom

      itab = WIDGET_INFO(cache.Tab,/TAB_CURRENT)
      WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=iTable
         
      sz   = dimensions(iTable)
      xdim = sz.sx
      ydim = sz.sy
         
      xfac = xdim/float((300*zoom[0]))
      yfac = ydim/float((300*zoom[0]))

      xpos = strtrim(string(int(ev.x*xfac)),1)
      ypos = strtrim(string(int(ev.y*yfac)),1)

      IF coord1 EQ "(x0,y0): " THEN BEGIN
         WIDGET_CONTROL, cache.coord1, SET_VALUE='(x0,y0): ('+xpos+','+ypos+')'
      ENDIF
      
      IF coord1 NE "(x0,y0): " AND coord2 EQ "(x1,y1): " THEN BEGIN
         WIDGET_CONTROL, cache.coord2, SET_VALUE='(x1,y1): ('+xpos+','+ypos+')'
      ENDIF
      
      IF coord1 NE "(x0,y0): " AND coord2 NE "(x1,y1): " THEN BEGIN
         WIDGET_CONTROL, cache.coord1, SET_VALUE='(x0,y0): '
         WIDGET_CONTROL, cache.coord2, SET_VALUE='(x1,y1): '
      ENDIF
   ENDIF
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description   : Event function for the small window. Allows the user to        ;;;
;;;                 either zoom the window with a left double-click, or to         ;;;
;;;                 choose new selection points with single right-click.           ;;;
;;; Pre-Condition : Requires the ev structure to be passed from the xmanager       ;;;
;;; Post-Condition: If new points are selected, it will replace the coordinates    ;;;
;;;                 in the main widget. If they choose to zoom, it spawns a larger ;;;
;;;                 draw widget.                                                   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro histogram_event, ev
   WIDGET_CONTROL, ev.TOP, GET_UVALUE=cache                                                  ; Grab the cache
   itab = WIDGET_INFO(cache.Tab,/TAB_CURRENT)                                                ; Get the current tab so we can reference the correct values
   flag = 1
   stat = tag_exist(ev,"clicks")                                                             ; Check to see if the user actually clicked on the widget (Leftover failsafe)

   IF cache.plottype EQ 0 THEN BEGIN
      flag = 0
   ENDIF

   IF stat EQ 1 THEN BEGIN
      IF ev.CLICKS EQ 2 AND ev.PRESS EQ 1 AND flag EQ 1 THEN BEGIN                           ; On double left click when the draw widget isnt empty, zoom 
         WIDGET_CONTROL, cache.zoom, GET_VALUE=zoom                                          ; Grab the user specified zoom value
         
         zoom   = int(zoom)                                                                  ; Convert string to int
         width  = zoom*300                                                                   ; New width value
         height = zoom*300                                                                   ; New height value
   
         LRGmain     = WIDGET_BASE(/COLUMN)                                                  ; Initialize a new base to draw in
         LRG_preview = WIDGET_DRAW(LRGmain,/BUTTON_EVENT,XS=width,YS=height,RETAIN=2)        ; Initialize the draw widget for the new scaled plot
         
         WIDGET_CONTROL, LRGmain, /realize
         WIDGET_CONTROL, LRG_preview, GET_VALUE=LRGdrawID                                    ; Grab the widget ID for the new draw wiget
         
         cache = create_struct(cache,"LRG_preview",LRGdrawID)                                ; Stuff out new draw widget id into the cache
         WIDGET_CONTROL,LRGmain,SET_UVALUE=cache                                             ; Store the new cache variable in our widget base
         
         WSET, LRGdrawID
         
         IF cache.plottype EQ 1 THEN BEGIN                                                   ; If we are working with the tvscl output, we need to grab the right values
            WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=fulltable                       ; Get the values for the current tab
            DEVICE, DECOMPOSED=1                                                             ; Allow us to edit draw widget for a moment
            TVSCL,congrid(fulltable,width,height)                                            ; Show the current tab values when rescaled to the zoomed size
            DEVICE, DECOMPOSED=0                                                             ; Prevent toying around with the widget
         ENDIF

         indcnt = (tag_exist(cache,"indices") EQ 1) ? n_elements(get_tags(cache.indices)):0  ; Find out how many tabs are actually being used
         
         IF cache.plottype EQ 2 THEN BEGIN                                                   ; 2 if a histogram or contour plot (Leftover from alpha. Should merge disptype
                                                                                             ; and plottype properly.)
            flag = 0                                                                         ; flag lets the code know if this is the first result actually plotted or not
            IF cache.disptype EQ "histogram" THEN BEGIN
               FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN                              ; Loop over the different tables to find any data that needs plotting
                  output = makehist(cache,j)                                                 ; Create a histogram using makehist from the current table

                  IF output[0] NE -1 THEN BEGIN
                     xval   = xvals(cache)                                                   ; Get string array with the bin locations

                     IF flag EQ 0 THEN BEGIN
                        IF n_elements(xval) GT 8 THEN BEGIN                                  ; If xvals is more than 8 indicies, reduce it to 8 to avoid clutter
                           dx  = int((n_elements(xval)-1)/8.)
                           tmp = [xval[0]]
                           for a=1,7,1 do tmp = [tmp,xval[0+a*dx]]
                           xval = tmp
                        ENDIF
                           
                        numtick = n_elements(xval)-1                                         ; Get the number of ticks we'll need to set the plot to display
                        plot,output,PSYM=10,xtickname=xval,xticks=numtick                    ; Plot the histogram with our custom labels
                        flag = 1                                                             ; trip the flag so any other histograms will use overplot instead
                     ENDIF ELSE BEGIN
                        oplot,output,psym=10,color=(j*250/indcnt)                            ; Overplot any additional histograms using a different color
                     ENDELSE
                  ENDIF
               ENDFOR
            ENDIF ELSE BEGIN
               FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN                              ; Loop over the different tables to find any data that needs plotting
                  output = makecon(cache,j,0,0)
               
                  IF output[0] EQ -1 THEN cache.conoff[*,j] = [-1,-1]                        ; If we get -1, then store -1,-1 as a flag
               ENDFOR
               
               FOR j=0,n_elements(cache.tablelist)-1,1 DO BEGIN
                  IF cache.conoff[0,j] NE -1 && cache.conoff[1,j] NE -1 THEN BEGIN           ; Check to see if current table returned a [-1,-1]
                     output = makecon(cache,j,0,0)                                           ; Get contour output from table
                     sz     = size(output)                                                   ; get the size of the output

                     if sz[0] EQ 1 then begin                                                ; If we have a 1D array, we just need to use a regular plot
                        IF flag EQ 0 THEN BEGIN
                           plot,output,XTITLE='Column',YTITLE='Row'
                           flag = 1
                        ENDIF ELSE BEGIN
                           oplot,output,color=(j*250/indcnt)
                        ENDELSE
                     ENDIF ELSE BEGIN                                                        ; If we get a 2d array, we need to do a touch more work
                                                                                             ; NOTE: Account for 2d and 1d mix?
                        xval   = xvals(cache)                                                ; Get the tick names

                        difx   = cache.conoff[0,j] - max([min(cache.conoff[0,*]),0])         ; Find the maximum offset between tabs in the X direction
                        dify   = cache.conoff[1,j] - max([min(cache.conoff[1,*]),0])         ; Find the maximum offset between tabs in the Y direction

                        output=makecon(cache,j,difx,dify)                                    ; Get the contour output, only now shift it according to difx and dify

                        IF flag EQ 0 THEN BEGIN
                           contour,output,xtickname=xval[0,*],ytickname=xval[1,*],XTITLE='Column',YTITLE='Row',NLEVELS=5
                           flag = 1
                        ENDIF ELSE BEGIN
                           contour,output,color=(j*250/indcnt),/OVERPLOT,NLEVELS=5
                        ENDELSE
                     ENDELSE
                  ENDIF
               ENDFOR
            ENDELSE
         ENDIF
         
         IF cache.plottype NE 1 THEN BEGIN                                          ; If draw widget is not displaying TVSCL, come up with a legend for plots
            X = [-2,0,2]                                                            ; Our symbols for the legend are just the line defined by [Xi,Yi]
            y = [0,0,0]
            usersym,x,y
   
            legname = strarr(indcnt)                                                ; Initialize the string array of legend entry text
            legsym  = intarr(indcnt)+8                                              ; Set the legend symbol array to 8, which uses the usersym output
            col     = intarr(indcnt)                                                ; Array of colors to use for each legend entry
            indname = get_tags(cache.indices)                                       ; Get the indice names for the active tabs
   
            for a=0,indcnt-1,1 do begin
               numstr     = strmid(indname[a],4)
               legname[a] = 'Tab '+numstr
               col[a]     = (a*250/indcnt)
            endfor
   
            col[0]=250

            legend,legname,psym=legsym,colors=col                                   ; Plot a legend
         ENDIF

         IF cache.disptype EQ "histogram" AND cache.plottype NE 1 THEN BEGIN        ; If we are using the histogram feature, we should also show the binsize and minimum
            INFOSTR = "Minimum is: "+strtrim(string(min(float(output))),2)
            xyouts,75,60,INFOSTR,/DEVICE
            
            INFOSTR = "Binsize is: "+strtrim(string(float(cache.binsize[0])),2)
            xyouts,75,50,INFOSTR,/DEVICE
         ENDIF
         
         
         XMANAGER, 'zoomed', LRGmain
      ENDIF
      
      IF ev.CLICKS EQ 1 AND ev.PRESS EQ 4 AND cache.plottype EQ 1 then begin         ; If a single right click, set a point for user defined selection from draw widget
         WIDGET_CONTROL, cache.coord1, GET_VALUE=coord1 
         WIDGET_CONTROL, cache.coord2, GET_VALUE=coord2
         WIDGET_CONTROL, cache.tablelist[itab], GET_VALUE=iTable
         
         sz   = dimensions(iTable)
         xdim = sz.sx
         ydim = sz.sy
         
         xfac = xdim/300.
         yfac = ydim/300.

         xpos = strtrim(string(int(ev.x*xfac)),1)
         ypos = strtrim(string(int(ev.y*yfac)),1)
  
         IF coord1 EQ "(x0,y0): " THEN BEGIN
            WIDGET_CONTROL, cache.coord1, SET_VALUE='(x0,y0): ('+xpos+','+ypos+')'
         ENDIF
         
         IF coord1 NE "(x0,y0): " AND coord2 EQ "(x1,y1): " THEN BEGIN
            WIDGET_CONTROL, cache.coord2, SET_VALUE='(x1,y1): ('+xpos+','+ypos+')'
         ENDIF
         
         IF coord1 NE "(x0,y0): " AND coord2 NE "(x1,y1): " THEN BEGIN
            WIDGET_CONTROL, cache.coord1, SET_VALUE='(x0,y0): '
            WIDGET_CONTROL, cache.coord2, SET_VALUE='(x1,y1): '
         ENDIF
      ENDIF
   ENDIF
end

pro histogram,pdsf,tabitr
   input  = [0]                                                                        ; Dummy array to first initialize the table with
   cache  = {disptype:"histogram",histmins:float(-999)}                                       ; Initialize the cache variable, which will store most of our info

   ;;; Create the Widget Bases
   main         = widget_base(mbar=BAR,/COLUMN)
   top          = widget_base(main,/ROW)
   tree_base    = widget_base(top,/COLUMN)
   preview_base = widget_base(top,/ROW)
   setting_base = widget_base(top,/COLUMN,XSIZE=300,YSIZE=300)
   coord_base   = widget_base(setting_base,/COLUMN)
   zoom_base    = widget_base(setting_base,/ROW)
   bin_base     = widget_base(setting_base,/ROW)
   prefbase     = widget_base(setting_base,/ROW,/EXCLUSIVE)

   ;;; Create Main Menu
   filemenu  = WIDGET_BUTTON(bar, VALUE='File', /MENU)
   file_save = WIDGET_BUTTON(filemenu, VALUE='Save Selection',EVENT_FUNC='save')
   file_exit = WIDGET_BUTTON(filemenu, VALUE='Exit',EVENT_FUNC="exit")
   helpmenu  = WIDGET_BUTTON(bar, VALUE='Help', /MENU)
   help_help = WIDGET_BUTTON(helpmenu, VALUE='Help',EVENT_FUNC="helpinfo")
 

   ;;; Read in tags for PDS structure
   ;;; NOTE: This is a stupid way to do things, but the best I could come up with at this time....
   tags    = get_tags(pdsf)                                 ; Call outside procedure, get_tags.pro, to find tags in a structure
   tagtree = widget_tree(tree_base,XSIZE=300,YSIZE=300)     ; Create Tree Widget that will house PDS Structure tags
   leafid  = strarr(1)                                      ; Initialize array to store leaves in the Tree Widget
   path    = ''                                             ; Initialize variable that will hold the path leading to a bottom element in a structure
   
   for i=0,n_elements(tags)-1,1 do begin
      iObj = tags[i]
      void = EXECUTE('iType = type(pdsf'+iObj+')')                   ; Find the type of the current tag
      
      if iType NE 8 then begin                                       ; Type 8 is a structure. We want the bottom elements. Skip Structures.

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
         ;;; To display COLUMN objects by their given name, we need to extract  ;;;
         ;;; information from the NAMES column. We find these names, store them ;;;
         ;;; then assign them to anything that matches *COLUMN*.                ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         namesplt = strsplit(iObj,'NAMES',/extract,/regex)           ; Split the current element to test for possible NAMES column

         IF strmid(namesplt,strlen(namesplt)-1) EQ '.' THEN BEGIN    ; We expect any matches to leave a substring ending in '.'
            exstr   = 'names = pdsf'+iObj                            ; Save the names column to a regular variable 'names'
            void    = EXECUTE(exstr)
            path    = namesplt
            nameind = 0                                              ; Iterand for going through names in later code
         ENDIF

         colsplit = strsplit(iObj,'COLUMN',/extract,/regex)          ; If we can break up the element by COLUMN and match it to 'path', we need to assign a name

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; Dynamically assign a leaf to the renamed PDS column. Note ;;; 
         ;;; that UVALUE stores the original tag name. This is needed  ;;;
         ;;; for later code so we can call on the contents properly.   ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         IF colsplit[0] EQ path THEN BEGIN
            exstr  = 'tagleaf'+strtrim(string(i),1)+' = WIDGET_TREE(tagtree,VALUE="'+path+names[nameind]+'",UVALUE="'+iObj+'",event_func="newform")'
            void   = EXECUTE(exstr[0])
            nameind = nameind+1
         ENDIF ELSE BEGIN
            exstr  = 'tagleaf'+strtrim(string(i),1)+' = WIDGET_TREE(tagtree,VALUE="'+iObj+'",UVALUE="'+iObj+'",event_func="newform")'
            void   = EXECUTE(exstr)
         ENDELSE

         exstr  = 'leafid = [leafid,tagleaf'+strtrim(string(i),1)+']'
         void   = EXECUTE(exstr)
      endif
   endfor
   leafid  = leafid[1:n_elements(leafid)-1]        ; Strip away the initial blank string we used to initialize this variable
   
   
   ;;; Build the Preview Window
   preview = WIDGET_DRAW(preview_base, XSIZE=300, YSIZE=300, /BUTTON_EVENTS,RETAIN=2)


   ;;; Build the Settings Window
   zoomlbl      = widget_label(zoom_base,value="Zoom:    ")
   zoom         = widget_text(zoom_base,value=strtrim(string(1),1),/EDITABLE)
   binsizelbl   = widget_label(bin_base,value="Binsize: ") 
   binsize      = widget_text(bin_base,value=strtrim(string(1),1),/EDITABLE)
   tvscl_button = widget_button(setting_base, value="TVSCL", EVENT_FUNC="tvscl",ysize=40,xsize=50)
   coord1lbl    = widget_label(coord_base,value="(x0,y0): ",XS=200,/ALIGN_LEFT)
   coord2lbl    = widget_label(coord_base,value="(x1,y1): ",XS=200,/ALIGN_LEFT)
   highbutton   = widget_button(setting_base,value="Verify/Highlight Selection",EVENT_FUNC="highlight",ysize=40,xsize=50)
   histbutton   = widget_button(setting_base,value="Plot",ysize=40,xsize=50,EVENT_FUNC='plothist')
   pref_hist    = WIDGET_BUTTON(prefbase,VALUE="Histogram",EVENT_FUNC='disptype_hist')
   pref_dist    = WIDGET_BUTTON(prefbase,VALUE="Distribution",EVENT_FUNC='disptype_dist')
   tab          = WIDGET_TAB(main,YS=570)


   tbstr  = 'tablelist=['                          ; Initialize tbstr. Contains a list of user specified tabs and their names

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;;; Concatenate the needed commands to create the user ;;;
   ;;; tabs and their tables. Then store their name into  ;;;
   ;;; into tbstr for later use.                          ;;;
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   FOR tableIDX=0,tabitr-1,1 DO BEGIN
      exstr = 'tab'+strtrim(string(tableIDX+1),1)+'_base= WIDGET_BASE(tab,TITLE="TABLE '+strtrim(string(tableIDX+1),1)+'")'
      void  = EXECUTE(exstr)

      exstr = 'table'+strtrim(string(tableIDX+1),1)+'= widget_table(tab'+strtrim(string(tableIDX+1),1) $ 
              +'_base,value=input,/disjoint_selection,SCR_XSIZE=920,SCR_YSIZE=570,UVALUE=pdsf)'
      void  = EXECUTE(exstr)
      
      tbstr = tbstr+'table'+strtrim(string(tableIDX+1),1)+','
   ENDFOR

   tbstr = strmid(tbstr,0,strlen(tbstr)-1)+']'     ; Clean up the tbstr and concatenate the final character to form a list
   void  = EXECUTE(tbstr)

   conoff = intarr(2,tabitr)                       ; Initialize Contour offsets

   DEVICE, DECOMPOSED=0                            ; Ensure the draw widget is not destroyed when it goes to the background
   loadct,2                                        ; Load a color pallet so the user can easily distinguish different graphs
   WIDGET_CONTROL, main, /realize
   WIDGET_CONTROL, pref_hist, /SET_BUTTON          ; Solely cosmetic. Shows this button selected to start with.
   WIDGET_CONTROL, preview, GET_VALUE=drawID       ; We can only get the ID of the draw widget after it has been realized

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;;; The most important variable in the program. Stores the WIDGET IDs and some important flags ;;;
   ;;; that the other functions need to operate. Be careful modifying this.                       ;;;
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   cache  = create_struct(cache,"tagtree",tagtree,"leafid",leafid,"binsize",binsize,"tablelist",tablelist,"preview",drawid,"zoom",zoom, $
                          "coord1",coord1lbl,"coord2",coord2lbl,"plottype",0,"prefh",pref_hist,"prefd",pref_dist,"Tab",tab,"conoff",conoff)

   WIDGET_CONTROL, main, SET_UVALUE=cache    ; Assign cache to the UVALUE of main. This way other widgets and events can grab it
   XMANAGER, 'histogram', main               ; Boot off main to the XMANAGER. I have not tested this on systems where XMANAGER settings are not straightforward.
end
