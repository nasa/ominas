;docformat = 'rst rst'
;=============================================================================
;+
; GRIM
; ====
;
;      General-purpose GRaphical Interface for oMinas.
; 
;
; CATEGORY: NV/GR
;
;
; CALLING SEQUENCE::
;
;            grim, arg1, arg2
;
;
; ARGUMENTS:
; ----------
; 
;  INPUT:
;  ~~~~~~
;      arg1, arg2:
; 
;            GRIM accepts up to two arguments, which can appear in either
;            order.  Possible arguments are:
;
;                  data descriptors [object array]
;                  file specifications [string array]
;                  grn (GRIM window number) [scalar]
;                  plot [1d array]
;                  image [2d array]
;                  cube [3d array]
;       
;      Plots are displayed as graphs whose abscissa are the array index, unless
;      an abscissa is present in the data descriptor.  Many functions are not
;      available in this mode.
;
;      Cubes are handled as multiple image planes unless /rgb is used
;      (see below).  All GRIM planes will contain the same data array,
;      but display only data ranges corresponding to one channel of the cube.
;      For /rgb (assuming the cube has three channels), the data are placed
;      on a single image plane with each cube channel assigned the R, G, or B
;      color channel.
;
;  OUTPUT:
;  ~~~~~~~
;      None
;
;  
;  KEYWORDS:
;  ---------
;
;   INPUT:
;   ~~~~~~
;      Descriptor Keywords
;      ~~~~~~~~~~~~~~~~~~~
;      The following inputs replace objects already maintained by GRIM.  They
;      must be given as either a single element, which is applied to the
;      current plane, or as an array with one element for each plane.
;
;      `cd`:  Replaces the current camera descriptor.  This may also be
;              a map descriptor, in which case some of GRIM's functions
;             will not be available.  When using a map descriptor instead
;             of a camera descriptor, you can specify a camera descriptor
;             as the observer descriptor (see the 'od' keyword below) and
;             some additional geometry functions will be available.
;
;      `od`:  Replaces the current observer descriptor.  The observer
;             descriptor is used to allow some geometry objects (limb,
;             terminator) to be computed when using a map descriptor instead
;             of a camera descriptor.
;
;      The following inputs replace or augment objects already maintained
;      by GRIM.  They are sorted into their respective planes by comparing
;      their internal generic descriptors with the data descriptor or
;      observer descriptor (in the case of a map) for each plane.  Objects
;      whose names match those already maintained by GRIM replace them.
;
;      `ltd`: Replaces the current light descriptor.
;
;      `pd`:   Adds/replaces planet descriptors.
;
;      `rd`:   Adds/replaces ring descriptors.
;
;      `sd`:   Adds/replaces star descriptors.
;
;      `std`:  Adds/replaces station descriptors
;
;      `ard`:  Adds/replaces array descriptors
;
;      `gd`:   Generic descriptor containing some or all of the above
;              descriptors.
;
;  `assoc_xd`:
;   If given, use these descriptors to sort descriptors into
;   planes instead of matching the data descriptors or observer
;   descriptors in their internal generic descriptors.
;
;
;      Descriptor Select Keywords
;      ~~~~~~~~~~~~~~~~~~~~~~~~~~
;      Descriptor select keywords (see pg_get_*) are specified using the
;      standard prefix corresponding to the descriptor type.  For example,
;      the fov keyword to pg_get_planets would be given to GRIM as plt_fov.
;      Note that these keywords do not appear in the transator arguments 
;      in GRIM's overlay settings tool.
;
;
;      Initial Colormap Keywords
;      ~~~~~~~~~~~~~~~~~~~~~~~~~
;  
;      The colormap structure (see colormap_descriptor__define) can be
;      be initialized via keywords prefied with 'cmd_', e.g., 'cmd_shade'.
;      In addition, the following keywords apply to the initial color map:
;
;      `*auto_stretch`:
;            If set, the color table for each plane is automatically
;            stretched.  This is identical to using the 'Auto' button
;            on on the GRIM color tool.
;
;
;      Translator Keywords
;      ~~~~~~~~~~~~~~~~~~~
;      The following keywords are passed directly to the translators, which
;      are responsible for interpreting their meanings.
;
;      `*cam_trs`: String giving translator keywords for the camera descriptors.
;
;      `*lgt_trs`: String giving translator keywords for the light descriptors.
;
;      `*plt_trs`: String giving translator keywords for the planet descriptors.
;
;      `*rng_trs`: String giving translator keywords for the ring descriptors.
;
;      `*str_trs`: String giving translator keywords for the star descriptors.
;
;      `*stn_trs`: String giving translator keywords for the station descriptors.
;
;      `*arr_trs`: String giving translator keywords for the array descriptors.
;
;
;      TVIM Keywords
;      ~~~~~~~~~~~~~
;      The following keywords set the initial viewing parameters and are
;      simply passed to TVIM.
;
;      `*xsize`:  Size of the graphics window in the x direction.  
;
;      `*ysize`:  Size of the graphics window in the y direction.  
;
;      `*zoom`:   Initial zoom to be applied to the image.  If not given, GRIM
;                 computes an initial zoom such that the entire image fits on the
;                 screen.
;
;      `*integer_zoom`:
;                 If set, zoom levels will be rounded to the nearst integer
;                 or 1/integer.
;
;      `*rotate`: Initial rotate value to be applied to the image (as in the IDL
;                 ROTATE routine).  If not given, 0 is assumed.
;
;      `*order`:  Initial display order to be applied to the image.
;
;      `*offset`: Initial offset (dx,dy) to be applied to the image.
;
;      `doffset`: Change the offset viewing parameter by this amount.
;
;      `default`: If set, use default tvim properties (zoom=[1,1], offset=[0,0]
;                 order=0 [bottom-up])
;
;      `previous`: If set, restore last-used tvim viewing parameters.
;
;      `restore`: If set, use saved tvim viewing paramters.
;
;
;      Customization Keywords
;      ~~~~~~~~~~~~~~~~~~~~~~ 
;      `*menu_extensions`:
;            Array of strings giving the names of functions that return
;            menu definitions, as defined by cw_pdmenu.  These menus are
;            added to the built-in GRIM menus between the Overlays menu
;            and the Help menu.  The default is 'grim_default_menus'.  If
;            the first character in the first menu function is '+', then
;            grim_default_menus is retained an the new menu are appended
;            after that menu.  Otherwise, 'grim_default_menus' is replaced.
;
;      `*button_extensions`:
;            Array of strings giving the names of definition functions
;            for custom cursor modes to be added after the built-in
;            cursor modes.  The definition function takes one argument
;            (see arg_extensions below) and returns a grim_user_mode_struct.
;
;      `*arg_extensions`:
;            Argument to be provided to the button extension definition
;            function above.
;
;      `*menu_fname`:
;            Name of a file containing additional menus to add to
;            the GRIM widget.  The file syntax follows that for cw_pdmenu.
;
;      `*arg_menus`:
;            Argument to be provided to the menu extension definition
;            function above.
;
;
;      Other Keywords
;      ~~~~~~~~~~~~~~
;      `*extensions`:
;               String array giving extensions to try for each input file.
;               see dat_read.
;
;      `*new`:  If set, a new GRIM instance is created and all keywords apply
;               to that instance.
;
;      `erase`: If set, erase the current image before doing anything else.
;
;      `*mode_init`:
;               Initial cursor mode.  See below.
;
;      `*mode_args`:
;               Array giving arguments for the cursor modes initialization
;               functions.  If a string, then syntax is NAME:ARG, where NAME
;               is the name of the cursor mode, and ARG is the argument for
;               that mode.  For example::
;
;                  mode_args='READOUT:myreadout_fn'
;
;               would cause the function 'myreadout_fn' to be added to
;               the list of functions called by pg_cursor and pg_measure
;               via the readout cursor mode.  If not a string, the argument
;               is passed to the initialization function with no processing.
;
;      `*retain`:
;               Retain settings for backing store (see "backing store" in
;               the IDL reference guide).  Defaults to 2.
;
;      `*clip`: Controls the number of fields of view in which overlays are
;               computed.
;
;      `*fov`:  Controls the number of fields of view in which to request
;               planet, ring and star descriptors.  Values are as follows:
;
;                   0 : get all descriptors
;                  <0 : relative to viewport
;                  >0 : relative to image / optic axis
;
;               Note that fov > 0 is the same as setting the fov descriptor
;               select keywords (see above).  Default is 0, but stars operate
;               best when fov > 0.
;
;      `*hide`: If set, overlays are hidden w.r.t shadows and obstructions.
;               Default is on.
;
;      `no_erase`:
;               If set, GRIM does not erase the draw windoww.
;
;      `no_refresh`:
;               If set, GRIM does not refresh.
;
;      `*rgb`:  If set, GRIM interprets a 3-plane cube as a 3-channel color image
;               to be displayed on a single plane.
;
;      `*channel`:
;               Array of bitmasks specifying the color channel in which to
;               display each given image: 1b, 2b, or 4b.
;
;      `*visibility`:
;               Initial visibility setting for planes:
;
;                  0: Only the current plane is drawn.
;                  1: All planes are drawn.
;
;               Default is 0.
;
;      `*max`:  Maximum data value to scale to when displaying images.
;               Values larger than this are set to the maximum color table
;               index.  If not set, the maximum value in the data set is used.
;               In cases where the data array is being subsampled, this value
;               may not be known, resulting in varying image scaling as more
;               and more data values are sampled.  That problem may be
;               eliminated via this keyword.
;
;      `exit`:  If set, GRIM immediately exits.  This can be used to kill an
;               existing GRIM window.
;
;      `modal`: If set, GRIM is run as a modal widget, i.e., there is no command
;               prompt.
;
;      `*frame`:If set, the initial view is set such that all members of the
;               named overlay types are are visible.  If /frame, then all
;               overlays are framed.  Note that object types that rely on the
;               view to determine which objects to compute (e.g., stars)
;               cannot be framed in this way.
;
;      `refresh_callbacks`:
;               Array of strings giving the names of procedures to be
;               called after each refresh.  See CALLBACK PROCEDURES
;               below.  Refresh callbacks receive only the data argument.
;
;      `refresh_callback_data_ps`:
;               Array of pointers (one per callback) to data for the refresh
;               callback procedures specified using the refresh_callbacks
;               keyword.  See CALLBACK PROCEDURES below.
;
;      `plane_callbacks`:
;               Array of strings giving the names of procedures to be
;               called after each plane change.  See CALLBACK PROCEDURES
;               below.  Plane callbacks receive only the data argument.
;
;      `plane_callback_data_ps`:
;               Array of pointers (one per callback) to data for the plane
;               callback procedures specified using the plane_callbacks
;               keyword.  See CALLBACK PROCEDURES below.
;
;      `*nhist`:History setting to be applied to data decriptor (see
;               ominas_data__define).  GRIM uses data descriptor history to
;               undo changes to the data array.  If nhist is not set, or is
;               equal to 1, the undo menu option will not function.
;
;      `*maintain`:
;               If given, this maintainance setting is applied to the data
;               descriptor (see ominas_data__define).
;
;      `*compress`:
;               Compression setting to be applied to data decriptor (see
;               ominas_data__define).
;
;      `*filter`:
;               Initial filter to use when loading or browsing files.
;
;      `*load_path`:
;               Initial path for the file loading dialog.
;
;      `*save_path`:
;               Initial path for the file saving dialog.
;
;      `*path`:  Sets both load_path and save_path to this value.
;
;      `*workdir`:
;               Default directory for saving user points, masks, tie
;               points, curves
;
;      `user_psym`:
;               Default plotting symbol for user overlays.
;
;      `grn`:   Identifies a specific GRIM window by number.  GRIM numbers are
;               displayed in the status bar, e.g.: grim <grn>.
;
;      `tag`:   Identifies a specific GRIM window by string.  GRIM tags are
;               displayed in the status bar in quotes.  If no GRIM window
;               exists with this tag, then one is created.
;
;      `pn`:    Directs GRIM to change to the plane corresponding to this plane
;               number.
;
;      `*cursor_swap`:
;               If set, cursor bitmaps are byte-order swapped.
;
;      `*loadct`:
;               Index of color table to load.
;
;      `*beta`: If set beta features are enabled.
;
;      `*npoints`:
;               Number of point to compute for various overlays.  Default is 
;               1000.
;
;      `*plane_syncing`: 
;               Turns plane syncing on (1) or off (0).  Default is 0.
;
;      `*tiepoint_syncing`: 
;               Turns tiepoint syncing on (1) or off (0).  Default is 0.
;
;      `*curve_syncing`: 
;               Turns curve syncing on (1) or off (0).  Default is 0.
;
;      `*activation_syncing`: 
;               Turns activation syncing on (1) or off (0).  Default is 0.
;
;      `*action_syncing`: 
;               Turns action syncing on (1) or off (0).  Default is 0.
;
;      `position`:
;               Sets the plot position; see the POSITION grahics keyword.
;
;      `color`: Sets the line color index for plots.  One element per plane.
;
;      `xrange`:Sets the X-axis range for plots.
;
;      `yrange`:Sets the Y-axis range for plots.
;
;      `thick`: Sets the line thickness for plots.  One element per plane.
;
;      `title`: For plots, sets the plot title for plots; one element per plane.
;               For images, sets the base default title.
;
;      `xtitle`:Sets the X-axis label for plots.  One element per plane.
;
;      `ytitle`:Sets the Y-axis label for plots.  One element per plane.
;
;      `psym`:  Sets the plotting symbol for plots.  One element per plane.
;
;      `nsum`:  See OPLOT.  One element per plane.
;
;      `*lights`:
;               List of bodies to use as light sources.  Default is 'SUN'.
;
;      `*overlays`:
;               List of initial overlays to compute on startup.  Each element
;               is of the form::
;
;                          type[:name1,name2,...][/key1=val1/key2=val2/...]
;
;               where 'type' is one of {limb, terminator, center,
;               star, ring, planet_grid, array, station, shadow, reflection}
;               and the names identify the name of the desired object.  The 
;               keys and vals correspond to fields in the overlay structure 
;               and may be used to override the defaults.  Note that GRIM will 
;               load more objects than named if required by another startup 
;               overlay.  For example::
;
;                        overlays='ring:a_ring'
;
;               will cause only one ring descriptor to load, whereas::
;
;                        overlays=['limb:saturn', 'ring:a_ring']
;
;               will cause all of Saturn's rings to load because they are
;               required in computing the limb points (for hiding).
;
;               Different results may be obtained using translator keywords,
;               because those keywords are evaluated at the translator level.
;               For example::
;
;                        overlays='ring:fn54'
;
;               may result in no ring, while::
;
;                        overlays='ring', rng_trs='name=fn54'
;
;               would be more likely to yield a ring.  In the former example,
;               the specified name is compared against whatever default ring
;               descriptors are returned by the tranlators, while in the latter
;               case, the 'name' translator keyword is compared against all
;               rings available to the translator.
;
;               Also note that the ordering is significant.  For example:
;
;                        overlays=['planet_grid:EARTH,MOON', $
;                                  'terminator:MOON', $
;                                  'shadow:MOON']
;
;		produces a different result than:
;
;                        overlays=['terminator:MOON', $
;                                  'shadow:MOON'
;                                  'planet_grid:EARTH,MOON']
;
;		To override an overlay parameters, use:
;
;                        overlays=['limb:color=white']
;                        overlays=['limb:jupiter/color=white/psym=1']
;                        etc.
;
;      `*exclude_overlays`:
;               Specifies overlays to exclude.  Syntax is the same for the ,
;               overlays keyword except keyword=value pairs are ignored.
;               If only a name or names are specified (i.e., no overlay type),
;               then all overlays with that name are excluded.  Note that the
;               exclusions are not implemented until after the overlays have 
;               been computed, so exclusions do not reduce processing.  The,
;               specified exclusions apply for the entire GRIM session.
;
;      `*delay_overlays`:
;               If set, initial overlays (see 'overlays' above) are not computed
;               until the first time they are accessed.  This option can greatly
;               improve performance in cases where a large number of image planes
;               are loaded with initial overlays, particularly if it is not
;               expected that all planes will necesarily be viewed or otherwise
;               accessed.  Typically this option will cause overlays to be
;               computed only for the initially visible planes, with other
;               planes loading overlays only as they are made visible.  However,
;               there may be other cirumstances that can cause initial overlays
;               to be loaded without actually viewing a plane.
;
;      `*settings_overlays`:
;               Structure giving initial overlay settings.  Fields are as 
;               follows:
;
;                name    : Name of overlay type.  If not present, all types are 
;                          affected.
;                color   : String giving overlay color.
;                shade   : Float giving color shade.
;                psym    : Plotting symbol.
;                symsize : Symbol size.
;                tlab    : Label toggle.
;                tshade  : Shading toggle.
;
;      `*activate`:
;               If set, inital overlay are activated.
;
;      `*ndd`:  Sets the global ndd value in the OMINAS state structure, which
;               controls the maximum number of data descriptors with maintain == 
;               1 to keep in memory at any given time
;
;      `*render_sampling`:
;               Over-sampling value for rendering.
;
;      `*render_numbra`:
;               Number of random rays to trace to light sources when rendering.
;
;      `*render_minimum`:
;               Minimum value (percent) to assign to photometric output in 
;               renderings.
;
;      `*render_rgb`:
;               If set, renderings are done in color if the source has color
;		color planes.  Default is off.
;
;      `*render_current`:
;               If set, the rendering source is the image on this plane rather 
;		a map.  Default is off.
;
;      `*render_spawn`:
;               If set, renderings from an image (as opposed to a rendering) are 
;		placed on a new plane.  Default is on, except for rendering 
;               planes.
;
;      `*render_sky`:
;               If set, the sky is included in the rendering.  Default is off.
;
;      `*render_auto`:
;               If set, automatically render whenever there is an object event. 
;               Default is off, though note that rendering planes always 
;		automatically re-render.
;
;      `*rendering`:
;               If set, perform a rendering on the initial descriptor set.
;
;      `*guideline`:
;               If set, the guideline is turned on at startup.
;
;
;
;  OUTPUT:
;  -------
;      None
;
;
;  GRIM Resource File
;  ------------------
;       The keywords marked above with an asterisk may be overridden using
;       the file $HOME/.ominas/grimrc.  Keyword=value pairs may be entered, one 
;       per line, using the same syntax as if the keyword were entered on the 
;       IDL command line to invoke GRIM.  Lines beginning with '#' are ignored.
;       Keywords entered in the resource file override the default values, and
;       are themselves overridden by keywords entered on the command line.
;
;  Shell Interface
;  ---------------
;       The `grim` alias may be used to start GRIM from the shell prompt.  
;       The shell interface accepts all keywords marked with an asterisk
;       above.  See grim.bat.
;
;       Example::
;
;            % grim -beta data/*.img overlay=center,limb:JUPITER
;
;
;  Environment Variables
;  ---------------------
;       GRIM currently defines no environment variables..
;
;
;  Common Blocks
;  -------------
;        grim_block:
;         Keeps track of most recent GRIM instance and which ones are
;         selected.
;
;
;  Side Effects
;  ------------
;       GRIM operates directly on the memory images of the descriptors that
;       it is given.  Therefore, those descriptors are modified during
;       a session.  This architecture allows data to be operated on concurrently
;       through GRIM and from the command line; see grift.pro for details.
;
;
;  Layout
;  ------
;       The philosphy that drives GRIM's layout is that the maximum possible
;       screen space should be devoted to displaying the data.  This policy
;       allows for many GRIM windows to be used simultaneously without being
;       obscured by crazy control panels full of buttons, gadgets, widgets,
;       doodads, whirly-gigs, and what-nots.  The GRIM layout consists of the
;       following items:
;
;            Title bar
;            ~~~~~~~~~
;               The title bar displays the GRIM window number (grn), the tag
;               (if any), the current plane number (pn), the total number of 
;               planes, the core name field of the data descriptor for the 
;               current plane, the default title (if given; see the title 
;               keyword above), and a string indicating which RGB channels are 
;               associated with the current plane.
;
;            Menu bar
;            ~~~~~~~~
;               Most of GRIM's functionality is accessed through the
;               system of pulldown menus at the top.  Individual menu
;               items are described in their own sections.
;
;            Shortcut buttons
;            ~~~~~~~~~~~~~~~~
;               Some commonly used menu options are duplicated as shortcut
;               buttons arranged horizontally just beneath the menu bar.  The
;               function of each button is displayed in the status bar (see
;               below) when the mouse cursor is hovered over the button.
;
;      Cursor mode buttons
;      ~~~~~~~~~~~~~~~~~~~
;               Cursor mode shortcut buttons are arranged vertically along the
;               left side of the GRIM window, and are provided as shortcuts
;               for the corresponding options in the Mode menu.  The following
;               modes are available:
;
;                  Activate:
;                       In activate mode, overlay objects may be activated
;                       or deactivated by clicking and/or dragging using the
;                       left or right mouse buttons respectively.  This
;                       activation mechanism allows the user to select which
;                       among a certain type of objects should be used in a
;                       given menu selection.  A left click on an overlay
;                       activates that overlay and a right click deactivates
;                       it.  A double click activates or deactivates all
;                       overlays associated with a given descriptor, or all
;                       stars.  Active overlays appear in the colors selected
;                       in the 'Overlay Settings' menu selection.  Inactive
;                       overlays appear in gray.  A descriptor is active
;                       whenever any of its overlays are active.
;
;                  Zoom:The zoom button puts GRIM in a zoom cursor mode, wherein
;                       the image zoom and offset are controlled by selecting
;                       a box in the image.  When the box is created using the
;                       left mouse button, zoom and offset are changed so that
;                       the contents of the box best fill the current graphics
;                       window.  When the right button is used, the contents of
;                       the current graphics window are shrunken so as to best
;                       fill the box.  In other words, the left button zooms in
;                       and the right button zooms out.
;
;                  Pan: The pan button puts GRIM in a pan cursor mode, wherein 
;                       the image offset is controlled by selecting an offset 
;                       vector using the left mouse button.  The middle button 
;                       may be used to center the image on a selected point.
;
;                  Pixel Readout:
;                       In pixel readout mode, a text window appears
;                       and displays data about the pixel selected
;                       using the left mouse button.
;
;                  Tiepoint:
;                       In tiepoint mode, tiepoints are added using the
;                       left mouse button and deleted using the right button.
;                       Tiepoints appear as crosses identified by numbers.
;                       The use of tiepoints is determined by the particular
;                       option selected by the user.
;
;                  Curve:
;                       In curve mode, curves are added using the
;                       left mouse button and deleted using the right button.
;                       Curves appear as red lines identified by numbers at
;                       each end.  The use of curves is determined by the
;                       particular option selected by the user.
;
;                  Mask:
;                       GRIM maintains a mask for each plane whose use is
;                       appication-dependent.  Mask mode allows pixels in the
;                       mask to be toggled on and off.
;
;                  Magnify:
;                       In magnify mode, image pixels in the graphics
;                       window may be magnifed using either the right or left
;                       mouse buttons.  The left button magnifies the displayed
;                       pixels, directly from the graphics window.  The right
;                       button magnifies the data itself, without the overlays.
;
;                  XY Zoom:
;                       Same as 'zoom' above, except the aspect ratio is
;                       set by the proportions of the selected box.
;
;                  Remove overlays:
;                       Allows the user to remove overlay arrays.
;
;                  Trim overlays:
;                       Allows the user to trim points from overlay arrays.
;
;                  Select within overlays:
;                       Allows the user to select points within overlay arrays.
;
;                  Define Region:
;                       Allows the user to define GRIM's region of interest.
;
;                  Smooth:
;                       Allows the user to select a smoothing box to be applied
;                       to the data array.
;
;                  Select Plane:
;                       Allows the user to change planes using the pointer.
;                       This option is only useful in cases where multiple
;                       planes are displayed.
;
;                  Drag Image:
;                       Allows the user to reposition the current plane by
;                       clicking and dragging.
;
;                  Target:
;                       Allows the user to re-target the camera by clicking.
;
;                  Navigate:
;                       Allows the user to modify the camera position and
;                       orientation using the mouse.
;
;
;            Graphics window
;            ~~~~~~~~~~~~~~~
;               The graphics window displays the data associated with the
;               given data descriptor using the current zoom, offset, and
;               display order.  The edges of the data are indicated by a dotted
;               line.  The camera optic axis is indicated by a large red cross.
;
;            Pixel readout
;            ~~~~~~~~~~~~~
;               The cursor position and corresponding data value are are
;               displayed beneath the graphics window, next to the message line.
;
;            Message line
;            ~~~~~~~~~~~~
;               The message line displays short messages pertaining GRIM's
;               current state or button functions.
;
;  Callback Procedures
;  -------------------
;       GRIM callback procedures are called with one or two arguments:
;       the first argument is a pointer to data that was provided
;       when the callback was added.  The second argument, if present, depends
;       on the applicatation.
;
;
;  X Resource Names
;  ----------------
;       The following X-windows resource names apply to GRIM's widgets::
; 
;        grim_base:           top level base
;        grim_mbar:           menu bar
;        grim_shortcuts_base: base containing shortcut buttons
;        grim_modes_base:     base containing modes buttons
;        grim_draw:           GRIM draw widget
;        grim_label:          GRIM bottom label widget
;
;       To turn off the confusing higlight box around the modes buttons,
;       put the following line in your ~/.Xdefaults file::
;
;            Idl*grim_modes_base*highlightThickness:  0
;
;       Shortcut buttons also have resource names that may be used to define
;       keyboard shortcuts (search grim.pro file for "resource_name=" to find
;       the names for each button.  
;
;       Each menu option has a corresponding resource name given by its 
;	event procedure name; see grim_menu_desc in grim.pro and 
;       grim_default_menus in grim_default_menus.pro.
;
;       Default definitios may be found in .ominas/Xdefaults-grim.
;
;
;  Operation
;  ---------
;       GRIM displays 1-, 2-, and 3-dimensional data sets.  1-dimensional
;       data arrays are displayed as plots.  In that case, the abscissa is
;       the sample number unless the data descriptor contains an abscissa.
;       Some functionality is not available when working with plots.  2- and 
;       3-dimensional arrays are displaye as image planes.  The only
;       difference between images and cubes in GRIM is that images planes
;       each have their own data descriptor, while cubes are represented by
;       multiple image planes that share a common data descriptor; each plane
;       in a cube corresponds to a unique offset in the data array stored in
;       the common data descriptor.  
;
;       GRIM requests only the data samples needed for the current viewing
;       parameters.  Therefore, GRIM can display data sets of arbitrary size
;       when used with a file reader that supports subsampling.  However, note
;       that specific menu options may request the entire data array, depending
;       on the application.
;
;       Each GRIM instance may contain any number of planes as well as
;       associated geometric data (i.e. object descriptors) and overlay arrays
;       for displaying various geometric objects -- limbs, rings, stars, etc.
;       An array of user overlay points is maintained to be used for application-
;       specific purposes.  Generally, a set of overlay points or a descriptor
;       must be activated in order to be used as input to a menu item; see
;       activate mode above.
;
;       There are exclusive and non-exclusive mechanisms for selecting GRIM
;       windows.  GRIM windows may be non-exclusively selected using the select
;       mode button mentioned above (upper-left corner).  The exclusive
;       selection mechanism consists of a "primary" GRIM window, indicated by
;       a red outline in the graphics window.  The primary selection is
;       changed by pressing any mode or shortcut button, or by clicking in
;       the graphics area of the desired GRIM window.  The meaning of the
;       various selections depends on the application.
;
;       The functions of the left and right mouse buttons are determined by the
;       cursor mode; some cursor modes define modifier keys to broaden the number
;       of functions available in that mode.  The middle mouse button toggles
;       the activation state of overlay arrays, or allows the image to be panned
;       if no overlay appears beneath the cursor.  The mouse wheel cycles among 
;       cursor modes, or zooms about the cursor position if the control key is 
;       held down.
;
;       Objects maintained by GRIM are accessible via the GRIFT interface,
;       for example::
;
;            IDL> grift, dd=dd, cd=cd, pd=pd, limb_ptd=limb_ptd
;
;       returns the data desciptor, camera descriptor, planet descriptors,
;       and limb points associated with the current plane.
;
;       GRIM registers event handlers for all of its objects, so the window
;       is updated any time an object is modifed, whether by GRIM or by some
;       other program, or from the command line.
;
;
;       :Examples:
; 
;            (1) To create a new GRIM instance with no data::
;
;                  IDL> grim, /new
;
;            (2) To create a new GRIM instance with data from a file of name
;                "filename"::
;
;                  IDL> dd = dat_read(filename)
;                  IDL> grim, dd
;
;                        or::
;
;                  IDL> grim, filename
;
;            (3) To give an existing GRIM instance a new camera descriptor::
;
;                  IDL> grim, cd=cd
;
;
;  Known bugs
;  ----------
;       Window resizing is not precise.  GRIM tries to resize to the selected
;       size, but typically overshoots.  This is probably platform-dependent.
;
;       Objects inherited by rendering planes do not respond to events.
;
;       Image shifting:
;        -  Descriptors not updated if shift performed form another window
;           because the there's no way for the irst window to know to
;           update its descriptors
;              - fix wrap-around; clip instead
;
;       Plane->Coregister does not update descriptors
;
;       Navigate mode gets weird when you do certain modifer key presses
;          --> maybe a conflict with <ctrl> wheel zoom action
;
;       Crashes occur with File->Close
;
;       /no_erase is not enabled for images, just plots.  Probably should fix
;       that.
;
;       Initial visibility setting does not seem to work until applied
;       using plane settings window.
;
;       /frame causes a crash if there are no initial overlays.
;
;       It's not clear whether the symsize keyword is actually used.
;
;       pn keyword does not function.
;
;       Crash when tiepoint syncing is on and tiepoint selected with
;       multiple planes.
;
;       Title keyword does not properly map multiple elements to multiple
;       planes.
;
;       Nsum keyword does not properly map multiple elements to multiple
;       planes.
;
;       Plane syncing appears to be incomplete and I don't remember what it
;       was supposed to be.  I'm sure it was awesome, though.
;
;       Not sure what slave_overlays keyword does, or was supposed to do.
;
;       Overlays on rendered planes do not respond to events
;
;       Menu toggles don't update propoerly in some circumsumstances.
;
;       grim_message sometimes pops up messages from nv_message, which can
;       be pretty obnxious.  This probably has to do with the calls to
;       grim_message in grim_compute.include
;
;       Overlay point selections are not retained after recomputing
;
;       Undo does not seem to be working reliably
;
;       Events on overlays copied to rendering planes do not function
;
;       The help menu is currently not working because it relied on the old
;       documentation system.
;
;       Navigation mode control is poor for the Shift-Right motion.
;
;	Target mode flips the camera orientation in the X direction.
;
;	File-> Save Postscript doesn't work right: the image order is
;	sometimes wrong, and the overlays don't line up.
;
;	Stars are not always correctly computed for wider fields of view.  
;
;
;
;  SEE ALSO
;  --------
;       `GRIFT`, `GRAFT`
;
;
; :History:
;   Written by: Spitale 7/2002
;
;-
;=============================================================================
@grim_bitmaps_include.pro
@grim_util_include.pro
@grim_planes_include.pro
@grim_data_include.pro
@grim_user_include.pro
@grim_compute_include.pro
@grim_overlays_include.pro

@grim_descriptors_include.pro
@grim_image_include.pro
@grim_menus_include.pro


;=============================================================================
; grim_constants
;
;=============================================================================
pro grim_constants
@grim_constants.common

 MAG_SIZE_DEVICE = 101				; must be odd
 MAG_SIZE_DATA = 21				; must be odd

 MAG_SIZE_DEVICE = 201				; must be odd
 MAG_SIZE_DATA = 41				; must be odd


 CONTEXT_SIZE = 100
 AXES_SIZE = 125

 SCALE_WIDTH = 10

 MARK_FRESH = 1b
 MARK_STALE = 2b
end
;=============================================================================



;=============================================================================
; grim_resize
;
;=============================================================================
pro grim_resize, grim_data, base_xsize, base_ysize, init=init

 ;-------------------------
 ; get current info
 ;-------------------------
 base_geom = widget_info(grim_data.base, /geom) 
 sub_base_geom = widget_info(grim_data.sub_base, /geom) 
 modes_base_geom = widget_info(grim_data.modes_base, /geom) 
 draw_geom = widget_info(grim_data.draw, /geom) 
 shortcuts_base_geom = widget_info(grim_data.shortcuts_base, /geom) 
 label_geom = widget_info(grim_data.label, /geom) 
 xy_label_geom = widget_info(grim_data.xy_label, /geom) 
 mbar_geom = widget_info(grim_data.mbar, /geom) 

 mbar_height = widget_get_mbar_height()

 ;-------------------------
 ; set  sizes
 ;-------------------------
 if(NOT keyword_set(base_xsize)) then $
                  base_xsize = base_geom.xsize + 2*base_geom.margin
 if(NOT keyword_set(base_ysize)) then $
                  base_ysize = base_geom.ysize + 2*base_geom.margin

 sub_base_xsize = sub_base_geom.xsize + 2*sub_base_geom.margin
 sub_base_ysize = sub_base_geom.ysize + 2*sub_base_geom.margin

 modes_base_xsize = modes_base_geom.xsize + 2*modes_base_geom.margin
 modes_base_ysize = modes_base_geom.ysize + 2*modes_base_geom.margin

 shortcuts_base_ysize = shortcuts_base_geom.ysize + 2*shortcuts_base_geom.margin

 label_xsize = label_geom.xsize + 2*label_geom.margin
 label_ysize = label_geom.ysize + 2*label_geom.margin

 draw_xsize = base_xsize - modes_base_xsize
 draw_ysize = base_ysize - label_ysize - mbar_height - shortcuts_base_ysize

 widget_control, grim_data.draw_base, $
	scr_xsize=draw_xsize, scr_ysize=draw_ysize
 widget_control, grim_data.draw, $
	scr_xsize=draw_xsize, scr_ysize=draw_ysize
; widget_control, grim_data.modes_base, $
;	scr_xsize=modes_base_xsize
;	scr_ysize=base_ysize - label_ysize - mbar_height - shortcuts_base_ysize
 widget_control, grim_data.label, scr_xsize=base_xsize - xy_label_geom.xsize




; draw_geom = widget_info(grim_data.draw, /geom) 
; draw_xsize = draw_geom.xsize
; draw_ysize = draw_geom.ysize

 ;-------------------------
 ; modify pixmap
 ;-------------------------
 pixmap = grim_data.pixmap

 wnum = !d.window
 window, /free, /pixmap, xsize=draw_xsize, ysize=draw_ysize
 grim_data.pixmap = !d.window

 if(pixmap NE -1) then $
  begin
   device, copy=[0,0, draw_xsize-1,draw_ysize-1, 0,0, wnum]
   wdelete, pixmap
  end
 wset, wnum


 ;-------------------------
 ; modify redraw pixmap
 ;-------------------------
 redraw_pixmap = grim_data.redraw_pixmap

 wnum = !d.window
 window, /free, /pixmap, xsize=draw_xsize, ysize=draw_ysize
 grim_data.redraw_pixmap = !d.window

 if(redraw_pixmap NE -1) then $
  begin
   device, copy=[0,0, draw_xsize-1,draw_ysize-1, 0,0, wnum]
   wdelete, redraw_pixmap
  end
 wset, wnum


 ;-------------------------
 ; modify overlay pixmap
 ;-------------------------
 overlay_pixmap = grim_data.overlay_pixmap

 wnum = !d.window
 window, /free, /pixmap, xsize=draw_xsize, ysize=draw_ysize
 grim_data.overlay_pixmap = !d.window

 if(overlay_pixmap NE -1) then $
  begin
   device, copy=[0,0, draw_xsize-1,draw_ysize-1, 0,0, wnum]
   wdelete, overlay_pixmap
  end
 wset, wnum



 ;-------------------------
 ; modify guideline pixmap
 ;-------------------------
 if(keyword_set(grim_data.guideline_pixmaps[0])) then $
                                     wdelete, grim_data.guideline_pixmaps[0]
 window, /free, xsize=draw_xsize, ysize=1, /pixmap
 grim_data.guideline_pixmaps[0] = !d.window


 if(keyword_set(grim_data.guideline_pixmaps[1])) then $
                                     wdelete, grim_data.guideline_pixmaps[1]
 window, /free, xsize=1, ysize=draw_ysize, /pixmap
 grim_data.guideline_pixmaps[1] = !d.window
 wset, wnum


 grim_data.base_xsize = base_geom.xsize
 grim_data.base_ysize = base_geom.ysize


 grim_set_data, grim_data, grim_data.base
 if(NOT keyword_set(init)) then grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
; grim_set_tracking
;
;=============================================================================
pro grim_set_tracking, grim_data

 widget_control, grim_data.draw, draw_motion_events=grim_data.tracking
 widget_control, grim_data.context_draw, draw_motion_events=grim_data.tracking
 if(NOT grim_data.tracking) then $
       widget_control, grim_data.xy_label, set_value='Tracking off' $
 else widget_control, grim_data.xy_label, set_value='Tracking on'

end
;=============================================================================



;=============================================================================
; grim_set_ct
;
;=============================================================================
pro grim_set_ct, grim_data
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

 tvlct, *grim_data.tv_rp, *grim_data.tv_gp, *grim_data.tv_bp
 r_curr = *grim_data.tv_rp
 g_curr = *grim_data.tv_gp
 b_curr = *grim_data.tv_bp
end
;=============================================================================



;=============================================================================
; grim_set_mode
;
;=============================================================================
pro grim_set_mode, grim_data, mode, new=new, init=init, data_p=data_p

 if(keyword_set(mode)) then grim_data.mode = mode $
 else mode = grim_data.mode

 if(keyword_set(new)) then grim_set_primary, grim_data.base

 if(keyword_set(new) OR keyword_set(init)) then $
  begin
   wid = grim_data.modes_base
   repeat $
    begin
     wid = widget_info(wid+1, find_by_uname='mode')
     if(keyword_set(wid)) then $
      begin
       widget_control, wid, get_uvalue=name
       if(size(name, /type) NE 7) then name = name.name
       if(name EQ mode) then widget_control, wid, sensitive=0 $
       else widget_control, wid, sensitive=1
      end
    endrep until(wid EQ 0)
  end

 if(keyword_set(data_p)) then grim_data.mode_data_p = data_p

 swap = grim_get_cursor_swap(grim_data)

 cursor_modes = *grim_data.cursor_modes_p
 data_p = 0
 if(keyword_set(cursor_modes)) then $
  begin
   names = cursor_modes.name
   w = where(names EQ mode)
   if(w[0] NE -1) then $
    begin
     data_p = cursor_modes[w].data_p
     grim_data.mode_data_p = data_p
    end
  end

 call_procedure, mode + '_mode', grim_data, data_p


end
;=============================================================================



;=============================================================================
; grim_kill_notify
;
;=============================================================================
pro grim_kill_notify, top
@grim_block.include

 grim_data = grim_get_data(top, /dead)

 if(grim_data.pixmap NE -1) then wdelete, grim_data.pixmap
 if(grim_data.redraw_pixmap NE -1) then wdelete, grim_data.redraw_pixmap
 if(grim_data.overlay_pixmap NE -1) then wdelete, grim_data.overlay_pixmap

 for i=0, grim_data.n_planes-1 do $
  begin
   plane = grim_get_plane(grim_data, pn=i)
   cd = grim_xd(plane, /cd)
   pd = grim_xd(plane, /pd)
   rd = grim_xd(plane, /rd)
   sd = grim_xd(plane, /sd)
   ltd = grim_xd(plane, /ltd)
   std = grim_xd(plane, /std)
   ard = grim_xd(plane, /ard)

   nv_notify_unregister, plane.dd, 'grim_descriptor_notify'
   if(keyword_set(cd)) then nv_notify_unregister, cd, 'grim_descriptor_notify'
   if(keyword_set(pd)) then nv_notify_unregister, pd, 'grim_descriptor_notify'
   if(keyword_set(rd)) then nv_notify_unregister, rd, 'grim_descriptor_notify'
   if(keyword_set(sd)) then nv_notify_unregister, sd, 'grim_descriptor_notify'
   if(keyword_set(std)) then nv_notify_unregister, std, 'grim_descriptor_notify'
   if(keyword_set(ard)) then nv_notify_unregister, ard, 'grim_descriptor_notify'
   if(keyword_set(ltd)) then nv_notify_unregister, ltd, 'grim_descriptor_notify'

;;;
   nv_ptr_free, [plane.skd_p, plane.cd_p, plane.pd_p, plane.rd_p, plane.sd_p, plane.std_p, $
             plane.ard_p, plane.ltd_p, plane.od_p, *plane.overlay_ptdps, $
             plane.user_ptd_tlp]
  end

 nv_ptr_free, [grim_data.rf_callbacks_p, grim_data.rf_callbacks_data_pp, $
           grim_data.planes_p, grim_data.pl_flags_p, $
           grim_data.menu_ids_p, grim_data.menu_desc_p]

 grim_grn_destroy, grim_data.grn

 w = where(_all_tops EQ top)
 _all_tops = rm_list_item(_all_tops, w[0], only=0)
 if(keyword_set(_all_tops[0])) then $
                    grim_set_primary, _all_tops[n_elements(_all_tops)-1]

end
;=============================================================================



;=============================================================================
; grim_modes_list
;
;=============================================================================
function grim_modes_list, grim_data

 base = grim_data.modes_base
 repeat $
  begin
   id = widget_info(base, /child)
   repeat $
    begin
     widget_control, id, get_uvalue=name
     if(size(name, /type) EQ 8) then name = name.name
     modes = append_array(modes, name)
     id = widget_info(id, /sibling)
    endrep until(id EQ 0)
   base = widget_info(base, /sibling)
  endrep until(base EQ 0)

 return, modes
end
;=============================================================================



;=============================================================================
; grim_interrupt_begin
;
;=============================================================================
pro grim_interrupt_begin, grim_data, plane=plane
common grim_interrupt_block, base

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ;------------------------------------------
 ; save the current state
 ;------------------------------------------
; data = ...

 ;------------------------------------------
 ; open the interrupt dialog
 ;------------------------------------------
 _base = dialog_interrupt(callback='grim_interrupt_callback', data=data)
 if(_base NE -1) then base = _base

end
;=============================================================================



;=============================================================================
; grim_interrupt_end
;
;=============================================================================
pro grim_interrupt_end, grim_data, plane=plane
common grim_interrupt_block, base

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ;------------------------------------------
 ; destroy the interrupt dialog
 ;------------------------------------------
 widget_control, base, /destroy


end
;=============================================================================



;=============================================================================
; grim_erase_guideline
;
;=============================================================================
pro grim_erase_guideline, grim_data

 x = grim_data.guideline_save_xy[0]
 y = grim_data.guideline_save_xy[1]

 if(x LT 0) then return

 device, copy=[0,0, !d.x_size,1, 0,y, grim_data.guideline_pixmaps[0]]
 device, copy=[0,0, 1,!d.y_size, x,0, grim_data.guideline_pixmaps[1]]

end
;=============================================================================



;=============================================================================
; grim_draw_guideline
;
;=============================================================================
pro grim_draw_guideline, grim_data, x, y

 ;--------------------------------------
 ; save window regions
 ;--------------------------------------
 wnum = !d.window
 wset, grim_data.guideline_pixmaps[0]
 device, copy=[0,y, !d.x_size,1, 0,0, wnum]
 wset, grim_data.guideline_pixmaps[1]
 device, copy=[x,0, 1,!d.y_size, 0,0, wnum]
 wset, wnum
 grim_data.guideline_save_xy = [x,y]

 ;--------------------------------------
 ; draw guidelines
 ;--------------------------------------
 line = 0
 color = ctred()
 plots, [0,!d.x_size], [y, y], line=line, /device, col=color
 plots, [x, x], [0,!d.y_size], line=line, /device, col=color

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_interrupt_callback
;
;=============================================================================
pro grim_interrupt_callback, data
 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ;------------------------------------------
 ; restore the old state
 ;------------------------------------------
;...

end
;=============================================================================



;=============================================================================
; grim_sampling_fn
;
;
;=============================================================================
function grim_sampling_fn, dd, source_image_pts_sample, data

 grim_data = grim_get_data()
 pos = cor_udata(dd, 'IMAGE_POS')
 if(NOT keyword_set(pos)) then return, source_image_pts_sample

 w = where(pos NE 0)
 if(w[0] EQ -1) then return, source_image_pts_sample

 xdim = dat_dim(dd)
 dim = size(source_image_pts_sample, /dim)
 n = n_elements(source_image_pts_sample)

 if(dim[0] NE 2) then $
         source_image_pts_sample = w_to_xy(xdim, source_image_pts_sample)
 n = n_elements(source_image_pts_sample)/2

 return, source_image_pts_sample - pos[0:1]#make_array(n, val=1d)
end
;=============================================================================



;=============================================================================
; grim_render_dim_fn
;
;
;=============================================================================
function grim_render_dim_fn, dd, dim_orig
 return, dim_orig
end
;=============================================================================



;=============================================================================
; grim_render_sampling_fn
;
;
;=============================================================================
function grim_render_sampling_fn, dd, source_image_pts_sample, source_image_pts_grid

 rdim = (dat_dim(dd, /true))[0:1]
 xdim = dat_dim(dd)

 dim = size(source_image_pts_sample, /dim)
 n = n_elements(source_image_pts_sample)

 if(dim[0] NE 2) then $
         source_image_pts_sample = w_to_xy(xdim, source_image_pts_sample)
 n = n_elements(source_image_pts_sample)/2

 render_image_pts_grid = gridgen(rdim, /rec, /double)

 xx = interpol(render_image_pts_grid[0,*,0], source_image_pts_grid[0,*,0], source_image_pts_sample[0,*])
 yy = interpol(render_image_pts_grid[1,0,*], source_image_pts_grid[1,0,*], source_image_pts_sample[1,*])

 render_image_pts_sample = round([xx,yy])
 w = where((render_image_pts_sample[0,*] LT 0) $
              OR render_image_pts_sample[0,*] GE rdim[0] $)
              OR render_image_pts_sample[1,*] LT 0 $
              OR render_image_pts_sample[1,*] GE rdim[1])

 samples = xy_to_w(rdim, render_image_pts_sample)

; w = where((samples LT 0) OR (samples GT n))

 if(w[0] NE -1) then samples[w] = -1

 return, samples
end
;=============================================================================



;=============================================================================
; grim_draw_vectors
;
;=============================================================================
pro grim_draw_vectors, cd, curves_ptd, points_ptd, user_ptd

 if(obj_valid(curves_ptd)) then $
  begin
   p = inertial_to_image_pos(cd, pnt_vectors(curves_ptd, /visible))
   pg_draw, reform(p), psym=3, col=ctgreen()
  end

 if(obj_valid(points_ptd)) then $
  begin
   p = inertial_to_image_pos(cd, pnt_vectors(points_ptd, /visible))
   pg_draw, reform(p), psym=1, col=ctgreen()
  end

 if(obj_valid(user_ptd)) then $
  begin
   p = inertial_to_image_pos(cd, pnt_vectors(user_ptd, /visible))
   pg_draw, reform(p), psym=3, col=ctgreen(0.5)
  end

end
;=============================================================================



;=============================================================================
; grim_increment_mode
;
;=============================================================================
pro grim_increment_mode, grim_data, dm

 modes = grim_modes_list(grim_data)
 nmodes = n_elements(modes)
 w = where(modes EQ grim_data.mode)
 ww = (w + dm)
 if(ww[0] LT 0) then ww = ww + nmodes 
 ww = ww mod nmodes
 grim_set_mode, grim_data, modes[ww[0]], /new

end
;=============================================================================



;=============================================================================
; grim_event
;
;=============================================================================
pro grim_event, event

 grim_data = grim_get_data(event.top)

 ;-----------------------------------
 ; for now, assume a resize event
 ;-----------------------------------
 grim_resize, grim_data, event.x, event.y

end
;=============================================================================



;=============================================================================
; grim_update_guideline
;
;=============================================================================
pro grim_update_guideline, grim_data, plane, x, y

 if(grim_data.guideline_flag) then $
  begin
   grim_erase_guideline, grim_data
   grim_draw_guideline, grim_data, x, y
  end

end
;=============================================================================



;=============================================================================
; grim_update_xy_label
;
;=============================================================================
pro grim_update_xy_label, grim_data, plane, x, y

 p = (convert_coord(double(x), double(y), /device, /to_data))[0:1]
 xx = str_pad(strtrim(p[0],2), 6)
 yy = str_pad(strtrim(p[1],2), 6)

 dn = ''
 dim = dat_dim(plane.dd)
 if(n_elements(dim) EQ 1) then dim = [dim, 1]

 ;- - - - - - - - - -  - - - 
 ; plot
 ;- - - - - - - - - -  - - - 
 if(grim_data.type EQ 'PLOT') then $
  begin
   if((p[0] GE 0) AND (p[0] LT dim[1])) then $
 			     dn = dat_data(plane.dd, sample=[1,p[0]], /nd)
  end $
 ;- - - - - - - - - -  - - - 
 ; image
 ;- - - - - - - - - -  - - - 
 else $
  begin
   p = round(p)
   if((p[0] GE 0) AND (p[0] LT dim[0]) AND $
      (p[1] GE 0) AND (p[1] LT dim[1])) then $
               dn = grim_get_image(grim_data, plane=plane, sample=p, /nd)
  end

 if(size(dn, /type) EQ 1) then dn = fix(dn)
 dn = strtrim(string(dn, format='(g10.4)'),2)
 widget_control, grim_data.xy_label, $
 			     set_value='(' + xx + ',' + yy + '): ' + dn

end
;=============================================================================



;=============================================================================
; grim_scroll
;
;=============================================================================
pro grim_scroll, grim_data, plane, clicks, modifiers

 ;- - - - - - - - - - - - - - - - -
 ; No modifier -- change mode 
 ;- - - - - - - - - - - - - - - - -
 if(NOT keyword_set(modifiers)) then $
  begin
   dm = - clicks
   grim_increment_mode, grim_data, dm
   grim_set_data, grim_data;, event.top
  end $
 ;- - - - - - - - - - - - - - - - -
 ; Ctrl -- change zoom 
 ;- - - - - - - - - - - - - - - - -
 else if(modifiers EQ 2) then $
  begin
   dm = double(clicks)
   factor = 2d^dm
   offset = grim_zoom_to_cursor(grim_data, factor, /relative, zoom=zoom)
   grim_refresh, grim_data, zoom=zoom, offset=offset
  end 

end
;=============================================================================



;=============================================================================
; grim_middle
;
;=============================================================================
pro grim_middle, grim_data, plane, id, x, y, press, clicks, modifiers, output_wnum

 if(press NE 2) then return

 if(grim_data.type EQ 'PLOT') then $
  begin
   xx = convert_coord(/data, /to_device,$
              [transpose(double(plane.xrange)), transpose(double(plane.yrange))])
   edge = [xx[0]+2, !d.x_size-xx[3]-1, xx[1]+2, !d.y_size-xx[4]-1]
   tvpan, wnum=input_wnum, /notvim, edge=edge, $
        	    p0=[x,y], cursor=60, hour=id, $
        	    output=output_wnum, col=ctred(), doffset=doffset
   grim_wset, grim_data, output_wnum
   grim_refresh, grim_data, doffset=doffset
  end $
 else $
  begin
   grim_activate_select, /point, /invert, grim_data, plane, [x,y], stat=stat
   if(stat NE -1) then $
    begin
     grim_refresh, grim_data, /noglass, /no_image
    end $
   else $
    begin
     tvpan, wnum=input_wnum, /noplot, edge=3, $
        	    p0=[x,y], cursor=60, hour=id, $
        	    output=output_wnum, col=ctred()
     grim_wset, grim_data, output_wnum
     grim_refresh, grim_data
    end
  end 
 grim_set_mode, grim_data


end
;=============================================================================



;=============================================================================
; grim_draw_event
;
;=============================================================================
pro grim_draw_event, event

 widget_control, event.id, get_value=value
 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, event.id, get_value=input_wnum
 output_wnum = grim_data.wnum

 struct = tag_names(event, /struct)
 
 if(NOT grim_test_motion_event(event)) then grim_set_primary, grim_data.base
; grim_set_primary, grim_data.base


 ;======================================
 ; jumpto droplist 
 ;======================================
 widget_control, grim_data.jumpto_droplist, get_value=val
 p = strpos(val[0], ':')
 if(p[0] NE -1) then grim_update_jumpto_droplist, grim_data


 ;======================================
 ; motion event 
 ;======================================
 if(struct EQ 'WIDGET_DRAW') then if(event.type EQ 2) then $
  begin
   grim_update_xy_label, grim_data, plane, event.x, event.y
   grim_update_guideline, grim_data, plane, event.x, event.y
  end


 ;===================================
 ; middle button and scroll wheel
 ;===================================
 case struct of
  'WIDGET_DRAW' : $
   case event.type of
    ;- - - - - - - - - - - - - - - - -
    ; scroll wheel -- zoom / mode
    ;- - - - - - - - - - - - - - - - -
    7 : grim_scroll, grim_data, plane, event.clicks, event.modifiers

    ;- - - - - - - - - - - - - - - - -
    ; middle button -- pan / activate
    ;- - - - - - - - - - - - - - - - -
    0 : grim_middle, grim_data, plane, $
           event.id, event.x, event.y, $
           event.press, event.clicks, event.modifiers, output_wnum

    else : 
   endcase

  else : 
 endcase


 ;===================================
 ; cursor modes
 ;===================================
 data = 0
 if(keyword_set(grim_data.mode_data_p)) then data = *grim_data.mode_data_p
 call_procedure, grim_data.mode + '_mouse_event', event, data
 *grim_data.mode_data_p = data


 grim_wset, grim_data, grim_data.wnum
 grim_set_mode, grim_data

end
;=============================================================================



;=============================================================================
; grim_rewind_event
;
;=============================================================================
pro grim_rewind_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'First plane'
   return
  end


 ;---------------------------------------------------------
 ; switch to previous plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_change_plane, grim_data, /first

end
;=============================================================================



;=============================================================================
; grim_previous_event
;
;=============================================================================
pro grim_previous_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Previous plane'
   return
  end


 ;---------------------------------------------------------
 ; switch to previous plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_change_plane, grim_data, /previous

end
;=============================================================================



;=============================================================================
; grim_jumpto_event
;
;=============================================================================
pro grim_jumpto_event, event

 grim_data = grim_get_data(event.top)

 ;-------------------------------------------------------------------
 ; if tracking event, print usage info and toggle names in droplist
 ;-------------------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
;print,event.enter
;cursor, x, y, /nowait
;print, !mouse.button
;stop
   if(event.enter) then grim_print, grim_data, 'Jump to plane'
;   grim_update_jumpto_droplist, grim_data, names=event.enter
   grim_update_jumpto_droplist, grim_data, /names
   return
  end

 ;---------------------------------------------------------
 ; jump to new plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base

 if(keyword_set(grim_data.jumpto_droplist)) then widget_control, grim_data.jumpto_droplist, get_value=pns
 if(keyword_set(grim_data.jumpto_combobox)) then widget_control, grim_data.jumpto_combobox, get_value=pns
 pn = pns[event.index]

 valid = grim_jumpto(grim_data, pn)
 if(valid) then grim_refresh, grim_data, /no_erase
end
;=============================================================================



;=============================================================================
; grim_next_event
;
;=============================================================================
pro grim_next_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Next plane'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_change_plane, grim_data, /next

end
;=============================================================================



;=============================================================================
; grim_fastforward_event
;
;=============================================================================
pro grim_fastforward_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Last plane'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_change_plane, grim_data, /last

end
;=============================================================================



;=============================================================================
; grim_crop_event
;
;=============================================================================
pro grim_crop_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Crop data to view'
   return
  end


 ;---------------------------------------------------------
 ; crop data
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_crop_plane, grim_data, plane

end
;=============================================================================



;=============================================================================
; grim_refresh_event
;
;=============================================================================
pro grim_refresh_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Refresh'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_refresh, grim_data


end
;=============================================================================



;=============================================================================
; grim_entire_event
;
;=============================================================================
pro grim_entire_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'View entire image'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /entire


end
;=============================================================================



;=============================================================================
; grim_view_previous_event
;
;=============================================================================
pro grim_view_previous_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Previous view'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /previous


end
;=============================================================================



;=============================================================================
; grim_colors_event
;
;=============================================================================
pro grim_colors_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Modify color tables'
   return
  end


 ;---------------------------------------------------------
 ; open color tool
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_modify_colors, grim_data


end
;=============================================================================



;=============================================================================
; grim_settings_event
;
;=============================================================================
pro grim_settings_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Overlay settings'
   return
  end


 ;---------------------------------------------------------
 ; open settings dialog
 ;---------------------------------------------------------
 grim_overlay_settings, grim_data, plane


end
;=============================================================================



;=============================================================================
; grim_header_event
;
;=============================================================================
pro grim_header_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Edit image header'
   return
  end


 ;---------------------------------------------------------
 ; open header editor
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_edit_header, grim_data


end
;=============================================================================



;=============================================================================
; grim_notes_event
;
;=============================================================================
pro grim_notes_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Edit image notes'
   return
  end


 ;---------------------------------------------------------
 ; open notes editor
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_edit_dd_notes, grim_data, plane=plane


end
;=============================================================================



;=============================================================================
; grim_undo_event
;
;=============================================================================
pro grim_undo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
    begin
     grim_print, grim_data, 'Undo last data edit.'
    end
   return
  end


 ;---------------------------------------------------------
 ; undo last edit
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_undo, grim_data, plane



end
;=============================================================================



;=============================================================================
; grim_redo_event
;
;=============================================================================
pro grim_redo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
    begin
     grim_print, grim_data, 'Redo last data edit.'
    end
   return
  end


 ;---------------------------------------------------------
 ; redo last edit
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_redo, grim_data, plane



end
;=============================================================================



;=============================================================================
; grim_toggle_image_event
;
;=============================================================================
pro grim_toggle_image_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
    begin
     if(NOT plane.image_visible) then grim_print, grim_data, 'Unhide image' $
     else grim_print, grim_data, 'Hide image'
    end
   return
  end


 ;---------------------------------------------------------
 ; toggle image
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_toggle_image, grim_data, plane



end
;=============================================================================



;=============================================================================
; grim_toggle_image_overlays_event
;
;=============================================================================
pro grim_toggle_image_overlays_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
    begin
     if(NOT plane.image_visible) then s = 'Unhide image' $
     else s = 'Hide image'

     if(grim_data.hidden) then s = s + ' and unhide all overlays' $
     else s = s + ' and hide all overlays'

     grim_print, grim_data, s
    end
   return
  end


 ;---------------------------------------------------------
 ; toggle image
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_toggle_image_overlays, grim_data, plane



end
;=============================================================================



;=============================================================================
; grim_hide_event
;
;=============================================================================
pro grim_hide_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
    begin
     if(grim_data.hidden) then grim_print, grim_data, 'Unhide all overlays' $
     else grim_print, grim_data, 'Hide all overlays'
    end
   return
  end


 ;---------------------------------------------------------
 ; hide all overlays
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, grim_data.draw, /hourglass
 grim_hide_overlays, grim_data



end
;=============================================================================



;=============================================================================
; grim_tracking_event
;
;=============================================================================
pro grim_tracking_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Toggle cursor tracking on/off'
   return
  end


 ;---------------------------------------------------------
 ; toggle tracking flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 if(grim_data.tracking EQ 0) then grim_data.tracking = 1 $
 else grim_data.tracking = 0

 grim_set_data, grim_data, event.top

 grim_set_tracking, grim_data
end
;=============================================================================



;=============================================================================
; grim_grid_event
;
;=============================================================================
pro grim_grid_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Toggle RA/DEC grid on/off'
   return
  end


 ;---------------------------------------------------------
 ; toggle grid flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_data.grid_flag = NOT grim_data.grid_flag

 grim_set_data, grim_data, event.top
 if(grim_data.grid_flag) then grim_refresh, grim_data, /no_image $
 else grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
; grim_pixel_grid_event
;
;=============================================================================
pro grim_pixel_grid_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Toggle Pixel grid on/off'
   return
  end


 ;---------------------------------------------------------
 ; toggle grid flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_data.pixel_grid_flag = NOT grim_data.pixel_grid_flag

 grim_set_data, grim_data, event.top
 if(grim_data.pixel_grid_flag) then grim_refresh, grim_data, /no_image $
 else grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
; grim_guideline_event
;
;=============================================================================
pro grim_guideline_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Toggle guidelines on/off'
   return
  end


 ;---------------------------------------------------------
 ; toggle grid flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_data.guideline_flag = NOT grim_data.guideline_flag

 if(NOT grim_data.guideline_flag) then grim_erase_guideline, grim_data

 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
; grim_context_event
;
;=============================================================================
pro grim_context_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
       grim_print, grim_data, 'Open/Close image context window'
   return
  end $
 else if(NOT grim_test_motion_event(event)) then $
                                               grim_set_primary, grim_data.base

 ;----------------------------
 ; toggle the mapping state
 ;----------------------------
 grim_toggle_context, grim_data

end
;=============================================================================



;=============================================================================
; grim_axes_event
;
;=============================================================================
pro grim_axes_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Toggle axes on/off'
   return
  end


 ;---------------------------------------------------------
 ; toggle axes state
 ;---------------------------------------------------------
 grim_toggle_axes, grim_data

end
;=============================================================================



;=============================================================================
; grim_render_event
;
;=============================================================================
pro grim_render_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Generate new rendering'
   return
  end


 ;---------------------------------------------------------
 ; render
 ;---------------------------------------------------------
 grim_render, grim_data, plane=plane


end
;=============================================================================



;=============================================================================
; grim_activate_all_event
;
;=============================================================================
pro grim_activate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Activate all overlays'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_activate_all, grim_data, plane
 grim_refresh, grim_data, /no_image

end
;=============================================================================



;=============================================================================
; grim_deactivate_all_event
;
;=============================================================================
pro grim_deactivate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Deactivate all overlays'
   return
  end


 ;---------------------------------------------------------
 ; switch to next plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_deactivate_all, grim_data, plane
 grim_refresh, grim_data, /no_image


end
;=============================================================================



;=============================================================================
; grim_repeat_event
;
;=============================================================================
pro grim_repeat_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Repeat last menu item.'
   return
  end


 ;---------------------------------------------------------
 ; repeat last option
 ;---------------------------------------------------------
 grim_repeat, grim_data


end
;=============================================================================



;=============================================================================
; grim_descriptor_notify_handle
;
;=============================================================================
pro grim_descriptor_notify_handle, grim_data, xd, refresh=refresh, new=new
@grim_constants.common

 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 new = 0

 ;-----------------------------------------------------------------
 ; if the data descriptor of the current plane is affected, then 
 ; remember to refresh the image
 ;-----------------------------------------------------------------
 use_pixmap = 1
 w = where(xd EQ plane.dd)
 if(w[0] NE -1) then $
  begin
   if(dat_update(plane.dd) EQ 1) then new = 1 $
   else $
    begin
     refresh = 1
     use_pixmap = 0
    end
  end

 ;---------------------------------------------------------------------------
 ; Call source routines for overlays that depend on any affected descriptors.
 ;
 ; Planes for which initial overlays have not yet been loaded are ignored
 ; because those overlays will be computed using the geometry that exists at 
 ; that time, and hence any dependencies should be automatically accounted for.
 ;---------------------------------------------------------------------------
 for j=0, nplanes-1 do $
  if(NOT keyword_set(*planes[j].initial_overlays_p)) then $
   begin
    points_ptd = grim_ptd(planes[j])
    n = n_elements(points_ptd)

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; build a list of source functions and dependencies
    ; such that each source function is called only once.
    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
    name_list = ''
    source_xd_list = ptr_new()
    points_ptd_list = ptr_new()
    source_points_ptd_list = ptr_new()

    if(keyword_set(points_ptd)) then $
     for i=0, n-1 do if(obj_valid(points_ptd[i])) then $
      begin
       source_xd = cor_dereference_gd(points_ptd[i])
       if(keyword_set(source_xd)) then $
        begin
         w = where(source_xd EQ xd)
         if(w[0] NE -1) then $
          begin
           name = cor_udata(points_ptd[i], 'GRIM_OVERLAY_NAME')
           if(NOT keyword_set(name)) then name = ''
;;           name = cor_tasks(points_ptd[i], /first)
;;           name = grim_get_overlay_name(points_ptd[i])

           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           ; find any point dependencies
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           source_ptd = obj_new()
           w = nwhere(points_ptd, source_xd)
           if(w[0] NE -1) then source_ptd = points_ptd[w]

           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           ; if first instance of this type of overlay, add a new item
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           w = where(name_list EQ name)
           if(w[0] EQ -1) then $
            begin
             name_list = append_array(name_list, name)
             source_xd_list = append_array(source_xd_list, ptr_new(source_xd))
             points_ptd_list = append_array(points_ptd_list, ptr_new(points_ptd[i]))
             source_points_ptd_list = append_array(source_points_ptd_list, ptr_new(source_ptd))
             if(plane.pn EQ planes[j].pn) then refresh = 1
            end $
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           ; otherwise, add to the existing item
           ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           else $
            begin
             ii = w[0]
             *source_xd_list[ii] = append_array(*source_xd_list[ii], source_xd)
             *points_ptd_list[ii] = append_array(*points_ptd_list[ii], points_ptd[i])
             *source_points_ptd_list[ii] = append_array(*source_points_ptd_list[ii], source_ptd)
            end 
          end
        end
      end

   ;- - - - - - - - - - - - - - - - - - - - - - - -
   ; get rid of redundant results
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   nn = 0
   if(keyword_set(name_list)) then nn = n_elements(name_list)
   for i=0, nn-1 do $
    begin
     *source_xd_list[i] = unique(*source_xd_list[i])
     *points_ptd_list[i] = unique(*points_ptd_list[i])
     *source_points_ptd_list[i] = unique(*source_points_ptd_list[i])
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; if the cd time is changed, then all descriptors will need to be reloaded
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;   if(NOT grim_test_map(grim_data)) then $
;    if(plane.t0 NE bod_time(grim_xd(plane, /cd))) then $
;     begin
;      grim_mark_descriptors, grim_data, /all, plane=plane, MARK_STALE
;      for i=0, nn-1 do *source_xd_list[i] = 0	; force everything to recompute.
;						; this is not the right way
;						; to do this since it destroys
;						; all memory of which overlays
;						; need to be recomputed
;     end


   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; Call each source function
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
;stop
;i=3
;print, *source_xd_list[i]		; some bad object references in here

   for i=0, nn-1 do $
         grim_overlay, grim_data, plane=plane, $
               name_list[i], source_xd=*source_xd_list[i], $
               ptd=*points_ptd_list[i], source_ptd=*source_points_ptd_list[i]

   for i=0, nn-1 do ptr_free, source_xd_list[i], points_ptd_list[i], source_points_ptd_list[i]


  end

 ;---------------------------------------------------------------------------
 ; render new image if auto rengering, or rendering plane
 ;---------------------------------------------------------------------------
 if(plane.rendering OR $
          (grim_get_toggle_flag(grim_data, 'RENDER_AUTO'))) then $
                                                grim_render, grim_data, plane=plane


 ;---------------------------------------------------------------------------
 ; Call user overlay notification function
 ;---------------------------------------------------------------------------
; if() then $
grim_user_notify, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_help
;
;=============================================================================
pro grim_help, grim_data, text

 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 if(NOT widget_info(grim_data.help_text, /valid)) then $
  begin
   grim_data.help_text = textedit(text, base=base, xs=80, ys=60, $
                                               resource_prefix='grim_help')
   widget_control, base, tlb_set_title='GRIM Help'
   grim_data.help_base = base
   grim_set_data, grim_data
   grim_refresh, grim_data, /no_image, /no_objects
  end $
 else $
  begin
   widget_control, grim_data.help_text, set_value=text
   widget_control, grim_data.help_base, /map
  end

; hide button

end
;=============================================================================



;=============================================================================
; grim_create_help_menu
;
;=============================================================================
pro grim_help_event, event
 text = ''
 nv_help, 'grim', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;=============================================================================



;=============================================================================
; grim_create_help_menu
;
;=============================================================================
function grim_create_help_menu, _menu_desc

 menu_desc = _menu_desc

 help_desc = strep_s(menu_desc, '_event', '_help_event')
; menu_desc = ['1\Help', help_desc]
 grim_desc = ['0\GRIM \grim_help_event']

 menu_desc = ['1\Help', grim_desc, help_desc]
;stop

 return, menu_desc
end
;=============================================================================



;=============================================================================
; grim_cull_menu_desc
;
;=============================================================================
function grim_cull_menu_desc, _menu_desc, plot, map, beta, $
            map_items=map_items, $
            map_indices=map_indices, $
            od_map_items=od_map_items, $
            od_map_indices=od_map_indices, $
            plot_items=plot_items, $
            plot_indices=plot_indices, $
            plot_only_items=plot_only_items, $
            plot_only_indices=plot_only_indices, $
            beta_only_indices=beta_only_indices

 menu_desc = _menu_desc

 ;-------------------------------------------
 ; mark items to cull
 ;-------------------------------------------
 if(plot) then mark = complement(menu_desc, [plot_indices, plot_only_indices]) $
 else mark = plot_only_indices

 if(map) then $
   mark = append_array(mark, complement(menu_desc, [map_indices, od_map_indices]))

 if(NOT beta) then mark = append_array(mark, beta_only_indices)

 ii = complement(menu_desc, mark)
 if(ii[0] EQ -1) then return, ''
 menu_desc = menu_desc[ii]


 ;-------------------------------------------
 ; remove consecutive duplicate items
 ;-------------------------------------------
 mark = 0
 for i=1, n_elements(menu_desc)-1 do $
       if(menu_desc[i] EQ menu_desc[i-1]) then mark = append_array(mark, [i])
 if(keyword_set(mark)) then menu_desc = rm_list_item(menu_desc, mark)


 ;-------------------------------------------
 ; remove null menus
 ;-------------------------------------------
 mark = 0
 for i=1, n_elements(menu_desc)-1 do $
       if(strmid(menu_desc[i],0,1) EQ '2') then $
             if(strmid(menu_desc[i-1],0,1) EQ '1') then mark = append_array(mark, [i])
 if(keyword_set(mark)) then menu_desc = rm_list_item(menu_desc, mark)


 return, menu_desc
end
;=============================================================================



;=============================================================================
; grim_parse_menu_desc
;
;=============================================================================
function grim_parse_menu_desc, _menu_desc, $
            map_items=map_items, $
            map_indices=map_indices, $
            od_map_items=od_map_items, $
            od_map_indices=od_map_indices, $
            plot_items=plot_items, $
            plot_indices=plot_indices, $
            plot_only_items=plot_only_items, $
            plot_only_indices=plot_only_indices, $
            beta_only_indices=beta_only_indices, $
            sync_indices=sync_indices, sync_items=sync_items

 map_token = '*'
 od_token = '#'
 plot_token = '+'
 plot_only_token = '%'
 beta_only_token = '?'
 sync_token = '!'

 map_items = ''
 od_map_items = ''
 plot_items = ''
 menu_desc = _menu_desc

 p = strpos(menu_desc, map_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], map_token, rem=map_items)
   menu_desc[w] = ss + map_items
   map_indices = w
  end

 p = strpos(menu_desc, od_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], od_token, rem=od_map_items)
   menu_desc[w] = ss + od_map_items
   od_map_indices = w
  end

 p = strpos(menu_desc, plot_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], plot_token, rem=plot_items)
   menu_desc[w] = ss + plot_items
   plot_indices = w
  end

 p = strpos(menu_desc, plot_only_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], plot_only_token, rem=plot_only_items)
   menu_desc[w] = ss + plot_only_items
   plot_only_indices = w
  end

 p = strpos(menu_desc, beta_only_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], beta_only_token, rem=beta_only_items)
   menu_desc[w] = ss + beta_only_items
   beta_only_indices = w
  end

 p = strpos(menu_desc, sync_token)
 w = where(p NE -1)
 if(w[0] NE -1) then $
  begin
   ss = str_nnsplit(menu_desc[w], sync_token, rem=sync_items)
   menu_desc[w] = ss + sync_items
   sync_indices = w
  end

 return, menu_desc
end
;=============================================================================



;=============================================================================
; grim_menu_desc
;
;  Items containing '*' work for maps as well.
;  Items containing '#' work for maps with observer descriptors.
;  Items containing '+' work for plots as well.
;  Items containing '%' work only for plots.
;  Items containing '?' work only for the beta version.
;  Items containing '!' can be synced to all planes.
;
;=============================================================================
function grim_menu_desc, cursor_modes=cursor_modes

 desc = [ '+*1\File' , $
           '0\Load                \+*grim_menu_file_load_event', $
           '0\Browse              \*grim_menu_file_browse_event', $
           '0\Save                \+*grim_menu_file_save_event', $
           '0\Save As             \+*grim_menu_file_save_as_event', $
           '0\Open As RGB          \*grim_menu_open_as_rgb_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save Detached Header    \+*grim_menu_file_save_detached_header_event', $
           '0\Save Detached Headers; All Planes\+*grim_menu_file_save_all_detached_headers_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save User Points    \*grim_menu_file_save_user_ptd_event', $
           '0\Save User Points; All Planes\*grim_menu_file_save_all_user_ptd_event', $
           '0\Load User Points    \*grim_menu_file_load_user_ptd_event', $
           '0\Load User Points; All Planes\*grim_menu_file_load_all_user_ptd_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save Tie Points     \*grim_menu_file_save_tie_ptd_event', $
           '0\Save Tie Points; All Planes \*grim_menu_file_save_all_tie_ptd_event', $
           '0\Load Tie Points     \*grim_menu_file_load_tie_ptd_event', $
           '0\Load Tie Points; All Planes \*grim_menu_file_load_all_tie_ptd_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save Curves         \*grim_menu_file_save_curves_event', $
           '0\Save Curves; All Planes     \*grim_menu_file_save_all_curves_event', $
           '0\Load Curves         \*grim_menu_file_load_curves_event', $
           '0\Load Curves; All Planes     \*grim_menu_file_load_all_curves_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save Mask           \*grim_menu_file_save_mask_event', $
           '0\Save Masks; All Planes      \*grim_menu_file_save_all_masks_event', $
           '0\Load Mask           \*grim_menu_file_load_mask_event', $
           '0\Load Masks; All Planes      \*grim_menu_file_load_all_masks_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Save Postscript     \+*grim_menu_file_save_ps_event', $
           '0\Save PNG            \+*grim_menu_file_save_png_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Repeat              \+*grim_menu_repeat_event', $
           '0\Undo                \+*grim_menu_undo_event', $
           '0\Redo                \+*grim_menu_redo_event', $
           '0\--------------------\+*grim_menu_delim_event', $ 
           '0\Select              \+*grim_select_event', $
           '0\Identify            \+*grim_identify_event', $
           '0\Close               \+*grim_menu_file_close_event', $
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\Mode' , $

          '+*1\Plane' , $
           '0\First               \+*grim_menu_plane_first_event' , $
           '0\Last               \+*grim_menu_plane_last_event' , $
           '0\Next               \+*grim_menu_plane_next_event' , $
           '0\Previous           \+*grim_menu_plane_previous_event', $
           '0\Jump               \+*grim_menu_plane_jump_event' , $
           '0\Browse             \*grim_menu_plane_browse_event', $
           '0\Open in new window \*grim_menu_plane_open_event', $
           '0\Crop to view       \+*grim_menu_plane_crop_event' , $
           '0\Reorder by time    \grim_menu_plane_reorder_time_event', $
           '0\Sequence           \*grim_menu_plane_sequence_event', $
           '0\Dump               \*grim_menu_plane_dump_event', $
           '0\Coregister         \grim_menu_plane_coregister_event', $
           '0\Coadd              \grim_menu_plane_coadd_event', $
           '0\Sync Planes        [xxx]\*grim_menu_plane_toggle_plane_syncing_event', $
           '0\Highlight          [xxx]\*grim_menu_plane_highlight_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
           '0\Copy Tie Points     \*grim_menu_plane_copy_tiepoints_event', $
;           '0\Propagate Tie Points\*grim_menu_plane_propagate_tiepoints_event', $
           '0\Sync Tie Points    [xxx]\*grim_menu_plane_toggle_tiepoint_syncing_event', $
           '0\Clear Tie Points    \*grim_menu_plane_clear_tiepoints_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
           '0\Copy Curves        \*grim_menu_plane_copy_curves_event', $
;           '0\Propagate Curves    \*grim_menu_plane_propagate_curves_event', $
           '0\Sync Curves        [xxx]\*grim_menu_plane_toggle_curve_syncing_event', $
           '0\Clear Curves        \*grim_menu_plane_clear_curves_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
           '0\Sync Actions       [xxx]\*grim_menu_plane_toggle_action_syncing_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
;           '0\Copy Activations        \*grim_menu_plane_copy_activations_event', $
           '0\Sync Activations   [xxx]\*grim_menu_plane_toggle_activation_syncing_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
           '0\Copy Mask          \*grim_menu_plane_copy_mask_event', $
           '0\Clear Mask         \*grim_menu_plane_clear_mask_event', $
           '0\------------------------\+*grim_menu_delim_event', $ 
           '0\Settings           \+*grim_menu_plane_settings_event', $
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\Data' , $
           '0\Adjust values        \+*grim_menu_data_adjust_event' , $
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\View' , $
           '0\Refresh              \+*grim_menu_view_refresh_event' , $
           '+*1\Zoom' , $
             '0\Specify           \+*grim_menu_view_zoom_event' , $
             '0\Double            \+*grim_menu_view_zoom_double_event' , $
             '0\Half              \+*grim_menu_view_zoom_half_event' , $
             '0\Force Integer        [xxx]\*grim_menu_view_zoom_force_integer_event', $
             '0\1                 \+*grim_menu_view_zoom_1_event' , $
             '0\2                 \+*grim_menu_view_zoom_2_event' , $
             '0\3                 \+*grim_menu_view_zoom_3_event' , $
             '0\4                 \+*grim_menu_view_zoom_4_event' , $
             '0\5                 \+*grim_menu_view_zoom_5_event' , $
             '0\6                 \+*grim_menu_view_zoom_6_event' , $
             '0\7                 \+*grim_menu_view_zoom_7_event' , $
             '0\8                 \+*grim_menu_view_zoom_8_event' , $
             '0\9                 \+*grim_menu_view_zoom_9_event' , $
             '0\10                 \+*grim_menu_view_zoom_10_event' , $
             '0\1/2                 \+*grim_menu_view_zoom_1_2_event' , $
             '0\1/3                 \+*grim_menu_view_zoom_1_3_event' , $
             '0\1/4                 \+*grim_menu_view_zoom_1_4_event' , $
             '0\1/5                 \+*grim_menu_view_zoom_1_5_event' , $
             '0\1/6                 \+*grim_menu_view_zoom_1_6_event' , $
             '0\1/7                 \+*grim_menu_view_zoom_1_7_event' , $
             '0\1/8                 \+*grim_menu_view_zoom_1_8_event' , $
             '0\1/9                 \+*grim_menu_view_zoom_1_9_event' , $
             '0\1/10                 \+*grim_menu_view_zoom_1_10_event' , $
             '2\<null>               \+*grim_menu_delim_event', $
           '+*1\Rotate' , $
             '0\0                 \+*grim_menu_view_rotate_0_event' , $
             '0\1                 \+*grim_menu_view_rotate_1_event' , $
             '0\2                 \+*grim_menu_view_rotate_2_event' , $
             '0\3                 \+*grim_menu_view_rotate_3_event' , $
             '0\4                 \+*grim_menu_view_rotate_4_event' , $
             '0\5                 \+*grim_menu_view_rotate_5_event' , $
             '0\6                 \+*grim_menu_view_rotate_6_event' , $
             '0\7                 \+*grim_menu_view_rotate_7_event' , $
             '2\<null>               \+*grim_menu_delim_event', $
           '0\Recenter             \+*grim_menu_view_recenter_event' , $
           '%0\Apply to all Planes  \+*grim_menu_view_apply_event' , $
           '0\Home                 \+*grim_menu_view_home_event' , $
           '0\Save                 \+*grim_menu_view_save_event' , $
           '0\Restore              \+*grim_menu_view_restore_event', $
           '0\Previous             \+*grim_menu_view_previous_event', $
           '0\Entire               \+*grim_menu_view_entire_event', $
           '0\Initial              \+*grim_menu_view_initial_event', $
           '0\Reverse Order        \*grim_menu_view_flip_event', $ 
           '0\Frame Overlays\*grim_menu_view_frame_event', $ 
           '0\---------------------\+*grim_menu_delim_event', $ 
           '0\Header               \grim_menu_view_header_event', $
           '0\Notes                \grim_menu_notes_event', $
           '0\---------------------\+*grim_menu_delim_event', $ 
           '0\Toggle Image         \+*grim_menu_toggle_image_event' , $
           '0\Toggle Image/Overlays \+*grim_menu_toggle_image_overlays_event' , $
           '0\Toggle Context       \+*grim_menu_context_event' , $
           '0\Toggle Axes          \*grim_menu_axes_event' , $
           '0\---------------------\+*grim_menu_delim_event', $ 
           '1\Render' , $
;            '0\RGB                  [xxx]\grim_menu_render_toggle_rgb_event' , $
            '0\Oversampling         [xxx]\grim_menu_render_enter_sampling_event' , $
            '0\Numbra               [xxx]\grim_menu_render_enter_numbra_event' , $
            '0\Minimum Brightness   [xxx]\grim_menu_render_enter_minimum_event' , $
            '0\From Current Plane   [xxx]\grim_menu_render_toggle_current_plane_event' , $
            '0\Spawn New Plane      [xxx]\grim_menu_render_toggle_spawn_event' , $
            '0\Render Sky           [xxx]\grim_menu_render_toggle_sky_event' , $
            '0\Automatic            [xxx]\grim_menu_render_toggle_auto_event' , $
            '2\Render                 \grim_menu_render_event' , $
           '0\---------------------\+*grim_menu_delim_event', $ 
           '0\Color Tables         \*grim_menu_view_colors_event', $ 
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\Overlays' ,$
           '0\Compute centers        \!grim_menu_points_centers_event', $ 
           '0\Compute limbs          \!#grim_menu_points_limbs_event', $        
           '0\Compute terminators    \!#grim_menu_points_terminators_event', $
           '0\Compute planet grids   \!*grim_menu_points_planet_grids_event', $ 
           '0\Compute rings          \!grim_menu_points_rings_event', $
           '0\Compute ring grids     \!grim_menu_points_ring_grids_event', $ 
           '0\Compute stations       \!*grim_menu_points_stations_event', $ 
           '0\Compute arrays         \!*grim_menu_points_arrays_event', $ 
           '0\Compute stars          \!grim_menu_points_stars_event', $ 
           '0\Compute shadows        \!grim_menu_points_shadows_event', $ 
;           '0\Compute reflections    \!?grim_menu_points_reflections_event', $ 
           '0\-------------------------\+*grim_menu_delim_event', $ 
           '0\Hide/Unhide all        \!+*grim_menu_hide_all_event', $ 
           '0\Clear all              \!*grim_menu_clear_all_event', $ 
           '0\Clear active           \!*grim_menu_clear_active_event', $ 
           '0\Activate all           \!*grim_menu_activate_all_event', $ 
           '0\Deactivate all         \!*grim_menu_deactivate_all_event', $ 
           '0\Invert Activations     \!*grim_menu_invert_event', $ 
           '0\-------------------------\+*grim_menu_delim_event', $ 
           '0\Overlay Settings       \+*grim_menu_points_settings_event', $
           '2\<null>               \+*grim_menu_delim_event']


 ;----------------------------------------------
 ; Insert cursor mode menu items
 ;----------------------------------------------
 if(keyword_set(cursor_modes)) then $
  begin
   p = strpos(desc, '1\Mode')
   w = (where(p NE -1))[0]

   nn = max([strlen(cursor_modes.menu), 8])

   items = '0\' + cursor_modes.menu + '  \' + cursor_modes.event_pro
   n = n_elements(items)
;   items[n-1] = strep(items[n-1], '2', 0)
   items = append_array(items, '2\<null>               \+*grim_menu_delim_event')

   desc = [desc[0:w], items, desc[w+1:*]]
   cursor_modes.event_pro = grim_parse_menu_desc(cursor_modes.event_pro)
  end

 return, desc
end
;=============================================================================



;=============================================================================
; grim_get_window_size
;
;=============================================================================
pro grim_get_window_size, grim_data, xsize=xsize, ysize=ysize

 _xsize = 0
 _ysize = 0

 plane = grim_get_plane(grim_data)

 dim = dat_dim(plane.dd)
 if(n_elements(dim) EQ 2) then $
  begin
   xs = double(dim[0])*grim_data.zoom
   ys = double(dim[1])*grim_data.zoom

   if(xs GT _xsize) then _xsize = xs
   if(ys GT _ysize) then _ysize = ys
  end

 if(NOT keyword_set(xsize)) then xsize = _xsize
 if(NOT keyword_set(ysize)) then ysize = _ysize
end
;=============================================================================



;=============================================================================
; grim_sync_action
;
;=============================================================================
pro grim_sync_action, grim_data, fn=fn

 if(NOT keyword_set(grim_data.repeat_fn)) then return
 fn = grim_data.repeat_fn
 event = *grim_data.repeat_event_p

 sync_items = *grim_data.sync_items_p
 w = where(fn EQ sync_items)
 if(w[0] EQ -1) then return

 grim_refresh, grim_data, /disable
 pg_draw, /suspend

 pn = grim_data.pn
 planes = grim_get_plane(grim_data, /all)
 for i=0, n_elements(planes)-1 do if(i NE pn) then $
  begin
   grim_data.pn = i
   grim_set_data, grim_data
   call_procedure, fn, event
 end

 pg_draw, /resume
 grim_refresh, grim_data, /enable

 grim_data.pn = pn
 grim_set_data, grim_data
 grim_refresh, /use_pixmap
end
;=============================================================================



;=============================================================================
; grim_actions
;  NOT COMPLETE
;=============================================================================
pro grim_actions, grim_data, actions

 for i=0, n_elements(actions)-1 do grim_sync_action, grim_data, fn=actions[i]

end
;=============================================================================



;=============================================================================
; grim_menu_capture
;
;=============================================================================
pro grim_menu_capture, fn, event
 grim_data = grim_get_data(event.top)
 if(NOT keyword_set(grim_data)) then return

 if(fn EQ 'grim_menu_repeat_event') then return

 grim_data.repeat_fn = fn
 *grim_data.repeat_event_p = event
 grim_set_data, grim_data, grim_data.base

 if(grim_get_toggle_flag(grim_data, 'ACTION_SYNCING')) then $
                                             grim_sync_action, grim_data

end
;=============================================================================



;=============================================================================
; grim_widgets
;
;=============================================================================
pro grim_widgets, grim_data, xsize=xsize, ysize=ysize, cursor_modes=cursor_modes, $
   menu_fname=menu_fname, menu_extensions=menu_extensions
@grim_constants.common

 if(grim_data.retain GT 0) then retain = grim_data.retain

 map = grim_test_map(grim_data)
 plot = grim_data.type EQ 'PLOT'
 beta = grim_data.beta

 ;-----------------------------------------
 ; base, menu bar
 ;-----------------------------------------
 grim_data.base = widget_base(mbar=mbar, /col, /tlb_size_events, $
                          resource_name='grim_base', rname_mbar='grim_mbar')
 grim_data.mbar = mbar
 grim_data.grn = grim_top_to_grn(grim_data.base, /new)

 menu_desc = grim_menu_desc(cursor_modes=cursor_modes)
 for i=0, n_elements(menu_extensions)-1 do $
                   menu_desc = [menu_desc, call_function(menu_extensions[i])]

 if(keyword_set(menu_fname)) then $
  begin
   user_menu_desc = strtrim(strip_comment(read_txt_file(menu_fname)), 2)
   if(keyword_set(user_menu_desc)) then menu_desc = [menu_desc, user_menu_desc]
  end


 ;-----------------------------------------
 ; setup menus
 ;-----------------------------------------
 menu_desc = grim_parse_menu_desc(menu_desc, $
     map_items=map_items, map_indices=map_indices, $
     od_map_items=od_map_items, od_map_indices=od_map_indices, $
     plot_items=plot_items, plot_indices=plot_indices, $
     plot_only_items=plot_only_items, plot_only_indices=plot_only_indices, $
     beta_only_indices=beta_only_indices, sync_items=sync_items)


 menu_desc = grim_cull_menu_desc(menu_desc, plot, map, beta, $
     map_items=map_items, map_indices=map_indices, $
     od_map_items=od_map_items, od_map_indices=od_map_indices, $
     plot_items=plot_items, plot_indices=plot_indices, $
     plot_only_items=plot_only_items, plot_only_indices=plot_only_indices, $
     beta_only_indices=beta_only_indices)

 grim_data.menu_desc_p = nv_ptr_new(menu_desc)
 grim_data.map_items_p = nv_ptr_new(map_items)
 grim_data.od_map_items_p = nv_ptr_new(od_map_items)
 grim_data.sync_items_p = nv_ptr_new(sync_items)

 grim_data.menu = $
          cw__pdmenu(grim_data.mbar, menu_desc, /mbar, ids=menu_ids, $
                                                  capture='grim_menu_capture')
 grim_data.menu_ids_p = nv_ptr_new(menu_ids)
 help_menu_desc = grim_create_help_menu(menu_desc)
 grim_data.help_menu = cw__pdmenu(grim_data.mbar, help_menu_desc, /mbar, /help)


 ;-----------------------------------------
 ; shortcut buttons
 ;-----------------------------------------
 grim_data.shortcuts_base = $
        widget_base(grim_data.base, /row, space=0, xpad=0, ypad=0, $
                                      resource_name='grim_shortcuts_base')

 grim_data.shortcuts_base1 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=0, ypad=0)

 grim_data.select_button = widget_button(grim_data.shortcuts_base1, $
             resource_name='grim_select_button', $
             value=grim_unselect_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_select_event')

 gm = widget_info(grim_data.shortcuts_base1, /geom)
 ys = gm.ysize
 grim_data.shortcuts_base2 = $
           widget_base(grim_data.shortcuts_base, /row, $
                                       space=0, xpad=4, ypad=0, ysize=ys)

 grim_data.rewind_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_rewind_button', $
             value=grim_rewind_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_rewind_event')

 grim_data.previous_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_previous_button', $
             value=grim_previous_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_previous_event')

; grim_data.jumpto_combobox = widget_combobox(grim_data.shortcuts_base2, $
;                    /editable, $
;                     resource_name='grim_jumpto_list', $
;                               value=['0'], /tracking_events, $
;                                              event_pro='grim_jumpto_event')
 grim_data.jumpto_droplist = widget_droplist(grim_data.shortcuts_base2, $
                     resource_name='grim_jumpto_list', $
                               value=['000'], /tracking_events, $
                                              event_pro='grim_jumpto_event')

 grim_data.next_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_next_button', $
             value=grim_next_bitmap(), /bitmap, /tracking_events, $
                                                  event_pro='grim_next_event')

 grim_data.fastforward_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_fastforward_button', $
             value=grim_fastforward_bitmap(), /bitmap, /tracking_events, $
                                                  event_pro='grim_fastforward_event')


 grim_data.shortcuts_base3 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=0, ypad=0)

 grim_data.crop_button = widget_button(grim_data.shortcuts_base3, $
             resource_name='grim_crop_button', $
             value=grim_crop_bitmap(), /bitmap, /tracking_events, $
                                                  event_pro='grim_crop_event')

 grim_data.refresh_button = widget_button(grim_data.shortcuts_base3, $
              resource_name='grim_refresh_button', $
              value=grim_refresh_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_refresh_event')

 grim_data.entire_button = widget_button(grim_data.shortcuts_base3, $
              resource_name='grim_entire_button', $
              value=grim_entire_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_entire_event')

 grim_data.view_previous_button = widget_button(grim_data.shortcuts_base3, $
              resource_name='grim_view_previous_button', $
              value=grim_view_previous_bitmap(), /bitmap, /tracking_events, $
                                          event_pro='grim_view_previous_event')


 grim_data.shortcuts_base4 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=4, ypad=0)

 grim_data.hide_button = widget_button(grim_data.shortcuts_base4, $
              resource_name='grim_hide_button', $
              value=grim_hide_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_hide_event')

 grim_data.toggle_image_button = widget_button(grim_data.shortcuts_base4, $
              resource_name='grim_toggle_image_button', $
              value=grim_hide_image_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_toggle_image_event')

 grim_data.toggle_image_overlays_button = widget_button(grim_data.shortcuts_base4, $
              resource_name='grim_toggle_image_overlays_button', $
              value=grim_hide_image_bitmap() AND grim_hide_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_toggle_image_overlays_event')

 if((NOT plot) AND (NOT map)) then $
   grim_data.render_button = widget_button(grim_data.shortcuts_base4, $
              resource_name='grim_render_button', $
              value=grim_render_bitmap(), /bitmap, /tracking_events, $
                                                 event_pro='grim_render_event')



 grim_data.shortcuts_base5 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=0, ypad=0)

 if(NOT plot) then $
   grim_data.color_button = widget_button(grim_data.shortcuts_base5, $
              resource_name='grim_color_button', $
              value=grim_colors_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_colors_event')

 grim_data.settings_button = widget_button(grim_data.shortcuts_base5, $
              resource_name='grim_settings_button', $
              value=grim_settings_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_settings_event')


 grim_data.shortcuts_base6 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=4, ypad=0)

 grim_data.tracking_button = widget_button(grim_data.shortcuts_base6, $
              resource_name='grim_tracking_button', $
              value=grim_tracking_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_tracking_event')

  grim_data.guideline_button = widget_button(grim_data.shortcuts_base6, $
              resource_name='grim_guideline_button', $
              value=grim_guideline_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_guideline_event')

 if(NOT plot) then $
  if(NOT grim_test_map(grim_data)) then $
    grim_data.grid_button = widget_button(grim_data.shortcuts_base6, $
              resource_name='grim_grid_button', $
              value=grim_grid_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_grid_event')

 if(NOT plot) then $
   grim_data.pixel_grid_button = widget_button(grim_data.shortcuts_base6, $
              resource_name='grim_pixel_grid_button', $
              value=grim_pixel_grid_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_pixel_grid_event')



 grim_data.shortcuts_base9 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=0, ypad=0)

 grim_data.context_button = widget_button(grim_data.shortcuts_base9, $
              resource_name='grim_context_button', $
              value=grim_context_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_context_event')

 if(NOT plot) then $
   grim_data.axes_button = widget_button(grim_data.shortcuts_base9, $
              resource_name='grim_axes_button', $
              value=grim_axes_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_axes_event')


 grim_data.shortcuts_base7 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=4, ypad=0)

 if(NOT plot) then $
   grim_data.activate_all_button = widget_button(grim_data.shortcuts_base7, $
         resource_name='grim_activate_all_button', $
         value=grim_activate_all_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_activate_all_event')

 if(NOT plot) then $
   grim_data.deactivate_all_button = widget_button(grim_data.shortcuts_base7, $
         resource_name='grim_deactivate_all_button', $
         value=grim_deactivate_all_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_deactivate_all_event')


 grim_data.shortcuts_base8 = $
        widget_base(grim_data.shortcuts_base, /row, space=0, xpad=0, ypad=0)

 grim_data.header_button = widget_button(grim_data.shortcuts_base8, $
         resource_name='grim_header_button', $
         value=grim_header_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_header_event')

 grim_data.notes_button = widget_button(grim_data.shortcuts_base8, $
         resource_name='grim_notes_button', $
         value=grim_notes_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_notes_event')

 grim_data.repeat_button = widget_button(grim_data.shortcuts_base8, $
         resource_name='grim_repeat_button', $
         value=grim_repeat_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_repeat_event')

 grim_data.undo_button = widget_button(grim_data.shortcuts_base8, $
         resource_name='grim_undo_button', $
         value=grim_undo_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_undo_event')
 w = where(strpos(menu_desc, 'grim_menu_undo_event') NE -1)
 grim_data.undo_menu_id = menu_ids[w[0]]

 grim_data.redo_button = widget_button(grim_data.shortcuts_base8, $
         resource_name='grim_redo_button', $
         value=grim_redo_bitmap(), /bitmap, /tracking_events, $
                                     event_pro='grim_redo_event')
 w = where(strpos(menu_desc, 'grim_menu_redo_event') NE -1)
 grim_data.redo_menu_id = menu_ids[w[0]]


 grim_data.identify_button = widget_button(grim_data.shortcuts_base8, $
             resource_name='grim_identify_button', $
             value=grim_identify_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_identify_event')



 grim_data.sub_base = widget_base(grim_data.base, /row, xpad=0, space=2)



 ;-----------------------------------------
 ; mode buttons
 ;-----------------------------------------
 grim_data.modes_base = $
        widget_base(grim_data.sub_base, /col, space=0, xpad=0, ypad=0, $
                                             resource_name='grim_modes_base')


 ;-----------------------------------------
 ; cursor modes
 ;-----------------------------------------
 nmodes = n_elements(cursor_modes)
 if(nmodes GT 0) then $
  begin
   for i=0, nmodes-1 do $
    begin
     event_pro = grim_parse_menu_desc(cursor_modes[i].event_pro)
     w = where(strpos(menu_desc, event_pro) NE -1)

     if(w[0] NE -1) then $
      begin
       ii = w[0]
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; Because we override the event_pro here, the user modes do not
       ; participate in GRIM's capture mechanism, so the 'repeat'
       ; command does not apply.  This is necessary because the user
       ; modes store their data in their button's uvalue, which would
       ; otherwise be used by the capture mechanism.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       button = widget_button(grim_data.modes_base, $
                   value=cursor_modes[i].bitmap, /bitmap, /tracking_events, $
                              event_pro=event_pro, uname='mode', $
                                                   uvalue=cursor_modes[i].name)
       widget_control, button, set_uvalue=cursor_modes[i]

       widget_control, menu_ids[ii], set_uvalue=cursor_modes[i], $
                                        event_pro=cursor_modes[i].event_pro
      end
    end
   end


 window, /free, /pixmap, xsize=MAG_SIZE_DEVICE, ysize=MAG_SIZE_DEVICE
 grim_data.mag_pixmap = !d.window
 window, /free, /pixmap, xsize=MAG_SIZE_DEVICE, ysize=MAG_SIZE_DEVICE
 grim_data.mag_redraw_pixmap = !d.window


 ;-----------------------------------------
 ; main draw window
 ;-----------------------------------------
 grim_data.draw_base = widget_base(grim_data.sub_base, $
                      xsize=xsize, ysize=ysize, space=0, xpad=0, ypad=0)

; grim_data.scale_draw = $
;      widget_draw(grim_data.main_draw_base, $
;            xsize=xsize+SCALE_WIDTH*2, ysize=ysize+SCALE_WIDTH*2, retain=retain)


; grim_data.draw_base = widget_base(grim_data.main_draw_base, $
;                                xsize=xsize, ysize=ysize, space=0, xoff=0, yoff=0)
 grim_data.draw = $
     widget_draw(grim_data.draw_base, $
                /button_events, /tracking_events, /motion_events, $
                event_pro='grim_draw_event', resource_name='grim_draw', $
                retain=retain)
 if(idl_v_chrono(!version.release) GE idl_v_chrono('6.4')) then $
                             widget_control, grim_data.draw, /draw_wheel_events
; widget_control, grim_data.draw_base, map=0


 ;-----------------------------------------
 ; message line
 ;-----------------------------------------
 grim_data.message_base = $
        widget_base(grim_data.base, /row, space=0, xpad=0, ypad=0, $
                                      resource_name='grim_message_base')

 grim_data.xy_label = $
       widget_label(grim_data.message_base, val='(----,----): ----------------', $
                       frame=1, /align_left, resource_name='grim_xy_label')

 grim_data.label = $
       widget_label(grim_data.message_base, val=' ', frame=1, /align_left, $
                                                    resource_name='grim_label')

 widget_control, grim_data.base, map=0
 widget_control, /realize, grim_data.base


 widget_control, grim_data.draw, get_value=wnum
 grim_data.wnum = wnum

; widget_control, grim_data.scale_draw, get_value=scale_wnum
; grim_data.scale_wnum = scale_wnum


 ;-----------------------------------------
 ; context draw window
 ;-----------------------------------------
 context_xsize = (context_ysize = CONTEXT_SIZE)
 grim_data.context_base = $
              widget_base(grim_data.draw_base, xs=context_xsize, $
                                           ys=context_ysize, xoff=0, yoff=0)
 grim_data.context_draw = widget_draw(grim_data.context_base, $
     /button_events, /motion_events, /tracking_events, /wheel_events, $
      event_pro='grim_draw_event', retain=retain)
 widget_control, grim_data.context_draw, get_value=context_wnum
 grim_data.context_wnum = context_wnum
 widget_control, grim_data.context_base, map=0

 window, /free, /pixmap, xsize=context_xsize, ysize=context_ysize
 grim_data.context_pixmap = !d.window

 wset, wnum

 ;-----------------------------------------
 ; axes draw window
 ;-----------------------------------------
 axes_xsize = (axes_ysize = AXES_SIZE)
 geom = widget_info(grim_data.draw_base, /geom)
 grim_data.axes_base = $
                widget_base(grim_data.draw_base, $
                xs=axes_xsize, ys=axes_ysize)
 grim_data.axes_draw = widget_draw(grim_data.axes_base, $
                /button_events, /motion_events, /tracking_events, $
                 event_pro='grim_draw_event', retain=retain, $
                 xs=axes_xsize, ys=axes_ysize)
 widget_control, grim_data.axes_draw, get_value=axes_wnum
 grim_data.axes_wnum = axes_wnum
 widget_control, grim_data.axes_base, map=0


 wset, wnum

end
;=============================================================================



;=============================================================================
; grim_get_default_zoom
;
;=============================================================================
function grim_get_default_zoom, dd
ratio = 0.75

 device, get_screen_size=screen_size
 
 xsize_max = screen_size[0] * ratio
 ysize_max = screen_size[1] * ratio

 dim = dat_dim(dd)
 if(n_elements(dim) EQ 1) then dim = [dim, 1]

 sx = double(dim[0])
 sy = double(dim[1])

 im = 0

 Rx = xsize_max / sx
 Ry = ysize_max / sy

 if(Rx LT Ry) then return, Rx $
 else return, Ry

end
;=============================================================================



;=============================================================================
; grim_save_initial_view
;
;=============================================================================
pro grim_save_initial_view, grim_data

 tvim, get_info=tvd, /inherit, /silent, /no_coord
 *grim_data.tvd_init_p = tvd

end
;=============================================================================



;=============================================================================
; grim_initial_framing
;
;=============================================================================
pro grim_initial_framing, grim_data, frame, delay_overlays=delay_overlays

 frame = strupcase(frame)
 z = 1d100

 if(keyword_set(delay_overlays)) then planes = grim_get_plane(grim_data) $
 else planes = grim_get_plane(grim_data, /all)

 for i=0, n_elements(planes)-1 do $
  begin
   name = grim_parse_overlay(planes[i], frame[0], obj_name)
   if(name EQ '1') then name = ''
   ptd = grim_ptd(planes[i], type=name)
   if(NOT keyword_set(ptd)) then return

   if(keyword_set(obj_name)) then $
    begin
     obj_names = cor_name(ptd)
     w = where(obj_names[0,*] EQ obj_name[0])
     if(w[0] EQ -1) then return
     ptd = ptd[*,w]
    end

   grim_frame_overlays, grim_data, planes[i], ptd
   tvim, get_info=tvd, /inherit, /silent
   if(min(tvd.zoom) LT z) then $
    begin
     z = min(tvd.zoom)
     off = tvd.offset
    end
  end

 tvim, zoom=z, offset=off, /inherit, /silent

end
;=============================================================================



;=============================================================================
; grim_initial_overlays
;
;=============================================================================
pro grim_initial_overlays, grim_data, plane=plane, _overlays, exclude=exclude, $
    only=only, temp=temp, ptd=ptd

 if(keyword_set(plane)) then planes = plane $
 else planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 if(grim_data.slave_overlays) then nplanes = 1

 ;------------------------------------------------------------------
 ; check each plane for initial overlays that have not been cleared
 ;------------------------------------------------------------------
 for j=0, nplanes-1 do $
  begin
   overlays = *planes[j].initial_overlays_p

   if(keyword_set(overlays)) then $
    begin
     widget_control, /hourglass

    ;---------------------------------------------------------------------
     ; clear overlays so they are not computed again for this plane
     ;---------------------------------------------------------------------
     *planes[j].initial_overlays_p = ''

     ;-----------------------------------------------------
     ; handle special keywords
     ;-----------------------------------------------------
     if(keyword_set(exclude)) then $
      begin
       *planes[j].initial_overlays_p = overlays
       for i=0, n_elements(exclude)-1 do $
	begin
	 w = where(overlays EQ exclude[i])
	 if(w[0] NE -1) then overlays = rm_list_item(overlays, w[0])
	end
      end

     if(keyword_set(only)) then $
      begin
       *planes[j].initial_overlays_p = overlays
       _overlays = overlays
       overlays = ''
       for i=0, n_elements(only)-1 do $
	begin
	 w = where(_overlays EQ only[i])
	 if(w[0] NE -1) then overlays = append_array(overlays, only[i])
	end 
      end
     
     ;-----------------------------------------------------
     ; compute overlays
     ;-----------------------------------------------------
     if(keyword_set(overlays)) then $
      for i=0, n_elements(overlays)-1 do $
       begin
        name = grim_parse_overlay(planes[j], overlays[i], obj_name)
        grim_print, grim_data, 'Plane ' + strtrim(j,1) + ': ' + name
        grim_overlay, grim_data, name, plane=planes[j], obj_name=obj_name, temp=temp, ptd=_ptd
        if(grim_data.activate) then grim_activate_all, grim_data, planes[j]
        if(keyword_set(_ptd)) then ptd = append_array(ptd, _ptd[*])
       end

     grim_set_plane, grim_data, planes[j], pn=planes[j].pn
    end
  end


end
;=============================================================================



;=============================================================================
; grim_rgb_dim_fn
;
;
;=============================================================================
function grim_rgb_dim_fn, dd, dat
 return, (dat_dim(dd, /true))[0:1]
end
;=============================================================================



;=============================================================================
; grim_get_arg
;
;=============================================================================
pro grim_get_arg, arg, dd=dd, grn=grn, extensions=extensions

 if(NOT keyword_set(arg)) then return

 type = size(arg, /type)
 dim = size(arg, /dim) 
 ndim = n_elements(dim)

 ;---------------------------------------------------
 ; object -- assume data descriptor 
 ;---------------------------------------------------
 if(type EQ 11) then $
  begin
   dd = append_array(dd, arg)
   return
  end

 ;---------------------------------------------------
 ; string -- assume file name(s); read descriptors 
 ;---------------------------------------------------
 if(type EQ 7) then $
  begin
   dd = dat_read(arg, extensions=extensions)
   return
  end

 ;------------------------------------------------
 ; scalar arg is grn
 ;------------------------------------------------
 if((ndim EQ 1) AND (dim[0] EQ 0)) then $
  begin
   grn = arg
   return
  end

 ;------------------------------------------------
 ; 1-D, 2-D or 3-D arg: just make dd
 ;------------------------------------------------
 if(ndim LE 3) then $
  begin
   _dd = dat_create_descriptors(1, data=arg)
   dd = append_array(dd, _dd)
   return
  end


 ;------------------------------------------------
 ; other inputs are invalid
 ;------------------------------------------------
 grim_message, 'Invalid argument.'
end
;=============================================================================



;=============================================================================
; grim_get_args
;
; Possible arguments to GRIM:
; 	dd (object)
; 	filename (string)
; 	grn (scalar)
; 	image (2d array)
; 	plot (1d array)
; 	cube (3d array)
;
;=============================================================================
pro grim_get_args, arg1, arg2, dd=dd, grn=grn, display_type=type, xzero=xzero, $
               maintain=maintain, compress=compress, nhist=nhist, $
               overlays=overlays, extensions=extensions, rgb=rgb

 ;--------------------------------------------
 ; build data descriptors list 
 ;--------------------------------------------
 grim_get_arg, arg1, dd=_dd, grn=grn, extensions=extensions
 grim_get_arg, arg2, dd=_dd, grn=grn, extensions=extensions


 ;--------------------------------------------
 ; if no data descriptors, create one 
 ;--------------------------------------------
 if(keyword_set(overlays)) then $
  begin
   overlays = strupcase(overlays)

;   if(NOT keyword_set(_dd)) then $
;    begin
;     pg_sort_args, dd, trs=trs, keyvals
;    end

  end


 ;--------------------------------------------
 ; process data descriptors 
 ;--------------------------------------------
 n_dd = n_elements(_dd)

 for i=0, n_dd-1 do $
  begin
   dim = dat_dim(_dd[i])
   ndim = n_elements(dim)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; set dd controls
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(nhist)) then dat_set_nhist, _dd[i], nhist[0]
   if(keyword_set(maintain)) then dat_set_maintain, _dd[i], maintain[0]
   if(keyword_set(compress)) then dat_set_compress, _dd[i], compress[0]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; non-3-D arrays get a plane and a zero offset
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if((ndim LT 3) OR keyword_set(rgb)) then $
    begin
     dd = append_array(dd, _dd[i])
     if(keyword_set(rgb)) then dat_set_dim_fn, dd, 'grim_rgb_dim_fn'
    end $ 
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; 3-D arrays are multi-plane if not rgb
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else dd = append_array(dd, dat_slices(_dd[i]))
  end


 ;-------------------------------------------------------------------
 ; all dd assumed to have same type as first one; default is image
 ;-------------------------------------------------------------------
 type = 'IMAGE'
 if(keyword_set(dd)) then $
  begin 
   dim = dat_dim(dd[0])
   if(n_elements(dim) EQ 1) then if(dim[0] GT 0) then  type = 'PLOT'
   if(dim[0] EQ 2) then type = 'PLOT'
  end


end
;=============================================================================



;=============================================================================
; grim_create_cursor_mode
;
;=============================================================================
function grim_create_cursor_mode, name, mode_args, cursor_modes, no_prefix=no_prefix

 prefix = ''
 if(NOT keyword_set(no_prefix)) then prefix = 'grim_mode_'

 arg = ''
 if(keyword_set(mode_args)) then $
  begin
   if(size(mode_args, /type) EQ 7) then $
    begin
     names = str_nnsplit(mode_args, ':', rem=args)
     w = where(strupcase(names) EQ strupcase(name))
     if(w[0] NE -1) then arg = args[w]
    end $
   else arg = mode_args
  end

 cursor_mode = call_function(prefix + name, arg)
 return, append_array(cursor_modes, cursor_mode)
end
;=============================================================================



;=============================================================================
; grim
;
;=============================================================================
pro grim, arg1, arg2, _extra=keyvals, $
        cd=_cd, pd=pd, rd=rd, sd=sd, std=std, ard=ard, ltd=ltd, od=_od, $
	new=new, xsize=xsize, ysize=ysize, no_refresh=no_refresh, $
	default=default, previous=previous, restore=restore, activate=activate, $
	doffset=doffset, no_erase=no_erase, filter=filter, rgb=rgb, visibility=visibility, channel=channel, exit=exit, $
	zoom=zoom, rotate=rotate, order=order, offset=offset, retain=retain, $
        gd=gd, nhist=nhist, compress=compress, maintain=maintain, $
	mode_init=mode_init, modal=modal, xzero=xzero, frame=frame, $
	refresh_callbacks=refresh_callbacks, refresh_callback_data_ps=refresh_callback_data_ps, $
	plane_callbacks=plane_callbacks, plane_callback_data_ps=plane_callback_data_ps, $
	max=max, path=path, symsize=symsize, lights=lights, settings_overlays=settings_overlays, $
	user_psym=user_psym, workdir=workdir, mode_args=mode_args, $
        save_path=save_path, load_path=load_path, overlays=overlays, exclude_overlays=exclude_overlays, pn=pn, $
	menu_fname=menu_fname, cursor_swap=cursor_swap, fov=fov, clip=clip, hide=hide, $
	menu_extensions=menu_extensions, button_extensions=button_extensions, $
	arg_extensions=arg_extensions, arg_menus=arg_menus, loadct=loadct, grn=grn, tag=tag, $
	extensions=extensions, beta=beta, rendering=rendering, npoints=npoints, $
	cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, $
        lgt_trs=lgt_trs, stn_trs=stn_trs, arr_trs=arr_trs, assoc_xd=assoc_xd, $
        plane_syncing=plane_syncing, tiepoint_syncing=tiepoint_syncing, $
	curve_syncing=curve_syncing, activation_syncing=activation_syncing, action_syncing=action_syncing, slave_overlays=slave_overlays, $
	position=position, delay_overlays=delay_overlays, auto_stretch=auto_stretch, $
	render_rgb=render_rgb, render_current=render_current, render_spawn=render_spawn, $
	render_auto=render_auto, render_sky=render_sky, render_numbra=render_numbra, render_sampling=render_sampling, $
	render_minimum=render_minimum, guideline=guideline, integer_zoom=integer_zoom, $
     ;----- extra keywords for plotting only ----------
	color=color, xrange=xrange, yrange=yrange, thick=thick, nsum=nsum, ndd=ndd, $
        xtitle=xtitle, ytitle=ytitle, psym=psym, title=title
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
@grim_block.include
@grim_constants.common

 if(keyword_set(tag)) then $
  begin
   _grn = grim_tag_to_grn(tag)
   if(_grn NE -1) then grn = _grn $
   else new = 1
  end

 if(keyword_set(exit)) then $
  begin
   grim_exit, grn=grn
   return
  end

 grim_constants

 grim_rc_settings, rcfile='.ominas/grimrc', keyvals=keyvals, $
	cmd=cmd, $
	new=new, xsize=xsize, ysize=ysize, mode_init=mode_init, $
	zoom=zoom, rotate=rotate, order=order, offset=offset, filter=filter, retain=retain, $
	path=path, save_path=save_path, load_path=load_path, symsize=symsize, $
        overlays=overlays, exclude_overlays=exclude_overlays, menu_fname=menu_fname, cursor_swap=cursor_swap, $
	fov=fov, clip=clip, menu_extensions=menu_extensions, button_extensions=button_extensions, arg_extensions=arg_extensions, arg_menus=arg_menus, $
	cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, lgt_trs=lgt_trs, stn_trs=stn_trs, arr_trs=arr_trs, $
	hide=hide, mode_args=mode_args, xzero=xzero, lights=lights, $
        psym=psym, nhist=nhist, maintain=maintain, ndd=ndd, workdir=workdir, $
        activate=activate, frame=frame, compress=compress, loadct=loadct, max=max, $
	extensions=extensions, beta=beta, rendering=rendering, npoints=npoints, $
        plane_syncing=plane_syncing, tiepoint_syncing=tiepoint_syncing, curve_syncing=curve_syncing, activation_syncing=activation_syncing, action_syncing=action_syncing, $
	visibility=visibility, channel=channel, render_numbra=render_numbra, render_sampling=render_sampling, $
	render_minimum=render_minimum, slave_overlays=slave_overlays, rgb=rgb, $
	delay_overlays=delay_overlays, auto_stretch=auto_stretch, guideline=guideline, $
	render_rgb=render_rgb, render_current=render_current, render_spawn=render_spawn, render_auto=render_auto, render_sky=render_sky, $
        integer_zoom=integer_zoom, settings_overlays=settings_overlays

 if(keyword_set(ndd)) then dat_set_ndd, ndd

; move to grim_add_planes...
if(NOT keyword_set(render_spawn)) then render_spawn = 1
if(NOT keyword_set(render_sampling)) then render_sampling = 1
if(NOT keyword_set(render_numbra)) then render_numbra = 1
if(NOT defined(render_minimum)) then render_minimum = 2
if(NOT defined(render_rgb)) then render_rgb = 1
if(NOT defined(render_current)) then render_current = 0
if(NOT defined(render_sky)) then render_sky = 0
if(NOT defined(render_auto)) then render_auto = 0



 if(NOT keyword_set(lights)) then lights = 'SUN'

 if(NOT keyword_set(menu_extensions)) then $
                                     menu_extensions = 'grim_default_menus' $
 else if(strmid(menu_extensions[0],0,1) EQ '+') then $
  begin
   menu_extensions[0] = strmid(menu_extensions[0], 1, strlen(menu_extensions[0])-1)
   menu_extensions = ['grim_default_menus', menu_extensions]
  end

 ;=========================================================
 ; cursor modes
 ;=========================================================
 cursor_modes = grim_create_cursor_mode('activate', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('zoom_plot', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('zoom', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('pan_plot', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('pan', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('readout', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('tiepoints', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('curves', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('mask', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('magnify', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('xyzoom', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('remove', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('trim', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('select', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('region', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('smooth', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('plane', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('drag', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('notes', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('target', mode_args, cursor_modes)
 cursor_modes = grim_create_cursor_mode('navigate', mode_args, cursor_modes)

 ;-------------------------------------------
 ; cursor mode extensions
 ;-------------------------------------------
 n_ext = n_elements(button_extensions)
 if(n_ext GT 0) then $
  begin
   if(NOT keyword_set(arg_extensions)) then arg_extensions = lonarr(n_ext)
   for i=0, n_ext-1 do $
    begin
     if(size(arg_extensions, /type) EQ 10) then arg_extension = *arg_extensions[i] $
     else arg_extension = arg_extensions[i]
    
     cursor_modes = append_array(cursor_modes, $
        grim_create_cursor_mode(button_extensions[i], arg_extension, /no_prefix))
    end
  end


 ;=========================================================
 ; input defaults
 ;=========================================================
 new = keyword_set(new)
 if(NOT keyword_set(fov)) then fov = 0
 if(NOT keyword_set(clip)) then clip = 0
 if(NOT defined(hide)) then hide = 1
 if(n_elements(retain) EQ 0) then retain = 2
 if(n_elements(maintain) EQ 0) then maintain = 1
 if(NOT keyword_set(compress)) then compress = ''
 if(NOT keyword_set(extensions)) then extensions = ''
 if(NOT keyword_set(trs)) then trs = ''
 if(NOT keyword_set(cam_trs)) then cam_trs = ''
 if(NOT keyword_set(plt_trs)) then plt_trs = ''
 if(NOT keyword_set(rng_trs)) then rng_trs = ''
 if(NOT keyword_set(str_trs)) then str_trs = ''
 if(NOT keyword_set(stn_trs)) then stn_trs = ''
 if(NOT keyword_set(arr_trs)) then arr_trs = ''
 if(NOT keyword_set(lgt_trs)) then lgt_trs = ''
 
 if(NOT keyword_set(title)) then title = ''
 if(NOT keyword_set(xtitle)) then xtitle = ''
 if(NOT keyword_set(ytitle)) then ytitle = ''

 ;=========================================================
 ; resolve arguments
 ;=========================================================
 grim_get_args, arg1, arg2, dd=dd, grn=grn, display_type=type, $
             nhist=nhist, maintain=maintain, compress=compress, $
             overlays=overlays, extensions=extensions, rgb=rgb

; if(keyword_set(rendering)) then ....

 if(NOT keyword_set(grim_get_data())) then new = 1

 if(NOT keyword_set(mode_init)) then $
  begin
   if(type EQ 'PLOT') then mode_init = 'grim_mode_zoom_plot' $
   else mode_init = 'grim_mode_activate'
  end


 if(keyword_set(xsize)) then default_xsize = xsize $
 else $
  begin
   if(type EQ 'PLOT') then xsize = 500 $
   else default_xsize = 768
  end
 if(keyword_set(ysize)) then default_ysize = ysize $
 else $
  begin
   if(type EQ 'PLOT') then ysize = 500 $
   else default_ysize = 768
  end


 ;=========================================================
 ; if new instance, set up widgets and data structures
 ;=========================================================
 if(new) then $
  begin
   ;-----------------------------
   ; defaults
   ;-----------------------------
   if(NOT keyword_set(dd)) then $
    begin
     dd = dat_create_descriptors(1, data=grim_blank(default_xsize, default_ysize), $
          name='BLANK', nhist=nhist, maintain=maintain, compress=compress)
    end
   if(NOT keyword_set(zoom)) then zoom = grim_get_default_zoom(dd[0])

   ;----------------------------------------------
   ; initialize data structure and common block
   ;----------------------------------------------
   grim_data = grim_init(dd, dd0=dd0, zoom=zoom, wnum=wnum, grn=grn, tag=tag, type=type, $
       filter=filter, retain=retain, user_callbacks=user_callbacks, $
       user_psym=user_psym, path=path, save_path=save_path, load_path=load_path, $
       cursor_swap=cursor_swap, fov=fov, clip=clip, hide=hide, $
       cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, stn_trs=stn_trs, lgt_trs=lgt_trs, arr_trs=arr_trs, $
       cam_select=cam_select, plt_select=plt_select, rng_select=rng_select, str_select=str_select, stn_select=stn_select, arr_select=arr_select, sun_select=sun_select, $
       cmd=cmd, color=color, xrange=xrange, yrange=yrange, position=position, thick=thick, nsum=nsum, $
       psym=psym, xtitle=xtitle, ytitle=ytitle, cursor_modes=cursor_modes, workdir=workdir, $
       symsize=symsize, nhist=nhist, maintain=maintain, lights=lights, $
       compress=compress, extensions=extensions, max=max, beta=beta, npoints=npoints, $
       visibility=visibility, channel=channel, keyvals=keyvals, $
       title=title, slave_overlays=slave_overlays, guideline=guideline, $
       render_rgb=render_rgb, render_current=render_current, render_spawn=render_spawn, render_minimum=render_minimum, $
       render_auto=render_auto, render_sky=render_sky, render_numbra=render_numbra, render_sampling=render_sampling, $
       overlays=overlays, activate=activate)


   ;----------------------------------------------
   ; initialize overlay settings
   ;----------------------------------------------
   grim_initial_overlay_settings, grim_data, settings_overlays


   ;----------------------------------------------
   ; initialize colors common block
   ;----------------------------------------------
   if(NOT defined(loadct)) then loadct = 0
   if(NOT keyword_set(r_curr)) then loadct, loadct
   ctmod

   ;-----------------------------
   ; widgets
   ;-----------------------------
   if(type NE 'PLOT') then grim_get_window_size, grim_data, xsize=xsize, ysize=ysize
   grim_widgets, grim_data, xsize=xsize, ysize=ysize, cursor_modes=cursor_modes, $
         menu_fname=menu_fname, menu_extensions=menu_extensions

   grn = grim_data.grn 

   planes = grim_get_plane(grim_data, /all)
   for i=0, n_elements(planes)-1 do planes[i].grn = grn
   grim_set_plane, grim_data, planes

   grim_set_mode, grim_data, mode_init, /init
   grim_set_data, grim_data, grim_data.base

   grim_resize, grim_data, /init
   widget_control, grim_data.base, map=1
   widget_control, grim_data.draw_base, map=1;, $
             ; xsize=xsize, ysize=ysize;, xoff=SCALE_WIDTH, yoff=SCALE_WIDTH


   geom = widget_info(grim_data.base, /geom)
   grim_data.base_xsize = geom.xsize
   grim_data.base_ysize = geom.ysize

   ;----------------------------------------------
   ; store initial tvim settings
   ;----------------------------------------------
   grim_wset, grim_data, /save

   ;----------------------------------------------
   ; register data descriptor events
   ;----------------------------------------------
   nv_notify_register, dd, 'grim_descriptor_notify', scalar_data=grim_data.base

   xmanager, 'grim', grim_data.base, $
                 /no_block, modal=modal, cleanup='grim_kill_notify'
   if(keyword_set(modal)) then return
  end


 ;======================================================================
 ; change to new window if specified
 ;======================================================================
 if(defined(grn)) then $
  begin
   grim_data = grim_get_data(grn=grn)
   grim_wset, grim_data
  end


 ;===========================================================================
 ; Update descriptors if any given
 ;  To sort descriptors into their appropriate planes, gds are compared 
 ;  to planes.dd, or to assoc_xd if given.  If cd is a MAP, then descriptors
 ;  are sorted by od, if given.  Note that cd and od are not sorted; there 
 ;  must either be one given for each, or a single descriptor given, which 
 ;  is applied to the current plane.  If dds are supplied to an existing
 ;  GRIM, then there must be one per plane.
 ;===========================================================================
 grim_data = grim_get_data()
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 if(NOT new) then if(keyword_set(dd)) then $
  begin
   if(nplanes NE n_elements(dd)) then $
         nv_message, 'Inconsistent inputs', $
         explanation='Did you forget to specify /new?'

   for i=0, nplanes-1 do planes[i].dd = dd[i]
   grim_set_plane, grim_data, planes
  end

 if(NOT keyword_set(_cd)) then _cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(_od)) then _od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(pd)) then pd = dat_gd(gd, dd=dd, /pd)
 if(NOT keyword_set(rd)) then rd = dat_gd(gd, dd=dd, /rd)
 if(NOT keyword_set(sd)) then sd = dat_gd(gd, dd=dd, /sd)
 if(NOT keyword_set(std)) then std = dat_gd(gd, dd=dd, /std)
 if(NOT keyword_set(ard)) then ard = dat_gd(gd, dd=dd, /ard)
 if(NOT keyword_set(ltd)) then ltd = dat_gd(gd, dd=dd, /ltd)

 _assoc_xd = planes.dd
 if(keyword_set(assoc_xd)) then _assoc_xd = assoc_xd

 ;------------------------------------------------------------
 ; must be either one cd or one per plane...
 ;------------------------------------------------------------
 if(keyword_set(_cd)) then $
  begin
   ncd = n_elements(_cd)
   cd = objarr(nplanes)
   if(ncd EQ 1) then cd[plane.pn] = _cd $
   else if(ncd EQ nplanes) then cd = _cd $
   else nv_message, 'One camera descriptor or one per plane required.'
  end

 ;------------------------------------------------------------
 ; must be either one od or one per plane...
 ;------------------------------------------------------------
 if(keyword_set(_od)) then $
  begin
   nod = n_elements(_od)
   od = objarr(nplanes)
   if(nod EQ 1) then od[plane.pn] = _od $
   else if(nod EQ nplanes) then od = _od $
   else nv_message, 'One observer descriptor or one per plane required.'
  end

 ;------------------------------------------------------------
 ; If cd is a map, the sort against od
 ;------------------------------------------------------------
 if(keyword_set(cd)) then $
  begin
   w = where(cor_class(cd) EQ 'MAP')
   if(w[0] NE -1) then $
     if(keyword_set(od)) then _assoc_xd[w] = od
  end

 ;------------------------------------------------------------
 ; Sort inputs
 ;------------------------------------------------------------
 for i=0, nplanes-1 do $
  begin
   if(keyword_set(od)) then $
      grim_add_xd, grim_data, planes[i].od_p, od[i], /one, /noregister
   if(keyword_set(cd)) then $
      grim_add_xd, grim_data, planes[i].cd_p, cd[i], /one

   grim_add_xd, grim_data, planes[i].pd_p, pd, assoc_xd=_assoc_xd[i]
   grim_add_xd, grim_data, planes[i].rd_p, rd, assoc_xd=_assoc_xd[i]
   grim_add_xd, grim_data, planes[i].std_p, std, assoc_xd=_assoc_xd[i]
   grim_add_xd, grim_data, planes[i].ard_p, ard, assoc_xd=_assoc_xd[i]
   grim_add_xd, grim_data, planes[i].sd_p, sd, assoc_xd=_assoc_xd[i]
   grim_add_xd, grim_data, planes[i].ltd_p, ltd, /one, assoc_xd=_assoc_xd[i]

;   grim_activate_xd, planes[i], grim_xd(planes[i]), /deactivate
  end


 ;-------------------------
 ; parse overlay exlusions
 ;-------------------------
 grim_parse_overlay_exclusions, grim_data, exclude_overlays


 ;=========================================================
 ; if no data, set default parameters
 ;=========================================================
 for i=0, n_elements(dd)-1 do $
  if(NOT keyword_set(dat_dim(dd[i]))) then $
   begin
    if(keyword_set(cd)) then cam_size = image_size(cd) $
    else cam_size = [512,512]
    dat_set_maintain, dd[i], 0, /noevent
    dat_set_compress, dd[i], compress, /noevent
    dat_set_data, dd[i], grim_blank(cam_size[0], cam_size[1]) , /noevent
   end


 ;=========================================================
 ; if new instance, setup initial view
 ;=========================================================
 if(new) then $
  begin
   grim_set_primary, grim_data.base

   ;----------------------------------------------
   ; sampling
   ;----------------------------------------------
   if(type NE 'PLOT') then $
      for i=0, nplanes-1 do $
         dat_set_sampling_fn, planes[i].dd, 'grim_sampling_fn', /noevent

;   entire = 1 & default = 0
   default = 0
   if(type EQ 'PLOT') then $
    begin
     entire = 0 & default = 1
    end

   ;----------------------------------------------
   ; initial settings
   ;----------------------------------------------
   widget_control, grim_data.draw, /hourglass
   if(NOT keyword_set(no_refresh)) then $
     grim_refresh, grim_data, default=default, entire=entire, $
	xsize=xsize, ysize=ysize, $
	xrange=planes[0].xrange, yrange=planes[0].yrange, $
	zoom=zoom, $
	rotate=rotate, $
	order=order, $
	offset=offset, /no_plot, /no_objects
  end $
 ;=========================================================
 ; if not new instance, just tvim with new settings
 ;=========================================================
 else $
  begin
   grim_data = grim_get_data()

   widget_control, grim_data.draw, /hourglass
   if(NOT keyword_set(no_refresh)) then $
     grim_refresh, grim_data, $
	default=default, previous=previous, restore=restore, $
	doffset=doffset, $
	zoom=zoom, $
	rotate=rotate, $
	order=order, $
	offset=offset, no_erase=no_erase
  end


 ;----------------------------------------------
 ; add any callbacks
 ;----------------------------------------------
 if(keyword_set(refresh_callbacks)) then $
        grim_add_refresh_callback, refresh_callbacks, refresh_callback_data_ps

 if(keyword_set(plane_callbacks)) then $
        grim_add_plane_callback, plane_callbacks, plane_callback_data_ps


 ;----------------------------------------------
 ; initial framing
 ;----------------------------------------------
 if(keyword_set(frame)) then $
        grim_initial_framing, grim_data, frame, delay_overlays=delay_overlays


 ;-------------------------
 ; save initial view
 ;-------------------------
 grim_save_initial_view, grim_data
 

 ;----------------------------------------------
 ; initial toggles
 ;----------------------------------------------
 if(keyword_set(plane_syncing)) then $
                   grim_set_toggle_flag, grim_data, 'PLANE_SYNCING', 1
 if(keyword_set(tiepoint_syncing)) then $
                   grim_set_toggle_flag, grim_data, 'TIEPOINT_SYNCING', 1
 if(keyword_set(curve_syncing)) then $
                   grim_set_toggle_flag, grim_data, 'CURVE_SYNCING', 1
 if(keyword_set(activation_syncing)) then $
                   grim_set_toggle_flag, grim_data, 'ACTIVATION_SYNCING', 1
 if(keyword_set(action_syncing)) then $
                   grim_set_toggle_flag, grim_data, 'ACTION_SYNCING', 1
 if(keyword_set(highlght)) then $
                   grim_set_toggle_flag, grim_data, 'PLANE_HIGHLIGHT', 1
 if(keyword_set(integer_zoom)) then $
                   grim_set_toggle_flag, grim_data, 'INTEGER_ZOOM', 1


 ;----------------------------------------------
 ; if new instance, initialize menu extensions
 ;----------------------------------------------
 if(new) then $
  begin
   if(keyword_set(menu_extensions)) then $
    begin
     for i=0, n_elements(menu_extensions)-1 do $
         if(routine_exists(menu_extensions[i]+'_init')) then $
                  call_procedure, menu_extensions[i]+'_init', grim_data, arg_menus
    end
  end



 ;---------------------------------------------------------
 ; if new instance, initialize menu toggles and values
 ;---------------------------------------------------------
 if(new) then $
  begin
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_toggle_plane_syncing_event', $
          grim_get_toggle_flag(grim_data, 'PLANE_SYNCING')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_toggle_tiepoint_syncing_event', $
          grim_get_toggle_flag(grim_data, 'TIEPOINT_SYNCING')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_toggle_curve_syncing_event', $
          grim_get_toggle_flag(grim_data, 'CURVE_SYNCING')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_toggle_activation_syncing_event', $
          grim_get_toggle_flag(grim_data, 'ACTIVATION_SYNCING')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_toggle_action_syncing_event', $
          grim_get_toggle_flag(grim_data, 'ACTION_SYNCING')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_plane_highlight_event', $
          grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')
   grim_update_menu_toggle, grim_data, $
         'grim_menu_view_zoom_force_integer_event', $
          grim_get_toggle_flag(grim_data, 'INTEGER_ZOOM')
  end



 ;----------------------------------------------
 ; initial rendering
 ;----------------------------------------------
 if(plane.render_auto) then $
  begin
   for i=0, nplanes-1 do grim_render, grim_data, plane=planes[i]
   grim_jump_to_plane, grim_data, plane.pn
  end


 ;-------------------------
 ; initial color stretch
 ;-------------------------
 if(keyword_set(auto_stretch)) then grim_stretch_plane, grim_data, planes

 ;-------------------------
 ; draw initial image
 ;-------------------------
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, no_erase=no_erase

 ;-------------------------
 ; initial overlays
 ;-------------------------
 if(NOT keyword_set(delay_overlays)) then $
  for i=0, nplanes-1 do $
         grim_initial_overlays, grim_data, plane=planes[i], overlays


 ;----------------------------------------------
 ; if new instance, initialize cursor modes
 ;----------------------------------------------
 if(new) then $
  for i=0, n_elements(cursor_modes)-1 do $
   begin
    refresh = 0
    if(routine_exists(cursor_modes[i].name+'_init')) then $
     begin
      call_procedure, cursor_modes[i].name+'_init', grim_data, cursor_modes[i].data_p
      refresh = 1
     end
   end

 ;-------------------------
 ; draw initial image
 ;-------------------------
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /no_image

end
;=============================================================================
