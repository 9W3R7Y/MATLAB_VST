#pragma once

typedef AudioProcessorValueTreeState::SliderAttachment   SliderAttachment;
typedef AudioProcessorValueTreeState::ButtonAttachment   ButtonAttachment;
typedef AudioProcessorValueTreeState::ComboBoxAttachment ComboBoxAttachment;

enum DisplayNamePosition { DisplayNameNone, DisplayNameLeft, DisplayNameRight, DisplayNameAbove, DisplayNameBelow };

Colour getBackgroundColor()
{
    return Colour::fromFloatRGBA(0.9375f, 0.9375f, 0.9375f, 1.f);
}

Colour getForegroundColor()
{
    return Colours::black;
}

class AppDesLookAndFeel : public LookAndFeel_V4
{
public:
    AppDesLookAndFeel()
    {
        setColour(PopupMenu::backgroundColourId, Colour(0xFFF9F9F9));
        setColour(PopupMenu::textColourId, Colours::black);
        setColour(PopupMenu::highlightedBackgroundColourId, Colour(0xFFA6DBFF));
        setColour(PopupMenu::highlightedTextColourId, Colours::black);
        setColour(PopupMenu::headerTextColourId, Colours::cyan);
        setColour(ComboBox::backgroundColourId, Colour(0xFFF5F5F5));
        setColour(ComboBox::textColourId, Colours::black);
        setColour(ComboBox::outlineColourId, Colour(0xFF999999));
        setColour(ComboBox::buttonColourId, Colours::cyan);
        setColour(ComboBox::arrowColourId, Colours::black);
        setColour(ComboBox::focusedOutlineColourId, Colours::magenta);
    }

    void drawToggleButton(Graphics& g, ToggleButton& button,
        bool isMouseOverButton, bool isButtonDown) override
    {
        auto fontSize = jmin(15.0f, button.getHeight() * 0.75f);
        auto tickWidth = fontSize;

        drawTickBox(g, button, 4.0f, (button.getHeight() - tickWidth) * 0.5f,
            tickWidth, tickWidth,
            button.getToggleState(),
            button.isEnabled(),
            isMouseOverButton,
            isButtonDown);

        g.setColour(button.findColour(ToggleButton::textColourId));
        g.setFont(fontSize);

        if (!button.isEnabled())
            g.setOpacity(0.5f);

        g.drawFittedText(button.getButtonText(),
            button.getLocalBounds().withTrimmedLeft(roundToInt(tickWidth) + 10)
            .withTrimmedRight(2),
            Justification::centredLeft, 10);
    }

    void drawTickBox(Graphics& g, Component& component,
        float x, float y, float w, float h,
        const bool ticked,
        const bool isEnabled,
        const bool isMouseOverButton,
        const bool isButtonDown) override
    {
        ignoreUnused(isEnabled, isMouseOverButton, isButtonDown);

        Rectangle<float> tickBounds(x, y, w, h);

        g.setColour(Colours::white);
        g.fillRect(tickBounds);
        g.setColour(Colour(0xFF999999));
        g.drawRect(tickBounds, 0.6f);

        if (ticked)
        {
            g.setColour(Colours::black);
            auto tick = getTickShape(0.75f);
            g.fillPath(tick, tick.getTransformToScaleToFit(tickBounds.reduced(2, 3).toFloat(), false));
        }
    }

    void drawComboBox(Graphics& g, int width, int height, bool,
        int, int, int, int, ComboBox& box) override
    {
        auto cornerSize = 5.0f;
        Rectangle<int> boxBounds(0, 0, width, height);

        g.setColour(box.findColour(ComboBox::backgroundColourId));
        g.fillRoundedRectangle(boxBounds.toFloat(), cornerSize);

        g.setColour(box.findColour(ComboBox::outlineColourId));
        g.drawRoundedRectangle(boxBounds.toFloat().reduced(0.5f, 0.5f), cornerSize, 1.0f);

        Path path;
        float x = width - 15.f;
        float y = height / 2.f - 3;
        path.startNewSubPath(x, y);
        path.lineTo(x+4, y+7);
        path.lineTo(x+8, y);
        path.closeSubPath();
        g.setColour(box.findColour(ComboBox::arrowColourId));
        g.fillPath(path);

    }

