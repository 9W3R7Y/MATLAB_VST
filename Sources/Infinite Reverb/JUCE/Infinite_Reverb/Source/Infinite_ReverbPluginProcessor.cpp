#include "../JuceLibraryCode/JuceHeader.h"

#include "Infinite_Reverb.h"
#include "Infinite_Reverb_types.h"

#if JUCE_VERSION >= 0x050400
using Parameter = AudioProcessorValueTreeState::Parameter;
#endif

struct onParamChangeListener : AudioProcessorValueTreeState::Listener
{
    onParamChangeListener(Infinite_ReverbStackData* sd)
    : SD(sd)
    {
    }
    
    void parameterChanged (const String& parameterID, float newValue) override
    {
	    (void)parameterID;
	    int idx = -1;
        if (parameterID == "sustain") {
            idx = 0;
        } else if (parameterID == "low") {
            idx = 1;
        } else if (parameterID == "high") {
            idx = 2;
        } else if (parameterID == "init_att") {
            idx = 3;
        } else if (parameterID == "amp_db") {
            idx = 4;
        }
		onParamChangeCImpl(SD, idx, static_cast<double>(newValue));
    }

    Infinite_ReverbStackData *SD;
};

//==============================================================================
class Infinite_ReverbAudioProcessor  : public AudioProcessor
{
    //==============================================================================
#if JUCE_VERSION >= 0x050400

public:
    Infinite_ReverbAudioProcessor()
        : paramListener(&mStackData),
          parameters(*this, nullptr, "Infinite_Reverb", {
                std::make_unique<Parameter>("sustain", "Sustain", "%/s",
                    NormalisableRange<float>(0.f,1.f), 1.f, [](float val) {return String(val, 3);}, nullptr),
                std::make_unique<Parameter>("low", "Sustain (Low Freq)", "%/s",
                    NormalisableRange<float>(0.f,1.f), 1.f, [](float val) {return String(val, 3);}, nullptr),
                std::make_unique<Parameter>("high", "Sustain (High Freq)", "%/s",
                    NormalisableRange<float>(0.f,1.f), 1.f, [](float val) {return String(val, 3);}, nullptr),
                std::make_unique<Parameter>("init_att", "Initial Attenuation", "",
                    NormalisableRange<float>(0.f,10.f), 0.f, [](float val) {return String(val, 3);}, nullptr),
                std::make_unique<Parameter>("amp_db", "Amp", "",
                    NormalisableRange<float>(-40.f,0.f), 0.f, [](float val) {return String(val, 3);}, nullptr) })

    {
        mStackData.pd = &mPersistentData;
        
        Infinite_Reverb_initialize(&mStackData);

        createPluginInstance(&mStackData, reinterpret_cast<unsigned long long>(this));

        parameters.addParameterListener("sustain", &paramListener);
        parameters.addParameterListener("low", &paramListener);
        parameters.addParameterListener("high", &paramListener);
        parameters.addParameterListener("init_att", &paramListener);
        parameters.addParameterListener("amp_db", &paramListener);

    }
    //==============================================================================
#else // For JUCE prior to 5.4.0
public:
    Infinite_ReverbAudioProcessor()
    :   paramListener(&mStackData), parameters (*this, nullptr)
    {
        mStackData.pd = &mPersistentData;
        
        Infinite_Reverb_initialize(&mStackData);

        createPluginInstance(&mStackData, reinterpret_cast<unsigned long long>(this));

        //
        // Parameter property sustain
        //
        parameters.createAndAddParameter ("sustain", "Sustain", "%/s",
            NormalisableRange<float>(0.f, 1.f), 1.f,
            [](float val) {return String(val, 3);},
            nullptr);
        parameters.addParameterListener("sustain", &paramListener);

        //
        // Parameter property low
        //
        parameters.createAndAddParameter ("low", "Sustain (Low Freq)", "%/s",
            NormalisableRange<float>(0.f, 1.f), 1.f,
            [](float val) {return String(val, 3);},
            nullptr);
        parameters.addParameterListener("low", &paramListener);

        //
        // Parameter property high
        //
        parameters.createAndAddParameter ("high", "Sustain (High Freq)", "%/s",
            NormalisableRange<float>(0.f, 1.f), 1.f,
            [](float val) {return String(val, 3);},
            nullptr);
        parameters.addParameterListener("high", &paramListener);

        //
        // Parameter property init_att
        //
        parameters.createAndAddParameter ("init_att", "Initial Attenuation", "",
            NormalisableRange<float>(0.f, 10.f), 0.f,
            [](float val) {return String(val, 3);},
            nullptr);
        parameters.addParameterListener("init_att", &paramListener);

        //
        // Parameter property amp_db
        //
        parameters.createAndAddParameter ("amp_db", "Amp", "",
            NormalisableRange<float>(-40.f, 0.f), 0.f,
            [](float val) {return String(val, 3);},
            nullptr);
        parameters.addParameterListener("amp_db", &paramListener);

        parameters.state = ValueTree(Identifier("Infinite_Reverb"));
    }
#endif

