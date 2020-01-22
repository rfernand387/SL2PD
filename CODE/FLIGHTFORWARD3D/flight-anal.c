#include <stdio.h>  
 
/*	These parameters must match parameters from flight4.c: */

#define MAX_NO_WVBANDS 400

#define RESULT_ZEN_GRID 10
#define RESULT_AZ_GRID 36

float BRF[MAX_NO_WVBANDS][RESULT_ZEN_GRID][RESULT_AZ_GRID][3];


float absfn(value)
	float value;
{
	if (value<0.0) return -1.0*value;
	else return value;
}

main() 
{

/*	Program used to extract data from BRDF array output by FLIGHT. Expects data to be
	in directory 'RESULTS', and writes a file suffixed '.out' with data of interest.

	To read, must change code below to specify LAI, FRAC_COV and SOLAR_ZENITH, 
	and code above for MAX_NO_WVBANDS, RESULT_ZEN_GRID and RESULT_AZ_GRID

	For writing output, access appropriate regions of BRDF by looping over
	waveband (wv), view zenith (vz) and relative azimuth (ra). 

*/

	int iwv,wvst,wvend,index_theta,index_phi,DIFF,DIR,COMBINED,type;
	char filename[70];
	float FRAC_COV,SOLAR_ZENITH,TOTAL_LAI;
	float vz,ra;
	FILE *fp,*fpout;

	DIR=0;DIFF=1;COMBINED=2;

/* 	Here enter parameters used to make file */
	
	type=DIR;
	FRAC_COV=0.47;
	TOTAL_LAI=2.3;
	SOLAR_ZENITH=50.0;

/*	Code will locate output from flight55.c in RESULTS directory if it exists */

	sprintf(filename,"RESULTS/Sz%02d-L%02d-fc%03d",
			(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5));
	fp=fopen(filename,"rb");
	if (fp!=NULL) {

		fread(&BRF[0][0][0][0],sizeof(float),
			MAX_NO_WVBANDS*RESULT_ZEN_GRID*RESULT_AZ_GRID*3,fp);
		fclose(fp);

/*	Here enter waveband number (nb not actual wavelength) and view angles to be output. Can be
	easily adapted to loop over wavebands as well, to display spectrum, while holding view angle
	constant.
*/
	wvst=0;wvend=1;
	for (iwv=wvst;iwv<= wvend;iwv++) {

		sprintf(filename,"RESULTS/Sz%02d-L%02d-fc%03d-wv%03d.out",
			(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5),iwv);
		fpout=fopen(filename,"w");
		printf("\n\nWaveband: %d\n",iwv);
		fprintf(fpout,"V_zen     Rel_az     Ref\n");
		printf("\nV_zen     Rel_az     Ref\n");


		for (vz=-90.0;vz<90.1;vz+=10.0) {

			if (vz<0.0) ra=180.0; else ra=0.0; 

		/* 	
			Assuming solar azimuth angle is zero;

			 Principal plane is seen by:
			 	if (vz<0.0) ra=180.0; else ra=0.0; 

			Cross principal plane is seen by:
			 	if (vz<0.0) ra=270.0; else ra=90.0; 

			To view azimuth variation at constant zenith use (eg):
				vz=60; for (ra=0.0;ra<360.1;ra+=1.25) { ...etc

		*/




			index_theta=(int)((absfn(vz)/90.0)*(RESULT_ZEN_GRID-1)+0.5);
			index_phi=(int)((ra/360.0)*(RESULT_AZ_GRID-1)+0.5);


			if (index_theta==0) index_phi=0;
			

										
			printf("%5.1f     %5.1f     %6.4f\n",vz,ra,
				BRF[iwv][index_theta][index_phi][type]);

			fprintf(fpout,"%5.1f     %5.1f     %6.4f\n",vz,ra,
				BRF[iwv][index_theta][index_phi][type]);

			}
		}
	}
	else printf("File not found, 'RESULTS/Sz%2d-L%2d-fc%02d.out'",
			(int)SOLAR_ZENITH,(int)(TOTAL_LAI*10.0+0.5),(int)(FRAC_COV*100.0+0.5));
	fclose(fpout);

}
