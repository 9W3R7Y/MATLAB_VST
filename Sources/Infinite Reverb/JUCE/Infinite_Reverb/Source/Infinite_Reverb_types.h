//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// Infinite_Reverb_types.h
//
// Code generation for function 'onParamChangeCImpl'
//

#ifndef INFINITE_REVERB_TYPES_H
#define INFINITE_REVERB_TYPES_H

// Include files
#include "Infinite_Reverb.h"
#include "rtwtypes.h"

// Type Definitions
struct Infinite_ReverbPersistentData {
  derivedAudioPlugin plugin;
  boolean_T plugin_not_empty;
  unsigned long long thisPtr;
  boolean_T thisPtr_not_empty;
  unsigned int state[625];
};

struct Infinite_ReverbStackData {
  struct {
    creal_T x_fft_allfreq[16384];
    creal_T x_fft[8192];
  } f0;
  Infinite_ReverbPersistentData *pd;
};

#endif
// End of code generation (Infinite_Reverb_types.h)
