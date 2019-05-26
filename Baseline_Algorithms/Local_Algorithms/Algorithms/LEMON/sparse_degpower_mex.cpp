/**
 * @file sparse_degpower_mex.cpp
 * @author Kyle Kloster
 */

/**
 * Scales sparse input vector by degrees of sparse input matrix.
 * The input matrix must be in matlab sparse format.
 * The input vector must be input in a "sparse way" (check below for details.)
 */



#ifndef __APPLE__
#define __STDC_UTF_16__ 1
#endif

#include <vector>
#include <assert.h>
#include <math.h>

#include "mex.h"

typedef long unsigned int luint;

#define DEBUGPRINT(x) do { if (debugflag) { \
mexPrintf x; mexEvalString("drawnow"); } \
} while (0)

int debugflag = 0;

struct sparserow{
    mwSize n, m;
    luint *ai;
    luint *aj;
    double *a;
    double volume;

    /**
     * Returns the degree of node u in sparserow s
     */
    luint sr_degree( luint u) {
        return (ai[u+1] - ai[u]);
    }
};

// USAGE
// to compute y = D^{power}*v for D the diagonal matrix of out-degrees of input matrix A.
// [v_scaled] = sparse_degpower_mex(A,v,power,debugflag)
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{

    int max_num_inputs = 4;
    if (nrhs < 2 || nrhs > max_num_inputs) {
        mexErrMsgIdAndTxt("sparse_degpower_mex:wrongNumberArguments",
                          "sparse_degpower_mex needs 2 to %i arguments, not %i", max_num_inputs, nrhs);
    }
    if (nlhs > 1 || nlhs < 1) {
        mexErrMsgIdAndTxt("sparse_degpower_mex:wrongNumberOutputs",
                          "sparse_degpower_mex needs 1 output, not %i", nlhs);
    }
    if (nrhs == max_num_inputs) {
        debugflag = (int)mxGetScalar(prhs[max_num_inputs-1]);
    }
    DEBUGPRINT(("\n sparse_degpower_mex: preprocessing start"));

    const mxArray* mat = prhs[0];
    const mxArray* set = prhs[1];

    // Decode sparse input matrix A
    if ( mxIsSparse(mat) == false ){
        mexErrMsgIdAndTxt("sparse_degpower_mex:wrongInputMatrix",
                          "sparse_degpower_mex needs sparse input matrix A");
    }
    if ( mxGetM(mat) != mxGetN(mat) ){
        mexErrMsgIdAndTxt("sparse_degpower_mex:wrongInputMatrixDimensions",
                          "sparse_degpower_mex needs square input matrix");
    }
    sparserow G;
    G.m = mxGetM(mat);
    G.n = mxGetN(mat);
    G.ai = mxGetJc(mat);
    G.aj = mxGetIr(mat);
    G.a = mxGetPr(mat);

    // Get parameters
    double power = 1.0;
    if (nrhs >= 3) { power = (double)mxGetScalar(prhs[2]);}
    DEBUGPRINT(("\n            parameters obtained"));

    // Decode input "vector"
    mxAssert( mxIsSparse(set) == true , "Invalid format for input: must be sparse vector");

    sparserow v;
    v.m = mxGetM(set);
    v.n = mxGetN(set);
    v.ai = mxGetJc(set);
    v.aj = mxGetIr(set);
    v.a = mxGetPr(set);
    mxAssert(v.n == 1, "Invalid format for input: must be sparse vector");
    if ( G.n != v.m ){
        mexErrMsgIdAndTxt("sparse_degpower_mex:wrongInputMatrixDimensions",
                          "sparse_degpower_mex needs compatible matrix and vector dimensions");
    }
    luint num_output = v.ai[1];
    DEBUGPRINT(("\n            sparse data structures decoded"));

    DEBUGPRINT(("\n Now prepare outputs."));
    if (nlhs > 0) { // sets output
        mxArray* ci_mex = mxCreateDoubleMatrix( num_output, 2, mxREAL);
        plhs[0] = ci_mex;
        double *ci = mxGetPr(ci_mex);
        for ( luint counter = 0; counter < num_output; counter++) {
            double valind = v.a[counter];
            luint gind = v.aj[counter];
            ci[ counter ] = gind + 1; // index
            double scalar = 0.0;
            double deg = (double)G.sr_degree(gind);
            if ( deg != 0.0 ){ scalar = pow(deg, power); }
            ci[ counter + num_output ] = valind * scalar; // value
        }
    }

}
