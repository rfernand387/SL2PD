#include <math.h> 
#include <stdio.h>
#include <stdlib.h>
/*
	FLIGHT - Forest LIGHT interaction model 
 	P.R.J. NORTH

	"THREE DIMENSIONAL FOREST LIGHT INTERACTION MODEL USING A MONTE CARLO METHOD",
	IEEE TRANACTIONS ON GEOSCIENCE AND REMOTE SENSING,
	VOL. 34, NO. 4, PP. 946-956, JULY 1996


	Version 6.3; October 2006
	Modifed by C. Barton to include photosynthetic rate calculations (2001).
	Modified by P. Alton to add full photosynthesis model and allow vertical profiles (2005) 
	Various modifications by M. A. Watson, esp facet & optasm BRDF (2005)


	Parameters/variables used -

	in_flight.data:
	MODE		Mode of operation: Forwards  ('f'), image  ('i'), solid-object image  ('s'), reverse ('r')
	ONED_FLAG	Dimension of model: '0' or '3' means 3D Representation, '1' means 1D representation
	SOLAR_ZENITH,VIEW_ZENITH  	Source zenith & View zenith  (degrees). (Negative value for source => diffuse beam only) 
	SOLAR_AZIMUTH,VIEW _AZIMUTH 	Source azimuth & View azimuth angles (degrees)
	NO_WVBANDS	Number of wavebands simulated
	NO_PHOTONS	Number of photon paths simulated
	TOTAL_LAI	Mean one-sided total foliage area index for scene (m^2/m^2)
	FRAC_GRN,FRAC_SEN,FRAC_BARK	Foliage composition:
				FRAC_GRN	Fraction of green leaves in foliage by area
				FRAC_SEN	Fraction of senescent/shoot material in foliage "    "
				FRAC_BARK	Fraction of bark in foliage   "    "	
	LAD[1-9]	Leaf angle distribution, giving angle between normal to leaves and vertical,
			expressed as fraction lying within 10 degree bins 0-10, 10-20, 20-30... 80-90
	SOILROUGH	Soil roughness index (0-1). Lambertian soil given by 0, rough (mean slope 60deg) given by 1
	AER_OPT		Aerosol optical thickness at 555nm (A negative value means direct beam only)
	LF_SIZE		Leaf size (radius, approximating leaf as circular disc).
	FRAC_COV	Fraction of ground covered by vegetation (on vertical projection, and approximating
			crowns as opaque)

	For 3D case only:

	CROWN_SHAPE	'e' for ellipsoid, 'c' for cones, 'f' for field data in file crowns.dat
	Exy, Ez		Crown radius (Exy), and centre to top distance (Ez). For cones, Ez gives crown
				height, while for ellipsoids it gives half of the crown height. 
	MIN_HT,MAX_HT	Min and Max height to first branch. Crowns randomly distributed between these ranges.
			Total canopy height will be the sum of this value and crown height
	DBH		Trunk dbh. Trunks approximated as cones from ground to top of crown. 
			A zero value indicates trunks should not be modelled (resulting in much faster calculation)

	Nb: all distances are specified in metres. For the 1D case, canopy height is assumed to be 1m, and LF_SIZE
	    should be scaled in proportion, in range 0-1.


Implicit files:

	Leaf/soil spectra:
		SPEC/leaf.spec:	WAVEBAND LEAF_REFLECTANCE LEAF_TRANSMITTANCE 
		SPEC/soil.spec:	WAVEBAND SOIL_REFLECTANCE
		SPEC/sen.spec:	WAVEBAND SEN_REFLECTANCE SEN_TRANSMITTANCE
		SPEC/bark.spec:	WAVEBAND BARK_REFLECTANCE

	Data files:

		DATA/soilbrdf.data:	BRDF shape of rough soil
		DATA/hotspot.data:	Hot-spot shape data
		DATA/lad.data:	  	Example leaf angle distributions

Internal  variables (global):

	RESULT_ZEN_GRID Number of angular bins in zenith angle to accumulate result
	RESULT_AZ_GRID	Number of angular bins in azimuth "	"	"	"
	NIR		Waveband (0=first) corresponding to greatest scattering (usually nir) 
	X_DIM 		Dimensions of "box" scene is located within (from -X_DIM to + X_DIM)
	Y_DIM  		"	"	"	"	"	"   (from -Y_DIM to + Y_DIM)
	NOSTANDS	Number of trees represented in scene


Output files:
	RESULT/XX		Array of BRDF values
	RESULT/XX.log		Log showing albedo, component absorption and nadir reflectance per waveband

-------------------------------------------------------------------------------------------------------------

Contact:
	Dr Peter North
	Environmental Modelling and Earth Observation Group,
	Dept. of Geography,
        University of Wales,
        Singleton Park,
	Swansea
	SA2 8PP

	Email P.R.J.North@swan.ac.uk


Publications should cite the references:

	P.R.J. North,"Three-dimensional forest light interaction model using a Monte Carlo method",
	IEEE Tranactions on Geoscience and Remote Sensing, Vol. 34, No. 4, pp. 946-956, July 1996.
	
	and 
	
	Alton, P.B., North, P., Kaduk, J. and Los, S.O., 2005. Radiative transfer modelling of direct
	and diffuse sunlight in a Siberian pine forest. Journal of Geophysical Research,110(D23): D23209

Further references on applications and development of this model:

	F.F. Gerard,  and P.R.J. North, "Analyzing the effect of structural variability
	and canopy gaps on Forest BRDF using a geometric-optical model", RSE 62:46-62, 1997.

	Dawson, T.P., Curran, P.J., North, P.R.J. and Plummer, S.E., 1999. The propagation of
	foliar biochemical absorption 	features in forest canopy reflectance: A theoretical analysis,
	Remote Sensing of Environment, Vol. 67, No. 2, pp. 147-159.
	
	Disney, M.I., Lewis, P. and North, P.R.J., 2000, Monte Carlo ray tracing in optical canopy
	reflectance modelling, Remote Sensing Reviews, Vol 18, No. 2-4, 197-226.
	
	Barton, C.V.M. and North, P.R.J., 2001, Remote sensing of canopy light use efficiency using
	the photochemical reflectance index: model and sensitivity analysis, Remote Sensing of Environment,78,164-273.
	
	Pinty, B., et al. 2001. The RAdiation transfer Model Intercomparison (RAMI) exercise, Journal of
	 Geophysical Research., 106(D11), 11,937-11,956.
	 
	North, P.R.J., 2002, Estimation of fAPAR, LAI and vegetation fractional cover from ATSR-2 imagery, Remote
	 Sensing of Environment, 80, 114-121.
	 
	Pinty, B., et al., Radiation Transfer Model Intercomparison (RAMI) exercise: Results from the second phase,
	Journal of Geophysical Research, 109 (D6).
	
	Los, S.O., North, P.R.J., Grey, W.M.F and Barnsley, M.J., 2005. A method to convert AVHRR Normalised
	 Difference Vegetation Index time-series to a standard viewing and illumination geometry. Remote
	 Sensing of Environment, 99(4): 400-411

	-------------------------------------------------------------------------------------------------------------  
*/



/*  MW:  ** Debugging macro **   */

#ifdef DEBUG
#define debugp printf
#else
#define debugp
#endif

// To turn on debugging print statements [debugp() statements], compile this file including -DDEBUG flag (defines the DEBUG statement needed for macro)
//
// e.g.:    cc -O -o FLIGHT56 flight56.c -lm -DDEBUG
//
// Works by replacing 'debugp' with 'printf' throughout code...
//
// Re-compile leaving out -DDEBUG to turn off again!
//
// This is independent of Peter's FPDEBUG routines...




#define BIN_OUT 0  /*  MW:  ** Binary image output, for reading with ENVI **   */

#define FLOAT_OUT 1  /*  MW:  ** Floating point image output, for reading with IDL **   */

#define MULT_VIEWS 0  //MW2: ** Not yet properly implemented, so leave as zero! Flag for triggering  runs of FLIGHT at different view angles, giving start, end and increment for solar and view azimuths in in_flight.data **  


// 1 = enabled, 0 = disabled





/*
	-------------------------------------------------------------------------------------------------------------  

The following four 'constants' may be changed. They define:

 	MAX_NOSTANDS        maximum number  of individual 'trees' represented. 
	MAX_NO_WVBANDS      maximum number  of wavebands possible.
	RESULT_ZEN_GRID     no. of bins  in zenith angle (0-90) to accumulate BRDF angular variation. 10 => 10 deg intervals,
				0-5, 5-15, 15-25, 25-35, 35-45... 75-85, 85-90
	RESULT_AZ_GRID      no. of bins in azimuth angle (0-360) to accumulate BRDF angular variation. 36 => 10 deg intervals.
				-5 to +5, 15-25, 25-35... 345-355


	To change to get 5 deg * 5 deg sampling, we would have :
		#define RESULT_ZEN_GRID 19
		#define RESULT_AZ_GRID 72

	while 1.25 deg sampling would use:
		#define RESULT_ZEN_GRID 73
		#define RESULT_AZ_GRID 288

	Nb: As the angular bins get smaller, more photon trajectories must be simulated to achieve an accurate result.
		SD Mean Err ~ sqrt(RESULT_AZ_GRID*RESULT_ZEN_GRID/NO_PHOTONS). E.g.  for ~5% error, at 19 * 72 grid,
		we need NO_PHOTONS = 550000
		
	CAVEAT:	A drawback of this sampling scheme is that solid angle extended by bins is not constant,
		generally getting larger away from nadir (except nadir itself and 85-90). 
		This should not affect mean values, only relative accuracy, as smaller bins are less sampled.

*/

#define MAX_NOSTANDS 50
#define MAX_NO_WVBANDS 302
#define MAX_NOFACETS 100
#define NO_COMPS (MAX_NOFACETS*2+10)    //MW: no. of scene components
/* NO_COMPS must be at least 2* NO_FACETS used */

#define RESULT_ZEN_GRID 19   //MW: for bins of size N degrees:  RESULT_ZEN_GRID = (90/N)+1
#define RESULT_AZ_GRID 72    //MW: for bins of size N degrees:  RESULT_AZ_GRID = (360/N)


/*	Internal constants that should not be changed */

#define GXVAL 10
#define GYVAL 10
#define GZVAL 19
#define GROUND_PLANE_NUMBER -1
#define SKY_PLANE_NUMBER -2
#define WALL1_NUMBER -3
#define WALL2_NUMBER -4
#define WALL3_NUMBER -5
#define WALL4_NUMBER -6
#define TRUNK_NUMBER -7
#define LEAF_NUMBER -8
#define SEN_NUMBER -9
#define BARK_NUMBER -10
#define FACET_NUMBER -11
#define PHOTON_THRESHOLD 0.0005
#define NO_ANGLES 10
#define PXVAL 19 
#define PYVAL 19
#define PZVAL 37
#define FAX 100
#define FAY 100

#define SKOPT 7
#define SKWV 4
#define SKSZEN 10
#define SKVZEN 10
#define SKRAZ 19


#define RDEG 57.2958
#define PI 3.1415927

#define MAX_ORDER_SCAT 200

/*  Global variables */

float gnd_fn_array[GXVAL][GYVAL][GZVAL];
float hot_spot_array[301][800];
int COLLISION_NO;
int ONED_FLAG;
float RAND_MULT;

struct stand *STANDS[MAX_NOSTANDS];
float ANGLES[NO_ANGLES];
float phase_fn_array[MAX_NO_WVBANDS][PXVAL][PYVAL][PZVAL];
float bk_phase_fn_array[MAX_NO_WVBANDS][PXVAL][PYVAL][PZVAL];
float sen_phase_fn_array[MAX_NO_WVBANDS][PXVAL][PYVAL][PZVAL];
double result[MAX_NO_WVBANDS][RESULT_ZEN_GRID][RESULT_AZ_GRID][3];
float fc_result[NO_COMPS];
char component_names[NO_COMPS][50];
float EXTINCTION_COEF_ARRAY[91];
float CANOPY_TOP, CANOPY_TOP_IN, CANOPY_TOP_OUT;
float NIR_LEAKAGE=0.0;
int WLIST[4][MAX_NOSTANDS];
int NIR;
float TOTAL_LAI;
float DIFF_FRAC[MAX_NO_WVBANDS];
float LEAKAGE[MAX_NO_WVBANDS];
float ALBEDO[MAX_NO_WVBANDS][3];
double ABS_SOIL[MAX_NO_WVBANDS][3];
double ABS_CANOPY_GR[MAX_NO_WVBANDS][3];
double ABS_CANOPY_SEN[MAX_NO_WVBANDS][3];
double ABS_CANOPY_BK[MAX_NO_WVBANDS][3];
float BRF[MAX_NO_WVBANDS][RESULT_ZEN_GRID][RESULT_AZ_GRID][3];
float BARK_LAI;
float Ez;
float Exy;
float SCALE_FACTOR;
int FIELD_DATA;

char MODE;
float SOLAR_ZENITH;
float SOLAR_AZIMUTH;
int NO_WVBANDS;
int NO_PHOTONS;
float LAI;
float FRAC_GRN, FRAC_SEN, FRAC_BARK;
float LAD[NO_ANGLES];
float SOILROUGH;
float AER_OPT;
float LF_SIZE;
float DBH;
int DIFF_SKY_FLAG;
int TRUNKFLAG;
int TRUNK_PRES;
int NOSTANDS;
float X_DIM;
float Y_DIM;
float Z_DIM;
float TOP_ONED;

float FRAC_COV;
char CROWN_SHAPE;
float CONE_ANGLE;
float TRUNK_ANGLE=1.0;
float CONE_HEIGHT;	
float HT_TO_WD=2.0;
float MIN_HT;
float MAX_HT;
float RHO[MAX_NO_WVBANDS];
float TAU[MAX_NO_WVBANDS];
int WAVELENGTH[MAX_NO_WVBANDS];
float GROUND_REFLECTANCE[MAX_NO_WVBANDS];
float BARK[MAX_NO_WVBANDS];
float RHO_SEN[MAX_NO_WVBANDS];
float TAU_SEN[MAX_NO_WVBANDS];
int COMPNO;
float MAXVAL_LAD;

float VIEW_ZENITH, VIEW_ZENITH_START;
float VIEW_AZIMUTH, VIEW_AZIMUTH_START;
float VIEW_ZENITH_END, VIEW_ZENITH_STEP;    //MW2: Variables allowing for multiple views
float VIEW_AZIMUTH_END, VIEW_AZIMUTH_STEP;

int run_count;  //MW2: counter for multiple runs of FLIGHT

float SOLAR_RAD[MAX_NO_WVBANDS];     	/* Direct beam radiance received on plane normal to beam */
float SKY_RAD[MAX_NO_WVBANDS];       	/* Sky radiance - received by a horizontal plane */
float TOTAL_RAD[MAX_NO_WVBANDS];	/* Direct + sky randiance - used as input */
float SKY_ARRAY[SKOPT][SKWV][SKSZEN][SKVZEN][SKRAZ]; /* Sky radiance - angular distribution  */
struct point *GROUND_NORM;		/* Ground normal vector */

/* Values for reverse mode, to be read from 'reverse.data' -  */

int BOUNCE_THRESHOLD;			/* Scattering order evaluated */
int BRANCH_NO;			/* No of diffuse samples per image point */
int IM_SIZE;					/* Image size (m*m) 0 uses default */
int N_LUE_SAMPLES;					/* Lue sample numbers (0 means do not estimate lue) */
int PRI_BAND_NO;			/* Waveband number of PRI band (ie 531 nm) -1 means do not use PRI calculation*/
int PRI_REFER_BAND_NO;			/* Waveband number of PRI reference band (ie 570 nm) */
float PAR_RAD;					/*  Total incoming radiation in PAR region umol m-2 s-1 */
float IR_RAD;					/* Total incoming radiation in IR region umol m-2 s-1 */
float KM;					/* Photosynthetic rate coeficient */
float PMAX;					/* Max photosynthetic rate  C umol-1 */

/* Global variables for photosynthesis calculation (PBA), to be read from in_flight_photosynthesis.data  */
float ALPHA;					
float VCMAX;					
float K_RUB;
float T_UP;
float T_DOWN;
float FDIF;
float MIN_GREEN_HEIGHT; /* Calculated from canopy structure in forest_gen3() */
int PHOTOSYNTHESIS_MODEL; /* 0=empirical hyperbolic model, 1=MOSES based model*/

double HEIGHT_LAST_SCATTER[MAX_NO_WVBANDS][3][100];     /*  PBA - GLOBALS FOR ABSORPTION AND SCATTERING HEIGHTS */
double HEIGHT_ABS_SOIL[MAX_NO_WVBANDS][3][100];
double HEIGHT_ABS_GR[MAX_NO_WVBANDS][3][100];
double HEIGHT_ABS_SEN[MAX_NO_WVBANDS][3][100];
double HEIGHT_ABS_BK[MAX_NO_WVBANDS][3][100];
double HEIGHT_ABS_GR_DIRECT[MAX_NO_WVBANDS];

struct facet *FACET[MAX_NOFACETS];
int NOFACETS;
int FACET_FLAG;
int SKY_MODEL;			/* Flag (0=isotropic diffuse;  1=non-isotropic diffuse according to tau, sun position */


int ACT_SOURCE_FLAG;
struct source *ACT_SOURCE;
float PATH_LENGTH[MAX_ORDER_SCAT];

struct plane *GROUND_PLANE,*SKY_PLANE,*WALL1,*WALL2,*WALL3,*WALL4;

void	threed_light_incident_on_facet(int,struct point *,int,struct point *,struct point *,int,double [MAX_NO_WVBANDS][MAX_ORDER_SCAT],double [MAX_NO_WVBANDS][MAX_ORDER_SCAT],double[MAX_NO_WVBANDS][MAX_ORDER_SCAT],int);
struct photon *find_reflectance(struct stand *,struct photon *photon);
float lue_fn(int,float,float);


/*	Data type definitions */


float degtorad(degrees)
	float degrees;
{	return (degrees * PI/180.0); }

struct stand {

	float lai;
	char crown_shape;
	struct ellipse *ellipse;
	struct cone *cone;
	struct cone *cone2;
	int list[MAX_NOSTANDS];
	float low[MAX_NOSTANDS];
	float high[MAX_NOSTANDS];
};



struct plane {
	float a;
	float b;
	float c;
	struct point *p1;
	struct point *p2;
	struct point *p3;
};

struct point {
	float x;
	float y;
	float z;
	float theta;
	float phi;
};

struct cone {
	struct point *apex;
	float tansqphi;
	float h;
	float radius_sq;
	float sphere_radius;
};            
	
struct ellipse {

	struct point *centre;
	float Ex;
	float Ey;
	float Ez;

};

struct cylinder {
	struct point *centre;
	float radius;
	float length;
	struct point *orientation;
};

struct distandpoint {
	float r;
	struct point *point;
};

struct standpoint {
	int standno;
	struct point *point;
};
	
struct photon {
	struct point *pos;
	struct point *vec;
	float intensity[MAX_NO_WVBANDS];
};


struct source {
 struct point *pos;
 struct point *vec;
 float radius;
 float sd_angle;
 float range;

 float  RAD[MAX_NO_WVBANDS];
};

struct facet {

/* t1,t2,t3 are vertices; fnormal is normal vector, fplane is plane, RHO is lambertian reflectance, opt_rho, A and B give optasm description for specular peak. If more peaks are added, then modify to opt_rho[MAX_NO_WVBANDS][MAX_NO_PEAKS] etc */

	struct point *t1;
	struct point *t2;
	struct point *t3;
	struct point *fnormal;
	struct plane *fplane;

	float RHO[MAX_NO_WVBANDS];
/* 	float opt_rho;
	float opt_A;
	float opt_B;
*/
};


struct threed_data {
/* type: type of facet (e.g. leaf, ground)
   stno: number of stand if within envelope, otherwise -1
   x,y,z location of facet       	*/
  
	int type;
	int stno;
	float x;
	float y;
	float z;
};

struct source *source_alloc()
{	
	return (struct source *) malloc(sizeof(struct source));
}

struct facet *facet_alloc()
{	
	return (struct facet *) malloc(sizeof(struct facet));
}

struct stand *stalloc()
{	
	return (struct stand *) malloc(sizeof(struct stand));
}

struct distandpoint *dpalloc()
{	
	return (struct distandpoint *) malloc(sizeof(struct distandpoint));
}

	
struct plane *plalloc()
{	
	return (struct plane *) malloc(sizeof(struct plane));
}
	
struct point *ptalloc()
{	
	return (struct point *) malloc(sizeof(struct point));
}

struct standpoint *spalloc()
{	
	return (struct standpoint *) malloc(sizeof(struct standpoint));
}

struct photon *phalloc()
{	
	return (struct photon *) malloc(sizeof(struct photon));
}

struct cone *conealloc()
{
	return (struct cone *) malloc(sizeof(struct cone));
}
	
struct ellipse *ellipsealloc()
{
	return (struct ellipse *) malloc(sizeof(struct ellipse));
}

struct cylinder *cylinalloc()
{
	return (struct cylinder *) malloc(sizeof(struct cylinder));
}


struct stand *mkstand_cone(lai,cone,cone2)
	float lai; 
	struct cone *cone;struct cone *cone2;

{	struct stand *st;
	st=stalloc();
	st->lai=lai;
	st->crown_shape='c';
	st->cone=cone;
	st->cone2=cone2;
	return st;
}

struct stand *mkstand_ellipse(lai,ellipse,cone2)
	float lai; 
	struct ellipse *ellipse;struct cone *cone2;

{	struct stand *st;
	st=stalloc();
	st->lai=lai;
	st->crown_shape='e';
	st->ellipse=ellipse;
	st->cone2=cone2;
	return st;
}

struct cylinder *mkcylinder(cen,rad,len,orient)
	float rad,len;
	struct point *cen; struct point *orient;
{
	struct cylinder *cy;
	cy=cylinalloc();
	cy->centre=cen;
	cy->radius=rad;
	cy->length=len;
	cy->orientation=orient;
	return cy;
}

struct plane *mkplane(p1,p2,p3)
	struct point *p1,*p2,*p3;

{
	struct plane *pl;
	float x1,y1,z1,x2,y2,z2,x3,y3,z3;

	x1=p1->x;
	y1=p1->y;
	z1=p1->z;
	x2=p2->x;
	y2=p2->y;
	z2=p2->z;
	x3=p3->x;
	y3=p3->y;
	z3=p3->z;
	

	pl=plalloc();

	pl->a=(-(y2*z1) + y3*z1 + y1*z2 - y3*z2 - y1*z3 + y2*z3)/
    (-(x3*y2*z1) + x2*y3*z1 + x3*y1*z2 - x1*y3*z2 - x2*y1*z3 + x1*y2*z3); 
 

	pl->b= (x2*z1 - x3*z1 - x1*z2 + x3*z2 + x1*z3 - x2*z3)/
    (-(x3*y2*z1) + x2*y3*z1 + x3*y1*z2 - x1*y3*z2 - x2*y1*z3 + x1*y2*z3);

	pl->c=(-(x2*y1) + x3*y1 + x1*y2 - x3*y2 - x1*y3 + x2*y3)/
    (-(x3*y2*z1) + x2*y3*z1 + x3*y1*z2 - x1*y3*z2 - x2*y1*z3 + x1*y2*z3);

	pl->p1=p1;
	pl->p2=p2;
	pl->p3=p3;
	return pl;
}

struct point *mkpoint(x,y,z)
	float x,y,z;
{
	struct point *pt;
	pt=ptalloc();
	pt->x=x;
	pt->y=y;
	pt->z=z;
	return pt;
}

struct cone *mkcone(apex,angle,height)
	struct point *apex;
	float angle,height;
{	struct cone *cone;
	cone=conealloc();
	cone->apex=apex;
	cone->tansqphi=tan(angle)*tan(angle);
	cone->h=height;
	cone->radius_sq=height*tan(angle)*height*tan(angle);
	cone->sphere_radius=sqrt(cone->radius_sq+height*height);
	return cone;
}

struct ellipse *mkellipse(centre,Ex,Ey,Ez)
	struct point *centre;
	float Ex,Ey,Ez;
{	
	struct ellipse *ellipse;
	ellipse=ellipsealloc();
	ellipse->centre=centre;
	ellipse->Ex=Ex;
	ellipse->Ey=Ey;
	ellipse->Ez=Ez;
	return ellipse;
}

struct standpoint *mkstandpoint(stno,pos)
	int stno;
	struct point *pos;
{	struct standpoint *sp;
	sp=spalloc();
	sp->standno=stno;
	sp->point=pos;
	return sp;
}

struct photon *mkphoton(position,vector,intensity)
	struct point *position,*vector;
	float *intensity;	
{	struct photon *ph;
	int i;
	ph=phalloc();
	ph->pos=position;
	ph->vec=vector;
	for (i=0;i<NO_WVBANDS;i++) ph->intensity[i]=intensity[i];
	return ph;
}

struct point *vplus(p1,v1)
	struct point *p1,*v1;
{
	struct point *p1plusv1;
	p1plusv1=mkpoint(p1->x+v1->x,p1->y+v1->y,p1->z+v1->z);
	return p1plusv1;
}


void vreverse(v1)
struct point *v1;
{
	v1->x=-v1->x;v1->y=-v1->y;v1->z=-v1->z;
}

struct point *vminus(p1,v1)
	struct point *p1,*v1;
{
	struct point *p1minusv1;
	p1minusv1=mkpoint(p1->x-v1->x,p1->y-v1->y,p1->z-v1->z);
	return p1minusv1;
}


int	vnormalise(vec)
	struct point *vec;
{
	float det;
	det=sqrt((vec->x)*(vec->x)+(vec->y)*(vec->y)+(vec->z)*(vec->z));
	vec->x=vec->x/det;
	vec->y=vec->y/det;
	vec->z=vec->z/det;
}

struct point *vcross(u,v)
	struct point *u,*v;		
/* Normalised vector cross product */
{
	float xsq,ysq;
	struct point *crossuv;
	crossuv=mkpoint(u->y*v->z - u->z*v->y, u->z*v->x - u->x*v->z, u->x*v->y - u->y*v->x);
	vnormalise(crossuv);
	xsq=crossuv->x*crossuv->x;
	ysq=crossuv->y*crossuv->y;
	crossuv->theta=acos(crossuv->z);
	crossuv->phi=acos(sqrt(xsq/(xsq+ysq)));
	return crossuv;
}

float dist(v1,v2)
	struct point *v1,*v2;
	
/* Distance between two points  */
{
	float d;
	d=sqrt((v1->x-v2->x)*(v1->x-v2->x) + (v1->y-v2->y)*(v1->y-v2->y) + (v1->z-v2->z)*(v1->z-v2->z));
	return d;
}

float absfn(value)
	float value;
{
	if (value<0.0) return -1.0*value;
	else return value;
}

float dot(vec1,vec2)
	struct point *vec1,*vec2;
	
	/* Takes dor product of 2 vectors, assuming *normalised*. Checks for rounding
		errors leading to values outsed -1<x<1, which previously led to error */
{
	float value;
	value=(vec1->x*vec2->x + vec1->y*vec2->y + vec1->z*vec2->z);
	if (value<-1.0 )return -1.0;
	else if (value>1.0) return 1.0;
	else return value;
}


float rand2()
/* Generate  precision random number in range 0-1. Where RAND_MAX is 
32767, rand() gives too small a range to adequately sample sphere of directions
at high angular resolution */

{
	float temp1,temp2,temp3,temp4;

	temp1=(float)rand()/((float)RAND_MAX+1.0);
	temp2=(float)rand()/(float)(RAND_MAX);
	temp3=(float)((int)(temp1*100.0))+temp2;
	temp4=(temp3)/100.0;

	return temp4;

}




/* Functions to allow photon trajectory simulation */



int inside_stand(pos,stand_number)
	struct point *pos;
	int stand_number;

/*	Checks if a photon is within the boundary of a crown */

{
	float x1,y1,z1,cx,cy,cz,h,tsq,dist_from_apex_sq,max_dist_sq,kx,ky,kz;

	struct cone *cone;
	struct ellipse *ellipse;

	x1=pos->x;y1=pos->y;z1=pos->z;

	if (STANDS[stand_number]->crown_shape=='c') {

		cone=STANDS[stand_number]->cone;
		cx=cone->apex->x;cy=cone->apex->y;cz=cone->apex->z;
		h=cone->h;

		tsq=cone->tansqphi;

		dist_from_apex_sq=(x1-cx)*(x1-cx)+(y1-cy)*(y1-cy);
		max_dist_sq=(cz-z1)*(cz-z1)*tsq;
	}
	else {


		ellipse=STANDS[stand_number]->ellipse;
		cx=ellipse->centre->x;cy=ellipse->centre->y;cz=ellipse->centre->z;

		kx=(x1-cx)/ellipse->Ex;
		ky=(y1-cy)/ellipse->Ey;
		kz=(z1-cz)/ellipse->Ez;

		dist_from_apex_sq=(kx*kx+ky*ky+kz*kz);
		max_dist_sq=1.0;
	}


	if (	(dist_from_apex_sq<max_dist_sq) && 
		((STANDS[stand_number]->crown_shape=='e' ) || ((cz-z1)<h) && (z1<cz)) )
		return 1;
	else return 0;
}
		


		
int replace_if_out(photon)
	struct photon *photon;

/*	After intersection with one of walls in bounding box, replace
	photon on opposite wall with same direction vector.
	Checks if photon has been placed inside a crown envelope, as
	crowns are allowed to intersect with walls. If so returns the
	crown number
*/
	
{
	int i,wno,res=0;

	wno=-1;
	if (photon->pos->x>X_DIM) {photon->pos->x=-X_DIM+0.01;wno=1;}
		
	if (photon->pos->x<-1*X_DIM) {photon->pos->x=X_DIM-0.01;wno=0;}
	if (photon->pos->y>Y_DIM) {photon->pos->y=-Y_DIM+0.01;wno=2;}
	if (photon->pos->y<-1*Y_DIM) {photon->pos->y=Y_DIM-0.01;wno=3;}

	i=0;
	if (wno>=0) {

	while ((WLIST[wno][i]>=0) && (NOSTANDS>0) && (res<=0)) {
		res=inside_stand(photon->pos,WLIST[wno][i]);
			i++;
		}
	}
	if (res>0) return WLIST[wno][i-1];
	else return -1;		
}


struct point *rand_norm_vec_samp(vec,facet_norm)
	struct point *vec, *facet_norm;

/*	Generates a random three dimensional vector, normalised so 
	magnitude of vector is 1. Samples in proportion to interception with facet
*/
{
	float x,y,theta,phi,r,flag,cosg;
	x=0;flag=0;
	while (flag==0)  {
		while (absfn(x)<.0005) x=2.0*rand()*RAND_MULT-1.0;
		y=rand()*RAND_MULT;

		theta=acos(x);
		phi=2*PI*y;
	
	/* Now rotate wrt facet_norm */
	/* printf("ft: %f fp: %f Old: th: %f ph: %f",facet_norm->theta,facet_norm->phi,theta,phi); */
		theta +=facet_norm->theta;
		phi +=facet_norm->phi;
		if (theta > PI) theta=2*PI-theta;
		if (phi > 2*PI) phi=phi-2*PI;
		/* printf("  New: th: %f ph: %f\n",theta,phi); */

		r=sin(theta);

		vec->x=r*cos(phi);
		vec->y=r*sin(phi);
		vec->z=x;


		cosg=absfn(dot(facet_norm,vec));
		r=rand()*RAND_MULT;
		if (r<cosg) flag=1;
	}

	vec->theta=theta;
	vec->phi=phi;
	return vec;


/*	x=2.0*rand()*RAND_MULT-1.0;
	if (x>=0.0) return (rand_norm_vec_up(vec)); else return (rand_norm_vec_down(vec));
*/

}

 struct point *rand_norm_vec_samp2(vec,facet_norm)
	struct point *vec, *facet_norm;

/*	Generates a random three dimensional vector, normalised so 
	magnitude of vector is 1. Each solid angle of a sphere will
	be uniformly sampled, oriented wrt facet_norm.
*/
{
	float x,y,theta,phi,r;
	x=0.0;
	while (absfn(x)<.0005) x=2.0*rand()*RAND_MULT-1.0;
	y=rand()*RAND_MULT;

	theta=acos(x);
	phi=2*PI*y;
	
	/* Now rotate wrt facet_norm */
	/* printf("ft: %f fp: %f Old: th: %f ph: %f",facet_norm->theta,facet_norm->phi,theta,phi); */
	theta +=facet_norm->theta;
	phi +=facet_norm->phi;
	if (theta > PI) theta=2*PI-theta;
	if (phi > 2*PI) phi=phi-2*PI;
	/* printf("  New: th: %f ph: %f\n",theta,phi); */

	r=sin(theta);

	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=x;
	vec->theta=theta;
	vec->phi=phi;

	return vec;


/*	x=2.0*rand()*RAND_MULT-1.0;
	if (x>=0.0) return (rand_norm_vec_up(vec)); else return (rand_norm_vec_down(vec));
*/

}


struct point *rand_norm_vec_up(vec)
	struct point *vec;

	/* Generates a random 3d vector in upwards direction */

{
	float x,y,theta,phi,r;

	y=rand()*RAND_MULT;
	x=rand()*RAND_MULT;
	if (x < .0005) x=.0005;
	theta=acos(x);


	phi=2.0*PI*y;
	r=sin(theta);
	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=x;	
	vec->theta=theta;
	vec->phi=phi;
	return vec;
}

struct point *rand_norm_vec_down_albedo(vec)
	struct point *vec;

	/* Generates a random 3d vector in downwards direction, but weighted to sample field of view of albedometer */

{
	float x,y,theta,phi,r;

	y=rand()*RAND_MULT;
	x=rand()*RAND_MULT*0.5;
	if (x < .0005)x=.0005; 

	/* theta=PI/2*(1+x); */

	theta=PI-asin(sqrt(2*x));

	phi=2.0*PI*y;
	r=sin(theta);
	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=cos(theta);	
	vec->theta=theta;
	vec->phi=phi;
	/* printf("%f %f %f %f %f\n",vec->theta,vec->phi,vec->x,vec->y,vec->z);*/
	return vec;



}

struct point *rand_norm_vec_down(vec)
	struct point *vec;

	/* Generates a random 3d vector in downwards direction */

{
	float x,y,theta,phi,r;

	y=rand()*RAND_MULT;
	x=rand()*RAND_MULT;
	if (x < .0005) x=.0005;
	theta=PI-acos(x);


	phi=2.0*PI*y;
	r=sin(theta);
	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=-1.0*x;	
	vec->theta=theta;
	vec->phi=phi;
	return vec;



}


struct point *rand_norm_vec(vec)
	struct point *vec;

