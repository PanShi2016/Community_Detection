/**
 * @file sweepcut_mex.cpp
 *
 * Implements a sweepcut procedure that sweeps over nodes acccording to
 * the ordering input in `node_ordering`. Options for terminating the sweep once
 * the set reaches half the volume of A, as well as for starting and stopping
 * the sweep at specified indices `sweepstart` and `sweepend`.
 *
 * USAGE:
 * [bestset,conductance,cut,volume] = \
 *        sweepcut_mex(A,node_ordering,halfvol_flag,sweepstart, sweepend, debugflag)
 *
 *
 * TO COMPILE:
 *
 * if ismac
 *      mex -O -largeArrayDims sweepcut_mex.cpp
 * else
 * mex -O CXXFLAGS="\$CXXFLAGS -std=c++0x" -largeArrayDims sweepcut_mex.cpp
 *
 *
 */

#ifndef __APPLE__
#define __STDC_UTF_16__ 1
#endif

#include <vector>
#include <assert.h>
#include <math.h>

//#include "sparsehash/dense_hash_map.h"
//#include "sparsevec.hpp"
#include <unordered_map>
#define tr1ns std

struct sparsevec {
    typedef tr1ns::unordered_map<size_t,double> map_type;
    map_type map;
};


#include "mex.h"

#define DEBUGPRINT(x) do { if (debugflag) { \
mexPrintf x; mexEvalString("drawnow"); } \
} while (0)

int debugflag = 0;

struct sparserow {
    mwSize n, m;
    mwIndex *ai;
    mwIndex *aj;
    double *a;

    /**
     * Returns the degree of node u in sparse graph s
     */
    mwIndex sr_degree( mwIndex u) {
        return (aj[u+1] - aj[u]);
    }
};

double get_cond( double cut, double vol, double tot_vol ){
	double temp_vol = std::min( vol, tot_vol - vol );
	if ( temp_vol == 0.0 ) return 1.0 ;
	return cut / temp_vol ;
}


/** Grow a set of seeds via the input diffusion.
 *
 * @param G - sparserow version of input matrix A
 */
void sweepcut(sparserow* G, std::vector<mwIndex>& noderank, mwIndex& sw_start,
  mwIndex& sw_end, mwIndex& bindex, double& bcond, double& bvol, double& bcut, int halfvol)
{
	// mwIndex length_array = noderank.size();
	double total_volume = (double)G->aj[G->n] ;
  sparsevec local_cut_G;
	double  curcond = 0.0, curvol = 0.0, curcut = 0.0;
	bcond = 2.0;

	//for ( mwIndex counter = 0, curindex = 0; counter < length_array; counter++, curindex++ ){
  for ( mwIndex counter = 0, curindex = 0; counter <= sw_end; counter++, curindex++ ){
		mwIndex curinterior = 0;
		mwIndex curnode = noderank[curindex];
		// move next neighbor into the local cut graph
		// and update current volume and current cut-edges
		for (mwIndex nzi = G->aj[curnode]; nzi < G->aj[curnode+1]; nzi++){
			mwIndex curneighb = G->ai[nzi];
			if (local_cut_G.map[curneighb] == 1){
				curinterior += 1;
			}
		}
		local_cut_G.map[curnode] = 1;
		curvol += (double) G->sr_degree(curnode);
		curcut += (double) ( G->sr_degree(curnode) - (double)2*curinterior );
		curcond = get_cond( curcut, curvol, total_volume);
		if ( (halfvol == 1) && (curvol >= total_volume/2.0) ){ break; }
    if ((curcond < bcond) && (curindex >= sw_start)) {
      bcond = curcond;
      bcut = curcut;
      bvol = curvol;
      bindex = curindex;
    }
	}

}

void copy_array_to_index_vector(const mxArray* v, std::vector<mwIndex>& vec)
{
    mxAssert(mxIsDouble(v), "array type is not double");
    size_t n = mxGetNumberOfElements(v);
    double *p = mxGetPr(v);

    vec.resize(n);

	sparsevec double_counter; // make sure we don't put any node in the array more than once.

    for (size_t i=0; i<n; ++i) {
        double elem = p[i];
        mxAssert(elem >= 1, "Only positive integer elements allowed");

		if (double_counter.map[elem] == 1){
			continue;
		}
		double_counter.map[elem] = 1;
        vec[i] = (mwIndex)elem - 1;
    }
}


