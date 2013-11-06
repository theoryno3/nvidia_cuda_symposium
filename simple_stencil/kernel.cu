#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define N 1024
#define RADIUS 5
#define BLOCK 512

__global__ void stencil_1d(int n, double *in, double *out)
{
	/* calculate global index in the array */
	/* insert code to calculate my global index in the array using block and thread build-in variables */
	int gindex = FIXME
	
	/* return if my global index is larger than the array size */
	if( gindex >= n ) return;

	/* code to handle the boundary conditions */
	if( gindex < RADIUS || gindex >= (n - RADIUS) ) 
	{
		out[gindex] = (double) gindex * ( (double)RADIUS*2 + 1) ;
		return;
	} /* end if */

	/* use result as temporary accumulator variable */
	double result = 0.0;
	
	for( int i = gindex-(RADIUS); i <= gindex+(RADIUS); i++ ) 
	{
		/* add the required elements from the array "in" to the temporary variable "result" */ 
		result = FIXME;
	}

	/* store the result in the "out" array */
	out[gindex] = result;
	return;
}

int main()
{
    double *in, *out;
	double *d_in, *d_out;
	int size = N * sizeof( double );

	/* allocate space for device copies of in, out */

	cudaMalloc( (void **) &d_in, size );
	cudaMalloc( (void **) &d_out, size );

	/* allocate space for host copies of in, out and setup input values */

	in = (double *)malloc( size );
	out = (double *)malloc( size );

	for( int i = 0; i < N; i++ )
	{
		in[i] = (double) i;
		out[i] = 0;
	}

	/* copy inputs to device */

	cudaMemcpy( d_in, in, size, cudaMemcpyHostToDevice );
	cudaMemset( d_out, 0, size );

	/* calculate block and grid sizes */

	dim3 blocks( BLOCK, 1, 1);

	/* insert code for proper grid size in X dimension */
	dim3 grids( FIXME, 1, 1);

	/* start the timers */

	cudaEvent_t start, stop;
	cudaEventCreate( &start );
	cudaEventCreate( &stop );
	cudaEventRecord( start, 0 );

	/* launch the kernel on the GPU */

	stencil_1d<<< grids, blocks >>>( N, d_in, d_out );

	/* stop the timers */

	cudaEventRecord( stop, 0 );
	cudaEventSynchronize( stop );
	float elapsedTime;
	cudaEventElapsedTime( &elapsedTime, start, stop );

	printf("Total time for %d elements was %f ms\n", N, elapsedTime );

	/* copy result back to host */

	cudaMemcpy( out, d_out, size, cudaMemcpyDeviceToHost );

	for( int i = 0; i < N; i++ )
	{
		if( in[i]*( (double)RADIUS*2+1 ) != out[i] ) printf("error in element %d in = %f out %f\n",i,in[i],out[i] );
	} /* end for */

	/* clean up */

	free(in);
	free(out);
	cudaFree( d_in );
	cudaFree( d_out );
	
	return 0;
} /* end main */