/*	Generates a random three dimensional vector, normalised so 
	magnitude of vector is 1. Each solid angle of a sphere will
	be uniformly sampled.
*/
{
	float x,y,theta,phi,r;
	x=0.0;
	while (absfn(x)<.0005) x=2.0*rand()*RAND_MULT-1.0;
	y=rand()*RAND_MULT;

	theta=acos(x);
	phi=2*PI*y;
	r=sin(theta);

	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=x;
	vec->theta=theta;
	vec->phi=phi;

	return vec;


/*	x=2.0*rand()*RAND_MULT-1.0;
	if (x>=0.0) return (rand_norm_vec_up(vec)); else return (rand_norm_vec_down(vec));
*/

}



set_up_vec(vec)
	struct point *vec;
{
	float theta,phi,r;

	theta=degtorad(SOLAR_ZENITH);
	phi=degtorad(SOLAR_AZIMUTH);
	r=sin(theta);
	vec->x=r*cos(phi);
	vec->y=r*sin(phi);
	vec->z=cos(theta);
	vec->theta=theta;
	vec->phi=phi;
}


set_up_photon(photon)
	struct photon *photon;

/* 	Used in imaging mode to set ray direction in direction of illumination
	after a collision */

{
	float theta,phi,r;

	theta=degtorad(SOLAR_ZENITH);
	phi=degtorad(SOLAR_AZIMUTH);
	r=sin(theta);
	photon->vec->x=r*cos(phi);
	photon->vec->y=r*sin(phi);
	photon->vec->z=cos(theta);
	photon->vec->theta=theta;
	photon->vec->phi=phi;
}




int inside_triangle(p1,f) 
struct point *p1;
struct facet *f;

         
{                                           
  	float a,b,c,d0,d1,d2;                     
  	struct point *t1,*t2,*t3;
  	/* check if point p1 lies inside triangle with vertices t1,t2,t3
  	NB Assumes all points lie on same plane */   
   	t1=f->t1;t2=f->t2;t3=f->t3;
 
	if (f->fnormal->z !=0.0) {
 
  		a=t2->y-t1->y;                          
  		b=-(t2->x-t1->x);                       
  		c=-a*t1->x-b*t1->y;                     
  		d0=a*p1->x+b*p1->y+c;                   
                                            
  		a=t3->y-t2->y;                          
  		b=-(t3->x-t2->x);                       
  		c=-a*t2->x-b*t2->y;                     
  		d1=a*p1->x+b*p1->y+c;                   
                                            
  		a=t1->y-t3->y;                          
  		b=-(t1->x-t3->x);                       
  		c=-a*t3->x-b*t3->y;                     
  		d2=a*p1->x+b*p1->y+c;                   
	} else if (f->fnormal->y !=0.0){
  		a=t2->z-t1->z;                          
  		b=-(t2->x-t1->x);                       
  		c=-a*t1->x-b*t1->z;                     
  		d0=a*p1->x+b*p1->z+c;                   
                                            
  		a=t3->z-t2->z;                          
  		b=-(t3->x-t2->x);                       
  		c=-a*t2->x-b*t2->z;                     
  		d1=a*p1->x+b*p1->z+c;                   
                                            
  		a=t1->z-t3->z;                          
  		b=-(t1->x-t3->x);                       
  		c=-a*t3->x-b*t3->z;                     
  		d2=a*p1->x+b*p1->z+c;	
	
	}   else {
  		a=t2->z-t1->z;                          
  		b=-(t2->y-t1->y);                       
  		c=-a*t1->y-b*t1->z;                     
  		d0=a*p1->y+b*p1->z+c;                   
                                            
  		a=t3->z-t2->z;                          
  		b=-(t3->y-t2->y);                       
  		c=-a*t2->y-b*t2->z;                     
  		d1=a*p1->y+b*p1->z+c;                   
                                            
  		a=t1->z-t3->z;                          
  		b=-(t1->y-t3->y);                       
  		c=-a*t3->y-b*t3->z;                     
  		d2=a*p1->y+b*p1->z+c;	
	
	}
	
	                      
        if((d0*d1>0.0) &&  (d0*d2>0.0))  return 1; else return 0;
                                    
}


	
struct distandpoint *intersect(p,pv,pl,dp)
	struct point *p;struct point *pv;struct plane *pl;
	struct distandpoint *dp;

	/* Intersection of vector through p in  direction pv with plane pl. 
	Returns both intersection point dp->point and distance to
	intersection dp->r
	*/

{	float r,x1,y1,z1,u,v,w,a,b,c;
	x1=p->x;y1=p->y;z1=p->z;
	u=pv->x;v=pv->y;w=pv->z;
	a=pl->a;b=pl->b;c=pl->c;
	r=(1-(a*x1+b*y1+c*z1))/(u*a+v*b+c*w);
	if (r>0.000001) {
		(dp->point)->x=x1+r*u;
		(dp->point)->y=y1+r*v;
		(dp->point)->z=z1+r*w;
		dp->r=r; }
	else {
		dp->r=1.0E20; }
		
	return dp;
}

struct distandpoint *facet_intersect(p,pv,f,dp)
	struct point *p;struct point *pv;struct facet *f;
	struct distandpoint *dp;

	/* Intersection of vector through p in  direction pv with facet f. 
	Returns both intersection point dp->point and distance to
	intersection dp->r
	*/
{	
	dp=intersect(p,pv,f->fplane,dp);
	if (dp->r<1.0E10) {
		if (inside_triangle(dp->point,f)==0) dp->r=1.0E20;
	}
	return dp;
} 


float 	coneintersect_from_in(p,pv,cone,flag)
	struct point *p;struct point *pv;struct cone *cone;int flag;

/*	Finds nearest intersection of vector (p,pv) with cone (cone). Returns distance
	to the intersection point. 
	Assumes we are inside cone to begin with (hence there is always one positive and 
	one negative value for intersection of vector, and we want the positive one.)
*/

{
	float x1,y1,z1,xv,yv,zv,cx,cy,cz,tsq,newz1,h,nx,ny,rsq;
	float tmp1,tmp2,tmp3,a,b,c;
	x1=p->x;y1=p->y;z1=p->z;
	xv=pv->x;yv=pv->y;zv=pv->z;
	cx=cone->apex->x;cy=cone->apex->y;cz=cone->apex->z;
	h=cone->h;
	rsq=cone->radius_sq;

	tsq=cone->tansqphi;
	tmp1= ((cz-h)-z1)/zv;

/* 	If intersect base of cone then stop, as must be closest point */

	if (tmp1>0.001) {
		nx=x1+tmp1*xv-cx;
		ny=y1+tmp1*yv-cy;
		if ((nx*nx+ny*ny) < rsq) return tmp1;
	}

/*	Now solve quadratic for rest of cone. If imaginary solutions only
	then no intersection. If Single solution then ray "grazes" cone. 
	If two solutions then check if positive (ie in forward direction for
	ray, and return nearest intersection. NB unclear if ray lies
	 along cone surface.).*/

	a=xv*xv+yv*yv-zv*zv*tsq;	
	b=2*(xv*(x1-cx)+yv*(y1-cy)-zv*tsq*(z1-cz));
	tmp1=cx-x1;tmp2=cy-y1;tmp3=cz-z1;
	c=tmp1*tmp1+tmp2*tmp2-tsq*tmp3*tmp3;

	tmp1=b*b-4*a*c;


/* More defensive programming - tmp1 should always be >0 if inside cone. failing this, give a low value so path will exit crown. */

	if (tmp1<0.0) {
		return 0.001;}
	else {

		tmp2=sqrt(tmp1);
		tmp1=(-1*b+tmp2)/(2*a);
		tmp3=(-1*b-tmp2)/(2*a);

		newz1=z1+tmp1*zv;


		if (tmp1>0.0) return tmp1; else return 0.001;

	}		
		
}

float 	coneintersect_from_out(p,pv,cone,rminsofar)
	struct point *p;struct point *pv;struct cone *cone;float rminsofar;

/*	Finds nearest intersection of vector (p,pv) with cone (cone). Returns distance
	to the intersection point, or value 1.0E20 if vector does not intersect. 
*/
{
	float x1,y1,z1,xv,yv,zv,cx,cy,cz,tsq,newz1,newz2,h,nx,ny,rmin,rsq;
	float tmp1,tmp2,tmp3,a,b,c;
	x1=p->x;y1=p->y;z1=p->z;
	cx=cone->apex->x;cy=cone->apex->y;cz=cone->apex->z;

	rmin=1.0E20;
	tmp1=cone->sphere_radius+rminsofar;
	tmp2=(x1-cx)*(x1-cx)+(y1-cy)*(y1-cy)+(z1-cz)*(z1-cz);
	if (tmp2>(tmp1*tmp1)) return rmin;
	
	xv=pv->x;yv=pv->y;zv=pv->z;
	h=cone->h;
	tsq=cone->tansqphi;
	rsq=cone->radius_sq;

	tmp1= ((cz-h)-z1)/zv;
	if (tmp1>0.0) {
		nx=x1+tmp1*xv-cx;
		ny=y1+tmp1*yv-cy;
		if ((nx*nx+ny*ny) < rsq)  rmin=tmp1;
	}

	a=xv*xv+yv*yv-zv*zv*tsq;	
	b=2*(xv*(x1-cx)+yv*(y1-cy)-zv*tsq*(z1-cz));
	tmp1=cx-x1;tmp2=cy-y1;tmp3=cz-z1;
	c=tmp1*tmp1+tmp2*tmp2-tsq*tmp3*tmp3;

	tmp1=b*b-4*a*c;

	/* Check for "grazing" */
	if (tmp1 < 0.000001) return 1.0E20; 

	else {

		tmp2=sqrt(tmp1);
		
		tmp1=(-1*b+tmp2)/(2*a);
		tmp3=(-1*b-tmp2)/(2*a);
		newz1=z1+tmp1*zv;
		newz2=z1+tmp3*zv;

		if ( ((tmp3<0.0000) || (tmp1<tmp3)) && (newz1<=cz)
			&& (newz1>cz-h) 
			&& (tmp1<rmin) && (tmp1 > 0.0))
			return tmp1;
		else if ((newz2<=cz) && (newz2>cz-h) && (tmp3<rmin)
			&& (tmp3 > 0.0))
			return tmp3;
		else return rmin;
		
	}
}

float ellipse_intersect_from_out(p,pv,ellipse,rminsofar)
	struct point *p;struct point *pv;struct ellipse *ellipse;
	float rminsofar;

/*	Finds nearest intersection of vector (p,pv) withellipse (ellipse). Returns distance
	to the intersection point, or value 1.0E20 if vector does not intersect. 
	rminsofar is a threshold to allow exclusion of intersection points more distant
	than this value, as they will be occluded by another object
*/

{

	float x1,y1,z1,xv,yv,zv,cx,cy,cz,Ex,Ey,Ez,Exy,Eyz,Exz,Exyz,
		a,b,c,tmp1,s;	

	x1=p->x;y1=p->y;z1=p->z;
	xv=pv->x;yv=pv->y;zv=pv->z;
	cx=ellipse->centre->x;cy=ellipse->centre->y;cz=ellipse->centre->z;
	Ex=ellipse->Ex;Ey=ellipse->Ey;Ez=ellipse->Ez;


	Exy=Ex*Ex*Ey*Ey;
	Exz=Ex*Ex*Ez*Ez;
	Eyz=Ey*Ey*Ez*Ez;
	Exyz=Exy*Ez*Ez;


	a=Eyz*xv*xv+Exz*yv*yv+Exy*zv*zv;

	b= 2*( Eyz*(xv*(x1-cx))+Exz*(yv*(y1-cy))+Exy*(zv*(z1-cz)) );

	c=Eyz*(x1*x1+cx*cx-2*x1*cx)+Exz*(y1*y1+cy*cy-2*y1*cy)+
		Exy*(z1*z1+cz*cz-2*z1*cz)-Exyz;


	tmp1=b*b-4*a*c;

	if (tmp1<0.00001) s=1e20;
		else s=(-b-sqrt(tmp1))/(2.0*a);

	if ((s<0.00001) || (s>rminsofar)) s=1e20;

	return s;
}



float ellipse_intersect_from_in(p,pv,ellipse)
	struct point *p;struct point *pv;struct ellipse *ellipse;


/*	Finds nearest intersection of vector (p,pv) withellipse (ellipse). Assumes
	starting point p is inside the ellipse. */

{

	float x1,y1,z1,xv,yv,zv,cx,cy,cz,Ex,Ey,Ez,Exy,Eyz,Exz,Exyz,
		a,b,c,tmp1,s;	

	x1=p->x;y1=p->y;z1=p->z;
	xv=pv->x;yv=pv->y;zv=pv->z;
	cx=ellipse->centre->x;cy=ellipse->centre->y;cz=ellipse->centre->z;
	Ex=ellipse->Ex;Ey=ellipse->Ey;Ez=ellipse->Ez;


	Exy=Ex*Ex*Ey*Ey;
	Exz=Ex*Ex*Ez*Ez;
	Eyz=Ey*Ey*Ez*Ez;
	Exyz=Exy*Ez*Ez;


	a=Eyz*xv*xv+Exz*yv*yv+Exy*zv*zv;

	b= 2*( Eyz*(xv*(x1-cx))+Exz*(yv*(y1-cy))+Exy*(zv*(z1-cz)) );

	c=Eyz*(x1*x1+cx*cx-2*x1*cx)+Exz*(y1*y1+cy*cy-2*y1*cy)+
		Exy*(z1*z1+cz*cz-2*z1*cz)-Exyz;


	tmp1=b*b-4*a*c;

	if (tmp1<0.0) {
		/* should not happen, but does due to rounding errors! Setting s=0 means trajectory leaves canopy 
			a=sqrt( (cx-x1)*(cx-x1)+ (cy-y1)*(cy-y1)+(cz-z1)*(cz-z1));
				  printf("a: %f\n",a); */
 
	 	s=1e20;s=0.01;
	 }

	else {
		s=(-b+sqrt(tmp1))/(2.0*a);

		if (s<0.00001)  {
			/* should not happen, but does due to rounding errors!
				a=sqrt( (cx-x1)*(cx-x1)+ (cy-y1)*(cy-y1)+(cz-z1)*(cz-z1));
		  	printf("a: %f\n",a); */
			s=1e20; s=0.01;
		 }

	}
	return s;
}


int find_facet(pos,vec,current_st_no,dp)
	struct point *pos, *vec;
	int current_st_no;
	struct distandpoint *dp;
/*
	Searches for intersection from pos along direction vec over list of facets. If intersect a facet then returns facet number, otherwise -1. Also modifies dp to give position and distance to intersection */


{
	struct point *npos;
	float rmin;
	int stno,i;
	
	rmin=1E10;stno=-1;	
	if (FACET_FLAG) {
		npos=mkpoint(0,0,0);
		for (i=0;i<NOFACETS;i++) {
			if ((i+MAX_NOSTANDS) != current_st_no) {
				dp=facet_intersect(pos,vec,FACET[i],dp);
				if (dp->r < rmin) {
					rmin=dp->r;
					npos->x=(dp->point)->x;
					npos->y=(dp->point)->y;
					npos->z=(dp->point)->z;
					stno=i+MAX_NOSTANDS;
				}
			}
		}
		dp->point->x=npos->x;
		dp->point->y=npos->y;
		dp->point->z=npos->z;
		dp->r = rmin;
		free(npos);
	} 
	return stno;
}

trace(photon,npos,current_st_no)
	struct photon *photon;struct standpoint *npos;
	int current_st_no;

/*	Central ray tracing routine external to crowns. 
	Finds the nearest object of intersection (crown, trunk, ground plane, sky-plane
	or bounding wall) and returns its code in  npos->standno
	Intersection point with this object is returned in npos->point
*/


{	struct point *pos,*vec;
	int i,stno,ang_flag,tmp1;
	float rmin,low,high,az;
	float dist_to_bound;
	struct distandpoint *dp;
	
	 FILE *FPDEBUG; 

	 /* FPDEBUG=fopen("RESULTS/DEBUG","a"); 
	  fprintf(FPDEBUG,"trace:  pz: %f sno: %d\n",photon->pos->z,current_st_no); 

	fflush(FPDEBUG); */
	
	pos=photon->pos;
	vec=photon->vec;
	dp=dpalloc();
	dp->point=ptalloc();
	rmin=9999.0;
	TRUNKFLAG=0;
	stno=GROUND_PLANE_NUMBER; /* default if error */
	if ((vec->z<0.0) && (current_st_no != GROUND_PLANE_NUMBER)) {
		dp=intersect(pos,vec,GROUND_PLANE,dp);
		if (dp->r < rmin) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=GROUND_PLANE_NUMBER;
		 }
	}

	if (vec->x>0.0)  {
		dp=intersect(pos,vec,WALL1,dp);
		if (dp->r < rmin) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=WALL1_NUMBER; 
		}
	}

	else if (vec->x<0.0)  {
		dp=intersect(pos,vec,WALL2,dp);
		if (dp->r < rmin) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=WALL2_NUMBER;
		 }	
	}

	if (vec->y<0.0)  {
		dp=intersect(pos,vec,WALL3,dp);
		if (dp->r < rmin) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=WALL3_NUMBER;
		 }	
	}

	else if (vec->y>0.0) {
		dp=intersect(pos,vec,WALL4,dp);
		if (dp->r < rmin) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=WALL4_NUMBER;
		 }
	}

	if (vec->z>0.0) {
		dp=intersect(pos,vec,SKY_PLANE,dp);
		if ((dp->r < rmin) || (rmin > 2.0*(X_DIM+Y_DIM+Z_DIM)) ) {
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=SKY_PLANE_NUMBER; 
		}
	}

	if (FACET_FLAG) {
		tmp1=find_facet(pos,vec,current_st_no,dp);
		if ((tmp1>0) && (dp->r < rmin)){
			rmin=dp->r;
			(npos->point)->x=(dp->point)->x;
			(npos->point)->y=(dp->point)->y;
			(npos->point)->z=(dp->point)->z;
			stno=tmp1;
		}	
	}


	 
		for (i=0;i<NOSTANDS;i++) { 

			ang_flag=1;

			if ((current_st_no>=0) && (current_st_no < MAX_NOSTANDS)){

				if ((i==current_st_no))  ang_flag=-1;
				else {
					low=STANDS[current_st_no]->low[i];
					high=STANDS[current_st_no]->high[i];
					az=photon->vec->phi;
					if (low<high) {
						if ((az < low) || (az > high)) ang_flag=-1;
					} else  if ((az > high) && (az < low)) ang_flag=-1;
				}
			}


			if (ang_flag>0) {

				if (STANDS[i]->crown_shape=='c') 
				dist_to_bound=coneintersect_from_out(pos,vec,STANDS[i]->cone,rmin);
				else dist_to_bound=ellipse_intersect_from_out(pos,vec,STANDS[i]->ellipse,rmin);

				if (dist_to_bound < rmin) {
					stno=i;
					rmin=dist_to_bound;
					(npos->point)->x=pos->x+dist_to_bound*(vec->x);
					(npos->point)->y=pos->y+dist_to_bound*(vec->y);
					(npos->point)->z=pos->z+dist_to_bound*(vec->z);
					TRUNKFLAG=0;
				}

				if (TRUNK_PRES) {
					dist_to_bound=coneintersect_from_out(pos,vec,STANDS[i]->cone2,rmin);

					if (dist_to_bound < rmin) {
						stno=i;
						rmin=dist_to_bound;
						(npos->point)->x=pos->x+dist_to_bound*(vec->x);
						(npos->point)->y=pos->y+dist_to_bound*(vec->y);
						(npos->point)->z=pos->z+dist_to_bound*(vec->z);
						TRUNKFLAG=1;
					}
				}


			}
		}
	
	/* Useful debugging tool to follow photon path: printf(" %d ",stno); */
	npos->standno=stno;
	free(dp->point);
	free(dp);
	if ((npos->point->x < -X_DIM*1.02) || (npos->point->x > X_DIM*1.02) ||(npos->point->y < -1*Y_DIM*1.02) ||(npos->point->y > Y_DIM*1.02) ||(npos->point->z < 0.0) ||(npos->point->z > Z_DIM*1.02) ) {
	
	/* Defensive programming; if path has left bounding box, then terminate trajectory by releasing to sky plane */
	
	
	/* FPDEBUG=fopen("RESULTS/DEBUG","a");
	fprintf(FPDEBUG,"trace:  px: %f py; %f pz: %f vx: %f vy; %f vz: %f sno: %d xd: %4.1f yd: %4.1f zd; %4.1f\n",pos->x,pos->y,pos->z,vec->x,vec->y,vec->z,current_st_no,X_DIM,Y_DIM,Z_DIM);

	 fprintf(FPDEBUG,"trace:  npx: %f npy; %f npz: %f rmin: %f sno: %d\n",npos->point->x,npos->point->y,npos->point->z,rmin,npos->standno);
	fflush(FPDEBUG); 
	
	
	 fclose(FPDEBUG);
	 */
	 npos->standno=SKY_PLANE_NUMBER; 
	 
	  }	 
	 
}



float hot_spot_fn(phase_angle,dist_before_collision)
	float phase_angle,dist_before_collision;
{
	int pindex,dindex;
	float t1,t2,hs;

/*	Returns multiplier in range 0->1 to adjust extinction coeficient
	on first canopy colision to account for hot-spot effect.

	Calculation uses scattering phase angle, mean size of scatterers 
	and length of path to surface of canopy. The approach is an apoproximation
	and valid for the first order of scattering only.

	Method based on a look-up table derived according to the method of
	Jupp and Strahler 'A hotspot model for leaf canopies' (RSE 1991).

	NB JUPP & STRAHLER LEAF_SIZE REFERS TO DIAMETER HENCE THE FACTOR OF
	2.0*LEAF_SIZE

 */



	pindex=(int)(phase_angle*RDEG*5.0);
	dindex=(int)(dist_before_collision*0.5/(2.0*LF_SIZE));
	dindex=2.0*LF_SIZE/(0.005*dist_before_collision);
	if (dindex>799) dindex=799;
	if ((pindex<=600) && (dindex <= 799) && (pindex>=0) && (dindex >=0)) {
		
		t1=phase_angle*RDEG*5.0-(float)pindex; /* 0 to 60 degrees */
		t2=1.0-t1;
		if (pindex<300) hs=t2*hot_spot_array[pindex][dindex]+t1*hot_spot_array[pindex+1][dindex];
			else {/* Interpolate outside LUT where 90 deg = zero correlation */
				t1=(120.0-phase_angle*RDEG)/60.0;
				t2=1.0-t1;
				hs=t2+t1*hot_spot_array[299][dindex];
			}

		 /* printf("ph: %f d: %f pi: %d di: %d  t1: %f t2: %f hs: %f\n", phase_angle*RDEG,dist_before_collision,pindex,dindex,t1,t2,hs); */
		return hs;
	}
	
	else return (1.0); 
	
}

float gnd_phase_function(theta_s,theta_o,phi)
	float  theta_s,theta_o,phi;

/*	Approximates BRDF of a rough soil based on table look-up */

{
	float ind1,ind2,ind3,a1,a2,b1,b2,t1,t2;
	if (phi >PI) phi=2*PI-phi;
	phi=PI-phi;
	if (theta_s<0.0) theta_s=-1.0*theta_s;
	if (theta_o<0.0) theta_o=-1.0*theta_o;

	ind1=(theta_s*18.0/PI);

	ind2=(theta_o*18.0/PI);

	ind3=(int)(phi*18.0/PI);

	if ((ind1>=18.0) || (ind2>=18.0) || (ind3>=18.0)) return 0.0;
	else {

/* 		Do bi-linear interp on zenith angles, but not necessary on azimuth */

		a1=gnd_fn_array[(int)ind1][(int)ind2][(int)ind3]; 
		a2=gnd_fn_array[(int)ind1+1][(int)ind2][(int)ind3]; 
		b1=gnd_fn_array[(int)ind1][(int)ind2+1][(int)ind3]; 
		b2=gnd_fn_array[(int)ind1+1][(int)ind2+1][(int)ind3]; 
		t1=ind1-(int)ind1;
		t2=ind2-(int)ind2;
		return (1.0-t2)*(t1*a2+(1.0-t1)*a1)+t2*(t1*b2+(1.0-t1)*b1); 
	}
}

struct photon *ground_interact(photon)
	struct photon *photon;

/*	Simulates interaction of photon with ground. Absorption takes place
	depending on soil spectrum and rough-soil phase function. Scattering
	is simulated randomly in an upwards direction
*/

{
	float theta_in,phi_in,old_intensity,kfac;
	int i;
	theta_in=photon->vec->theta;
	phi_in=photon->vec->phi;
	photon->vec=rand_norm_vec_up(photon->vec); 
	photon->pos->z=0.005;	
	kfac=cos(photon->vec->theta)*2.0*
			(SOILROUGH*gnd_phase_function(PI-theta_in, photon->vec->theta, 
			absfn(photon->vec->phi-phi_in))+(1.0-SOILROUGH));

	for (i=0;i<NO_WVBANDS;i++) {
		old_intensity=photon->intensity[i];
			photon->intensity[i]=photon->intensity[i]*GROUND_REFLECTANCE[i]*kfac;
		ABS_SOIL[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
 	}
	COLLISION_NO++;
	return photon;
}


struct photon *trunk_interact(stand,photon)
	struct stand *stand;
	struct photon *photon;

/*	Simulates interaction of photon with trunk. */

{
	float xval,yval,xsq,ysq,zsq,tanphi,fac,old_intensity;
	int trunkflag,i;

	struct point *pos,*vec,*newvec;

	pos=photon->pos;
	vec=photon->vec;

		trunkflag=0;
		newvec=ptalloc();
		while (trunkflag==0) {
			newvec=rand_norm_vec(newvec);


			tanphi=tan(PI*0.5-atan(sqrt(stand->cone2->tansqphi)));

			xval=(pos->x-stand->cone2->apex->x);
			yval=(pos->y-stand->cone2->apex->y);
			xsq=xval*xval;
			ysq=yval*yval;
			zsq=(xsq+ysq)/(tanphi*tanphi);

	/* fac is cosine of angle between new direction and surface normal */

			fac=(xval*newvec->x+yval*newvec->y+sqrt(zsq)*newvec->z)
				/sqrt(xsq+ysq+zsq);
	/* Ensure new vector is facing away from trunk surface */
			if ((fac>0.01) && (fac<1.0)) trunkflag=1;
		
		}
		vec->x=newvec->x;
		vec->y=newvec->y;
		vec->z=newvec->z;
		vec->theta=newvec->theta;
		vec->phi=newvec->phi;
		 for (i=0;i<NO_WVBANDS;i++) {
			old_intensity=photon->intensity[i];
			photon->intensity[i]=photon->intensity[i] *BARK[i]*fac*2.0;
			ABS_CANOPY_BK[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
		}
		free(newvec);
	COLLISION_NO++;
	return photon;
}
	

float phase_function(wv_no,theta_s,theta_o,phi)
	float  theta_s,theta_o,phi;
	int wv_no;

/*	Calculates phase function of foliage from look-up table, based
	on incomming and outgoing direction vectors, and wavelength.
	Nearest-neighbour interpolation is used, which is fast but could lead
	to small error in case of rapidly changing phase function.
*/

{
	return
 	 phase_fn_array[wv_no][(int)(theta_s*18.0/PI+0.5)][(int)(theta_o *
			 18.0/PI+0.5)][(int)(phi*18.0/PI+0.5)];
}


struct point *prim_normal(stand,pos)
	struct stand *stand;
	struct point *pos;

/*	Calculates normal vector for a point on the boundary of crown. Used
	for imaging when crowns are approximated as opaque
 */

{
	struct point *nvec;
	float x,y,a,b,c,t;
	nvec=mkpoint(0.0,0.0,0.0);

	if (stand->crown_shape=='c') {
		x=pos->x-stand->cone->apex->x;
		y=pos->y-stand->cone->apex->y;
		t=sqrt(stand->cone->tansqphi);
			nvec->x=x/(t*sqrt(x*x+y*y));
			nvec->y=y/(t*sqrt(x*x+y*y));
			nvec->z=-1.0;
	}
	else {
		x=pos->x-stand->ellipse->centre->x;
		y=pos->y-stand->ellipse->centre->y;
		a=stand->ellipse->Ex;b=stand->ellipse->Ey;c=stand->ellipse->Ez;
		nvec->x=-1*(x*c/a)/sqrt( absfn(1.0-x*x/(a*a)-y*y/(b*b)));
		nvec->y=-1*(y*c/b)/sqrt(absfn(1.0-x*x/(a*a)-y*y/(b*b)));
		nvec->z=-1.0;
	}
	vnormalise(nvec);
	return(nvec);
}

 

float diffuse_est(wv)
	float wv;
{
/* Computes an approximation of frac. of diffuse radiation, given
	aerosol optical thickness, waveband (um) and solar zenith.

	k is approximate angstrom coeficient for continental aerosol
	dmeff gives effective diffuse fraction, by including light
		scattered close to solar direction with direct beam
	ryfrac and aerfrac give frac of rayleigh and aerosol scattered
		light to reach the ground surface
*/
	float dmeff,k,a,tau_rayleigh,tau_aero,tau_tot,ryfrac,aerfrac,dir,diff,diff_frac,pressure,p0;
	if (AER_OPT < 0) diff_frac=0.0;
	else {
		dmeff=0.55;
		ryfrac=0.5;aerfrac=0.75;
		k=-1.25;
		a=AER_OPT/pow(.55,k);
		pressure=1013.25;
		p0=1013.25;					tau_rayleigh=(pressure/p0)*(.008569*pow(wv,-4.0)*(1.0+.0113*pow(wv,-2.0)+.00013*pow(wv,-4.0))) /cos(degtorad(SOLAR_ZENITH));
		tau_aero=dmeff*a*pow(wv,k)/cos(degtorad(SOLAR_ZENITH));
		tau_tot=(tau_aero+tau_rayleigh);
		dir=exp(-1.0*tau_tot);
		diff=ryfrac*(1.0-exp(-1.0*tau_rayleigh))+aerfrac*(1.0-exp(-1.0*tau_aero));
		diff_frac=(diff/(dir+diff));
	}

	return diff_frac;
}
	
		

lambertian_interact(stand,photon)
	struct stand *stand;
	struct photon *photon;

/*	Calculates Lambertian reflectance of point on crown based on solid object
	approximation (MODE='s')
*/

{
	int i;
	float fac;
	struct point *normal_vec;

	normal_vec=prim_normal(stand,photon->pos);
	fac=dot(photon->vec,normal_vec);
	free(normal_vec);

	for (i=0;i<NO_WVBANDS;i++) photon->intensity[i]=photon->intensity[i]*absfn(fac);

}


foliage_interact(vec,newvec,photon)
	struct point *vec,*newvec;
	struct photon *photon;

{
	float a1,a2,prob,ph,old_intensity;
	int ind1,ind2,ind3,i;

/* 	Assuming uniform mix of components based on total fractions present. Following line may be
	changed to calculate varying components depending on position within crown: */

	a1=1.0-FRAC_SEN-FRAC_BARK;a2=1.0-FRAC_BARK;	
	prob=rand()*RAND_MULT;
				
/*	Calculate phase function from look-up table. Currently uses nearest neighbour interpolation for
	speed; should change for sharply varying phase function, eg when including specular reflection.
*/
	ind1=(int)(vec->theta*18.0/PI+0.5);
	ind2=(int)(newvec->theta*18.0/PI+0.5);
	ind3=(int)(absfn(vec->phi - newvec->phi)*18.0/PI+0.5);


	for (i=0;i<NO_WVBANDS;i++) {

		if (prob<a1) {
			ph=phase_fn_array[i][ind1][ind2][ind3];

 			if ((MODE == 'i') && (COMPNO <0)) COMPNO=2; else COMPNO++;

		}

		else if (prob<a2) {
			ph=sen_phase_fn_array[i][ind1][ind2][ind3];
			if ((MODE == 'i') && (COMPNO <0)) COMPNO=4; else COMPNO++;
		}

 	 	else {
			ph=bk_phase_fn_array[i][ind1][ind2][ind3];
 			if ((MODE == 'i') && (COMPNO <0)) COMPNO=6; else COMPNO++;
		}
						
		old_intensity=photon->intensity[i];
		photon->intensity[i]=photon->intensity[i]*ph;

		if (prob<=a1)
			ABS_CANOPY_GR[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
		else if (prob<=a2)
			ABS_CANOPY_SEN[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
		else 
			ABS_CANOPY_BK[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
				
 	}
}



struct photon *oned_interact(stand,photon)

	struct stand *stand;
	struct photon *photon;

/*	Simulates photon trajectory in a 1 dimensional representation (eg SAIL). Calculates
	scattering and absorption for successive interactions until photon escapes from
	canopy or exceeds maximum number of scattering events.
	For imaging mode, records code of component (COMPNO) interacted with on first collision.
*/


{
	struct point *pos,*vec,*newvec;
	float prob,tau_val,dist_before_collision,pos_z;
	float ray_zenith_angle;
	float dist_to_bound,tau_multiplier,phase_angle,dist_to_bound2;
	int outflag,index,bounce_no,i;


	bounce_no=0;
	tau_multiplier=1.0;

	pos=photon->pos;
	vec=photon->vec;
	outflag=0;

	while ( ((MODE == 'f') && (outflag==0)) || (((MODE=='s') || (MODE=='i')) && (outflag==0) && (COMPNO!=1) &&
		 (COMPNO !=3) && (COMPNO !=5) && (COMPNO!=7))) {		
		if (bounce_no > BOUNCE_THRESHOLD) {
			outflag=1;
			NIR_LEAKAGE+=photon->intensity[NIR];
			for (i=0;i<NO_WVBANDS;i++) {
				LEAKAGE[i]+=photon->intensity[i];
				photon->intensity[i]=0.0;
			}
		}


/*		Distance to soil boundary 		*/

		if (vec->z<0.0) {
	 
			dist_to_bound2=-1.0*pos->z/vec->z ;
		}
		else dist_to_bound2=1e6;

/*		Distance to top of canopy  boundary 		*/

		dist_to_bound=(TOP_ONED-pos->z)/vec->z;


		if ((bounce_no==1) && (LF_SIZE>0.0) && (dist_to_bound>0.0)){
			tau_multiplier=hot_spot_fn(phase_angle,dist_to_bound*cos(phase_angle));
			if (tau_multiplier<0.0001) tau_multiplier=0.0001;
		}

		else tau_multiplier=1.0;


/*		Calculate sample photon path length through medium */
		ray_zenith_angle=vec->theta*RDEG;
		if (ray_zenith_angle > 90.0) ray_zenith_angle=(180.0-ray_zenith_angle);
		index=(int)(ray_zenith_angle); 
		tau_val=tau_multiplier*(stand->lai)*EXTINCTION_COEF_ARRAY[index];
	
		prob=rand()*RAND_MULT;
		if (prob <= 0.0) prob=0.0001;
		dist_before_collision=-(log(prob)/tau_val);

/*		Now find out if reach boundary	*/

		if ((dist_to_bound < dist_before_collision) && (dist_to_bound >0.0)) {
			outflag=1;
			pos_z=pos->z+(dist_to_bound)*(vec->z);
		}

		else if (dist_to_bound2 < dist_before_collision) {
			pos->z=0.001;
			newvec=ptalloc();	

			if (MODE == 'f') {

				newvec->x=vec->x;
				newvec->y=vec->y;
				newvec->z=vec->z;
				photon=ground_interact(photon);
				if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(newvec,vec));

			}
			else {
				COMPNO=0;
				set_up_vec(newvec);
				if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(vec,newvec));
				vec->x=newvec->x;
				vec->y=newvec->y;
				vec->z=newvec->z;
				vec->theta=newvec->theta;
				vec->phi=newvec->phi;
				COLLISION_NO++;
			}
			free(newvec);
			bounce_no++;
		}
	
		else if (outflag==0) {

		
			pos->z=pos->z+dist_before_collision*vec->z;
			

			newvec=ptalloc();
			if (MODE=='f') newvec=rand_norm_vec(newvec);
			else set_up_vec(newvec);
			foliage_interact(vec,newvec,photon);

			if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(vec,newvec));
		 				
			vec->x=newvec->x;
			vec->y=newvec->y;

			vec->z=newvec->z;
			vec->theta=newvec->theta;
			vec->phi=newvec->phi;

			free(newvec);
			bounce_no++;
			COLLISION_NO++;
		}
	}
	pos->z=pos_z;
	return photon;
}




struct photon *stand_interact(stand,photon)
	struct stand *stand;
	struct photon *photon;

/*	Simulates photon trajectory within a cown boundary, using a turbid medium
	approximation. Calculates scattering and absorption for successive interactions
	until photon escapes from crown or exceeds maximum number of scattering events.

	If a trunk is present within crown, scattering may occur with this.

	For imaging mode, records code of component (COMPNO) interacted with on first collision.
*/



{
	struct point *pos,*vec,*newvec;
	struct distandpoint *dp;
	float prob,tau_val,dist_before_collision,pos_x,pos_y,
		pos_z,ph,old_intensity;
	float ray_zenith_angle;
	float dist_to_bound,tau_multiplier,phase_angle,fac,dist_to_bound2,dist_to_ground;
	float xval,yval,xsq,ysq,zsq,tanphi,a1,a2;
	float cx,cy,cz,tsq,dist_from_apex_sq,max_dist_sq,kx,ky,kz;
	int outflag,index,flag,bounce_no,trunkflag,i,ind1,ind2,ind3;

	if (stand->crown_shape=='c') {

		cx=stand->cone->apex->x;cy=stand->cone->apex->y;cz=stand->cone->apex->z;
		tsq=stand->cone->tansqphi;
	}
	else {
		cx=stand->ellipse->centre->x;cy=stand->ellipse->centre->y;cz=stand->ellipse->centre->z;
	}


	dp=dpalloc();
	dp->point=ptalloc();
	flag=1;
	bounce_no=0;
	tau_multiplier=1.0;
	dist_to_bound2=1e20;
	pos=photon->pos;
	vec=photon->vec;
	outflag=0;


	while ( ((MODE == 'f') && (outflag==0)) || (((MODE=='s') || (MODE=='i')) &&
		 (outflag==0) && (COMPNO!=1) && (COMPNO !=3) && (COMPNO !=5) && (COMPNO!=7))) {
		if (COLLISION_NO > BOUNCE_THRESHOLD) {
			outflag=1;
			NIR_LEAKAGE+=photon->intensity[NIR];
			for (i=0;i<NO_WVBANDS;i++) {
				LEAKAGE[i]+=photon->intensity[i];
				photon->intensity[i]=0.0;
			}
		}


		if (stand->crown_shape=='c') 
			dist_to_bound=coneintersect_from_in(pos,vec,stand->cone,flag) ;
			else dist_to_bound=ellipse_intersect_from_in(pos,vec,stand->ellipse);

 		flag=0;
		if (TRUNKFLAG==1) dist_to_bound2=coneintersect_from_out(pos,vec,stand->cone2,dist_to_bound); else dist_to_bound2=1e20;

		dp=intersect(pos,vec,GROUND_PLANE,dp);
		dist_to_ground=dp->r;

		if ((bounce_no==1) && (LF_SIZE>0.0) && (dist_to_bound>0.0)){
			tau_multiplier=hot_spot_fn(phase_angle,dist_to_bound*cos(phase_angle));
			if (tau_multiplier<0.0001) tau_multiplier=0.0001;
		}

		else tau_multiplier=1.0;

		ray_zenith_angle=vec->theta*RDEG;
		if (ray_zenith_angle > 90.0) ray_zenith_angle=(180.0-ray_zenith_angle);
		index=(int)(ray_zenith_angle); 
		tau_val=tau_multiplier*(stand->lai)*EXTINCTION_COEF_ARRAY[index];
		prob=rand()*RAND_MULT;
		if (prob <= 0.0) prob=0.0001;
		dist_before_collision=-(log(prob)/tau_val);


		if ((TRUNKFLAG==1) && (dist_to_bound2 < dist_before_collision) && (dist_to_bound2 < dist_to_ground)) {
			pos->x=pos->x+(dist_to_bound2)*(vec->x)*0.95;
			pos->y=pos->y+(dist_to_bound2)*(vec->y)*0.95;
			pos->z=pos->z+(dist_to_bound2)*(vec->z)*0.95;
			trunkflag=1;
			newvec=ptalloc();

			while (trunkflag==0) {
				newvec=rand_norm_vec(newvec);

				tanphi=tan(PI*0.5-atan(sqrt(stand->cone2->tansqphi)));

				xval=(pos->x-stand->cone2->apex->x);
				yval=(pos->y-stand->cone2->apex->y);
				xsq=xval*xval;
				ysq=yval*yval;
				zsq=(xsq+ysq)/(tanphi*tanphi);


				fac=(xval*newvec->x+yval*newvec->y+sqrt(zsq)*newvec->z)
					/sqrt(xsq+ysq+zsq);
				if ((fac<1.0) && (fac>0.01)) trunkflag=1;
			}

			vec->x=newvec->x;
			vec->y=newvec->y;
			vec->z=newvec->z;
			vec->theta=newvec->theta;
			vec->phi=newvec->phi;

			if (MODE == 'f') {		
				for (i=0;i<NO_WVBANDS;i++) {
					old_intensity=photon->intensity[i];
					photon->intensity[i]=photon->intensity[i]*BARK[i]*fac*2.0;
					ABS_CANOPY_BK[i][DIFF_SKY_FLAG]+=old_intensity-photon->intensity[i];
				}
			}

 			if  (COMPNO >=0)  COMPNO++; else if (MODE == 'i') COMPNO=6; else COMPNO=2;

			COLLISION_NO++;
			free(newvec);
			bounce_no++;

		}
	
		else if ((dist_before_collision > dist_to_ground) && (dist_to_bound > dist_to_ground)) {
			/* canopy envelope has ground as lower boundary */
			pos->x=(dp->point)->x;
			pos->y=(dp->point)->y;
			pos->z=(dp->point)->z;
			newvec=ptalloc();	

			if (MODE == 'f') {
				newvec->x=vec->x;
				newvec->y=vec->y;
				newvec->z=vec->z;
				photon=ground_interact(photon);
				if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(vec,newvec));
			}
			else {
				COMPNO=0;
				set_up_vec(newvec);	
				COLLISION_NO++;
				if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(vec,newvec));
				newvec->x=vec->x;
				newvec->y=vec->y;
				newvec->z=vec->z;
			}
			free(newvec);
			bounce_no++;
		}

		else {
			if ((dist_to_bound < dist_before_collision) ) {
				outflag=1;
				pos_x=pos->x+(dist_to_bound)*(vec->x)*1.01;
				pos_y=pos->y+(dist_to_bound)*(vec->y)*1.01;
				pos_z=pos->z+(dist_to_bound)*(vec->z)*1.01;
			}
	
	
			if ((outflag==0) && (dist_before_collision < dist_to_ground)) {

		
				pos->x=pos->x+dist_before_collision*vec->x;
				pos->y=pos->y+dist_before_collision*vec->y;
				pos->z=pos->z+dist_before_collision*vec->z;

				newvec=ptalloc();

				if (MODE == 'f') newvec=rand_norm_vec(newvec);
				else {
					set_up_vec(newvec);
				}


				foliage_interact(vec,newvec,photon);


				if ((bounce_no==0) && (LF_SIZE>0.0)) phase_angle=PI-acos(dot(vec,newvec));
		
				vec->x=newvec->x;
				vec->y=newvec->y;
				vec->z=newvec->z;
				vec->theta=newvec->theta;
				vec->phi=newvec->phi;

				free(newvec);
				bounce_no++;
				COLLISION_NO++;
			}
		}
	}

	pos->x=pos_x;
	pos->y=pos_y;
	pos->z=pos_z;
	free(dp->point);
	free(dp);
	return photon;
}