    void drawLinearSlider(Graphics& g, int x, int y, int width, int height,
        float sliderPos,
        float minSliderPos,
        float maxSliderPos,
        const Slider::SliderStyle style, Slider& slider) override
    {

        Colour trackColor(0xFF999999);
        Colour thumbLineColor(0xFFA6A6A6);
        Colour thumbFillColor(0xFFF5F5F5);
        Colour tickColor(0xFF000000);

        auto trackWidth = jmin(3.0f, slider.isHorizontal() ? height * 0.25f : width * 0.25f);

        Point<float> startPoint(slider.isHorizontal() ? x : x + width * 0.5f,
            slider.isHorizontal() ? y + height * 0.5f : height + y);

        Point<float> endPoint(slider.isHorizontal() ? width + x : startPoint.x,
            slider.isHorizontal() ? startPoint.y : y);

        Path backgroundTrack;
        backgroundTrack.startNewSubPath(startPoint);
        backgroundTrack.lineTo(endPoint);
        g.setColour(trackColor);
        g.strokePath(backgroundTrack, { trackWidth, PathStrokeType::mitered, PathStrokeType::butt });

        float tickSpace = 7.f;
        float tickLen = 8.f;
        float tickWid = 1.f;
        g.setColour(tickColor);
        if (slider.isHorizontal()) {
            float tickX = startPoint.x;
            float tickY = startPoint.y + tickSpace;
            float len = endPoint.x - startPoint.x;
            Rectangle<float> tick(tickX, tickY, tickWid, tickLen);
            g.fillRect(tick);
            g.fillRect(tick.withX(tickX + len / 4.f));
            g.fillRect(tick.withX(tickX + len / 2.f));
            g.fillRect(tick.withX(tickX + 3 * len / 4.f));
            g.fillRect(tick.withX(tickX + len));
        }
        else
        {
            float tickX = startPoint.x + tickSpace;
            float tickY = startPoint.y;
            float len = endPoint.y - startPoint.y;
            Rectangle<float> tick(tickX, tickY, tickLen, tickWid);
            g.fillRect(tick);
            g.fillRect(tick.withY(tickY + len / 4.f));
            g.fillRect(tick.withY(tickY + len / 2.f));
            g.fillRect(tick.withY(tickY + 3 * len / 4.f));
            g.fillRect(tick.withY(tickY + len));
        }

        float kx = slider.isHorizontal() ? sliderPos : (x + width * 0.5f);
        float ky = slider.isHorizontal() ? (y + height * 0.5f) : sliderPos;
        const float w = 5.f;
        const float h1 = 6.f;
        const float h2 = 7.f;
        const float align = 6.f;
        Path thumb;
        if (slider.isHorizontal()) {
            ky += align;
            thumb.startNewSubPath(kx, ky);
            thumb.lineTo(kx - w, ky - h1);
            thumb.lineTo(kx - w, ky - h1 - h2);
            thumb.lineTo(kx + w, ky - h1 - h2);
            thumb.lineTo(kx + w, ky - h1);
            thumb.closeSubPath();
        }
        else
        {
            kx += align;
            thumb.startNewSubPath(kx, ky);
            thumb.lineTo(kx - h1, ky - w);
            thumb.lineTo(kx - h1 - h2, ky - w);
            thumb.lineTo(kx - h1 - h2, ky + w);
            thumb.lineTo(kx - h1, ky + w);
            thumb.closeSubPath();
        }
        g.setColour(thumbFillColor);
        g.fillPath(thumb);
        g.setColour(thumbLineColor);
        g.strokePath(thumb, { 1.f, PathStrokeType::mitered, PathStrokeType::square });
    }

};

class FilmstripLookAndFeel : public LookAndFeel_V4
{
public:
    FilmstripLookAndFeel(const unsigned char file[], const int fileSize, int framewid, int frameht)
        : frameWidth(framewid), frameHeight(frameht)
    {
        filmStrip = ImageCache::getFromMemory(file, fileSize);
        isVertical = (filmStrip.getWidth() == frameWidth);
        nFrames = isVertical ? filmStrip.getHeight() / frameHeight : filmStrip.getWidth() / frameWidth;
    }
    ~FilmstripLookAndFeel() {}

