Image curve fitting library
===========================

 The purpose of the image curve fitting routines is to perform a least-square
 fit to the offset between a specified curve and a feature in an image.
 This is done by first searching for the curve in the image and then
 computing coefficients for a linear least-square fit.  The search consists of
 scanning for the greatest correlation between a portion of the image and a
 specified edge model within some distance from the specified curve at every
 point.  Once the linear coefficients have been computed, they can be input
 to mbfit as part of a simultaneous linear least-square fit.