int circ_intersect(i,j,leeway)
	int i,j;
	float leeway;
{

	/* Checks if two ellipses/cones overlap: Nb only applies to ellipses if Ex=Ey 
		(ie Ellipse has circular horizontal cross-section)
		leeway is fractional threshold of tolerence for overlapping crowns
	*/

	struct cone *cone1,*cone2;
	struct ellipse *ellipse1,*ellipse2;
	float cx1,cx2,cy1,cy2,rsq1,rsq2,dist_sq,dist_rad;

	if (STANDS[i]->crown_shape=='c') {

		cone1=STANDS[i]->cone;
		cx1=cone1->apex->x;cy1=cone1->apex->y;
		rsq1=cone1->radius_sq;
	}
	else {
		ellipse1=STANDS[i]->ellipse;

		cx1=ellipse1->centre->x;cy1=ellipse1->centre->y;
		rsq1=ellipse1->Ex*ellipse1->Ex;
	}
		if (STANDS[j]->crown_shape=='c') {

		cone2=STANDS[j]->cone;
		cx2=cone2->apex->x;cy2=cone2->apex->y;
		rsq2=cone2->radius_sq;
	}
	else {

		ellipse2=STANDS[j]->ellipse;
		cx2=ellipse2->centre->x;cy2=ellipse2->centre->y;
		rsq2=ellipse2->Ex*ellipse2->Ex;
	}
	
	dist_sq=(cx1-cx2)*(cx1-cx2)+(cy1-cy2)*(cy1-cy2);
	dist_rad=rsq1+rsq2;
	if (dist_sq*leeway<= dist_rad*dist_rad) return 1;
	else return 0;

}

mk_low_high()


/* 	Computes angular range from which each crown is visible
	from each other. Used to speed run-time calculation
*/

{
	int i,j;
	float r1,r2,x1,x2,y1,y2,k,base,inc;
	for (i=0;i<NOSTANDS;i++) {
		for (j=i+1;j<NOSTANDS;j++) {
		if (circ_intersect(i,j,0.96) > 0) {
			STANDS[i]->low[j]=0.0;
			STANDS[i]->high[j]=2*PI;
			STANDS[j]->low[i]=0.0;
			STANDS[j]->high[i]=2*PI;
		}
	else {

	if (STANDS[i]->crown_shape=='c') {
		r1=sqrt(STANDS[i]->cone->radius_sq);
		x1=STANDS[i]->cone->apex->x;
		y1=STANDS[i]->cone->apex->y;
	}
	else {
		if (STANDS[i]->ellipse->Ex >STANDS[i]->ellipse->Ey) r1=STANDS[i]->ellipse->Ex;
			else  r1=STANDS[i]->ellipse->Ey;
		x1=STANDS[i]->ellipse->centre->x;
		y1=STANDS[i]->ellipse->centre->y;
	}


	if (STANDS[j]->crown_shape=='c') {
		r2=sqrt(STANDS[j]->cone->radius_sq);
		x2=STANDS[j]->cone->apex->x;
		y2=STANDS[j]->cone->apex->y;
	}

	else {
		if (STANDS[j]->ellipse->Ex >STANDS[j]->ellipse->Ey) r2=STANDS[j]->ellipse->Ex;
			else  r2=STANDS[j]->ellipse->Ey;
		x2=STANDS[j]->ellipse->centre->x;
		y2=STANDS[j]->ellipse->centre->y;
	}


		base=atan((y2-y1)/(x2-x1));
		if  (x2<x1) {
			if (base <0.0) base=base+PI; 
			else base=base-PI;
		}

		k=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
		inc=asin((r1+r2)/k);
		STANDS[i]->low[j]=base-inc-0.005;
		STANDS[i]->high[j]=base+inc+0.005;
		STANDS[j]->low[i]=PI+STANDS[i]->low[j];
		STANDS[j]->high[i]=PI+STANDS[i]->high[j];
		if (STANDS[j]->high[i]>2*PI) 
			STANDS[j]->high[i]=STANDS[j]->high[i]-2*PI;
	if (STANDS[j]->low[i]<0.0) 
			STANDS[j]->low[i]=STANDS[j]->low[i]+2*PI;

		if ((base-inc) < 0.0) {
			STANDS[i]->low[j]=PI*2+(base-inc);
			STANDS[i]->high[j]=PI*2+(base+inc);
			if (STANDS[i]->high[j]>2*PI) 
			STANDS[i]->high[j]=STANDS[i]->high[j]-2*PI;
		}
	}



		}
	}
}




	
int inside(photon,stand_number)
	struct photon *photon;
	int stand_number;

/* As crowns may overlap, this routine checks whether a photon within the boundary
	of a crown given by 'stand_number', is also within the boundary of another crown.
	If so, then return the number of this crown, otherwise return -1. Uses pre-compiled
	list of all stands which overlap with each crown.
*/

{
	int i=0,res=0;
	while ((res<=0) && (STANDS[stand_number]->list[i]>=0))  {
		res=inside_stand(photon->pos,STANDS[stand_number]->list[i]);
		i++;
	}
		if (res>0) return STANDS[stand_number]->list[i-1];
		else return -1;
}





mk_intersect_lists()

/* Compiles list of crowns which overlap each other. */


{
	int icnt[MAX_NOSTANDS];
	int i,j;
	for (i=0;i<NOSTANDS;i++) {
		icnt[i]=0;
		for (j=0;j<NOSTANDS;j++) {
			STANDS[i]->list[j]=-1;
		}
	}

	for (i=0;i<NOSTANDS;i++) {

		for (j=i+1;j<NOSTANDS;j++) {
			if (circ_intersect(i,j,0.96)) {
				STANDS[i]->list[icnt[i]]=j;
				STANDS[j]->list[icnt[j]]=i;
				icnt[i]++;icnt[j]++;
			}
		}
	}

}



intersect_facets_crowns(no_crowns)
	int no_crowns;
	/* Checks if any facets intersect crowns or trunks */
	
{
	struct point *pos, *vec;
	struct distandpoint *dp;
	int flag,i,j;

	pos=mkpoint(0,0,0);vec=mkpoint(0,0,-1.0);    /* MW: vec = vector pointing straight down (pos will be set to top of trunk)   */ 
	dp=dpalloc();
	dp->point=ptalloc();
	flag=0;
	for (i=0;i<no_crowns;i++) {
		for (j=0;j<NOFACETS;j++) {
			vec->x=0.0;vec->y=0.0;vec->z=-1.0;
			/* Check intersect with trunk */
			/* Check ctre of trunk */
			if (TRUNK_PRES==1) {
			        pos->x=STANDS[i]->cone2->apex->x;   /* MW: set 'pos' position equal to top of trunk (x,y and z)  */
				pos->y=STANDS[i]->cone2->apex->y;
				pos->z=STANDS[i]->cone2->apex->z;
				dp=facet_intersect(pos,vec,FACET[j],dp);  /* MW: check for intersection  */

				if (dp->r < pos->z) {
					flag=1;
					/*  printf("px: %f py; %f pz: %f vx: %f vy: %f vz: %f\n  fx1: %f fy1: %f fz1: %f fx2: %f fy2: %f fz2: %f fx3: %f fy3: %f fz3: %f\n",pos->x,pos->y,pos->z,vec->x,vec->y,vec->z,FACET[j]->t1->x,FACET[j]->t1->y,FACET[j]->t1->z,FACET[j]->t2->x,FACET[j]->t2->y,FACET[j]->t2->z,FACET[j]->t3->x,FACET[j]->t3->y,FACET[j]->t3->z); 
				printf("i: %d j: %d r: %f \n",i,j,dp->r); */
				
				}
			}
		
		
		/* Check intersect with crown */
		
		
		}
	}

	return flag;
}	
	
	

mk_wall_lists()

/*	Compiles list of crowns which overlap bounding wall planes */

{
	int ind1,ind2,ind3,ind4,i;
	float cx,cy,r;

	for (i=0;i<NOSTANDS;i++) {
		WLIST[0][i]=-1;
		WLIST[1][i]=-1;
		WLIST[2][i]=-1;
		WLIST[3][i]=-1;
	}

	ind1=0;ind2=0;ind3=0;ind4=0;


	for (i=0;i<NOSTANDS;i++) {

		if (STANDS[i]->crown_shape=='c') {

			cx=STANDS[i]->cone->apex->x;cy=STANDS[i]->cone->apex->y;
			r=sqrt(STANDS[i]->cone->radius_sq);
		}
		else {
			cx=STANDS[i]->ellipse->centre->x;cy=STANDS[i]->ellipse->centre->y;
			if (STANDS[i]->ellipse->Ex >STANDS[i]->ellipse->Ey) r=STANDS[i]->ellipse->Ex;
				else  r=STANDS[i]->ellipse->Ey;
		}
		
		if ((cx+r) >= X_DIM ) {WLIST[0][ind1]=i;ind1++;}
		if ((cx-r) <= -1*X_DIM ) {WLIST[1][ind2]=i;ind2++;}
		if ((cy-r) <= -1*Y_DIM ) {WLIST[2][ind3]=i;ind3++;}
		if ((cy+r) >= Y_DIM ) {WLIST[3][ind4]=i;ind4++;}
	}
}

		




struct photon *sim(photon)
	struct photon *photon;

/*	Main routine to control 3D simulation. Calls 'trace' to find object of
	intersection in photon path, then calls appropriate routine to deal
	with that interaction. 
	Code is complicated to deal with different modes of operation, to include checks
	 on stray photons, check rounding errors and deal with case of overlapping crowns.
*/

{
	
	int outflag,stand_number=SKY_PLANE_NUMBER,new_stand,wno=-1,i,
		old_stand=SKY_PLANE_NUMBER,inflag=0;
	float dist_to_bound;
	struct standpoint *first_interaction;
	outflag=0;
	first_interaction=mkstandpoint(0,mkpoint(0.0,0.0,0.0));
	while (((MODE=='f') && (outflag==0) && (photon->pos->z >0.0) && (photon->pos->z < CANOPY_TOP_OUT) && (photon->intensity[NIR]>0.00001)) 
		|| (((MODE=='i') || (MODE=='s')) && (outflag==0) && (COMPNO!=1) && (COMPNO !=3) && (COMPNO !=5) && (COMPNO!=7) &&
			 (photon->pos->z >0.0) && (photon->pos->z < CANOPY_TOP_OUT)) ) {


		if (COLLISION_NO > BOUNCE_THRESHOLD) {
			outflag=1;
			NIR_LEAKAGE+=photon->intensity[NIR];
			for (i=0;i<NO_WVBANDS;i++) {
				LEAKAGE[i]+=photon->intensity[i];
				photon->intensity[i]=0.0;
			}
		}

		inflag=0;
		if (wno>=0) {
			i=0;
			
			while ((inflag==0) && (NOSTANDS>0) && (WLIST[wno][i]>=0) ) {
				if (inside_stand(photon->pos,WLIST[wno][i])>0)
				{
					stand_number=WLIST[wno][i];
					inflag=1;
				}
				i++;
			}
		}

		if (inflag==0) {
			trace(photon,first_interaction,old_stand);
			stand_number=first_interaction->standno;
		


			photon->pos->x=first_interaction->point->x;
			photon->pos->y=first_interaction->point->y;
			photon->pos->z=first_interaction->point->z; 
		}


		old_stand=stand_number;

		wno=-1;
		switch(stand_number) {

		case SKY_PLANE_NUMBER: 	outflag=1;
					break;
		case GROUND_PLANE_NUMBER: 

			if (MODE=='f') photon=ground_interact(photon);
			else {
				COMPNO=0;
				set_up_photon(photon);
				COLLISION_NO++;
				photon->pos->z=0.02;	

			}
			break;
		case WALL1_NUMBER: (photon->pos)->x=-1*X_DIM+0.0001;wno=1;
		/* printf("%f %f %f %f %f %f\n",photon->pos->x,photon->pos->y,photon->pos->z,photon->vec->x,photon->vec->y,photon->vec->z); */
			break;
		case WALL2_NUMBER: (photon->pos)->x=X_DIM-0.0001;wno=0;
			break;
		case WALL3_NUMBER: (photon->pos)->y=Y_DIM-0.0001;wno=3; 
		 	break;
		case WALL4_NUMBER: (photon->pos)->y=-1*Y_DIM+0.0001;wno=2;
		 	break;
		default: {

			if (TRUNKFLAG==1) {
				new_stand=stand_number;
				if (MODE=='f') photon=trunk_interact(STANDS[new_stand],photon);
				else {
 					if  (COMPNO <0) COMPNO=2; else COMPNO++;
					set_up_photon(photon);
					COLLISION_NO++;
				}

				TRUNKFLAG=0;
				break;		
			}
			else {
				new_stand=stand_number;
				while ((new_stand >=0) 
				 	&& (photon->intensity[NIR]>0.00001)) {
  

					if (MODE=='s') { 
						COLLISION_NO++;
						if (COMPNO <0) COMPNO=2; else COMPNO++;
						set_up_photon(photon);	
						lambertian_interact(STANDS[new_stand],photon);

						if (STANDS[new_stand]->crown_shape=='c') 
							{
								dist_to_bound=coneintersect_from_in(photon->pos,photon->vec,STANDS[new_stand]->cone,1);
							}
							else dist_to_bound=ellipse_intersect_from_in(photon->pos,photon->vec,
								STANDS[new_stand]->ellipse);

						if ((dist_to_bound<1e5) && (dist_to_bound>0.001)) {
							COLLISION_NO++;
							if (COMPNO==2) COMPNO++;
						}

						new_stand=-1;
						break;		

					}
					else {


						old_stand=new_stand;
						photon=stand_interact(STANDS[new_stand],photon);


						new_stand=replace_if_out(photon);
						if (new_stand<0) new_stand=inside(photon,stand_number);
						if (new_stand==old_stand) break;
					}
				}
			}
		}
			
		}
	}
	free(first_interaction->point);
	free(first_interaction);

	/* Some defensive programming */
	if ((photon->pos->z <0.0) || (photon->pos->z > Z_DIM+10.0)) {
		outflag=1;
		NIR_LEAKAGE+=photon->intensity[NIR];
			for (i=0;i<NO_WVBANDS;i++) {
				LEAKAGE[i]+=photon->intensity[i];
				photon->intensity[i]=0.0;
			}
	}

	return photon;
}


float betafn(theta,theta_l)
	float theta,theta_l;

/*	Sub-function in phase function calculation */
	

{	float beta;
	beta=acos(-1/(tan(theta)*tan(theta_l)));
	return beta;
}

float kfn(theta_l,theta_s)
	float theta_l,theta_s;

/*	Sub-function in extinction coeficient calculation */

{	float kvalue,beta;
	if ((theta_s+theta_l)<(PI/2)) beta = PI;
		else beta=betafn(theta_s,theta_l);
	kvalue=2/PI * ( (beta-PI/2)*cos(theta_l) +
	sin(beta)*tan(theta_s)*sin(theta_l) );
	return kvalue;
}

mk_extinction_coef_array()

/*	Pre-compile table of extinction coeficients for each 
	angle of travel within medium. Uses angular distribution
	only - multiply by foliage density to get actual ext. coef. 
*/

{	float k;
	int i;
	int theta_s;
	for (theta_s=0;theta_s<=90;theta_s++) {
	k=0.0;
	for (i=1;i<10;i++) k=k+LAD[i]*
	 		cos(degtorad((float)theta_s))* 
 			kfn(degtorad(ANGLES[i]),degtorad((float)theta_s));
	EXTINCTION_COEF_ARRAY[theta_s]=k;	};
}




leaf_reflectance_fn(in_photon_vec,out_photon_vec,leaf_normal_vec,RHO_AR,TAU_AR,OUT_AR)

/*	Calculates bi-lambertian phase function for an individual leaf, across
	entire spectrum
*/


	struct point *in_photon_vec,*out_photon_vec,*leaf_normal_vec;
	float RHO_AR[MAX_NO_WVBANDS],TAU_AR[MAX_NO_WVBANDS],OUT_AR[MAX_NO_WVBANDS];
{	
	float in_dot_leaf,out_dot_leaf,k1;
	int i;

	in_dot_leaf=dot(in_photon_vec,leaf_normal_vec);
	out_dot_leaf=dot(out_photon_vec,leaf_normal_vec);


	k1=absfn(out_dot_leaf)/PI;
	if ((in_dot_leaf*out_dot_leaf) <= 0) for (i=0;i<NO_WVBANDS;i++) OUT_AR[i]= RHO_AR[i]*k1;
	else for (i=0;i<NO_WVBANDS;i++) OUT_AR[i]= TAU_AR[i]*k1;
}



phase_fn_evaluate(theta_s,theta_o,phi,RHO_AR,TAU_AR,OUT_AR)
	float theta_s,theta_o,phi;
	float RHO_AR[MAX_NO_WVBANDS],TAU_AR[MAX_NO_WVBANDS],OUT_AR[MAX_NO_WVBANDS];

/*	Calculates bi-lambertian phase function for foliage, across
	entire spectrum, for given incomming and outgoing directions,
	based on reflectance & transmittance characteristics,
	and leaf angle distribution.
*/


{
	struct point *in_photon_vec, *out_photon_vec, *leaf_normal_vec;
	float leaf_normal_zenith,leaf_normal_azimuth,lnz,lna;
	float LFN_AR[MAX_NO_WVBANDS], ph_val[MAX_NO_WVBANDS],total[MAX_NO_WVBANDS];
	float in_dot_leaf,clnz,slnz;
	int i,j;

	in_photon_vec=ptalloc();
	out_photon_vec=ptalloc();
	leaf_normal_vec=ptalloc();

	in_photon_vec->x= sin(theta_s);
	in_photon_vec->y= 0;
	in_photon_vec->z= cos(theta_s);
	out_photon_vec->x= sin(theta_o)*cos(phi);
	out_photon_vec->y= sin(theta_o)*sin(phi);
	out_photon_vec->z= cos(theta_o);
	i=0;
	for (j=0;j<NO_WVBANDS;j++) total[j]=0;
	for (leaf_normal_zenith=5.0;leaf_normal_zenith<=85.0;
		leaf_normal_zenith=leaf_normal_zenith+10.0) {
		i=i+1;
		for (j=0;j<NO_WVBANDS;j++) ph_val[j]=0;
		lnz=degtorad(leaf_normal_zenith);
		slnz=sin(lnz);
		clnz=cos(lnz);
	
		for(leaf_normal_azimuth=0.0;leaf_normal_azimuth<=350.0; 
			leaf_normal_azimuth=leaf_normal_azimuth+10.0) {
			lnz=degtorad(leaf_normal_zenith);
			lna=degtorad(leaf_normal_azimuth);
			leaf_normal_vec->x= 
  			slnz*cos(lna);

			leaf_normal_vec->y= slnz*sin(lna);

			leaf_normal_vec->z= clnz ;
	
			leaf_reflectance_fn(in_photon_vec,
		 			out_photon_vec,leaf_normal_vec,RHO_AR,TAU_AR,LFN_AR);

			in_dot_leaf=absfn(dot(in_photon_vec,leaf_normal_vec));

 			for (j=0;j<NO_WVBANDS;j++) ph_val[j]=ph_val[j]+in_dot_leaf*LFN_AR[j];
		}
	
		for (j=0;j<NO_WVBANDS;j++) total[j]=total[j]+ph_val[j]*LAD[i]*PI/18;
	}

	for (j=0;j<NO_WVBANDS;j++) OUT_AR[j]=total[j]*PI/2;
	free(in_photon_vec);
	free(out_photon_vec);
	free(leaf_normal_vec);
}


	
mk_phase_fn_array(RHO_AR,TAU_AR,OUT_AR)
	float RHO_AR[MAX_NO_WVBANDS],TAU_AR[MAX_NO_WVBANDS],OUT_AR[MAX_NO_WVBANDS][PXVAL][PYVAL][PZVAL];


/*	Pre-compile phase function array for all incomming and outgoing angles */

{
	float solid_angle;
	int theta_s,theta_o,phi,j;
	float PFV_AR[MAX_NO_WVBANDS],total[MAX_NO_WVBANDS];

	for (theta_s=0;theta_s< PXVAL;theta_s++) {
		for (j=0;j<NO_WVBANDS;j++) total[j]=0.0;
		for (theta_o=0;theta_o< PYVAL ;theta_o++) {
			for (phi=0;phi< PZVAL-1 ;phi++) {

			phase_fn_evaluate(
				degtorad((float)theta_s*10.0),
 				degtorad((float)theta_o*10.0),
				degtorad((float)phi*10.0),RHO_AR,TAU_AR,PFV_AR);

		for (j=0;j<NO_WVBANDS;j++) OUT_AR[j][theta_s][theta_o][phi]=PFV_AR[j];

	if ((theta_o==0) || (theta_o==18))
 			solid_angle=(1.0-cos(degtorad(5.0)))*2.0*PI/36.0;
		else 
		solid_angle=2*PI*( 
		cos(degtorad((float)theta_o*10.0-5.0))
		- cos(degtorad((float)theta_o*10.0+5.0)) )/36.0; 

		for (j=0;j<NO_WVBANDS;j++) total[j]=total[j]+PFV_AR[j]*solid_angle;

			}
		};
		for (theta_o=0;theta_o< PYVAL ;theta_o++) {
			for (phi=0;phi< PZVAL-1 ;phi++) {
				for (j=0;j<NO_WVBANDS;j++) OUT_AR[j][theta_s][theta_o][phi]=
					(OUT_AR[j][theta_s][theta_o][phi])*
					(RHO_AR[j]+TAU_AR[j])/(total[j]/(4*PI));
			}
			for (j=0;j<NO_WVBANDS;j++) OUT_AR[j][theta_s][theta_o][PZVAL-1]=
		 		OUT_AR[j][theta_s][theta_o][0];
		}
	};
}

	


read_hot_spot_array()

/*	Reads array describing foliage hot-spot function
*/

{
	int pindex,dindex;
	float pa,dp,tm;
	FILE *fpg;
	fpg=fopen("DATA/hotspot2.data","r"); 
	hot_spot_array[0][0]=0.001;

	for (pindex=1;pindex<=300.0;pindex++) {


		for (dindex=1;dindex<=799;dindex++) {

			hot_spot_array[0][dindex]=0.001;
		
			fscanf(fpg, "%f %f %f",&pa,&dp,&tm);

			hot_spot_array[pindex][dindex]=tm;
		}
		hot_spot_array[pindex][0]=hot_spot_array[pindex][1];

	}

	fclose(fpg);
}


read_reflectance_arrays()	 

/* Read arrays of reflectance spectra from files in directory SPEC.
	Each file must have NO_WAVEBANDS lines, each line is of form
	Wavelength Ref (Trans)
	Format is %f %f (%f)
	where Trans is only present for green leaf and senescent leaf spectra
	Function will return error if Wavelengths do not correspond between files,
	or if insufficient entries in file.
*/

{	
	int i,PreWave;
	float Rf,Tr,Wave;
	FILE *fplf,*fpsoil,*fpbark,*fpsen;


/*	Must always have soil spectral values, and wavelengths */

 	fpsoil=fopen("SPEC/soil.spec","r");
	if (fpsoil == NULL) {
		printf("ERROR - Missing soil spectrum file 'SPEC/soil.spec' \n");
		exit(0);
	}


	if (FRAC_GRN>0.0) {
		fplf=fopen("SPEC/leaf.spec","r");
		if (fplf == NULL) {
			printf("ERROR - Missing leaf spectrum file 'SPEC/leaf.spec' \n");
			exit(0);
		}
	}

	if ((FRAC_BARK>0.0) || (TRUNK_PRES>0)) {
		fpbark=fopen("SPEC/bark.spec","r");
		if (fpbark == NULL) {
			printf("ERROR - Missing bark spectrum file 'SPEC/bark.spec' \n");
			exit(0);
		}
	}

	if (FRAC_SEN>0.0) {
		fpsen=fopen("SPEC/sen.spec","r"); 
		if (fpsen == NULL) {
			printf("ERROR - Missing senescent spectrum file 'SPEC/sen.spec' \n");
			exit(0);
		}
	}




	for (i=0;i<NO_WVBANDS;i++) {

		fscanf(fpsoil,"%f %f\n",&Wave,&Rf);
		if ((Wave<350.0) || (Wave>3500.0)) {
			printf("ERROR - Waveband out of range (350.0-3500.0nm),\nInput value: %f\n",Wave);
			exit(0);
		}
		PreWave=(int)Wave;
		WAVELENGTH[i]=(int)Wave;
		GROUND_REFLECTANCE[i]=Rf;


		if (FRAC_GRN>0.0) {

			fscanf(fplf,"%f %f %f\n",&Wave,&Rf,&Tr);
		
			if ((int)Wave != PreWave) {
				printf("ERROR - Waveband mismatch (Soil/Leaf) \n");
				exit(0);
			}
			RHO[i]=Rf;TAU[i]=Tr;
		}
		
		if ((FRAC_BARK>0.0) || (TRUNK_PRES>0)) {

			fscanf(fpbark,"%f %f\n",&Wave,&Rf);

			if ((int)Wave != PreWave) {
				printf("ERROR - Waveband mismatch (Soil/Bark) \n");
				exit(0);
			}
			BARK[i]=Rf;
		}

		if (FRAC_SEN>0.0) {
			fscanf(fpsen,"%f %f %f\n",&Wave,&Rf,&Tr);

			if ((int)Wave != PreWave) {
				printf("ERROR - Waveband mismatch (Soil/Sen) \n");
				exit(0);
			}
			RHO_SEN[i]=Rf;TAU_SEN[i]=Tr;
		}

	}

	
	fclose(fpsoil);
	if (FRAC_GRN>0.0) fclose(fplf);
	if (FRAC_BARK>0.0) fclose(fpbark);
	if (FRAC_SEN>0.0) fclose(fpsen);
}

