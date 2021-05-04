//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// Infinite_Reverb.h
//
// Code generation for function 'Infinite_Reverb'
//

#ifndef INFINITE_REVERB_H
#define INFINITE_REVERB_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Type Declarations
struct Infinite_ReverbStackData;

// Type Definitions
class derivedAudioPlugin {
public:
  void process(Infinite_ReverbStackData *SD,
               const coder::array<double, 2U> &x_frame,
               coder::array<double, 2U> &y_frame);
  derivedAudioPlugin();
  ~derivedAudioPlugin();
  double PrivateSampleRate;
  int PrivateLatency;
  double n;
  double x_buff[16384];
  double y_buff[16384];
  double s_buff[16384];
  double spectrum_buff[8192];
  double amp_db;
  double sustain;
  double low;
  double high;
  double init_att;
};

// Function Declarations
extern void Infinite_Reverb_initialize(Infinite_ReverbStackData *SD);

extern void Infinite_Reverb_terminate();

extern void createPluginInstance(Infinite_ReverbStackData *SD,
                                 unsigned long long thisPtr);

extern int getLatencyInSamplesCImpl(Infinite_ReverbStackData *SD);

extern void onParamChangeCImpl(Infinite_ReverbStackData *SD, int paramIdx,
                               double value);

extern void processEntryPoint(Infinite_ReverbStackData *SD,
                              double samplesPerFrame, const double i1_data[],
                              const int i1_size[1], const double i2_data[],
                              const int i2_size[1], double o1_data[],
                              int o1_size[1], double o2_data[], int o2_size[1]);

extern void resetCImpl(Infinite_ReverbStackData *SD, double rate);

#endif
// End of code generation (Infinite_Reverb.h)
