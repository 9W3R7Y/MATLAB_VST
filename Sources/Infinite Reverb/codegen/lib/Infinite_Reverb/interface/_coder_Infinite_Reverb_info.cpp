//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_Infinite_Reverb_info.cpp
//
// Code generation for function 'onParamChangeCImpl'
//

// Include files
#include "_coder_Infinite_Reverb_info.h"
#include "emlrt.h"
#include "tmwtypes.h"

// Function Declarations
static const mxArray *emlrtMexFcnResolvedFunctionsInfo();

// Function Definitions
static const mxArray *emlrtMexFcnResolvedFunctionsInfo()
{
  const mxArray *nameCaptureInfo;
  const char_T *data[8]{
      "789ced58cf52d34018df3a3832ce28d5193d7392f1e254680378b216904a4b0bad0c2371"
      "ca36f928b1c96e4836407909af1e7d0a9f416f1e9cd11790834f616a"
      "9ab20d84026923d5fd663adbafbfcdf76ff3fd76bb28912f261042779127a9c7de78c7fd"
      "1cbb9f64e7f71ba8578278a233dee2f4636efe4d34d67d8e9fffbe33",
      "2a943038649e42b001dd27556a680413566d99802cb0a9be0fea1f6447d3a1aa1950e195"
      "d5b6662c7150576943edefb95d509a15c740d6ae7d12a1ce2bdd7a7c"
      "e5f2455cbe6317ac4733a41eed79b7d16417df5a7c9b7b26bfb6c1b2e5157ce434b5c922"
      "66b6635046e5ac692e6086e50255b02e57c130656642663635afa695",
      "1a4829b596c6a9995a7d765aaaa9909166e6d2f5b49499952929630b1bb95d4c1a90cb1b"
      "a6fec4e8c9ef30627ef7cec98fc71bc0cabad3d0489ed80c13c55f5f"
      "3f8eed2bc61194b0387c19d4babeebe3cfc787b4aea7cad959d6bef59cb8607efc78dc33"
      "7f1c7d74c9e0d7f3ef8938fd695f1e7d8bd39f2f7fcb5fd4be7c18e2",
      "2f19c09d6973eea0bc59aaaf617deee5c6abbd56b6955b3a89a31c1287efa75f1c88d3f9"
      "38e2b23f4cfee6f1addc50fa5c054b73b7bbaca36ad46bf8007f9b11"
      "f39be0f4b3f2f3f13cd9d188c6a0b60efb60d523f376bff342b28338a449e801e9fafb1c"
      "d15f23d45f2f7eee7a2e50c53180305b5e70aba153b3adc8c56cb590",
      "7d51dba854e50a752c056cd9afdaa45735395045772de3e2979f31f3f5dad4f88738fdf9"
      "32aa7cfd20c45f3280abf5d572e16956b24a7bd2414a5a2fcdd39d22"
      "127c3d2ae7b2a8efc9fd3ef9f9f8e98da3378eed2bc61194b8cedbd77d1fde0ec96f54cf"
      "db9f604a9cb7d1e0f9db7d738e96571637e7d32b47cb991294de3069",
      "0dfd3bfc1df57ca684d84f06f021f1b7053630714ff2ffecc7db21f98d2a6f8b7b124fc4"
      "3dc9e5ec8f789f9b1675ff6fdb8b8459ad32d5081bf4b95bf0b7e0ef"
      "38fc09fef644f0f7e5ec47ed7323c47e32800fa9cf150b3083335a5df0f7d5fc09fe16fc"
      "1d873fc1df83b1ff23c4fe45ebb817623f19c087d7e70597c089d2ca",
      "930a364c1d6cfe1645f0b8e0f1f3f3133cee89e0f1b3e3b8ee3cfe1bd28b9c0e",
      ""};
  nameCaptureInfo = nullptr;
  emlrtNameCaptureMxArrayR2016a(&data[0], 10568U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties()
{
  mxArray *xEntryPoints;
  mxArray *xInputs;
  mxArray *xResult;
  const char_T *epFieldName[6]{
      "Name",           "NumberOfInputs", "NumberOfOutputs",
      "ConstantInputs", "FullPath",       "TimeStamp"};
  const char_T *propFieldName[5]{"Version", "ResolvedFunctions", "EntryPoints",
                                 "CoverageInfo", "IsPolymorphic"};
  xEntryPoints =
      emlrtCreateStructMatrix(1, 5, 6, (const char_T **)&epFieldName[0]);
  xInputs = emlrtCreateLogicalMatrix(1, 2);
  emlrtSetField(xEntryPoints, 0, (const char_T *)"Name",
                emlrtMxCreateString((const char_T *)"onParamChangeCImpl"));
  emlrtSetField(xEntryPoints, 0, (const char_T *)"NumberOfInputs",
                emlrtMxCreateDoubleScalar(2.0));
  emlrtSetField(xEntryPoints, 0, (const char_T *)"NumberOfOutputs",
                emlrtMxCreateDoubleScalar(0.0));
  emlrtSetField(xEntryPoints, 0, (const char_T *)"ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 0, (const char_T *)"FullPath",
      emlrtMxCreateString(
          (const char_T *)"C:\\Users\\Kazuki "
                          "Matsumoto\\AppData\\Local\\Temp\\tpe5709d4c_e60d_"
                          "4a03_b726_de56384b4657\\onParamChangeCImpl.m"));
  emlrtSetField(xEntryPoints, 0, (const char_T *)"TimeStamp",
                emlrtMxCreateDoubleScalar(738280.94369212969));
  xInputs = emlrtCreateLogicalMatrix(1, 1);
  emlrtSetField(xEntryPoints, 1, (const char_T *)"Name",
                emlrtMxCreateString((const char_T *)"resetCImpl"));
  emlrtSetField(xEntryPoints, 1, (const char_T *)"NumberOfInputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 1, (const char_T *)"NumberOfOutputs",
                emlrtMxCreateDoubleScalar(0.0));
  emlrtSetField(xEntryPoints, 1, (const char_T *)"ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 1, (const char_T *)"FullPath",
      emlrtMxCreateString(
          (const char_T *)"C:\\Users\\Kazuki "
                          "Matsumoto\\AppData\\Local\\Temp\\tpe5709d4c_e60d_"
                          "4a03_b726_de56384b4657\\resetCImpl.m"));
  emlrtSetField(xEntryPoints, 1, (const char_T *)"TimeStamp",
                emlrtMxCreateDoubleScalar(738280.94369212969));
  xInputs = emlrtCreateLogicalMatrix(1, 3);
  emlrtSetField(xEntryPoints, 2, (const char_T *)"Name",
                emlrtMxCreateString((const char_T *)"processEntryPoint"));
  emlrtSetField(xEntryPoints, 2, (const char_T *)"NumberOfInputs",
                emlrtMxCreateDoubleScalar(3.0));
  emlrtSetField(xEntryPoints, 2, (const char_T *)"NumberOfOutputs",
                emlrtMxCreateDoubleScalar(2.0));
  emlrtSetField(xEntryPoints, 2, (const char_T *)"ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 2, (const char_T *)"FullPath",
      emlrtMxCreateString(
          (const char_T *)"C:\\Users\\Kazuki "
                          "Matsumoto\\AppData\\Local\\Temp\\tpe5709d4c_e60d_"
                          "4a03_b726_de56384b4657\\processEntryPoint.m"));
  emlrtSetField(xEntryPoints, 2, (const char_T *)"TimeStamp",
                emlrtMxCreateDoubleScalar(738280.94369212969));
  xInputs = emlrtCreateLogicalMatrix(1, 1);
  emlrtSetField(xEntryPoints, 3, (const char_T *)"Name",
                emlrtMxCreateString((const char_T *)"createPluginInstance"));
  emlrtSetField(xEntryPoints, 3, (const char_T *)"NumberOfInputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 3, (const char_T *)"NumberOfOutputs",
                emlrtMxCreateDoubleScalar(0.0));
  emlrtSetField(xEntryPoints, 3, (const char_T *)"ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 3, (const char_T *)"FullPath",
      emlrtMxCreateString(
          (const char_T *)"C:\\Users\\Kazuki "
                          "Matsumoto\\AppData\\Local\\Temp\\tpe5709d4c_e60d_"
                          "4a03_b726_de56384b4657\\createPluginInstance.m"));
  emlrtSetField(xEntryPoints, 3, (const char_T *)"TimeStamp",
                emlrtMxCreateDoubleScalar(738280.94369212969));
  xInputs = emlrtCreateLogicalMatrix(1, 0);
  emlrtSetField(
      xEntryPoints, 4, (const char_T *)"Name",
      emlrtMxCreateString((const char_T *)"getLatencyInSamplesCImpl"));
  emlrtSetField(xEntryPoints, 4, (const char_T *)"NumberOfInputs",
                emlrtMxCreateDoubleScalar(0.0));
  emlrtSetField(xEntryPoints, 4, (const char_T *)"NumberOfOutputs",
                emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 4, (const char_T *)"ConstantInputs", xInputs);
  emlrtSetField(
      xEntryPoints, 4, (const char_T *)"FullPath",
      emlrtMxCreateString((
          const char_T *)"C:\\Users\\Kazuki "
                         "Matsumoto\\AppData\\Local\\Temp\\tpe5709d4c_e60d_"
                         "4a03_b726_de56384b4657\\getLatencyInSamplesCImpl.m"));
  emlrtSetField(xEntryPoints, 4, (const char_T *)"TimeStamp",
                emlrtMxCreateDoubleScalar(738280.94369212969));
  xResult =
      emlrtCreateStructMatrix(1, 1, 5, (const char_T **)&propFieldName[0]);
  emlrtSetField(xResult, 0, (const char_T *)"Version",
                emlrtMxCreateString((const char_T *)"9.10.0.1602886 (R2021a)"));
  emlrtSetField(xResult, 0, (const char_T *)"ResolvedFunctions",
                (mxArray *)emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, (const char_T *)"EntryPoints", xEntryPoints);
  return xResult;
}

// End of code generation (_coder_Infinite_Reverb_info.cpp)