read_gnd_array()
{
/*
	This reads in full BRDF of a rough soil, generated using Hapke's
	model. Subsequent soil BRDFs are calculated as a linear function
	of this and a Lambertian BRDF, depending on soil roughness parameter (0-1)
*/

	float wvst,wvend,sz,saz,vz,vaz,ref,ch;
	int source_zen,view_zen,rel_az;
	FILE *fpg,*fpg2;
	fpg2=fopen("DATA/soilbrdf.data","r"); 
	for(source_zen=0;source_zen<GXVAL;source_zen++) {
		for(view_zen=0;view_zen<GYVAL;view_zen++) {
			for(rel_az=0;rel_az<GZVAL;rel_az++) {
				fscanf(fpg2, "%f %f %f %f",&sz,&vz,&vaz,&ref);
				gnd_fn_array[source_zen][view_zen][rel_az]=ref;
			}
		}
	}
	fclose(fpg2); 

}

read_canopy_data()

/* 
	Read data from "crowns.data" for user positioning and characterisation of canopy.
	Read in (i) dimsnesions and number of crowns, and (ii) the set of crown positions and data.

	Format:
	X__DIM, Y_DIM, NOSTANDS
	followed by NOSTANDS lines of
	crown type (c=0 or e=1), centre (x,y,z), shape parameters (Ex,Ey) or (r,h), LAI, LAD (user=0,sph=1,pl=2,er=3), LEAF_SIZE, DBH
	e    x    y    z   Ex   Ey  LAI LAD LEAF_SIZE  DBH
	...

	eg:
	50.0, 50.0, 12.0
	1  1.2 -10.1 12.7 1.0  2.0 3.1 2  0.1 0.2
	0  1.8 25.2 4.7 0.5  0.5  0.8  1 0.02  0.0
	...
	etc
*/

{
	FILE *fps;
	int i;
	float x,y,z,Exy,Ez,lai,leaf_size,dbh;
	float totwidth,totheight,totlength,minheight;
	int type,lad;

	fps=fopen("crowns.data","r"); 

	fscanf(fps,"%f %f %d",&X_DIM,&Y_DIM,&NOSTANDS);

	if (NOSTANDS < 0) {
		printf("ERROR - NOSTANDS must not be less than zero\nInput value: %d\n",NOSTANDS);
		exit(0);
	}
	if (NOSTANDS > MAX_NOSTANDS) {
		printf("ERROR - NOSTANDS  must not be greater than MAX_NOSTANDS \nInput value: %d  MAX_NOSTANDS: %d\n Revise input size or change MAX_NOSTANDS (line 140)\n",NOSTANDS,MAX_NOSTANDS);
		exit(0);
	}
	
	if ((X_DIM < 0.0) || (Y_DIM < 0.0)) {
		printf("ERROR - X_DIM and Y_DIM must be greater than zero\nInput values: %f %f\n",X_DIM,Y_DIM);
		exit(0);
	}
	totwidth=0; totheight=0; totlength=0.0; minheight=999.0;
	TRUNK_PRES=0;CANOPY_TOP=0.0;TRUNK_ANGLE=0.0;
	for (i=0;i<NOSTANDS;i++) {
		fscanf(fps,"%d %f %f %f %f %f %f %d %f %f",&type,&x,&y,&z,&Exy,&Ez,&lai,&lad,&leaf_size,&dbh);

		if (type==0) {
			if (dbh>0.0) {
				TRUNK_ANGLE=atan(dbh/z);
			}
			STANDS[i]=
				mkstand_cone(lai,
					mkcone(mkpoint(x,y,z),atan(Ez/Exy),Ez),
					mkcone(mkpoint(x,y,z),TRUNK_ANGLE,z) );
			if (z>CANOPY_TOP) CANOPY_TOP=z;
			if ((z-Ez)<minheight) minheight=z-Ez;
			totheight+=Ez;totlength+=Ez;totwidth+=Exy;

		}
		else if (type==1) {
			if (dbh>0.0) {
				TRUNK_ANGLE=atan(dbh/(z+Ez));
			}
			STANDS[i]=mkstand_ellipse(lai,
					mkellipse(mkpoint(x,y,z),Exy,Exy,Ez),
					mkcone(mkpoint(x,y,z+Ez),TRUNK_ANGLE,z+Ez) );
			if (z+Ez>CANOPY_TOP) CANOPY_TOP=z+Ez;
			if ((z-Ez)<minheight) minheight=z-Ez;
			totheight+=z+Ez;totlength+=2.0*Ez;totwidth+=Exy;
		}

		else {
			printf("ERROR - Crown type must be 0 (cone) or 1 (ellipse) \nInput value: %d\n",type);
			exit(0);
		}
		if (dbh > 0.0) TRUNK_PRES = 1;

/* Further individualised crowns not implemented for now:
	Should amend each stands to have its own parameterisation of LAD (e.g. 1-planophile, 2=spherical, 3= erectophile, 4=userinput) etc
		STANDS[i]->lad=lad;
		STANDS[i]->leaf_size=leaf_size;
		STANDS[i]->dbh=dbh;
*/
	}	
	
	printf("No. trees: %d\n",NOSTANDS);
	printf("Stand density: %f (crowns/ha)\n",10000*NOSTANDS/(4.0*X_DIM*Y_DIM));
	printf("Max tree height: %f \n",CANOPY_TOP);
	printf("Min height to first branch: %f \n",minheight);
	printf("Mean tree height: %f\n",totheight/((float)NOSTANDS));
	printf("Mean crown length: %f\n",totlength/((float)NOSTANDS));
	printf("Mean crown radius: %f\n\n",totwidth/((float)NOSTANDS));
	CANOPY_TOP_OUT=CANOPY_TOP+0.015;
	CANOPY_TOP_IN=CANOPY_TOP+0.01;
	if (Z_DIM < CANOPY_TOP_OUT) Z_DIM=CANOPY_TOP_OUT+0.2;

	SKY_PLANE=mkplane( mkpoint(X_DIM,-1*Y_DIM,Z_DIM), 
		mkpoint(X_DIM,Y_DIM,Z_DIM), mkpoint(-1*X_DIM,Y_DIM,Z_DIM));
	fclose(fps);
}

save_canopy_data()
{
	FILE *fps;
	int i;
	float x,y,z,Exy,Ez,lai,leaf_size,dbh;
	int type,lad;

	lai=0.0;
	lad=0;
	leaf_size=0.0;
	dbh=0.0;

	fps=fopen("crowns_out.data","w"); 
		
	fprintf(fps,"%f %f %d\n",X_DIM,Y_DIM,NOSTANDS);
	printf("%f %f %d\n",X_DIM,Y_DIM,NOSTANDS);

	for (i=0;i<NOSTANDS;i++) {
		lai=STANDS[i]->lai;

		if (STANDS[i]->crown_shape=='c') {
			type=0 ;
			x=STANDS[i]->cone->apex->x;
			y=STANDS[i]->cone->apex->y;
			z=STANDS[i]->cone->apex->z;
			Ez=STANDS[i]->cone->h;
			Exy=Ez*sqrt(STANDS[i]->cone->tansqphi);
		}
		else {
			type=1; 
			x=STANDS[i]->ellipse->centre->x;
			y=STANDS[i]->ellipse->centre->y;
			z=STANDS[i]->ellipse->centre->z;
			Ez=STANDS[i]->ellipse->Ez;
			Exy=STANDS[i]->ellipse->Ex;
		}
		fprintf(fps,"%d %f %f %f %f %f %f %d %f %f\n",type,x,y,z,Exy,Ez,lai,lad,leaf_size,dbh);
		printf("%d %f %f %f %f %f %f %d %f %f\n",type,x,y,z,Exy,Ez,lai,lad,leaf_size,dbh);
	}
}

read_struct_data()


/*	read data from "in_flight.data" describing scene to be
	simulated */

{
	FILE *fps;
	float LAD5,LAD15,LAD25,LAD35,LAD45,LAD55,LAD65,LAD75,LAD85;

	char buff;
	char buff2[30];
	fps=fopen("in_flight.data","r"); 
	fscanf(fps, "%s",&MODE);
	fscanf(fps, "%d",&ONED_FLAG);
	if (ONED_FLAG==3) ONED_FLAG=0; /* Allow setting of '3' or '0' to specify 3D case */
	fscanf(fps, "%f %f",&SOLAR_ZENITH,&VIEW_ZENITH_START);


	VIEW_ZENITH=VIEW_ZENITH_START;
	
	if (MULT_VIEWS) {fscanf(fps, "%f %f",&VIEW_ZENITH_END,&VIEW_ZENITH_STEP);}  //MW2: new lines to scan for extra numbers, or end of line
	else  {
	  while (buff!='\n') {  
	    fscanf(fps, "%c",&buff);
	    //printf("\n%c",buff);
	  }
	  VIEW_ZENITH_END=VIEW_ZENITH_START;
	  VIEW_ZENITH_STEP=10.0;
	}

	
	fscanf(fps, "%f %f",&SOLAR_AZIMUTH,&VIEW_AZIMUTH_START);

	
	VIEW_AZIMUTH=VIEW_AZIMUTH_START;
	buff=0;
	if (MULT_VIEWS) {fscanf(fps, "%f %f",&VIEW_AZIMUTH_END,&VIEW_AZIMUTH_STEP);}  //MW2: new lines to scan for extra numbers, or end of line
	else {
	  while (buff!='\n') {  
	    fscanf(fps, "%c",&buff);
	    //printf("\n%c",buff);
	  }
	  VIEW_AZIMUTH_END=VIEW_AZIMUTH_START;
	  VIEW_AZIMUTH_STEP=10.0;
	}


	fscanf(fps, "%d",&NO_WVBANDS);
	fscanf(fps, "%d",&NO_PHOTONS);
	fscanf(fps, "%f",&TOTAL_LAI);
	fscanf(fps, "%f %f %f",&FRAC_GRN,&FRAC_SEN,&FRAC_BARK);
	fscanf(fps, "%f %f %f %f %f %f %f %f %f",&LAD5,&LAD15,&LAD25,&LAD35,&LAD45,&LAD55,&LAD65,&LAD75,&LAD85);
	fscanf(fps, "%f",&SOILROUGH);
	fscanf(fps, "%f",&AER_OPT);
	fscanf(fps, "%f",&LF_SIZE);
	fscanf(fps, "%f",&FRAC_COV);

	//MW2: print statements to show variables:
	printf("\nSOLAR_ZENITH: %f \tVIEW_ZENITH: %f",SOLAR_ZENITH,VIEW_ZENITH);
	if (MULT_VIEWS) printf("\n\t\t\t\tVIEW_ZENITH_END: %f \t VIEW_ZENITH_STEP: %f",VIEW_ZENITH_END,VIEW_ZENITH_STEP);
	printf("\nSOLAR_AZIMUTH: %f \tVIEW_AZIMUTH: %f",SOLAR_AZIMUTH,VIEW_AZIMUTH);
	if (MULT_VIEWS) printf("\n\t\t\t\tVIEW_AZIMUTH_END: %f \t VIEW_AZIMUTH_STEP: %f",VIEW_AZIMUTH_END,VIEW_AZIMUTH_STEP);
	printf("\n");
printf("ONED_FLAG= %d\n",ONED_FLAG);


/* Following parameters are only required for 3D case: */

	if (ONED_FLAG==0) {

		X_DIM=10.0;
		Y_DIM=10.0;

		fscanf(fps, "%s",&CROWN_SHAPE);
		if (CROWN_SHAPE=='f') {
			FIELD_DATA=1;
		} else{
			FIELD_DATA=0;
			fscanf(fps, "%f %f",&Exy,&Ez);
			if (CROWN_SHAPE=='c') { 
				CONE_ANGLE=atan(Exy/(Ez))*180.0/PI;
				CONE_HEIGHT=Ez;
				printf("HT_TO_WD = %f\n",HT_TO_WD);    /* MW:  check */
			} 
			else {
				HT_TO_WD=Ez/Exy;
				 printf("HT_TO_WD = %f\n",HT_TO_WD);    /* MW:  check */
			}
		
			fscanf(fps, "%f %f",&MIN_HT,&MAX_HT);
			fscanf(fps, "%f",&DBH);
			if (DBH>0.0) {
				TRUNK_PRES = 1;
				TRUNK_ANGLE=atan(DBH/(0.5*(MAX_HT+MIN_HT)+Ez))*180.0/PI;
			}
			else TRUNK_PRES = 0;
		}

	}
	else {
		X_DIM=1.0;
		Y_DIM=1.0;
		Z_DIM=1.0;
	}
	fclose(fps);

	LAD[1]=LAD5;LAD[2]=LAD15;LAD[3]=LAD25;LAD[4]=LAD35;LAD[5]=LAD45;
	LAD[6]=LAD55;LAD[7]=LAD65;LAD[8]=LAD75;LAD[9]=LAD85;
}

check_data()

/*	Preforms some validation checks on data read in */

{
	int i;
	float totlad=0.0;

	if ((MODE != 'f') && (MODE != 'i') && (MODE != 's') && (MODE != 'r')) {
		printf("ERROR - MODE must be f,r,i or s\nInput value: %s\n",MODE);
		exit(0);
	}
	if ((ONED_FLAG!=0) && (ONED_FLAG!=1)) {
		printf("ERROR - ONED_FLAG must be 0 or 1\nInput value: %d\n",ONED_FLAG);
				exit(0);
	}
	if ((MODE == 's') && (ONED_FLAG==1)) {
			printf("ERROR - 's' mode only appropriate for 3D case\n");
					exit(0);
	}

	if (SOLAR_ZENITH>90.0) {
		printf("ERROR - Solar zenith must be in range 0-90 (dir) or <0 (diffuse)\nInput value: %f\n",SOLAR_ZENITH);
		exit(0);
	}

	if ( (MODE!='f') && (MODE!='r') && (SOLAR_ZENITH<0.0))   {
		printf("ERROR - Solar zenith must be in range 0-90 for imaging mode\nInput value: %f\n",SOLAR_ZENITH);
		exit(0);
	}

	if ((SOLAR_AZIMUTH<0.0) || (SOLAR_AZIMUTH>360.0)) {
		printf("ERROR - Solar zenith must be in range 0-360\nInput value: %f\n",SOLAR_AZIMUTH);
		exit(0);
	}

	//MW2: error checking for range values - must be ascending order
	if (MULT_VIEWS) {
	  if (VIEW_ZENITH_END < VIEW_ZENITH) {
		printf("ERROR - End point for view zenith range must be greater than view zenith (= start point)!\n");
		exit(0);
	  }
	}
	//MW2: error checking for range values - must be ascending order
	if (MULT_VIEWS) {
	  if (VIEW_AZIMUTH_END < VIEW_AZIMUTH) {
		printf("ERROR - End point for view azimuth range must be greater than view azimuth (= start point)!\n");
		exit(0);
	  }
	}




	if (NO_WVBANDS<1) {
		 printf("ERROR - NO_WVBANDS  must be > 0 \nInput value: %d\n",NO_WVBANDS);
		exit(0);
	}

	if (NO_WVBANDS>MAX_NO_WVBANDS) {
		 printf("ERROR - NO_WVBANDS (%4d) must be < MAX_NO_WVBANDS (%4d) \n",NO_WVBANDS,MAX_NO_WVBANDS);
		exit(0);
	}

	if (NO_PHOTONS<1) {
		 printf("ERROR - NO_PHOTONS  must be > 0 \nInput value: %d\n",NO_PHOTONS);
		exit(0);
	}

	/* if (TOTAL_LAI<0.0)  {
		 printf("ERROR - TOTAL_LAI must be >= 0 \nInput value: %f\n",TOTAL_LAI);
		exit(0);
		}
	*/
	if ((FRAC_GRN<0.0) || (FRAC_SEN<0.0) || (FRAC_BARK<0.0) || ((FRAC_GRN+FRAC_SEN+FRAC_BARK)>1.000001) || ((FRAC_GRN+FRAC_SEN+FRAC_BARK)<0.9999)) {
		printf("ERROR - FRAC_GRN/FRAC_SEN/FRAC_BARK must be in range 0 - 1\n");
		exit(0);
	}

	for (i=1;i<=9;i++) totlad+=LAD[i];
	if ((totlad > 1.0001) || (totlad < 0.9999)) {
		printf("ERROR - LAD must sum to 1.0\nInput value: %f\n",totlad);
		exit(0);
	}

	if ((SOILROUGH<0.0) || (SOILROUGH>1.0))   {
		printf("ERROR - SOILROUGH must lie in range 0-1 \nInput value: %f\n",SOILROUGH);
		exit(0);
	}

	if ( AER_OPT>10.0)   {
		printf("ERROR - AER_OPT must be < 10 (use negative value of solar zenith for pure diffuse) \nInput value: %f\n",AER_OPT);
		exit(0);
	}

	if ( (MODE!='f') && (MODE!='r') && (AER_OPT>=0.0))   {
		 printf("Direct illumination only in this mode...\n"); 
		AER_OPT=-1.0;
	}

	if ( (ONED_FLAG==1) &&  (LF_SIZE>1.0) )  {
		printf("ERROR - LF_SIZE must lie in range 0-1 for 1D case. \nInput value: %f\n",LF_SIZE);
		exit(0);
	}
	if (LF_SIZE<0.0)  {
		printf("ERROR - LF_SIZE must lie be > 0 \nInput value: %f\n",LF_SIZE);
		exit(0);
	}

	if (ONED_FLAG==0) {

		if (NOSTANDS<0) {
			 printf("ERROR - NO_STANDS  must be >= 0 \n");
			exit(0);
		}

		if (NOSTANDS>MAX_NOSTANDS) {
		 	printf("ERROR - NOSTANDS (%4d) must be <= MAX_NOSTANDS (%4d) \n",NOSTANDS,MAX_NOSTANDS);
			exit(0);
		}
		if (X_DIM<=0.0) {
		 	printf("ERROR - X_DIM must be > 0\nInput value: %f\n",X_DIM);
			exit(0);
		}

		if (Y_DIM<=0.0) {
		 	printf("ERROR - Y_DIM must be > 0\nInput value: %f\n",Y_DIM);
			exit(0);
		}

		if ((FRAC_COV<0.0)|| (FRAC_COV>1.0)) {
		 	printf("ERROR - FRAC_COV must lie in range 0-1 \nInput value: %f\n",FRAC_COV);
			exit(0);
		}
		if ((DBH<0.0)|| (DBH>Exy)) {
		 	printf("ERROR - DBH must lie in range 0-Crown radius \nInput value: %f\n",DBH);
			exit(0);
		}
	}
}

find_max_scat()

/*	finds waveband at which foliage is minimally absorbing, in order to terminate
	photon trajectory when this falls below some threshold (close to zero)
*/

{
	int i;
	float absorption,min_abs=2.0;
	for (i=0;i<NO_WVBANDS;i++) {
		absorption=1.0-((RHO[i]+TAU[i])*FRAC_GRN+FRAC_SEN*(RHO_SEN[i]+TAU_SEN[i])+(FRAC_BARK*BARK[i]));
		if ((absorption > 1.0) || (absorption < 0.0)) {
			printf("ERROR - Foliage absorption (at waveband #%d) must lie in range 0-1\nValue=%f",i,absorption);
			exit(0);
		}
		if ((absorption < min_abs) || (i==0)) {
			min_abs=absorption;
			NIR=i;
		}
	}
}


float find_frac_cover(no_trials)
	int no_trials;

/*	Monte-Carlo estimation of fractional cover to allow estimate
	to include overlapping boundaries correctly. Accuracy is
	1/sqrt(no_trials)
*/

{
	int i,j,flag;
	float tot=0.0,total_area=0.0;
	float x1,y1,cx,cy,dist_from_apex_sq,rsq;
	struct cone *cone;
	struct ellipse *ellipse;


	for (i=1;i<=no_trials;i++) {
		x1=(rand()*RAND_MULT*(float)(X_DIM)*2.0)-(float)X_DIM;
		y1=(rand()*RAND_MULT*(float)(Y_DIM)*2.0)-(float)Y_DIM;
		flag=0;
		for  (j=0;j<NOSTANDS;j++) {

			if (STANDS[j]->crown_shape=='c') {

				cone=STANDS[j]->cone;
				cx=cone->apex->x;cy=cone->apex->y;
				rsq=cone->radius_sq;
				dist_from_apex_sq=(x1-cx)*(x1-cx)+(y1-cy)*(y1-cy);
				 if (cone->apex->z < cone->h) {
					printf("ERROR - cone (stand no. %d) lies below ground\n",j);
					printf ("z: %f h: %f\n",cone->apex->z,cone->h);
					exit(0);
				}
				

			}

			else {
				ellipse=STANDS[j]->ellipse;
				cx=ellipse->centre->x;cy=ellipse->centre->y;
				dist_from_apex_sq=(x1-cx)*(x1-cx)+(y1-cy)*(y1-cy);
				rsq=ellipse->Ex*ellipse->Ex;
				if (ellipse->centre->z<0.0) {
					printf("ERROR - ellipse centre (stand no. %d) lies below ground\n",j);
					exit(0);
				}

			}

			if (dist_from_apex_sq<rsq) flag=1;

		}
		if (flag==1) tot++;
	}
		total_area=tot/((float)no_trials);
	return total_area;
}


int clearing_intersect(crown_no)   /* NOT YET FINISHED   */
	int crown_no;
	{
	float x,y;
	int flag;

	/* Check crown does not appear in one of designated areas for cleared. Specify these by, e.g. rectangles read in, using 'image coordinates', in range 0->1, 0->1 */
				        
	if (STANDS[crown_no]->crown_shape='c') {
	  x=(STANDS[crown_no]->cone->apex->x)/X_DIM;   /* should scale between -1 and 1  etc */
	  y=STANDS[crown_no]->cone->apex->y;
	} else {
	  x=STANDS[crown_no]->ellipse->centre->x;
	  y=STANDS[crown_no]->ellipse->centre->y;
	}
	return flag;

}


forest_gen3()

/*	Generates a 3d distribution of crowns to fit user statistics. Currently somewhat clumsy
	 and can be slow for high fractional covers (>90%), but is fairly robust.

	SCALE_FACTOR relates measurements in the simulation to user defined measurements,
	to facilitate communication.

	If we wish to use other distributions or field data, we must place each cone/ellipse
	within the box [-X_DIM to +X_DIM, -Y_DIM to +Y_DIM, 0 to Z_DIM]. The variable SCALE_FACTOR 
	must then be set to define the ratio of the real size of the plot to the x-y dimensions of the box.

	X_DIM and Y_DIM are global variables set in read_struct_data(), and currently fixed at 10. 
	Z_DIM is arbitrarily set at just above the highest tree.

	As user's units are in metres, the following internal variables will be scaled when used by the
	program:

	LEAF_SIZE
	Exy, Ez 
	MIN_HT,MAX_HT
	DBH	

 	In this routine, SCALE_FACTOR ties Exy to the internal variable mean_radius, which is chosen to fit the
	spheroids/cones into the bounding box.


*/ 


{
  float del,leeway,x,y,mean_radius,frac_overlap,fot,ffc,var_tol,X_VAR_TOGGLE,Z_VAR_TOGGLE,a=1,b=1; /* MW: Variables added */
	int i,k,flag,cnt,tries,tries2,cnt2;
	float tot,totvol,totwidth,totheight,totlength,minheight,temp;

       	var_tol=0.4;     /*MW:  variation tolerance for radius of crown, e.g. set to 40%   */
       	X_VAR_TOGGLE=0;  /*MW:  toggle for x/y variation: 0=off   */
       	if (X_VAR_TOGGLE) { printf("X/Y variation enabled: %f%% tolerance\n",var_tol*100); }
       	Z_VAR_TOGGLE=0;  /*MW:  toggle for z variation: 0=off    */
       	if (Z_VAR_TOGGLE) { printf("Z variation enabled: %f%% tolerance\n",var_tol*100); }

	leeway=1.0;    /* MW: value should vary between 1 and 4 for 0 - 100% overlap tolerance - see p.27 v.II labbook */

	del=0.001*(float)X_DIM; /*  Allow this fraction of overlap between crowns and wall boundaries */

	mean_radius=sqrt(4.0*FRAC_COV*(float)X_DIM*(float)Y_DIM/((float)NOSTANDS*PI));
	flag=0;
	i=0; /* Attempt to place i th stand within loop below */
	cnt=0;
	tries=10;
	
	fot=FRAC_COV*2.5; /* fractional overlap tolerance - allow overlap to increase to this extent if necessary */


	if (FRAC_COV>.4) {
		leeway+=2.5*(FRAC_COV-.4);
		mean_radius*=sqrt(1.0+0.05*FRAC_COV);
	}

	tries2=10; /* Total number of 'backtracking' attempts allowed, before changing overlap permitted */
	cnt2=0;
	ffc=0.0; /* fractional cover so far */
	frac_overlap=2.0*(1-1/sqrt(leeway));

	while ( (absfn(ffc-FRAC_COV)>0.01) || (i<(NOSTANDS-1)) ) {


		if (ffc<FRAC_COV ) {

		/* If there is a problem generating fractional cover, adjust parameters to allow greater
			overlap between tree crowns
		*/
			if ((i== (NOSTANDS)) || ((FRAC_COV>.95) && (i> NOSTANDS/2)) ) mean_radius=mean_radius*
				sqrt( (float)i/(float)NOSTANDS*FRAC_COV/ffc );

			frac_overlap=2.0*(1-1/sqrt(leeway));
			if ((frac_overlap<fot) || ((FRAC_COV>.95) && (frac_overlap<2.0))) leeway=leeway*1.1;
			frac_overlap=2.0*(1-1/sqrt(leeway));
		}
		cnt2=0;i=0;

		SCALE_FACTOR=Exy/mean_radius; /* Maps 'mean-radius' calculated to user statement of crown radius Exy */

		/* printf("internal variable mean_radius = %f\n",mean_radius);   /* MW:  Un-comment to show progress of frac. cover searching  */

		while((i<NOSTANDS) && (cnt2<tries2)) {

	/*  Within this loop simply try to place trees at random within box */
	
			x=0.5*mean_radius+2.0*rand()*RAND_MULT*((float)X_DIM-0.5*mean_radius-del)-(float)X_DIM;
			y=0.5*mean_radius+2.0*rand()*RAND_MULT*((float)Y_DIM-0.5*mean_radius-del)-(float)Y_DIM;
				 

			if (STANDS[i]->crown_shape=='c') {
				 STANDS[i]->cone->apex->x=x;
				 STANDS[i]->cone->apex->y=y;
				 
				 if (X_VAR_TOGGLE) {         /*MW:  if/else to use x/y-variation or not, dependent on state of X_VAR_TOGGLE   */
				   b=mean_radius+(((rand()*RAND_MULT)-0.5)*2*var_tol*mean_radius);    /*MW: Randomised radius */
				   STANDS[i]->cone->radius_sq=b*b; 

				 }
				 else {
				   STANDS[i]->cone->radius_sq=mean_radius*mean_radius;
				  }

				 if (Z_VAR_TOGGLE) {         /*MW:  if/else to use z-variation or not, dependent on state of Z_VAR_TOGGLE   */

				   a=(sqrt(STANDS[i]->cone->radius_sq))/(sqrt(STANDS[i]->cone->tansqphi));    /*MW: New starting height, function of new radius and
														old angle, => keep same aspect ratio */
				   STANDS[i]->cone->h=a+(((rand()*RAND_MULT)-0.5)*2*var_tol*a);  /*MW: Randomised new height */
				   STANDS[i]->cone->tansqphi=(sqrt(STANDS[i]->cone->radius_sq)/STANDS[i]->cone->h)      /*MW:  tan(phi) = radius/height */
				                            *(sqrt(STANDS[i]->cone->radius_sq)/STANDS[i]->cone->h);
				   
				 }
				 else {
				   a=(sqrt(STANDS[i]->cone->radius_sq))/(sqrt(STANDS[i]->cone->tansqphi));    /*MW: New starting height, function of new radius and
														old angle, => keep same aspect ratio */
				   STANDS[i]->cone->h=a;   /*MW: No variation in new height */
				   /*MW: tansqphi is the same as before */
				 }

				STANDS[i]->cone->apex->z=STANDS[i]->cone->h+(MIN_HT+rand()*RAND_MULT*(MAX_HT-MIN_HT))/SCALE_FACTOR;
				/* STANDS[i]->cone->radius_sq=mean_radius*mean_radius; */  /*  MW: commented out - resets radius_squared?!  */

				STANDS[i]->cone->sphere_radius =
 				  sqrt(STANDS[i]->cone->radius_sq*STANDS[i]->cone->radius_sq+STANDS[i]->cone->h*STANDS[i]->cone->h);

				STANDS[i]->cone2->apex=STANDS[i]->cone->apex;   /*MW: crown and trunk apexes are at same point   */
				STANDS[i]->cone2->h=STANDS[i]->cone->apex->z;
				 
			}
			else {
				STANDS[i]->ellipse->centre->x=x;
				STANDS[i]->ellipse->centre->y=y;
				
				if (X_VAR_TOGGLE) {         /*MW:  if/else to use x/y-variation or not, dependent on state of X_VAR_TOGGLE   */
				  STANDS[i]->ellipse->Ex=mean_radius+(((rand()*RAND_MULT)-0.5)*2*var_tol*mean_radius);   /*MW:  Ex +/- 50%   */
				  STANDS[i]->ellipse->Ey=STANDS[i]->ellipse->Ex;    /*MW:  Changed from "...=mean_radius;"    */
				}
				else {
				  STANDS[i]->ellipse->Ex=mean_radius;   
				  STANDS[i]->ellipse->Ey=STANDS[i]->ellipse->Ex;
				}
							
				if (Z_VAR_TOGGLE) {         /*MW:  if/else to use z-variation or not, dependent on state of Z_VAR_TOGGLE   */
				  STANDS[i]->ellipse->Ez=STANDS[i]->ellipse->Ex*HT_TO_WD
				    +(((rand()*RAND_MULT)-0.5)*2*var_tol*(STANDS[i]->ellipse->Ex*HT_TO_WD));   /*MW: Randomised new height */
				}	  /*MW:  Ez defined as fn of Ex and HT_TO_WD     */
				else  {       
				  STANDS[i]->ellipse->Ez=STANDS[i]->ellipse->Ex*HT_TO_WD; /*MW: No variation in new height */
				}
			
				STANDS[i]->ellipse->centre->z=
					STANDS[i]->ellipse->Ez+(MIN_HT+rand()*RAND_MULT*(MAX_HT-MIN_HT))/SCALE_FACTOR;
				STANDS[i]->cone2->apex->x=STANDS[i]->ellipse->centre->x;
				STANDS[i]->cone2->apex->y=STANDS[i]->ellipse->centre->y;
				STANDS[i]->cone2->apex->z=STANDS[i]->ellipse->centre->z+STANDS[i]->ellipse->Ez;

				STANDS[i]->cone2->h=STANDS[i]->cone2->apex->z;
			}

			flag=0;

			 for(k=0;k<i;k++) if (circ_intersect(i,k,leeway)) flag=-1; 
			 if (NOFACETS >0) { if (intersect_facets_crowns(i+1)) flag=-1;} 
			 
			 /* if (clearing_intersect(i)) flag=-1; */  /*MW: un-comment to call tree-rejection routine  */
			 
			 
			if (flag==0) { /* crown is acceptable, increase i to place next crown */
				i++; 
				cnt=0;
			}
			else 	cnt++;   /* Repeat attempt to place i'th crown, unless cnt>tries*i */

 			if (cnt>tries*i) { /* Backtrack - remove previous tree (if any), and try again, resetting cnt */
				cnt=0;
				if (i>0) i--;
				cnt2++; 
			}
			
		} /* repeat until crowns placed or number of tries exceeded (cnt2>=tries2) */
		
	temp=NOSTANDS;
	NOSTANDS=i;
	ffc=find_frac_cover(20000);
	NOSTANDS=temp;

	} /* Repeat until fractional coverage is great enough, and all crowns placed */

	 /* Now multiply all measurements by SCALE_FACTOR, so units are 1m. We get a new scene size X_DIM, Y_DIM.  */
	 X_DIM=X_DIM*SCALE_FACTOR;
	 Y_DIM=Y_DIM*SCALE_FACTOR;
	for  (i=0;i<NOSTANDS;i++) {
		if (STANDS[i]->crown_shape=='c') {
			STANDS[i]->cone->h=STANDS[i]->cone->h*SCALE_FACTOR;
			STANDS[i]->cone->apex->x=STANDS[i]->cone->apex->x*SCALE_FACTOR;
			STANDS[i]->cone->apex->y=STANDS[i]->cone->apex->y*SCALE_FACTOR;
			STANDS[i]->cone->apex->z=STANDS[i]->cone->apex->z*SCALE_FACTOR;
			STANDS[i]->cone->radius_sq=STANDS[i]->cone->radius_sq*SCALE_FACTOR*SCALE_FACTOR;
			STANDS[i]->cone->sphere_radius=STANDS[i]->cone->sphere_radius*SCALE_FACTOR;
		} 
		else {
			STANDS[i]->ellipse->centre->x=STANDS[i]->ellipse->centre->x*SCALE_FACTOR;
			STANDS[i]->ellipse->centre->y=STANDS[i]->ellipse->centre->y*SCALE_FACTOR;
			STANDS[i]->ellipse->centre->z=STANDS[i]->ellipse->centre->z*SCALE_FACTOR;

			STANDS[i]->ellipse->Ex=STANDS[i]->ellipse->Ex*SCALE_FACTOR;
			STANDS[i]->ellipse->Ey=STANDS[i]->ellipse->Ey*SCALE_FACTOR;
			STANDS[i]->ellipse->Ez=STANDS[i]->ellipse->Ez*SCALE_FACTOR;


		}
			STANDS[i]->cone2->h=STANDS[i]->cone2->h*SCALE_FACTOR;
			STANDS[i]->cone2->apex->x=STANDS[i]->cone2->apex->x*SCALE_FACTOR;
			STANDS[i]->cone2->apex->y=STANDS[i]->cone2->apex->y*SCALE_FACTOR;
			STANDS[i]->cone2->apex->z=STANDS[i]->cone2->apex->z*SCALE_FACTOR;
	}
	SCALE_FACTOR=1.0;
			
		

	
	/* Now compute canopy statistics */
	
	
	tot=0.0;totvol=0.0;totwidth=0.0;totheight=0.0;totlength=0.0;minheight=999.9;
	CANOPY_TOP=0.0;

	for  (i=0;i<NOSTANDS;i++) {
		if (STANDS[i]->crown_shape=='c') {


				
				STANDS[i]->cone2->radius_sq=
					STANDS[i]->cone2->h*sqrt(STANDS[i]->cone2->tansqphi);
				STANDS[i]->cone2->radius_sq=STANDS[i]->cone2->radius_sq*
					STANDS[i]->cone2->radius_sq;	
				STANDS[i]->cone2->sphere_radius=
					sqrt(STANDS[i]->cone2->radius_sq*STANDS[i]->cone2->radius_sq
					+STANDS[i]->cone2->h*STANDS[i]->cone2->h);


			tot=tot+PI*STANDS[i]->cone->radius_sq;
			totvol+= 0.3333*PI*STANDS[i]->cone->radius_sq*STANDS[i]->cone->h;
			totwidth+=sqrt(STANDS[i]->cone->radius_sq);
			totheight+=STANDS[i]->cone->apex->z;
			totlength+=STANDS[i]->cone->h;
			if (STANDS[i]->cone->apex->z > CANOPY_TOP) CANOPY_TOP=STANDS[i]->cone->apex->z;
			if (STANDS[i]->cone->apex->z-STANDS[i]->cone->h < minheight)
				 minheight=STANDS[i]->cone->apex->z-STANDS[i]->cone->h;
		}
		else {
		

				STANDS[i]->cone2->radius_sq=
					STANDS[i]->cone2->h*sqrt(STANDS[i]->cone2->tansqphi);
				STANDS[i]->cone2->radius_sq=STANDS[i]->cone2->radius_sq*
					STANDS[i]->cone2->radius_sq;	
				STANDS[i]->cone2->sphere_radius=
					sqrt(STANDS[i]->cone2->radius_sq*STANDS[i]->cone2->radius_sq
					+STANDS[i]->cone2->h*STANDS[i]->cone2->h);

			tot=tot+PI*STANDS[i]->ellipse->Ex*STANDS[i]->ellipse->Ex;
			totvol+= 1.3333*PI*STANDS[i]->ellipse->Ex*STANDS[i]->ellipse->Ey*STANDS[i]->ellipse->Ez;
			totwidth+=STANDS[i]->ellipse->Ex;
			totheight+=STANDS[i]->cone2->apex->z;
			totlength+=2.0*STANDS[i]->ellipse->Ez;
			if (STANDS[i]->cone2->apex->z > CANOPY_TOP)
				 CANOPY_TOP=STANDS[i]->cone2->apex->z;
			if (STANDS[i]->ellipse->centre->z-STANDS[i]->ellipse->Ez < minheight)
				 minheight=STANDS[i]->ellipse->centre->z-STANDS[i]->ellipse->Ez;
		}
	 }
	 
	 

	 
	printf("Backtracking count: %d\n",cnt2);
	printf("No. trees: %d\n",NOSTANDS);
	printf("Crown volume density (m3/m2) (not accounting for overlap): %f   \n", totvol/(4.0*X_DIM*Y_DIM));
	printf("Stand density: %f (crowns/ha)\n",10000*NOSTANDS/(4.0*X_DIM*Y_DIM));
	printf("Max tree height: %f \n",CANOPY_TOP);
	printf("Min height to first branch: %f \n",minheight);
	printf("Mean tree height: %f\n",totheight/((float)NOSTANDS));
	printf("Mean crown length: %f\n",totlength/((float)NOSTANDS));
	printf("Mean crown radius: %f\n",totwidth/((float)NOSTANDS));
	printf("Scene dimensions: x: %f m y; %f m\n",2*X_DIM,2*Y_DIM);

/*	Fix upper boundary just above canopy to speed calculation of photon trajectories */

	CANOPY_TOP_OUT=CANOPY_TOP+0.015;
	CANOPY_TOP_IN=CANOPY_TOP+0.01;
	if (Z_DIM < CANOPY_TOP_OUT) Z_DIM=CANOPY_TOP_OUT+0.2;

	SKY_PLANE=mkplane( mkpoint(X_DIM,-1*Y_DIM,Z_DIM), 
		mkpoint(X_DIM,Y_DIM,Z_DIM), mkpoint(-1*X_DIM,Y_DIM,Z_DIM));
		
	MIN_GREEN_HEIGHT = (minheight*100.0)/CANOPY_TOP; /*Used in photosynthesis calculation */

}