    //==============================================================================
    ~Infinite_ReverbAudioProcessor()
    {
        Infinite_Reverb_terminate();
    }
    
    //==============================================================================
    void prepareToPlay (double sampleRate, int samplesPerBlock) override
    {
        (void)samplesPerBlock;
        resetCImpl(&mStackData, sampleRate);
        setLatencySamples(getLatencyInSamplesCImpl(&mStackData));
    }

    void releaseResources() override                { }
    
    
    void processBlock (AudioBuffer<double>& buffer, MidiBuffer& midiMessages) override
    {
        (void)midiMessages;
        ScopedNoDenormals noDenormals;
        const double** inputs = buffer.getArrayOfReadPointers();
        double** outputs = buffer.getArrayOfWritePointers();
        int nSamples = buffer.getNumSamples();
        Infinite_ReverbStackData *SD = &mStackData;

        int osz0_;
        int osz1_;
        if (nSamples <= MAX_SAMPLES_PER_FRAME) {
            /* Fast path for common frame sizes. */
            int isz0_ = nSamples;
            int isz1_ = nSamples;
            processEntryPoint(SD, (double)nSamples,
                    inputs[0], &isz0_,
                    inputs[1], &isz1_,
                    outputs[0], &osz0_,
                    outputs[1], &osz1_);
        } else {
            /* Fallback for unusually large frames. */
            int isz0_ = MAX_SAMPLES_PER_FRAME;
            int isz1_ = MAX_SAMPLES_PER_FRAME;
            int n = MAX_SAMPLES_PER_FRAME;
            for (int i_ = 0; i_ < nSamples; i_ += MAX_SAMPLES_PER_FRAME) {
                if (i_ + MAX_SAMPLES_PER_FRAME > nSamples) {
                    n = nSamples - i_;
                    isz0_ = nSamples - i_;
                    isz1_ = nSamples - i_;
                }
                processEntryPoint(SD, (double)n,
                        inputs[0]+i_, &isz0_,
                        inputs[1]+i_, &isz1_,
                        outputs[0]+i_, &osz0_,
                        outputs[1]+i_, &osz1_);
            }
        }

    }
    
    void processBlock (AudioBuffer<float>& buffer,  MidiBuffer& midiMessages) override
    {
        (void)midiMessages;
        AudioBuffer<double> doubleBuffer;
        doubleBuffer.makeCopyOf(buffer);
        processBlock(doubleBuffer, midiMessages);
        buffer.makeCopyOf(doubleBuffer);
    }
    
    //==============================================================================
    bool hasEditor() const override                 { return true; }
    AudioProcessorEditor* createEditor() override;
    
    //==============================================================================
    const String getName() const override           { return JucePlugin_Name; }

    bool acceptsMidi() const override               { return false; }
    bool producesMidi() const override              { return false; }
    bool isMidiEffect () const override             { return false; }
    double getTailLengthSeconds() const override    { return 0.0;   }

    //==============================================================================
    // NB: some hosts don't cope very well if you tell them there are 0 programs,
    // so this should be at least 1, even if you're not really implementing programs.
    int getNumPrograms() override                       { return 1;  }
    int getCurrentProgram() override                    { return 0;  }
    void setCurrentProgram (int index) override         { (void) index; }
    const String getProgramName (int index) override    { (void) index; return {}; }
    void changeProgramName (int index, const String& newName) override  { (void) index; (void) newName; }
    
    //==============================================================================
    void getStateInformation (MemoryBlock& destData) override
    {
        auto xml (parameters.state.createXml());
        copyXmlToBinary (*xml, destData);
    }
    
    void setStateInformation (const void* data, int sizeInBytes) override
    {
        auto xmlState (getXmlFromBinary (data, sizeInBytes));
        if (xmlState != nullptr)
            if (xmlState->hasTagName (parameters.state.getType()))
                parameters.state = ValueTree::fromXml (*xmlState);
    }
    
    bool supportsDoublePrecisionProcessing() const override  { return true; }
    
private:
    //==============================================================================
    static const int MAX_SAMPLES_PER_FRAME = 4096;

    Infinite_ReverbStackData mStackData;
    Infinite_ReverbPersistentData mPersistentData;
    onParamChangeListener paramListener;
    
    //==============================================================================
    AudioProcessorValueTreeState parameters;
 
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (Infinite_ReverbAudioProcessor)
};

//==============================================================================
// This creates new instances of the plugin..
AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new Infinite_ReverbAudioProcessor();
}

#include "Infinite_ReverbPluginEditor.h"

AudioProcessorEditor* Infinite_ReverbAudioProcessor::createEditor()
{
    return new Infinite_ReverbAudioProcessorEditor(*this, parameters);
}

