clear all;
p = PitchShifter();Fs = 44100;
test_plugin_realtime(p,Fs,1024,10,false);