float find_canopy_volume(no_trials)
	int no_trials;
{

	/* 	Uses Monte Carlo integration to estimate total volume enclosed by
		all ellipses and cones. This is necessary as no analytic formula 
		exists for the volume of intersection of two ellipses.

		Fractional accuracy is ~ 1/sqrt(no_trials)
	*/

	struct photon *photon;
	float tot=0.0,total_volume=0.0;
	int i,j,flag;
	float ph_intensity[MAX_NO_WVBANDS];  
	photon=mkphoton(mkpoint(1.0,1.0,Z_DIM-0.01),mkpoint(0.0,0.0,-1.0),ph_intensity);
	for (i=1;i<=no_trials;i++) {

		photon->pos->x=(rand()*RAND_MULT*(float)(X_DIM)*2.0)-(float)X_DIM;
		photon->pos->y=(rand()*RAND_MULT*(float)(Y_DIM)*2.0)-(float)Y_DIM;
		photon->pos->z=rand()*RAND_MULT*CANOPY_TOP_IN;

		flag=0;
	
		for  (j=0;j<NOSTANDS;j++) if (inside_stand(photon->pos,j)) flag=1;
		if (flag==1) tot++;
	}

	total_volume=4.0*(float)(X_DIM)*(float)(Y_DIM)*CANOPY_TOP_IN*tot/((float)no_trials);
	free(photon);
	return total_volume;
}

define_component_names()
{
	sprintf(component_names[0],"Sunlit soil      ");
	sprintf(component_names[1],"Shaded soil      ");

	if ((MODE=='i') || (MODE=='r')) {
		sprintf(component_names[2],"Sunlit green leaf");
		sprintf(component_names[3],"Shaded green leaf");
		sprintf(component_names[4],"Sunlit senescent leaf");
		sprintf(component_names[5],"Shaded senescent leaf");
		sprintf(component_names[6],"Sunlit bark      ");
		sprintf(component_names[7],"Shaded bark      ");
	}
	else {
		sprintf(component_names[2],"Sunlit foliage");
		sprintf(component_names[3],"Shaded foliage");
	}
}


float calculate_sky_diff_irrad(wv,theta,phi)
	int wv;	
	float theta,phi;
/* Returns coefficient to give anisotropic sky radiance distribution; wv is wavelength in nm, theta and phi are zenith and azimuth
 of vector to sky, in radians. Uses normalised LUT of sky radiance distribution in SKY_ARRAY 
 Currently simple 'nearest neighbour' interpolation except for AER_OPT and Wavelength.
 For efficiency a single table could be interpolated prior to main run for all wavelengths, and  given solar zen & AOPT  */
{

	int index_sz,index_zen,index_az,index_tau,index_wv;
	float rel_az,fac,fac1,fac2,l1,l2,fac3;

	rel_az=RDEG*phi-SOLAR_AZIMUTH;
	if (rel_az <0.0) rel_az=rel_az+360.0;
	if (rel_az >180.0) rel_az=rel_az-180.0; /* Symmetric around 180 deg */

	index_sz=(int)(SOLAR_ZENITH*0.1);if (index_sz<0) index_sz=10;
	index_zen=(int)(RDEG*theta*0.1);
	index_az=(int)(rel_az*0.1);
	index_tau=(int)AER_OPT*2; if (index_tau<0) index_tau=0;if (index_tau>6) index_tau=6;
	index_wv=(int)(wv/400-1); if (index_wv<0) index_wv=0;if (index_wv>3) index_wv=3;
	if (index_zen == 0) index_az=0;

/*printf("tau %d  wv %d  sz %d  zen %d  az %d \n", index_tau, index_wv, index_sz, index_zen, index_az);*/
	
	fac1=SKY_ARRAY[index_tau][index_wv][index_sz][index_zen][index_az];

	/* The following provides bilinear interpolation on wavelength and AOT; for speed could simply return fac1 */
	/* First interpolate value at wv=index_wv between 2 values of AER_OPT: */

	if (index_tau<6) { 
		fac2=SKY_ARRAY[index_tau+1][index_wv][index_sz][index_zen][index_az];
		l1=AER_OPT*2.0-(float)index_tau;
		l2=1.0-l1;
		fac=fac2*l1+fac1*l2;
	} else fac=fac1;
	
	
/* Interpolate value at wv=index_wv+1 between 2 values of AER_OPT: */
	if (index_wv<3) { 
		fac1=SKY_ARRAY[index_tau][index_wv+1][index_sz][index_zen][index_az];
		if (index_tau<6) { 
		  fac2=SKY_ARRAY[index_tau+1][index_wv+1][index_sz][index_zen][index_az];
		  l1=AER_OPT*2.0-(float)index_tau;
		  l2=1.0-l1;
		  fac3=fac2*l1+fac1*l2;
		} else fac3=fac1;
	/* Combine to give interpolated value: */
		
		l1=(wv/400-1)-(float)index_wv;
		l2=1.0-l1;
		fac=fac3*l1+fac*l2;
	}

	
	return fac;

}



read_sky_field()
{
/* Read map of angular variation of sky diffuse radiance dependent on aerosol loading, 
   	wavelength and solar angle, and normalise */
   
	int tauind,lambda,isz,ivz,ira,ti,wv,sz,vz,ra,isz2,ivz2,ira2,iwv,i, use_lut;
	float radiance,tau,n_sum,n_sum2,fac,nfac,tsz,tsa,taopt;
	float norm_steven, b_steven, n_steven=0.0;
	struct point *vec;
	FILE *fpout;
	vec=mkpoint(0.0,0.0,0.0);
	
	printf("Reading diffuse sky table\n");
	fpout=fopen("DATA/sky_diffuse2.data","r");
	taopt=AER_OPT;tsa=SOLAR_AZIMUTH;tsz=SOLAR_ZENITH;

	use_lut=1;
	if (use_lut==0){ 
		b_steven=0.0; 		/* From Steven and Unsworth, giving alternative diffuse sky model for cloud (b=0 for 
					isotropic). See Alton et al., JGR 2005 */
	
		norm_steven=((1.0+b_steven)*3.142)/(3.142+(2.0*b_steven));
	}

	for (tauind=0; tauind<=6; tauind+=1) {
  	  for (lambda=400; lambda<=1600; lambda+=400) {
    	    for (isz=0; isz<=90; isz+=10){
	      n_sum=0.0;n_sum2=0.0;
      	      for (ivz=0; ivz<=90; ivz+=10) {
	      
	        if (use_lut==0) n_steven = ( 1 + (b_steven*cos((ivz*3.142)/180)) )/( 1+b_steven );
	      
       	        for (ira=0; ira<=180; ira+=10) {
		
		  if (use_lut==1) {
       		  	fscanf(fpout,"%f %i %i %i %i %f", &tau,&wv,&sz,&vz,&ra,&radiance);

		  	if ((tau != (float)tauind*0.5) || (wv !=lambda) || (sz !=isz) || (vz !=ivz) || (ra !=ira)) {
				printf("\nError - input sky diffuse file does not match\n");
       				exit(0);
		 	 }
		  }
		  else { 
		  	radiance = n_steven*norm_steven;
		  }
		  iwv=lambda/400-1;isz2=isz/10;ivz2=ivz/10;ira2=ira/10;
		  SKY_ARRAY[tauind][iwv][isz2][ivz2][ira2]=radiance;
		}
	      }
	      
	      if (use_lut==1) {
	         
		 /* Normalise for given Solar angle, wavelength and tau such that projection of radiance onto horizontal plane=1.*/
	         AER_OPT=tau;SOLAR_AZIMUTH=0.0;SOLAR_ZENITH=(float)sz;fac=0.0;

	         for(i=0;i<10000;i++){
			vec=rand_norm_vec_up(vec);
			fac+=cos(vec->theta)*calculate_sky_diff_irrad(wv,vec->theta,vec->phi);
	         }
	         nfac=2.0*fac/10000.0;
	         for (ivz=0; ivz<=90; ivz+=10)  {
       	        	for (ira=0; ira<=180; ira+=10)  {
		  	     ivz2=ivz/10;ira2=ira/10;

		 	     SKY_ARRAY[tauind][iwv][isz2][ivz2][ira2]=SKY_ARRAY[tauind][iwv][isz2][ivz2][ira2]/nfac;
		  
			}
                 }
	       
	       }      /*  LUT active  */
	      	       	           
	     }  /* solar zenith */
	     
	   }  /* lambda */	  	   

	} /* optical depth */
	 
        SOLAR_AZIMUTH=tsa;SOLAR_ZENITH=tsz;AER_OPT=taopt;

	fclose(fpout);
}


/* --------------- ----------- ---------------- --------------- ----------------- ------------------ ----- */


read_reverse_data()
/*	read data from "reverse.data" describing extra info on image size, PRI and photosysnthesis model */

{

	FILE *fps;

	fps=fopen("reverse.data","r"); 
	fscanf(fps, "%d",&BOUNCE_THRESHOLD);
	fscanf(fps, "%d",&BRANCH_NO);
	fscanf(fps, "%d",&IM_SIZE);
	fscanf(fps, "%d",&N_LUE_SAMPLES);
	fscanf(fps, "%d",&PRI_BAND_NO);
	fscanf(fps, "%d",&PRI_REFER_BAND_NO);
	fscanf(fps, "%f",&PAR_RAD);
	fscanf(fps, "%f",&IR_RAD);
	fscanf(fps, "%f",&KM);
	fscanf(fps, "%f",&PMAX);
	fclose(fps);

/*	Check/set defaults */
	if (BRANCH_NO<1) BRANCH_NO=1;
	if (IM_SIZE<1) IM_SIZE=100;

}



struct point *reverse_vec(vec)
	struct point *vec;
/*	Creates vector in the opposite direction of vec */
{
	struct point *new_vec;
	new_vec=mkpoint(-1.0*vec->x,-1.0*vec->y,-1.0*vec->z);
	new_vec->theta=PI-vec->theta;
	new_vec->phi=PI-vec->phi;
	return(new_vec);

}

find_maxval_lad()
{
	int i;
	MAXVAL_LAD=0.0;
	for (i=1;i<10;i++) if (LAD[i]>MAXVAL_LAD) MAXVAL_LAD=LAD[i];
}

struct point *find_leaf_orientation(vec)
	struct point *vec;
/* Generate sample leaf orientation, given we intersect within a canopy defined by 
	zenith leaf angle distribution LAD, from a direction vec. 
*/  



{
	int i,flag;
	float theta_s,phi_s,p,r,theta_l,phi_l,cosg;
	struct point *leaf_normal;

	leaf_normal=mkpoint(0.0,0.0,0.0);
	flag=0;
	while (flag==0)  {
		i=0;
		while ((i<1) || (i>9)) i=1+(int)(rand()*RAND_MULT*9.0);
		/* theta_l=degtorad(ANGLES[i]); */
		 theta_l=degtorad(ANGLES[i]-5.0+10.0*rand()*RAND_MULT); 
		
		phi_l=rand()*RAND_MULT*2.0*PI;

		r=sin(theta_l);

		leaf_normal->x=r*cos(phi_l);
		leaf_normal->y=r*sin(phi_l);
		leaf_normal->z=cos(theta_l);	

		cosg=dot(leaf_normal,vec);
		p=LAD[i]*absfn(cosg);

		r=rand()*RAND_MULT*MAXVAL_LAD;

		if (r<p) flag=1;	
	}

/* 	Ensure leaf normal faces incoming direction */

	if (cosg<0.0) {
		leaf_normal->theta=theta_l;
		leaf_normal->phi=phi_l;
	} else {
		leaf_normal->theta=PI-theta_l;
		leaf_normal->phi=PI-phi_l;
		if (leaf_normal->phi <0) leaf_normal->phi+=2*PI;
		leaf_normal->x=-leaf_normal->x;
		leaf_normal->y=-leaf_normal->y;
		leaf_normal->z=-leaf_normal->z;
	}

 	return leaf_normal;
}

int oned_find_intersection(stand,pos,vec,vec_old,bounce_no,npos) 
	struct stand *stand;
	struct point *pos,*vec,*vec_old,*npos;
	int bounce_no;

/*	Finds intersection point from pos in direction vec in a 1D canopy. Returns new position in 
	npos, and type of new material in variable type. If bounce_no=1 then uses vec_old to compute
	a hotspot function.

	NB - here type is only sky, ground or leaf. Should be changed to allow different leaf types.
*/
{

	float dist_to_bound2,dist_to_bound,phase_angle,tau_multiplier,ray_zenith_angle,prob,tau_val,
		dist_before_collision;
	int index,outflag,type;




/*		Distance to soil boundary 		*/

		if (vec->z<0.0) {
	 
			dist_to_bound2=-1.0*pos->z/vec->z ;
		}
		else dist_to_bound2=1e6;

/*		Distance to top of canopy  boundary 		*/

		dist_to_bound=(TOP_ONED-pos->z)/vec->z;


		if ((bounce_no==1) && (LF_SIZE>0.0) && (dist_to_bound>0.0)){
			phase_angle=PI-acos(dot(vec,vec_old));
			
			
			/* printf("pz: %f vt: %f vot: %f ab: %f c: %f\n",
			TOP_ONED-pos->z,vec->theta,vec_old->theta, 
			   0.5*(vec->theta+PI-vec_old->theta), 
			   cos(0.5*(vec->theta+PI-vec_old->theta))); */
				tau_multiplier=hot_spot_fn(phase_angle,(TOP_ONED-pos->z)/cos(0.5*(vec->theta+PI-vec_old->theta)));
			if (tau_multiplier<0.0001) tau_multiplier=0.0001;
		}

		else tau_multiplier=1.0;


/*		Calculate sample photon path length through medium */
		ray_zenith_angle=vec->theta*RDEG;
		if (ray_zenith_angle > 90.0) ray_zenith_angle=(180.0-ray_zenith_angle);
		index=(int)(ray_zenith_angle); 
		tau_val=tau_multiplier*(stand->lai)*EXTINCTION_COEF_ARRAY[index];
	
		prob=rand()*RAND_MULT;
		if (prob <= 0.0) prob=0.0001;
		dist_before_collision=-(log(prob)/tau_val);


/*		Now find out if reach boundary	*/

		if ((dist_to_bound < dist_before_collision) && (dist_to_bound >0.0)) {
			/* reach sky boundary */
			outflag=1;
			type=SKY_PLANE_NUMBER;
		}

		else if (dist_to_bound2 < dist_before_collision) {
			/* soil boundary */
			npos->z=0.001;
			type=GROUND_PLANE_NUMBER;
			}
		else {
			/* hit another leaf */
			npos->z=pos->z+dist_before_collision*vec->z;
			type=LEAF_NUMBER;
		}


	return type;
}




