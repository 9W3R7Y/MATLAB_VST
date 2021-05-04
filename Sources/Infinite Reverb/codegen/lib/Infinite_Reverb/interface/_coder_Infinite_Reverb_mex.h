//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_Infinite_Reverb_mex.h
//
// Code generation for function 'onParamChangeCImpl'
//

#ifndef _CODER_INFINITE_REVERB_MEX_H
#define _CODER_INFINITE_REVERB_MEX_H

// Include files
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"

// Function Declarations
MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS();

void unsafe_createPluginInstance_mexFunction(int32_T nlhs, int32_T nrhs,
                                             const mxArray *prhs[1]);

void unsafe_getLatencyInSamplesCImpl_mexFunction(int32_T nlhs, mxArray *plhs[1],
                                                 int32_T nrhs);

void unsafe_onParamChangeCImpl_mexFunction(int32_T nlhs, int32_T nrhs,
                                           const mxArray *prhs[2]);

void unsafe_processEntryPoint_mexFunction(int32_T nlhs, mxArray *plhs[2],
                                          int32_T nrhs, const mxArray *prhs[3]);

void unsafe_resetCImpl_mexFunction(int32_T nlhs, int32_T nrhs,
                                   const mxArray *prhs[1]);

#endif
// End of code generation (_coder_Infinite_Reverb_mex.h)
