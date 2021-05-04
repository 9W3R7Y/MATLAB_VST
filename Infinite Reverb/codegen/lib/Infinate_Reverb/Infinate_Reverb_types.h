//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// Infinate_Reverb_types.h
//
// Code generation for function 'onParamChangeCImpl'
//

#ifndef INFINATE_REVERB_TYPES_H
#define INFINATE_REVERB_TYPES_H

// Include files
#include "Infinate_Reverb.h"
#include "rtwtypes.h"

// Type Definitions
struct Infinate_ReverbPersistentData {
  derivedAudioPlugin plugin;
  boolean_T plugin_not_empty;
  unsigned long long thisPtr;
  boolean_T thisPtr_not_empty;
  unsigned int state[625];
};

struct Infinate_ReverbStackData {
  struct {
    creal_T x_fft_allfreq[16384];
    creal_T x_fft[8192];
  } f0;
  Infinate_ReverbPersistentData *pd;
};

#endif
// End of code generation (Infinate_Reverb_types.h)
