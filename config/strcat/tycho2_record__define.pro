; docformat = 'rst'
;+
; Format of one line of the TYCHO-2 tyc2.dat catalog file
; 
; :Fields:
;    tyc1 : type=integer
;       [1,9537]+= TYC1 from TYC or GSC
;    tyc2 : type=long
;       [1,12121]  TYC2 from TYC or GSC
;    tyc3 : type=integer
;       [1,3]      TYC3 from TYC
;    pflag : type=string
;       [ PX] mean position flag
;    mRAdeg : type=float
;       []? Mean Right Asc, ICRS, epoch=J2000
;    mDEdeg : type=float
;       []? Mean Decl, ICRS, at epoch=J2000
;    pmRA : type=float
;       ? Proper motion in RA*cos(dec)
;    pmDE : type=float
;       ? Proper motion in Dec
;    e_mRA : type=integer
;       [3,183]? s.e. RA*cos(dec),at mean epoch
;    e_mDE : type=integer
;       [1,184]? s.e. of Dec at mean epoch
;    e_pmRA : type=float
;       [0.2,11.5]? s.e. prop mot in RA*cos(dec)
;    e_pmDE : type=float
;       [0.2,10.3]? s.e. of proper motion in Dec
;    mepRA : type=float
;       [1915.95,1992.53]? mean epoch of RA
;    mepDE : type=float
;       [1911.94,1992.01]? mean epoch of Dec
;    Num : type=integer
;       [2,36]? Number of positions used
;    g_mRA : type=float
;       [0.0,9.9]? Goodness of fit for mean RA
;    g_mDE : type=float
;       [0.0,9.9]? Goodness of fit for mean Dec
;    g_pmRA : type=float
;       [0.0,9.9]? Goodness of fit for pmRA
;    g_pmDE : type=float
;       [0.0,9.9]? Goodness of fit for pmDE
;    BT : type=float
;       [2.183,16.581]? Tycho-2 BT magnitude
;    e_BT : type=float
;       [0.014,1.977]? s.e. of BT
;    VT : type=float
;       [1.905,15.193]? Tycho-2 VT magnitude
;    e_VT : type=float
;       [0.009,1.468]? s.e. of VT
;    prox : type=integer
;       [3,999] proximity indicator
;    TYC : type=string
;       [T] Tycho-1 star
;    HIP : type=long
;       [1,120404]? Hipparcos number
;    CCDM : type=string
;       CCDM component identifier for HIP stars
;    RAdeg : type=float
;       Observed Tycho-2 Right Ascension, ICRS
;    DEdeg : type=float
;       Observed Tycho-2 Declination, ICRS
;    epRA : type=float
;       [0.81,2.13]  epoch-1990 of RAdeg
;    epDE : type=float
;       [0.72,2.36]  epoch-1990 of DEdeg
;    e_RA : type=float
;       s.e.RA*cos(dec), of observed Tycho-2 RA
;    e_DE : type=float
;       s.e. of observed Tycho-2 Dec
;    posflg : type=string
;       [ DP] type of Tycho-2 solution
;    corr : type=float
;       [-1,1] correlation (RAdeg,DEdeg)
;
; :Private:
;-
pro tycho2_record__define

struct = $
  { tycho2_record, $
    tyc1:	     0,  $
    tyc2:	     0l, $
    tyc3:	     0,  $
    pflag:	   '', $
    mRAdeg:	   float(0), $
    mDEdeg:	   float(0), $
    pmRA:	     float(0), $
    pmDE:	     float(0), $
    e_mRA:	   0,  $
    e_mDE:	   0,  $
    e_pmRA:	   float(0), $
    e_pmDE:    float(0), $
    mepRA:	   float(0), $
    mepDE:	   float(0), $
    Num:	     0,  $
    g_mRA:	   float(0), $
    g_mDE:	   float(0), $
    g_pmRA:	   float(0), $
    g_pmDE:	   float(0), $
    BT:		     float(0), $
    e_BT:	     float(0), $
    VT:		     float(0), $
    e_VT:	     float(0), $
    prox:	     0,  $
    TYC:	     '', $
    HIP:	     0l, $
    CCDM:	     '', $
    RAdeg:	   float(0), $
    DEdeg:	   float(0), $
    epRA:	     float(0), $
    epDE:	     float(0), $
    e_RA:	     float(0), $
    e_DE:	     float(0), $
    posflg:	   '', $
    corr:	     float(0)  $
  }

end