    void findFilmStripFrame(float sliderPosProportional, int& frameX, int& frameY)
    {
        int frameNumber = jmin(static_cast<int>(floorf(sliderPosProportional * nFrames)), nFrames - 1);
        if (isVertical) {
            frameX = 0;
            frameY = frameNumber * frameHeight;
        }
        else {
            frameX = frameNumber * frameWidth;
            frameY = 0;
        }
    }

    void drawFilmStripFrame(Graphics& g, int x, int y, int width, int height, float sliderPosProportional)
    {
        int frameX;
        int frameY;
        findFilmStripFrame(sliderPosProportional, frameX, frameY);

        x += (width - frameWidth) / 2;
        y += (height - frameHeight) / 2;
        g.drawImage(filmStrip, x, y, frameWidth, frameHeight, frameX, frameY, frameWidth, frameHeight);
    }

    void drawLinearSlider(Graphics& g, int x, int y, int width, int height,
        float sliderPos,
        float minSliderPos,
        float maxSliderPos,
        const Slider::SliderStyle style, Slider& slider) override
    {
        if (style == Slider::SliderStyle::LinearVertical)
        {
            float sliderPosProportional = (y + height - sliderPos) / height;
            drawFilmStripFrame(g, x, y, width, height, sliderPosProportional);
        }
        else if (style == Slider::SliderStyle::LinearHorizontal)
        {
            float sliderPosProportional = (sliderPos - x) / width;
            drawFilmStripFrame(g, x, y, width, height, sliderPosProportional);
        }
        else
        {
            LookAndFeel_V4::drawLinearSlider(g, x, y, width, height, sliderPos, minSliderPos, maxSliderPos, style, slider);
        }
    }

    void drawRotarySlider(Graphics&g, int x, int y, int width, int height,
        float sliderPosProportional, float rotaryStartAngle,
        float rotaryEndAngle, Slider& slider) override
    {
        (void)rotaryStartAngle;
        (void)rotaryEndAngle;
        (void)slider;

        drawFilmStripFrame(g, x, y, width, height, sliderPosProportional);
    }

    void drawToggleButton(Graphics& g, ToggleButton& button, bool isMouseOverButton, bool isButtonDown) override
    {
        (void)isMouseOverButton;
        (void)isButtonDown;

        Rectangle<int> r = button.getLocalBounds();

        int x = r.getX();
        int y = r.getY();
        int width = r.getWidth();
        int height = r.getHeight();
        float proportion = button.getToggleState() ? 1.f : 0.f;
        drawFilmStripFrame(g, x, y, width, height, proportion);
    }

private:
    Image filmStrip;
    int frameWidth;
    int frameHeight;
    int nFrames;
    bool isVertical;
};

struct BetterSlider : public Slider
{
    BetterSlider ()
        : doLog(false)
    {}

    String getTextFromValue(double v) override
    {
        if (textFromValueFunction != nullptr)
            return textFromValueFunction(v) 
            + getTextValueSuffix(); // Slider::getTextFromValue() omits this.

        if (getNumDecimalPlacesToDisplay() > 0)
            return String(v, getNumDecimalPlacesToDisplay()) + getTextValueSuffix();

        return String(roundToInt(v)) + getTextValueSuffix();
    }

    double proportionOfLengthToValue(double proportion) override
    {
        if (doLog) 
        {
            double min = getMinimum();
            double max = getMaximum();
            return min * pow(max / min, proportion);
        }
        else 
        {
            return Slider::proportionOfLengthToValue(proportion);
        }
    }

    double valueToProportionOfLength(double value) override
    {
        if (doLog)
        {
            double min = getMinimum();
            double max = getMaximum();
            return log(value / min) / log(max / min);
        } 
        else
        {
            return Slider::valueToProportionOfLength(value);
        }
    }

    bool doLog;
};

class ParamWidget
{
public:
    ParamWidget(AudioProcessorEditor& parent,
        AudioProcessorValueTreeState& vts,
        const String& parameterID,
        Rectangle<int> displayNameBounds,
        const String& displayNameJustification)
    {
        parent.addAndMakeVisible(displayName);
        displayName.setBounds(displayNameBounds);

        if (displayNameJustification == "above")
            displayName.setJustificationType(Justification::centredTop);
        else if (displayNameJustification == "below")
            displayName.setJustificationType(Justification::centredBottom);
        else if (displayNameJustification == "left")
            displayName.setJustificationType(Justification::centredLeft);
        else if (displayNameJustification == "right")
            displayName.setJustificationType(Justification::centredRight);

        displayName.setText(vts.getParameter(parameterID)->name, dontSendNotification);
        displayName.setColour(Label::textColourId, getForegroundColor());
    }

