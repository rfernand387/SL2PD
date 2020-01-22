	FLIGHT - Forest LIGHT interaction model 
 	P.R.J. North

	"THREE DIMENSIONAL FOREST LIGHT INTERACTION MODEL USING A MONTE CARLO METHOD",
	IEEE TRANSACTIONS ON GEOSCIENCE AND REMOTE SENSING,
	VOL. 34, NO. 4, PP. 946-956, JULY 1996


	Version 5.0
	1 Dec 2002

----------------------------------------------------------------------------------------


The following files/directories should be present in directory FLIGHT:

FLIGHT-
	flight5.c
	flight-anal.c
	in_flight.data
	reverse.data
	format_reverse.data
	-RESULTS
		(blank)
	-SPEC
		leaf.spec
  		soil.spec
	-DATA
		hotspot.data
   		lad.data
       		soilbrdf.data
	-EXAMPLES		
		-EXAMPLE1
		
			README.txt
			in_flight.data
			flight-anal.c
			-RESULTS
				Sz50-L24-fc047
				Sz50-L24-fc047-dir.log
				Sz50-L24-fc047-wv000.out
				Sz50-L24-fc047-wv001.out
			-SPEC
				...
			-DATA
				...
   		-EXAMPLE2
			...+subdirectories...
		...

----------------------------------------------------------------------------------------

Flight5, Introductory Notes:

COMPILATION AND INPUTS
The main code is 'flight5.c'. This should be compiled using the maths library (-lm) option:
	 cc -O -o f5 flight5.c -lm.
	 
On running, it takes the file 'in_flight.data' to specify the input parameters
such as LAI, LAD, crown distribution. The file also specifies mode of ray-tracing:
'f' Forwards mode -  simulation to generate full BRDF
'r' Reverse mode - fast ray tracing for a single view direction (** now the normal mode of execution)
'i' Image mode - generates a simple image of scene, mainly for testing / visualisation (** now redundant - use 'r')
's' Solid mode - treats crowns as solid objects, and creates a simple image (** now redundant - recommend 'r')

Two canopy structure modes are possible:
1D -  homogenous, specified by LAI, LAD, fractional cover
3D -  inhomogeneous, including additional description of structure
      by geometric primitives (e.g. ellipsoids, cones) describing where foliage lies.
	
In 'reverse' mode the program also reads the parameters in 'reverse.data'.

For the 3D canopy usually we specify a statistical distribution (fractional cover, mean crown 
size and shape, variation in height). Shapes supported are ellipsoids 'e' and cones 'c'. There is
 an option 'f' to read in a set of field data in file 'crowns.data'.

The number of photon paths traced is specified in in_flight.data (or reverse.data for 'r' mode).
A low number gives high speed, but low accuracy. Error falls off as ~1/sqrt(n). A typical value 
is ~10^6 for 10 degree angular sampling (or 10^4 in 'r' mode).

Further parameters specify solar and view angles, leaf size, soil roughness, and aerosol 
optical depth (controlling diffuse light fraction). These are explained in comments 
on the first page of 'flight5.c', and in the file  'format_reverse.data'.  

The files in 'DATA' are used internally by the program (look-up tables for soil roughness and 
leaf hot-spot effect) and should not be altered. Additionally, the file 'lad.data' gives 4 example
leaf angle distributions which can be used by copying into in_flight.data.

SPECTRA
The directory 'SPEC' contains spectral values.
As a minimum, the code requires spectra for leaf reflectance and transmittance,
and soil reflectance. There is an option to simulate fractions of up to two further
components in the foliage, e.g. senescent material, and bark. The fractions of these
are specified in 'in_flight.data', and currently assumed randomly distributed in foliage. 

Some example spectra are given. To vary them, it is probably best to make a new directory with
the appropriate files in it, and copy these to directory SPEC. The code can use ouput from leaf 
reflectance models (e.g. PROSPECT, LIBERTY).


OUTPUT
Output from the program will appear in directory 'RESULTS'. Similarly
with SPEC, run the program and then copy output from 'RESULTS' to wherever
you want them stored permanently. The output filenames include the solar angle,
LAI and fractional cover to help identification.

The program will calculate the BRDF and absorption: 

  The normal output ('f' mode') is a 3D array giving the BRDF for conditions specified, ie
  a reflectance value for each waveband, view zenith and view azimuth. 

  Also given are '.log' files recording albedo, absorption by each plant material,
  nadir reflectance and reflectance at one specified view direction at each waveband.

  Cases are separated for direct, diffuse and combined direct+diffuse. The output array
  contains all 3 (or zeros if not calculated), while each has a separate .log file. 

The program 'flight-anal.c' allows extraction of subsets of data from the output array
of flight5.c. It can be altered easily - currently it is set up to display the principal 
plane reflectance for a particular waveband.  Must be altered for changing solar zenith,
lai etc, as these affect the filename of the flight output file..

In reverse mode ('r' mode) we only calculate reflectance for the specified view direction, 
and so the program runs much more quickly. Currently this is only implemented for 1D canopies. 
This mode also allows calculation of photosynthetic rate and light use efficiency (LUE) as
described in Barton and North 2001.

	in_flight.data:
	1MODE		Mode of operation: Forwards  ('f'), image  ('i'), solid-object image  ('s'), reverse ('r')
	2ONED_FLAG	Dimension of model: '0' or '3' means 3D Representation, '1' means 1D representation
	3SOLAR_ZENITH,VIEW_ZENITH  	Source zenith & View zenith  (degrees). (Negative value for source => diffuse beam only) 
	4SOLAR_AZIMUTH,VIEW _AZIMUTH 	Source azimuth & View azimuth angles (degrees)
	5NO_WVBANDS	Number of wavebands simulated
	6NO_PHOTONS	Number of photon paths simulated
	7TOTAL_LAI	Mean one-sided total foliage area index for scene (m^2/m^2)
	8FRAC_GRN,FRAC_SEN,FRAC_BARK	Foliage composition:
				FRAC_GRN	Fraction of green leaves in foliage by area
				FRAC_SEN	Fraction of senescent/shoot material in foliage "    "
				FRAC_BARK	Fraction of bark in foliage   "    "	
	9LAD[1-9]	Leaf angle distribution, giving angle between normal to leaves and vertical,
			expressed as fraction lying within 10 degree bins 0-10, 10-20, 20-30... 80-90
	10SOILROUGH	Soil roughness index (0-1). Lambertian soil given by 0, rough (mean slope 60deg) given by 1
	11AER_OPT		Aerosol optical thickness at 555nm (A negative value means direct beam only)
	12LF_SIZE		Leaf size (radius, approximating leaf as circular disc).
	13FRAC_COV	Fraction of ground covered by vegetation (on vertical projection, and approximating
			crowns as opaque)

	For 3D case only:

	14CROWN_SHAPE	'e' for ellipsoid, 'c' for cones, 'f' for field data in file crowns.dat
	15Exy, Ez		Crown radius (Exy), and centre to top distance (Ez). For cones, Ez gives crown
				height, while for ellipsoids it gives half of the crown height. 
	16MIN_HT,MAX_HT	Min and Max height to first branch. Crowns randomly distributed between these ranges.
			Total canopy height will be the sum of this value and crown height
	17DBH		Trunk dbh. Trunks approximated as cones from ground to top of crown. 
			A zero value indicates trunks should not be modelled (resulting in much faster calculation)