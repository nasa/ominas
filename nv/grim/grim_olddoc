;=============================================================================
;+
; NAME:
;	GRIM
;
;
; PURPOSE:
;	General-purpose GRaphical Interface for oMinas.
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	
;	grim, arg1, arg2
;
;
; ARGUMENTS:
;  INPUT:
;	arg1, arg2:	
;		Grim accepts up to two arguments, which can appear in either 
;		order.  Possible arguments are:
;
; 			data descriptors (object)
;			file specification (string)
; 			grn (scalar)
; 			plot (1d array)
; 			image (2d array)
; 			cube (3d array)
;
;	Plots are displayed as graphs whose abscissa are the array index, unless
;	an abscissa is present in the data descriptor.  Many functions are not 
;	available in this mode.  
;
;	Cubes are handled as multiple image planes unless /rgb is used 
;	(see below).  All grim planes will contain the same data array,
;	but display only data ranges corresponding to one channel of the cube.
;	For /rgb (assuming the cube has three channels), the data are placed 
;	on a single image plane with each cube channel assigned the R, G, or B 
;	color channel.
;	
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	Descriptor Keywords
;	-------------------
;	The following inputs replace objects already maintained by GRIM.  They
;	must be given as either a single element, which is applied to the 
;	current plane, or as an array with one element for each plane.  
;
;	 cd:	Replaces the current camera descriptor.  This may also be 
;		a map descriptor, in which case some of GRIM's functions 
;		will not be available.  When using a map descriptor instead 
;		of a camera descriptor, you can specify a camera descriptor 
;		as the observer descriptor (see the 'od' keyword below) and 
;		some additional geometry functions will be available.
;
;	 od:	Replaces the current observer descriptor.  The observer
;		descriptor is used to allow some geometry objects (limb,
;		terminator) to be computed when using a map descriptor instead
;		of a camera descriptor.
;
;	The following inputs replace or augment objects already maintained 
;	by GRIM.  They are sorted into their respective planes by comparing 
;	their internal generic descriptors with the data descriptor or 
;	observer descriptor (in the case of a map) for each plane.  Objects
;	whose names match those already maintained by GRIM replace them.
;
;	 sund:	Replaces the current sun descriptor.
;
;	 pd:	Adds/replaces planet descriptors.
;
;	 rd:	Adds/replaces ring descriptors.
;
;	 sd:	Adds/replaces star descriptors.
;
;	 std:	Adds/replaces station descriptors
;
;	 ard:	Adds/replaces array descriptors
;
;	 gd:	Generic descriptor containing some or all of the above 
;		descriptors.
;
;	 assoc_xd: 
;		If given, use these descriptors to sort descriptors into 
;		planes instead of matching the data descriptors or observer
;		descriptors in their internal generic descriptors.
;
;
;	Descriptor Select Keywords
;	--------------------------
;	Descriptor select keywords (see pg_get_*) are specified using the
;	standard prefix corresponding to the descriptor type.  For example, 
;	the fov keyword to pg_get_planets would be given to grim as plt_fov.  
;
;
;	Initial Colormap Keywords
;	-------------------------
;	The colormap structure (see colormap_descriptor__define) can be
;	be initialized via keywords prefied with 'cmd_', e.g., 'cmd_shade'.
;	In addition, the following keywords apply to the initial color map:
;
;	*auto_stretch:
;		If set, the color table for each plane is automatically
;		stretched.  This is identical to using the 'Auto' button
;		on on the grim color tool.
;
;
;	Translator Keywords
;	-------------------
;	The following keywords are passed directly to the translators, which
;	are responsible for interpreting their meanings.
;
;	*cam_trs:
;		String giving translator keywords for the camera descriptors.
;
;	*sun_trs: 
;		String giving translator keywords for the sun descriptors.
;
;	*plt_trs: 
;		String giving translator keywords for the planet descriptors.
;
; 	*rng_trs: 
;		String giving translator keywords for the ring descriptors.
;
; 	*str_trs: 
;		String giving translator keywords for the star descriptors.
;
; 	*stn_trs: 
;		String giving translator keywords for the stations descriptors.
;
; 	*arr_trs: 
;		String giving translator keywords for the array descriptors.
;
;
;	TVIM Keywords
;	-------------
;	The following keywords set the initial viewing parameters and are
;	simply passed to TVIM.  
;
;	*xsize:	Size of the graphics window in the x direction.  Defaults to
;		400 pixels.
;
;	*ysize:	Size of the graphics window in the y direction.  Defaults to
;		400 pixels.
;
;	*zoom:	Initial zoom to be applied to the image.  If not given, grim
;		computes an initial zoom such that the entire image fits on the
;		screen.
;
;	*rotate:	
;		Initial rotate value to be applied to the image (as in the IDL
;		ROTATE routine).  If not given, 0 is assumed.
;
;	*order:	Initial display order to be applied to the image.
;
;	*offset:	
;		Initial offset (dx,dy) to be applied to the image.
;	
;	 doffset: 
;		Change the offset viewing parameter by this amount.
;
;	 default: 
;		If set, use default tvim properties (zoom=[1,1], offset=[0,0]
;               order=0 [bottom-up])
;
;	 previous: 
;		If set, restore last-used tvim viewing parameters.
;
;	 restore: 
;		If set, use saved tvim viewing paramters.
;
;
;	Customization Keywords
;	----------------------
;	*menu_extensions:
;		Array of strings giving the names of functions that return
;		menu definitions, as defined by cw_pdmenu.  These menus are 
;		added to the built-in GRIM menus between the Overlays menu
;		and the Help menu.  The default is 'grim_default_menus'.  If
;		the first character in the first menu function is '+', then
;		grim_default_menus is retained an the new menu are appended
;		after that menu.  Otherwise, 'grim_default_menus' is replaced.
;
;	*button_extensions:
;		Array of strings giving the names of definition functions
;		for custom cursor modes to be added after the built-in
;		cursor modes.  The definition function takes one argument 
;		(see arg_extensions below) and returns a grim_user_mode_struct.
;
;	*arg_extensions:
;		Argument to be provided to the button extension definition
;		function above. 
;
;	*menu_fname:	
;		Name of a file containing additional menus to add to
;		the grim widget.  The file syntax follows that for cw_pdmenu.
;
;
;	Other Keywords
;	--------------
;	*extensions:
;		String array giving extensions to try for each input file.
;		see dat_read.
;
;	*new:	If set, a new grim instance is created and all keywords apply
;		to that instance.
;
;	 erase:	If set, erase the current image before doing anything else.
;
;	*mode_init:
;		Initial cursor mode.  See below.
;
;	*mode_args:
;		Array giving arguments for the cursor modes initialization
;		functions.  If a string, then syntax is NAME:ARG, where NAME 
;		is the name of the cursor mode, and ARG is the argument for 
;		that mode.  For example:
;
;			mode_args='READOUT:myreadout_fn'
;
;		would cause the function 'myreadout_fn' to be added to 
;		the list of functions called by pg_cursor and pg_measure
;		via the readout cursor mode.  If not a string, the argument 
;		is passed to the initialization function with no processing.
;
;	*retain:	
;		Retain settings for backing store (see "backing store" in 
;		the IDL reference guide).  Defaults to 2.
;
;	*clip:	Controls the number of fields of view in which overlays are 
;		computed.
;
;	*fov:	Controls the number of fields of view in which to request
;		planet, ring and star descriptors.  Values are as follows:
;
; 			 0 : get all descriptors
;                  	<0 : relative to viewport
;                 	>0 : relative to image / optic axis
;
;		Note that fov > 0 is the same as setting the fov descriptor
;		select keywords (see above).  Default is 0, but stars operate
;		best when fov > 0.
;
;	*hide:	If set, overlays are hidden w.r.t shadows and obstructions.
; 		Default is on. 
;
;	 no_erase: 
;		If set, GRIM does not erase the draw windoww.
;
;	no_refresh:
;		If set, grim does not refresh.
;
;	*rgb:	If set, grim interprets a 3-plane cube as a 3-channel image
;               to be displayed on a single plane.
;
;	*channel: 
;		Array of bitmasks specifying the color channel in which to 
;		display each given image: 1b, 2b, or 4b.
;
;	*visibility: 
;		Initial visibility setting for planes:
;
;                	0: Only the current plane is drawn.
;                	1: All planes are drawn.
;
;                Default is 0.
;
;	*max:	Maximum data value to scale to when displaying images.  
;		Values larger than this are set to the maximum color table 
;		index.  If not set, the maximum value in the data set is used.  
;		In cases where the data array is being subsampled, this value 
;		may not be known, resulting in varying image scaling as more 
;		and more data values are sampled.  That problem may be
;		eliminated via this keyword.
;
;	 exit:	If set, GRIM immediately exits.  This can be used to kill an
;		existing GRIM window.
;
;	 modal:	If set, grim is run as a modal widget, i.e., there is no command
;		prompt.
;
;	*frame:	If set, the initial view is set such that all members of the 
;		named overlay types are are visible.  If /frame, then all
;		overlays are framed.  Note that object types that rely on the
;		view to determine which objects to compute (e.g., stars) 
;		cannot be framed in this way.  
;
;	 refresh_callbacks: 
;		Array of strings giving the names of procedures to be 
;		called after each refresh.  See CALLBACK PROCEDURES
;		below.  Refresh callbacks receive only the data argument.
;
;	 refresh_callback_data_ps: 
;		Array of pointers (one per callback) to data for the refresh 
;		callback procedures specified using the refresh_callbacks 
;		keyword.  See CALLBACK PROCEDURES below.  
;
;	 plane_callbacks: 
;		Array of strings giving the names of procedures to be 
;		called after each plane change.  See CALLBACK PROCEDURES
;		below.  Plane callbacks receive only the data argument.
;
;	 plane_callback_data_ps: 
;		Array of pointers (one per callback) to data for the plane 
;		callback procedures specified using the plane_callbacks 
;		keyword.  See CALLBACK PROCEDURES below.  
;
;	*nhist:	History setting to be applied to data decriptor (see 
;		ominas_data__define).  GRIM uses data descriptor history to 
;		undo changes to the data array.  If nhist is not set, or is 
;		equal to 1, the undo menu option will not function.
;
;	*maintain: 
;		If given, this maintainance setting is applied to the data
;		descriptor (see ominas_data__define).
;
;	*compress: 
;		Compression setting to be applied to data decriptor (see 
;		ominas_data__define).  
;
;	*filter:
;		Initial filter to use when loading or browsing files.
;
;	*load_path: 
;		Initial path for the file loading dialog.
;
;	*save_path: 
;		Initial path for the file saving dialog.
;
;	*path:	Sets both load_path and save_path to this value.
;
;	*workdir: 
;		Default directory for saving user points, masks, tie 
;		points, curves
;
;	 user_psym: 
;		Default plotting symbol for user overlays.  
;
;	 grn:	Identifies a specific GRIM window by number.  Grim numbers are
;		displayed in the status bar, e.g.: grim <grn>.
;
;	 pn:	Directs GRIM to change to the plane corresponding to this plane 
;		number.
;
;	*cursor_swap: 
;		If set, cursor bitmaps are byte-order swapped.
;
;	*loadct: 
;		Index of color table to load.
;
;	*beta:	If set beta features are enabled.
;
;	*npoints: 
;		Number of point to compute for various overlays.  Default is 1000.
;
; 	*plane_syncing: Turns plane syncing on (1) or off(0).  Default is 0.
;
; 	*tiepoint_syncing: Turns tiepoint syncing on (1) or off(0).  Default is 0.
;
; 	*curve_syncing: Turns curve syncing on (1) or off(0).  Default is 0.
;
; 	 position: 
;		Sets the plot position; see the POSITION grahics keyword.
;
; 	 color:	Sets the line color index for plots.  One element per plane.
;
; 	 xrange: 
;		Sets the X-axis range for plots.
;
; 	 yrange: 
;		Sets the Y-axis range for plots.
;
;	 thick:	Sets the line thickness for plots.  One element per plane.
;
;	 title:	For plots, sets the plot title for plots; one element per plane.
;		For images, sets the base default title.
;
;	 xtitle: 
;		Sets the X-axis label for plots.  One element per plane.
;
;	 ytitle: 
;		Sets the Y-axis label for plots.  One element per plane.
;
;	 psym:	Sets the plotting symbol for plots.  One element per plane.
;
;	 nsum:	See OPLOT.  One element per plane.
;
;
;	*overlays: 
;		List of initial overlays to compute on startup.  Each element
;		is of the form:
;
;                          type[:name1,name2,...]
;
;		where 'type' is one of {limb, terminator, planet_center, 
;		star, ring, planet_grid, array, station} and the names 
;		identify the name of the desired object.  Note that grim 
;		will load more objects than named if required by another 
;		startup overlay.  For example:
;
;                         overlays='ring:a_ring'
;
;		will cause only one ring descriptor to load, whereas
;
;                         overlays=['limb:saturn', 'ring:a_ring']
;
;		will cause all of Saturn's rings to load because they are
;		required in computing the limb points (for hiding).
;
;		Different results may be obtained using translator keywords, 
;		because those keywords are evaluated at the translator level.  
;		For example:
;
;			overlays='ring:fn54'
;
;		may result in no ring, while:
;
;			overlays='ring', trs_rd='name=fn54'
;
;		would be more likely to yield a ring.  In the former example,
;		the specified name is compared against whatever default ring
;		descriptors are returned by the tranlators, while in the latter
;		case, the 'name' translator keyword is compared against all
;		rings available to the translator.
; 
;
;	*delay_overlays:
;		If set, initial overlays (see 'overlays' above) are not computed 
;		until the first time they are accessed.  This option can greatly
;		improve performance in cases where a large number of image planes
;		are loaded with initial overlays, particularly if it is not
;		expected that all planes will necesarily be viewed or otherwise
;		accessed.  Typically this option will cause overlays to be
;		computed only for the initially visible planes, with other
;		planes loading overlays only as they are made visible.  However, 
;		there may be other cirumstances that can cause initial overlays 
;		to be loaded without actually viewing a plane.
; 
;	*activate: 
;		If set, inital overlay are activated.
;
;	*ndd: 	Sets the global ndd value in the OMINAS sate structure, which
;		controls the maximum number of data descriptors with maintain == 1 
;		to keep in memory at any given time
;
;	*render_sample:
;		Over-sampling value for rendering.  See pg_render.
;
;	*render_pht_min:
;		Minimum value to assign to photometric output in renderings.
;		See pg_render.
;
;
;	Incomplete Keywords
;	-------------------
;	*rendering:
;		If set, perform a rendering on the initial descriptor set.  
;
;
;  OUTPUT: NONE
;
;
; RESOURCE FILE:
;	The keywords marked above with an asterisk may be overridden using 
;	the file $HOME/.ominas/grimrc.  Keyword=value pairs may be entered, one per
;	line, using the same syntax as if the keyword were entered on the IDL 
;	command line to invoke grim.  Lines beginning with '#' are ignored.
;	Keywords entered in the resource file override the default values, and
;	are themselves overridden by keywords entered on the command line.
;
; SHELL INTERFACE
;	The 'grim' alias may be used to start grim from the shell prompt
;	via the XIDL interface.  The shell interface accepts all keywords 
;	marked above with an asterisk.  See grim.bat.
;
;	Example (assuming the grim alias described in grim.bat): 
;
;	 % grim -beta data/*.img overlay=planet_center,limb:JUPITER
;
;
; ENVIRONMENT VARIABLES:
;	Grim currently defines no environment variables..
;
;
; COMMON BLOCKS:
;	 grim_block:
;		Keeps track of most recent grim instance and which ones are 
;		selected.
;
;
; SIDE EFFECTS:
;	Grim operates directly on the memory images of the descriptors that 
;	it is given.  Therefore, those descriptors are modified during 
;	a session.  This architecture allows data to be operated on concurrently
;	through grim and from the command line; see grift.pro for details.
;
;
; LAYOUT:
;	The philosphy that drives GRIM's layout is that the maximum possible 
;	screen space should be devoted to displaying the data.  This policy 
;	allows for many GRIM windows to be used simultaneously without being 
;	obscured by crazy control panels full of buttons, gadgets, widgets, 
;	doodads, whirly-gigs, and what-nots.  The grim layout consists of the 
;	following items:
;
;	 Title bar:
;		The title bar displays the grim window number (grn),
;		the current plane number (pn), the total number of planes, the 
;		name field of the data descriptor for the current plane, the
;		default title (if given; see the title keyword above), and 
;		a string indicating which RGB channels are associated with the
;		current plane.
;
;	 Menu bar: 
;		Most of grim's functionality is accessed through the 
;		system of pulldown menus at the top.  Individual menu
;		items are described in their own sections.
;
;	 Shortcut buttons: 
;		Some commonly used menu options are duplicated as shortcut 
;		buttons arranged horizontally just beneath the menu bar.  The
;		function of each button is displayed in the status bar (see 
;		below) when the mouse cursor is hovered ove the button.
;
;	 Cursor mode buttons: 
;		Cursor mode shortcut buttons are arranged vertically along the 
;		left side of the GRIM window, and as provided as shortcuts
;		for the corresponding options in the Mode menu.  The following 
;		modes are available:
;
;		Activate: 
;			In activate mode, overlay objects may be activated
;			or deactivated by clicking and/or dragging using the
;			left or right mouse buttons respectively.  This
;			activation mechanism allows the user to select which
;			among a certain type of objects should be used in a
;			given menu selection.  A left click on an overlay
;			activates that overlay and a right click deactivates
;			it.  A double click activates or deactivates all
;			overlays associated with a given descriptor, or all
;			stars.  Active overlays appear in the colors selected
;			in the 'Overlay Settings' menu selection.  Inactive
;			overlays appear in cyan.  A descriptor is active
;			whenever any of its overlays are active.
;
;		Zoom:	The zoom button puts grim in a zoom cursor mode, wherein
;			the image zoom and offset are controlled by selecting
;			a box in the image.  When the box is created using the
;			left mouse button, zoom and offset are changed so that 
;			the contents of the box best fill the current graphics
;			window.  When the right button is used, the contents of
;			the current graphics window are shrunken so as to best
;			fill the box.  In other words, the left button zooms in
;			and the right button zooms out.
;
;		Pan: 	The pan button puts grim in a pan cursor mode, wherein the 
;			image offset is controlled by selecting an offset vector
;			using the left mouse button.  The middle button may be
;			used to center the image on a selected point.
;
;		Pixel Readout:	
;			In pixel readout mode, a text window appears 
;			and displays data about the pixel selected 
;			using the left mouse button.  
;
;		Tiepoint: 
;			In tiepoint mode, tiepoints are added using the
;			left mouse button and deleted using the right button.
;			Tiepoints appear as crosses identified by numbers.
;			The use of tiepoints is determined by the particular 
;			option selected by the user.
;
;		Curve: 
;			In curve mode, curves are added using the
;			left mouse button and deleted using the right button.
;			Curves appear as red lines identified by numbers at
;			each end.  The use of curves is determined by the 
;			particular option selected by the user.
;
;		Mask: 
;			GRIM maintains a mask for each plane whose use is
;			appication-dependent.  Mask mode allows pixels in the
;			mask to be toggled on and off.
;
;		Magnify: 
;			In magnify mode, image pixels in the graphics
;			window may be magnifed using either the right or left
;			mouse buttons.  The left button magnifies the displayed
;			pixels, directly from the graphics window.  The right
;			button magnifies the data itself, without the overlays.
;
;		XY Zoom: 
;			Same as 'zoom' above, except the aspect ratio is
;			set by the proportions of the selected box.
;
;		Remove overlays: 
;			Allows the user to remove overlay arrays.
;
;		Trim overlays: 
;			Allows the user to trim points from overlay arrays.
;
;		Select within overlays: 
;			Allows the user to select points within overlay arrays.
;
;		Define Region: 
;			Allows the user to define GRIM's region of interest.
;
;		Smooth:
;			Allows the user to select a smoothing box to be applied
;			to the data array.
;
;		Select Plane:
;			Allows the user to change planes using the pointer.  
;			This option is only useful in cases where multiple
;			planes are displayed.
;
;		Drag Image:
;			Allows the user to reposition the current plane by 
;			clicking and dragging.
;
;		Navigate:
;			Allows the user to modify the camera position and 
;			orientation usng the mouse.
;
;
;	 Graphics window: 
;		The graphics window displays the data associated with the 
;		given data descriptor using the current zoom, offset, and 
;		display order.  The edges of an image are indicated by a dotted 
;		line.  The camera optic axis is indicated by a large red cross.
;
;	 Pixel readout: 
;		The cursor position and corresponding data value are are 
;		displayed beneath the graphics window, next to the message line.
;
;	 Message line: 
;		The message line displays short messages pertaining GRIM's
;		 current state, or displayng button functions.
;
; CALLBACK PROCEDURES:
;	GRIM callback procedures are called with one or two arguments:
;       the first argument is a pointer to data that was provided
;	when the callback was added.  The second argument, if present, depends 
;	on the applicatation.  
;
;
; RESOURCE NAMES
;	The following X-windows resource names apply to grim:
;	 grim_base:		top level base
;	 grim_mbar:		menu bar
;	 grim_shortcuts_base:	base containing shortcut buttons
;	 grim_modes_base:	base containing modes buttons
;	 grim_draw:		grim draw widget
;	 grim_label:		grim bottom label widget
;
;	To turn off the confusing higlight box around the modes buttons, 
;	put the following line in your ~/.Xdefaults file:
;
;	 Idl*grim_modes_base*highlightThickness:	0
;
;
; OPERATION:
;	GRIM displays 1-, 2-, and 3-dimensional data sets.  1-dimensional 
;	data arrays are displayed as plots.  In that case, the abscissa is 
;	the sample number unless the data descriptor contains an abscissa.  
;	2- and 3-dimensional arrays are displaye as image planes.  The only 
;	difference between images and cubes in GRIM is that images planes 
;	each have their own data descriptor, while cubes are represented by 
;	multiple image planes that share a common data descriptor; each plane 
;	in a cube corresponds to a unique offset in the data array stored in 
;	the common data descriptor.  Some functionality is not available when
;	working with plots.  In that case, those options do not appear in the 
;	menus.
;
;	GRIM requests only the data samples needed for the current viewing 
;	parameters.  Therefore, GRIM can display data sets of arbitrary size
;	when used with a file reader that supports subsampling.  However, note 
;	that specific menu options may request the entire data array, depending 
;	on the application.  
;
;	Each GRIM window may contain any number of planes as well as 
;	associated geometric data (i.e. object descriptors) and overlay arrays 
;	for displaying various geometric objects -- limbs, rings, stars, etc.  
;	An array of user overlay points is maintained to be used for application-
;	specific purposes.  Generally, a set of overlay points or a descriptor 
;	must be activated in order to be used as input to a menu item; see 
;	activate mode above.  
;
;	There are exclusive and non-exclusive mechanisms for selecting grim
;	windows.  Grim windows may be non-exclusively selected using the select
;	mode button mentioned above (upper-left corner).  The exclusive
;	selection mechanism consists of a "primary" GRIM window, indicated by 
;	a red outline in the graphics window.  The primary selection is 
;	changed by pressing any mode or shortcut button, or by clicking in 
;	the graphics area of the desired grim window.  The meaning of the
;	various selections depends on the application.
;
;	The functions of the left and right mouse buttons are determined by the
;	cursor mode; some cursor modes define modifier keys to broaden the number
;	of functions available in that mode.  The middle mouse button toggles
;	the activation state of overlay arrays, or pans the image if no overlay
;	appears beneath the cursor.  The mouse wheel cycles among cursor modes, 
;	or zooms about the cursor position if the control key is held down.
;
;	Objects maintained by GRIM are accessible via the grift interface,
;	for example:
;
;		IDL> grift, dd=dd, cd=cd, pd=pd, limb_ptd=limb_ptd
;
;	returns the data desciptor, camera descriptor, planet descriptors,
;	and limb points associated with the current plane.  
;
;	GRIM registers event handlers for all of its objects, so the window
;	is updated any time an object is modifed, whether by GRIM or by some
;	other program, or from the command line.
;
;
; EXAMPLES:
;	(1) To create a new grim instance with no data:
;
;		IDL> grim, /new
;
;	(2) To create a new grim instance with data from a file of name
;	    "filename":
;
;		IDL> dd = dat_read(filename)
;		IDL> grim, dd
;
;		   or
;
;		IDL> grim, filename
;
;	(3) To give an existing grim instance a new camera descriptor:
;
;		IDL> grim, cd=cd
;
;
; KNOWN BUGS:
;	Window resizing is not precise.  GRIM tries to resize to the selected
;	size, but typically overshoots.  This is probably platform-dependent.
;
;	Objects inherited by rendering planes do not respond to events.
;
;	Image shifting:
;	 -  Descriptors not updated if shift performed form another window
;	    because the there's no way for the irst window to know to
;	    update its descriptors
;        - fix wrap-around; clip instead
;
;	Plane->Coregister does not update descriptors
;
;	Navigate mode gets weird when you do certain modifer key presses
;	   --> maybe a conflict with <ctrl> wheel zoom action
;
;	Crashes occur with File->Close
;
;	/no_erase is not enabled for images, just plots.  Probably should fix 
;	that.
;
;	Initial visibility setting does not seem to work until applied
;	using plane settings window.
;
;	/frame causes a crash if there are no initial overlays.
;
;	It's not clear whether the symsize keyword is actually used.
;
;	pn keyword does not function.
;
;	Crash when tiepoint syncing is on and tiepoint selected with
;	multiple planes.
;
;	Title keyword does not properly map multiple elements to multiple
;	planes.
;
;	Nsum keyword does not properly map multiple elements to multiple
;	planes.
;
;	Plane syncing appears to be incomplete and I don't remember what it
;	was supposed to be.  I'm sure it was awesome, though.
;
;	Not sure what slave_overlays keyword does, or was supposed to do.
;
;	Overlays on rendered planes do not respond to events
;
;	Menu toggles don't update propoerly in some circumsumstances.
;
;	grim_message sometimes pops up messages from nv_message, which can
;	be pretty obnxious.  This probably has to do with the calls to
;	grim_message in grim_compute.include
;
;	Overlay point selections are not retained after recomputing
;
;	Undo does not seem to be working
;
;
;
; STATUS:
;	Incomplete.
;
;
; SEE ALSO:
;	grift, graft
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale 7/2002
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
; grim_test_motion_event
;
;=============================================================================
function grim_test_motion_event, event

 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then return, 1

 if(struct EQ 'WIDGET_DRAW') then if(event.type EQ 2) then return, 1

 return, 0
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
; grim_write_ptd
;
;=============================================================================
pro grim_write_ptd, grim_data, filename

 xoff = 0.5
 yoff = 2.0
 bits_per_pixel = 8

 ;--------------------------------------------------------------
 ; set coord. sys and get clipped, scaled image
 ;--------------------------------------------------------------
 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 grim_refresh, grim_data, tvimage=_tvimage, $
                                    /no_back, /no_context, /no_callback

 ;--------------------------------------------------------------
 ; find device coords of image corners
 ;--------------------------------------------------------------
 s = size(grim_image(grim_data, plane=plane))
 xsize = s[1]
 ysize = s[2]

 p = fix(convert_coord(0d,0d, /data, /to_device, /double))
 q = fix(convert_coord(double(xsize-1),double(ysize-1), /data, /to_device)) - 1

 x0 = min([p[0], q[0]])
 x1 = max([p[0], q[0]])
 y0 = min([p[1], q[1]])
 y1 = max([p[1], q[1]])

 if(tvd.order) then $
  begin
   yy0 = y0
   yy1 = y1
   y0 = !d.y_size-1 - yy1
   y1 = !d.y_size-1 - yy0
  end

 x0 = x0 > 0
 x1 = x1 < !d.x_size-1
 y0 = y0 > 0
 y1 = y1 < !d.y_size-1

 ;--------------------------------------------------------------
 ; trim image, allowing a bit of safety
 ;--------------------------------------------------------------
 xs = x1-x0-2
 ys = y1-y0-2
 _tvimage = _tvimage[0:xs, 0:ys]

 x1 = x0 + xs
 y1 = y0 + ys

 ;--------------------------------------------------------------
 ; insert into image to plot
 ;--------------------------------------------------------------
 type = size(_tvimage, /type)
 tvimage = make_array(!d.x_size, !d.y_size, type=type)
 tvimage[x0:x1, y0:y1] = _tvimage

 ;--------------------------------------------------------------
 ; determine aspect ratio --
 ;  Currently, the overlays are not properly drawn if any edge
 ;  of the image is visible in the graphics window.
 ;--------------------------------------------------------------
 aspect = double(!d.x_size)/double(!d.y_size)
 if(aspect GE 1.0) then $
  begin
   xsize = 7.5
   ysize = xsize / aspect
  end $
 else $
  begin
   ysize = 7.5
   xsize = ysize * aspect
  end

 ;--------------------------------------------------------------
 ; Without this step, the overlays may be drawn incorrectly
 ; the first time in a session.  I don't know why.
 ;--------------------------------------------------------------
 set_plot, 'PS'
 device, /color, filename=filename, bits_per_pixel=bits_per_pixel, $
         xsize=xsize, ysize=ysize, /inches, xoffset=xoff, yoffset=yoff
 device, /close
 set_plot, 'X'


 ;--------------------------------------------------------------
 ; write the PS file 
 ;--------------------------------------------------------------
 set_plot, 'PS'
 device, /color, filename=filename, bits_per_pixel=bits_per_pixel, $
         xsize=xsize, ysize=ysize, /inches, xoffset=xoff, yoffset=yoff

 ctmod, top=top
 tv, tvimage, order=tvd.order, top=top
 grim_refresh, grim_data, tvimage=tvimage, $
           /no_image, /no_callback, /no_wset, /no_coord, /no_context, /no_back

 device, /close
 set_plot, 'X'

end
;=============================================================================



;=============================================================================
; grim_write
;
;=============================================================================
pro grim_write, grim_data, filename, filetype=filetype

 widget_control, /hourglass
 plane = grim_get_plane(grim_data)

 if(NOT keyword_set(filename)) then return

 split_filename, filename, dir, name
 if(NOT keyword_set(name)) then return

 ;---------------------------------------------
 ; prompt before overwriting existing file
 ;---------------------------------------------
 ff = file_search(filename)
 if(keyword_set(ff)) then $
  begin
   ans = dialog_message('Overwrite ' + filename + '?', /question)
   if(ans NE 'Yes') then return
  end


 grim_suspend_events

 ;---------------------------------------------
 ; output descriptors
 ;---------------------------------------------
 if(keyword_set(*plane.cd_p)) then $
  case grim_test_map(grim_data) of
    0 : $
	begin
	 pg_put_cameras, plane.dd, cd=*plane.cd_p
	 od = *plane.cd_p
	end
    1 : $
	begin
	 pg_put_maps, plane.dd, md=*plane.cd_p
	 od = *plane.od_p
	end
  endcase

 if(keyword_set(*plane.pd_p)) then $
            pg_put_planets, plane.dd, pd=*plane.pd_p, od=od

 if(keyword_set(*plane.rd_p)) then $
              pg_put_rings, plane.dd, rd=*plane.rd_p, od=od

 if(keyword_set(*plane.sd_p)) then $
              pg_put_stars, plane.dd, sd=*plane.sd_p, od=od

; if(keyword_set(*plane.std_p)) then $ 
 ;             pg_put_stations, plane.dd, std=*plane.std_p, od=od ;no such function

 if(keyword_set(*plane.ard_p)) then $
              pg_put_arrays, plane.dd, ard=*plane.ard_p, od=od

 if(keyword_set(*plane.ard_p)) then $
              pg_put_stations, plane.dd, ard=*plane.ard_p, od=od

 if(keyword_set(*plane.sund_p)) then $
              pg_put_stars, plane.dd, sd=*plane.sund_p, od=od

 grim_resume_events

 ;---------------------------------------------
 ; write data
 ;---------------------------------------------
 dat_write, filename, plane.dd, filetype=filetype

end
;=============================================================================



;=============================================================================
; grim_get_save_filename
;
;=============================================================================
function grim_get_save_filename, grim_data, filetype=filetype

 plane = grim_get_plane(grim_data)
 name = dat_filename(plane.dd)
 split_filename, name, dir, _name

 if(keyword_set(plane.save_path)) then path = plane.save_path
 if(NOT keyword_set(path)) then path = dir
 if(NOT keyword_set(path)) then path = './'


 types = strupcase(dat_detect_filetype(/all))
 w = where(strupcase(dat_filetype(plane.dd)) EQ types)

 if(w[0] NE -1) then $
   types = [types[w[0]], rm_list_item(types, w[0], only='')]

 filename = pickfiles(/one, get_path=get_path, $
               title='Select filename for saving', path=path, default=name, $
               options=['Filetype:',types], sel=filetype)

 return, filename
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

   nv_notify_unregister, plane.dd, 'grim_descriptor_notify'
   if(keyword_set(*plane.cd_p)) then nv_notify_unregister, *plane.cd_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.pd_p)) then nv_notify_unregister, *plane.pd_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.rd_p)) then nv_notify_unregister, *plane.rd_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.sd_p)) then nv_notify_unregister, *plane.sd_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.std_p)) then nv_notify_unregister, *plane.std_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.ard_p)) then nv_notify_unregister, *plane.ard_p, 'grim_descriptor_notify'
   if(keyword_set(*plane.sund_p)) then nv_notify_unregister, *plane.sund_p, 'grim_descriptor_notify'

   nv_ptr_free, [plane.cd_p, plane.pd_p, plane.rd_p, plane.sd_p, plane.std_p, plane.ard_p, plane.sund_p, $
             plane.od_p, plane.active_xd_p, plane.active_overlays_ptdp,$
             grim_get_overlay_ptdp(grim_data, plane=plane, 'LIMB'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'RING'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'TERMINATOR'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'STAR'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'STATION'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'ARRAY'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'PLANET_GRID'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'RING_GRID'), $
             grim_get_overlay_ptdp(grim_data, plane=plane, 'PLANET_CENTER'), $
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
; grim_load_files
;
;=============================================================================
pro grim_load_files, grim_data, filenames, load_path=load_path

 plane = grim_get_plane(grim_data)
 filter = plane.filter

 ;------------------------------------
 ; load each file onto a new plane
 ;------------------------------------
 nfiles = n_elements(filenames)

 first = 1
 for i=0, nfiles-1 do $
  begin
   dd = dat_read(filenames[i], nhist=grim_data.nhist, $
            maintain=grim_data.maintain, compress=grim_data.compress, extensions=grim_data.extensions)
   if(keyword_set(dd)) then $
    begin
     grim_add_planes, grim_data, dd, pn=pn, filter=filter

     if(first) then $
      begin
       first = 0
       grim_data.pn = pn[0]
      end

     plane = grim_get_plane(grim_data, pn=pn)
     plane.load_path = load_path

     grim_set_plane, grim_data, plane, pn=pn

     nv_notify_register, dd, 'grim_descriptor_notify', scalar_data=grim_data.base
   end
  end


 grim_set_data, grim_data, grim_data.base

 ;------------------------------------
 ; set initial zoom and display image
 ;------------------------------------
 dim = dat_dim(dd)
 geom = widget_info(grim_data.draw, /geom)

 zoom = double(geom.xsize) / double(dim[0])
 offset = [0d,0d]

 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 grim_refresh, grim_data, zoom=zoom, offset=offset, order=tvd.order
 grim_wset, grim_data, /save

end
;=============================================================================



;=============================================================================
; grim_deactivate_all
;
;=============================================================================
pro grim_deactivate_all, grim_data, plane

 grim_deactivate_all_overlays, grim_data, plane
 grim_deactivate_all_xds, plane

end
;=============================================================================



;=============================================================================
; grim_activate_all
;
;=============================================================================
pro grim_activate_all, grim_data, plane

 grim_activate_all_overlays, grim_data, plane
 grim_activate_all_xds, plane

end
;=============================================================================



;=============================================================================
; grim_modify_colors
;
;=============================================================================
pro grim_modify_colors, grim_data

 ctmod, top=top
 gr_colortool

end
;=============================================================================



;=============================================================================
; grim_edit_header
;
;=============================================================================
pro grim_edit_header, grim_data

 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 if(NOT widget_info(grim_data.header_text, /valid)) then $
  begin
   header = dat_header(plane.dd)   
   grim_data.header_text = $
               textedit(header, base=base, resource='grim_header', ysize=40)
   grim_data.header_base = base
   grim_set_data, grim_data
   grim_refresh, grim_data, /no_image, /no_objects
  end $
 else widget_control, grim_data.header_base, /map

; hide button

end
;=============================================================================



;=============================================================================
; grim_edit_notes
;
;=============================================================================
pro grim_edit_notes, grim_data, plane=plane

 widget_control, grim_data.draw, /hourglass

 if(NOT widget_info(grim_data.notes_text, /valid)) then $
  begin
   grim_data.notes_text = $
          textedit(*plane.notes_p, base=base, /editable, resource='grim_notes')
   grim_data.notes_base = base
   grim_set_data, grim_data
   grim_refresh, grim_data, /no_image, /no_objects
  end $
 else widget_control, grim_data.notes_base, /map

; hide button

end
;=============================================================================



;=============================================================================
; grim_user_ptd_fname
;
;=============================================================================
function grim_user_ptd_fname, grim_data, plane, basename=basename

 if(NOT keyword_set(basename)) then $
  begin
   basename = cor_name(plane.dd)
   if(NOT keyword_set(basename)) then basename = 'grim-' + strtrim(plane.pn,2)
  end

 return, grim_data.workdir + '/' + basename + '.user_ptd'
end
;=============================================================================



;=============================================================================
; grim_write_user_points
;
;=============================================================================
pro grim_write_user_points, grim_data, plane, fname=_fname

 if(NOT keyword_set(_fname)) then $
             fname = grim_user_ptd_fname(grim_data, plane) $
 else fname = _fname

 user_ptd = grim_get_user_ptd(plane=plane)

 w = where(pnt_valid(user_ptd))
 if(w[0] NE -1) then pnt_write, fname, user_ptd $
 else $
  begin
   ff = file_search(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_mask_fname
;
;=============================================================================
function grim_mask_fname, grim_data, plane, basename=basename
 if(NOT keyword_set(basename)) then basename = cor_name(plane.dd)
 return, grim_data.workdir + '/' + basename + '.mask'
end
;=============================================================================



;=============================================================================
; grim_write_mask
;
;=============================================================================
pro grim_write_mask, grim_data, plane, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_mask_fname(grim_data, plane)

 mask = *plane.mask_p
 if(mask[0] EQ -1) then return

 if(mask[0] NE -1) then write_mask, fname, mask, dim=dat_dim(plane.dd) $
 else $
  begin
   ff = file_search(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_read_user_points
;
;=============================================================================
pro grim_read_user_points, grim_data, plane

 fname = grim_user_ptd_fname(grim_data, plane)

 ff = (file_search(fname))[0]
 if(keyword_set(ff)) then user_ptd = pnt_read(ff) $
 else user_ptd = 0

 w = where(pnt_valid(user_ptd))
 if(w[0] NE -1) then $
  begin
   n = n_elements(user_ptd)
   tags = strarr(n)

   for i=0, n-1 do $
    begin
     tag = cor_name(user_ptd[i])
     tags[i] = tag
    end

   for i=0, n-1 do $
    begin
     w = where(tags EQ tags[i])
     if(w[0] NE -1) then $
      begin
       grim_add_user_points, user_ptd[w], [tags[i]], plane=plane, /no_refresh
       tags[w] = ''
      end
    end


  end

end
;=============================================================================



;=============================================================================
; grim_read_mask
;
;=============================================================================
pro grim_read_mask, grim_data, plane, fname=fname

 if(NOT keyword_set(fname)) then fname = grim_mask_fname(grim_data, plane)

 ff = (file_search(fname))[0]
 if(keyword_set(ff)) then mask = read_mask(ff, sub=sub) $
 else mask = -1

 if(mask[0] NE -1) then grim_add_mask, grim_data, sub, plane=plane, /replace, /sub

end
;=============================================================================



;=============================================================================
; grim_jumpto
;
;=============================================================================
function grim_jumpto, grim_data, id

 if(keyword_set(id)) then $
  begin
   widget_control, id, get_value=pns
   if(pns[0] EQ '') then return, 0
   widget_control, grim_data.jumpto_text, set_value=''
   w = str_isnum(pns)
   if(w[0] EQ -1) then return, 0
  end $
 else $
  begin
   done = 0
   repeat $
    begin
     pns = dialog_input('Plane number:')
     if(NOT keyword_set(pns)) then return, 0
     w = str_isnum(pns)
     if(w[0] NE -1) then done = 1
    endrep until(done)
  end

 pn = (long(pns))[0]
 grim_jump_to_plane, grim_data, pn, valid=valid

 return, valid
end
;=============================================================================



;=============================================================================
; grim_recenter
;
;=============================================================================
pro grim_recenter, grim_data, p

 cx = !d.x_size/2
 cy = !d.y_size/2
 q = convert_coord(double(cx), double(cy), /device, /to_data)

 grim_refresh, grim_data, doffset=(p-q)[0:1]

end
;=============================================================================



;=============================================================================
; grim_zoom
;
;=============================================================================
function grim_zoom, grim_data

 done = 0
 repeat $
  begin
   zs = dialog_input('New zoom:')
   if(NOT keyword_set(zs)) then return, 0
   w = str_isfloat(zs)
   if(w[0] NE -1) then done = 1
  endrep until(done)

 zoom = double(zs)
 return, zoom
end
;=============================================================================



;=============================================================================
; grim_zoom_to_cursor
;
;=============================================================================
function grim_zoom_to_cursor, zz, relative=relative, zoom=zoom

 tvim, get_info=tvd, /silent
 if(keyword_set(relative)) then zoom = tvd.zoom*zz $
 else zoom = zz

 zf = zoom / tvd.zoom

 cursor, x, y, /nowait, /data
 device_cc = transpose([transpose([0,0]), transpose([!d.x_size-1, !d.y_size-1])])
 data_cc = (convert_coord(double(device_cc[0,*]), double(device_cc[1,*]), /device, /to_data))[0:1,*]
 data_size = abs(data_cc[*,0] - data_cc[*,1])

 new_data_size = data_size/zf

 ff = [(x-tvd.offset[0])/(data_size[0]-1), (y-tvd.offset[1])/(data_size[1]-1)]
 offset = [x-new_data_size[0]*ff[0], y-new_data_size[1]*ff[1]] + 1

 return, offset
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
; grim_toggle_context
;
;=============================================================================
pro grim_toggle_context, grim_data

 ;----------------------------
 ; toggle the mapping state
 ;----------------------------
 if(grim_data.context_mapped) then grim_data.context_mapped = 0 $
 else grim_data.context_mapped = 1
 grim_set_data, grim_data, grim_data.base

 ;------------------------------------------------------
 ; if mapped, copy the image onto the window
 ;------------------------------------------------------
 if(grim_data.context_mapped) then $
  begin
   grim_refresh, grim_data, /no_main
   grim_show_context_image, grim_data
  end

 ;----------------------------
 ; set the new mapping state
 ;----------------------------
 widget_control, grim_data.context_base, map=grim_data.context_mapped

end
;=============================================================================



;=============================================================================
; grim_toggle_axes
;
;=============================================================================
pro grim_toggle_axes, grim_data

 ;---------------------------------------------------------
 ; toggle axes flag
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_data.axes_flag = NOT grim_data.axes_flag

 ;----------------------------
 ; set the new mapping state
 ;----------------------------
 widget_control, grim_data.axes_base, map=grim_data.axes_flag

 grim_set_data, grim_data, grim_data.base

 ;------------------------------------------------------
 ; if mapped, copy the image onto the window
 ;------------------------------------------------------
 if(grim_data.axes_flag) then grim_show_axes, grim_data

end
;=============================================================================



;=============================================================================
; grim_render
;
;=============================================================================
pro grim_render, grim_data, plane=plane

 if(grim_data.type EQ 'plot') then return

 ;---------------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;---------------------------------------------------------
; grim_load_descriptors, grim_data, name, plane=plane, $
;       cd=cd, pd=pd, rd=rd, sund=sund, sd=sd, ard=ard, std=std, od=od, $
;       gd=gd
 grim_load_descriptors, grim_data, 'LIMB', plane=plane


 ;---------------------------------------------------------
 ; render
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 widget_control, /hourglass


 ;---------------------------------------------------------
 ; Create new plane unless the current one is a rendering
 ;  The new plane will include a transformation that allows
 ;  the rendering to appear in the correct location in the
 ;  display relative to the data coordinate system.
 ;---------------------------------------------------------
 if(NOT plane.rendering) then $
  begin
   new_plane = grim_clone_plane(grim_data, plane=plane)
   new_plane.rendering = 1
   new_plane.dd = nv_clone(plane.dd)

   dat_set_sampling_fn, new_plane.dd, 'grim_render_sampling_fn', /noevent

   dat_set_dim_fn, new_plane.dd, 'grim_render_dim_fn'
   dat_set_dim_data, new_plane.dd, dat_dim(plane.dd)

   nv_notify_register, new_plane.dd, 'grim_descriptor_notify', scalar_data=grim_data.base

   grim_set_plane, grim_data, new_plane

   grim_jump_to_plane, grim_data, new_plane.pn
   grim_refresh, grim_data, /no_image
  end $
 else new_plane = plane


 ;---------------------------------------------------------
 ; set up grid
 ;---------------------------------------------------------
 nv_suspend_events

 device_pts = gridgen([!d.x_size,!d.y_size])
 image_pts = (convert_coord(device_pts, /device, /to_data))[0:1,*]
 image_pts = reform(image_pts, 2, !d.x_size,!d.y_size, /over)

 dat_set_sampling_data, new_plane.dd, image_pts
 grim_set_plane, grim_data, new_plane
 grim_set_data, grim_data, grim_data.base


 ;---------------------------------------------------------
 ; perform rendering
 ;---------------------------------------------------------
 grim_render_image, grim_data, plane=new_plane, image_pts=image_pts

 nv_resume_events

 grim_refresh, grim_data

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
; grim_repeat
;
;=============================================================================
pro grim_repeat, grim_data

 if(keyword_set(grim_data.repeat_fn)) then $
             call_procedure, grim_data.repeat_fn, *grim_data.repeat_event_p

end
;=============================================================================



;=============================================================================
; grim_exit
;
;=============================================================================
pro grim_exit, grim_data, grn=grn

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data()
 if(NOT defined(grn)) then grn = grim_data.grn

 for i=0, n_elements(grn)-1 do $
  begin
   grim_data = grim_get_data(grn=grn[i])
   if(keyword_set(grim_data)) then widget_control, grim_data.base, /destroy
  end
end
;=============================================================================



;=============================================================================
; grim_undo
;
;=============================================================================
pro grim_undo, grim_data, plane
 dat_undo, plane.dd
end
;=============================================================================



;=============================================================================
; grim_redo
;
;=============================================================================
pro grim_redo, grim_data, plane
 dat_redo, plane.dd
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

 rdim = dat_dim(dd, /true)
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
pro grim_draw_vectors, cd, curves_ptd, points_ptd

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
 if(grim_data.type EQ 'plot') then $
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
 ; No modifier -- change mde 
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
   offset = grim_zoom_to_cursor(factor, /relative, zoom=zoom)
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

 if(grim_data.type EQ 'plot') then $
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
   stat = grim_activate_by_point(/invert, grim_data, plane, [x,y], clicks=clicks)
   if(stat NE -1) then grim_refresh, grim_data, /noglass, /no_image $
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
;+
; FILE MENU
;	
;-
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_event
;
;
; PURPOSE:
;	Allows user to load images into new image planes.  The user is 
;	prompted for filenames and dat_read is used to read each image.
;	Multiple images may be selected and a new plane is created for
;	each image.  On X-windows systems, multiple files may be selected 
;	either by dragging across the filenames or by holding down the 
;	control key to toggle the selected files.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_file_load_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_message, /clear
 
 widget_control, grim_data.base, /hourglass

 ;--------------------------
 ; select file
 ;--------------------------
 if(keyword__set(plane.load_path)) then path = plane.load_path
 filenames = pickfiles(get_path=get_path, path=path, $
                        filter=plane.filter, title='Select images to load')
 if(NOT keyword__set(filenames[0])) then return

 ;----------------------------------
 ; load each file into a new plane
 ;----------------------------------
 widget_control, grim_data.base, /hourglass
 grim_load_files, grim_data, filenames, load_path=get_path

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_browse_event
;
;
; PURPOSE:
;	Allows user to load images into new image planes using the brim 
;	browser.  Images are selected using the left mouse button and
;	each image is loaded on a new plane.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
pro grim_menu_file_browse_help_event, event
 text = ''
 nv_help, 'grim_menu_file_browse_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_browse_file_left_event, base, i, id, status=status

 status = -1
 grim_data = grim_get_data(base)


 status = 0
end
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pro grim_menu_file_browse_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 widget_control, grim_data.base, /hourglass

 ;----------------------------------
 ; load images into brim
 ;----------------------------------
 if(keyword__set(plane.load_path)) then path = plane.load_path
 grim_wset, grim_data, grim_data.wnum, get_info=tvd

 brim, filenames, path=plane.load_path, get_path=get_path, ids=filenames, $
      left_fn='grim_browse_file_left_event', fn_data=event.top, /modal, $
      select=select, title='Select images to load', order=tvd.order, $
      filter=plane.filter, /enable
 if(NOT keyword__set(select)) then return
 if(select[0] EQ '') then return

 ;----------------------------------
 ; load each file into a new plane
 ;----------------------------------
 widget_control, grim_data.base, /hourglass
 grim_load_files, grim_data, select, load_path=get_path

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_event
;
;
; PURPOSE:
;	Allows user to save the current image plane and geometry.  If there 
;	is no current filename for the current plane, then the user is 
;	prompted for one.  All descriptors are written through the translators
;	and then dat_write is used to write the data file.  Specific behavior 
;	is governed by OMINAS' configuration.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_file_save_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; prompt for filename if necessary
 ;------------------------------------------------------
 filename = dat_filename(plane.dd)
 if(NOT keyword_set(filename)) then $
        filename = grim_get_save_filename(grim_data, filetype=filetype)
 if(NOT keyword_set(filename)) then return


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write, grim_data, filename, filetype=filetype

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_as_event
;
;
; PURPOSE:
;	Same as 'Save' above, except always prompts for a filename. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_file_save_as_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_as_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_as_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; prompt for filename 
 ;------------------------------------------------------
 filename = grim_get_save_filename(grim_data, filetype=filetype)
 if(NOT keyword_set(filename)) then return

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write, grim_data, filename, filetype=filetype

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_open_as_rgb_event
;
;
; PURPOSE:
;	Opens a new grim window with the current channal configuration 
;	reduced to a 3-channel RGB cube.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2016
;	
;-
;=============================================================================
pro grim_menu_open_as_rgb_help_event, event
 text = ''
 nv_help, 'grim_menu_open_as_rgb_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_open_as_rgb_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass
 grim_wset, grim_data, grim_data.wnum, get_info=tvd

 dim = dat_dim(plane.dd)
 cube = grim_scale_image(grim_data, r, g, b, plane=plane, $
                                 xrange=[0,dim[0]-1], yrange=[0,dim[1]-1])

; look at render event to transfer overlays, etc
; dd = nv_clone(plane.dd)
; dat_set_data, dd, cube
 dd = dat_create_descriptors(1, data=cube)
 dat_set_filetype, dd, dat_filetype(plane.dd)

 grim, /new, /rgb, dd, order=tvd.order, zoom=tvd.zoom[0], offset=tvd.offset, $
       xsize=!d.x_size, ysize=!d.y_size

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_user_ptd_event
;
;
; PURPOSE:
;	Writes user points for the current plane to a file called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_user_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_user_ptd_fname(grim_data, plane), $
                            title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_user_points, grim_data, plane, fname=fname
 grim_print, grim_data, 'User points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_user_ptd_event
;
;
; PURPOSE:
;	Writes user points for all planes to files called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_all_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_user_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_user_points, grim_data, planes[i], fname=fname
 grim_print, grim_data, 'All user points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_user_ptd_event
;
;
; PURPOSE:
;	loads user points for the current plane from a file called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_user_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_user_points, grim_data, plane
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_user_ptd_event
;
;
; PURPOSE:
;	Loads user points for all planes from files called
;	[image name].user_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_all_user_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_user_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_user_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_user_points, grim_data, planes[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_tie_ptd_event
;
;
; PURPOSE:
;	Writes tie points for the current plane to a file called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_tie_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'TIEPOINT'), $
                                            title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_indexed_arrays, grim_data, plane, 'TIEPOINT', fname=fname
 grim_print, grim_data, 'Tie points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_tie_ptd_event
;
;
; PURPOSE:
;	Writes tie points for all planes to files called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_save_all_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_tie_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_indexed_arrays, grim_data, planes[i], 'TIEPOINT'
 grim_print, grim_data, 'All tie points saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_tie_ptd_event
;
;
; PURPOSE:
;	loads tie points for the current plane from a file called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_tie_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'TIEPOINT'), $
                                         title='Select filename to load', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_indexed_arrays, grim_data, plane, 'TIEPOINT', fname=fname
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_tie_ptd_event
;
;
; PURPOSE:
;	Loads tie points for all planes from files called
;	[image name].tie_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_file_load_all_tie_ptd_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_tie_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_tie_ptd_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_indexed_arrays, grim_data, planes[i], 'TIEPOINT'
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_curves_event
;
;
; PURPOSE:
;	Writes curves for the current plane to a file called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_save_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'CURVE'), $
                                         title='Select filename for saving', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_indexed_arrays, grim_data, plane, 'CURVE', fname=fname
 grim_print, grim_data, 'Curves saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_curves_event
;
;
; PURPOSE:
;	Writes curves for all planes to files called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_save_all_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_indexed_arrays, grim_data, planes[i], 'CURVE'
 grim_print, grim_data, 'All curves saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_curves_event
;
;
; PURPOSE:
;	loads curves for the current plane from a file called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_load_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear

 ;------------------------------------------------------
 ; get filename
 ;------------------------------------------------------
 fname = pickfiles(default=grim_indexed_array_fname(grim_data, plane, 'CURVE'), $
                                            title='Select filename to load', /one)

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_indexed_arrays, grim_data, plane, 'CURVE', fname=fname
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_curves_event
;
;
; PURPOSE:
;	Loads curves for all planes from files called
;	[image name].curve_ptd 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2015
;	
;-
;=============================================================================
pro grim_menu_file_load_all_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_curves_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_indexed_arrays, grim_data, planes[i], 'CURVE'
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_mask_event
;
;
; PURPOSE:
;	Writes mask points for the current plane to a file called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_save_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_mask_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_mask_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_write_mask, grim_data, plane
 grim_print, grim_data, 'Mask saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_all_masks_event
;
;
; PURPOSE:
;	Writes mask points for all planes to files called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_save_all_masks_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_all_masks_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_all_masks_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_write_mask, grim_data, planes[i]
 grim_print, grim_data, 'All masks saved.'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_mask_event
;
;
; PURPOSE:
;	loads mask points for the current plane from a file called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_load_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_mask_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_mask_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 plane = grim_get_plane(grim_data)
 grim_message, /clear


 ;------------------------------------------------------
 ; write data
 ;------------------------------------------------------
 grim_read_mask, grim_data, plane
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_load_all_masks_event
;
;
; PURPOSE:
;	Loads mask points for all planes from files called
;	[image name].mask 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_file_load_all_masks_help_event, event
 text = ''
 nv_help, 'grim_menu_file_load_all_masks_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_load_all_masks_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 planes = grim_get_plane(grim_data, /all)
 grim_message, /clear

 ;------------------------------------------------------
 ; read data
 ;------------------------------------------------------
 for i=0, n_elements(planes)-1 do $
                          grim_read_mask, grim_data, planes[i]
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_save_ps_event
;
;
; PURPOSE:
;	Saves the current view as a postscript file. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 12/2002
;	
;-
;=============================================================================
pro grim_menu_file_save_ps_help_event, event
 text = ''
 nv_help, 'grim_menu_file_save_ptd_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_save_ps_event, event



 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base

 ;------------------------------------------------------
 ; prompt for filename 
 ;------------------------------------------------------
 filename = pickfiles(get_path=get_path, $
                         title='Select filename for saving', path=path, /one)
 if(NOT keyword__set(filename)) then return

 ;------------------------------------------------------
 ; write postscript file
 ;------------------------------------------------------
 widget_control, grim_data.draw, /hourglass
 grim_write_ptd, grim_data, filename[0]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_repeat_event
;
;
; PURPOSE:
;	Repeats the last menu option.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2006
;	
;-
;=============================================================================
pro grim_menu_repeat_help_event, event
 text = ''
 nv_help, 'grim_menu_file_repeat_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_repeat_event, event

 grim_data = grim_get_data(event.top)
 grim_repeat, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_undo_event
;
;
; PURPOSE:
;	Undoes the last data modification.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2006
;	
;-
;=============================================================================
pro grim_menu_undo_help_event, event
 text = ''
 nv_help, 'grim_menu_file_undo_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_undo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_undo, grim_data, plane
 
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_redo_event
;
;
; PURPOSE:
;	Redoes the last data modification.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2006
;	
;-
;=============================================================================
pro grim_menu_redo_help_event, event
 text = ''
 nv_help, 'grim_menu_file_redo_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_redo_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_redo, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_select_event
;
;
; PURPOSE:
;	Selects or unselects a grim window.  This functionality is for use
;	with functions that require input from more than one grim instance. 
;	The selected state is red; unselected is gray.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	This option toggles a given grim instance between selected 
;	and unselected states, for use with functions that require 
;	input from more than one grim instance.  When a given instance 
;	is selected, this button displays an asterisk.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_select_help_event, event
 text = ''
 nv_help, 'grim_select_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_select_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
       grim_print, grim_data, 'Select/Deselect this grim window'
   return
  end $
 else if(NOT grim_test_motion_event(event)) then $
                                               grim_set_primary, grim_data.base

 grim_select, grim_data
 grim_set_data, grim_data, event.top

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_identify_event
;
;
; PURPOSE:
;	Causes grim to identify itself on the IDL command line.
;
;
; CATEGORY:
;	NV/GR
;
;
; OPERATION:
;	This option causes grim to print a message on the IDL command line.
;	It is useful in cases where multiple grim instances are running in
;	multiple IDL sessions.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2009
;	
;-
;=============================================================================
pro grim_identify_help_event, event
 text = ''
 nv_help, 'grim_identify_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_identify_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then $
       grim_print, grim_data, 'Identify this grim window'
   return
  end $
 else if(NOT grim_test_motion_event(event)) then $
                                               grim_set_primary, grim_data.base

 grim_identify, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_file_close_event
;
;
; PURPOSE:
;	Closes the current image plane.  All other image plane numbers 
;	remain the same.  If there is only one image plane, the grim exits. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_file_close_help_event, event
 text = ''
 nv_help, 'grim_menu_file_close_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_file_close_event, event

 grim_data = grim_get_data(event.top)
 grim_rm_plane, grim_data, grim_data.pn

end
;=============================================================================



;=============================================================================
;+
; PLANE MENU
;	
;-
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_next_event
;
;
; PURPOSE:
;	Changes to the next-numbered image plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_plane_next_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_next_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_next_event, event

 grim_data = grim_get_data(event.top)

 grim_next_plane, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_previous_event
;
;
; PURPOSE:
;	Changes to the previous-numbered image plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_plane_previous_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_previous_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_previous_event, event

 grim_data = grim_get_data(event.top)

 grim_previous_plane, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_jump_event
;
;
; PURPOSE:
;	Prompts the user and jumps to a new plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_plane_jump_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_jump_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_jump_event, event

 grim_data = grim_get_data(event.top)

 valid = grim_jumpto(grim_data)
 if(valid) then grim_refresh, grim_data, /no_erase

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_browse_event
;
;
; PURPOSE:
;	Opens a brim browser showing all planes.  The left mouse button 
;	may be used to jump among planes.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2002
;	
;-
;=============================================================================
pro grim_menu_plane_browse_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_browse_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_browse_plane_left_event, base, i, id, status=status

 status = -1
 grim_data = grim_get_data(base)
 if(NOT grim_exists(grim_data)) then return

 pn = id[0]

 grim_jump_to_plane, grim_data, pn, valid=valid
 if(valid) then $
  begin
   grim_refresh, grim_data, /no_erase
   status = 1
  end

end
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pro grim_browse_refresh_event, data_p

 base = *data_p
 if(NOT widget_info(base, /valid_id)) then $
  begin
   grim_rm_refresh_callback, data_p
   return
  end

 grim_data = grim_get_data()
 plane = grim_get_plane(grim_data)

 widget_control, base, get_uvalue=brim_data

 planes = grim_get_plane(grim_data, /all)
 brim_select, brim_data, plane.pn, dd=planes.dd, id=planes.pn


end
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pro grim_menu_plane_browse_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all, pn=pns)

 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 brim, planes.dd, ids=pns, $
      left_fn='grim_browse_plane_left_event', fn_data=event.top, $
      select=grim_data.pn, /exclusive, order=tvd.order, /enable, base=base

 grim_add_refresh_callback, 'grim_browse_refresh_event', nv_ptr_new(base)

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_open_event
;
;
; PURPOSE:
;	Opens the image of the current plane in a new grim window.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_plane_open_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_open_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_open_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass
 grim_wset, grim_data, grim_data.wnum, get_info=tvd
 grim, /new, plane.dd, order=tvd.order, zoom=tvd.zoom[0], offset=tvd.offset, $
       xsize=!d.x_size, ysize=!d.y_size

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_evolve_event
;
;
; PURPOSE:
;	Evolves the selected objects onto all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_plane_evolve_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_evolve_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_evolve_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, /hourglass

grim_print, grim_data, 'Not implemented!'

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_crop_event
;
;
; PURPOSE:
;	Crops the data to the current viewing parameters.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2013
;	
;-
;=============================================================================
pro grim_menu_plane_crop_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_crop_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_crop_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_crop_plane, grim_data, plane
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_reorder_time_event
;
;
; PURPOSE:
;	Rearranges all planes in time order.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2004
;	
;-
;=============================================================================
pro grim_menu_plane_reorder_time_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_reorder_time_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_reorder_time_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 times = dblarr(n)
 for i=0, n-1 do $
  begin
   cd = *planes[i].cd_p
   if(NOT keyword__set(cd)) then grim_message, $
                   'You must first load camera descriptors for each plane.'
   times[i] = bod_time(cd)
  end

 s = sort(times)

 planes = planes[s]
 for i=0, n-1 do $
  begin
   planes[i].pn = i
   grim_set_plane, grim_data, planes[i], pn=i
  end

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_sequence_event
;
;
; PURPOSE:
;	Displays all planes in sequence using xinteranimate.  This option is
;	useful or blinking as well.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_plane_sequence_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_sequence_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_sequence_event, event

 grim_data = grim_get_data(event.top)

 ;--------------------------------------------
 ; get valid planes
 ;--------------------------------------------
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)
 if(n LE 1) then return
 
 ;--------------------------------------------
 ; set up images
 ;--------------------------------------------
 widget_control, /hourglass

 geom = widget_info(grim_data.draw, /geom)
 xinteranimate, set=[geom.xsize, geom.ysize, n]
 tvim, /noplot, /silent, $
           /new, /inherit, xsize=geom.xsize, ysize=geom.ysize, /pixmap
 pixmap = !d.window

; for i=0, n-1 do $
;  begin
;grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title
;im = tvrd()
;write_gif, /mult, '~/test.gif', im
;  end
;write_gif, /close
;stop

 for i=0, n-1 do $
  begin
   grim_print, grim_data, $
     'Loading plane ' + strtrim(i,2) + ' of ' + strtrim(n,2) + '...'

   wset, pixmap & erase & wset, grim_data.wnum

   grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title

   xinteranimate, frame=i, window=pixmap, /show
  end

 grim_print, grim_data, ''

 ;--------------------------------------------
 ; run the movie
 ;--------------------------------------------
 wdelete, pixmap
 grim_wset, grim_data, grim_data.wnum

 xinteranimate
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_dump_event
;
;
; PURPOSE:
;	Dumps all planes to png files entitled [filename].png.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2004
;	
;-
;=============================================================================
pro grim_menu_plane_dump_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_dump_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_dump_event, event

 grim_data = grim_get_data(event.top)

 ;--------------------------------------------
 ; get valid planes
 ;--------------------------------------------
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)
 if(n LE 1) then return
 
 ;--------------------------------------------
 ; set up images
 ;--------------------------------------------
 widget_control, /hourglass

 geom = widget_info(grim_data.draw, /geom)
 xinteranimate, set=[geom.xsize, geom.ysize, n]
 tvim, /noplot, /silent, $
           /new, /inherit, xsize=geom.xsize, ysize=geom.ysize, /pixmap
 pixmap = !d.window


 for i=0, n-1 do $
  begin
   filename = cor_name(planes[i].dd)
   grim_refresh, grim_data, plane=planes[i], wnum=pixmap, /no_title
   wset, pixmap
   write_png, filename + '.png', tvrd()
  end

 wdelete, pixmap
 grim_wset, grim_data, grim_data.wnum

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_coregister_event 
;
;
; PURPOSE:
;	Shifts the images on each plane so as to center the active object 
;	at the same pixel on each plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_plane_coregister_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_coregister_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_coregister_event, event

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)
 n = n_elements(planes)

 widget_control, grim_data.draw, /hourglass


 ;------------------------------------------------
 ; make sure relevant descriptors are loaded
 ;------------------------------------------------
 for i=0, n-1 do $
   grim_load_descriptors, grim_data, class='CAMERA', plane=planes[i], cd=cd
 if(NOT keyword_set(cd[0])) then return 


 ;------------------------------------------------
 ; build descriptor arrays
 ;------------------------------------------------
 cd = objarr(n)
 bx = objarr(n)
 dd = objarr(n)

 for i=0, n-1 do $
  if(keyword_set(*planes[i].active_xd_p)) then $
   begin
    dd[i] = planes[i].dd
    cd[i] = *planes[i].cd_p
    bx[i] = (*planes[i].active_xd_p)[0]		; Is this a good assumption?
   end

 w = where(obj_valid(dd))
 if(n_elements(w) LT 2) then $
  begin
   grim_message, 'There must be active overlays on at least two planes.'
   return
  end

 dd = dd[w]
 cd = cd[w]
 bx = bx[w]

 ;------------------------------------------------
 ; recenter image
 ;------------------------------------------------
; we don't want one event for every registration here....
; nv_suspend_events;, /flush
 pg_coregister, dd, cd=cd, bx=bx
; nv_resume_events;, /flush

 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_coadd_event 
;
;
; PURPOSE:
;	Averages all planes.  Not implemented.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2004
;	
;-
;=============================================================================
pro grim_menu_plane_coadd_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_coadd_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_coadd_event, event

 grim_data = grim_get_data(event.top)
 planes = grim_get_plane(grim_data, /all)
 widget_control, grim_data.draw, /hourglass

 
; grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_plane_syncing_event
;
;
; PURPOSE:
;	Toggles plane syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2016
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_plane_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_plane_syncing_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_plane_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'PLANE_SYNCING')
 flag = 1 - flag
 
 grim_set_toggle_flag, grim_data, 'PLANE_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                       'grim_menu_plane_toggle_plane_syncing_event', flag


; grim_sync_planes, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_highlight_event 
;
;
; PURPOSE:
;	Toggles highlighting of the current plane image.  Useful when 
;	multiple planes are visible simultaneously.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2008
;	
;-
;=============================================================================
pro grim_menu_plane_highlight_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_highlight_event ', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_highlight_event, event

 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'PLANE_HIGHLIGHT', flag
 grim_update_menu_toggle, grim_data, 'grim_menu_plane_highlight_event', flag


; widget_control, grim_data.draw, /hourglass
 
 grim_refresh, grim_data
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_tiepoints_event
;
;
; PURPOSE:
;	Copies all tieppoints from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_copy_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_tiepoints_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_tiepoints_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then $
                        grim_copy_tiepoint, grim_data, plane, planes[i]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_propagate_tiepoints_event
;
;
; PURPOSE:
;	Copies all tieppoints from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_propagate_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_propagate_tiepoints_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_propagate_tiepoints_event, event

 widget_control, /hourglass


 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 nplanes = n_elements(planes)
 pn = plane.pn


 tie_pts = pnt_points(plane.tiepoints_ptd)
 if(NOT keyword_set(tie_pts)) then return
 npts = n_elements(tie_pts)/2
 ii = grim_get_tiepoint_indices(grim_data, plane=plane)

 grim_load_descriptors, grim_data, class='CAMERA', plane=plane, cd=cd
 if(NOT keyword_set(cd[0])) then $ 
  begin
   grim_message, 'No camera descriptor!'
   return
  end
 grim_load_descriptors, grim_data, class='PLANET', plane=plane, pd=pd
 if(NOT keyword_set(pd[0])) then return

 cd = cd[0]

 pd0 = get_primary(cd, pd)
 name = cor_name(pd0)

 tie_pts = reform(tie_pts, 2, 1, npts, /over)

 dkd = make_array(npts, $
           val=orb_construct_descriptor(pd0, sma=1d8, GG=const_G))
 for i=0, npts-1 do $ 
   dkd[i] = image_to_orbit(cd, pd0, dkd[i], tie_pts[*,0,i], GG=const_G)
;orb_set_ma, dkd, orb_anom_to_lon(dkd, orb_get_ma(dkd), pd0)
; for i=0, npts-1 do orb_print_elements_mks, dkd[i], pd0

 for i=0, nplanes-1 do $
  if(planes[i].pn NE pn) then $
   begin
    grim_load_descriptors, grim_data, class='CAMERA', plane=planes[i]
    cdi = (*planes[i].cd_p)[0]
    if(keyword_set(cdi)) then $
     begin
      grim_load_descriptors, grim_data, class='PLANET', plane=planes[i]
      w = where(cor_name(pd) EQ name)
      if(w[0] NE -1) then $
       begin
        pdi = (pd)[w[0]]

        dt = bod_time(pdi) - bod_time(pd0)
        dkdt = objarr(npts)
        r = dblarr(1,3,npts)
        for j=0, npts-1 do $
         begin
          dkdt[j] = orb_evolve(dkd[j], dt)
          bod_set_pos, dkdt[j], bod_pos(pdi)
          r[*,*,j] = orb_to_cartesian(dkdt[j], v=_v)
;          r[*,*,j] = orb_to_cartesian_lt(cdi, dkdt[j], c=const_c, v=_v)
         end

        if(npts GT 1) then r = transpose(r)
        p = reform(inertial_to_image_pos(cdi, r))
plots, p, psym=1, col=ctgreen()

        grim_copy_tiepoint, grim_data, plane, planes[i]
        planes[i] = grim_get_plane(grim_data, pn=planes[i].pn) 

        grim_replace_tiepoints, grim_data, ii, p, plane=planes[i]

        nv_free, dkdt
       end
     end

   end

 nv_free, dkd

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_tiepoint_syncing_event
;
;
; PURPOSE:
;	Toggles tiepoint syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_tiepoint_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_tiepoint_syncing_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_tiepoint_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)

 flag = grim_get_toggle_flag(grim_data, 'TIEPOINT_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'TIEPOINT_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
               'grim_menu_plane_toggle_tiepoint_syncing_event', flag


; grim_sync_tiepoints, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_tiepoints_event
;
;
; PURPOSE:
;	Clears all tiepoints from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
pro grim_menu_plane_clear_tiepoints_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_tiepoints_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_tiepoints_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_tiepoint, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_curves_event
;
;
; PURPOSE:
;	Copies all curves from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2004
;	
;-
;=============================================================================
pro grim_menu_plane_copy_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_curves_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then grim_copy_curve, grim_data, plane, planes[i]

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_toggle_curve_syncing_event
;
;
; PURPOSE:
;	Toggles curve syncing on/off.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2012
;	
;-
;=============================================================================
pro grim_menu_plane_toggle_curve_syncing_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_toggle_curve_syncing_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_toggle_curve_syncing_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)


 grim_data = grim_get_data(event.top)
 
 flag = grim_get_toggle_flag(grim_data, 'CURVE_SYNCING')
 flag = 1 - flag

 grim_set_toggle_flag, grim_data, 'CURVE_SYNCING', flag
 grim_update_menu_toggle, grim_data, $
                      'grim_menu_plane_toggle_curve_syncing_event', flag

; grim_sync_curves, grim_data
; grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_curves_event
;
;
; PURPOSE:
;	Clears all curves from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2004
;	
;-
;=============================================================================
pro grim_menu_plane_clear_curves_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_curves_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_curves_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_curve, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_copy_mask_event
;
;
; PURPOSE:
;	Copies mask from the current plane to all other planes.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_plane_copy_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_copy_mask_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_copy_mask_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)

 n = n_elements(planes)
 pn = plane.pn

 for i=0, n-1 do if(i NE pn) then grim_copy_mask, grim_data, plane, planes[i]
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_clear_mask_event
;
;
; PURPOSE:
;	Clears the mask from the current plane.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2013
;	
;-
;=============================================================================
pro grim_menu_plane_clear_mask_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_clear_mask_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_clear_mask_event, event

 widget_control, /hourglass

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_rm_mask, grim_data, plane=plane, /all
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_plane_settings_event
;
;
; PURPOSE:
;	Allows the user modify settings for the loaded image planes.  
;	Each plane may displayed in any combination of the three color
;	channels.  Also, a plane may be made visible even when it is not
;	the current plane, instead of the default behavior, which is to 
;	display the plane only whenit is current.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2002
;	
;-
;=============================================================================
pro grim_menu_plane_settings_help_event, event
 text = ''
 nv_help, 'grim_menu_plane_settings_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_plane_settings_event, event

 grim_data = grim_get_data(event.top)
 grim_plane_settings, grim_data

end
;=============================================================================



;=============================================================================
;+
; DATA MENU
;	
;-
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_data_adjust_event
;
;
; PURPOSE:
;	This option allows the user to adjust data values.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2014
;	
;-
;=============================================================================
pro grim_menu_data_adjust_help_event, event
 text = ''
 nv_help, 'grim_menu_data_adjust_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_data_adjust_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 ;------------------------------------------------
 ; adjust the data
 ;------------------------------------------------
 grim_logging, grim_data, /start
 pg_data_adjust, plane.dd
 grim_logging, grim_data, /stop

 
end
;=============================================================================



;=============================================================================
;+
; VIEW MENU
;	
;-
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_refresh_event
;
;
; PURPOSE:
;	Redraws the overlays on the graphics display. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_refresh_help_event, event
 text = ''
 nv_help, 'grim_menu_view_refresh_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_refresh_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_event
;
;
; PURPOSE:
;	Prompts the user for a new zoom factor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_view_zoom_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_event, event

 grim_data = grim_get_data(event.top)
 zoom = grim_zoom(grim_data)
 if(zoom NE 0) then grim_refresh, grim_data, zoom=zoom

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_double_event
;
;
; PURPOSE:
;	Doubles the current zoom, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_double_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_double_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(2d, /relative, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_half_event
;
;
; PURPOSE:
;	Halves the current zoom, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_half_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_half_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(0.5d, /relative, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_event
;
;
; PURPOSE:
;	Sets the current zoom to 1, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_2_event
;
;
; PURPOSE:
;	Sets the current zoom to 2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_2_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(2d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_3_event
;
;
; PURPOSE:
;	Sets the current zoom to 3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_3_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(3d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_4_event
;
;
; PURPOSE:
;	Sets the current zoom to 4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_4_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(4d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_6_event
;
;
; PURPOSE:
;	Sets the current zoom to 6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_6_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(6d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_7_event
;
;
; PURPOSE:
;	Sets the current zoom to 7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_7_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(7d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_8_event
;
;
; PURPOSE:
;	Sets the current zoom to 8, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_8_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_8_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(8d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_9_event
;
;
; PURPOSE:
;	Sets the current zoom to 9, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_9_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_9_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(9d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_10_event
;
;
; PURPOSE:
;	Sets the current zoom to 10, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_10_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_10_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(10d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_2_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_2_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/2d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_3_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_3_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/3d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_4_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_4_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/4d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_5_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_5_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/5d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_6_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_6_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/6d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_7_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_7_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/7d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_8_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/8, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_8_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_8_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/8d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_9_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/9, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_9_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_9_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/9d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_zoom_1_10_event
;
;
; PURPOSE:
;	Sets the current zoom to 1/10, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_zoom_1_10_help_event, event
 text = ''
 nv_help, 'grim_menu_view_zoom_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_zoom_1_10_event, event

 grim_data = grim_get_data(event.top)
 offset = grim_zoom_to_cursor(1d/10d, zoom=zoom)
 grim_refresh, grim_data, zoom=zoom, offset=offset

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_0_event
;
;
; PURPOSE:
;	Sets the current rotate to 0, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_0_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_0_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=0

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_1_event
;
;
; PURPOSE:
;	Sets the current rotate to 1, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_1_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_1_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=1

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_2_event
;
;
; PURPOSE:
;	Sets the current rotate to 2, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_2_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_2_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=2

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_3_event
;
;
; PURPOSE:
;	Sets the current rotate to 3, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_3_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_3_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=3

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_4_event
;
;
; PURPOSE:
;	Sets the current rotate to 4, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_4_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_4_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=4

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_5_event
;
;
; PURPOSE:
;	Sets the current rotate to 5, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_5_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_5_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=5

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_6_event
;
;
; PURPOSE:
;	Sets the current rotate to 6, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_6_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_6_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=6

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_rotate_7_event
;
;
; PURPOSE:
;	Sets the current rotate to 7, centered at the mouse cursor. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2013
;	
;-
;=============================================================================
pro grim_menu_view_rotate_7_help_event, event
 text = ''
 nv_help, 'grim_menu_view_rotate_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_rotate_7_event, event

 grim_data = grim_get_data(event.top)
 grim_refresh, grim_data, rotate=7

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_recenter_event
;
;
; PURPOSE:
;	Recenters the view at the cursor position. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2008
;	
;-
;=============================================================================
pro grim_menu_view_recenter_help_event, event
 text = ''
 nv_help, 'grim_menu_view_home_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_recenter_event, event

 grim_data = grim_get_data(event.top)

 cursor, x, y, /device, /nowait

 p = convert_coord(double(x), double(y), /device, /to_data)
 grim_recenter, grim_data, p

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_apply_event
;
;
; PURPOSE:
;	Applys the current view to all planes. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2016
;	
;-
;=============================================================================
pro grim_menu_view_apply_help_event, event
 text = ''
 nv_help, 'grim_menu_view_home_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_apply_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

 for i=0, nplanes-1 do if(planes[i].pn NE plane.pn) then $
  begin
   planes[i].xrange = plane.xrange
   planes[i].yrange = plane.yrange
   planes[i].position = plane.position
  end

 grim_set_data, grim_data, event.top

 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /home

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_home_event
;
;
; PURPOSE:
;	Sets the tvim home view settings. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2005
;	
;-
;=============================================================================
pro grim_menu_view_home_help_event, event
 text = ''
 nv_help, 'grim_menu_view_home_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_home_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /home

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_save_event
;
;
; PURPOSE:
;	Saves the current view settings. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_save_help_event, event
 text = ''
 nv_help, 'grim_menu_view_save_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_save_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_wset, grim_data, /noplot, /save

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_restore_event
;
;
; PURPOSE:
;	Restores the last-saved view settings. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_restore_help_event, event
 text = ''
 nv_help, 'grim_menu_view_restore_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_restore_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /restore

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_previous_event
;
;
; PURPOSE:
;	Restores the previous view settings. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_previous_help_event, event
 text = ''
 nv_help, 'grim_menu_view_previous_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_previous_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /previous

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_entire_event
;
;
; PURPOSE:
;	Applies the 'entire' display parameters, as given in tvim. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_entire_help_event, event
 text = ''
 nv_help, 'grim_menu_view_entire_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_entire_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /entire

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_initial_event
;
;
; PURPOSE:
;	Reverts to the initial view parameters for this grim widget. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2007
;	
;-
;=============================================================================
pro grim_menu_view_initial_help_event, event
 text = ''
 nv_help, 'grim_menu_view_entire_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_initial_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 tvd = *grim_data.tvd_init_p
 tvim, /inherit, /silent, zoom=tvd.zoom, order=tvd.order, offset=tvd.offset

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_flip_event
;
;
; PURPOSE:
;	Reverses the curent display order. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_flip_help_event, event
 text = ''
 nv_help, 'grim_menu_view_flip_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_flip_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass
 grim_refresh, grim_data, /flip

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_frame_event
;
;
; PURPOSE:
;	Modifies view settings so as to display the either all overlays
;	or those that are active. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2007
;	
;-
;=============================================================================
pro grim_menu_view_frame_help_event, event
 text = ''
 nv_help, 'grim_menu_view_frame_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_frame_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 widget_control, grim_data.draw, /hourglass

 ptd = grim_get_all_active_overlays(grim_data, plane=plane)
 if(NOT keyword_set(ptd)) then $
   ptd = grim_get_all_overlays(grim_data, plane=plane)
 if(NOT keyword_set(ptd)) then return

 grim_frame_overlays, grim_data, plane, ptd

 grim_refresh, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_header_event
;
;
; PURPOSE:
;	Opens a text window showing the image header. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2003
;	
;-
;=============================================================================
pro grim_menu_view_header_help_event, event
 text = ''
 nv_help, 'grim_menu_view_header_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_header_event, event

 grim_data = grim_get_data(event.top)
 grim_edit_header, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_notes_event
;
;
; PURPOSE:
;	Opens a text window allowing the user to enter notes for each plane. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 10/2003
;	
;-
;=============================================================================
pro grim_menu_notes_help_event, event
 text = ''
 nv_help, 'grim_menu_notes_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_notes_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_edit_notes, grim_data, plane=plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_toggle_image_event
;
;
; PURPOSE:
;	Toggles the image On/Off. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
pro grim_menu_image_help_event, event
 text = ''
 nv_help, 'grim_menu_toggle_image_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_toggle_image_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_toggle_image, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_toggle_image_overlays_event
;
;
; PURPOSE:
;	Toggles the image and overlays On/Off. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2012
;	
;-
;=============================================================================
pro grim_menu_image_overlays_help_event, event
 text = ''
 nv_help, 'grim_menu_toggle_image_overlays_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_toggle_image_overlays_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_toggle_image_overlays, grim_data, plane

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_context_event
;
;
; PURPOSE:
;	Toggles the context window On/Off. 
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2005
;	
;-
;=============================================================================
pro grim_menu_context_help_event, event
 text = ''
 nv_help, 'grim_menu_context_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_context_event, event

 grim_data = grim_get_data(event.top)
 grim_toggle_context, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_axes_event
;
;
; PURPOSE:
;	Toggles the axes window On/Off.  The colors are as follows:
;
;	 Blue	- Inertial axes.
;	 Red	- Camera axes.
;	 Green	- Direction to primary planet, not foreshortened.
;	 Yellow	- Direction to Sun, not foreshortened.
;
;	Vectors pointing away from the camera are dotted.  The vectors are 
;	rooted at a point 1d5 distance units in front of the camera .  
;	In the direction corresponding to the image position of the drawn 
;	axes.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2005
;	
;-
;=============================================================================
pro grim_menu_axes_help_event, event
 text = ''
 nv_help, 'grim_menu_axes_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_axes_event, event

 grim_data = grim_get_data(event.top)
 grim_toggle_axes, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_render_event
;
;
; PURPOSE:
;	Renders the visible scene and places it in a new plane unless
;	the current plane is already rendering. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================
pro grim_menu_render_help_event, event
 text = ''
 nv_help, 'grim_menu_render_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_render_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)
 grim_render, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_view_colors_event
;
;
; PURPOSE:
;	Opens gr_colortool. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_view_colors_help_event, event
 text = ''
 nv_help, 'grim_menu_view_colors_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_view_colors_event, event

 grim_data = grim_get_data(event.top)
 grim_set_primary, grim_data.base
 grim_modify_colors, grim_data

end
;=============================================================================



;=============================================================================
;+
; OVERLAYS MENU
;	
;-
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_planet_centers_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	planet center positions using pg_center for all active objects.  If no
;	active objects, then all centers are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_planet_centers_help_event, event
 text = ''
 nv_help, 'grim_menu_points_planet_centers_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_planet_centers_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute centers
 ;------------------------------------------------
 grim_overlay, grim_data, 'PLANET_CENTER'
; grim_planet_centers, grim_data

 ;------------------------------------------------
 ; draw centers
 ;------------------------------------------------
; grim_draw, grim_data, /center, /label
 grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_limbs_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	limbs using pg_limbs for all active objects.  If no active objects, 
;	then all limbs are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_limbs_help_event, event
 text = ''
 nv_help, 'grim_menu_points_limbs_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_limbs_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute limbs
 ;------------------------------------------------
 grim_overlay, grim_data, 'LIMB'
; grim_limbs, grim_data

 ;------------------------------------------------
 ; draw limbs
 ;------------------------------------------------
; grim_draw, grim_data, /limb
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_terminators_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	terminators using pg_limb with the sun as the observer for all active
;	objects.  If no active objects, then all terminators are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_terminators_help_event, event
 text = ''
 nv_help, 'grim_menu_points_terminators_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_terminators_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute terminators
 ;------------------------------------------------
 grim_overlay, grim_data, 'TERMINATOR'
; grim_terminators, grim_data

 ;------------------------------------------------
 ; draw terminators
 ;------------------------------------------------
; grim_draw, grim_data, /term
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_planet_grids_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	planet grids using pg_grid for all active objects.  If no active
;	objects, then all grids are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_planet_grids_help_event, event
 text = ''
 nv_help, 'grim_menu_points_planet_grids_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_planet_grids_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'PLANET_GRID'
; grim_planet_grids, grim_data

 ;------------------------------------------------
 ; draw planet grids
 ;------------------------------------------------
; grim_draw, grim_data, /plgrid
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_rings_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	ring outlines using pg_disk. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_rings_help_event, event
 text = ''
 nv_help, 'grim_menu_points_rings_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_rings_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute rings
 ;------------------------------------------------
 grim_overlay, grim_data, 'RING'
;grim_rings, grim_data

 ;------------------------------------------------
 ; draw rings
 ;------------------------------------------------
; grim_draw, grim_data, /ring
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_ring_grids_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	ring grids using pg_grid for all active objects.  If no active
;	objects, then all grids are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2004
;	
;-
;=============================================================================
pro grim_menu_points_ring_grids_help_event, event
 text = ''
 nv_help, 'grim_menu_points_ring_grids_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_ring_grids_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

; grim_interrupt_begin, grim_data

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'RING_GRID'

 ;------------------------------------------------
 ; draw planet grids
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap

; grim_interrupt_end, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_stations_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	planet stations for all active objects.  If no active objects, then 
;	all stations are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
pro grim_menu_points_stations_help_event, event
 text = ''
 nv_help, 'grim_menu_points_stations_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_stations_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'STATION'

 ;------------------------------------------------
 ; draw stations
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_arrays_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	arrays for all active objects.  If no active objects, then 
;	all arrays are computed.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 3/2012
;	
;-
;=============================================================================
pro grim_menu_points_arrays_help_event, event
 text = ''
 nv_help, 'grim_menu_points_arrays_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_arrays_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute planet grids
 ;------------------------------------------------
 grim_overlay, grim_data, 'ARRAY'

 ;------------------------------------------------
 ; draw arrays
 ;------------------------------------------------
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_stars_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	star positions using pg_center. 
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_stars_help_event, event
 text = ''
 nv_help, 'grim_menu_points_stars_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_stars_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute stars
 ;------------------------------------------------
 grim_overlay, grim_data, 'STAR'

 ;------------------------------------------------
 ; draw stars
 ;------------------------------------------------
; grim_draw, grim_data, /star, /label
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_shadows_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	shadows of the currently active overlay points on all other objects. 
;	Note that you may have to disable overlay hiding in order to compute
;	and activate all of the appropriate source points for the shadows
;	since many point that are not visible to the observer may still have
;	a line of sight to the sun.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_points_shadows_help_event, event
 text = ''
 nv_help, 'grim_menu_points_shadows_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_shadows_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute shadows
 ;------------------------------------------------
 grim_overlay, grim_data, 'SHADOW'
;grim_shadows, grim_data

 ;------------------------------------------------
 ; draw shadow
 ;------------------------------------------------
; grim_draw, grim_data, /shadow
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_reflections_event
;
;
; PURPOSE:
;	Obtains the necessary descriptors through the translators and computes
;	reflections of the currently active overlay points on all other objects. 
;	Note that you may have to disable overlay hiding in order to compute
;	and activate all of the appropriate source points for the reflections
;	since many point that are not visible to the observer may still have
;	a line of sight to the sun.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_points_reflections_help_event, event
 text = ''
 nv_help, 'grim_menu_points_reflections_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_reflections_event, event

 grim_data = grim_get_data(event.top)
 widget_control, grim_data.draw, /hourglass

 ;------------------------------------------------
 ; load descriptors and compute reflections
 ;------------------------------------------------
 grim_overlay, grim_data, 'REFLECTION'
;grim_reflections, grim_data

 ;------------------------------------------------
 ; draw reflection
 ;------------------------------------------------
; grim_draw, grim_data, /reflection
 grim_refresh, grim_data, /use_pixmap


end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_hide_all_event
;
;
; PURPOSE:
;	 Hides/unhides all overlay objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2003
;	
;-
;=============================================================================
pro grim_menu_hide_all_help_event, event
 text = ''
 nv_help, 'grim_menu_hide_all_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_hide_all_event, event

 grim_data = grim_get_data(event.top)

 grim_set_primary, grim_data.base
 grim_hide_overlays, grim_data

end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_clear_all_event
;
;
; PURPOSE:
;	 Clears all objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_clear_all_help_event, event
 text = ''
 nv_help, 'grim_menu_clear_all_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_clear_all_event, event

 grim_message, /question, result=result, $
           ['Are you sure you want to clear all overlays?']
 if(result NE 'Yes') then return


 grim_data = grim_get_data(event.top)
 grim_clear_objects, grim_data, /all

 grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_clear_active_event
;
;
; PURPOSE:
;	 Clears all active objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_clear_active_help_event, event
 text = ''
 nv_help, 'grim_menu_clear_active_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_clear_active_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_clear_active_overlays, grim_data, plane
 grim_clear_active_user_overlays, plane


 grim_refresh, grim_data, /use_pixmap
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_activate_all_event
;
;
; PURPOSE:
;	 Activates all objects.
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_activate_all_help_event, event
 text = ''
 nv_help, 'grim_menu_activate_all_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_activate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_activate_all, grim_data, plane
 grim_refresh, grim_data, /no_image

 return
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_deactivate_all_event
;
;
; PURPOSE:
;	 Deactivates all objects.
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 9/2002
;	
;-
;=============================================================================
pro grim_menu_deactivate_all_help_event, event
 text = ''
 nv_help, 'grim_menu_deactivate_all_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_deactivate_all_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_deactivate_all, grim_data, plane
 grim_refresh, grim_data, /no_image

 return
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_invert_all_event
;
;
; PURPOSE:
;	 Inverts current overlay activations.  Desccriptor activations are
;	 determined by the resulting overlay activations. 
;
;
; CATEGORY:
;	NV/GR
;	 
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2002
;	
;-
;=============================================================================
pro grim_menu_invert_all_help_event, event
 text = ''
 nv_help, 'grim_menu_invert_all_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_invert_event, event

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_invert_all_overlays, grim_data, plane

 grim_refresh, grim_data, /no_image
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	grim_menu_points_settings_event
;
;
; PURPOSE:
;	Allows the user modify settings relevant to the overlay points.  
;
;
; CATEGORY:
;	NV/GR
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grim_menu_points_settings_help_event, event
 text = ''
 nv_help, 'grim_menu_points_settings_event', cap=text
 if(keyword_set(text)) then grim_help, grim_get_data(event.top), text
end
;----------------------------------------------------------------------------
pro grim_menu_points_settings_event, event
@grim_block.include

 grim_data = grim_get_data(event.top)
 plane = grim_get_plane(grim_data)

 grim_overlay_settings, grim_data, plane

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
 grim_previous_plane, grim_data

end
;=============================================================================



;=============================================================================
; grim_jumpto_event
;
;=============================================================================
pro grim_jumpto_event, event

 grim_data = grim_get_data(event.top)

 ;---------------------------------------------------------
 ; if tracking event, just print usage info
 ;---------------------------------------------------------
 struct = tag_names(event, /struct)
 if(struct EQ 'WIDGET_TRACKING') then $
  begin
   if(event.enter) then grim_print, grim_data, 'Jump to plane'
   return
  end


 ;---------------------------------------------------------
 ; jump to new plane
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 valid = grim_jumpto(grim_data, grim_data.jumpto_text)
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
 grim_next_plane, grim_data

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
 ; open header editor
 ;---------------------------------------------------------
 grim_set_primary, grim_data.base
 grim_edit_notes, grim_data, plane=plane


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
; grim_help
;
;=============================================================================
pro grim_help, grim_data, text

 plane = grim_get_plane(grim_data)
 widget_control, grim_data.draw, /hourglass

 if(NOT widget_info(grim_data.help_text, /valid)) then $
  begin
   grim_data.help_text = textedit(text, base=base, xs=80, resource_prefix='grim_help')
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
function grim_create_help_menu, _menu_desc

 menu_desc = _menu_desc

 help_desc = strep_s(menu_desc, '_event', '_help_event')
 menu_desc = ['1\Help', help_desc]

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
            beta_only_indices=beta_only_indices

 map_token = '*'
 od_token = '#'
 plot_token = '+'
 plot_only_token = '%'
 beta_only_token = '?'

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
;
;=============================================================================
function grim_menu_desc, cursor_modes=cursor_modes

 desc = [ '+*1\File' , $
           '0\Load                \+*grim_menu_file_load_event', $
           '0\Browse              \*grim_menu_file_browse_event', $
           '0\Save                \+*grim_menu_file_save_event', $
           '0\Save As             \+*grim_menu_file_save_as_event', $
           '0\Open As RGB          \+*grim_menu_open_as_rgb_event', $
           '0\--------------------\+grim_menu_delim_event', $ 
           '0\Save User Points    \+*grim_menu_file_save_user_ptd_event', $
           '0\Save All User Points\+*grim_menu_file_save_all_user_ptd_event', $
           '0\Load User Points    \+*grim_menu_file_load_user_ptd_event', $
           '0\Load All User Points\+*grim_menu_file_load_all_user_ptd_event', $
           '0\--------------------\grim_menu_delim_event', $ 
           '0\Save Tie Points     \*grim_menu_file_save_tie_ptd_event', $
           '0\Save All Tie Points \*grim_menu_file_save_all_tie_ptd_event', $
           '0\Load Tie Points     \*grim_menu_file_load_tie_ptd_event', $
           '0\Load All Tie Points \*grim_menu_file_load_all_tie_ptd_event', $
           '0\--------------------\grim_menu_delim_event', $ 
           '0\Save Curves         \*grim_menu_file_save_curves_event', $
           '0\Save All Curves     \*grim_menu_file_save_all_curves_event', $
           '0\Load Curves         \*grim_menu_file_load_curves_event', $
           '0\Load All Curves     \*grim_menu_file_load_all_curves_event', $
           '0\--------------------\grim_menu_delim_event', $ 
           '0\Save Mask           \*grim_menu_file_save_mask_event', $
           '0\Save All Masks      \*grim_menu_file_save_all_masks_event', $
           '0\Load Mask           \*grim_menu_file_load_mask_event', $
           '0\Load All Masks      \*grim_menu_file_load_all_masks_event', $
           '0\--------------------\+grim_menu_delim_event', $ 
           '0\Save Postscript     \+*grim_menu_file_save_ps_event', $
           '0\--------------------\+grim_menu_delim_event', $ 
           '0\Repeat              \+*grim_menu_repeat_event', $
           '0\Undo                \+*grim_menu_undo_event', $
           '0\Redo                \+*grim_menu_redo_event', $
           '0\--------------------\+grim_menu_delim_event', $ 
           '0\Select              \+*grim_select_event', $
           '0\Identify            \+*grim_identify_event', $
           '0\Close               \+*grim_menu_file_close_event', $
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\Mode' , $

          '+*1\Plane' , $
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
           '0\Toggle Syncing            [xxx]\*grim_menu_plane_toggle_plane_syncing_event', $
           '0\Toggle Highlight          [xxx]\*grim_menu_plane_highlight_event', $
           '0\-------------------\*grim_menu_delim_event', $ 
           '0\Copy tie points     \*grim_menu_plane_copy_tiepoints_event', $
;           '0\Propagate tie points\*grim_menu_plane_propagate_tiepoints_event', $
           '0\Toggle tie point syncing  [xxx]\*grim_menu_plane_toggle_tiepoint_syncing_event', $
           '0\Clear tie points    \*grim_menu_plane_clear_tiepoints_event', $
           '0\-------------------\*grim_menu_delim_event', $ 
           '0\Copy curves        \*grim_menu_plane_copy_curves_event', $
;           '0\Propagate curves    \*grim_menu_plane_propagate_curves_event', $
           '0\Toggle curves syncing     [xxx]\*grim_menu_plane_toggle_curve_syncing_event', $
           '0\Clear curves        \*grim_menu_plane_clear_curves_event', $
           '0\-------------------\*grim_menu_delim_event', $ 
           '0\Copy mask          \*grim_menu_plane_copy_mask_event', $
           '0\Clear mask         \*grim_menu_plane_clear_mask_event', $
           '0\-------------------\*grim_menu_delim_event', $ 
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
           '0\---------------------\*grim_menu_delim_event', $ 
           '0\Header               \grim_menu_view_header_event', $
           '0\Notes                \grim_menu_notes_event', $
           '0\---------------------\*grim_menu_delim_event', $ 
           '0\Toggle Image         \+*grim_menu_toggle_image_event' , $
           '0\Toggle Image/Overlays \+*grim_menu_toggle_image_overlays_event' , $
           '0\Toggle Context       \+*grim_menu_context_event' , $
           '0\Toggle Axes          \*grim_menu_axes_event' , $
           '0\---------------------\*grim_menu_delim_event', $ 
           '0\Render               \grim_menu_render_event' , $
           '0\---------------------\*grim_menu_delim_event', $ 
           '0\Color Tables         \*grim_menu_view_colors_event', $ 
           '2\<null>               \+*grim_menu_delim_event', $

          '+*1\Overlays' ,$
           '0\Compute planet centers \grim_menu_points_planet_centers_event', $ 
           '0\Compute limbs          \#grim_menu_points_limbs_event', $        
           '0\Compute terminators    \#grim_menu_points_terminators_event', $
           '0\Compute planet grids   \*grim_menu_points_planet_grids_event', $ 
           '0\Compute rings          \grim_menu_points_rings_event', $
           '0\Compute ring grids     \grim_menu_points_ring_grids_event', $ 
           '0\Compute stations       \*grim_menu_points_stations_event', $ 
           '0\Compute arrays         \*grim_menu_points_arrays_event', $ 
           '0\Compute stars          \grim_menu_points_stars_event', $ 
           '0\Compute shadows        \grim_menu_points_shadows_event', $ 
           '0\Compute reflections    \?grim_menu_points_reflections_event', $ 
           '0\-------------------------\*grim_menu_delim_event', $ 
           '0\Hide/Unhide all        \+*grim_menu_hide_all_event', $ 
           '0\Clear all              \*grim_menu_clear_all_event', $ 
           '0\Clear active           \*grim_menu_clear_active_event', $ 
           '0\Activate all           \*grim_menu_activate_all_event', $ 
           '0\Deactivate all         \*grim_menu_deactivate_all_event', $ 
           '0\Invert activations     \*grim_menu_invert_event', $ 
           '0\-------------------------\*grim_menu_delim_event', $ 
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
 plot = grim_data.type EQ 'plot'
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
     beta_only_indices=beta_only_indices)


;;;;; problem is consecutive 2/<null> lines....
 menu_desc = grim_cull_menu_desc(menu_desc, plot, map, beta, $
     map_items=map_items, map_indices=map_indices, $
     od_map_items=od_map_items, od_map_indices=od_map_indices, $
     plot_items=plot_items, plot_indices=plot_indices, $
     plot_only_items=plot_only_items, plot_only_indices=plot_only_indices, $
     beta_only_indices=beta_only_indices)

 grim_data.menu_desc_p = nv_ptr_new(menu_desc)
 grim_data.map_items_p = nv_ptr_new(map_items)
 grim_data.od_map_items_p = nv_ptr_new(od_map_items)

 grim_data.menu = $
          cw__pdmenu(grim_data.mbar, menu_desc, /mbar, ids=menu_ids, $
                                                  capture='grim_menu_capture')
 grim_data.menu_ids_p = nv_ptr_new(menu_ids)
 help_menu_desc = grim_create_help_menu(menu_desc)
 grim_data.help_menu = cw__pdmenu(grim_data.mbar, help_menu_desc, /mbar)


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

 grim_data.previous_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_previous_button', $
             value=grim_previous_bitmap(), /bitmap, /tracking_events, $
                                              event_pro='grim_previous_event')

 grim_data.jumpto_text = widget_text(grim_data.shortcuts_base2, $
                     resource_name='grim_jumpto_text', xsize=3, $
                               value='', /tracking_events, /editable, $
                                              event_pro='grim_jumpto_event')

 grim_data.next_button = widget_button(grim_data.shortcuts_base2, $
             resource_name='grim_next_button', $
             value=grim_next_bitmap(), /bitmap, /tracking_events, $
                                                  event_pro='grim_next_event')


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
       ; participate in grim's capture mechanism, so the 'repeat'
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
   name = grim_parse_overlay(frame[0], obj_name)
   if(name EQ '1') then name = ''
   ptd = grim_get_all_overlays(grim_data, plane=planes[i], name=name)
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
        name = grim_parse_overlay(overlays[i], obj_name)
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
 type = 'image'
 if(keyword_set(dd)) then $
  begin 
   dim = dat_dim(dd[0])
   if(n_elements(dim) EQ 1) then type = 'plot'
   if(dim[0] EQ 2) then type = 'plot'
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
        cd=_cd, pd=pd, rd=rd, sd=sd, std=std, ard=ard, sund=sund, od=_od, $
	new=new, xsize=xsize, ysize=ysize, no_refresh=no_refresh, $
	default=default, previous=previous, restore=restore, activate=activate, $
	doffset=doffset, no_erase=no_erase, filter=filter, rgb=rgb, visibility=visibility, channel=channel, exit=exit, $
	zoom=zoom, rotate=rotate, order=order, offset=offset, retain=retain, $
        gd=gd, nhist=nhist, compress=compress, maintain=maintain, $
	mode_init=mode_init, modal=modal, xzero=xzero, frame=frame, $
	refresh_callbacks=refresh_callbacks, refresh_callback_data_ps=refresh_callback_data_ps, $
	plane_callbacks=plane_callbacks, plane_callback_data_ps=plane_callback_data_ps, $
	max=max, path=path, symsize=symsize, $
	user_psym=user_psym, workdir=workdir, mode_args=mode_args, $
        save_path=save_path, load_path=load_path, overlays=overlays, pn=pn, $
	menu_fname=menu_fname, cursor_swap=cursor_swap, fov=fov, clip=clip, hide=hide, $
	menu_extensions=menu_extensions, button_extensions=button_extensions, $
	arg_extensions=arg_extensions, loadct=loadct, grn=grn, $
	extensions=extensions, beta=beta, rendering=rendering, npoints=npoints, $
	cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, $
        sun_trs=sun_trs, stn_trs=stn_trs, arr_trs=arr_trs, assoc_xd=assoc_xd, $
        plane_syncing=plane_syncing, tiepoint_syncing=tiepoint_syncing, $
	curve_syncing=curve_syncing, render_sample=render_sample, $
	render_pht_min=render_pht_min, slave_overlays=slave_overlays, $
	position=position, delay_overlays=delay_overlays, auto_stretch=auto_stretch, $
     ;----- extra keywords for plotting only ----------
	color=color, xrange=xrange, yrange=yrange, thick=thick, nsum=nsum, ndd=ndd, $
        xtitle=xtitle, ytitle=ytitle, psym=psym, title=title
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
@grim_block.include
@grim_constants.common

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
        overlays=overlays, menu_fname=menu_fname, cursor_swap=cursor_swap, $
	fov=fov, clip=clip, menu_extensions=menu_extensions, button_extensions=button_extensions, arg_extensions=arg_extensions, $
	cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, sun_trs=sun_trs, stn_trs=stn_trs, arr_trs=arr_trs, $
	hide=hide, mode_args=mode_args, xzero=xzero, $
        psym=psym, nhist=nhist, maintain=maintain, ndd=ndd, workdir=workdir, $
        activate=activate, frame=frame, compress=compress, loadct=loadct, max=max, $
	extensions=extensions, beta=beta, rendering=rendering, npoints=npoints, $
        plane_syncing=plane_syncing, tiepoint_syncing=tiepoint_syncing, curve_syncing=curve_syncing, $
	visibility=visibility, channel=channel, render_sample=render_sample, $
	render_pht_min=render_pht_min, slave_overlays=slave_overlays, rgb=rgb, $
	delay_overlays=delay_overlays, auto_stretch=auto_stretch

 if(keyword_set(ndd)) then dat_set_ndd, ndd

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
 if(NOT keyword_set(sun_trs)) then sun_trs = ''
 
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
   if(type EQ 'plot') then mode_init = 'grim_mode_zoom_plot' $
   else mode_init = 'grim_mode_activate'
  end


 if(type EQ 'plot') then $
  begin
   if(NOT keyword_set(xsize)) then xsize = 500
   if(NOT keyword_set(ysize)) then ysize = 500
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
     if(NOT keyword_set(xsize)) then xsize = 768
     if(NOT keyword_set(ysize)) then ysize = 768
     dd = dat_create_descriptors(1, data=grim_blank(xsize, ysize), $
          name='BLANK', nhist=nhist, maintain=maintain, compress=compress)
    end $
   else $
    for i=0, n_elements(dd)-1 do $
     if(NOT keyword_set(dat_dim(dd[i]))) then $
      begin
       if(NOT keyword_set(xsize)) then xsize = 512
       if(NOT keyword_set(ysize)) then ysize = 512
       dat_set_maintain, dd[i], 0
       dat_set_compress, dd[i], compress
       dat_set_data, dd[i], grim_blank(xsize, ysize) 
      end

   if(NOT keyword_set(zoom)) then zoom = grim_get_default_zoom(dd[0])

   ;----------------------------------------------
   ; initialize data structure and common block
   ;----------------------------------------------
   grim_data = grim_init(dd, dd0=dd0, zoom=zoom, wnum=wnum, grn=grn, type=type, $
       filter=filter, retain=retain, user_callbacks=user_callbacks, $
       user_psym=user_psym, path=path, save_path=save_path, load_path=load_path, $
       cursor_swap=cursor_swap, fov=fov, clip=clip, hide=hide, $
       cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, stn_trs=stn_trs, sun_trs=sun_trs, arr_trs=arr_trs, $
       cam_select=cam_select, plt_select=plt_select, rng_select=rng_select, str_select=str_select, stn_select=stn_select, arr_select=arr_select, sun_select=sun_select, $
       cmd=cmd, color=color, xrange=xrange, yrange=yrange, position=position, thick=thick, nsum=nsum, $
       psym=psym, xtitle=xtitle, ytitle=ytitle, cursor_modes=cursor_modes, workdir=workdir, $
       symsize=symsize, nhist=nhist, maintain=maintain, $
       compress=compress, extensions=extensions, max=max, beta=beta, npoints=npoints, $
       visibility=visibility, channel=channel, keyvals=keyvals, $
       title=title, render_sample=render_sample, slave_overlays=slave_overlays, $
       render_pht_min=render_pht_min, overlays=overlays, activate=activate)


   ;----------------------------------------------
   ; initialize colors common block
   ;----------------------------------------------
   if(NOT defined(loadct)) then loadct = 0
   if(NOT keyword_set(r_curr)) then loadct, loadct
   ctmod

   ;-----------------------------
   ; widgets
   ;-----------------------------
   if(type NE 'plot') then grim_get_window_size, grim_data, xsize=xsize, ysize=ysize
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
 ;  must either be one given for each, or a single desciptor given, which 
 ;  is applied to the current plane.
 ;===========================================================================
 if(NOT keyword_set(_cd)) then _cd = dat_gd(gd, dd=dd, /cd)
 if(NOT keyword_set(_od)) then _od = dat_gd(gd, dd=dd, /od)

 if(NOT keyword_set(pd)) then pd = dat_gd(gd, dd=dd, /pd)
 if(NOT keyword_set(rd)) then rd = dat_gd(gd, dd=dd, /rd)
 if(NOT keyword_set(sd)) then sd = dat_gd(gd, dd=dd, /sd)
 if(NOT keyword_set(std)) then std = dat_gd(gd, dd=dd, /std)
 if(NOT keyword_set(ard)) then ard = dat_gd(gd, dd=dd, /ard)
 if(NOT keyword_set(sund)) then sund = dat_gd(gd, dd=dd, /sund)

 grim_data = grim_get_data()
 plane = grim_get_plane(grim_data)
 planes = grim_get_plane(grim_data, /all)
 nplanes = n_elements(planes)

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
      grim_add_descriptor, grim_data, planes[i].od_p, od[i], /one, /noregister
   if(keyword_set(cd)) then $
      grim_add_descriptor, grim_data, planes[i].cd_p, cd[i], /one

   grim_add_descriptor, grim_data, planes[i].pd_p, pd, assoc_xd=_assoc_xd[i]
   grim_add_descriptor, grim_data, planes[i].rd_p, rd, assoc_xd=_assoc_xd[i]
   grim_add_descriptor, grim_data, planes[i].std_p, std, assoc_xd=_assoc_xd[i]
   grim_add_descriptor, grim_data, planes[i].ard_p, ard, assoc_xd=_assoc_xd[i]
   grim_add_descriptor, grim_data, planes[i].sd_p, sd, assoc_xd=_assoc_xd[i]
;--   grim_add_descriptor, grim_data, planes[i].sd_p, sund, assoc_xd=_assoc_xd[i]
   grim_add_descriptor, grim_data, planes[i].sund_p, sund, /one, assoc_xd=_assoc_xd[i]
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
   if(type NE 'plot') then $
      for i=0, nplanes-1 do $
         dat_set_sampling_fn, planes[i].dd, 'grim_sampling_fn', /noevent

   entire = 1 & default = 0
   if(type EQ 'plot') then $
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
 if(keyword_set(highlght)) then $
                   grim_set_toggle_flag, grim_data, 'PLANE_HIGHLIGHT', 1


 ;----------------------------------------------
 ; if new instance, initialize menu extensions
 ;----------------------------------------------
 if(new) then $
  begin
   if(keyword_set(menu_extensions)) then $
    begin
     for i=0, n_elements(menu_extensions)-1 do $
         if(routine_exists(menu_extensions[i]+'_init')) then $
                  call_procedure, menu_extensions[i]+'_init', grim_data
    end
  end

 ;----------------------------------------------
 ; if new instance, initialize cursor modes
 ;----------------------------------------------
 if(new) then $
     for i=0, n_elements(cursor_modes)-1 do $
        if(routine_exists(cursor_modes[i].name+'_init')) then $
            call_procedure, cursor_modes[i].name+'_init', grim_data, cursor_modes[i].data_p



 ;----------------------------------------------
 ; if new instance, initialize menu toggles
 ;----------------------------------------------
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
         'grim_menu_plane_highlight_event', $
          grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')
  end


 ;-------------------------
 ; initial color stretch
 ;-------------------------
 if(keyword_set(auto_stretch)) then grim_stretch_plane, grim_data, planes

 ;-------------------------
 ; draw initial image
 ;-------------------------
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, no_erase=no_erase


 ;----------------------------------------------
 ; compute any initial overlays
 ;----------------------------------------------
 if(keyword_set(overlays)) then $
    if(NOT keyword_set(delay_overlays)) then $
                        grim_initial_overlays, grim_data, plane=_plane


end
;=============================================================================
