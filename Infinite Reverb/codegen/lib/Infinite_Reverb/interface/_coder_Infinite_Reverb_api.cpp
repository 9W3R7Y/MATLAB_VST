//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_Infinite_Reverb_api.cpp
//
// Code generation for function 'onParamChangeCImpl'
//

// Include files
#include "_coder_Infinite_Reverb_api.h"
#include "_coder_Infinite_Reverb_mex.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131610U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "Infinite_Reverb",                                    // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

// Function Declarations
static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *value,
                                 const char_T *identifier);

static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId);

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               real_T **ret_data, int32_T *ret_size);

static uint64_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *thisPtr,
                                   const char_T *identifier);

static uint64_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId);

static int32_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                  const emlrtMsgIdentifier *msgId);

static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId);

static int32_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *paramIdx,
                                const char_T *identifier);

static int32_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                const emlrtMsgIdentifier *parentId);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *i1,
                             const char_T *identifier, real_T **y_data,
                             int32_T *y_size);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             real_T **y_data, int32_T *y_size);

static const mxArray *emlrt_marshallOut(const real_T u_data[],
                                        const int32_T *u_size);

static const mxArray *emlrt_marshallOut(const int32_T u);

static uint64_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId);

// Function Definitions
static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *value,
                                 const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  real_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(value), &thisId);
  emlrtDestroyArray(&value);
  return y;
}

static real_T b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                 const emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = e_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               real_T **ret_data, int32_T *ret_size)
{
  static const int32_T dims{4096};
  const boolean_T b{true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                            false, 1U, (void *)&dims, &b, ret_size);
  *ret_data = (real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
}

static uint64_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *thisPtr,
                                   const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  uint64_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = c_emlrt_marshallIn(sp, emlrtAlias(thisPtr), &thisId);
  emlrtDestroyArray(&thisPtr);
  return y;
}

static uint64_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                   const emlrtMsgIdentifier *parentId)
{
  uint64_T y;
  y = f_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static int32_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                  const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  int32_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"int32",
                          false, 0U, (void *)&dims);
  ret = *(int32_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real_T e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                 const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  real_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                          false, 0U, (void *)&dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static int32_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *paramIdx,
                                const char_T *identifier)
{
  emlrtMsgIdentifier thisId;
  int32_T y;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  y = emlrt_marshallIn(sp, emlrtAlias(paramIdx), &thisId);
  emlrtDestroyArray(&paramIdx);
  return y;
}

static int32_T emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                                const emlrtMsgIdentifier *parentId)
{
  int32_T y;
  y = d_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *i1,
                             const char_T *identifier, real_T **y_data,
                             int32_T *y_size)
{
  emlrtMsgIdentifier thisId;
  real_T *r;
  int32_T i;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(i1), &thisId, &r, &i);
  *y_size = i;
  *y_data = r;
  emlrtDestroyArray(&i1);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             real_T **y_data, int32_T *y_size)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y_data, y_size);
  emlrtDestroyArray(&u);
}

static const mxArray *emlrt_marshallOut(const real_T u_data[],
                                        const int32_T *u_size)
{
  static const int32_T i{0};
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericArray(1, (const void *)&i, mxDOUBLE_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m, (void *)&u_data[0]);
  emlrtSetDimensions((mxArray *)m, u_size, 1);
  emlrtAssign(&y, m);
  return y;
}

static const mxArray *emlrt_marshallOut(const int32_T u)
{
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
  *(int32_T *)emlrtMxGetData(m) = u;
  emlrtAssign(&y, m);
  return y;
}

static uint64_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                                   const emlrtMsgIdentifier *msgId)
{
  static const int32_T dims{0};
  uint64_T ret;
  emlrtCheckBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"uint64",
                          false, 0U, (void *)&dims);
  ret = *(uint64_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void Infinite_Reverb_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  Infinite_Reverb_xil_terminate();
  Infinite_Reverb_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void Infinite_Reverb_initialize()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

void Infinite_Reverb_terminate()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

void createPluginInstance_api(const mxArray *prhs)
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  uint64_T thisPtr;
  st.tls = emlrtRootTLSGlobal;
  // Marshall function inputs
  thisPtr = c_emlrt_marshallIn(&st, emlrtAliasP(prhs), "thisPtr");
  // Invoke the target function
  createPluginInstance(thisPtr);
}

void getLatencyInSamplesCImpl_api(const mxArray **plhs)
{
  int32_T n;
  // Invoke the target function
  n = getLatencyInSamplesCImpl();
  // Marshall function outputs
  *plhs = emlrt_marshallOut(n);
}

void onParamChangeCImpl_api(const mxArray *const prhs[2])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T value;
  int32_T paramIdx;
  st.tls = emlrtRootTLSGlobal;
  // Marshall function inputs
  paramIdx = emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "paramIdx");
  value = b_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "value");
  // Invoke the target function
  onParamChangeCImpl(paramIdx, value);
}

void processEntryPoint_api(const mxArray *const prhs[3], int32_T nlhs,
                           const mxArray *plhs[2])
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T(*i1_data)[4096];
  real_T(*i2_data)[4096];
  real_T(*o1_data)[4096];
  real_T(*o2_data)[4096];
  real_T samplesPerFrame;
  int32_T i1_size;
  int32_T i2_size;
  int32_T o1_size;
  int32_T o2_size;
  st.tls = emlrtRootTLSGlobal;
  o1_data = (real_T(*)[4096])mxMalloc(sizeof(real_T[4096]));
  o2_data = (real_T(*)[4096])mxMalloc(sizeof(real_T[4096]));
  // Marshall function inputs
  samplesPerFrame =
      b_emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "samplesPerFrame");
  emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "i1", (real_T **)&i1_data,
                   &i1_size);
  emlrt_marshallIn(&st, emlrtAlias(prhs[2]), "i2", (real_T **)&i2_data,
                   &i2_size);
  // Invoke the target function
  processEntryPoint(samplesPerFrame, *i1_data, *(int32_T(*)[1]) & i1_size,
                    *i2_data, *(int32_T(*)[1]) & i2_size, *o1_data,
                    *(int32_T(*)[1]) & o1_size, *o2_data,
                    *(int32_T(*)[1]) & o2_size);
  // Marshall function outputs
  plhs[0] = emlrt_marshallOut(*o1_data, &o1_size);
  if (nlhs > 1) {
    plhs[1] = emlrt_marshallOut(*o2_data, &o2_size);
  }
}

void resetCImpl_api(const mxArray *prhs)
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T rate;
  st.tls = emlrtRootTLSGlobal;
  // Marshall function inputs
  rate = b_emlrt_marshallIn(&st, emlrtAliasP(prhs), "rate");
  // Invoke the target function
  resetCImpl(rate);
}

// End of code generation (_coder_Infinite_Reverb_api.cpp)
