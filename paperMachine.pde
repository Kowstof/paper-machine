import java.util.*;
import processing.video.*;
import beads.*;

Capture cam;
AudioContext ac;

int beats = 16;
String[] samples = {"kick.wav", "snare.wav", "hat.wav", "open_hat.wav", "clap.wav", "crash.wav"};
int bpm = 120;
int xOffset = 110;
int yOffset = 76;
int stepWidth = 30;
int stepHeight = 35;
Channel[] channels = new Channel[samples.length];

void setup() {
  size(640, 480);
  frameRate(60);
  colorMode(RGB, 255, 255, 255);
  cam = new Capture(this);
  ac = new AudioContext();
  cam.start();

  for (int i = 0; i < samples.length; i++) {
    channels[i] = new Channel(beats, 100, 80, samples[i]);
  }
  updateBeats();
  play();
}



void draw() {
  if (cam.available())
    cam.read();
  image(cam, 0, 0);
  drawGrid(); // comment this like to toggle overlay
}



void play() {
  Clock clock = new Clock(ac, 1000 * 60 / (bpm * 4)); // the equation converts set bpm to milisecond intervals
  clock.addMessageListener(
    new Bead() {
    public void messageReceived(Bead message) {
      Clock c = (Clock)message;
      if (c.getBeatCount() == beats) {
        updateBeats();
        c.reset();
      }

      if (c.isBeat()) {
        int beat = c.getBeatCount();

        for (Channel channel : channels) {
          SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(channel.sample));
          Gain gain = new Gain(ac, 1, channel.velocities[beat]);
          gain.addInput(player);
          ac.out.addInput(gain);
        }
      }
    }
  }
  );

  ac.out.addDependent(clock);
  ac.start();
}

void drawGrid() {
  for (int channel = 0; channel < channels.length; channel++) {
    for (int step = 0; step < beats; step++) {

      int startX = xOffset + (step * stepWidth);
      int startY = yOffset + (channel * stepHeight);
      color avgColour = getAverageColour(channel, step);
      float h = hue(avgColour);
      float s = saturation(avgColour);
      float b = brightness(avgColour);

      String label = "";
      fill(avgColour);
      //noFill();
      //noStroke();
      rect(startX, startY, stepWidth, stepHeight);

      if (h > 0 && h < 19 && s > 40 && b > 20) { // red
        fill(255, 0, 0);
        label = "HI";
      } else if (h > 60 && h < 145 && s > 40 && b > 20) { // green
        fill(0, 255, 0);
        label = "LO";
      } else if (h > 146 && h < 260 && s > 40 && b > 20) { // blue
        fill(0, 0, 255);
        label = "MID";
      } else {
        fill(0);
        label = "OFF";
      }

      text(label, startX + 5, startY + 25);
    }
  }
}

void updateBeats() {
  for (int channel = 0; channel < channels.length; channel++) {
    for (int step = 0; step < beats; step++) {
      float value = checkStep(channel, step);
      channels[channel].updateBeat(step, value);
    }
  }
}

float checkStep(int channel, int step) {
  color avgColour = getAverageColour(channel, step);
  float h = hue(avgColour);
  float s = saturation(avgColour);
  float b = brightness(avgColour);

  if (h > 0 && h < 19 && s > 40 && b > 20) // red
    return 1;
  else if (h > 60 && h < 145 && s > 40 && b > 20) // green
    return 0.25;
  else if (h > 146 && h < 260 && s > 40 && b > 20) // blue
    return 0.5;
  else
    return 0;
}

color getAverageColour(int channel, int step) {
  float r = 0;
  float g = 0;
  float b = 0;
  int pixelCount = 0;
  int startX = xOffset + (step * stepWidth);
  int startY = yOffset + (channel * stepHeight);

  for (int x = startX; x <= startX + stepWidth; x++) {
    for (int y = startY; y <= startY + stepHeight; y++) {
      color c = cam.get(x, y);
      r += red(c);
      g += green(c);
      b += blue(c);
      pixelCount++;
    }
  }
  return color(r / pixelCount, g / pixelCount, b / pixelCount);
}