light_incident_on_facet(stand,pos,ftype,facet_norm,vec_old,bounce_no,radsum,radsum2)
	struct stand *stand;
	struct point *pos,*facet_norm,*vec_old;
	int ftype,bounce_no;
	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
{
/* 	Calculates  total light incident on facet of type ftype at location pos with normal facet_norm.  
	NB - calculates incident on upper side of facet in radsum, and on reverse side in radsum2
	 (given by direction of facet-norm). Only calculates radsum 2 if not soil.
	Result for waveband i is returned in array radsum[bounce_no][i].

	Ground and sky reflectances are modelled as isotropic, and leaf reflectance as bi-Lambertian.
*/

	float fac,intfac,sky_fac;
	struct point *npos, *vec, *lnew;
	int type,i,j,m;

	/* Sample higher orders more sparsely in proportional to expected intensity */

	if (bounce_no==1) m=BRANCH_NO; else m=1;

	npos=mkpoint(0.0,0.0,0.0);
	vec=mkpoint(0.0,0.0,0.0);

	for (i=0;i<NO_WVBANDS;i++) { radsum[i][bounce_no]=0.0;radsum2[i][bounce_no]=0.0; }

	/* First direct light (if present): is facet illuminated? */

	if (SOLAR_ZENITH >= 0.0) {
		 set_up_vec(vec);
		type=oned_find_intersection(stand,pos,vec,vec_old,bounce_no,npos);

		if (type==SKY_PLANE_NUMBER) {
		  	fac=dot(vec,facet_norm);

			for (i=0;i<NO_WVBANDS;i++) {
				 if (fac >0.0) {
					radsum[i][bounce_no]=SOLAR_RAD[i]*fac;
				 } else radsum2[i][bounce_no]=-1.0*SOLAR_RAD[i]*fac;
			}
		}
		 else {
		 	if (bounce_no==1) COMPNO++; 
		}
	} else if (bounce_no==1) COMPNO++;
	


/*	Now sample diffuse light, if within scattering order threshold.

	Sampling density of diffuse field (m) is reduced with scattering order.
	Due to cut off point, there will be some higher order scattered flux unaccounted for. The scattering
	order should be chosen so this is small, and a value could potentially be approximated for the remaining
	flux.  
 */

	if (bounce_no < BOUNCE_THRESHOLD) {

		for (j=0;j<m;j++) {

			/* Trace each of m rays in new (random) directions */

			if (ftype==GROUND_PLANE_NUMBER) {
				vec=rand_norm_vec_up(vec); intfac=4.0*PI;
			} else { 
				 vec=rand_norm_vec(vec); intfac=8.0*PI; 
			}

			fac=dot(vec,facet_norm);   
	
			/* Find where new rays hits */

			type=oned_find_intersection(stand,pos,vec,vec_old,bounce_no,npos);
		
			/* Add appropriate randiance value scaled by projection onto facet (fac) */

			if (type==SKY_PLANE_NUMBER) {
				if (SKY_MODEL) sky_fac=calculate_sky_diff_irrad(WAVELENGTH[i],vec->theta,vec->phi); else
				 	sky_fac=1.0;
				for (i=0;i<NO_WVBANDS;i++) {
					if (fac>0.0) {
						radsum[i][bounce_no+1]=sky_fac*SKY_RAD[i]/(2*PI);
						radsum[i][bounce_no]+=
							((intfac*0.5)/((float)m))*radsum[i][bounce_no+1]*(fac/cos(vec->theta));
						
					}
					else {
						radsum2[i][bounce_no+1]=SKY_RAD[i]/(2*PI);
						radsum2[i][bounce_no]+=
							((-intfac*0.5)/((float)m))*radsum2[i][bounce_no+1]*(fac/cos(vec->theta));
					}
				}
			}

			/* If ground or new leaf then use recursion to evaluate light incident on this */

			 else if (type==GROUND_PLANE_NUMBER) {
				light_incident_on_facet(stand,npos,type,GROUND_NORM,vec,bounce_no+1,radsum,radsum2);
				for (i=0;i<NO_WVBANDS;i++) {
					if (fac>0.0) radsum[i][bounce_no]+=(intfac/((float)m))*radsum[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
					else radsum2[i][bounce_no]+=(-intfac/((float)m))*radsum2[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
				}
			}
			else {
				/* Calculate light incident on each side of leaf seperately. Use RHO and TAU here 
					 for speed in diffuse calculation rather than dynamic function. */

				lnew=find_leaf_orientation(vec);


				light_incident_on_facet(stand,npos,type,lnew,vec,bounce_no+1,radsum,radsum2);

				for (i=0;i<NO_WVBANDS;i++)
					if (fac>0.0) 
 						radsum[i][bounce_no]+=
							(intfac/((float)m))*(radsum[i][bounce_no+1]*RHO[i]+radsum2[i][bounce_no+1]*TAU[i])*fac/(2*PI);
					else 
			 			radsum2[i][bounce_no]+=
							(-intfac/((float)m))*(radsum[i][bounce_no+1]*RHO[i]+radsum2[i][bounce_no+1]*TAU[i])*fac/(2*PI);
					
				free(lnew);
			}

		}
	}
	free(npos);free(vec);
 
}

float par_fn(spectrum)
	float spectrum[MAX_NO_WVBANDS];
/* Integrates over PAR spectral region */
{
	int i;
	float 	tot_par;
	tot_par=0.0;
	for (i=0;i<NO_WVBANDS;i++)
		if ((WAVELENGTH[i]>=400) && (WAVELENGTH[i]<=700) && (i!=PRI_BAND_NO)  )tot_par+=spectrum[i];
	return tot_par;
}
	
		
float PRIFN(stand,radsum,radsum2,bounce_no)

	struct stand *stand;
	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	int bounce_no;

/*	 Calculates reflectance/transmittance of PRI_BAND_NO (531nm) based on PRI_REFER_BAND_NO (570nm)
	 and total incoming PAR flux on leaf.
*/
	{
	float QL,lue,ref;
	int i;
	float tot_incident_flux[MAX_NO_WVBANDS];
	for (i=0;i<NO_WVBANDS;i++) tot_incident_flux[i]=radsum[i][bounce_no]+radsum2[i][bounce_no];
	QL=par_fn(tot_incident_flux);	
	lue=PMAX/(KM+QL);
	/* ref=RHO[PRI_REFER_BAND_NO]*(5900.0*lue+31.0)/(4100.0*lue+49.0); */
	ref=RHO[PRI_REFER_BAND_NO]*(12083.3*lue+9.0)/(8750.0*lue+41.0);
	return ref;
}


float leaf_reflectance_function(stand,radsum,radsum2,band_no,bounce_no)

/* 	Determines leaf spectral reflectance based on total incident light field. 
Allows calculation for PRI study */

	struct stand *stand; 

	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	int bounce_no,band_no;
{
	float ref;
	if (band_no != PRI_BAND_NO) 
	ref=RHO[band_no];
	else ref=PRIFN(stand,radsum,radsum2,bounce_no);
	return ref;
}


float leaf_transmittance_function(stand,radsum,radsum2,band_no,bounce_no)

/* 	Determines leaf spectral transmittance based on total incident light field.  */


	struct stand *stand;
	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	int bounce_no,band_no;
{
	float tr;
	if (band_no != PRI_BAND_NO) tr=TAU[band_no];
	else tr=TAU[PRI_REFER_BAND_NO]*PRIFN(stand,radsum,radsum2,bounce_no)/RHO[PRI_REFER_BAND_NO];
	return tr;
}



struct point *random_leaf_normal()
{
/* Constructs vector of a random leaf normal, based on leaf angle distribution LAD */

	int flag,i;
	float theta_l,phi_l,r;
	struct point *leaf_normal;
	leaf_normal=mkpoint(0.0,0.0,0.0);
	flag=0;
	while (flag==0)  {
		i=0;
		while ((i<1) || (i>9)) i=1+(int)(rand()*RAND_MULT*9.0);
		r=rand()*RAND_MULT*MAXVAL_LAD;
		if (r<LAD[i]) flag=1;	
	}
		theta_l=degtorad(ANGLES[i]-5.0+10.0*rand()*RAND_MULT); 
		phi_l=rand()*RAND_MULT*2.0*PI;
		r=sin(theta_l);

		leaf_normal->x=r*cos(phi_l);
		leaf_normal->y=r*sin(phi_l);
		leaf_normal->z=cos(theta_l);	
		leaf_normal->theta=theta_l;
		leaf_normal->phi=phi_l;

	return leaf_normal;
}



read_struct_data_photosyn()


/*	read data from "in_flight_photosyn.data" for photosynthetic properties */

{	 

	FILE *fps_photosyn;

	fps_photosyn=fopen("in_flight_photosyn.data","r");
	fscanf(fps_photosyn, "%f",&ALPHA);
	fscanf(fps_photosyn, "%f",&VCMAX);
	fscanf(fps_photosyn, "%f",&K_RUB);
	fscanf(fps_photosyn, "%f",&T_DOWN);
	fscanf(fps_photosyn, "%f",&T_UP);
	fscanf(fps_photosyn, "%f",&FDIF);
	 
	fclose(fps_photosyn);
	 
}





float leaf_photosynthesis_fn(incident_flux)
	float incident_flux[MAX_NO_WVBANDS];
/* Simple estimate of leaf photosynthetic rate (umol C m-2 s-1) based on total incident PPFD. NB this is based
	on incident rather than absorbed PAR */
{
	float QL,P;

	/* KM=200.0; PMAX=10.0; These are read in input file*/
	QL=par_fn(incident_flux);
	
	P=QL*PMAX/(KM+QL);
	return P;
}

float leaf_photosynthesis_moses(incident_flux,t_leaf,z,lai,ci)

 /* Estimate of leaf photosynthetic rate (umol C m-2 s-1) based on Collatz model in MOSES */
     
	float 	incident_flux[MAX_NO_WVBANDS];
	float 	t_leaf, z, lai, ci;
{
	float 	oa, vcmax, fdc3, conv, tau, ccp, q10_leaf, rd, fsmc, dq, dqcrit, ca;
	float 	tlow, tupp, alpha, fwe_c3, fo, tdegc, qtenf, denom, vcm, ko, kc;
	float 	wcarb, wlite, wexpt, b1, b2, b3, wp, wl, incident_flux_total, kpar_p, kpar;
	float 	al=0.0;
	
	incident_flux_total = par_fn(incident_flux);
	
/*	incident_flux_total = 1500*0.5*exp(lai*0.5*((z-TOP_ONED)/TOP_ONED));*/
	
	if ( incident_flux_total < 0.0 ) incident_flux_total = 0.0; 

	fsmc = 1.0;		     /* water factor  */
	oa = 20800;		     /* atmospheric O2 pressure (Pa) - mean value in MOSES for Siberia site */
	ca = 34.5;                   /* canopy CO2 pressure (Pa) - mean value in MOSES for Siberia site */
	fdc3 = 0.015;                /* dark resp coefficent for C3 - source MOSES */
	fwe_c3 = 0.5;                /* coefficient for export of products - source MOSES */
	fo     = 0.85;		     /* ci/ca for dq=0  - source MOSES */
	q10_leaf = 2.0;
	tdegc = t_leaf - 273.3;      /* leaf temp in deg C  */
	kpar   = 0.75;	             /* extinction coefficient for light */	   	    

  	tlow  = T_DOWN;
	tupp  = T_UP;		     /* lower and upper temps for RUBISCO chemical activity */
	kpar_p = K_RUB;		     /* extinction coefficient for rubisco */
	vcmax = VCMAX;		     /* rate when light-saturated (umol/m2/s) */
	alpha = ALPHA;		     /* quantum efficiency */
	
        /*  Distribute Rubisco as exponential fall-off in light intensity. Normalise for vcmax if necessary */ 	  
	if (ONED_FLAG==1) {
		vcmax = vcmax * exp( lai*kpar_p*(z-TOP_ONED)/TOP_ONED );
/*		vcmax = ((lai*kpar_p)/(lai*kpar)) * vcmax * (1-exp(-1*lai*kpar))/(1-exp(-1*lai*kpar_p)); */ }
	else  {
		vcmax = vcmax * exp( lai*kpar_p*(z-CANOPY_TOP)/(CANOPY_TOP*(1.0-(MIN_GREEN_HEIGHT/100.0))) );
/*		vcmax = ((lai*kpar_p)/(lai*kpar)) * vcmax * (1-exp(-1*lai*kpar))/(1-exp(-1*lai*kpar_p)); */ 
	}
 
	tau = 2600.0 * (  pow(0.57,(0.1*(tdegc-25.0)))  );
	ccp = 0.5 * oa / tau;
	qtenf = vcmax * (  pow(q10_leaf,(0.1*(tdegc-25.0)))  );
	denom = ( 1 + exp(0.3*(tdegc-tupp)) ) * ( 1 + exp(0.3*(tlow-tdegc)) );
	vcm = qtenf / denom;
	rd = fdc3 * vcm;
	
/*	ci = ccp + (  (ca - ccp) * fo * ( 1.0 - dq_ratio )  );*/     		 /* calculate internal CO2 concentration */
    	 
	kc = 30.0 * (  pow(2.1,( 0.1*(tdegc-25.0)))  );          		 /* calculate compensatory points for CO2 and O2 */
	ko = 30000.0 * (  pow(1.2,(0.1*(tdegc-25.0)))  );
	
	wcarb = vcm * (  (ci-ccp)/( ci+kc*(1.0+oa/ko) )  );			 /* RUBISCO-limited photo */
	wlite = alpha * ( incident_flux_total * (ci-ccp)/(ci+(2*ccp)) );         /* light-limited photo */
	wexpt = fwe_c3 * vcm;							 /* export-limited photo */
	
	b1 = 0.83;						   		 /* co-limited rate of photosynthesis */
	b2 = -1.0 * ( wcarb + wlite );				   		 /* smoothing constants from MOSES */
	b3 = wcarb * wlite;
	wp = (-1.0*b2)/(2*b1)  -  pow( ( ((b2*b2)/(4*b1*b1))-(b3/b1) ), 0.5 );
	b1 = 0.93;  

	b2 = -1.0 * ( wp + wexpt ); 

	b3 = wp * wexpt;
	wl = (-1.0*b2)/(2*b1)  -  pow( ( ((b2*b2)/(4*b1*b1))-(b3/b1) ), 0.5 );

	al = ( wl - rd ) * fsmc;
  
        /*if (wcarb<wlite) al=wcarb; else al=wlite;*/
        /*printf("%f  %f %f %f  %f %f %f %f\n", (z/TOP_ONED), wcarb, wlite, wexpt, wp, wl, rd, al); */
	/* printf("%f %f %f %f \n", (z/CANOPY_TOP), incident_flux_total, al, vcmax); */
	
	return al;
}




facet_radiance(stand,pos,facet_norm,vec,type,radsum,radsum2)

/* 	Calculates radiance from facet of type 'type', at position 'pos', with normal 'facet_norm'.
	Returns spectrum in radsum[0][*]
	Radsum[1][*] holds incident light flux on upper side of facet, 
*/
	struct stand *stand;
	struct point *pos, *facet_norm,*vec;
	int type;
	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];

{
	float  lf, tr;
	int i;


	if (type==GROUND_PLANE_NUMBER) {
		light_incident_on_facet(stand,pos,type,facet_norm,vec,1,radsum,radsum2);
		for (i=0;i<NO_WVBANDS;i++) radsum[i][0]=radsum[i][1]*GROUND_REFLECTANCE[i];
	}
	else {
		light_incident_on_facet(stand,pos,type,facet_norm,vec,1,radsum,radsum2);
	
		for (i=0;i<NO_WVBANDS;i++) {
			lf=leaf_reflectance_function(stand,radsum,radsum2,i,1);
			tr=leaf_transmittance_function(stand,radsum,radsum2,i,1);

			radsum[i][0]=radsum[i][1]*lf+radsum2[i][1]*tr; 
		}

	}
}

		
struct photon *find_reflectance(in_stand,in_photon)

	struct stand *in_stand;
	struct photon *in_photon;	
{
	/* takes 'photon' - defining view location and directionm, and returns reflectance, given by radiance 
	in view direction divided by total downwelling radiance */ 

	struct point *facet_norm, *vec_old, *npos;
	double radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	int type,i;



	vec_old=mkpoint(0.0,0.0,0.0);
	npos=mkpoint(0.0,0.0,0.0);
	type=oned_find_intersection(in_stand,find_reflectance,in_photon->vec,vec_old,0,npos);


	if (type!=GROUND_PLANE_NUMBER) {
		facet_norm=find_leaf_orientation(in_photon->vec);
		COMPNO=2;
	}
	else {
		facet_norm=mkpoint(GROUND_NORM->x,GROUND_NORM->y,GROUND_NORM->z);
			facet_norm->theta=GROUND_NORM->theta;facet_norm->phi=GROUND_NORM->phi;
		COMPNO=0;
	}
	facet_radiance(in_stand,npos,facet_norm,in_photon->vec,type,radsum,radsum2);
	/* reflectance is be given by radiance/incoming_flux */



	for (i=0;i<NO_WVBANDS;i++) in_photon->intensity[i]=radsum[i][0]/(cos(degtorad(SOLAR_ZENITH))*SOLAR_RAD[i]+SKY_RAD[i]);

	free(facet_norm); free(vec_old); free(npos);
	return in_photon;
}


/* --------------- ----------- ---------------- --------------- ----------------- ------------------ ----- */


	



struct threed_data *threed_data_alloc()
{
	return (struct threed_data *) malloc(sizeof(struct threed_data));
}


/* prototype fn*/
struct threed_data *threed_find_intersection(int old_stand_no,struct point *pos,struct point *vec,struct point *vec_old,int bounce_no,int INSIDE_STAND);
	

struct point *trunk_norm(stand,pos)
	struct stand *stand;
	struct point *pos;
{
	float tanphi,xval,yval,xsq,ysq,zsq;
	struct point *facet_norm;
	
			tanphi=tan(PI*0.5-atan(sqrt(stand->cone2->tansqphi)));
			xval=(pos->x-stand->cone2->apex->x);
			yval=(pos->y-stand->cone2->apex->y);
			xsq=xval*xval;
			ysq=yval*yval;
			zsq=(xsq+ysq)/(tanphi*tanphi);
			facet_norm=mkpoint(xval,yval,sqrt(zsq));
			facet_norm->theta=acos(facet_norm->z);facet_norm->phi=acos(sqrt(xsq/(xsq+ysq)));
	return facet_norm;
}

struct threed_data *threed_find_intersection_canopy(stand_no,pos,vec,vec_old,bounce_no)

	struct point *pos,*vec,*vec_old;
	int bounce_no,stand_no;
	
/*	Finds collision of photon within a canopy boundary, or continues trajectory externally by mutual recursion with threed_find_intersection.
*/

{
	struct distandpoint *dp;
	struct threed_data *res;
	struct photon *photon;

	float prob,tau_val,dist_before_collision;
	float ray_zenith_angle,dist_to_facet,tmp1;
	float dist_to_bound,tau_multiplier,phase_angle,dist_to_bound2,dist_to_ground,a1,a2;
	int outflag,index,flag,trunkflag,i,new_stand,INSIDE_STAND;
	float ph_intensity[MAX_NO_WVBANDS];  
	 /* FILE *FPDEBUG; */
	/* FPDEBUG=fopen("RESULTS/DEBUG","a"); */
	/* fprintf(FPDEBUG,"3d_fint_c "); */
	/* fprintf(FPDEBUG,"px: %f py: %f pz: %f vx: %f vy: %f vz: %f bn: %d\n",pos->x,pos->y,pos->z,vec->x,vec->y,vec->z,bounce_no); 

	fflush(FPDEBUG); */
	
	INSIDE_STAND=1;  /* Flag to state within crown until specified otherwise */

	dist_to_facet=1e20;
	dp=dpalloc();
	dp->point=ptalloc();
	flag=1;
	tau_multiplier=1.0;
	outflag=0;		

/* First calculate distance to boundaries: edge of canopy envelope, faceted objects (if present), ground boundary */

		if (STANDS[stand_no]->crown_shape=='c') 
			dist_to_bound=coneintersect_from_in(pos,vec,STANDS[stand_no]->cone,flag) ;
			else dist_to_bound=ellipse_intersect_from_in(pos,vec,STANDS[stand_no]->ellipse);

 		flag=0;
		/* printf("canopy, dtb; %f\n",dist_to_bound); */
		/* if (TRUNK_PRES) dist_to_bound2=coneintersect_from_out(pos,vec,STANDS[stand_no]->cone2,dist_to_bound); */

		dp=intersect(pos,vec,GROUND_PLANE,dp);
		dist_to_ground=dp->r;
		if (FACET_FLAG) {
			tmp1=find_facet(pos,vec,stand_no,dp);
			dist_to_facet=dp->r;
		}
		
		
		
/* Now estimate leaf hotspot effect on extinction coefficient */

		if ((bounce_no==1) && (LF_SIZE>0.0) && (dist_to_bound>0.0)){
			phase_angle=PI-acos(dot(vec_old,vec));
			tau_multiplier=hot_spot_fn(phase_angle,dist_to_bound*cos(phase_angle));
			if (tau_multiplier<0.0001) tau_multiplier=0.0001;
		}

		else tau_multiplier=1.0;
		
/* Find distance before collision with foliage */

		ray_zenith_angle=vec->theta*RDEG;
		if (ray_zenith_angle > 90.0) ray_zenith_angle=(180.0-ray_zenith_angle);
		index=(int)(ray_zenith_angle); 
		tau_val=tau_multiplier*(STANDS[stand_no]->lai)*EXTINCTION_COEF_ARRAY[index];
		prob=rand()*RAND_MULT;
		if (prob <= 0.0) prob=0.0001;
		dist_before_collision=-(log(prob)/tau_val);
		
/* Return closest of these as collision point. Some approximations to avoid photons 'trapped' due to rounding errors */

		/* if ((TRUNKFLAG==1) && (dist_to_bound2 < dist_before_collision) && (dist_to_bound2 < dist_to_ground)) {
			res=threed_data_alloc();
			res->x=pos->x+(dist_to_bound2)*(vec->x)*0.95;
			res->y=pos->y+(dist_to_bound2)*(vec->y)*0.95;
			res->z=pos->z+(dist_to_bound2)*(vec->z)*0.95;
			res->type=TRUNK_NUMBER;
			res->stno=stand_no;
			TRUNKFLAG=0;
		} */
	
		if ((dist_before_collision > dist_to_ground) && (dist_to_bound > dist_to_ground) && (dist_to_facet > dist_to_ground)) {
			/* canopy envelope has ground as lower boundary */
			 /* FPDEBUG=fopen("RESULTS/DEBUG","a");fprintf(FPDEBUG,"stno: %d z: %f vz: %f dbc: %f dtb: %f dtg: %f \n",
			 stand_no,pos->z,vec->z,dist_before_collision,dist_to_bound,dist_to_ground); fflush(FPDEBUG); 
 fclose(FPDEBUG); 			*/
			res=threed_data_alloc();
			res->x=(dp->point)->x;
			res->y=(dp->point)->y;
			res->z=(dp->point)->z;
			res->type=GROUND_PLANE_NUMBER;
			res->stno=stand_no;
		}

		else if ((dist_to_bound > dist_before_collision ) && (dist_to_facet > dist_before_collision)) {
			res=threed_data_alloc();
			res->x=pos->x+dist_before_collision*vec->x;
			res->y=pos->y+dist_before_collision*vec->y;
			res->z=pos->z+dist_before_collision*vec->z;
			res->stno=stand_no;

		/* Determine which component within crown */
			a1=1.0-FRAC_SEN-FRAC_BARK;a2=1.0-FRAC_BARK;	
			prob=rand()*RAND_MULT;
			if (prob<a1) res->type=LEAF_NUMBER;
			else if (prob<a2) res->type=SEN_NUMBER;
			else res->type=BARK_NUMBER;	
		} 
		
		else if (dist_to_bound  > dist_to_facet) {
			res=threed_data_alloc();
			res->x=pos->x+dist_to_facet*vec->x;
			res->y=pos->y+dist_to_facet*vec->y;
			res->z=pos->z+dist_to_facet*vec->z;
			res->stno=tmp1;
			res->type=FACET_NUMBER;

/* If no intersection then continue search from outside envelope. First we check if we are in another crown (due to overlap between two crowns or between crown and the boundary. */

		} else {
		 photon=mkphoton(mkpoint(pos->x+(dist_to_bound)*(vec->x)*1.01,pos->y+(dist_to_bound)*(vec->y)*1.01,pos->z+(dist_to_bound)*(vec->z)*1.01),mkpoint(vec->x,vec->y,vec->z),ph_intensity); 
		
			
			new_stand=replace_if_out(photon);
			/* fprintf(FPDEBUG,"New stand [1]: %d ",new_stand);  fflush(FPDEBUG); */

			if (new_stand<0) new_stand=inside(photon,stand_no);
			 /* fprintf(FPDEBUG,"New stand [2]: %d stno: %d\n",new_stand,stand_no); fflush(FPDEBUG); */
			
			if ((new_stand>0) && (new_stand!=stand_no)) {
				 	res=threed_find_intersection_canopy(new_stand,photon->pos,vec,vec_old,bounce_no);
			/* FPDEBUG=fopen("RESULTS/DEBUG","a");fprintf(FPDEBUG,"New stand [2]: %d stno: %d\n",new_stand,stand_no); fflush(FPDEBUG); fclose(FPDEBUG); */

					}
			
			else {
				INSIDE_STAND=0;
				res=threed_find_intersection(stand_no,photon->pos,vec,vec_old,bounce_no,INSIDE_STAND);
			}
			free(photon->pos);free(photon->vec); free(photon);

		}
	 /* fprintf(FPDEBUG,"exit 3d_find_c\n"); fflush(FPDEBUG); */
	free(dp->point);
	free(dp);
	/* free(photon); */
	/* fclose(FPDEBUG); */

	return res;
}






struct threed_data *threed_find_intersection(old_stand_no,pos,vec,vec_old,bounce_no,INSIDE_STAND)
	struct point *pos,*vec,*vec_old;
	int bounce_no,old_stand_no,INSIDE_STAND;

/*	Finds intersection point from pos in direction vec in a 3D canopy. Returns new position in 
	npos, and type of new material (e.g. sky, ground, leaf) in variable type. If bounce_no=1 then uses vec_old to compute
	a hotspot function.
	
	Calls 'trace' to find object of intersection in photon path, then calls appropriate routine to find intersection within that object. 

	old_stand_no - previous stand; should be external to a crown otherwise call should be to threed_find_intersection_canopy
*/


{
	
	int outflag,stand_number=SKY_PLANE_NUMBER,new_stand,wno=-1,i,inflag=0;
	float dist_to_bound;
	struct standpoint *first_interaction;
	struct threed_data *res;
	struct photon *photon;
	float ph_intensity[MAX_NO_WVBANDS];  

	/* FILE *FPDEBUG;
	FPDEBUG=fopen("RESULTS/DEBUG","a"); */
	 /* printf("3df_int os: %d pz: %f vz: %f  voz: %f bn: %d IS: %d \n",old_stand_no,pos->z,vec->z,vec_old->z,bounce_no,INSIDE_STAND); 

	fflush(NULL); */

	outflag=0;wno=-1;
	first_interaction=mkstandpoint(0,mkpoint(0.0,0.0,0.0));

	photon=mkphoton(mkpoint(pos->x,pos->y,pos->z),mkpoint(vec->x,vec->y,vec->z),ph_intensity);
	photon->vec->theta=vec->theta;photon->vec->phi=vec->phi;
	
	if (INSIDE_STAND==1) {
		stand_number=old_stand_no;
		res=threed_find_intersection_canopy(old_stand_no,pos,
			vec,vec_old,bounce_no);
		outflag=1; 
	} else {
	
		while (outflag<1) {
 

		
		/* if previously met boundary, check if now inside a crown due to potential overlap on opposite boundary wall */

			  inflag=0;
			  if (wno>=0) {
				i=0;
			
				while ((inflag==0) && (NOSTANDS>0) && (WLIST[wno][i]>=0) ) {
					if (inside_stand(photon->pos,WLIST[wno][i])>0)
					{
						stand_number=WLIST[wno][i];
						inflag=1;
					}
				i++;
				}
			  }
			  if (inflag==1) {
				old_stand_no=stand_number;
				res=threed_find_intersection_canopy(old_stand_no,photon->pos,photon->vec,vec_old,
						bounce_no);
					outflag=1;
					break;		
			  }
				
		/* otherwise, continue tracing path */		

			trace(photon,first_interaction,old_stand_no); 
			stand_number=first_interaction->standno;
			old_stand_no=stand_number;

			wno=-1;
			/* fprintf(FPDEBUG,"	st_no: %d \n", stand_number);  fflush(FPDEBUG); */
			switch(stand_number) {

			  case SKY_PLANE_NUMBER: 	outflag=1;
			  		res=threed_data_alloc();

					res->x=first_interaction->point->x;
					res->y=first_interaction->point->y;
					res->z=first_interaction->point->z;
					res->type=SKY_PLANE_NUMBER;
					res->stno=SKY_PLANE_NUMBER;
					break;
			  case GROUND_PLANE_NUMBER: 
			  		res=threed_data_alloc();
					outflag=1;
					res->x=first_interaction->point->x;
					res->y=first_interaction->point->y;
					res->z=first_interaction->point->z;
					res->type=GROUND_PLANE_NUMBER;
					res->stno=GROUND_PLANE_NUMBER;

					break;
			  case WALL1_NUMBER:
			 		photon->pos->x=-1*X_DIM+0.0001;
					photon->pos->y=first_interaction->point->y;
					photon->pos->z=first_interaction->point->z;
					wno=1;
					break;

			  case WALL2_NUMBER: 
					photon->pos->x=X_DIM-0.0001;
					photon->pos->y=first_interaction->point->y;
					photon->pos->z=first_interaction->point->z;
					wno=0;
					break;

			  case WALL3_NUMBER: 
					photon->pos->x=first_interaction->point->x;
					photon->pos->y=Y_DIM-0.0001;
					photon->pos->z=first_interaction->point->z;
					wno=3; 
					break;

			  case WALL4_NUMBER: 
					photon->pos->x=first_interaction->point->x;
					photon->pos->y=-1*Y_DIM+0.0001;
					photon->pos->z=first_interaction->point->z;
					wno=2;
					break;	
			  default: {
				if (TRUNKFLAG==1) {
					res=threed_data_alloc();
					outflag=1;
					res->x=first_interaction->point->x;
					res->y=first_interaction->point->y;
					res->z=first_interaction->point->z;
					res->type=TRUNK_NUMBER;
					TRUNKFLAG=0;
					res->stno=stand_number;
					break;		
				}
				else if (stand_number >= MAX_NOSTANDS) {
					res=threed_data_alloc();
					outflag=1;
					res->x=first_interaction->point->x;
					res->y=first_interaction->point->y;
					res->z=first_interaction->point->z;
					res->type=FACET_NUMBER;
					res->stno=stand_number;
					if (dot(photon->vec,FACET[stand_number-MAX_NOSTANDS]->fnormal) >0) vreverse (FACET[stand_number-MAX_NOSTANDS]->fnormal);				
					break;		

				}
				else { 
					old_stand_no=stand_number;
				res=threed_find_intersection_canopy(old_stand_no,first_interaction->point,photon->vec,vec_old,
						bounce_no);
					outflag=1;
					break;		
				}
			  }

				
			   	
			}
		}
	}
		
	free(first_interaction->point);
	free(first_interaction);
	free(photon->pos);
	free(photon->vec);
	free(photon);
	 /* printf("exit 3df_int os res-t: %d x: %f y; %f z; %f st: %d \n", res->type,res->x,res->y,res->z,res->stno); fflush(NULL); */
	/* fclose(FPDEBUG); */

	return res;
}



void	threed_light_incident_on_facet(stand_no,pos,ftype,facet_norm,vec_old,bounce_no,radsum0,radsum,radsum2,INSIDE_STAND)
	struct point *pos,*facet_norm,*vec_old;
	int ftype,bounce_no,stand_no,INSIDE_STAND;
	double radsum0[MAX_NO_WVBANDS][MAX_ORDER_SCAT], radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],
	 	radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
{
/* 	Calculates  total light incident on facet of type ftype at location pos with normal facet_norm.  
	NB - calculates incident on upper side of facet in radsum, and on reverse side in radsum2
	 (given by direction of facet-norm). Only calculates radsum 2 if facet allows transmittance.
	Result of top surface for waveband i is returned in array radsum[bounce_no][i].
	Result of lower surface for waveband i is returned in array radsum2[bounce_no][i].
	Direct beam only (ie without diffuse addition) is returned as radsum0[bounce_no][i]
	Ground and sky reflectances are modelled as isotropic, and leaf reflectance as bi-Lambertian.
*/

	float fac,sky_fac,temp,intfac,source_angle,radius,source_area,t1,t2,t3,plength;
	struct point *npos, *vec, *lnew;
	int type,i,j,m,TEMP_INSIDE_STAND,new_stand_no,facet_number;
	struct threed_data *res;
	/*FILE *FPDEBUG; */
	/* Sample higher orders more sparsely in proportional to expected intensity */

	/* FPDEBUG=fopen("RESULTS/DEBUG","a"); */
	/*  printf("3dLIFC st_no: %d pz: %f ft: %d\n",stand_no,pos->z,ftype);  fflush(NULL); */


	if (bounce_no==1) m=BRANCH_NO; else m=1;

	npos=mkpoint(0.0,0.0,0.0);
	vec=mkpoint(0.0,0.0,0.0);

	for (i=0;i<NO_WVBANDS;i++) { radsum[i][bounce_no]=0.0;radsum2[i][bounce_no]=0.0;radsum0[i][bounce_no]=0;  }

	/* First direct light (if present): is facet illuminated? */

	 if (SOLAR_ZENITH >= 0.0) { 
		set_up_vec(vec);
		fac=dot(vec,facet_norm);
	
		res=threed_find_intersection(stand_no,pos,vec,vec_old,bounce_no,INSIDE_STAND);
		type=res->type;
		free(res);
		if (type==SKY_PLANE_NUMBER) {

			for (i=0;i<NO_WVBANDS;i++) {
				 if (fac >0.0) {
					radsum[i][bounce_no]=SOLAR_RAD[i]*fac;
					 radsum0[i][bounce_no]=SOLAR_RAD[i]*fac; 
					}
				 else {
					 radsum2[i][bounce_no]=-SOLAR_RAD[i]*fac;
				 	 radsum0[i][bounce_no]=-SOLAR_RAD[i]*fac; 
				}
			}
		}
	 	else if (bounce_no==1) COMPNO++; 
		 
	} else if (bounce_no==1) COMPNO++; 
	
	/* Next lines allow second active (laser) source */
	
	if (ACT_SOURCE_FLAG ==1) {
		free(vec);
		vec=vminus(ACT_SOURCE->pos,pos); /* Vector towards active source */
		plength=dist(ACT_SOURCE->pos,pos);
		vnormalise(vec);
		source_angle=acos(-dot(vec,ACT_SOURCE->vec));  /* Angle between source direction and line to target */
	 

		if (source_angle<(2*ACT_SOURCE->sd_angle)){ /* Ie within 2 sd for illumination cone of laser */
		
			 /* printf("vx: %f vy: %f vz: %f avx: %f avy: %f avz: %f ca: %f as_ca: %f\n",vec->x,vec->y,vec->z,ACT_SOURCE->vec->x,ACT_SOURCE->vec->y,ACT_SOURCE->vec->z,source_angle,ACT_SOURCE->sd_angle); */ 
		
		res=threed_find_intersection(stand_no,pos,vec,vec_old,bounce_no,INSIDE_STAND);
		type=res->type;
		
		free(res);
		    if (type==SKY_PLANE_NUMBER) {
		    	PATH_LENGTH[bounce_no]=plength;
		    	/* printf("Sky!\n"); */
			t1=dot(vec,facet_norm);
			radius=tan(source_angle)*ACT_SOURCE->range;
			t2=exp(-radius*radius/(ACT_SOURCE->radius*ACT_SOURCE->radius));
			t3=PI*ACT_SOURCE->radius*ACT_SOURCE->radius; 
			fac=t1*t2/t3;
			 /* printf("sf: %f sr: %f radius: %f t1: %f t2: %f t3: %f fac: %f\n",SCALE_FACTOR,ACT_SOURCE->radius,radius,t1,t2,t3,fac); */
			/* The term fac accounts for change in beam intensity due to (t1) orientation of beam relative to facet surface, (t2)  Gaussian weighting depending on angle from centre of beam , and (t3)  normalisation of Gaussian by area spread at scene */
			
			for (i=0;i<NO_WVBANDS;i++) {
				 if (fac >0.0) {
					 radsum[i][bounce_no]+=ACT_SOURCE->RAD[i]*fac;
					 radsum0[i][bounce_no]+=ACT_SOURCE->RAD[i]*fac; 
					}
				 else {
					 radsum2[i][bounce_no]+=-ACT_SOURCE->RAD[i]*fac;
				 	 radsum0[i][bounce_no]+=-ACT_SOURCE->RAD[i]*fac; 
				}
			}		
		    }
		}
		
	}
	

/*	Now sample diffuse light, if within scattering order threshold.

	Sampling density of diffuse field (m) is reduced with scattering order.
	Due to cut off point, there will be some higher order scattered flux unaccounted for. The scattering
	order should be chosen so this is small, and a value could potentially be approximated for the remaining
	flux.  
 */
	 
	if (bounce_no < BOUNCE_THRESHOLD) {

		for (j=0;j<m;j++) {

			/* Trace each of m rays in new (random) directions */

			if (ftype==GROUND_PLANE_NUMBER) {
				vec=rand_norm_vec_up(vec); intfac=4.0*PI;
			} else { 
				 vec=rand_norm_vec(vec); intfac=8.0*PI; 
			}
				fac=dot(vec,facet_norm);  
	
			/* Find where new rays hits */
			/* temp=INSIDE_STAND; */
			 /* fprintf(FPDEBUG,"3dLIFC diffuse: INSIDE_STAND: %d j: %d\n",INSIDE_STAND,j);  fflush(FPDEBUG); */

			res=threed_find_intersection(stand_no,pos,vec,vec_old,bounce_no,INSIDE_STAND);
			type=res->type;
			npos->x=res->x;npos->y=res->y;npos->z=res->z;
			new_stand_no=res->stno;
			free(res); 
			if ((new_stand_no >= 0) && (new_stand_no < MAX_NOSTANDS)) TEMP_INSIDE_STAND=1; else TEMP_INSIDE_STAND=0;
			
			/* Add appropriate randiance value scaled by projection onto facet (fac) */

			if (type==SKY_PLANE_NUMBER) {
				
				for (i=0;i<NO_WVBANDS;i++) {
				if (SKY_MODEL) sky_fac=calculate_sky_diff_irrad(WAVELENGTH[i],vec->theta,vec->phi); else
				 sky_fac=1.0;
					if (fac>0.0) {
						radsum[i][bounce_no+1]=sky_fac*SKY_RAD[i]/(2*PI);											radsum[i][bounce_no]+=
							((intfac*0.5)/((float)m))*radsum[i][bounce_no+1]*(fac/cos(vec->theta));
									
					}
					else {
						radsum2[i][bounce_no+1]=sky_fac*SKY_RAD[i]/(2*PI);
						radsum2[i][bounce_no]+=
							((-intfac*0.5)/((float)m))*radsum2[i][bounce_no+1]*(fac/cos(vec->theta));						}
				}
			}

			/* If ground or new leaf then use recursion to evaluate light incident on this */

			 else if (type==GROUND_PLANE_NUMBER) {
			 
	threed_light_incident_on_facet(new_stand_no,npos,type,GROUND_NORM,vec,bounce_no+1,radsum0,radsum,radsum2,TEMP_INSIDE_STAND);
				for (i=0;i<NO_WVBANDS;i++) {
					if (fac>0.0) radsum[i][bounce_no]+=(intfac/((float)m))*radsum[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
					else radsum2[i][bounce_no]+=(-intfac/((float)m))*radsum[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
				}
			}
			else if (type==TRUNK_NUMBER) {
				threed_light_incident_on_facet(new_stand_no,npos,type,trunk_norm(STANDS[new_stand_no],npos),vec,bounce_no+1,radsum0,radsum,radsum2,TEMP_INSIDE_STAND);
				for (i=0;i<NO_WVBANDS;i++) {
					if (fac>0.0) radsum[i][bounce_no]+=(intfac/((float)m))*radsum[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
					else radsum2[i][bounce_no]+=(-intfac/((float)m))*radsum[i][bounce_no+1]*GROUND_REFLECTANCE[i]*fac/(2*PI);
				}
			}
						
			else if (type==FACET_NUMBER) {
				facet_number=new_stand_no-MAX_NOSTANDS;
			 
	threed_light_incident_on_facet(new_stand_no,npos,type,FACET[facet_number]->fnormal,vec,bounce_no+1,radsum0,radsum,radsum2,TEMP_INSIDE_STAND);
				for (i=0;i<NO_WVBANDS;i++) {
					if (fac>0.0) radsum[i][bounce_no]+=(intfac/((float)m))*radsum[i][bounce_no+1]*FACET[facet_number]->RHO[i]*fac/(2*PI);
					else radsum2[i][bounce_no]+=(-intfac/((float)m))*radsum[i][bounce_no+1]*FACET[facet_number]->RHO[i]*fac/(2*PI);
				}
			}
			else {
				/* Calculate light incident on each side of leaf seperately. Use RHO and TAU here 
					 for speed in diffuse calculation rather than dynamic function. */

				lnew=find_leaf_orientation(vec);


				threed_light_incident_on_facet(new_stand_no,npos,type,lnew,vec,bounce_no+1,radsum0,radsum,radsum2,TEMP_INSIDE_STAND);
				for (i=0;i<NO_WVBANDS;i++)
					if (fac>0.0) 
 						radsum[i][bounce_no]+=
							(intfac/((float)m))*(radsum[i][bounce_no+1]*RHO[i]+radsum2[i][bounce_no+1]*TAU[i])*fac/(2*PI);
					else 
			 			radsum2[i][bounce_no]+=
							(-intfac/((float)m))*(radsum[i][bounce_no+1]*RHO[i]+radsum2[i][bounce_no+1]*TAU[i])*fac/(2*PI);
					

				free(lnew);
			}

		}

	}
	free(npos);free(vec);	
	/* fclose(FPDEBUG); */

 
}


struct point *find_spec_vec(sol_vec,fnorm)
	struct point *sol_vec,*fnorm;	
{
/* find vector of specular direction: */
	struct point *specular_vec;
	float t1,xsq,ysq;
	
	specular_vec=mkpoint(0.0,0.0,0.0);
	
	t1=2.0*dot(sol_vec,fnorm);
	specular_vec->x=t1*fnorm->x-sol_vec->x;
	specular_vec->y=t1*fnorm->y-sol_vec->y;
	specular_vec->z=t1*fnorm->z-sol_vec->z;
	
	specular_vec->theta=acos(sol_vec->z);
	
	xsq=specular_vec->x*specular_vec->x;
	ysq=specular_vec->y*specular_vec->y;
	specular_vec->phi=acos(specular_vec->x/sqrt(xsq+ysq));
	if (specular_vec->y<0.0) specular_vec->phi=2*PI-specular_vec->phi;
	return 	specular_vec;						
}

float optasm(A,B,view_dir,specular_vec)
	/* Optasm model for specular peak: */
	float A,B;		
	struct point *view_dir,*specular_vec;
{
	float d,rho;
	d=(B+1.0-dot(view_dir,specular_vec));
	if (d>0) rho=A/d; else rho=0.0;
	return rho;
}



float leaf_refl_fn(leaf_norm,vec)
/* MW: Optasm BRDF for viewing direction 'vec' to give single specular peak, for addition to facet radiance. Solar direction is calculated within this routine. */

	struct point *leaf_norm, *vec;
{
	float A,B,rho;
	struct point *solar_vec,*specular_vec,*view_dir;

	A=0.0;B=0.0;
	//A=0.0001;B=0.0005; // Testing values for optasm parameters
	
	solar_vec=mkpoint(0.0,0.0,0.0);view_dir=mkpoint(0.0,0.0,0.0);
	view_dir->x=-vec->x;view_dir->y=-vec->y;view_dir->z=-vec->z;// Reverse direction of incident beam 
	set_up_vec(solar_vec);
	
	specular_vec=find_spec_vec(solar_vec,leaf_norm);
	rho=optasm(A,B,view_dir,specular_vec); 
	//printf("\n** leaf rho: %f\n\n",rho);

	return rho;
}



float facet_refl_fn(facet_number,vec)
/* MW: Optasm BRDF for viewing direction 'vec' to give single specular peak, for addition to facet radiance. Solar direction is calculated within this routine.
NB: Transformation to find specular direction untested & needs to be properly calculated / changed */

	int facet_number;
	struct point *vec;
{
	float A,B,rho,theta_s,phi_s,r;
	struct point *solar_vec,*specular_vec,*facet_normal,*view_dir;

	A=0.0;B=0.0;
	//A=0.0001;B=0.0005; // Testing values. Need to read in A & B for each facet
	
	solar_vec=mkpoint(0.0,0.0,0.0);view_dir=mkpoint(0.0,0.0,0.0);
	view_dir->x=-vec->x;view_dir->y=-vec->y;view_dir->z=-vec->z;// Reverse direction of incident beam 
	set_up_vec(solar_vec);
	facet_normal=FACET[facet_number]->fnormal;

	/*
	printf("\n\n");
	printf("facet_normal->x: %f\n",facet_normal->x);
	printf("facet_normal->y: %f\n",facet_normal->y);
	printf("facet_normal->z: %f\n",facet_normal->z);
	printf("facet_normal->theta: %f\n",facet_normal->theta); 
	printf("facet_normal->phi: %f\n\n",facet_normal->phi); 
	
	printf("solar_vec->x: %f\n",solar_vec->x);
	printf("solar_vec->y: %f\n",solar_vec->y);
	printf("solar_vec->z: %f\n",solar_vec->z);
	printf("solar_vec->theta: %f\n",solar_vec->theta);
	printf("solar_vec->phi: %f\n\n",solar_vec->phi);
	*/
		
	specular_vec=find_spec_vec(solar_vec,facet_normal);
	
	/*
	printf("specular_vec->x: %f\n",specular_vec->x);
	printf("specular_vec->y: %f\n",specular_vec->y);
	printf("specular_vec->z: %f\n",specular_vec->z);
	printf("specular vec theta: %f\n",specular_vec->theta);
	printf("specular vec phi: %f\n",specular_vec->phi);
	*/	

	rho=optasm(A,B,view_dir,specular_vec); 
	//printf("facet rho: %f\n\n",rho);


/* 	printf("\nfno: %d svx: %f svy: %f svz: %f spx: %f spy: %f spz: %f  vx: %f vy: %f vz: %f\n"
	       ,facet_number,solar_vec->x,solar_vec->y,solar_vec->z,specular_vec->x,specular_vec->y,specular_vec->z,view_dir->x,view_dir->y,view_dir->z);
	printf("fno: %d fn_th: %f  fn_ph: %f sv_th: %f  sv_ph: %f sp_th: %f  sp_ph: %f vdsp: %f A: %f B: %f rho: %f\n", 
	       facet_number,facet_normal->theta,facet_normal->phi,solar_vec->theta,solar_vec->phi,theta_s,phi_s,dot(view_dir,specular_vec),A,B,rho);
 */
 		

	free(solar_vec);free(specular_vec);free(view_dir);

	return rho;
}

threed_facet_radiance(stand_no,pos,facet_norm,vec,type,radsum0,radsum,radsum2,INSIDE_STAND)

/* 	Calculates radiance from facet of type 'type', at position 'pos', with normal 'facet_norm'.
	Returns spectrum in radsum[0][*]
	Radsum[1][*] holds incident light flux on upper side of facet, 
*/
	struct point *pos, *facet_norm,*vec;
	int type,stand_no,INSIDE_STAND;
	double  radsum0[MAX_NO_WVBANDS][MAX_ORDER_SCAT], radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],
	 	radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
{
	float  lf, tr, rho;
	int i,facet_number;

/* Ground plane, leaf, trunk, or other facet */

	/* FILE *FPDEBUG;
	FPDEBUG=fopen("RESULTS/DEBUG","a"); */
	 /* printf("3dfac_r st_no: %d pz: %f typ: %d\n",stand_no,pos->z,type); 

	fflush(NULL); */

	if (type==GROUND_PLANE_NUMBER) {
		threed_light_incident_on_facet(stand_no,pos,type,facet_norm,vec,1,radsum0,radsum,radsum2,INSIDE_STAND);
		for (i=0;i<NO_WVBANDS;i++) radsum[i][0]=radsum[i][1]*GROUND_REFLECTANCE[i];
	}
	else if (type==TRUNK_NUMBER) {
		threed_light_incident_on_facet(stand_no,pos,type,facet_norm,vec,1,radsum0,radsum,radsum2,INSIDE_STAND);
		for (i=0;i<NO_WVBANDS;i++) radsum[i][0]=radsum[i][1]*BARK[i];
	}
	else if (type==FACET_NUMBER) {
		facet_number=stand_no-MAX_NOSTANDS;
		threed_light_incident_on_facet(stand_no,pos,type,facet_norm,vec,1,radsum0,radsum,radsum2,INSIDE_STAND);
		/* Original: for (i=0;i<NO_WVBANDS;i++) radsum[i][0]=radsum[i][1]*FACET[facet_number]->RHO[i];
		New is sum of direct light with optasm BRDF and direct+diffuse light using facet albedo; (radsum[i][1]-radsum0[i][1]) would be the term for diffuse only if preffered */
		 for (i=0;i<NO_WVBANDS;i++)
		 	radsum[i][0]=radsum[i][1]*FACET[facet_number]->RHO[i] + 
				radsum0[i][1]*facet_refl_fn(facet_number,vec); 
		/* for (i=0;i<NO_WVBANDS;i++) radsum[i][0]=radsum[i][1]*FACET[facet_number]->RHO[i]; */
	}
	else {
		threed_light_incident_on_facet(stand_no,pos,type,facet_norm,vec,1,radsum0,radsum,radsum2,INSIDE_STAND);
	
		for (i=0;i<NO_WVBANDS;i++) {
			if (type == LEAF_NUMBER) { 
				lf=RHO[i]; tr=TAU[i]; 
			} else if (type == SEN_NUMBER) {
				lf=RHO_SEN[i]; tr=TAU_SEN[i];
			} else {
				lf=BARK[i]; tr=0.0;
			}
			rho=leaf_refl_fn(facet_norm,vec);			
			radsum[i][0]=radsum[i][1]*lf+radsum2[i][1]*tr+radsum0[i][1]*rho ; 
		}

	}
	/* fclose(FPDEBUG); */

}

struct photon *threed_find_reflectance(stand_no,photon,INSIDE_STAND)
	struct photon *photon;
	int stand_no,INSIDE_STAND;
{
	/* takes 'photon' - defining view location and direction, and returns reflectance, given by radiance 
	in view direction divided by total downwelling radiance */ 

	struct point *facet_norm, *vec_old, *vec, *pos,*npos;
	double radsum0[MAX_NO_WVBANDS][MAX_ORDER_SCAT], radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	float tanphi, xval,yval,xsq,ysq,zsq,z;
	int type,i,facet_number;
	struct threed_data *res;
	/* FILE *FPDEBUG;

	FPDEBUG=fopen("RESULTS/DEBUG","a"); 
	  fprintf(FPDEBUG,"3dfr st_no: %d pz: %f \n",stand_no,photon->pos->z);  

	fflush(FPDEBUG); */
	pos=mkpoint(photon->pos->x,photon->pos->y,photon->pos->z);
	vec=mkpoint(photon->vec->x,photon->vec->y,photon->vec->z);
	vec_old=mkpoint(photon->vec->x,photon->vec->y,photon->vec->z);
	npos=mkpoint(0.0,0.0,0.0);
	res=threed_find_intersection(stand_no,pos,vec,vec_old,0,INSIDE_STAND);
	
	type=res->type;
	npos->x=res->x; npos->y=res->y; npos->z=res->z;
	
	if ((res->stno >= 0) && (res->stno < MAX_NOSTANDS))INSIDE_STAND=1;

/* Now have trunks, facet, ground plane or leaf */
	
	if (type ==  GROUND_PLANE_NUMBER) {
		facet_norm=mkpoint(GROUND_NORM->x,GROUND_NORM->y,GROUND_NORM->z);
		facet_norm->theta=GROUND_NORM->theta;facet_norm->phi=GROUND_NORM->phi;
		COMPNO=0; /* fprintf(FPDEBUG,"(3dfr 1)	type: %d st_no: %d pz: %f COMPNO: %d\n",type,stand_no,photon->pos->z,COMPNO); fflush(FPDEBUG); */
	} else if (type ==  TRUNK_NUMBER) {
		tanphi=tan(PI*0.5-atan(sqrt(STANDS[res->stno]->cone2->tansqphi)));
		xval=(npos->x-STANDS[res->stno]->cone2->apex->x);
		yval=(npos->y-STANDS[res->stno]->cone2->apex->y);
		xsq=xval*xval;
		ysq=yval*yval;
		zsq=(xsq+ysq)/(tanphi*tanphi);
		facet_norm=mkpoint(xval,yval,sqrt(zsq));
		vnormalise(facet_norm);
		facet_norm->theta=acos(facet_norm->z);facet_norm->phi=acos(sqrt(xsq/(xsq+ysq)));
		/* printf("x: %f y: %f z: %f th; %f ph: %f\n",facet_norm->x,facet_norm->y,facet_norm->z,
		   facet_norm->theta,facet_norm->phi); */
		COMPNO=6;
	} else if (type==FACET_NUMBER) {
		facet_number=res->stno-MAX_NOSTANDS;
		facet_norm=mkpoint(FACET[facet_number]->fnormal->x,FACET[facet_number]->fnormal->y,FACET[facet_number]->fnormal->z);
		COMPNO=10+2*facet_number;

	} else {
		facet_norm=find_leaf_orientation(photon->vec);
		if (type == LEAF_NUMBER) COMPNO=2; else if (type == SEN_NUMBER)COMPNO=4; else COMPNO=6;
	}
	/* fprintf(FPDEBUG,"(3dfr)	type: %d st_no: %d pz: %f COMPNO: %d\n",type,stand_no,photon->pos->z,COMPNO); fflush(FPDEBUG); */ 
	/* printf(FPDEBUG,"x; %f\n",npos->x);fflush(NULL); */

	threed_facet_radiance(res->stno,npos,facet_norm,photon->vec,type,radsum0,radsum,radsum2,INSIDE_STAND);
	/* BRF: reflectance is be given by radiance/incoming_flux, or simply radiance for active source mode */
	if (ACT_SOURCE_FLAG) for (i=0;i<NO_WVBANDS;i++) photon->intensity[i]=radsum[i][0]/PI; /* radiance */ 
	else for (i=0;i<NO_WVBANDS;i++) photon->intensity[i]=radsum[i][0]/(cos(degtorad(SOLAR_ZENITH))*SOLAR_RAD[i]+SKY_RAD[i]);

	free(facet_norm); free(vec_old); free(npos); free(res); free(pos); free(vec);
	 /* fprintf(FPDEBUG,"exit-3dfr type: %d st_no: %d pz: %f COMPNO: %d\n",type,stand_no,photon->pos->z,COMPNO); fflush(FPDEBUG); */ 

	/* fclose(FPDEBUG); */ 

	return photon;
}

/* --------------- ----------- ---------------- --------------- ----------------- ------------------ ----- */

read_active_source()
/* 	read data from "source.data" describing laser position, direction, divergence angle */
{
	FILE *fpsource, *fpspec;
	float x1,x2,x3,y1,y2,z1,z2,Sz,Sa,Sr,r,angle,range,Wave,rad,theta,phi;
	int i;
	struct point *vec;
	
	printf("Reading source.data...\n");
	fpsource=fopen("source.data","r"); 
	/* fscanf(fpsource,"%f %f %f",&x1,&y1,&z1);  EITHER read x,y,z location of source relative to centre of scene  */
	 
	fscanf(fpsource,"%f %f %f",&Sz,&Sa,&Sr); /*  OR read SOURCE_ZEN, SOURCE_AZ, RANGE and calculate this point*/
	

	
	
	
	fscanf(fpsource,"%f %f %f",&x2,&y2,&z2); /* x,y,z location of target point within scene (giving centre/direction of beam)*/
	
	
	printf("Active source\n  Target: (%5.2f, %5.2f, %5.2f),\n direction (%5.2f %5.2f)\n range: (%5.2f)m \n\n",x2,y2,z2,Sz,Sa,Sr);


	
	theta=degtorad(Sz);
	phi=degtorad(Sa);
	r=Sr*sin(theta);
	x1=r*cos(phi);
	y1=r*sin(phi);
	z1=Sr*cos(theta);
	
		
	fscanf(fpsource,"%f",&angle); /* angle of beam divergance (assuming gaussian conical spread - gives 1sd of intensity for angle from central beam vector) */
	ACT_SOURCE=source_alloc();
	ACT_SOURCE->pos=mkpoint(x1,y1,z1);
	ACT_SOURCE->range=Sr;
	vec=vminus(mkpoint(x2,y2,z2),ACT_SOURCE->pos);x3=vec->x;
	vnormalise(vec);  /* Sr=z3/vec->z; */
	ACT_SOURCE->vec=vec;
	ACT_SOURCE->sd_angle=degtorad(angle);
	ACT_SOURCE->radius=Sr*tan(degtorad(angle));


	fpspec=fopen("source.spec","r"); 
	if (fpspec == NULL) {
		printf("ERROR - Missing source spectrum file source.spec \n");
		exit(0);
	} 

	for (i=0;i<NO_WVBANDS;i++) {
	 	fscanf(fpspec,"%f %f\n",&Wave,&rad);
		if ((int)Wave != WAVELENGTH[i]) {
			printf("ERROR - Waveband mismatch in source spectrum file source.spec \n");
			printf("Wave: %d Rad: %4.3f \n",(int)Wave, rad);fflush(NULL);
			exit(0);
		}
		/* printf("Source waveband: %d rad: %f\n",i,rad); */
		ACT_SOURCE->RAD[i]=rad;  
	}

	fpspec=fopen("solar.spec","r"); 
	if (fpspec == NULL) {
		printf("ERROR - Missing solar spectrum file solar.spec \n");
		exit(0);
	} 

	for (i=0;i<NO_WVBANDS;i++) {
	 	fscanf(fpspec,"%f %f\n",&Wave,&rad);
		if ((int)Wave != WAVELENGTH[i]) {
			printf("ERROR - Waveband mismatch in source spectrum file source.spec \n");
			printf("Wave: %d Rad: %4.3f \n",(int)Wave, rad);fflush(NULL);
			exit(0);
		}
		/* printf("Solar waveband: %d rad: %f\n",i,rad);*/
		
		/* File 'solar.spec' gives total incident light at land surface on horizontal plane, in W/m2 
		  TOTAL_RAD gives projection normal to incident beam for direct light, or horizontal plane for diffuse light. */
		if (SOLAR_ZENITH>0) TOTAL_RAD[i]=rad/cos(degtorad(SOLAR_ZENITH)); else TOTAL_RAD[i]=rad;
	}

}



read_facets_data()
/*	read data from "facets.data" describing triangular facet representations  

	Read in (i) dimenesions of cell and number of facets, and (ii) the set of facet positions and data.   [ MW: X&Y_DIM - NOT YET!  ONLY NO_FACETS read!! ]
	NB Must match with X_DIM, Y_DIM in crown.data if this is used as well.
	
	Format:
	X__DIM, Y_DIM, NOFACETS                       * MW: X_DIM and Y_DIM not used at present - defaults to dimensions in crowns.data or generated values? *
	followed by NOFACETS lines of
	x1 y1 z1  x2 y2 z2  x3 y3 z3 filename.spec
	
	This corresponds to three triangle vertices while filename.spec gives filename of file containing spectrum to include wavebands and reflectance values for each facet.
	
	File may be extended to read in optasm description.
	
	e.g.:
	50.0 50.0 3
	0.0 0.0 0.0  2.0 0.0 0.0  0.0 0.0 2.0 red.spec
	0.0 0.0 0.0  0.0 2.0 0.0  0.0 0.0 2.0 green.spec
	2.0 0.0 0.0  0.0 2.0 0.0  0.0 0.0 2.0 blue.spec
*/

{
	FILE *fpfacet, *fpspec;
	int i,j,spec_open=0;
	float x1,y1,z1,x2,y2,z2,x3,y3,z3,xd,yd;
	float Wave,Rf;
	struct point *u,*v;
	char filename[70];
	fpfacet=fopen("FACETS/facets.data","r"); 

	fscanf(fpfacet,"%d",&NOFACETS);
	/* Units of faceted object will be based on canopy dimensions defined in in_flight.data or crowns.data */

	debugp("No. facets: %d\n",NOFACETS);   //MW: DEBUGGING!

	if (NOFACETS >0) {
	        debugp("HELLO!\n");   //MW: DEBUGGING!
		if (NOFACETS >= MAX_NOFACETS) {
			printf("ERROR - NOFACETS  must not be greater than MAX_NOFACETS \nInput value: %d  MAX_NOFACETS: %d\n Revise input size or change MAX_NOFACETS (line 141)\n",NOFACETS,MAX_NOFACETS);
			exit(0);
		}
		if (NO_COMPS<2*NOFACETS){
			printf("ERROR - NO_COMPS  must  be at least 2*NOFACETS \n NO_COMPS: %d  NOFACETS: %d\n Revise input size or change \n",NO_COMPS,NOFACETS);
			exit(0);
		}
		for (i=0;i<NOFACETS;i++) {
			fscanf(fpfacet,"%f %f %f %f %f %f %f %f %f %s",&x1,&y1,&z1,&x2,&y2,&z2,&x3,&y3,&z3,&filename);
			debugp("%d: %f %f %f %f %f %f %f %f %f %s\n",i+1,x1,y1,z1,x2,y2,z2,x3,y3,z3,filename);   //MW: DEBUGGING!

			if (z1>CANOPY_TOP) CANOPY_TOP=z1;if (z2>CANOPY_TOP) CANOPY_TOP=z2;if (z3>CANOPY_TOP) CANOPY_TOP=z3;

			sprintf(component_names[2*i+10],"Sunlit facet %d   ",i);
			sprintf(component_names[2*i+11],"Shaded facet %d   ",i);

			FACET[i]=facet_alloc();
			FACET[i]->t1=mkpoint(x1,y1,z1);
			FACET[i]->t2=mkpoint(x2,y2,z2);
			FACET[i]->t3=mkpoint(x3,y3,z3);
			u=vminus(FACET[i]->t3,FACET[i]->t1);
			v=vminus(FACET[i]->t3,FACET[i]->t2);
			FACET[i]->fnormal=vcross(u,v);
			FACET[i]->fplane=mkplane(FACET[i]->t1,FACET[i]->t2,FACET[i]->t3);
			free(u);free(v);

			fpspec=fopen(filename,"r");


			if (fpspec == NULL) {
				printf("ERROR - Missing facet spectrum file %s \n",filename);
				exit(0);
				} else spec_open=1;

			for (j=0;j<NO_WVBANDS;j++) {
				fscanf(fpspec,"%f %f\n",&Wave,&Rf);
				if ((int)Wave != WAVELENGTH[j]) {
				  printf("ERROR - Waveband mismatch in facet spectrum file %s \n",filename);
				 	printf("Wave: %d Rf: %4.3f \n",(int)Wave, Rf);fflush(NULL);
				  exit(0);
				}
				FACET[i]->RHO[j]=Rf;
			} if (spec_open) fclose(fpspec);spec_open=0;		
		}
	} else FACET_FLAG=0;
	debugp("FACET_FLAG=%d\n", FACET_FLAG); //MW: DEBUGGING!
	printf("No. facets: %d\n",NOFACETS);
	debugp("got this far!\n");    //MW: DEBUGGING!
	debugp("CANOPY_TOP_OUT = %f, CANOPY_TOP = %f, CANOPY_TOP_IN = %f, Z_DIM = %f, X_DIM = %f, Y_DIM = %f\n", CANOPY_TOP_OUT,CANOPY_TOP,CANOPY_TOP_IN,Z_DIM,X_DIM,Y_DIM);    //MW: DEBUGGING!
	
	CANOPY_TOP_OUT=CANOPY_TOP+0.015;
	CANOPY_TOP_IN=CANOPY_TOP+0.01;
	if (Z_DIM < CANOPY_TOP_OUT)  Z_DIM=CANOPY_TOP_OUT+0.2; 
	debugp("CANOPY_TOP_OUT = %f, CANOPY_TOP = %f, CANOPY_TOP_IN = %f, Z_DIM = %f, X_DIM = %f, Y_DIM = %f\n", CANOPY_TOP_OUT,CANOPY_TOP,CANOPY_TOP_IN,Z_DIM,X_DIM,Y_DIM);    //MW: DEBUGGING!

	debugp("and this far!\n");    //MW: DEBUGGING!
	SKY_PLANE=mkplane( mkpoint(X_DIM,-1*Y_DIM,Z_DIM), 
		mkpoint(X_DIM,Y_DIM,Z_DIM), mkpoint(-1*X_DIM,Y_DIM,Z_DIM));
	debugp("and this far again!\n");    //MW: DEBUGGING!
	
	fclose(fpfacet); 
	  /* MW: if a facet spectrum file was opened, close it */
	debugp("end of reading facets!\n");    //MW: DEBUGGING!
}

/* --------------- ----------- ---------------- --------------- ----------------- ------------------ ----- */



check_random()
{
/* 	First check random number generator and RAND_MAX are compatable. Otherwise
	this can result in an error which is hard to trace.
*/
	int i;
	float temp;

	temp=0;
	for (i=0;i<20000;i++) temp+=rand()*RAND_MULT; 
	if (absfn(temp/10000.0-1.0)>.1) {
		printf("ERROR - RAND_MAX not set\n");
		exit(0);
	}
}

main()

/* Main simulation routine. Mostly controls inputs and outputs.
*/

{
	float xst,yst,theta,phi,r;  
	float ph_intensity[MAX_NO_WVBANDS],temparr[MAX_NO_WVBANDS];  
	int i,j,index_theta,index_phi,PHOTON_COUNT,DUD_NO,NO_PHOTONS_EFF,resulterrflag,out_no, npr;
	float solid_angle,refl,total[MAX_NO_WVBANDS][2],zen_step_size,az_step_size,act_frac_cover,kfac,mean_collision_no,stepsize;
	float can_vol,prob,DFLAG_START,DFLAG_END,MAX_DIFF_FRAC,df_sample_mult;
	float intensity,temp,w,r_thresh,pri,off_x,off_y;
	float *rf,mean_ref[MAX_NO_WVBANDS],fc_int[NO_COMPS][MAX_NO_WVBANDS];
	int NO_IR_BANDS,NO_PAR_BANDS,flag,facet_read_flag;
	int INSIDE_STAND;/* flag to improve efficiency during 3D reverse tracing: 1=inside a crown, 0 = outside */

	char filename[70];
	struct point *phvec;
	struct photon *in_photon, *out_photon;
	
		
	in_photon = (struct photon*) malloc (1 * sizeof(struct photon));
	out_photon = (struct photon*) malloc (1 * sizeof(struct photon));
	FILE *fp,*fplog,*fpim,*fpint,*fpint2,*fpint3;


	PHOTOSYNTHESIS_MODEL=0;	
	ACT_SOURCE_FLAG=0;

	printf("\nStarted\n");

	debugp("Debugging print statements enabled\n");
	if (BIN_OUT) { printf("Binary output enabled\n"); }
	if (FLOAT_OUT) { printf("Floating point output enabled\n"); }
	if (MULT_VIEWS)	printf("Multiple view runs enabled: MULT_VIEWS=%d\n", MULT_VIEWS);


	RAND_MULT=1.0/(float)RAND_MAX;
	check_random();

	

	GROUND_NORM=mkpoint(0.0,0.0,1.0);
	GROUND_NORM->theta=0.0;
	GROUND_NORM->phi=0.0;

 	IM_SIZE=100; /* default value */
	Z_DIM=1.0;
	COMPNO=-1;
	mean_collision_no=0.0;
	for(i=1;i<=9;i++) ANGLES[i]=10.0*(float)i-5.0;
	printf("\nReading structural data...\n");
	read_struct_data();
	if (PHOTOSYNTHESIS_MODEL==1) read_struct_data_photosyn();

	check_data();
	find_maxval_lad();


	//MW2: Do calc of how many runs corresponding to view zen & az ranges
	
	int no_of_runs;
	
	if (MULT_VIEWS) {
	  int no_of_zen,no_of_az;
	  no_of_zen=((VIEW_ZENITH_END-VIEW_ZENITH)/VIEW_ZENITH_STEP)+1;
	  printf("\nNo. of view zenith angles = %d",no_of_zen);
	  no_of_az=((VIEW_AZIMUTH_END-VIEW_AZIMUTH)/VIEW_AZIMUTH_STEP)+1;
	  printf("\nNo. of view azimuth angles = %d",no_of_az);
	  no_of_runs=no_of_zen*no_of_az;
	  printf("\n => Total no. of FLIGHT runs = %d",no_of_runs);
	  printf("\n\n");
	}
	else { 
	  no_of_runs=1;
	  printf("\nTotal no. of FLIGHT runs = %d",no_of_runs);
	  printf("\n\n");
	}






	printf("Reading spectral reflectance data...\n");
	read_reflectance_arrays();
	
	printf("Reading soil BRDF array...\n");	
	read_gnd_array();
	




	if ((MODE=='r') && (ONED_FLAG ==0)) FACET_FLAG=1; 
	find_max_scat();  

		
	if (ONED_FLAG==1) NOSTANDS=1; else NOSTANDS=MAX_NOSTANDS-1;
	
	FACET_FLAG=0;  /* MW: change to allow/disallow facet data */



	    


	flag=1;facet_read_flag=0;
	while (flag==1) {
		flag=0;
		if (FIELD_DATA!=1) { 

		  /* Set up canopy enevelopes with dummy variables for lai, position and shape - */  /* MW: i.e. 'initialising' crowns before real values?   */


			for (i=0;i<NOSTANDS;i++) {
				if (CROWN_SHAPE=='c') 
					STANDS[i]=mkstand_cone(1.0,
						mkcone(mkpoint(3.0,3.0,CONE_HEIGHT*1.5),
						degtorad(CONE_ANGLE),CONE_HEIGHT),
						mkcone(mkpoint(3.0,3.0,3.0),
						degtorad(TRUNK_ANGLE),CONE_HEIGHT) );
				else if ((CROWN_SHAPE=='e') || (1 !=2))
					STANDS[i]=
					mkstand_ellipse(1.0,
						mkellipse(mkpoint(3.0,3.0,3.0),
						1.0,1.0,1.0),
						mkcone(mkpoint(3.0,3.0,3.0),
						degtorad(TRUNK_ANGLE),1.0) );
			}
			if (ONED_FLAG!=1) {
				printf("Generating simulated crown distribution...\n");
				forest_gen3();
			}

		}

		else {
			printf("\nReading canopy position data...");
			SCALE_FACTOR=1.0;
			read_canopy_data();
		}

		if (FACET_FLAG) {
			if (facet_read_flag==0) {
				printf("Reading facet data...\n");
				read_facets_data();
				facet_read_flag=1;
				debugp("facet_read_flag = %d\n\n",facet_read_flag);  //MW: DEBUGGING!
				flag=intersect_facets_crowns(NOSTANDS);
				} 
			} 
	}


	if (ACT_SOURCE_FLAG==1) {
		printf("Reading active source data...\n"); read_active_source();
	}




	
	SKY_PLANE=mkplane( mkpoint(X_DIM,-1*Y_DIM,Z_DIM), 
		mkpoint(X_DIM,Y_DIM,Z_DIM), mkpoint(-1*X_DIM,Y_DIM,Z_DIM));

	GROUND_PLANE=mkplane( mkpoint(X_DIM,-1*Y_DIM,0.01),
		mkpoint(X_DIM,Y_DIM,0.01), mkpoint(-1*X_DIM,Y_DIM,0.01));

	WALL1=mkplane(mkpoint(X_DIM,-1*Y_DIM,0.0),mkpoint(X_DIM,Y_DIM,0.0),
		mkpoint(X_DIM,Y_DIM,Z_DIM));

	WALL2=mkplane(mkpoint(-1*X_DIM,-1*Y_DIM,0.0),
  			mkpoint(-1*X_DIM,Y_DIM,0.0), 
			mkpoint(-1*X_DIM,Y_DIM,Z_DIM));

	WALL3=mkplane(mkpoint(X_DIM,-1*Y_DIM,0.0),
			mkpoint(-1*X_DIM,-1*Y_DIM,0.0), 
			mkpoint(X_DIM,-1*Y_DIM,Z_DIM));

	WALL4=mkplane(mkpoint(X_DIM,Y_DIM,0.0), 
		mkpoint(-1*X_DIM,Y_DIM,0.0),
		mkpoint(X_DIM,Y_DIM,Z_DIM));
	


	/* If we are in imaging mode, only record first & second scattering events,
		otherwise set large threshold value. Nb - this can be altered to
		explore amount of energy absorbed/reflected at different orders of scattering.
		Eg  BOUNCE_THRESHOLD=0 will accumulate only single scattering energy. 
        */

	if ((MODE=='i') || (MODE=='s')) {
		BOUNCE_THRESHOLD=2;
		NO_WVBANDS=1;
		define_component_names();
	}
	else {
		if (MODE =='r') {
			printf("Reading data for reverse mode...\n");
			read_reverse_data();
		} 

	/* Error in max ref band ~ (.5*w)^n, where w is single scattering albedo, and n is order of
		scattering considered. Other bands will have smaller error.
	  BOUNCE_THRESHOLD<0 indicates this should be set automatically
	*/
		if ((BOUNCE_THRESHOLD<0) || (MODE=='f')) {
			w=.6*(RHO[NIR]+TAU[NIR]);r_thresh=.000004;
			BOUNCE_THRESHOLD=(int)(log(r_thresh)/log(w));
		}
			if (BOUNCE_THRESHOLD >= MAX_ORDER_SCAT) BOUNCE_THRESHOLD=MAX_ORDER_SCAT-1;
			/* Always evaluate diffuse field for PRI,even if v. small */
			if ((BOUNCE_THRESHOLD < 2) && (PRI_BAND_NO>=0)) BOUNCE_THRESHOLD=2; 
		printf("Scattering order: %d\n",BOUNCE_THRESHOLD);

		define_component_names();
	}
	if ((MODE=='r') && (ACT_SOURCE_FLAG==0)) {
		/* Partition radiance in PAR and IR domain evenly into bands. Units are Mol PPFD /(knm) where knm denotes
			the wavelength range represented by each band. TOTAL_RAD is total on a plane perpendicular to
			incoming direction. This may be parititioned into a diffuse field, which is defined as flux
			arriving perpendicular to the ground plane. */

		NO_IR_BANDS=0;NO_PAR_BANDS=0;
		for (i=0;i<NO_WVBANDS;i++) if (WAVELENGTH[i] >700) NO_IR_BANDS++; else NO_PAR_BANDS++;
		for (i=0;i<NO_WVBANDS;i++) if (WAVELENGTH[i] >700) TOTAL_RAD[i]=IR_RAD/(float)NO_IR_BANDS;
			 else TOTAL_RAD[i]=PAR_RAD/(float)NO_PAR_BANDS; 
				/* Craig's partition 
				NO_PAR_BANDS=3;
				TOTAL_RAD[0]=0.334*PAR_RAD;
				TOTAL_RAD[1]=0.01*PAR_RAD; used for PRI reflectance not a PAR band
				TOTAL_RAD[2]=0.334*PAR_RAD;
				TOTAL_RAD[3]=0.332*PAR_RAD;

			}
				*/
	}
	

	//MW2: alternative loop start position - memory problem in between forest gen call above and this point, field data not



	
	MAX_DIFF_FRAC=0.0;
	if ((MODE=='r') && (SOLAR_ZENITH>=0.0) &&  (AER_OPT >=0.0)) SKY_MODEL=0; else SKY_MODEL=0;
        /* SKY_MODEL=0;   MW: Comment out to enable anisotropic diffuse sky look-up table!  */
	if (SKY_MODEL) read_sky_field();

	 
	for (VIEW_ZENITH=VIEW_ZENITH_START; VIEW_ZENITH<=VIEW_ZENITH_END; VIEW_ZENITH=VIEW_ZENITH+VIEW_ZENITH_STEP) {
	  for (VIEW_AZIMUTH=VIEW_AZIMUTH_START; VIEW_AZIMUTH<=VIEW_AZIMUTH_END; VIEW_AZIMUTH=VIEW_AZIMUTH+VIEW_AZIMUTH_STEP) {
	    /* printf("\n\nFLIGHT run # %d:-\n",run_count+1); */
	    if (MULT_VIEWS) printf("VIEW_ZENITH: %f       VIEW_AZIMUTH: %f \n\n",VIEW_ZENITH,VIEW_AZIMUTH);
	    
	
	if ( ((MODE=='f') && (AER_OPT >=0.0)) || (MODE=='r')) {
		printf("Calculating diffuse fraction...\n");
		for (i=0;i<NO_WVBANDS;i++) {
			if (SOLAR_ZENITH >=0.0) DIFF_FRAC[i]=diffuse_est((float)WAVELENGTH[i]*.001); else DIFF_FRAC[i]=1.0;	
			if (DIFF_FRAC[i]>=MAX_DIFF_FRAC) MAX_DIFF_FRAC=DIFF_FRAC[i];
			if (DIFF_FRAC[i] <0) {
				printf("\nERROR - diffuse fraction at band %d (%dnm) <0 %f\n",i+1,WAVELENGTH[i],DIFF_FRAC[i]);
				exit(0);
			}
			if (MODE=='r') {
					SOLAR_RAD[i]=TOTAL_RAD[i]*(1.0-DIFF_FRAC[i])/cos(degtorad(SOLAR_ZENITH));
					SKY_RAD[i]=TOTAL_RAD[i]*DIFF_FRAC[i];
			printf("%d nm  Diffuse frac: %f dir rad: %f dif rad: %f\n",WAVELENGTH[i],DIFF_FRAC[i],SOLAR_RAD[i],SKY_RAD[i]);

				
			}
		}
	}





	  /*	  int rn;
		  srand(2); //MW2: fix random seed, so each run the same for same view zenith and azimuth? 
		  rn=(rand()%100);
		  printf("random number =%d\n",rn); */
	  
	  
	
	if ((MODE=='i') || (MODE=='s') || (MODE=='r')) {

		/* filenames for image, showing (i) components, and (ii) intensities */

	  //printf("run count = %d\n\n",run_count+1);

		sprintf(filename,"RESULTS/flt-image.out");
		fpim=fopen(filename,"w");
		if (BIN_OUT) {
		 //sprintf(filename,"RESULTS/flt-int.out");  /* original version */  
		  sprintf(filename,"RESULTS/flt-int-Vz%03d-Va%03d.out",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH);      //MW2 - unique identifiers for image files
		  //printf("%s\n\n",filename);
		  fpint=fopen(filename,"w");
		}
		if (FLOAT_OUT) {
		  //sprintf(filename,"RESULTS/flt-int_float.out");
		  sprintf(filename,"RESULTS/flt-int_float-Vz%03d-Va%03d.out",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH);
		  fpint2=fopen(filename,"w");
		  
		}
		if (ACT_SOURCE_FLAG){ sprintf(filename,"RESULTS/flt-path_float-Vz%03d-Va%03d.out",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH);
		  fpint3=fopen(filename,"w");
		  }
	}

	if (ONED_FLAG ==0) {
		
		mk_intersect_lists();
		mk_wall_lists();
		mk_low_high();

		can_vol=find_canopy_volume(40000);
		act_frac_cover=find_frac_cover(40000);
		printf("Frac. cover (accounting for overlap): %f\n",act_frac_cover);
		FRAC_COV=act_frac_cover;
		printf("Crown volume density (m3/m2) (accounting for overlap): %f   \n",
			 can_vol/(4.0*X_DIM*Y_DIM));

		if ((FIELD_DATA==0) || (TOTAL_LAI>0)) {
			LAI=TOTAL_LAI*4.0*(float)(X_DIM*Y_DIM)/can_vol; /*LAI is density of leaf area within crown in m2/m3 */
			for (i=0;i<NOSTANDS;i++)  STANDS[i]->lai=LAI; 
		}

	} 
	else {
		TOP_ONED=1.0;CANOPY_TOP_IN=TOP_ONED;
		LAI=TOTAL_LAI;
		SCALE_FACTOR=1.0;
		for (i=0;i<NOSTANDS;i++) STANDS[i]->lai=LAI;

	}

/*	Variable LAI here refers to leaf area density (m2/m3) within the code, which is the parameter
	 actually used to calculate extinction coeficients. TOTAL_LAI, the input value, is however
	 normal leaf area index (m2/m2), and includes all (non-trunk) foliage.
*/

	if (BARK_LAI >0.0) printf("Bark LAI equiv: %f\n",BARK_LAI);

	if (ONED_FLAG ==0) printf("Total LAI (m2/m2): %f density (m2/m3): %f\n",TOTAL_LAI,LAI);
		else 	printf("Total LAI (m2/m2): %f\n",TOTAL_LAI);
	printf("Frac green: %f  Frac sen: %f Frac bark: %f\n",FRAC_GRN,FRAC_SEN,FRAC_BARK);


/*	Define LAI for each stand to be a constant, unless read in from field data, but could vary here if required */

if ((MODE!='s') && (FRAC_COV>0.0) && (TOTAL_LAI>0.0)) {
		printf("Reading hot-spot array...\n");
		read_hot_spot_array(); 
		if (MODE != 'r') {
			printf("Compiling phase function arrays...\n");
			if (FRAC_GRN > 0.0) mk_phase_fn_array(RHO,TAU,phase_fn_array);
			if (FRAC_SEN > 0.0) mk_phase_fn_array(RHO_SEN,TAU_SEN,sen_phase_fn_array);
			if (FRAC_BARK > 0.0) {
				for (i=0;i<MAX_NO_WVBANDS;i++) temparr[i]=0.0;
				mk_phase_fn_array(BARK,temparr,bk_phase_fn_array);
			}
		}

/*   		Create array of directional extinction coefficients. These use the LAD and assume azimuthal isotropy, 
		and are normalised to an LAI of 1.0
*/	printf("NOSTANDS: %d\n",NOSTANDS);
		printf("\nCompiling extinction coefficient array...\n");
		mk_extinction_coef_array(); 

	}



/* 	Three options: 
		(i) Evaluate direct beam only (AER_OPT<0) or in an imaging mode
		(ii) Evaluate diffuse beam only (SOLAR_ZENITH<0)
		(iii) Evaluate both and combine (AER_OPT>0 and SOLAR_ZENITH>=0)
*/






	zen_step_size=90.0/(float)(RESULT_ZEN_GRID-1);
	az_step_size=360.0/(float)RESULT_AZ_GRID;
	DFLAG_START=0;DFLAG_END=0;
	if (MODE == 'f') {
	
		if (SOLAR_ZENITH<0.0) { DFLAG_START=1;DFLAG_END=1;printf("Diffuse mode\n");}
		if ((AER_OPT<0.0) && (SOLAR_ZENITH>=0.0)) { DFLAG_START=0;DFLAG_END=0;printf("Direct mode,\nSolar zenith: %f \n",SOLAR_ZENITH);}
		if ((AER_OPT>=0.0) && (SOLAR_ZENITH>=0.0) )  { 
			DFLAG_START=0;DFLAG_END=1;printf("Direct+diffuse mode,\nSolar zenith: %f \nAerosol opt: %f\n",SOLAR_ZENITH,AER_OPT);
		}

		if (DFLAG_START==1)	sprintf(filename,"RESULTS/Diff-L%02d-fc%03d",
			(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5));
			else sprintf(filename,"RESULTS/Sz%02d-L%02d-fc%03d",
				(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5));
		fp=fopen(filename,"wb");
		printf("Output BRDF will be in file %s\n",filename);
	}
	for (DIFF_SKY_FLAG=DFLAG_START;DIFF_SKY_FLAG<=DFLAG_END;DIFF_SKY_FLAG++) {

		if (DIFF_SKY_FLAG==1) sprintf(filename,"RESULTS/Sz%02d-L%02d-fc%03d-dif.log",
				(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5));
			else {
			  if (MULT_VIEWS) {sprintf(filename,"RESULTS/Vz%03d-Va%03d-dir.log",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH);}
			  else sprintf(filename,"RESULTS/Sz%02d-L%02d-fc%03d-Vz%03d-Va%03d-dir.log",
				      (int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5),(int)VIEW_ZENITH,(int)VIEW_AZIMUTH); }
	                             	//MW2: above includes unique identifer for multiple view directions

		fplog=fopen(filename,"w");

		in_photon=mkphoton(mkpoint(1.0,1.0,Z_DIM-0.01),mkpoint(0.0,0.0,-1.0),ph_intensity);

		for (i=0;i<NO_WVBANDS;i++) {
			total[i][DIFF_SKY_FLAG]=0.0;
			ALBEDO[i][DIFF_SKY_FLAG]=0.0;
			ABS_SOIL[i][DIFF_SKY_FLAG]=0.0;
			ABS_CANOPY_GR[i][DIFF_SKY_FLAG]=0.0;
			ABS_CANOPY_SEN[i][DIFF_SKY_FLAG]=0.0;
			ABS_CANOPY_BK[i][DIFF_SKY_FLAG]=0.0;
			mean_ref[i]=0.0;
			for (index_theta=0;index_theta<RESULT_ZEN_GRID;index_theta++) {
				for (index_phi=0;index_phi<RESULT_AZ_GRID;index_phi++) {
					result[i][index_theta][index_phi][DIFF_SKY_FLAG]=0.0;
				}
			} 
		} 

		if ((MODE == 'i') || (MODE=='s') || (MODE=='r')) {
			for (out_no=0;out_no<NO_COMPS;out_no++) {
 				fc_result[out_no]= 0.0;
				for (i=0;i<NO_WVBANDS;i++) fc_int[out_no][i]=0.0;
			}
		}

		NIR_LEAKAGE=0.0;
		for (i=0;i<NO_WVBANDS;i++) LEAKAGE[i]=0.0;
			
		PHOTON_COUNT=0;
		DUD_NO=0;
		stepsize=2.0*(float)X_DIM/((float)IM_SIZE);
 		if (MODE!='f') NO_PHOTONS=IM_SIZE*IM_SIZE;
	
		/* If calculating diffuse field in addition to direct, then we use a smaller sampling, as less
			accuracy is required Sampling used is approx. in proportion to max amount of diffuse radiation  */
		
		if ((DIFF_SKY_FLAG==1) && (SOLAR_ZENITH>=0.0) && (MODE=='f')) {
			printf("\nCalculating diffuse component");
			 df_sample_mult=MAX_DIFF_FRAC;
		}
			else df_sample_mult=1.0;

		NO_PHOTONS_EFF=(int)(NO_PHOTONS*df_sample_mult+0.5);


	if ((MODE=='r') && (N_LUE_SAMPLES>0))	{
		printf("\nSampling photosynthetic rate...\n");
		temp=lue_fn(PHOTOSYNTHESIS_MODEL,20.0,300.0);  /*Leaf model, Internal Co2, temp (K) */
		 printf("\nCanopy LUE: %f\n",temp); 
	}

	
	if ((MODE=='r') && (ONED_FLAG==0) && (VIEW_ZENITH>0) ){
		/* Offset view plane so (0,0,0) is viewed in centre, rather than (0,0,CANOPY_TOP_IN) */
		r=atan(degtorad(VIEW_ZENITH))*CANOPY_TOP_IN;
		off_x=r*cos(degtorad(VIEW_AZIMUTH));
		off_y=r*sin(degtorad(VIEW_AZIMUTH));
	} else {
		off_x=0.0; off_y=0.0;
	}
		printf("\nCommencing simulation of %d photon trajectories...\n",NO_PHOTONS_EFF);
		while (PHOTON_COUNT < NO_PHOTONS_EFF) {

			for (yst=-1.0*Y_DIM+stepsize*0.5+off_y;yst<=(Y_DIM+off_y);yst=yst+stepsize) {
				for (xst=-1.0*X_DIM+stepsize*0.5+off_x;xst<=(X_DIM+off_x);xst=xst+stepsize) {
			
	
				
 
					if ( (float)((5*PHOTON_COUNT)/NO_PHOTONS_EFF)==
						(5.0*((float)(PHOTON_COUNT))/((float)NO_PHOTONS_EFF))) {

						printf("%5.1f %% paths traced\n",
							100.0*(float)(PHOTON_COUNT)/(float)(NO_PHOTONS_EFF));  

						
 					} 
					in_photon->pos->x=xst;
					in_photon->pos->y=yst;
					in_photon->pos->z=CANOPY_TOP_IN;
	

					if (MODE=='f') {
					
						if (DIFF_SKY_FLAG==1) in_photon->vec=rand_norm_vec_down(in_photon->vec);
						else {
							theta=(180.0-SOLAR_ZENITH)*PI/180.0;
							if (theta <= PI/2) theta=PI/2.0+0.02;
							phi=degtorad(SOLAR_AZIMUTH);
							r=sin(theta);
							in_photon->vec->x=r*cos(phi);
							in_photon->vec->y=r*sin(phi);
							in_photon->vec->z=cos(theta);
							in_photon->vec->theta=theta;
							in_photon->vec->phi=phi;
						}
					}

 					else {


						/* Here theta and phi correspond to view direction for imaging mode */
						/* For sampling hemispherical albedo, use:  VIEW_ZENITH<0 */
						if (VIEW_ZENITH<0) in_photon->vec=rand_norm_vec_down_albedo(in_photon->vec);
						else {
							theta=PI-degtorad(VIEW_ZENITH); /* 0 input means Nadir */
							phi=degtorad(VIEW_AZIMUTH)-PI; /* phi means hotspot if solar_az=phi */
							r=sin(theta);
							in_photon->vec->x=r*cos(phi);
							in_photon->vec->y=r*sin(phi);
							in_photon->vec->z=cos(theta);
							in_photon->vec->theta=theta;
							in_photon->vec->phi=phi;
						}
					 
					}




					for (i=0;i<NO_WVBANDS;i++) in_photon->intensity[i]=1.0;
					for (i=0;i<=BOUNCE_THRESHOLD;i++) PATH_LENGTH[i]=0.0;
/*
					Non-isotropic sky requires implementation of function norm_skyfac,
						giving angular distribution of skylight, normalised to mean
						hemispherically integrated value of 1.

					if (DIFF_SKY_FLAG==1) 
						for (i=0;i<NO_WVBANDS;i++)
							 in_photon->intensity[i]=norm_skyfac(i,in_photon->vec->theta,in_photon->vec->phi);
*/

					COLLISION_NO=0;
					COMPNO=-1;

					if ((MODE == 'r') && (ONED_FLAG ==1)) {
						
						in_photon->pos->z=TOP_ONED;
						out_photon=find_reflectance(STANDS[0],in_photon);

						for (i=0;i<NO_WVBANDS;i++) {
							mean_ref[i]+=out_photon->intensity[i];
							fc_int[COMPNO][i]+=out_photon->intensity[i];
						}

					}
					if ((MODE == 'r') && (ONED_FLAG ==0)) {

						/* fprintf(FPDEBUG,"main - start rev 3D \n");fflush(FPDEBUG); */
						INSIDE_STAND=0;
						out_photon=threed_find_reflectance(SKY_PLANE_NUMBER,in_photon,INSIDE_STAND);
						for (i=0;i<NO_WVBANDS;i++) {
							mean_ref[i]+=out_photon->intensity[i];
							fc_int[COMPNO][i]+=out_photon->intensity[i];
						}

					}
					else if (ONED_FLAG ==0) out_photon=sim(in_photon); 
					else {
						in_photon->pos->z=TOP_ONED;
						prob=rand()*RAND_MULT;
						if (prob<=FRAC_COV) out_photon=oned_interact(STANDS[0],in_photon);
						else { out_photon=ground_interact(in_photon);COMPNO=0; }
					}

 					out_no=COMPNO;

					phvec=out_photon->vec;

					PHOTON_COUNT++;
					resulterrflag=0;

					if (MODE == 'f') {
						for (i=0;i<NO_WVBANDS;i++) {
							if ( (out_photon->intensity[i]<0.0) || 
								(out_photon->intensity[i]>30.0) || 
								(COLLISION_NO > BOUNCE_THRESHOLD)) resulterrflag=1;
						}
					}

					if ( (MODE =='r') || ((phvec->theta <PI*0.5) && (phvec->theta >=0.0) && (resulterrflag==0))) {
						temp=degtorad(zen_step_size*0.5);

						if (phvec->theta <= temp) index_theta=0;
						else if (phvec->theta >= (0.5*PI- temp)) index_theta=RESULT_ZEN_GRID-1;

						else index_theta=(int)(2.0*(phvec->theta+temp)/PI*((float)RESULT_ZEN_GRID-1.0));

						if (index_theta==0) index_phi=0;
						else {
							temp=degtorad(az_step_size*0.5);
							if ((phvec->phi <= temp) || (phvec->phi >= (2.0*PI- temp))) index_phi=0;
							else 
							index_phi=(int)(0.5*(phvec->phi+temp)/PI*((float)RESULT_AZ_GRID-1.0));
						}

						if (MODE=='f') {

							kfac=2.0*cos(phvec->theta);

							for (i=0;i<NO_WVBANDS;i++) {
								intensity=out_photon->intensity[i]/kfac;	

							total[i][DIFF_SKY_FLAG]=total[i][DIFF_SKY_FLAG]+out_photon->intensity[i];

								result[i][index_theta][index_phi][DIFF_SKY_FLAG]= 
									result[i][index_theta][index_phi][DIFF_SKY_FLAG]+intensity;
					 		}
						}

						else {
							
							fc_result[out_no]++;
							fprintf(fpim,"%d\n",out_no);
										 
							for (i=0;i<NO_WVBANDS;i++) {   /* MW: BIP output format (1 pixel, all wavebands...)   */
							  if (FLOAT_OUT) { fprintf(fpint2,"%f\n",out_photon->intensity[i]); } /* MW: floating-point output format (for IDL) */
							  if (BIN_OUT) { fwrite (&(out_photon->intensity[i]), sizeof(float), 1, fpint); } /* MW: binary output format (for ENVI) */
							  
							  
							  
							}
							if (ACT_SOURCE_FLAG) fprintf(fpint3,"%f\n",PATH_LENGTH[1]);

						}

						mean_collision_no+=(float)COLLISION_NO;

					}

					else { 
						NIR_LEAKAGE+=out_photon->intensity[NIR];
						for (i=0;i<NO_WVBANDS;i++) {
							LEAKAGE[i]+=in_photon->intensity[i];
							in_photon->intensity[i]=0.0;
						}

						DUD_NO++;
					}
	
				}
			}
		};
		printf("\nNo. Photons traced: %d \n",PHOTON_COUNT);

		if (MODE=='f') {

			printf("Mean no. interactions: %f \n",mean_collision_no/(float)(PHOTON_COUNT-DUD_NO));
			printf("Photons trajectories discontinued: %d,\n  accounting for %f %% of energy at min. absorbing band\n\n",
				DUD_NO,NIR_LEAKAGE*100.0/((float)(PHOTON_COUNT)));

			printf("   No. Wave(nm)    Alb    Rf_Nadir  Rf_view  Abs_gr   Abs_sn  Abs_bk  Abs_soil\n ");
			fprintf(fplog,"   No. Wave(nm)    Alb    Rf_Nadir  Rf_view  Abs_gr   Abs_sn  Abs_bk  Abs_soil\n ");

			for (i=0;i<NO_WVBANDS;i++) {
				for (index_theta=0;index_theta<RESULT_ZEN_GRID;index_theta++) {
					for (index_phi=0;index_phi<RESULT_AZ_GRID;index_phi++) {

						if ((index_theta==0)  )
 							solid_angle=(1.0-cos(degtorad(zen_step_size*0.5)))*2*PI;
						else if (index_theta==(RESULT_ZEN_GRID-1))
 							solid_angle=2.0*PI*(cos(degtorad((float)index_theta*zen_step_size
								- zen_step_size*0.5))
								- cos(degtorad((float)index_theta*zen_step_size)) )
								/((float)RESULT_AZ_GRID);
						else
							solid_angle=2*PI*(cos(degtorad((float)index_theta*zen_step_size
									-zen_step_size*0.5))
								- cos(degtorad((float)index_theta*zen_step_size
				 				+zen_step_size*0.5)) )
								/((float)RESULT_AZ_GRID);

						refl=result[i][index_theta][index_phi][DIFF_SKY_FLAG]/
								((float)PHOTON_COUNT)*2*PI/solid_angle;
						BRF[i][index_theta][index_phi][DIFF_SKY_FLAG]=refl;

					}
				}; 
				ALBEDO[i][DIFF_SKY_FLAG]=total[i][DIFF_SKY_FLAG]/((float)PHOTON_COUNT);
			

				ABS_SOIL[i][DIFF_SKY_FLAG]=ABS_SOIL[i][DIFF_SKY_FLAG]/((float)PHOTON_COUNT);
				ABS_CANOPY_GR[i][DIFF_SKY_FLAG]=ABS_CANOPY_GR[i][DIFF_SKY_FLAG]/((float)PHOTON_COUNT);
				ABS_CANOPY_SEN[i][DIFF_SKY_FLAG]=ABS_CANOPY_SEN[i][DIFF_SKY_FLAG]/((float)PHOTON_COUNT);
				ABS_CANOPY_BK[i][DIFF_SKY_FLAG]=ABS_CANOPY_BK[i][DIFF_SKY_FLAG]/((float)PHOTON_COUNT);

				/* Extract value for specified view zenith */
				temp=degtorad(zen_step_size*0.5);
				index_theta=(int)(2.0*(degtorad(VIEW_ZENITH)+temp)/PI*((float)RESULT_ZEN_GRID-1.0));

				temp=degtorad(az_step_size*0.5);
				index_phi=(int)(0.5*(PI-degtorad(VIEW_AZIMUTH)+temp)/PI*((float)RESULT_AZ_GRID-1.0));
				if (index_theta <=0) { index_theta=0;index_phi=0; }
				if (index_theta>RESULT_ZEN_GRID-1)   index_theta=RESULT_ZEN_GRID-1;
				if (index_phi>RESULT_AZ_GRID-1) index_phi=index_phi-RESULT_AZ_GRID;
				if (index_phi<0) index_phi=index_phi+RESULT_AZ_GRID;


				printf("%4d  %4d      %6.4f   %6.4f    %6.4f   %6.4f   %6.4f  %6.4f  %6.4f\n ",
					i+1,WAVELENGTH[i],
					ALBEDO[i][DIFF_SKY_FLAG],BRF[i][0][0][DIFF_SKY_FLAG],BRF[i][index_theta][index_phi][DIFF_SKY_FLAG],
					ABS_CANOPY_GR[i][DIFF_SKY_FLAG],ABS_CANOPY_SEN[i][DIFF_SKY_FLAG],
					ABS_CANOPY_BK[i][DIFF_SKY_FLAG],ABS_SOIL[i][DIFF_SKY_FLAG]);

				fprintf(fplog,"%4d  %4d      %6.4f   %6.4f    %6.4f   %6.4f   %6.4f  %6.4f  %6.4f\n ",
					i+1,WAVELENGTH[i],
					ALBEDO[i][DIFF_SKY_FLAG],BRF[i][0][0][DIFF_SKY_FLAG],BRF[i][index_theta][index_phi][DIFF_SKY_FLAG],
					ABS_CANOPY_GR[i][DIFF_SKY_FLAG],ABS_CANOPY_SEN[i][DIFF_SKY_FLAG],
					ABS_CANOPY_BK[i][DIFF_SKY_FLAG],ABS_SOIL[i][DIFF_SKY_FLAG]);

			}
			
		}
		
	}

	if ((AER_OPT>0.0) && (SOLAR_ZENITH>=0.0) && (MODE=='f')) {

		printf("\nCalculating combined direct/diffuse BRDF\n");

		sprintf(filename,"RESULTS/Sz%2d-L%2d-fc%02d-a%3d.log",
				(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5),(int)(AER_OPT*100.0+0.5));
		fplog=fopen(filename,"w");
		printf("   No. Wave(nm)  F.Diff    Alb     Rf_Nadir  Rf_view  Abs_gr  Abs_sn  Abs_bk  Abs_soil\n ");
		fprintf(fplog,"   No. Wave(nm)  F.Diff    Alb     Rf_Nadir  Rf_view  Abs_gr  Abs_sn  Abs_bk  Abs_soil\n ");


		for (i=0;i<NO_WVBANDS;i++) {

			ALBEDO[i][2]=(1.0-DIFF_FRAC[i])*ALBEDO[i][0]+DIFF_FRAC[i]*ALBEDO[i][1];

			ABS_CANOPY_GR[i][2]=(1.0-DIFF_FRAC[i])*ABS_CANOPY_GR[i][0]+DIFF_FRAC[i]*ABS_CANOPY_GR[i][1];
			ABS_CANOPY_SEN[i][2]=(1.0-DIFF_FRAC[i])*ABS_CANOPY_SEN[i][0]+DIFF_FRAC[i]*ABS_CANOPY_SEN[i][1];
			ABS_CANOPY_BK[i][2]=(1.0-DIFF_FRAC[i])*ABS_CANOPY_BK[i][0]+DIFF_FRAC[i]*ABS_CANOPY_BK[i][1];
			ABS_SOIL[i][2]=(1.0-DIFF_FRAC[i])*ABS_SOIL[i][0]+DIFF_FRAC[i]*ABS_SOIL[i][1];

			for (index_theta=0;index_theta<RESULT_ZEN_GRID;index_theta++) {
				for (index_phi=0;index_phi<(RESULT_AZ_GRID);index_phi++) {

					BRF[i][index_theta][index_phi][2]=
						(1.0-DIFF_FRAC[i])*BRF[i][index_theta][index_phi][0]
						+DIFF_FRAC[i]*BRF[i][index_theta][index_phi][1];
				}
			}

			/* Extract value for specified view zenith */
			temp=degtorad(zen_step_size*0.5);
			index_theta=(int)(2.0*(degtorad(VIEW_ZENITH)+temp)/PI*((float)RESULT_ZEN_GRID-1.0));

			temp=degtorad(az_step_size*0.5);
			index_phi=(int)(0.5*(PI-degtorad(VIEW_AZIMUTH)+temp)/PI*((float)RESULT_AZ_GRID-1.0));
			if (index_theta <=0) { index_theta=0;index_phi=0; }
			if (index_theta>RESULT_ZEN_GRID-1)   index_theta=RESULT_ZEN_GRID-1;
			if (index_phi>RESULT_AZ_GRID-1) index_phi=index_phi-RESULT_AZ_GRID;
			if (index_phi<0) index_phi=index_phi+RESULT_AZ_GRID;


			printf("%4d  %4d      %6.4f   %6.4f    %6.4f   %6.4f   %6.4f  %6.4f  %6.4f  %6.4f\n ",
				i+1,WAVELENGTH[i],DIFF_FRAC[i],
				ALBEDO[i][2],BRF[i][0][0][2],BRF[i][index_theta][index_phi][2],
				ABS_CANOPY_GR[i][2],ABS_CANOPY_SEN[i][2],ABS_CANOPY_BK[i][2],ABS_SOIL[i][2]);

			fprintf(fplog,"%4d  %4d      %6.4f   %6.4f    %6.4f   %6.4f   %6.4f  %6.4f  %6.4f  %6.4f\n ",
				i+1,WAVELENGTH[i],DIFF_FRAC[i],
				ALBEDO[i][2],BRF[i][0][0][2],BRF[i][index_theta][index_phi][2],
				ABS_CANOPY_GR[i][2],ABS_CANOPY_SEN[i][2],ABS_CANOPY_BK[i][2],ABS_SOIL[i][2]);

		}


		fflush(fplog); 
		fclose(fplog);

	}

	if ((DUD_NO>0) && ((MODE=='i') || (MODE=='s') || (MODE=='r'))) { 

	/* Possibility of a few photons missing from image - will fill in with 0's so we still have (eg) 200*200 */
		for (i=0;i<DUD_NO;i++) {
			fprintf(fpim,"%d\n",out_no);
				for (j=0;j<NO_WVBANDS;j++)   /* MW: BIP output format (1 pixel, all wavebands...)   */
				  if (FLOAT_OUT) { fprintf(fpint2,"%f\n",out_photon->intensity[j]); }  /* MW: floating-point output format (for IDL) */
				  if (BIN_OUT) { fwrite (&(out_photon->intensity[i]), sizeof(float), 1, fpint); }  /* MW: binary output format (for ENVI)  */
		}
	}
	 /* free(in_photon->intensity);free(in_photon->vec);free(in_photon);	free(out_photon->intensity);free(out_photon->vec);free(out_photon); */


	if (MODE=='i')  {
		printf("\nComponent fractions:\n");
		for (out_no=0;out_no<NO_COMPS;out_no++) printf("%s: %5.2f\n",component_names[out_no],(float)fc_result[out_no]/(float)PHOTON_COUNT);
		printf("\nOutput image is in file 'RESULTS/flt-image.out'\n\n");	}

	if (MODE=='r') {
		printf("\nComponent fractions:\n\n");
		printf("Component           Frac"); 
		if (NO_WVBANDS >6) npr=6; else npr=NO_WVBANDS; /* Avoid illegible output for component spectra */
		for (i=0;i<npr;i++) printf("%6dnm",WAVELENGTH[i]);
		if (npr < NO_WVBANDS) printf(" ...");
		for (out_no=0;out_no<NO_COMPS;out_no++) {
 			if (fc_result[out_no] > 0.0) {
				printf("\n%s: %5.2f ",component_names[out_no],(float)fc_result[out_no]/(float)PHOTON_COUNT);
					if (fc_result[out_no] >0) for (i=0;i<NO_WVBANDS;i++)
						 printf(" %6.4f ",fc_int[out_no][i]/(float)fc_result[out_no]);
			}
		}
		// if (AER_OPT <0.0) {
			// printf("\n\n   No. Wave(nm)     Rf\n");
			// fprintf(fplog,"\n\n   No. Wave(nm)     Rf\n");

		// for (i=0;i<npr;i++) printf("%4d    %4d      %6.4f\n", i+1,WAVELENGTH[i], mean_ref[i]/((float)PHOTON_COUNT));
		// for (i=0;i<NO_WVBANDS;i++) fprintf(fplog,"%4d    %4d      %6.4f\n", i+1,WAVELENGTH[i], mean_ref[i]/((float)PHOTON_COUNT));
		// }
		else {
			printf("\n\n   No. Wave(nm)  F.Diff     Rf\n");
		for (i=0;i<NO_WVBANDS;i++) printf("%4d  %4d      %6.4f   %6.4f\n", i+1,WAVELENGTH[i],DIFF_FRAC[i], mean_ref[i]/((float)PHOTON_COUNT));
			fprintf(fplog,"\n\n");for (i=0;i<NO_WVBANDS;i++) fprintf(fplog,"%4d  %4d      %6.4f   %6.4f\n", i+1,WAVELENGTH[i],DIFF_FRAC[i],mean_ref[i]/((float)PHOTON_COUNT));
		}
		if (PRI_BAND_NO >=0) {	pri=(mean_ref[PRI_BAND_NO]-mean_ref[PRI_REFER_BAND_NO])/(mean_ref[PRI_BAND_NO]+mean_ref[PRI_REFER_BAND_NO]);
			printf("\nPRI: %f  [%f %%]\n",pri,pri/-0.052942-1.0);
		}
		printf("\n\nOutput image is in file 'RESULTS/flt-image.out'\n");
		if (BIN_OUT) { printf("Output reflectance values are in file 'RESULTS/flt-int-Vz%03d-Va%03d.out'\n\n",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH); }  //MW2
		if (FLOAT_OUT) { printf("Output reflectance float values are in file 'RESULTS/flt-int_float-Vz%03d-Va%03d.out'\n\n",(int)VIEW_ZENITH,(int)VIEW_AZIMUTH);}
		//if (BIN_OUT) { printf("Output reflectance values are in file 'RESULTS/flt-int.out'\n\n"); }
		//if (FLOAT_OUT) { printf("Output reflectance float values are in file 'RESULTS/flt-int_float.out'\n\n");}


	}

	if ((MODE)=='s') {
		printf("\nComponent fractions:\n\n");
		for (out_no=0;out_no<4;out_no++) {
 			printf("%s: %5.2f\n",component_names[out_no],(float)fc_result[out_no]/(float)PHOTON_COUNT);
		}
		printf("\nOutput image is in file 'RESULTS/flt-image.out',\nLambertian intensities in 'RESULTS/flt-int.out'\n\n");
	}

	if (MODE=='f') {
		fwrite(&BRF[0][0][0][0],sizeof(float),MAX_NO_WVBANDS*RESULT_ZEN_GRID*RESULT_AZ_GRID*3,fp);
		fflush(fp); 
		fclose(fp);
	}
	if ((MODE=='i') || (MODE=='s') || (MODE=='r')) { 
		fflush(fpim);fclose(fpim);
		if (FLOAT_OUT) { fflush(fpint2);fclose(fpint2);}
		if (BIN_OUT) { fflush(fpint);fclose(fpint); }
		
	}
	 if (ACT_SOURCE_FLAG) { fflush(fpint3);fclose(fpint3); }
        //save_canopy_data();    /*MW:  calls function to output data file containing details of stands    */

    free(in_photon);
    free(out_photon);
	fflush(fplog); 	
	fclose(fplog);
	/* fclose(FPDEBUG); */




	run_count++;

	/* printf("\n%f",VIEW_ZENITH);
	printf("\n%f",VIEW_ZENITH_END);
	printf("\n%f",VIEW_ZENITH_STEP);
	printf("\n");
	printf("\n%f",VIEW_AZIMUTH);
	printf("\n%f",VIEW_AZIMUTH_END);
	printf("\n%f",VIEW_AZIMUTH_STEP);  */
	  }           //MW2: END BIG LOOP HERE
	}
	  
	//printf("\nEND!\n");
	
	

}




float lue_fn(pmodel,ci,t_leaf)


	int pmodel;
	float ci, t_leaf;

/*	Estimates parameters of canopy APAR, IPAR, photostynthetic rate and light use efficieny (LUE). Uses n samples
	of a random leaf within canopy, and then scales this by total canopy LAI. Returns a value of LUE. 
	pmodel flag determines which leaf photosynthesis model to use

	NB For photosyntheis / APAR, we should have high sampling of diffuse light (e.g. BRANCH_NO=80), but only need low
	 	scattering order (e.g. BOUNCE_THRESHOLD=5) **/
{
	double radsum0[MAX_NO_WVBANDS][MAX_ORDER_SCAT],radsum[MAX_NO_WVBANDS][MAX_ORDER_SCAT],
		radsum2[MAX_NO_WVBANDS][MAX_ORDER_SCAT];
	struct point *pos,*vec_old,*leaf_normal;
	struct photon *in_photon;
	struct stand *stand;
	int i,j, k, stand_no, h_index,INSIDE_STAND;
	float canopy_abs[MAX_NO_WVBANDS],canopy_interception[MAX_NO_WVBANDS], leaf_absorption[MAX_NO_WVBANDS],leaf_interception[MAX_NO_WVBANDS];
	float height_photo[100];
	float z,rf,tr,w,canopy_photosynthesis,canopy_apar,canopy_ipar,leaf_apar,temp,canopy_lue,incident_par,canopy_fapar;
	float leaf_photosynthesis, canopy_fipar,canopy_inc_lue;
	float ph_intensity[MAX_NO_WVBANDS];
	float  direct, frac_sunlit, abs_sunlit;

	frac_sunlit=direct=abs_sunlit=0.0;
	
	vec_old=mkpoint(0.0,0.0,0.0);
	temp=LF_SIZE;LF_SIZE=0.0;
	pos=mkpoint(0.0,0.0,0.0);
	in_photon=mkphoton(mkpoint(0.0,0.0,0.0),mkpoint(0.0,0.0,0.0),ph_intensity);
	canopy_photosynthesis=0.0;
	for (i=0;i<NO_WVBANDS;i++) {canopy_abs[i]=0.0; canopy_interception[i]=0.0;}
	
	stand = STANDS[0];		
	FILE *height_gr, *height_ph;
     	height_gr=fopen("plotting/height_gr","w");
	height_ph=fopen("plotting/height_ph","w");	

        /*srand(time());*/ 
	 
	 for(j=0;j<N_LUE_SAMPLES;j++) {						/* n samples of random leaf within canopy */
	 
		leaf_normal=random_leaf_normal();
		
		if (ONED_FLAG==1) {
			z=rand()*RAND_MULT*TOP_ONED;
			pos->z=z; 
			light_incident_on_facet(stand,pos,2,leaf_normal,vec_old,1,radsum,radsum2); 	
		}
		else {
			stand_no=-1;
			while (stand_no<0) {
			
				pos->x=(rand()*RAND_MULT*(float)(X_DIM)*2.0)-(float)X_DIM;
				pos->y=(rand()*RAND_MULT*(float)(Y_DIM)*2.0)-(float)Y_DIM;  

				pos->z=rand()*RAND_MULT*CANOPY_TOP;
				in_photon->pos = pos;
				z=pos->z;
							
				for  (k=0;k<NOSTANDS;k++) if (inside_stand(in_photon->pos,k)) stand_no=k;

			}

			INSIDE_STAND=1;  

			threed_light_incident_on_facet(stand_no,pos,2,leaf_normal,vec_old,1,radsum0,radsum,radsum2,INSIDE_STAND);


		} 
		
		free(leaf_normal);
		
		
		if (z<0.00001)      h_index = 0;				   
		if (ONED_FLAG==1)   h_index = (int)(  ( (z/TOP_ONED)-0.00001 ) *100  );
		else                h_index = (int)(  ( (z/CANOPY_TOP)-0.00001 ) *100  );


		for (i=0;i<NO_WVBANDS;i++) {		
			rf=RHO[i]; tr=TAU[i]; w=1.0-rf-tr;
			leaf_interception[i]=radsum[i][1]+radsum2[i][1];
			leaf_absorption[i]=leaf_interception[i]*w;
			canopy_interception[i]+=leaf_interception[i];
			canopy_abs[i]+=leaf_absorption[i];
			HEIGHT_ABS_GR[i][2][h_index] += leaf_absorption[i];
			HEIGHT_ABS_GR[i][0][h_index] += HEIGHT_ABS_GR_DIRECT[i]*w;
			
			if (i==0) {

 		   	   direct+=HEIGHT_ABS_GR_DIRECT[0]*(w/N_LUE_SAMPLES);
 		   	   if (HEIGHT_ABS_GR_DIRECT[0]>0.0) {
  			   frac_sunlit=frac_sunlit+(1.0/N_LUE_SAMPLES);
			   abs_sunlit=abs_sunlit+(leaf_absorption[0]/N_LUE_SAMPLES);
		/*printf("%f %f %d \n", (z/TOP_ONED), leaf_interception[i], 1);*/
		           }
		/*else { printf("%f %f %d\n", (z/TOP_ONED), leaf_interception[i], 0);}*/
		        }
			
			HEIGHT_ABS_GR_DIRECT[i] = 0.0;
		}

		/* Estimate photosynthetic rate using Collatz or hyperbolic model. This is based on incident flux on leaf */ 

		/* leaf_photosynthesis = leaf_photosynthesis_moses(leaf_interception,t_leaf,z,TOTAL_LAI,ci); */
		if (pmodel==0) leaf_photosynthesis =leaf_photosynthesis_fn(leaf_interception);
			else leaf_photosynthesis = leaf_photosynthesis_moses(leaf_interception,t_leaf,z,TOTAL_LAI,ci);
			
		/* printf("%f %f %f \n", z, leaf_interception[0], leaf_photosynthesis); */
  
	        canopy_photosynthesis+=leaf_photosynthesis;	
		height_photo[h_index]+=leaf_photosynthesis; 
 	
	}									


/*	for (i=0;i<NO_WVBANDS;i++) {
	 
	      for (h_index=0;h_index<100;h_index++) {
	       fprintf(height_gr," %d  %5.1f  %f %f %f \n", WAVELENGTH[i], h_index+0.5, TOTAL_LAI*HEIGHT_ABS_GR[i][0][h_index]/(float)N_LUE_SAMPLES,
	             TOTAL_LAI*(HEIGHT_ABS_GR[i][2][h_index]-HEIGHT_ABS_GR[i][0][h_index])/(float)N_LUE_SAMPLES,
		     TOTAL_LAI*HEIGHT_ABS_GR[i][2][h_index]/(float)N_LUE_SAMPLES );
		  
	       if (WAVELENGTH[i]<=700) fprintf(height_ph," %5.1f  %f \n", WAVELENGTH[i], 
	                 h_index+0.5, TOTAL_LAI*height_photo[h_index]/(float)N_LUE_SAMPLES); } 
	} */


	/* Values are for flux/rates per m2 of leaf. Must scale by LAI to give totals */
	
	canopy_apar=TOTAL_LAI*par_fn(canopy_abs)/(float)N_LUE_SAMPLES;
	canopy_ipar=TOTAL_LAI*par_fn(canopy_interception)/(float)N_LUE_SAMPLES;
	canopy_photosynthesis=TOTAL_LAI*canopy_photosynthesis/(float)N_LUE_SAMPLES;
	canopy_lue=canopy_photosynthesis/canopy_apar;	
	incident_par=cos(degtorad(SOLAR_ZENITH))*par_fn(SOLAR_RAD)+par_fn(SKY_RAD); 
	canopy_fapar=canopy_apar/incident_par;
	canopy_fipar=canopy_ipar/incident_par;	
	canopy_inc_lue=canopy_photosynthesis/incident_par;
	
	printf("Diffuse PAR in horiz plane: %f  (fDIF = %f) \n", SKY_RAD[0], DIFF_FRAC[0] );
	printf("Direct PAR in horiz plane: %f  \n", SOLAR_RAD[0]*cos(degtorad(SOLAR_ZENITH)) ); 
	   
	/* printf("\n%4.2f of leaves are sunlit \nabsorbing %4.2f and %4.2f of direct and total sky radiance respectively \n", 
	            frac_sunlit, direct*TOTAL_LAI, abs_sunlit*TOTAL_LAI);
		    */
	for (i=0;i<NO_WVBANDS;i++) printf( "band: %d frac_canopy_abs: %f \n",
	    	i,TOTAL_LAI*canopy_abs[i]/((float)N_LUE_SAMPLES*(cos(degtorad(SOLAR_ZENITH))*SOLAR_RAD[i]+SKY_RAD[i])) );

	printf("\nIncident PAR: %f umol s-1 m-2\n",incident_par);
	printf("Canopy APAR: %f umol s-1 m-2\n",canopy_apar);
	printf("Canopy fAPAR: %f\n" ,canopy_fapar);
	printf("Canopy photosynthetic rate: %f umol C m-2 s-1\nCanopy lue (Incident PAR): %f umol C/umol Incident PAR\nCanopy lue (APAR): %f umol C/umol APAR\n",canopy_photosynthesis,canopy_inc_lue,canopy_lue);
	
	/* printf("LAI %f  theta %f  ci %f  t_leaf %f  PAR_top %f  photosyn %f \n",
	     TOTAL_LAI, SOLAR_ZENITH, ci, t_leaf, par_fn(TOTAL_RAD), canopy_photosynthesis); */

	LF_SIZE=temp;
	free(vec_old);free(pos);	
	
	return canopy_inc_lue;
	
}



