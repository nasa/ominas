Image point fitting library
===========================

 The purpose of the image point fitting routines is to perform a least-square
 fit to the offset between a specified set of discrete points and discrete
 features in an image.  This is done by first searching for the features
 in the image and then computing coefficients for a linear least-square
 fit.  Once the linear coefficients have been computed, they can be input
 to mbfit as part of a simultaneous linear least-square fit.

	
