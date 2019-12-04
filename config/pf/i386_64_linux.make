###############################################################################
# i386_linux.make
#
#  libc0.a is simply libc.a, copied from an early version of redhat for 
#  backward compatibility.
#
###############################################################################
GCC=		gcc
LDSO=		ld
SO_CC_OPTIONS=	-shared -fPIC
CC_OPTIONS=	 
SO_LD_OPTIONS=	-shared -Bstatic
ANSI=	
COPY=		cp
ARCHIVE=	ar rcv
DEARCHIVE=	ar -x
SOCKET_LIBS=	
DL_LIBS=	
MATH_LIBS=	-lm
#C_LIBS=		-lc0 $(SOCKET_LIBS) $(DL_LIBS) $(MATH_LIBS)
C_LIBS=		-lc $(SOCKET_LIBS) $(DL_LIBS) $(MATH_LIBS)


###############################################################################