// USAGE
// [bindex,bcond,bcut,bvol] = sweepcut_mex(A,noderank,halfvol,sweepstart, sweepend, debugflag)
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    // arguments/outputs error-checking
    if ( nrhs > 6 || nrhs < 2 ) {
        mexErrMsgIdAndTxt("sweepcut_mex:wrongNumberArguments",
                          "sweepcut_mex needs two to six arguments, not %i", nrhs);
    }
    if (nrhs == 6) {
        debugflag = (int)mxGetScalar(prhs[5]);
    }
    DEBUGPRINT(("sweepcut_mex: preprocessing start: \n"));
    if ( nlhs > 4 ){
        mexErrMsgIdAndTxt("sweepcut_mex:wrongNumberOutputs",
                          "sweepcut_mex needs 0 to 4 outputs, not %i", nlhs);
    }

    // Retrieve Sparse Matrix input
    const mxArray* mat = prhs[0];
    if ( mxIsSparse(mat) == false ){
        mexErrMsgIdAndTxt("sweepcut_mex:wrongInputMatrix",
                          "sweepcut_mex needs sparse input matrix");
    }
    if ( mxGetM(mat) != mxGetN(mat) ){
        mexErrMsgIdAndTxt("sweepcut_mex:wrongInputMatrixDimensions",
                          "sweepcut_mex needs square input matrix");
    }
    sparserow r;
    r.m = mxGetM(mat);
    r.n = mxGetN(mat);
    r.aj = mxGetJc(mat);
    r.ai = mxGetIr(mat);
    r.a = mxGetPr(mat);



    // Retrieve ordered node array
    const mxArray* set = prhs[1];
    std::vector< mwIndex > node_array;
    copy_array_to_index_vector( set, node_array );

	// Retrieve "half volume" flag
	int halfvol = 0;
  mwIndex sweep_start = 0;
  mwIndex sweep_end = node_array.size()-1;
	if (nrhs >= 3){ halfvol = (int) mxGetScalar(prhs[2]); }
  if (nrhs >= 4) { sweep_start = (mwIndex)mxGetScalar(prhs[3]) - 1; } // shift from matlab indices
  if (nrhs >= 5) { sweep_end = (mwIndex)mxGetScalar(prhs[4]) - 1; }

  if ( sweep_start > sweep_end ){
      mexErrMsgIdAndTxt("sweepcut_mex:incompatibleIndexRange",
                        "sweepcut_mex needs sweep start index <= sweep end index");
  }

// INPUTS DECODED
// now perform sweep procedure

    // Prepare outputs
    mxArray* conductanceMX = mxCreateDoubleMatrix(1,1,mxREAL);
    mxArray* cutMX = mxCreateDoubleMatrix(1,1,mxREAL);
    mxArray* volumeMX = mxCreateDoubleMatrix(1,1,mxREAL);
    mxArray* break_indexMX = mxCreateDoubleMatrix(1,1,mxREAL);
	double conductance, cut, volume;
	mwIndex break_index;
    if (nlhs > 0) { plhs[0] = break_indexMX; }
    if (nlhs > 1) { plhs[1] = conductanceMX; }
    if (nlhs > 2) { plhs[2] = cutMX; }
    if (nlhs > 3) { plhs[3] = volumeMX; }

    // input/outputs prepared!
    DEBUGPRINT(("sweepcut_mex: preprocessing end: \n"));

    // execute actual code
    sweepcut(&r, node_array, sweep_start, sweep_end, break_index, conductance, volume, cut, halfvol);

    DEBUGPRINT(("sweepcut_mex: call to sweepcut() done\n"));

	double* dummy = NULL;
	dummy = mxGetPr( conductanceMX ); *dummy = conductance;
	dummy = mxGetPr( break_indexMX ); *dummy = (double) break_index + 1.0 ; // shifting to matlab indexing
	dummy = mxGetPr( cutMX ); *dummy = cut;
	dummy = mxGetPr( volumeMX ); *dummy = volume;
}