    virtual ~ParamWidget() {}

protected:
    Label displayName;
    float getFloatParameterValue(AudioProcessorValueTreeState& vts, const String& parameterID) {
        return gfp(vts.getRawParameterValue(parameterID));
    }
private:
    float gfp(std::atomic<float>* paValue) {
        return paValue->load(std::memory_order_relaxed);
    }
    float gfp(float* pValue) {
        return (*pValue);
    }
};

class SliderKnob : public ParamWidget
{
public:
    SliderKnob(AudioProcessorEditor& parent,
        AudioProcessorValueTreeState& vts,
        const String& parameterID,
        const String& displayNameJustification,
        const String& style,
        const String& editBoxPosition,
        bool doLog, 
        Rectangle<int> displayNameBounds,
        Rectangle<int> controlBounds,
        LookAndFeel* filmstrip)
        : ParamWidget(parent, vts, parameterID, displayNameBounds, displayNameJustification),
        attachment(vts, parameterID, slider)
    {
        int textBoxWidth = 75;
		parent.addAndMakeVisible(slider);
        slider.doLog = doLog;
		slider.setBounds(controlBounds);
        slider.setTooltip(displayName.getText());
        if (style == "hslider")
            slider.setSliderStyle(Slider::LinearHorizontal);
        else if (style == "vslider")
            slider.setSliderStyle(Slider::LinearVertical);
        else
            slider.setSliderStyle(Slider::RotaryHorizontalVerticalDrag);

        Slider::TextEntryBoxPosition textBoxPosition = Slider::NoTextBox;
        if (editBoxPosition == "editleft")
            textBoxPosition = Slider::TextBoxLeft;
        else if (editBoxPosition == "editright")
            textBoxPosition = Slider::TextBoxRight;
        else if (editBoxPosition == "editabove")
            textBoxPosition = Slider::TextBoxAbove;
        else if (editBoxPosition == "editbelow")
            textBoxPosition = Slider::TextBoxBelow;

        slider.setTextBoxStyle(textBoxPosition, false, textBoxWidth, 20);
        slider.setColour(Slider::textBoxTextColourId, getForegroundColor());
        slider.setTextValueSuffix(" " + vts.getParameter(parameterID)->label);

        slider.setLookAndFeel(filmstrip);
    }

    BetterSlider slider;
    SliderAttachment attachment;
};

class DropDown : public ParamWidget
{
public:
    DropDown(AudioProcessorEditor& parent,
            AudioProcessorValueTreeState& vts,
            const String& parameterID,
            const String& displayNameJustification,
            const StringArray& itemList,
            Rectangle<int> displayNameBounds,
            Rectangle<int> controlBounds,
            LookAndFeel* filmstrip)
    : ParamWidget(parent, vts, parameterID, displayNameBounds, displayNameJustification),
      attachment(vts, parameterID, combo)
    {
        parent.addAndMakeVisible(combo);
        combo.setBounds(controlBounds);
        combo.setTooltip(displayName.getText());

        combo.addItemList(itemList, 1);
        combo.setSelectedItemIndex(roundToInt(getFloatParameterValue(vts, parameterID)), dontSendNotification);

        combo.setLookAndFeel(filmstrip);
    }

private:
    ComboBox combo;
    ComboBoxAttachment attachment;
};

class CheckBox : public ParamWidget
{
public:
    CheckBox(AudioProcessorEditor& parent,
             AudioProcessorValueTreeState& vts,
             const String& parameterID,
             const String& displayNameJustification,
             Rectangle<int> displayNameBounds,
             Rectangle<int> controlBounds,
             LookAndFeel* filmstrip)
        : ParamWidget(parent, vts, parameterID, displayNameBounds, displayNameJustification),
        button(displayNameJustification == "none" ? vts.getParameter(parameterID)->name : ""),
        attachment(vts, parameterID, button)
    {
        parent.addAndMakeVisible (button);
        button.setBounds(controlBounds);
        button.setTooltip(displayName.getText());

        button.setToggleState(getFloatParameterValue(vts, parameterID) >= 0.5f, dontSendNotification);
        button.setColour(ToggleButton::textColourId, getForegroundColor());
        button.setColour(ToggleButton::tickColourId, getForegroundColor());
        button.setColour(ToggleButton::tickDisabledColourId, getForegroundColor());

        button.setLookAndFeel(filmstrip);
        if (displayNameJustification == "none")
        {
            button.changeWidthToFitText();
            displayName.setBounds({ 0, 0, 0, 0 });
        }
    }

private:
    ToggleButton button;
    ButtonAttachment attachment;
};

class ToggleRocker : public ParamWidget
{
public:
    ToggleRocker(AudioProcessorEditor& parent,
        AudioProcessorValueTreeState& vts,
        const String& parameterID,
        const String& displayNameJustification,
        const StringArray& itemList, 
        Rectangle<int> displayNameBounds,
        Rectangle<int> controlBounds,
        LookAndFeel* filmstrip)
        : ParamWidget(parent, vts, parameterID, displayNameBounds, displayNameJustification),
        button(vts.getParameter(parameterID)->name),
        attachment(vts, parameterID, button)
    {
        parent.addAndMakeVisible(label0);
        label0.setBounds(controlBounds.removeFromBottom(20));
        label0.setJustificationType(Justification::centred);
        label0.setText(itemList[0], dontSendNotification);
        label0.setColour(Label::textColourId, getForegroundColor());

        parent.addAndMakeVisible(label1);
        label1.setBounds(controlBounds.removeFromTop(20));
        label1.setJustificationType(Justification::centred);
        label1.setText(itemList[1], dontSendNotification);
        label1.setColour(Label::textColourId, getForegroundColor());

        parent.addAndMakeVisible(button);
        button.setBounds(controlBounds);
        button.setTooltip(displayName.getText());

        button.setToggleState(getFloatParameterValue(vts, parameterID) >= 0.5f, dontSendNotification);

        button.setLookAndFeel(filmstrip);
     }

private:
    Label label0;
    Label label1;
    ToggleButton button;
    ButtonAttachment attachment;
};


//==============================================================================
/**
*/
class Infinite_ReverbAudioProcessorEditor  : public AudioProcessorEditor
{
public:
    Infinite_ReverbAudioProcessorEditor (Infinite_ReverbAudioProcessor& p,
            AudioProcessorValueTreeState& vts)
        : AudioProcessorEditor (&p), processor (p), valueTreeState (vts), tooltip(this)
        {

        Typeface::Ptr noto = Typeface::createSystemTypefaceFor(notoSansFile, notoSansFileSize);
        appdeslnf.setDefaultSansSerifTypeface(noto);

        widgets.add (new SliderKnob(*this, vts, "sustain", "right", "hslider", "editright", 0, {10, 30, 154, 30}, {174, 30, 400, 30}, &appdeslnf));
        widgets.add (new SliderKnob(*this, vts, "low", "right", "hslider", "editright", 0, {10, 70, 154, 30}, {174, 70, 400, 30}, &appdeslnf));
        widgets.add (new SliderKnob(*this, vts, "high", "right", "hslider", "editright", 0, {10, 110, 154, 30}, {174, 110, 400, 30}, &appdeslnf));
        widgets.add (new SliderKnob(*this, vts, "init_att", "right", "hslider", "editright", 0, {10, 150, 154, 30}, {174, 150, 400, 30}, &appdeslnf));
        widgets.add (new SliderKnob(*this, vts, "amp_db", "right", "hslider", "editright", 0, {10, 190, 154, 30}, {174, 190, 400, 30}, &appdeslnf));

        setSize(584, 230);
    }

    ~Infinite_ReverbAudioProcessorEditor()
    {
    }


    //==============================================================================
    void paint (Graphics& g) override
    {
        g.fillAll (getBackgroundColor());

    }

private:
    Infinite_ReverbAudioProcessor& processor;
    AudioProcessorValueTreeState& valueTreeState;
    TooltipWindow tooltip;
    AppDesLookAndFeel appdeslnf;


    OwnedArray<ParamWidget> widgets;

    static const unsigned char notoSansFile[];
    static const int notoSansFileSize;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (Infinite_ReverbAudioProcessorEditor)
};

#include "Infinite_ReverbPluginEditorResources.h"


